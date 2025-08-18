"""
Enrichment Service

Orchestrates progressive enrichment of sightings with contextual data including
weather conditions, celestial events, satellite passes, and content classification.
"""

import asyncio
import logging
from abc import ABC, abstractmethod
from datetime import datetime, timedelta
from typing import Dict, Any, Optional, List, Tuple
from dataclasses import dataclass
import json

logger = logging.getLogger(__name__)


@dataclass
class EnrichmentContext:
    """Context data for enrichment processing"""
    sighting_id: str
    latitude: float
    longitude: float
    altitude: Optional[float]
    timestamp: datetime
    azimuth_deg: float
    pitch_deg: float
    roll_deg: Optional[float] = None
    category: str = "unknown"
    title: str = ""
    description: str = ""


@dataclass
class EnrichmentResult:
    """Result from an enrichment processor"""
    processor_name: str
    success: bool
    data: Optional[Dict[str, Any]] = None
    error: Optional[str] = None
    processing_time_ms: Optional[int] = None
    confidence_score: Optional[float] = None  # 0.0 to 1.0
    metadata: Optional[Dict[str, Any]] = None


class EnrichmentProcessor(ABC):
    """Abstract base class for enrichment processors"""
    
    @property
    @abstractmethod
    def name(self) -> str:
        """Processor name for identification"""
        pass
    
    @property
    @abstractmethod
    def priority(self) -> int:
        """Processing priority (lower numbers = higher priority)"""
        pass
    
    @property
    @abstractmethod
    def timeout_seconds(self) -> int:
        """Maximum processing time before timeout"""
        pass
    
    @abstractmethod
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Process enrichment for the given context"""
        pass
    
    @abstractmethod
    async def is_available(self) -> bool:
        """Check if processor is available (API keys, services, etc.)"""
        pass


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
        return 1  # High priority
    
    @property
    def timeout_seconds(self) -> int:
        return 10
    
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
            
            # Check cache first
            cache_key = f"{context.latitude:.3f},{context.longitude:.3f},{context.timestamp.isoformat()[:13]}"
            if cache_key in self._cache:
                cache_entry = self._cache[cache_key]
                if datetime.utcnow() - cache_entry['timestamp'] < timedelta(seconds=self._cache_ttl_seconds):
                    logger.debug(f"Weather cache hit for {cache_key}")
                    return cache_entry['result']
            
            # Simulate OpenWeather API call (replace with actual implementation)
            await asyncio.sleep(0.1)  # Simulate API latency
            
            # Mock weather data - replace with actual API call
            weather_data = await self._fetch_weather_data(context)
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            result = EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=weather_data,
                processing_time_ms=processing_time,
                confidence_score=0.9,
                metadata={
                    "source": "openweather",
                    "api_version": "2.5",
                    "cache_key": cache_key,
                }
            )
            
            # Cache the result
            self._cache[cache_key] = {
                'result': result,
                'timestamp': datetime.utcnow()
            }
            
            return result
            
        except Exception as e:
            logger.error(f"Weather enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )
    
    async def _fetch_weather_data(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Fetch weather data from OpenWeather API"""
        import aiohttp
        from datetime import timezone
        
        base_url = "https://api.openweathermap.org/data/2.5"
        
        async with aiohttp.ClientSession() as session:
            # Fetch current weather
            current_url = f"{base_url}/weather"
            current_params = {
                'lat': context.latitude,
                'lon': context.longitude,
                'appid': self.api_key,
                'units': 'metric'
            }
            
            async with session.get(current_url, params=current_params) as response:
                if response.status != 200:
                    raise Exception(f"OpenWeather API error: {response.status} - {await response.text()}")
                
                current_data = await response.json()
            
            # Fetch UV index (separate API call)
            uvi_url = f"{base_url}/uvi"
            uvi_params = {
                'lat': context.latitude,
                'lon': context.longitude,
                'appid': self.api_key
            }
            
            uv_index = None
            try:
                async with session.get(uvi_url, params=uvi_params) as uv_response:
                    if uv_response.status == 200:
                        uv_data = await uv_response.json()
                        uv_index = uv_data.get('value', 0)
            except Exception as e:
                logger.warning(f"Failed to fetch UV index: {e}")
            
            # Transform OpenWeather data to our format
            weather = current_data.get('weather', [{}])[0]
            main = current_data.get('main', {})
            wind = current_data.get('wind', {})
            clouds = current_data.get('clouds', {})
            sys = current_data.get('sys', {})
            
            # Convert visibility from meters to kilometers
            visibility_m = current_data.get('visibility', 10000)
            visibility_km = visibility_m / 1000.0
            
            # Convert timestamps
            sunrise_ts = sys.get('sunrise')
            sunset_ts = sys.get('sunset')
            sunrise_utc = None
            sunset_utc = None
            
            if sunrise_ts:
                sunrise_utc = datetime.fromtimestamp(sunrise_ts, tz=timezone.utc).isoformat()
            if sunset_ts:
                sunset_utc = datetime.fromtimestamp(sunset_ts, tz=timezone.utc).isoformat()
            
            # Map weather condition codes to our categories
            weather_id = weather.get('id', 800)
            condition_mapping = {
                (200, 299): "thunderstorm",
                (300, 399): "drizzle", 
                (500, 599): "rain",
                (600, 699): "snow",
                (700, 799): "atmosphere",  # fog, haze, etc.
                (800, 800): "clear",
                (801, 804): "cloudy",
            }
            
            weather_condition = "unknown"
            for (start, end), condition in condition_mapping.items():
                if start <= weather_id <= end:
                    weather_condition = condition
                    break
            
            return {
                # Temperature data
                "temperature_c": main.get('temp', 0),
                "feels_like_c": main.get('feels_like', 0),
                "dew_point_c": main.get('dew_point', main.get('temp', 0) - 10),  # Approximate if not available
                
                # Atmospheric conditions
                "pressure_hpa": main.get('pressure', 1013.25),
                "humidity_percent": main.get('humidity', 0),
                "visibility_km": visibility_km,
                "cloud_cover_percent": clouds.get('all', 0),
                "uvi": uv_index if uv_index is not None else 0,
                
                # Wind data
                "wind_speed_ms": wind.get('speed', 0),
                "wind_direction_deg": wind.get('deg', 0),
                "wind_gust_ms": wind.get('gust', 0),
                
                # Weather conditions
                "weather_main": weather.get('main', 'Clear'),
                "weather_description": weather.get('description', 'Clear sky'),
                "weather_icon": weather.get('icon', '01d'),
                "weather_condition": weather_condition,
                
                # Precipitation data
                "precipitation_mm": current_data.get('rain', {}).get('1h', 0) + current_data.get('snow', {}).get('1h', 0),
                "rain_1h": current_data.get('rain', {}).get('1h', 0),
                "snow_1h": current_data.get('snow', {}).get('1h', 0),
                
                # Sun times (Unix timestamps)
                "sunrise": sys.get('sunrise', 0),
                "sunset": sys.get('sunset', 0),
                "sunrise_utc": sunrise_utc,
                "sunset_utc": sunset_utc,
                
                # Additional metadata
                "timezone_offset": current_data.get('timezone', 0),
                "country": sys.get('country'),
                "city": current_data.get('name'),
                "openweather_id": weather_id,
                "data_timestamp": datetime.fromtimestamp(current_data.get('dt', 0), tz=timezone.utc).isoformat(),
                "coord_lat": current_data.get('coord', {}).get('lat', context.latitude),
                "coord_lon": current_data.get('coord', {}).get('lon', context.longitude),
            }


