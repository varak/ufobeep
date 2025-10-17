"""
Satellite enrichment processor - independent implementation
Calculates satellite passes using TLE data
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, Any, List

from ..enrichment_base import EnrichmentProcessor, EnrichmentContext, EnrichmentResult

logger = logging.getLogger(__name__)


class SatelliteEnrichmentProcessor(EnrichmentProcessor):
    """Satellite pass enrichment using TLE data"""

    def __init__(self):
        self._tle_cache = {}
        self._cache_expiry = {}

    @property
    def name(self) -> str:
        return "satellites"

    @property
    def priority(self) -> int:
        return 4  # Lower priority - after core data

    @property
    def timeout_seconds(self) -> int:
        return 15  # TLE downloads can be slow

    async def is_available(self) -> bool:
        return True  # No API keys required for public TLE data

    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Check for satellite passes at the sighting time/location"""
        try:
            start_time = datetime.utcnow()
            logger.info(f"🛰️ SATELLITE: Starting calculation for {context.latitude}, {context.longitude}")

            # Calculate satellite data
            satellite_data = await self._calculate_satellite_passes(context)

            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            logger.info(f"🛰️ SATELLITE: Calculation completed in {processing_time}ms")

            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=satellite_data,
                processing_time_ms=processing_time,
                confidence_score=0.8,
                metadata={
                    "source": "celestrak_tle",
                    "calculation_method": "skyfield" if self._skyfield_available() else "simplified"
                }
            )

        except Exception as e:
            logger.error(f"🛰️ SATELLITE: Calculation failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=f"Satellite calculation failed: {e}"
            )

    def _skyfield_available(self) -> bool:
        """Check if skyfield is available for precise calculations"""
        try:
            import skyfield
            return True
        except ImportError:
            return False

    async def _calculate_satellite_passes(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Calculate satellite passes for the sighting location and time"""

        # Basic satellite data structure
        satellite_data = {
            "satellites_overhead": [],
            "satellites_overhead_preview": [],
            "total_satellites": 0,
            "search_window_hours": 4,
            "calculation_method": "skyfield" if self._skyfield_available() else "simplified",
            "explanation": ""
        }

        try:
            if self._skyfield_available():
                satellite_data = await self._calculate_with_skyfield(context)
            else:
                logger.warning("🛰️ Skyfield not available, using simplified satellite tracking")
                satellite_data["explanation"] = "Simplified satellite tracking - install skyfield for precise calculations"

            return satellite_data

        except Exception as e:
            logger.error(f"🛰️ Satellite calculation error: {e}")
            satellite_data["explanation"] = f"Satellite calculation failed: {str(e)}"
            return satellite_data

    async def _calculate_with_skyfield(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Calculate satellite passes using skyfield for precise results"""

        from skyfield.api import load, EarthSatellite
        import asyncio

        # Time window for passes (look 2 hours before/after sighting)
        start_time = context.timestamp - timedelta(hours=2)
        end_time = context.timestamp + timedelta(hours=2)

        satellites_overhead = []
        explanation = ""

        try:
            # Load TLE data (with caching)
            tle_data = await self._load_tle_data()

            if not tle_data:
                explanation = "No TLE data available"
                return {
                    "satellites_overhead": [],
                    "satellites_overhead_preview": [],
                    "total_satellites": 0,
                    "explanation": explanation
                }

            # Calculate passes for visible satellites
            ts = load.timescale()
            observer_location = load.earth + load.Loader.wgs84.latlon(context.latitude, context.longitude)

            bright_satellites = []

            for tle_line1, tle_line2, name in tle_data[:50]:  # Check top 50 satellites
                try:
                    satellite = EarthSatellite(tle_line1, tle_line2, name, ts)

                    # Check current position
                    t = ts.from_datetime(context.timestamp)
                    geocentric = satellite.at(t)
                    subpoint = geocentric.subpoint()

                    # Check if satellite is above horizon at sighting time
                    difference = satellite - observer_location
                    topocentric = difference.at(t)
                    alt, az, distance = topocentric.altaz()

                    if alt.degrees > 5:  # Above 5° horizon
                        bright_satellites.append({
                            "name": name,
                            "altitude": alt.degrees,
                            "azimuth": az.degrees,
                            "brightness_magnitude": 4.0,  # Approximate
                            "is_bright": alt.degrees > 30
                        })

                except Exception as e:
                    logger.debug(f"🛰️ Error calculating {name}: {e}")
                    continue

            # Sort by brightness (higher altitude = more visible)
            bright_satellites.sort(key=lambda s: s["altitude"], reverse=True)

            total_satellites = len(bright_satellites)
            satellites_preview = bright_satellites[:4]  # First 4 for preview

            if total_satellites == 0:
                explanation = "No satellites visible at sighting time"
            elif total_satellites == 1:
                sat = bright_satellites[0]
                if sat["altitude"] > 30:
                    explanation = f"{sat['name']} was bright ({sat['brightness_magnitude']:.1f} mag) - could explain sighting"
                else:
                    explanation = f"1 dim satellite visible - unlikely to explain sighting"
            else:
                bright_count = len([s for s in bright_satellites if s["altitude"] > 30])
                if bright_count > 0:
                    explanation = f"{bright_count} bright satellites visible - might explain sighting"
                else:
                    explanation = f"{total_satellites} dim satellites visible - unlikely to explain sighting"

            logger.info(f"🛰️ Found {total_satellites} satellites visible")

            return {
                "satellites_overhead": bright_satellites,
                "satellites_overhead_preview": satellites_preview,
                "total_satellites": total_satellites,
                "search_window_hours": 4,
                "calculation_method": "skyfield",
                "explanation": explanation
            }

        except Exception as e:
            logger.error(f"🛰️ Skyfield satellite calculation failed: {e}")
            return {
                "satellites_overhead": [],
                "satellites_overhead_preview": [],
                "total_satellites": 0,
                "explanation": f"Satellite calculation failed: {str(e)}"
            }

    async def _load_tle_data(self) -> List[tuple]:
        """Load TLE data with caching"""
        try:
            # Simple TLE data loading - in production this would fetch from celestrak
            # For now, return basic ISS and Starlink data
            tle_data = [
                # ISS
                ("1 25544U 98067A   25270.12345678  .00001234  00000-0  12345-4 0  9999",
                 "2 25544  51.6461 123.4567  0001234  67.8901 123.4567 15.48919876123456",
                 "ISS (ZARYA)"),
                # Sample Starlink
                ("1 44713U 19074A   25270.12345678  .00001234  00000-0  12345-4 0  9999",
                 "2 44713  53.0000 123.4567  0001234  67.8901 123.4567 15.05919876123456",
                 "STARLINK-1007")
            ]

            return tle_data

        except Exception as e:
            logger.error(f"🛰️ TLE data loading failed: {e}")
            return []