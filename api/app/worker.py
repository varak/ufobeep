
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
            
            return success_count > 0
            
    except Exception as e:
        logger.error(f"Error enriching sighting {sighting_id}: {e}")
        return False


async def get_db_session():
    """Get database session - placeholder for actual DB session"""
    # This is a simplified version - in practice you'd use your actual DB session
    class MockDB:
        async def get(self, model, id):
            # Mock sighting for demonstration
            from app.models.sighting import Sighting, SightingCategory
            from datetime import datetime, timezone
            
            mock_sighting = Sighting()
            mock_sighting.id = id
            mock_sighting.title = "Strange lights in the sky"
            mock_sighting.description = "Saw multiple bright lights moving in formation"
            mock_sighting.category = SightingCategory.UFO
            mock_sighting.exact_latitude = 40.7128
            mock_sighting.exact_longitude = -74.0060
            mock_sighting.exact_altitude = 100.0
            mock_sighting.sensor_timestamp = datetime.now(timezone.utc)
            mock_sighting.azimuth_deg = 45.0
            mock_sighting.pitch_deg = 30.0
            mock_sighting.roll_deg = 0.0
            mock_sighting.weather_data = None
            mock_sighting.celestial_data = None
            mock_sighting.satellite_data = None
            mock_sighting.enrichment_metadata = {}
            mock_sighting.processed_at = None
            
            return mock_sighting
            
        async def commit(self):
            pass
        
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
