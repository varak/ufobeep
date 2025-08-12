
import asyncio
import time
import logging
import json
from datetime import datetime
from typing import Dict, Any, Optional
from uuid import UUID

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


class EnrichmentQueue:
    """Simple in-memory queue for enrichment tasks"""
    
    def __init__(self):
        self._queue = asyncio.Queue()
        self._processing = set()
    
    async def enqueue_sighting(self, sighting_id: str):
        """Add a sighting to the enrichment queue"""
        if sighting_id not in self._processing:
            await self._queue.put(sighting_id)
            logger.info(f"Enqueued sighting {sighting_id} for enrichment")
    
    async def get_next_sighting(self) -> Optional[str]:
        """Get the next sighting to process"""
        try:
            sighting_id = await asyncio.wait_for(self._queue.get(), timeout=1.0)
            self._processing.add(sighting_id)
            return sighting_id
        except asyncio.TimeoutError:
            return None
    
    def mark_completed(self, sighting_id: str):
        """Mark a sighting as completed"""
        self._processing.discard(sighting_id)
        self._queue.task_done()


# Global enrichment queue
enrichment_queue = EnrichmentQueue()


async def enrich_sighting(sighting_id: str) -> bool:
    """
    Enrich a sighting with contextual data using the enrichment pipeline.
    Returns True if successful, False otherwise.
    """
    try:
        from app.services.enrichment_service import enrichment_orchestrator, initialize_enrichment_processors
        from app.services.enrichment_service import EnrichmentContext
        from app.models.sighting import Sighting
        from app.database import get_db_session
        
        logger.info(f"Starting enrichment for sighting {sighting_id}")
        
        # Initialize processors if not already done
        if not enrichment_orchestrator.processors:
            initialize_enrichment_processors()
        
        # Get sighting from database
        async with get_db_session() as db:
            sighting = await db.get(Sighting, UUID(sighting_id))
            if not sighting:
                logger.error(f"Sighting {sighting_id} not found")
                return False
            
            # Create enrichment context
            context = EnrichmentContext(
                sighting_id=sighting_id,
                latitude=sighting.exact_latitude,
                longitude=sighting.exact_longitude,
                altitude=sighting.exact_altitude,
                timestamp=sighting.sensor_timestamp,
                azimuth_deg=sighting.azimuth_deg,
                pitch_deg=sighting.pitch_deg,
                roll_deg=sighting.roll_deg,
                category=sighting.category.value if sighting.category else "unknown",
                title=sighting.title or "",
                description=sighting.description or ""
            )
            
            # Run enrichment pipeline
            enrichment_results = await enrichment_orchestrator.enrich_sighting(context)
            
            # Update sighting with enrichment data
            success_count = 0
            total_count = len(enrichment_results)
            
            enrichment_metadata = {
                "enrichment_timestamp": datetime.utcnow().isoformat(),
                "processors_run": total_count,
                "processors_succeeded": 0,
                "processing_errors": []
            }
            
            # Store enrichment results in sighting
            for processor_name, result in enrichment_results.items():
                if result.success:
                    success_count += 1
                    
                    # Store data in appropriate fields
                    if processor_name == "weather" and result.data:
                        sighting.weather_data = result.data
                    elif processor_name == "celestial" and result.data:
                        sighting.celestial_data = result.data
                    elif processor_name == "satellites" and result.data:
                        sighting.satellite_data = result.data
                    elif processor_name == "content_filter" and result.data:
                        enrichment_metadata["content_analysis"] = result.data
                else:
                    enrichment_metadata["processing_errors"].append({
                        "processor": processor_name,
                        "error": result.error,
                        "timestamp": datetime.utcnow().isoformat()
                    })
                
                # Store processing metadata
                enrichment_metadata[f"{processor_name}_processing_time_ms"] = result.processing_time_ms
                enrichment_metadata[f"{processor_name}_confidence"] = result.confidence_score
            
            enrichment_metadata["processors_succeeded"] = success_count
            sighting.enrichment_metadata = enrichment_metadata
            sighting.processed_at = datetime.utcnow()
            
            await db.commit()
            
            logger.info(f"Enrichment completed for sighting {sighting_id}: "
                       f"{success_count}/{total_count} processors succeeded")
            
            # Trigger alert fanout for nearby users
            if success_count > 0:
                await trigger_alert_fanout(sighting_id, sighting)
            
            return success_count > 0
            
    except Exception as e:
        logger.error(f"Error enriching sighting {sighting_id}: {e}")
        return False


async def get_db_session():
    """Get real database session using the same pool as main.py"""
    try:
        from app.main import db_pool
        
        class DatabaseSession:
            def __init__(self, pool):
                self.pool = pool
                self.conn = None
                
            async def get(self, model, id):
                """Get a record from database by ID"""
                try:
                    from app.models.sighting import Sighting
                    from datetime import datetime
                    
                    if not self.conn:
                        raise Exception("Database connection not established")
                    
                    # Query sighting from database
                    row = await self.conn.fetchrow(
                        """
                        SELECT id, title, description, category, exact_latitude, exact_longitude, 
                               exact_altitude, sensor_timestamp, azimuth_deg, pitch_deg, roll_deg,
                               weather_data, celestial_data, satellite_data, enrichment_metadata, 
                               processed_at, created_at, updated_at, alert_level
                        FROM sightings WHERE id = $1
                        """,
                        str(id)
                    )
                    
                    if not row:
                        return None
                    
                    # Convert row to sighting object
                    sighting = Sighting()
                    sighting.id = row['id']
                    sighting.title = row['title']
                    sighting.description = row['description']
                    sighting.exact_latitude = row['exact_latitude']
                    sighting.exact_longitude = row['exact_longitude']
                    sighting.exact_altitude = row['exact_altitude']
                    sighting.sensor_timestamp = row['sensor_timestamp']
                    sighting.azimuth_deg = row['azimuth_deg']
                    sighting.pitch_deg = row['pitch_deg']
                    sighting.roll_deg = row['roll_deg']
                    sighting.weather_data = row['weather_data']
                    sighting.celestial_data = row['celestial_data']
                    sighting.satellite_data = row['satellite_data']
                    sighting.enrichment_metadata = row['enrichment_metadata'] or {}
                    sighting.processed_at = row['processed_at']
                    sighting.created_at = row['created_at']
                    sighting.updated_at = row['updated_at']
                    
                    return sighting
                    
                except Exception as e:
                    logger.error(f"Error getting sighting {id}: {e}")
                    return None
            
            async def commit(self):
                """Commit changes - handled automatically with asyncpg"""
                pass
            
            async def execute(self, query, *args):
                """Execute a query"""
                if self.conn:
                    return await self.conn.execute(query, *args)
                return None
                
            async def fetch(self, query, *args):
                """Fetch multiple rows"""
                if self.conn:
                    return await self.conn.fetch(query, *args)
                return []
                
            async def fetchrow(self, query, *args):
                """Fetch single row"""
                if self.conn:
                    return await self.conn.fetchrow(query, *args)
                return None
            
            async def __aenter__(self):
                if db_pool:
                    self.conn = await db_pool.acquire()
                return self
            
            async def __aexit__(self, exc_type, exc_val, exc_tb):
                if self.conn and db_pool:
                    await db_pool.release(self.conn)
        
        return DatabaseSession(db_pool)
        
    except Exception as e:
        logger.error(f"Error creating database session: {e}")
        # Fallback to mock for testing
        class MockDB:
            async def get(self, model, id):
                return None
            async def commit(self):
                pass
            async def execute(self, query, *args):
                return None
            async def fetch(self, query, *args):
                return []
            async def fetchrow(self, query, *args):
                return None
            async def __aenter__(self):
                return self
            async def __aexit__(self, exc_type, exc_val, exc_tb):
                pass
        return MockDB()


