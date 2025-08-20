"""
BlackSky enrichment processor for UFOBeep
"""

from datetime import datetime
from typing import Optional
import logging

from app.services.blacksky_service import BlackSkyService
from app.services.enrichment_service import EnrichmentProcessor, EnrichmentResult, EnrichmentContext

logger = logging.getLogger(__name__)


class BlackSkyEnrichmentProcessor(EnrichmentProcessor):
    """BlackSky satellite imagery enrichment processor"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.blacksky_service = BlackSkyService(api_key)
    
    @property
    def name(self) -> str:
        return "blacksky"
    
    async def is_available(self) -> bool:
        """Check if BlackSky processor is available"""
        return await self.blacksky_service.is_available()
    
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Process BlackSky imagery option for the sighting"""
        try:
            start_time = datetime.utcnow()
            
            # Get BlackSky imagery option
            blacksky_data = await self.blacksky_service.get_imagery_option(
                latitude=context.latitude,
                longitude=context.longitude,
                timestamp=context.timestamp
            )
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=blacksky_data,
                processing_time_ms=processing_time,
                confidence_score=1.0,
                metadata={
                    "source": "blacksky_service",
                    "premium_feature": True,
                    "feature_status": "coming_soon"
                }
            )
            
        except Exception as e:
            logger.error(f"BlackSky enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )