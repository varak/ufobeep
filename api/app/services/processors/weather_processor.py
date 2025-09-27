"""
Weather enrichment processor - independent implementation
Fetches weather data using OpenWeather API
"""

import asyncio
import logging
from datetime import datetime
from typing import Dict, Any, Optional

from ..enrichment_base import EnrichmentProcessor, EnrichmentContext, EnrichmentResult

logger = logging.getLogger(__name__)


class WeatherEnrichmentProcessor(EnrichmentProcessor):
    """Weather data enrichment using OpenWeather API"""

    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self._cache = {}  # Simple in-memory cache
        self._cache_ttl_seconds = 600  # 10 minutes

    @property
    def name(self) -> str:
        return "weather"

    @property
    def priority(self) -> int:
        return 1  # High priority - core environmental data

    @property
    def timeout_seconds(self) -> int:
        return 5

    async def is_available(self) -> bool:
        return self.api_key is not None

    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Fetch weather data for the sighting location and time"""
        if not await self.is_available():
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error="OpenWeather API key not configured"
            )

        try:
            start_time = datetime.utcnow()
            logger.info(f"🌤️ WEATHER: Starting fetch for {context.latitude}, {context.longitude}")

            # Fetch weather data
            weather_data = await self._fetch_weather_data(context)

            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            logger.info(f"🌤️ WEATHER: Fetch completed in {processing_time}ms")

            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=weather_data,
                processing_time_ms=processing_time,
                confidence_score=0.9,
                metadata={
                    "source": "openweather",
                    "api_version": "2.5"
                }
            )

        except Exception as e:
            logger.error(f"🌤️ WEATHER: Fetch failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=f"Weather fetch failed: {e}"
            )

    async def _fetch_weather_data(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Fetch weather data from OpenWeather API"""

        import aiohttp
        import json

        # Check cache first
        cache_key = f"{context.latitude:.3f},{context.longitude:.3f}"
        cached_data = self._cache.get(cache_key)

        if cached_data and (datetime.utcnow() - cached_data['timestamp']).seconds < self._cache_ttl_seconds:
            logger.info(f"🌤️ Using cached weather data")
            return cached_data['data']

        # Fetch from API
        url = f"https://api.openweathermap.org/data/2.5/weather"
        params = {
            "lat": context.latitude,
            "lon": context.longitude,
            "appid": self.api_key,
            "units": "metric"
        }

        async with aiohttp.ClientSession() as session:
            async with session.get(url, params=params) as response:
                if response.status != 200:
                    raise Exception(f"OpenWeather API error: {response.status}")

                data = await response.json()

                # Transform to our format
                weather_data = {
                    "temperature": data["main"]["temp"],
                    "humidity": data["main"]["humidity"],
                    "pressure": data["main"]["pressure"],
                    "wind_speed": data.get("wind", {}).get("speed", 0),
                    "wind_direction": data.get("wind", {}).get("deg", 0),
                    "visibility": data.get("visibility", 10000) / 1000.0,  # Convert to km
                    "cloud_cover": data.get("clouds", {}).get("all", 0),
                    "condition": data["weather"][0]["main"],
                    "description": data["weather"][0]["description"]
                }

                # Cache the result
                self._cache[cache_key] = {
                    'data': weather_data,
                    'timestamp': datetime.utcnow()
                }

                logger.info(f"🌤️ Weather: {weather_data['condition']}, {weather_data['temperature']}°C")

                return weather_data