async def run_enrichment_worker():
    """Run the sighting enrichment worker"""
    logger.info("Starting enrichment worker loop...")
    
    # Initialize enrichment processors
    from app.services.enrichment_service import initialize_enrichment_processors
    initialize_enrichment_processors()
    
    processed_count = 0
    failed_count = 0
    
    while True:
        try:
            # Get next sighting from queue
            sighting_id = await enrichment_queue.get_next_sighting()
            
            if sighting_id:
                logger.info(f"Processing sighting {sighting_id} (total processed: {processed_count})")
                
                # Enrich the sighting
                success = await enrich_sighting(sighting_id)
                
                # Mark as completed
                enrichment_queue.mark_completed(sighting_id)
                
                if success:
                    processed_count += 1
                    logger.info(f"Successfully enriched sighting {sighting_id}")
                else:
                    failed_count += 1
                    logger.warning(f"Failed to enrich sighting {sighting_id}")
                
                # Brief pause between processing
                await asyncio.sleep(0.1)
            else:
                # No work available, sleep longer
                await asyncio.sleep(2)
                
        except KeyboardInterrupt:
            logger.info("Enrichment worker interrupted by user")
            break
        except Exception as e:
            logger.error(f"Error in enrichment worker: {e}")
            failed_count += 1
            await asyncio.sleep(5)
    
    logger.info(f"Enrichment worker stopping. Processed: {processed_count}, Failed: {failed_count}")


async def trigger_enrichment(sighting_id: str):
    """Trigger enrichment for a sighting (called from API endpoints)"""
    await enrichment_queue.enqueue_sighting(sighting_id)


async def trigger_alert_fanout(sighting_id: str, sighting):
    """Trigger alert fanout for newly enriched sightings"""
    try:
        from app.workers.alert_fanout import alert_fanout_worker, SightingEvent
        
        logger.info(f"Triggering alert fanout for sighting {sighting_id}")
        
        # Create sighting event from database sighting
        sighting_event = SightingEvent(
            sighting_id=sighting_id,
            latitude=sighting.exact_latitude,
            longitude=sighting.exact_longitude,
            title=sighting.title,
            description=sighting.description,
            shape=None,  # TODO: extract from enrichment data if available
            confidence_score=None,  # TODO: extract from enrichment data if available
            created_at=sighting.created_at
        )
        
        # Get nearby users from database
        user_locations = await get_nearby_user_locations(
            sighting.exact_latitude, 
            sighting.exact_longitude
        )
        
        # Get device registry from database
        device_registry = await get_device_registry([ul.user_id for ul in user_locations])
        
        # Process the fanout
        results = await alert_fanout_worker.process_new_sighting(
            sighting=sighting_event,
            user_locations=user_locations,
            device_registry=device_registry
        )
        
        logger.info(f"Alert fanout completed for {sighting_id}: {results['notifications_sent']} sent")
        return results
        
    except Exception as e:
        logger.error(f"Error triggering alert fanout for sighting {sighting_id}: {e}")
        return None


async def get_nearby_user_locations(latitude: float, longitude: float):
    """Get users within alert range of a location using Haversine distance"""
    try:
        from app.workers.alert_fanout import UserLocation
        
        async with get_db_session() as db:
            logger.info(f"Querying nearby users for lat={latitude}, lon={longitude}")
            
            # Query users with location and alert preferences
            # Uses Haversine formula for distance calculation in SQL
            users = await db.fetch("""
                SELECT 
                    u.id as user_id,
                    u.location,
                    u.alert_range_km,
                    u.push_notifications,
                    -- Calculate distance using Haversine formula
                    6371 * 2 * ASIN(SQRT(
                        POWER(SIN(RADIANS(CAST(SPLIT_PART(u.location, ',', 1) AS FLOAT) - $1) / 2), 2) +
                        COS(RADIANS($1)) * 
                        COS(RADIANS(CAST(SPLIT_PART(u.location, ',', 1) AS FLOAT))) *
                        POWER(SIN(RADIANS(CAST(SPLIT_PART(u.location, ',', 2) AS FLOAT) - $2) / 2), 2)
                    )) as distance_km
                FROM users u 
                WHERE u.is_active = true 
                  AND u.push_notifications = true
                  AND u.location IS NOT NULL
                  AND u.location != ''
                HAVING distance_km <= u.alert_range_km 
                  AND distance_km <= 100  -- Max system limit
                ORDER BY distance_km ASC
                LIMIT 1000
            """, latitude, longitude)
            
            user_locations = []
            for user in users:
                try:
                    # Parse location string "lat,lon" 
                    if user['location'] and ',' in user['location']:
                        lat_str, lon_str = user['location'].split(',', 1)
                        user_lat = float(lat_str.strip())
                        user_lon = float(lon_str.strip())
                        
                        user_location = UserLocation(
                            user_id=str(user['user_id']),
                            latitude=user_lat,
                            longitude=user_lon,
                            alert_range_km=user['alert_range_km'] or 50.0,
                            max_alerts_per_hour=10,  # Default limit
                            alert_notifications_enabled=user['push_notifications'] or False
                        )
                        user_locations.append(user_location)
                        
                except (ValueError, IndexError) as e:
                    logger.warning(f"Invalid location format for user {user['user_id']}: {user['location']}")
                    continue
            
            logger.info(f"Found {len(user_locations)} users within alert range")
            return user_locations
            
    except Exception as e:
        logger.error(f"Error getting nearby user locations: {e}")
        return []


