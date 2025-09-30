
import asyncio
import time
import logging
import json
from datetime import datetime, timedelta
from typing import Dict, Any, Optional
from uuid import UUID

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)

logger = logging.getLogger(__name__)


def get_local_time(latitude: float, longitude: float) -> datetime:
    """Get accurate local time for coordinates using timezone lookup"""
    try:
        from timezonefinder import TimezoneFinder
        import pytz

        # Find timezone for coordinates
        tf = TimezoneFinder()
        timezone_str = tf.timezone_at(lat=latitude, lng=longitude)
        utc_now = datetime.utcnow().replace(tzinfo=pytz.utc)

        print(f"WORKER DEBUG: Lat/Lon: {latitude}, {longitude}")
        print(f"WORKER DEBUG: Timezone found: {timezone_str}")
        print(f"WORKER DEBUG: UTC time: {utc_now}")

        if timezone_str:
            # Get current time in that timezone
            tz = pytz.timezone(timezone_str)
            local_time = utc_now.astimezone(tz)
            local_naive = local_time.replace(tzinfo=None)
            print(f"WORKER DEBUG: Local time: {local_time}")
            print(f"WORKER DEBUG: Local naive: {local_naive}")
            return local_naive
        else:
            print("WORKER DEBUG: No timezone found, using UTC")
            return datetime.utcnow()

    except Exception as e:
        print(f"WORKER DEBUG: Timezone error: {e}")
        return datetime.utcnow()


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
        
        worker_start_time = datetime.utcnow()
        logger.info(f"🚀 WORKER ENRICHMENT START: Processing sighting {sighting_id}")
        
        # Initialize processors if not already done
        if not enrichment_orchestrator.processors:
            logger.info(f"🔧 WORKER ENRICHMENT: Initializing enrichment processors...")
            initialize_enrichment_processors()
            logger.info(f"🔧 WORKER ENRICHMENT: {len(enrichment_orchestrator.processors)} processors initialized")
        else:
            logger.info(f"🔧 WORKER ENRICHMENT: Using {len(enrichment_orchestrator.processors)} existing processors")
        
        # Get sighting from database using working asyncpg approach
        from app.services.database_service import get_database_pool
        pool = await get_database_pool()

        async with pool.acquire() as conn:
            # Get sighting data
            sighting = await conn.fetchrow("""
                SELECT id, title, description, category, sensor_data,
                       public_latitude, public_longitude, public_latitude as exact_latitude, public_longitude as exact_longitude,
                       created_at, enrichment_data
                FROM sightings WHERE id = $1
            """, UUID(sighting_id))

            if not sighting:
                logger.error(f"❌ Sighting {sighting_id} not found in database")
                return False

            logger.info(f"✅ Sighting {sighting_id} loaded from database")

            # Extract coordinates from sensor_data
            sensor_data = sighting['sensor_data'] or {}

            # Debug data types
            print(f"WORKER DEBUG: sensor_data type: {type(sensor_data)}")
            print(f"WORKER DEBUG: sensor_data: {sensor_data}")

            # Parse sensor_data if it's a JSON string
            if isinstance(sensor_data, str):
                try:
                    import json
                    sensor_data = json.loads(sensor_data)
                    print(f"WORKER DEBUG: Parsed sensor_data: {sensor_data}")
                except Exception as e:
                    print(f"WORKER DEBUG: Failed to parse sensor_data: {e}")
                    sensor_data = {}

            # Fallback to stored coordinates if sensor_data missing
            lat = sensor_data.get('latitude') or sensor_data.get('lat') or \
                  sighting.get('exact_latitude') or sighting.get('public_latitude') or 0
            lon = sensor_data.get('longitude') or sensor_data.get('lng') or \
                  sighting.get('exact_longitude') or sighting.get('public_longitude') or 0

            # Validate coordinates
            if lat is None or lon is None:
                raise ValueError(f"No coordinates available for sighting {sighting_id} - cannot calculate accurate celestial data")

            # Create enrichment context
            context_start = datetime.utcnow()
            context = EnrichmentContext(
                sighting_id=sighting_id,
                latitude=float(lat),
                longitude=float(lon),
                altitude=sensor_data.get('altitude', 0),
                timestamp=datetime.utcnow(),
                azimuth_deg=sensor_data.get('azimuth', 0),
                pitch_deg=sensor_data.get('pitch', 0),
                category=sighting['category'] or "unknown",
                title=sighting['title'] or "",
                description=sighting['description'] or ""
            )
            
            context_time = int((datetime.utcnow() - context_start).total_seconds() * 1000)
            logger.info(f"✅ WORKER ENRICHMENT: Context created ({context_time}ms)")
            
            # Run enrichment pipeline
            pipeline_start = datetime.utcnow()
            logger.info(f"🔄 WORKER ENRICHMENT: Starting enrichment pipeline for sighting {sighting_id}")
            
            enrichment_results = await enrichment_orchestrator.enrich_sighting(context)
            
            pipeline_time = int((datetime.utcnow() - pipeline_start).total_seconds() * 1000)
            logger.info(f"✅ WORKER ENRICHMENT: Pipeline completed ({pipeline_time}ms)")
            
            # Update sighting with enrichment data
            success_count = 0
            total_count = len(enrichment_results)
            
            enrichment_metadata = {
                "enrichment_timestamp": datetime.utcnow().isoformat(),
                "processors_run": total_count,
                "processors_succeeded": 0,
                "processing_errors": []
            }
            
            # Save enrichment results to separate database columns
            for processor_name, result in enrichment_results.items():
                if result.success and result.data:
                    success_count += 1

                    # Save to appropriate column - JSON serialize dict data
                    import json
                    serialized_data = json.dumps(result.data) if isinstance(result.data, dict) else result.data

                    if processor_name == "weather":
                        await conn.execute("UPDATE sightings SET weather_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved weather data")
                    elif processor_name == "celestial":
                        await conn.execute("UPDATE sightings SET celestial_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved celestial data")
                    elif processor_name == "aircraft_tracking":
                        await conn.execute("UPDATE sightings SET aircraft_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved aircraft data")
                    elif processor_name == "satellites":
                        await conn.execute("UPDATE sightings SET satellite_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved satellite data")
                    elif processor_name == "geocoding":
                        await conn.execute("UPDATE sightings SET geocoding_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved geocoding data")
                    elif processor_name == "content_filter":
                        await conn.execute("UPDATE sightings SET content_analysis_data = $2::jsonb WHERE id = $1", UUID(sighting_id), serialized_data)
                        logger.info(f"✅ Saved content analysis data")

                    logger.info(f"✅ {processor_name} enrichment successful")
                else:
                    logger.error(f"❌ {processor_name} enrichment failed: {result.error if result else 'No result'}")

            if success_count == 0:
                logger.warning(f"⚠️ No enrichment data saved for sighting {sighting_id}")
            
            total_worker_time = int((datetime.utcnow() - worker_start_time).total_seconds() * 1000)
            logger.info(f"🎉 WORKER ENRICHMENT FINISHED: Sighting {sighting_id} - {success_count}/{total_count} processors succeeded - Total worker time: {total_worker_time}ms")
            
            # Trigger alert fanout for nearby users
            if success_count > 0:
                logger.info(f"🚨 WORKER ENRICHMENT: Triggering alert fanout for sighting {sighting_id}")
                await trigger_alert_fanout(sighting_id, sighting)
                logger.info(f"✅ WORKER ENRICHMENT: Alert fanout completed for sighting {sighting_id}")
            else:
                logger.warning(f"⚠️  WORKER ENRICHMENT: No successful processors for sighting {sighting_id} - skipping alert fanout")
            
            return success_count > 0
            
    except Exception as e:
        total_worker_time = int((datetime.utcnow() - worker_start_time).total_seconds() * 1000) if 'worker_start_time' in locals() else 0
        logger.error(f"💥 WORKER ENRICHMENT ERROR: Failed to enrich sighting {sighting_id} after {total_worker_time}ms: {e}")
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
                        SELECT id, title, description, category, public_latitude, public_longitude,
                               null as exact_altitude, created_at as sensor_timestamp, null as azimuth_deg, null as pitch_deg, null as roll_deg,
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
                    sighting.exact_latitude = row['public_latitude']
                    sighting.exact_longitude = row['public_longitude']
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
            latitude=sighting['public_latitude'],
            longitude=sighting['public_longitude'],
            title=sighting['title'],
            description=sighting['description'],
            shape=None,  # TODO: extract from enrichment data if available
            confidence_score=None,  # TODO: extract from enrichment data if available
            created_at=sighting['created_at']
        )

        # Get nearby users from database
        user_locations = await get_nearby_user_locations(
            sighting['public_latitude'],
            sighting['public_longitude']
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
        from app.services.database_service import get_database_pool

        pool = await get_database_pool()
        async with pool.acquire() as db:
            logger.info(f"Querying nearby users for lat={latitude}, lon={longitude}")
            
            # Query devices with location and user alert preferences
            # Uses Haversine formula for distance calculation in SQL
            users = await db.fetch("""
                SELECT
                    user_id,
                    lat,
                    lon,
                    alert_range_km,
                    push_notifications,
                    distance_km
                FROM (
                    SELECT
                        d.user_id,
                        d.lat,
                        d.lon,
                        u.alert_range_km,
                        u.push_notifications,
                        -- Calculate distance using Haversine formula
                        6371 * 2 * ASIN(SQRT(
                            POWER(SIN(RADIANS(d.lat - $1) / 2), 2) +
                            COS(RADIANS($1)) *
                            COS(RADIANS(d.lat)) *
                            POWER(SIN(RADIANS(d.lon - $2) / 2), 2)
                        )) as distance_km
                    FROM devices d
                    JOIN users u ON d.user_id = u.id
                    WHERE u.is_active = true
                      AND d.lat IS NOT NULL
                      AND d.lon IS NOT NULL
                      AND d.push_enabled = true
                      AND u.alert_range_km IS NOT NULL
                ) AS nearby
                WHERE distance_km <= alert_range_km
                ORDER BY distance_km ASC
                LIMIT 1000
            """, latitude, longitude)
            
            user_locations = []
            for user in users:
                try:
                    # Use lat/lon from devices table
                    if user['lat'] is not None and user['lon'] is not None:
                        user_lat = float(user['lat'])
                        user_lon = float(user['lon'])
                        
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