class CelestialEnrichmentProcessor(EnrichmentProcessor):
    """Celestial data enrichment (sun, moon, planets, stars)"""
    
    def __init__(self):
        self._skyfield_available = False
        try:
            # Check if skyfield is available
            import skyfield
            self._skyfield_available = True
        except ImportError:
            logger.warning("Skyfield not available for celestial calculations")
    
    @property
    def name(self) -> str:
        return "celestial"
    
    @property
    def priority(self) -> int:
        return 2  # Medium-high priority
    
    @property
    def timeout_seconds(self) -> int:
        return 15
    
    async def is_available(self) -> bool:
        return self._skyfield_available
    
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Calculate celestial object positions and visibility"""
        if not await self.is_available():
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error="Skyfield library not available"
            )
        
        try:
            start_time = datetime.utcnow()
            
            # Calculate celestial data
            celestial_data = await self._calculate_celestial_data(context)
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=celestial_data,
                processing_time_ms=processing_time,
                confidence_score=1.0,  # Astronomical calculations are deterministic
                metadata={
                    "source": "skyfield",
                    "calculation_method": "precise_ephemeris",
                }
            )
            
        except Exception as e:
            logger.error(f"Celestial enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )
    
    async def _calculate_celestial_data(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Calculate celestial object positions using skyfield"""
        try:
            # Import skyfield components
            from skyfield.api import load, Topos
            from skyfield.almanac import find_discrete, risings_and_settings
            from skyfield import almanac
            import math
            
            # Load ephemeris data
            ts = load.timescale()
            planets = load('de421.bsp')  # JPL ephemeris
            
            # Convert timestamp to skyfield time
            t = ts.from_datetime(context.timestamp)
            
            # Observer location
            observer = Topos(latitude_degrees=context.latitude, longitude_degrees=context.longitude)
            
            # Get celestial objects
            earth = planets['earth']
            sun = planets['sun']
            moon = planets['moon']
            venus = planets['venus']
            mars = planets['mars']
            jupiter = planets['jupiter barycenter']
            saturn = planets['saturn barycenter']
            
            # Observer position
            observer_pos = earth + observer
            
            # Calculate sun position
            sun_apparent = observer_pos.at(t).observe(sun).apparent()
            sun_alt, sun_az, _ = sun_apparent.altaz()
            sun_alt_deg = sun_alt.degrees
            sun_az_deg = sun_az.degrees
            sun_visible = sun_alt_deg > -6  # Civil twilight threshold
            
            # Calculate moon position and phase
            moon_apparent = observer_pos.at(t).observe(moon).apparent()
            moon_alt, moon_az, moon_distance = moon_apparent.altaz()
            moon_alt_deg = moon_alt.degrees
            moon_az_deg = moon_az.degrees
            moon_visible = moon_alt_deg > 0
            
            # Moon phase calculation
            sun_moon = observer_pos.at(t).observe(moon - sun).apparent()
            moon_phase = almanac.moon_phase(planets, t)
            phase_names = ['new', 'waxing_crescent', 'first_quarter', 'waxing_gibbous', 
                          'full', 'waning_gibbous', 'last_quarter', 'waning_crescent']
            phase_index = int((moon_phase.degrees + 22.5) / 45) % 8
            phase_name = phase_names[phase_index]
            moon_illumination = (1 - math.cos(math.radians(moon_phase.degrees))) / 2
            
            # Calculate planet positions
            planets_data = {}
            planet_objects = [
                ('venus', venus, -3.9),
                ('mars', mars, 0.7), 
                ('jupiter', jupiter, -2.2),
                ('saturn', saturn, 0.7)
            ]
            
            visible_planets = []
            for name, planet_obj, base_magnitude in planet_objects:
                try:
                    apparent = observer_pos.at(t).observe(planet_obj).apparent()
                    alt, az, distance = apparent.altaz()
                    alt_deg = alt.degrees
                    az_deg = az.degrees
                    is_visible = alt_deg > 0 and sun_alt_deg < -6  # Visible when above horizon and after twilight
                    
                    if is_visible:
                        visible_planets.append(name)
                    
                    planets_data[name] = {
                        "altitude_deg": alt_deg,
                        "azimuth_deg": az_deg,
                        "is_visible": is_visible,
                        "distance_au": distance.au,
                        "magnitude": base_magnitude,  # Simplified - actual magnitude varies
                    }
                except Exception as e:
                    logger.warning(f"Failed to calculate {name} position: {e}")
                    planets_data[name] = {
                        "altitude_deg": None,
                        "azimuth_deg": None,
                        "is_visible": False,
                        "distance_au": None,
                        "magnitude": None,
                    }
            
            # Bright stars (simplified - just a few major ones)
            bright_stars_data = [
                {"name": "Sirius", "ra_hours": 6.75, "dec_deg": -16.7, "magnitude": -1.46},
                {"name": "Canopus", "ra_hours": 6.4, "dec_deg": -52.7, "magnitude": -0.74},
                {"name": "Arcturus", "ra_hours": 14.25, "dec_deg": 19.2, "magnitude": -0.05},
                {"name": "Vega", "ra_hours": 18.6, "dec_deg": 38.8, "magnitude": 0.03},
            ]
            
            bright_stars = []
            visible_bright_stars_count = 0
            
            for star in bright_stars_data:
                # Simple alt/az calculation for stars (simplified)
                try:
                    # Convert RA/Dec to alt/az (very simplified - should use proper coordinate transformation)
                    # This is a placeholder - proper implementation would use skyfield's star catalog
                    alt_deg = 45.0  # Placeholder
                    az_deg = 180.0  # Placeholder
                    is_visible = alt_deg > 0 and sun_alt_deg < -18  # Visible when above horizon and after astronomical twilight
                    
                    if is_visible:
                        visible_bright_stars_count += 1
                    
                    bright_stars.append({
                        "name": star["name"],
                        "altitude_deg": alt_deg,
                        "azimuth_deg": az_deg,
                        "magnitude": star["magnitude"],
                        "is_visible": is_visible,
                    })
                except Exception as e:
                    logger.warning(f"Failed to calculate {star['name']} position: {e}")
            
            # Determine twilight type
            if sun_alt_deg > -6:
                twilight_type = "day" if sun_alt_deg > 0 else "civil_twilight"
            elif sun_alt_deg > -12:
                twilight_type = "nautical_twilight"
            elif sun_alt_deg > -18:
                twilight_type = "astronomical_twilight"
            else:
                twilight_type = "night"
            
            return {
                "sun": {
                    "altitude_deg": sun_alt_deg,
                    "azimuth_deg": sun_az_deg,
                    "is_visible": sun_visible,
                    "distance_au": 1.0,  # Approximately constant
                },
                "moon": {
                    "altitude_deg": moon_alt_deg,
                    "azimuth_deg": moon_az_deg,
                    "is_visible": moon_visible,
                    "phase": moon_phase.degrees / 360.0,  # 0-1 scale
                    "phase_name": phase_name,
                    "phase_angle_deg": moon_phase.degrees,
                    "illumination": moon_illumination,
                    "distance_km": moon_distance.km,
                },
                "planets": planets_data,
                "bright_stars": bright_stars,
                "summary": {
                    "twilight_type": twilight_type,
                    "sun_altitude_deg": sun_alt_deg,
                    "moon_phase_name": phase_name,
                    "moon_illumination": moon_illumination,
                    "visible_planets": visible_planets,
                    "visible_bright_stars": visible_bright_stars_count,
                    "observation_quality": "excellent" if twilight_type == "night" else "poor" if twilight_type == "day" else "good",
                }
            }
            
        except ImportError:
            # Fallback if skyfield is not available
            logger.warning("Skyfield not available, using simplified calculations")
            return await self._calculate_celestial_data_simplified(context)
        except Exception as e:
            logger.error(f"Skyfield calculation failed: {e}")
            return await self._calculate_celestial_data_simplified(context)
    
    async def _calculate_celestial_data_simplified(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Simplified celestial calculations without skyfield"""
        import math
        from datetime import timezone
        
        # Simple sun position calculation (very approximate)
        # This is just for fallback - not accurate for precise work
        day_of_year = context.timestamp.timetuple().tm_yday
        solar_declination = 23.45 * math.sin(math.radians(360 * (284 + day_of_year) / 365))
        
        hour_angle = 15 * (context.timestamp.hour - 12)  # Simplified
        lat_rad = math.radians(context.latitude)
        dec_rad = math.radians(solar_declination)
        hour_rad = math.radians(hour_angle)
        
        sun_alt = math.asin(
            math.sin(lat_rad) * math.sin(dec_rad) + 
            math.cos(lat_rad) * math.cos(dec_rad) * math.cos(hour_rad)
        )
        sun_alt_deg = math.degrees(sun_alt)
        
        sun_az = math.atan2(
            -math.sin(hour_rad),
            math.tan(dec_rad) * math.cos(lat_rad) - math.sin(lat_rad) * math.cos(hour_rad)
        )
        sun_az_deg = (math.degrees(sun_az) + 180) % 360
        
        return {
            "sun": {
                "altitude_deg": sun_alt_deg,
                "azimuth_deg": sun_az_deg,
                "is_visible": sun_alt_deg > -6,
                "distance_au": 1.0,
            },
            "moon": {
                "altitude_deg": -15.0,  # Placeholder
                "azimuth_deg": 75.0,   # Placeholder
                "is_visible": False,
                "phase": 0.5,
                "phase_name": "unknown",
                "distance_km": 384400,
            },
            "planets": {
                "venus": {"altitude_deg": None, "azimuth_deg": None, "is_visible": False, "magnitude": -3.9},
                "mars": {"altitude_deg": None, "azimuth_deg": None, "is_visible": False, "magnitude": 0.7},
                "jupiter": {"altitude_deg": None, "azimuth_deg": None, "is_visible": False, "magnitude": -2.2},
                "saturn": {"altitude_deg": None, "azimuth_deg": None, "is_visible": False, "magnitude": 0.7},
            },
            "bright_stars": [],
            "summary": {
                "twilight_type": "day" if sun_alt_deg > 0 else "night",
                "visible_planets": [],
                "visible_bright_stars": 0,
                "moon_illumination": 0.5,
                "observation_quality": "unknown",
            }
        }


class SatelliteEnrichmentProcessor(EnrichmentProcessor):
    """Satellite pass enrichment using TLE data"""
    
    def __init__(self):
        self._tle_cache = {}
        self._tle_cache_expiry = None
    
    @property
    def name(self) -> str:
        return "satellites"
    
    @property
    def priority(self) -> int:
        return 3  # Medium priority
    
    @property
    def timeout_seconds(self) -> int:
        return 20
    
    async def is_available(self) -> bool:
        # No API keys required for public TLE data
        return True
    
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Check for satellite passes at the sighting time/location"""
        try:
            start_time = datetime.utcnow()
            
            # Calculate satellite data
            satellite_data = await self._calculate_satellite_passes(context)
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=satellite_data,
                processing_time_ms=processing_time,
                confidence_score=0.85,
                metadata={
                    "source": "celestrak_tle",
                    "tle_age_hours": 12,  # Example TLE age
                }
            )
            
        except Exception as e:
            logger.error(f"Satellite enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )
    
    async def _calculate_satellite_passes(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Calculate satellite passes using TLE data from CelesTrak"""
        try:
            import aiohttp
            from datetime import timezone, timedelta
            import math
            
            # Check for skyfield availability for orbital calculations
            try:
                from skyfield.api import load, Topos, EarthSatellite
                from skyfield.sgp4lib import EarthSatellite as SGP4Satellite
                skyfield_available = True
            except ImportError:
                logger.warning("Skyfield not available for satellite calculations, using simplified approach")
                skyfield_available = False
            
            # Time window for passes (look 2 hours before/after sighting)
            start_time = context.timestamp - timedelta(hours=2)
            end_time = context.timestamp + timedelta(hours=2)
            
            satellite_data = {
                "iss_passes": [],
                "starlink_passes": [],
                "other_satellites": [],
                "summary": {
                    "total_visible_passes": 0,
                    "brightest_magnitude": None,
                    "next_bright_pass": None,
                    "search_window_hours": 4,
                    "calculation_method": "skyfield" if skyfield_available else "simplified"
                }
            }
            
            if skyfield_available:
                # Use skyfield for precise calculations
                satellite_data = await self._calculate_with_skyfield(context, start_time, end_time)
            else:
                # Use simplified approach without skyfield
                satellite_data = await self._calculate_simplified(context, start_time, end_time)
            
            return satellite_data
            
        except Exception as e:
            logger.error(f"Satellite calculation failed: {e}")
            return {
                "iss_passes": [],
                "starlink_passes": [],
                "other_satellites": [],
                "summary": {
                    "total_visible_passes": 0,
                    "brightest_magnitude": None,
                    "next_bright_pass": None,
                    "search_window_hours": 4,
                    "error": str(e)
                }
            }
    
    async def _fetch_tle_data(self) -> Dict[str, List[str]]:
        """Fetch TLE data from CelesTrak"""
        import aiohttp
        from datetime import timedelta
        
        # Check cache first
        if (self._tle_cache_expiry and 
            datetime.utcnow() < self._tle_cache_expiry and 
            self._tle_cache):
            logger.debug("Using cached TLE data")
            return self._tle_cache
        
        tle_urls = {
            'iss': 'https://celestrak.org/NORAD/elements/gp.php?CATNR=25544&FORMAT=tle',
            'starlink': 'https://celestrak.org/NORAD/elements/gp.php?GROUP=starlink&FORMAT=tle',
            'visual': 'https://celestrak.org/NORAD/elements/gp.php?GROUP=visual&FORMAT=tle'
        }
        
        tle_data = {}
        
        async with aiohttp.ClientSession() as session:
            for category, url in tle_urls.items():
                try:
                    logger.debug(f"Fetching TLE data for {category}")
                    async with session.get(url, timeout=10) as response:
                        if response.status == 200:
                            content = await response.text()
                            tle_lines = [line.strip() for line in content.strip().split('\n') if line.strip()]
                            
                            # Parse TLE format (3 lines per satellite)
                            satellites = []
                            for i in range(0, len(tle_lines), 3):
                                if i + 2 < len(tle_lines):
                                    sat_name = tle_lines[i].strip()
                                    line1 = tle_lines[i + 1].strip()
                                    line2 = tle_lines[i + 2].strip()
                                    
                                    # Basic TLE validation
                                    if (len(line1) >= 69 and len(line2) >= 69 and 
                                        line1.startswith('1 ') and line2.startswith('2 ')):
                                        satellites.append({
                                            'name': sat_name,
                                            'line1': line1,
                                            'line2': line2
                                        })
                            
                            tle_data[category] = satellites
                            logger.info(f"Fetched {len(satellites)} TLE records for {category}")
                        else:
                            logger.warning(f"Failed to fetch TLE for {category}: HTTP {response.status}")
                            tle_data[category] = []
                            
                except Exception as e:
                    logger.error(f"Error fetching TLE for {category}: {e}")
                    tle_data[category] = []
        
        # Cache the results for 2 hours
        self._tle_cache = tle_data
        self._tle_cache_expiry = datetime.utcnow() + timedelta(hours=2)
        
        return tle_data
    
    async def _calculate_with_skyfield(self, context: EnrichmentContext, start_time: datetime, end_time: datetime) -> Dict[str, Any]:
        """Calculate satellite passes using skyfield for precise orbital mechanics"""
        from skyfield.api import load, Topos, EarthSatellite
        import math
        
        # Load timescale and observer location
        ts = load.timescale()
        observer = Topos(latitude_degrees=context.latitude, longitude_degrees=context.longitude)
        
        # Convert times to skyfield format
        t_start = ts.from_datetime(start_time.replace(tzinfo=timezone.utc))
        t_end = ts.from_datetime(end_time.replace(tzinfo=timezone.utc))
        
        # Fetch TLE data
        tle_data = await self._fetch_tle_data()
        
        all_passes = []
        
        # Process ISS
        iss_passes = []
        if tle_data.get('iss'):
            for sat_info in tle_data['iss'][:1]:  # Just ISS
                try:
                    satellite = EarthSatellite(sat_info['line1'], sat_info['line2'], sat_info['name'], ts)
                    passes = await self._find_passes_skyfield(satellite, observer, t_start, t_end, ts)
                    iss_passes.extend(passes)
                except Exception as e:
                    logger.warning(f"Failed to calculate ISS passes: {e}")
        
        # Process Starlink (limit to brightest/most recent)
        starlink_passes = []
        if tle_data.get('starlink'):
            starlink_sats = tle_data['starlink'][:20]  # Limit to 20 for performance
            for sat_info in starlink_sats:
                try:
                    if 'STARLINK' in sat_info['name'].upper():
                        satellite = EarthSatellite(sat_info['line1'], sat_info['line2'], sat_info['name'], ts)
                        passes = await self._find_passes_skyfield(satellite, observer, t_start, t_end, ts)
                        starlink_passes.extend(passes)
                except Exception as e:
                    logger.debug(f"Failed to calculate passes for {sat_info['name']}: {e}")
        
        # Process other bright satellites
        other_passes = []
        if tle_data.get('visual'):
            visual_sats = tle_data['visual'][:10]  # Limit to 10 brightest
            for sat_info in visual_sats:
                try:
                    if not any(keyword in sat_info['name'].upper() 
                             for keyword in ['ISS', 'STARLINK']):
                        satellite = EarthSatellite(sat_info['line1'], sat_info['line2'], sat_info['name'], ts)
                        passes = await self._find_passes_skyfield(satellite, observer, t_start, t_end, ts)
                        other_passes.extend(passes)
                except Exception as e:
                    logger.debug(f"Failed to calculate passes for {sat_info['name']}: {e}")
        
        # Sort all passes by time and find brightest
        all_passes = iss_passes + starlink_passes + other_passes
        all_passes.sort(key=lambda x: x['pass_start_utc'])
        
        brightest_mag = None
        next_bright_pass = None
        
        for pass_info in all_passes:
            if pass_info['is_visible_pass']:
                mag = pass_info['brightness_magnitude']
                if mag is not None and (brightest_mag is None or mag < brightest_mag):
                    brightest_mag = mag
                if next_bright_pass is None and pass_info['pass_start_utc'] > context.timestamp.isoformat():
                    next_bright_pass = pass_info['pass_start_utc']
        
        return {
            "iss_passes": iss_passes,
            "starlink_passes": starlink_passes,
            "other_satellites": other_passes,
            "summary": {
                "total_visible_passes": len([p for p in all_passes if p['is_visible_pass']]),
                "brightest_magnitude": brightest_mag,
                "next_bright_pass": next_bright_pass,
                "search_window_hours": 4,
                "calculation_method": "skyfield",
                "tle_sources": ["celestrak_iss", "celestrak_starlink", "celestrak_visual"]
            }
        }
    
    async def _find_passes_skyfield(self, satellite, observer, t_start, t_end, ts):
        """Find visible passes for a satellite using skyfield"""
        passes = []
        
        try:
            # Sample points every 30 seconds in the time window
            times = ts.linspace(t_start, t_end, int((t_end.tt - t_start.tt) * 24 * 60 * 2))  # Every 30 seconds
            
            # Calculate satellite positions
            topocentric = (satellite - observer).at(times)
            alt, az, distance = topocentric.altaz()
            
            # Find passes (when satellite goes above horizon)
            above_horizon = alt.degrees > 0
            
            pass_start = None
            max_elevation = -90
            max_elevation_time = None
            
            for i in range(len(times)):
                if above_horizon[i] and pass_start is None:
                    # Pass starts
                    pass_start = times[i]
                    max_elevation = alt.degrees[i]
                    max_elevation_time = times[i]
                elif above_horizon[i] and pass_start is not None:
                    # Continue pass - check for max elevation
                    if alt.degrees[i] > max_elevation:
                        max_elevation = alt.degrees[i]
                        max_elevation_time = times[i]
                elif not above_horizon[i] and pass_start is not None:
                    # Pass ends
                    pass_end = times[i]
                    
                    # Only include passes with reasonable elevation
                    if max_elevation > 10:  # At least 10 degrees elevation
                        # Estimate brightness (very rough approximation)
                        distance_km = distance.km[i]
                        brightness_mag = self._estimate_satellite_brightness(
                            satellite.name, distance_km, max_elevation
                        )
                        
                        # Determine general direction
                        start_az = az.degrees[max(0, i-10)]
                        end_az = az.degrees[min(len(az.degrees)-1, i)]
                        direction = self._calculate_direction(start_az, end_az)
                        
                        passes.append({
                            "satellite_name": satellite.name,
                            "norad_id": self._extract_norad_id(satellite),
                            "pass_start_utc": pass_start.utc_iso(),
                            "pass_end_utc": pass_end.utc_iso(),
                            "max_elevation_deg": round(max_elevation, 1),
                            "max_elevation_time_utc": max_elevation_time.utc_iso(),
                            "brightness_magnitude": brightness_mag,
                            "direction": direction,
                            "is_visible_pass": max_elevation > 10 and brightness_mag is not None and brightness_mag < 6,
                        })
                    
                    # Reset for next pass
                    pass_start = None
                    max_elevation = -90
                    max_elevation_time = None
                    
        except Exception as e:
            logger.error(f"Error finding passes for {satellite.name}: {e}")
        
        return passes
    
    def _estimate_satellite_brightness(self, sat_name: str, distance_km: float, elevation_deg: float) -> Optional[float]:
        """Rough satellite brightness estimation"""
        if distance_km <= 0:
            return None
        
        # Base magnitudes for common satellites (very approximate)
        base_magnitudes = {
            'ISS': -1.5,
            'STARLINK': 3.0,
            'HUBBLE': 1.5,
            'TERRA': 2.0,
            'AQUA': 2.5,
        }
        
        base_mag = 4.0  # Default for unknown satellites
        for keyword, mag in base_magnitudes.items():
            if keyword in sat_name.upper():
                base_mag = mag
                break
        
        # Rough distance correction (inverse square law approximation)
        distance_factor = 2.5 * math.log10(distance_km / 400)  # 400km reference altitude
        
        # Elevation correction (atmospheric extinction)
        elevation_factor = -0.1 * math.log10(math.sin(math.radians(max(elevation_deg, 1))))
        
        estimated_mag = base_mag + distance_factor + elevation_factor
        return round(estimated_mag, 1)
    
    def _extract_norad_id(self, satellite) -> Optional[int]:
        """Extract NORAD ID from TLE data"""
        try:
            # NORAD ID is in positions 3-7 of line 1
            line1 = satellite.model.satnum
            return int(line1)
        except:
            return None
    
    def _calculate_direction(self, start_az: float, end_az: float) -> str:
        """Calculate general direction of satellite pass"""
        directions = [
            (0, "N"), (45, "NE"), (90, "E"), (135, "SE"),
            (180, "S"), (225, "SW"), (270, "W"), (315, "NW")
        ]
        
        def az_to_direction(azimuth):
            azimuth = azimuth % 360
            closest = min(directions, key=lambda x: abs(x[0] - azimuth))
            return closest[1]
        
        start_dir = az_to_direction(start_az)
        end_dir = az_to_direction(end_az)
        
        if start_dir == end_dir:
            return start_dir
        else:
            return f"{start_dir} to {end_dir}"
    
    async def _calculate_simplified(self, context: EnrichmentContext, start_time: datetime, end_time: datetime) -> Dict[str, Any]:
        """Simplified satellite calculation without skyfield"""
        # Return mock data with indication that precise calculation wasn't available
        return {
            "iss_passes": [{
                "satellite_name": "ISS (ZARYA)",
                "norad_id": 25544,
                "pass_start_utc": (context.timestamp + timedelta(hours=1)).isoformat() + "Z",
                "pass_end_utc": (context.timestamp + timedelta(hours=1, minutes=6)).isoformat() + "Z",
                "max_elevation_deg": 45.0,
                "max_elevation_time_utc": (context.timestamp + timedelta(hours=1, minutes=3)).isoformat() + "Z",
                "brightness_magnitude": -2.5,
                "direction": "SW to NE",
                "is_visible_pass": True,
            }],
            "starlink_passes": [{
                "satellite_name": "STARLINK-XXXX",
                "norad_id": None,
                "pass_start_utc": (context.timestamp + timedelta(hours=2)).isoformat() + "Z",
                "pass_end_utc": (context.timestamp + timedelta(hours=2, minutes=4)).isoformat() + "Z",
                "max_elevation_deg": 30.0,
                "max_elevation_time_utc": (context.timestamp + timedelta(hours=2, minutes=2)).isoformat() + "Z",
                "brightness_magnitude": 3.5,
                "direction": "W to E",
                "is_visible_pass": True,
            }],
            "other_satellites": [],
            "summary": {
                "total_visible_passes": 2,
                "brightest_magnitude": -2.5,
                "next_bright_pass": (context.timestamp + timedelta(hours=1)).isoformat() + "Z",
                "search_window_hours": 4,
                "calculation_method": "simplified_mock",
                "note": "Skyfield library required for precise satellite tracking"
            }
        }


class GeocodeEnrichmentProcessor(EnrichmentProcessor):
    """Reverse geocoding enrichment using OpenWeatherMap Geocoding API"""
    
    def __init__(self, api_key: Optional[str] = None):
        self.api_key = api_key
        self._cache = {}  # Simple in-memory cache
        self._cache_ttl_seconds = 3600  # 1 hour cache for location names
    
    @property
    def name(self) -> str:
        return "geocoding"
    
    @property
    def priority(self) -> int:
        return 1  # High priority - location names are important
    
    @property
    def timeout_seconds(self) -> int:
        return 8
    
    async def is_available(self) -> bool:
        return self.api_key is not None
    
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Fetch location name for the sighting coordinates"""
        if not await self.is_available():
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error="OpenWeather API key not configured"
            )
        
        try:
            start_time = datetime.utcnow()
            
            # Check cache first (rounded to 3 decimal places for reasonable cache hits)
            cache_key = f"{context.latitude:.3f},{context.longitude:.3f}"
            if cache_key in self._cache:
                cache_entry = self._cache[cache_key]
                if datetime.utcnow() - cache_entry['timestamp'] < timedelta(seconds=self._cache_ttl_seconds):
                    logger.debug(f"Geocoding cache hit for {cache_key}")
                    return cache_entry['result']
            
            # Fetch location name from OpenWeather Geocoding API
            location_data = await self._fetch_location_name(context.latitude, context.longitude)
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            result = EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=location_data,
                processing_time_ms=processing_time,
                confidence_score=0.95,  # Geocoding is quite reliable
                metadata={
                    "source": "openweather_geocoding",
                    "api_version": "1.0",
                    "cache_key": cache_key,
                }
            )
            
            # Cache the result
            self._cache[cache_key] = {
                'result': result,
                'timestamp': datetime.utcnow()
            }
            
            return result
            
        except Exception as e:
            logger.error(f"Geocoding enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )
    
    async def _fetch_location_name(self, latitude: float, longitude: float) -> Dict[str, Any]:
        """Fetch location name using OpenWeather Geocoding API reverse geocoding"""
        import aiohttp
        
        # OpenWeather reverse geocoding endpoint
        base_url = "http://api.openweathermap.org/geo/1.0/reverse"
        
        async with aiohttp.ClientSession() as session:
            params = {
                'lat': latitude,
                'lon': longitude,
                'limit': 1,  # We only need one result
                'appid': self.api_key
            }
            
            async with session.get(base_url, params=params) as response:
                if response.status != 200:
                    raise Exception(f"OpenWeather Geocoding API error: {response.status} - {await response.text()}")
                
                data = await response.json()
                
                if not data or len(data) == 0:
                    raise Exception("No location data found for coordinates")
                
                location_info = data[0]  # Take the first (most relevant) result
                
                # Format location name based on country
                city = location_info.get('name', '')
                state = location_info.get('state', '')
                country = location_info.get('country', '')
                
                # Create formatted location name
                if country == 'US' and state:
                    # For US locations, use "City, State" format
                    location_name = f"{city}, {state}" if city else state
                elif city and country:
                    # For international locations, use "City, Country" format
                    location_name = f"{city}, {country}"
                elif country:
                    # Fallback to just country
                    location_name = country
                else:
                    # Ultimate fallback
                    location_name = "Unknown Location"
                
                return {
                    "location_name": location_name,
                    "city": city,
                    "state": state,
                    "country": country,
                    "country_code": location_info.get('country', ''),
                    "latitude": location_info.get('lat', latitude),
                    "longitude": location_info.get('lon', longitude),
                    "raw_data": location_info,
                    "formatted_address": self._format_full_address(location_info),
                }
    
    def _format_full_address(self, location_info: Dict[str, Any]) -> str:
        """Format a full address from location components"""
        components = []
        
        if location_info.get('name'):
            components.append(location_info['name'])
        if location_info.get('state'):
            components.append(location_info['state'])
        if location_info.get('country'):
            components.append(location_info['country'])
        
        return ', '.join(components) if components else "Unknown Location"


class ContentFilterProcessor(EnrichmentProcessor):
    """Content filtering and classification using HuggingFace models"""
    
    def __init__(self, api_token: Optional[str] = None, nsfw_model: str = "martin-ha/toxic-comment-model"):
        self.api_token = api_token
        self.nsfw_model = nsfw_model
        self._transformers_available = False
        self._model_cache = {}
        
        # Check if transformers is available for local processing
        try:
            import transformers
            self._transformers_available = True
            logger.info("HuggingFace transformers available for local processing")
        except ImportError:
            logger.info("HuggingFace transformers not available, will use API calls")
    
    @property
    def name(self) -> str:
        return "content_filter"
    
    @property
    def priority(self) -> int:
        return 4  # Lower priority
    
    @property
    def timeout_seconds(self) -> int:
        return 30
    
    async def is_available(self) -> bool:
        # Always available for basic text analysis
        # API token enables advanced HF models
        return True
    
    async def process(self, context: EnrichmentContext) -> EnrichmentResult:
        """Analyze content for classification and filtering"""
        try:
            start_time = datetime.utcnow()
            
            # Analyze content
            content_analysis = await self._analyze_content(context)
            
            processing_time = int((datetime.utcnow() - start_time).total_seconds() * 1000)
            
            # Determine confidence based on analysis method
            confidence = content_analysis.get("confidence", 0.5)
            if content_analysis.get("analysis_method") == "huggingface_api":
                confidence = min(confidence + 0.2, 1.0)  # Higher confidence with HF models
            
            return EnrichmentResult(
                processor_name=self.name,
                success=True,
                data=content_analysis,
                processing_time_ms=processing_time,
                confidence_score=confidence,
                metadata={
                    "model": content_analysis.get("analysis_method", "basic"),
                    "language": content_analysis.get("language_detected", "en"),
                    "hf_api_available": self.api_token is not None,
                    "transformers_available": self._transformers_available,
                }
            )
            
        except Exception as e:
            logger.error(f"Content filter enrichment failed: {e}")
            return EnrichmentResult(
                processor_name=self.name,
                success=False,
                error=str(e)
            )
    
    async def _analyze_content(self, context: EnrichmentContext) -> Dict[str, Any]:
        """Analyze content for safety and classification"""
        text = f"{context.title} {context.description}".strip()
        
        if not text:
            return self._get_empty_analysis()
        
        # Try different analysis methods in order of preference
        if self.api_token and len(text) < 5000:  # HF API has length limits
            try:
                return await self._analyze_with_huggingface_api(text)
            except Exception as e:
                logger.warning(f"HuggingFace API analysis failed: {e}, falling back to local analysis")
        
        if self._transformers_available:
            try:
                return await self._analyze_with_transformers(text)
            except Exception as e:
                logger.warning(f"Local transformers analysis failed: {e}, falling back to basic analysis")
        
        # Fallback to basic analysis
        return await self._analyze_basic(text)
    
    async def _analyze_with_huggingface_api(self, text: str) -> Dict[str, Any]:
        """Analyze content using HuggingFace Inference API"""
        import aiohttp
        
        # Prepare requests for different models
        toxicity_result = None
        sentiment_result = None
        classification_result = None
        
        headers = {
            "Authorization": f"Bearer {self.api_token}",
            "Content-Type": "application/json"
        }
        
        async with aiohttp.ClientSession() as session:
            # Toxicity/NSFW detection
            try:
                toxicity_url = f"https://api-inference.huggingface.co/models/{self.nsfw_model}"
                toxicity_payload = {"inputs": text}
                
                async with session.post(toxicity_url, headers=headers, json=toxicity_payload, timeout=15) as response:
                    if response.status == 200:
                        toxicity_data = await response.json()
                        if isinstance(toxicity_data, list) and len(toxicity_data) > 0:
                            toxicity_result = toxicity_data[0]
                    elif response.status == 503:
                        logger.info("HuggingFace model loading, will retry...")
                        await asyncio.sleep(2)
                        async with session.post(toxicity_url, headers=headers, json=toxicity_payload, timeout=15) as retry_response:
                            if retry_response.status == 200:
                                toxicity_data = await retry_response.json()
                                if isinstance(toxicity_data, list) and len(toxicity_data) > 0:
                                    toxicity_result = toxicity_data[0]
            except Exception as e:
                logger.warning(f"Toxicity detection failed: {e}")
            
            # Sentiment analysis
            try:
                sentiment_url = "https://api-inference.huggingface.co/models/cardiffnlp/twitter-roberta-base-sentiment-latest"
                sentiment_payload = {"inputs": text}
                
                async with session.post(sentiment_url, headers=headers, json=sentiment_payload, timeout=10) as response:
                    if response.status == 200:
                        sentiment_data = await response.json()
                        if isinstance(sentiment_data, list) and len(sentiment_data) > 0:
                            sentiment_result = sentiment_data[0]
            except Exception as e:
                logger.warning(f"Sentiment analysis failed: {e}")
            
            # Text classification for content categories
            try:
                classification_url = "https://api-inference.huggingface.co/models/facebook/bart-large-mnli"
                candidate_labels = ["UFO sighting", "aircraft", "natural phenomenon", "hoax", "scientific observation"]
                classification_payload = {
                    "inputs": text,
                    "parameters": {"candidate_labels": candidate_labels}
                }
                
                async with session.post(classification_url, headers=headers, json=classification_payload, timeout=10) as response:
                    if response.status == 200:
                        classification_result = await response.json()
            except Exception as e:
                logger.warning(f"Classification failed: {e}")
        
        # Process results
        return self._process_hf_results(text, toxicity_result, sentiment_result, classification_result)
    
    async def _analyze_with_transformers(self, text: str) -> Dict[str, Any]:
        """Analyze content using local transformers"""
        try:
            from transformers import pipeline, AutoTokenizer, AutoModelForSequenceClassification
            import torch
            
            results = {}
            
            # Sentiment analysis (lightweight model)
            if "sentiment" not in self._model_cache:
                try:
                    self._model_cache["sentiment"] = pipeline(
                        "sentiment-analysis",
                        model="distilbert-base-uncased-finetuned-sst-2-english",
                        return_all_scores=True
                    )
                except Exception as e:
                    logger.warning(f"Failed to load sentiment model: {e}")
            
            if "sentiment" in self._model_cache:
                try:
                    sentiment_scores = self._model_cache["sentiment"](text[:512])  # Limit text length
                    if sentiment_scores and len(sentiment_scores) > 0:
                        results["sentiment"] = sentiment_scores[0]
                except Exception as e:
                    logger.warning(f"Sentiment analysis failed: {e}")
            
            # Process results and combine with basic analysis
            basic_analysis = await self._analyze_basic(text)
            
            # Update with transformer results
            if "sentiment" in results:
                sentiment_data = results["sentiment"]
                positive_score = next((item["score"] for item in sentiment_data if item["label"] == "POSITIVE"), 0)
                negative_score = next((item["score"] for item in sentiment_data if item["label"] == "NEGATIVE"), 0)
                
                # Convert to polarity (-1 to 1)
                polarity = positive_score - negative_score
                basic_analysis["sentiment"]["polarity"] = round(polarity, 3)
                basic_analysis["sentiment"]["confidence"] = max(positive_score, negative_score)
            
            basic_analysis["analysis_method"] = "transformers_local"
            basic_analysis["confidence"] = 0.75
            
            return basic_analysis
            
        except Exception as e:
            logger.error(f"Transformers analysis failed: {e}")
            return await self._analyze_basic(text)
    
    async def _analyze_basic(self, text: str) -> Dict[str, Any]:
        """Basic text analysis without external models"""
        import re
        from collections import Counter
        
        text_lower = text.lower()
        words = re.findall(r'\b\w+\b', text_lower)
        word_count = len(words)
        
        # Content safety analysis
        unsafe_keywords = {
            'profanity': ['fuck', 'shit', 'damn', 'hell', 'ass'],
            'spam_indicators': ['click', 'free', 'win', 'prize', 'buy', 'sale'],
            'conspiracy': ['hoax', 'fake', 'lie', 'conspiracy', 'coverup'],
        }
        
        safety_scores = {}
        for category, keywords in unsafe_keywords.items():
            matches = sum(1 for word in words if word in keywords)
            safety_scores[category] = min(matches / max(word_count, 1), 1.0)
        
        toxicity_score = max(safety_scores.get('profanity', 0), safety_scores.get('conspiracy', 0) * 0.3)
        spam_score = safety_scores.get('spam_indicators', 0)
        
        # Content classification
        category_keywords = {
            'ufo': ['ufo', 'craft', 'disc', 'triangle', 'lights', 'hovering', 'silent', 'metallic', 'alien', 'extraterrestrial'],
            'natural': ['bird', 'plane', 'airplane', 'balloon', 'star', 'planet', 'moon', 'cloud', 'weather'],
            'military': ['military', 'drone', 'aircraft', 'helicopter', 'jet', 'fighter'],
            'astronomical': ['meteor', 'comet', 'satellite', 'space', 'orbit', 'iss']
        }
        
        category_scores = {}
        for category, keywords in category_keywords.items():
            matches = sum(1 for word in words if word in keywords)
            category_scores[category] = min(matches / max(word_count, 1) * 3, 1.0)  # Scale up
        
        # Find predicted category
        if category_scores:
            predicted_category = max(category_scores.items(), key=lambda x: x[1])[0]
            if category_scores[predicted_category] < 0.1:
                predicted_category = "unknown"
        else:
            predicted_category = "unknown"
        
        # Simple sentiment analysis
        positive_words = ['amazing', 'incredible', 'beautiful', 'wonderful', 'great', 'good', 'excellent']
        negative_words = ['scary', 'terrifying', 'awful', 'bad', 'terrible', 'horrible', 'frightening']
        
        positive_count = sum(1 for word in words if word in positive_words)
        negative_count = sum(1 for word in words if word in negative_words)
        
        polarity = (positive_count - negative_count) / max(word_count, 1)
        subjectivity = (positive_count + negative_count) / max(word_count, 1)
        
        # Language detection (very basic)
        common_english_words = {'the', 'and', 'or', 'but', 'in', 'on', 'at', 'to', 'for', 'of', 'with', 'by'}
        english_word_count = sum(1 for word in words if word in common_english_words)
        language = "en" if english_word_count > len(words) * 0.1 else "unknown"
        
        return {
            "is_safe": toxicity_score < 0.3 and spam_score < 0.3,
            "toxicity_score": round(toxicity_score, 3),
            "spam_score": round(spam_score, 3),
            "classification": {
                "category_confidence": category_scores,
                "predicted_category": predicted_category,
            },
            "sentiment": {
                "polarity": round(polarity, 3),  # -1 to 1
                "subjectivity": round(subjectivity, 3),  # 0 to 1
            },
            "language_detected": language,
            "word_count": word_count,
            "analysis_method": "basic_keywords",
            "confidence": 0.5,
        }
    
    def _process_hf_results(self, text: str, toxicity_result, sentiment_result, classification_result) -> Dict[str, Any]:
        """Process HuggingFace API results into our standard format"""
        analysis = {
            "is_safe": True,
            "toxicity_score": 0.0,
            "spam_score": 0.0,
            "classification": {
                "category_confidence": {},
                "predicted_category": "unknown",
            },
            "sentiment": {
                "polarity": 0.0,
                "subjectivity": 0.5,
            },
            "language_detected": "en",
            "analysis_method": "huggingface_api",
            "confidence": 0.8,
        }
        
        # Process toxicity results
        if toxicity_result and isinstance(toxicity_result, list):
            for item in toxicity_result:
                if item.get("label") == "TOXIC":
                    toxicity_score = item.get("score", 0)
                    analysis["toxicity_score"] = round(toxicity_score, 3)
                    analysis["is_safe"] = toxicity_score < 0.5
                    break
        
        # Process sentiment results
        if sentiment_result and isinstance(sentiment_result, list):
            sentiment_scores = {item["label"]: item["score"] for item in sentiment_result}
            
            positive = sentiment_scores.get("LABEL_2", 0)  # twitter-roberta uses LABEL_2 for positive
            negative = sentiment_scores.get("LABEL_0", 0)  # LABEL_0 for negative
            neutral = sentiment_scores.get("LABEL_1", 0)   # LABEL_1 for neutral
            
            # Convert to polarity (-1 to 1)
            polarity = positive - negative
            subjectivity = 1 - neutral  # Higher subjectivity when less neutral
            
            analysis["sentiment"]["polarity"] = round(polarity, 3)
            analysis["sentiment"]["subjectivity"] = round(subjectivity, 3)
        
        # Process classification results
        if classification_result and "scores" in classification_result and "labels" in classification_result:
            labels = classification_result["labels"]
            scores = classification_result["scores"]
            
            # Map HuggingFace labels to our categories
            label_mapping = {
                "UFO sighting": "ufo",
                "aircraft": "aircraft",
                "natural phenomenon": "natural",
                "hoax": "hoax",
                "scientific observation": "scientific"
            }
            
            category_confidence = {}
            for label, score in zip(labels, scores):
                mapped_category = label_mapping.get(label, label.lower().replace(" ", "_"))
                category_confidence[mapped_category] = round(score, 3)
            
            analysis["classification"]["category_confidence"] = category_confidence
            
            # Set predicted category as the highest scoring one
            if category_confidence:
                predicted_category = max(category_confidence.items(), key=lambda x: x[1])[0]
                analysis["classification"]["predicted_category"] = predicted_category
        
        # Add word count
        analysis["word_count"] = len(text.split())
        
        return analysis
    
    def _get_empty_analysis(self) -> Dict[str, Any]:
        """Return empty analysis for empty text"""
        return {
            "is_safe": True,
            "toxicity_score": 0.0,
            "spam_score": 0.0,
            "classification": {
                "category_confidence": {},
                "predicted_category": "unknown",
            },
            "sentiment": {
                "polarity": 0.0,
                "subjectivity": 0.0,
            },
            "language_detected": "unknown",
            "word_count": 0,
            "analysis_method": "empty_text",
            "confidence": 1.0,
        }


class EnrichmentOrchestrator:
    """Orchestrates the enrichment pipeline for sightings"""
    
    def __init__(self):
        self.processors: List[EnrichmentProcessor] = []
        self.max_concurrent_processors = 3
    
    def register_processor(self, processor: EnrichmentProcessor):
        """Register an enrichment processor"""
        self.processors.append(processor)
        # Sort by priority (lower numbers first)
        self.processors.sort(key=lambda p: p.priority)
    
    async def enrich_sighting(self, context: EnrichmentContext) -> Dict[str, EnrichmentResult]:
        """Run all available enrichment processors for a sighting"""
        results = {}
        
        logger.info(f"Starting enrichment for sighting {context.sighting_id}")
        
        # Filter to available processors
        available_processors = []
        for processor in self.processors:
            try:
                if await processor.is_available():
                    available_processors.append(processor)
                else:
                    logger.warning(f"Processor {processor.name} is not available, skipping")
                    results[processor.name] = EnrichmentResult(
                        processor_name=processor.name,
                        success=False,
                        error="Processor not available"
                    )
            except Exception as e:
                logger.error(f"Error checking availability of {processor.name}: {e}")
                results[processor.name] = EnrichmentResult(
                    processor_name=processor.name,
                    success=False,
                    error=f"Availability check failed: {e}"
                )
        
        # Process in batches to respect concurrency limits
        for i in range(0, len(available_processors), self.max_concurrent_processors):
            batch = available_processors[i:i + self.max_concurrent_processors]
            
            # Run batch concurrently
            batch_tasks = []
            for processor in batch:
                task = asyncio.create_task(
                    self._run_processor_with_timeout(processor, context)
                )
                batch_tasks.append((processor.name, task))
            
            # Wait for batch to complete
            for processor_name, task in batch_tasks:
                try:
                    result = await task
                    results[processor_name] = result
                except asyncio.TimeoutError:
                    results[processor_name] = EnrichmentResult(
                        processor_name=processor_name,
                        success=False,
                        error="Processing timeout"
                    )
                except Exception as e:
                    results[processor_name] = EnrichmentResult(
                        processor_name=processor_name,
                        success=False,
                        error=str(e)
                    )
        
        logger.info(f"Completed enrichment for sighting {context.sighting_id}: "
                   f"{sum(1 for r in results.values() if r.success)}/{len(results)} succeeded")
        
        return results
    
    async def _run_processor_with_timeout(
        self, 
        processor: EnrichmentProcessor, 
        context: EnrichmentContext
    ) -> EnrichmentResult:
        """Run a processor with timeout handling"""
        try:
            return await asyncio.wait_for(
                processor.process(context),
                timeout=processor.timeout_seconds
            )
        except asyncio.TimeoutError:
            logger.warning(f"Processor {processor.name} timed out after {processor.timeout_seconds}s")
            raise
        except Exception as e:
            logger.error(f"Processor {processor.name} failed: {e}")
            return EnrichmentResult(
                processor_name=processor.name,
                success=False,
                error=str(e)
            )
    
    def get_processor_status(self) -> Dict[str, Dict[str, Any]]:
        """Get status of all registered processors"""
        status = {}
        for processor in self.processors:
            status[processor.name] = {
                "priority": processor.priority,
                "timeout_seconds": processor.timeout_seconds,
                "available": None,  # Will be checked asynchronously
            }
        return status


# Global orchestrator instance
enrichment_orchestrator = EnrichmentOrchestrator()


def initialize_enrichment_processors():
    """Initialize and register all enrichment processors"""
    from app.config.environment import settings
    
    # Get the OpenWeather API key (used by both weather and geocoding processors)
    weather_api_key = getattr(settings, 'openweather_api_key', None)
    
    # Geocoding processor - high priority for location names
    geocoding_processor = GeocodeEnrichmentProcessor(api_key=weather_api_key)
    enrichment_orchestrator.register_processor(geocoding_processor)
    
    # Weather processor - needs API key
    weather_processor = WeatherEnrichmentProcessor(api_key=weather_api_key)
    enrichment_orchestrator.register_processor(weather_processor)
    
    # Celestial processor - no API key needed
    celestial_processor = CelestialEnrichmentProcessor()
    enrichment_orchestrator.register_processor(celestial_processor)
    
    # Satellite processor - no API key needed
    satellite_processor = SatelliteEnrichmentProcessor()
    enrichment_orchestrator.register_processor(satellite_processor)
    
    # Content filter processor - HuggingFace API token optional for enhanced features
    hf_api_token = getattr(settings, 'huggingface_api_token', None)
    hf_nsfw_model = getattr(settings, 'huggingface_model_nsfw', 'martin-ha/toxic-comment-model')
    content_processor = ContentFilterProcessor(api_token=hf_api_token, nsfw_model=hf_nsfw_model)
    enrichment_orchestrator.register_processor(content_processor)
    
    logger.info(f"Initialized {len(enrichment_orchestrator.processors)} enrichment processors")
    logger.info(f"Weather API available: {weather_api_key is not None}")
    logger.info(f"Geocoding API available: {weather_api_key is not None}")
    logger.info(f"HuggingFace API available: {hf_api_token is not None}")


class EnrichmentDataGenerator:
    """
    Service class for generating enrichment data from sensor inputs
    
    🔧 MODULAR ARCHITECTURE: Each enrichment component can be:
    - ✅ Added independently (drop-in modules)  
    - ✅ Disabled individually (feature flags)
    - ✅ Configured separately (settings toggles)
    - ✅ Tested in isolation (unit testable)
    
    🌡️ UNIT CONVERSION SUPPORT:
    - ✅ Temperature: Celsius/Fahrenheit  
    - ✅ Distance: Kilometers/Miles
    - ✅ Speed: m/s, km/h, mph
    - ✅ Pressure: hPa/inHg
    
    Future modules ready for drop-in:
    - 🔞 NSFW Content Detector
    - 🎯 Object Classification (AI/ML)
    - ✈️ Enhanced Plane Matching  
    - 🌍 Geological Context
    - 📡 Radio Interference Detection
    """
    
    def __init__(self, enable_nsfw_detection=True, enable_object_classification=True, use_metric=True):
        """Initialize the enrichment data generator with feature flags and unit preferences"""
        if not enrichment_orchestrator.processors:
            initialize_enrichment_processors()
            
        # Feature flags for modular control
        self.enable_nsfw_detection = enable_nsfw_detection
        self.enable_object_classification = enable_object_classification
        self.use_metric = use_metric  # True for metric, False for imperial
    
    def _extract_coordinates_from_sensor_data(self, sensor_data: dict) -> Tuple[Optional[float], Optional[float]]:
        """Extract latitude and longitude from sensor data, handling both formats"""
        if not sensor_data:
            return None, None
        
        # Check nested location format
        if "location" in sensor_data and isinstance(sensor_data["location"], dict):
            location = sensor_data["location"]
            lat = location.get("latitude")
            lng = location.get("longitude")
            if lat is not None and lng is not None:
                return float(lat), float(lng)
        
        # Check flat format
        lat = sensor_data.get("latitude")
        lng = sensor_data.get("longitude")
        if lat is not None and lng is not None:
            return float(lat), float(lng)
        
        return None, None
    
    def _convert_temperature(self, celsius: float) -> dict:
        """Convert temperature with unit labels and controlled precision"""
        if celsius is None:
            return {"value": None, "unit": "°C" if self.use_metric else "°F"}
            
        # Clean input - handle crazy precision from APIs
        celsius = round(float(celsius), 2)  # Limit input precision first
        
        if self.use_metric:
            return {"value": round(celsius, 1), "unit": "°C"}
        else:
            fahrenheit = (celsius * 9/5) + 32
            return {"value": round(fahrenheit, 1), "unit": "°F"}
    
    def _convert_distance(self, kilometers: float) -> dict:
        """Convert distance with unit labels and controlled precision"""
        if kilometers is None:
            return {"value": None, "unit": "km" if self.use_metric else "mi"}
            
        # Clean input precision
        kilometers = round(float(kilometers), 3)
        
        if self.use_metric:
            return {"value": round(kilometers, 1), "unit": "km"}
        else:
            miles = kilometers * 0.621371
            return {"value": round(miles, 1), "unit": "mi"}
    
    def _convert_speed(self, meters_per_second: float) -> dict:
        """Convert wind speed with unit labels and controlled precision"""
        if meters_per_second is None:
            return {"value": None, "unit": "km/h" if self.use_metric else "mph"}
            
        # Clean input precision
        meters_per_second = round(float(meters_per_second), 2)
        
        if self.use_metric:
            # Convert to km/h for metric
            kmh = meters_per_second * 3.6
            return {"value": round(kmh, 1), "unit": "km/h"}
        else:
            # Convert to mph for imperial
            mph = meters_per_second * 2.237
            return {"value": round(mph, 1), "unit": "mph"}
    
    def _convert_pressure(self, hectopascals: float) -> dict:
        """Convert atmospheric pressure with unit labels and controlled precision"""
        if hectopascals is None:
            return {"value": None, "unit": "hPa" if self.use_metric else "inHg"}
            
        # Clean input precision
        hectopascals = round(float(hectopascals), 2)
        
        if self.use_metric:
            return {"value": round(hectopascals, 0), "unit": "hPa"}  # Whole numbers for pressure
        else:
            inches_hg = hectopascals * 0.02953
            return {"value": round(inches_hg, 2), "unit": "inHg"}  # 2 decimals for inches
    
    def _calculate_observation_quality(self, weather_data: dict) -> str:
        """Calculate observation quality for UFO sightings based on weather conditions"""
        try:
            visibility = weather_data.get("visibility_km", 10.0)
            cloud_cover = weather_data.get("cloud_cover_percent", 0)
            humidity = weather_data.get("humidity_percent", 50)
            wind_speed = weather_data.get("wind_speed_ms", 0)
            precipitation = weather_data.get("rain_1h_mm", 0) + weather_data.get("snow_1h_mm", 0)
            
            # Start with perfect score
            score = 100
            
            # Visibility penalties
            if visibility < 1.0:
                score -= 60
            elif visibility < 5.0:
                score -= 30
            elif visibility < 8.0:
                score -= 15
            
            # Cloud cover penalties
            if cloud_cover > 80:
                score -= 25
            elif cloud_cover > 50:
                score -= 15
            elif cloud_cover > 25:
                score -= 5
            
            # Precipitation penalty
            if precipitation > 0:
                score -= 20
            
            # Humidity penalty
            if humidity > 85:
                score -= 10
            elif humidity > 70:
                score -= 5
            
            # Wind penalty
            if wind_speed > 10:
                score -= 10
            elif wind_speed > 5:
                score -= 5
            
            # Clamp score
            score = max(0, min(100, score))
            
            # Convert to quality rating
            ratings = [(90, "excellent"), (75, "very_good"), (60, "good"), 
                      (40, "fair"), (25, "poor")]
            for threshold, rating in ratings:
                if score >= threshold:
                    return rating
            return "very_poor"
                
        except Exception:
            return "unknown"
    
    def _build_location_data(self, context: EnrichmentContext, sensor_data: dict, enrichment_results: dict) -> dict:
        """Build location enrichment data with intelligent unit conversion"""
        location_data = {
            "latitude": context.latitude,
            "longitude": context.longitude,
            "units": "metric" if self.use_metric else "imperial"
        }
        
        # Altitude conversion - we usually get meters, user wants their preference
        altitude_m = context.altitude or 0
        if self.use_metric:
            location_data["altitude"] = {"value": round(altitude_m, 1), "unit": "m"}
        else:
            altitude_ft = altitude_m * 3.28084  # Convert meters to feet
            location_data["altitude"] = {"value": round(altitude_ft, 1), "unit": "ft"}
        
        # Accuracy conversion - GPS accuracy in meters, user wants their preference
        accuracy_m = sensor_data.get("accuracy", 0)
        if self.use_metric:
            location_data["accuracy"] = {"value": round(accuracy_m, 1), "unit": "m"}
        else:
            accuracy_ft = accuracy_m * 3.28084  # Convert meters to feet
            location_data["accuracy"] = {"value": round(accuracy_ft, 1), "unit": "ft"}
        
        # Add geocoding results if available
        if "geocoding" in enrichment_results and enrichment_results["geocoding"].success:
            geocoding_data = enrichment_results["geocoding"].data
            location_data.update({
                "name": geocoding_data.get("location_name", "Unknown Location"),
                "city": geocoding_data.get("city", ""),
                "state": geocoding_data.get("state", ""),
                "country": geocoding_data.get("country", ""),
                "formatted_address": geocoding_data.get("formatted_address", "")
            })
        else:
            location_data["name"] = "Unknown Location"
        
        return location_data
    
    def _build_weather_data(self, enrichment_results: dict) -> dict:
        """Build weather enrichment data with intelligent unit conversion"""
        if "weather" not in enrichment_results or not enrichment_results["weather"].success:
            return {
                "condition": "Clear", 
                "description": "Weather unavailable", 
                "observation_quality": "unknown",
                "units": "metric" if self.use_metric else "imperial"
            }
        
        weather_data = enrichment_results["weather"].data
        
        # Smart unit conversion - detect what we have, provide what user wants
        weather_response = {
            "condition": weather_data.get("weather_main", "Clear"),
            "description": weather_data.get("weather_description", "Clear sky"),
            "icon_code": weather_data.get("weather_icon", "01d"),
            
            # Percentage and directional data (always the same)
            "humidity": weather_data.get("humidity_percent", 0),
            "cloud_coverage": weather_data.get("cloud_cover_percent", 0),
            "uv_index": weather_data.get("uvi", 0),
            "wind_direction": weather_data.get("wind_direction_deg", 0),
            
            # Time data (always the same)
            "sunrise": weather_data.get("sunrise", 0),
            "sunset": weather_data.get("sunset", 0),
            "timestamp": weather_data.get("dt", 0),
            "timezone_offset": weather_data.get("timezone_offset", 0),
            
            # Quality assessment
            "observation_quality": self._calculate_observation_quality(weather_data),
            "units": "metric" if self.use_metric else "imperial"
        }
        
        # Temperature conversions - we get Celsius, user wants their preference
        temp_c = weather_data.get("temperature_c", 0)
        feels_c = weather_data.get("feels_like_c", 0) 
        dew_c = weather_data.get("dew_point_c", 0)
        
        if temp_c is not None:
            weather_response["temperature"] = self._convert_temperature(temp_c)
        if feels_c is not None:
            weather_response["feels_like"] = self._convert_temperature(feels_c)
        if dew_c is not None:
            weather_response["dew_point"] = self._convert_temperature(dew_c)
        
        # Pressure conversion - we get hPa, user wants their preference
        pressure_hpa = weather_data.get("pressure_hpa", 1013)
        if pressure_hpa is not None:
            weather_response["pressure"] = self._convert_pressure(pressure_hpa)
        
        # Distance conversion - we get km, user wants their preference
        visibility_km = weather_data.get("visibility_km", 10.0)
        if visibility_km is not None:
            weather_response["visibility"] = self._convert_distance(visibility_km)
        
        # Wind speed conversion - we get m/s, user wants their preference
        wind_ms = weather_data.get("wind_speed_ms", 0)
        wind_gust_ms = weather_data.get("wind_gust_ms", 0)
        
        if wind_ms is not None:
            weather_response["wind_speed"] = self._convert_speed(wind_ms)
        if wind_gust_ms is not None:
            weather_response["wind_gust"] = self._convert_speed(wind_gust_ms)
        
        # Precipitation - convert mm to inches for imperial users
        rain_mm = weather_data.get("rain_1h_mm", 0)
        snow_mm = weather_data.get("snow_1h_mm", 0)
        
        if self.use_metric:
            weather_response["rain_1h"] = {"value": rain_mm, "unit": "mm"}
            weather_response["snow_1h"] = {"value": snow_mm, "unit": "mm"}
        else:
            # Convert mm to inches
            rain_inches = rain_mm * 0.0393701 if rain_mm else 0
            snow_inches = snow_mm * 0.0393701 if snow_mm else 0
            weather_response["rain_1h"] = {"value": round(rain_inches, 2), "unit": "in"}
            weather_response["snow_1h"] = {"value": round(snow_inches, 2), "unit": "in"}
        
        return weather_response
    
    def _build_celestial_data(self, enrichment_results: dict) -> dict:
        """Build celestial enrichment data"""
        if "celestial" not in enrichment_results or not enrichment_results["celestial"].success:
            return {
                "moon_phase": 0.5,
                "moon_phase_name": "Unknown",
                "visible_planets": [],
                "bright_stars": 0,
                "observation_quality": "unknown"
            }
        
        celestial_data = enrichment_results["celestial"].data
        summary = celestial_data.get("summary", {})
        return {
            "moon_phase": celestial_data.get("moon", {}).get("phase", 0.5),
            "moon_phase_name": summary.get("moon_phase_name", "Unknown"),
            "visible_planets": summary.get("visible_planets", []),
            "bright_stars": summary.get("visible_bright_stars", 0),
            "observation_quality": summary.get("observation_quality", "unknown")
        }
    
    def _build_satellite_data(self, enrichment_results: dict) -> dict:
        """Build satellite tracking data"""
        if "satellites" not in enrichment_results or not enrichment_results["satellites"].success:
            return {
                "visible_satellites": 0,
                "starlink_present": False,
                "iss_visible": False,
                "brightest_magnitude": None,
                "next_pass": None
            }
        
        satellite_data = enrichment_results["satellites"].data
        summary = satellite_data.get("summary", {})
        return {
            "visible_satellites": summary.get("total_visible_passes", 0),
            "starlink_present": len(satellite_data.get("starlink_passes", [])) > 0,
            "iss_visible": len(satellite_data.get("iss_passes", [])) > 0,
            "brightest_magnitude": summary.get("brightest_magnitude"),
            "next_pass": summary.get("next_bright_pass")
        }
    
    def _build_processing_summary(self, enrichment_results: dict) -> dict:
        """Build processing summary data"""
        successful_processors = sum(1 for result in enrichment_results.values() if result.success)
        total_processors = len(enrichment_results)
        return {
            "total_processors": total_processors,
            "successful_processors": successful_processors,
            "failed_processors": total_processors - successful_processors,
            "processor_results": {
                name: {"success": result.success, "error": result.error}
                for name, result in enrichment_results.items()
            }
        }
    
    def _build_nsfw_detection_data(self, enrichment_results: dict, media_files: list = None) -> dict:
        """Build NSFW detection data - MODULAR COMPONENT"""
        if not self.enable_nsfw_detection or not media_files:
            return {"enabled": False, "status": "disabled"}
        
        # TODO: Implement NSFW detection when ready
        return {
            "enabled": True,
            "status": "not_implemented",
            "confidence": 0.0,
            "is_safe": True,
            "detected_categories": []
        }
    
    def _build_object_classification_data(self, enrichment_results: dict, media_files: list = None) -> dict:
        """Build object classification data - MODULAR COMPONENT"""
        if not self.enable_object_classification or not media_files:
            return {"enabled": False, "status": "disabled"}
        
        # TODO: Implement AI object classification when ready  
        return {
            "enabled": True,
            "status": "not_implemented",
            "confidence": 0.0,
            "detected_objects": [],
            "classification": "unknown"
        }
    
    async def generate_enrichment_data(self, sensor_data: dict, media_files: list = None) -> dict:
        """Generate enrichment data for a sighting - clean orchestrator method"""
        import uuid
        
        # Extract coordinates
        lat, lng = self._extract_coordinates_from_sensor_data(sensor_data)
        if lat is None or lng is None:
            return {
                "status": "completed",
                "processed_at": datetime.now().isoformat(),
                "error": "No location data available for enrichment",
            }
        
        try:
            # Create enrichment context
            context = EnrichmentContext(
                sighting_id=str(uuid.uuid4()),
                latitude=lat,
                longitude=lng,
                altitude=sensor_data.get("altitude"),
                timestamp=datetime.now(),
                azimuth_deg=sensor_data.get("azimuth_deg", 0),
                pitch_deg=sensor_data.get("pitch_deg", 0),
                roll_deg=sensor_data.get("roll_deg"),
                category="ufo",
                title="",
                description=""
            )
            
            # Run enrichment orchestrator
            enrichment_results = await enrichment_orchestrator.enrich_sighting(context)
            
            # Build clean response using focused, modular methods
            enrichment_data = {
                "status": "completed",
                "processed_at": datetime.now().isoformat(),
                "location": self._build_location_data(context, sensor_data, enrichment_results),
                "weather": self._build_weather_data(enrichment_results),
                "celestial": self._build_celestial_data(enrichment_results),
                "satellite_check": self._build_satellite_data(enrichment_results),
                "plane_match": {"is_plane": False, "confidence": 0.0, "nearby_flights": []},
                "processing_summary": self._build_processing_summary(enrichment_results)
            }
            
            # Add modular components if enabled
            if media_files:  # Only include these if media is present
                enrichment_data["nsfw_detection"] = self._build_nsfw_detection_data(enrichment_results, media_files)
                enrichment_data["object_classification"] = self._build_object_classification_data(enrichment_results, media_files)
            
            return enrichment_data
            
        except Exception as e:
            logger.error(f"Error in enrichment processing: {e}")
            return {
                "status": "failed",
                "processed_at": datetime.now().isoformat(),
                "error": str(e),
                "location": {
                    "latitude": sensor_data.get("latitude", 0),
                    "longitude": sensor_data.get("longitude", 0),
                    "altitude": sensor_data.get("altitude", 0),
                    "accuracy": sensor_data.get("accuracy", 0),
                    "name": "Unknown Location"
                }
            }