async def get_device_registry(user_ids: list):
    """Get device registry for a list of user IDs"""
    try:
        device_registry = {}
        
        if not user_ids:
            return device_registry
            
        async with get_db_session() as db:
            logger.info(f"Querying device registry for {len(user_ids)} users")
            
            # Query active devices for the users
            placeholders = ','.join([f'${i+1}' for i in range(len(user_ids))])
            devices = await db.fetch(f"""
                SELECT 
                    user_id,
                    id,
                    device_id,
                    device_name,
                    platform,
                    push_token,
                    push_provider,
                    push_enabled,
                    alert_notifications,
                    chat_notifications,
                    system_notifications,
                    is_active
                FROM devices
                WHERE user_id = ANY(ARRAY[{placeholders}]::UUID[])
                  AND is_active = true
                  AND push_enabled = true
                  AND push_token IS NOT NULL
                  AND push_token != ''
            """, *user_ids)
            
            # Group devices by user_id
            for device in devices:
                user_id = str(device['user_id'])
                
                if user_id not in device_registry:
                    device_registry[user_id] = []
                
                device_data = {
                    "id": str(device['id']),
                    "device_id": device['device_id'],
                    "device_name": device['device_name'],
                    "platform": device['platform'],
                    "push_token": device['push_token'],
                    "push_provider": device['push_provider'],
                    "push_enabled": device['push_enabled'],
                    "alert_notifications": device['alert_notifications'],
                    "chat_notifications": device['chat_notifications'],
                    "system_notifications": device['system_notifications'],
                    "is_active": device['is_active']
                }
                
                device_registry[user_id].append(device_data)
            
            total_devices = sum(len(devices) for devices in device_registry.values())
            logger.info(f"Found {total_devices} active devices for {len(device_registry)} users")
            
            return device_registry
            
    except Exception as e:
        logger.error(f"Error getting device registry: {e}")
        return {}


async def run_alerts_worker():
    """Run the real-time alerts worker"""
    from app.services.alerts_service import alerts_service
    
    logger.info("Starting real-time alerts worker...")
    
    try:
        await alerts_service.run_alerts_loop(interval_seconds=15)
    except Exception as e:
        logger.error(f"Alerts worker error: {e}")


async def run_combined_worker():
    """Run both enrichment and alerts workers concurrently"""
    logger.info("Starting combined UFOBeep background worker...")
    logger.info(f"Worker started at {datetime.utcnow().isoformat()}")
    
    try:
        # Run both workers concurrently
        await asyncio.gather(
            run_enrichment_worker(),
            run_alerts_worker(),
            return_exceptions=True
        )
    except KeyboardInterrupt:
        logger.info("Background worker interrupted by user")
    except Exception as e:
        logger.error(f"Background worker error: {e}")
    finally:
        logger.info("Background worker shutting down...")


if __name__ == "__main__":
    # Run the combined worker with asyncio
    asyncio.run(run_combined_worker())
