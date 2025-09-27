"""
Celestial data enrichment processor - clean, focused implementation
Calculates sun, moon, planet, and star positions using Skyfield
"""

import asyncio
import logging
from datetime import datetime
from typing import Dict, Any

from ..enrichment_base import EnrichmentProcessor, EnrichmentContext, EnrichmentResult

logger = logging.getLogger(__name__)


class CelestialEnrichmentProcessor(EnrichmentProcessor):
    """Celestial data enrichment (sun, moon, planets, stars) using Skyfield"""

    def __init__(self):
        self._skyfield_available = False
        try:
            import skyfield
            self._skyfield_available = True
            logger.info("Skyfield available for celestial calculations")
        except ImportError:
            logger.error("Skyfield not available - celestial calculations will fail")

    @property
    def name(self) -> str:
        return "celestial"

    @property
    def timeout_seconds(self) -> int:
        return 8  # Skyfield can be slow on first load

    @property
    def priority(self) -> int:
        return 3  # Medium priority - after weather but before satellites

    async def is_available(self) -> bool:
        return self._skyfield_available

    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Calculate celestial object positions and visibility - no fallbacks, proper calculations only"""

        # Require proper skyfield - fail if not available
        if not await self.is_available():
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error="Skyfield not available - celestial calculations require proper astronomical library"
            )

        try:
            start_time = datetime.utcnow()
            logger.info(f"🌌 CELESTIAL: Starting calculation for {context.latitude}, {context.longitude} at {context.timestamp}")

            # Use proper skyfield calculation
            data = await self._calculate_celestial_data_skyfield(context)

            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            logger.info(f"🌌 CELESTIAL: Calculation completed in {processing_time}ms")

            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=data,
                processing_time_ms=processing_time,
                confidence_score=0.95,
                metadata={
                    "source": "skyfield",
                    "calculation_method": "precise"
                }
            )

        except Exception as e:
            logger.error(f"🌌 CELESTIAL: Calculation failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=f"Celestial calculation failed: {e}"
            )

    async def _calculate_celestial_data_skyfield(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Calculate celestial data using proper Skyfield astronomy library"""

        logger.info(f"🌌 SKYFIELD: Calculating for timestamp {context.timestamp}")

        # Import here to avoid startup delays
        import subprocess
        import json

        # Use the dedicated celestial calculation script
        import os

        # Determine correct working directory
        if os.path.exists('/home/ufobeep/ufobeep'):
            cwd = '/home/ufobeep/ufobeep'
            script_path = '/home/ufobeep/ufobeep/api/scripts/calc_celestial.py'
        else:
            cwd = '/home/mike/D/ufobeep'
            script_path = '/home/mike/D/ufobeep/api/scripts/calc_celestial.py'

        cmd = [
            'python3', script_path,
            '--lat', str(context.latitude),
            '--lon', str(context.longitude),
            '--time', context.timestamp.isoformat() + 'Z'
        ]

        logger.info(f"🌌 SKYFIELD: Running command: {' '.join(cmd)} in {cwd}")

        try:
            result = subprocess.run(
                cmd,
                capture_output=True,
                text=True,
                timeout=30,
                cwd=cwd
            )

            logger.info(f"🌌 SKYFIELD: Return code: {result.returncode}")
            logger.info(f"🌌 SKYFIELD: Stdout: {result.stdout[:200]}...")
            logger.info(f"🌌 SKYFIELD: Stderr: {result.stderr}")

            if result.returncode != 0:
                logger.error(f"🌌 SKYFIELD: Calculation failed - {result.stderr}")
                raise Exception(f"Celestial calculation failed: {result.stderr}")

            if not result.stdout.strip():
                logger.error(f"🌌 SKYFIELD: Empty output received")
                raise Exception("Celestial calculation returned empty output")

            # Parse JSON result
            celestial_data = json.loads(result.stdout)
            logger.info(f"🌌 SKYFIELD: Raw calculation successful")

            # Transform to our structured format
            return self._transform_to_structured_format(celestial_data, context)

        except subprocess.TimeoutExpired:
            logger.error(f"🌌 SKYFIELD: Calculation timed out after 30 seconds")
            raise Exception("Celestial calculation timed out")
        except json.JSONDecodeError as e:
            logger.error(f"🌌 SKYFIELD: Invalid JSON response: {e}")
            raise Exception(f"Invalid celestial calculation response: {e}")
        except Exception as e:
            logger.error(f"🌌 SKYFIELD: Unexpected error: {e}")
            raise

    def _transform_to_structured_format(self, celestial_data: Dict[str, Any], context: EnrichmentContext) -> Dict[str, Any]:
        """Transform raw skyfield output to structured format for client consumption"""

        sun_data = celestial_data.get('sun', {})
        moon_data = celestial_data.get('moon', {})
        planets_data = celestial_data.get('planets', {})
        stars_data = celestial_data.get('bright_stars', [])

        # Process sun data
        sun_alt = sun_data.get('altitude', -90)
        sun_visible = sun_alt > -6

        # Classify sun visibility
        if sun_alt > 0:
            visibility_category = "daylight"
        elif sun_alt > -18:
            visibility_category = "twilight"
        else:
            visibility_category = "dark"

        logger.info(f"🌌 SUN: Altitude {sun_alt:.1f}° → {visibility_category}")

        # Process planets
        visible_planets = []
        for planet_name, planet_data in planets_data.items():
            if isinstance(planet_data, dict):
                altitude = planet_data.get('altitude', 0)
                if altitude > 5:  # Only include planets above 5° horizon
                    visible_planets.append({
                        "name": planet_name.title(),
                        "altitude": altitude,
                        "azimuth": planet_data.get('azimuth', 0),
                        "magnitude": planet_data.get('magnitude'),
                        "is_prominent": altitude > 45,
                        "visibility_category": "high" if altitude > 45 else ("medium" if altitude > 20 else "low")
                    })

        # Process stars
        bright_stars = []
        for star in stars_data:
            if isinstance(star, dict):
                bright_stars.append({
                    "name": star.get('name', 'Unknown'),
                    "altitude": star.get('altitude', 0),
                    "azimuth": star.get('azimuth', 0),
                    "magnitude": star.get('magnitude'),
                    "brightness_category": "very_bright" if (star.get('magnitude') or 3) < 1.0 else "prominent"
                })

        logger.info(f"🌌 RESULT: {len(visible_planets)} planets, {len(bright_stars)} stars visible")

        return {
            "sun": {
                "altitude": sun_alt,
                "azimuth": sun_data.get('azimuth', 0),
                "is_visible": sun_visible,
                "visibility_category": visibility_category
            },
            "moon": {
                "altitude": moon_data.get('altitude', -90),
                "azimuth": moon_data.get('azimuth', 0),
                "is_visible": moon_data.get('altitude', -90) > 0,
                "phase_name": moon_data.get('phase', 'New Moon'),
                "phase_fraction": moon_data.get('illumination', 0) / 100.0,
                "illumination": moon_data.get('illumination', 0),
                "brightness_category": self._classify_moon_brightness(moon_data.get('illumination', 0))
            },
            "visible_planets": visible_planets,
            "bright_stars_visible": bright_stars,
            "sky_conditions": {
                "is_daylight": sun_visible,
                "has_moon_illumination": moon_data.get('altitude', -90) > 0,
                "total_bright_objects": len(visible_planets) + len(bright_stars),
                "could_confuse_with_ufos": len(visible_planets) + len(bright_stars) >= 3,
                "visibility_rating": "poor" if sun_visible else "excellent"
            }
        }

    def _classify_moon_brightness(self, illumination: float) -> str:
        """Classify moon brightness category"""
        if illumination > 60:
            return "bright"
        elif illumination > 20:
            return "moderate"
        elif illumination > 5:
            return "thin"
        else:
            return "hidden"