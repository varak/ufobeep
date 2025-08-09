import asyncio
import logging
import math
import time
from datetime import datetime, timezone
from typing import Optional, List, Tuple
from base64 import b64encode

import httpx
import numpy as np
from geopy.distance import geodesic

from ..config.environment import settings
from ..schemas.plane_match import (
    SensorDataSchema, PlaneMatchResponse, PlaneMatchInfo, 
    OpenSkyResponse, OpenSkyState, LineOfSight, PlaneMatchCandidate
)

logger = logging.getLogger(__name__)


class PlaneMatchService:
    """Service for matching captured objects against aircraft data"""
    
    def __init__(self):
        self.client = httpx.AsyncClient(timeout=30.0)
        self._auth_header = None
        self._auth_expires = 0
    
    async def match_plane(self, sensor_data: SensorDataSchema) -> PlaneMatchResponse:
        """
        Main entry point for plane matching analysis.
        
        Args:
            sensor_data: Device sensor readings and location
            
        Returns:
            PlaneMatchResponse with match results
        """
        try:
            if not settings.plane_match_enabled:
                return PlaneMatchResponse(
                    is_plane=False,
                    confidence=0.0,
                    reason="Plane matching is disabled",
                    timestamp=datetime.now(timezone.utc)
                )
            
            # Validate radius constraint (free tier limit)
            if settings.plane_match_radius_km > 80:
                logger.warning(f"Radius {settings.plane_match_radius_km}km exceeds free tier limit of 80km")
                radius_km = min(settings.plane_match_radius_km, 80.0)
            else:
                radius_km = settings.plane_match_radius_km
            
            # Get aircraft data from OpenSky
            aircraft_states = await self._get_aircraft_in_area(
                lat=sensor_data.latitude,
                lon=sensor_data.longitude,
                radius_km=radius_km,
                timestamp=sensor_data.utc
            )
            
            if not aircraft_states:
                return PlaneMatchResponse(
                    is_plane=False,
                    confidence=0.0,
                    reason=f"No aircraft found within {radius_km}km radius",
                    timestamp=datetime.now(timezone.utc)
                )
            
            # Calculate line of sight for each aircraft
            candidates = []
            observer_pos = (sensor_data.latitude, sensor_data.longitude)
            
            for aircraft in aircraft_states:
                if (aircraft.latitude is None or 
                    aircraft.longitude is None or 
                    aircraft.baro_altitude is None):
                    continue
                
                # Calculate line of sight to aircraft
                los = self._calculate_line_of_sight(
                    observer_pos=observer_pos,
                    observer_alt=sensor_data.altitude or 0,
                    target_pos=(aircraft.latitude, aircraft.longitude),
                    target_alt=aircraft.baro_altitude
                )
                
                # Calculate angular error between device pointing direction and aircraft
                angular_error = self._calculate_angular_error(
                    device_azimuth=sensor_data.azimuth_deg,
                    device_pitch=sensor_data.pitch_deg,
                    aircraft_bearing=los.bearing_deg,
                    aircraft_elevation=los.elevation_deg
                )
                
                # Only consider aircraft within tolerance
                if angular_error <= settings.plane_match_tolerance_deg:
                    confidence = self._calculate_confidence(
                        angular_error=angular_error,
                        distance_km=los.distance_km,
                        altitude=aircraft.baro_altitude
                    )
                    
                    candidates.append(PlaneMatchCandidate(
                        aircraft=aircraft,
                        line_of_sight=los,
                        angular_error=angular_error,
                        confidence=confidence
                    ))
            
            if not candidates:
                return PlaneMatchResponse(
                    is_plane=False,
                    confidence=0.0,
                    reason=f"No aircraft within {settings.plane_match_tolerance_deg}° tolerance found",
                    timestamp=datetime.now(timezone.utc)
                )
            
            # Find best match (lowest angular error, highest confidence)
            best_match = min(candidates, key=lambda c: c.angular_error)
            
            # Create match info
            match_info = PlaneMatchInfo(
                callsign=best_match.aircraft.callsign,
                icao24=best_match.aircraft.icao24,
                aircraft_type=None,  # Not provided by OpenSky API
                origin=None,  # Would need additional API calls
                destination=None,  # Would need additional API calls
                altitude=best_match.aircraft.baro_altitude,
                velocity=best_match.aircraft.velocity,
                angular_error=best_match.angular_error
            )
            
            return PlaneMatchResponse(
                is_plane=True,
                matched_flight=match_info,
                confidence=best_match.confidence,
                reason=f"Matched aircraft {match_info.display_name} with {best_match.angular_error:.1f}° error",
                timestamp=datetime.now(timezone.utc)
            )
            
        except Exception as e:
            logger.error(f"Error in plane matching: {e}")
            return PlaneMatchResponse(
                is_plane=False,
                confidence=0.0,
                reason=f"Analysis failed: {str(e)}",
                timestamp=datetime.now(timezone.utc)
            )
    
    async def _get_aircraft_in_area(
        self, 
        lat: float, 
        lon: float, 
        radius_km: float,
        timestamp: datetime
    ) -> List[OpenSkyState]:
        """Get aircraft states from OpenSky API within specified area"""
        
        # Calculate bounding box
        bbox = self._calculate_bbox(lat, lon, radius_km)
        
        # Quantize timestamp for caching
        quantized_time = self._quantize_timestamp(timestamp)
        
        try:
            # Ensure authentication
            await self._ensure_authenticated()
            
            # Make API request
            url = f"{settings.opensky_base_url}/states/all"
            params = {
                'lamin': bbox['lat_min'],
                'lomin': bbox['lon_min'],
                'lamax': bbox['lat_max'],
                'lomax': bbox['lon_max'],
                'time': quantized_time
            }
            
            headers = {
                'Authorization': self._auth_header
            } if self._auth_header else {}
            
            logger.info(f"Fetching aircraft data from OpenSky: bbox={bbox}, time={quantized_time}")
            
            response = await self.client.get(url, params=params, headers=headers)
            response.raise_for_status()
            
            data = response.json()
            opensky_response = OpenSkyResponse.from_api_response(data)
            
            logger.info(f"Retrieved {len(opensky_response.states)} aircraft states")
            
            return opensky_response.states
            
        except httpx.HTTPStatusError as e:
            if e.response.status_code == 429:
                logger.warning("OpenSky API rate limit exceeded")
                raise Exception("Aircraft data temporarily unavailable (rate limited)")
            else:
                logger.error(f"OpenSky API error {e.response.status_code}: {e.response.text}")
                raise Exception(f"Aircraft data service error: {e.response.status_code}")
        except Exception as e:
            logger.error(f"Error fetching aircraft data: {e}")
            raise Exception("Aircraft data service unavailable")
    
    async def _ensure_authenticated(self):
        """Ensure we have a valid OAuth2 token for OpenSky API"""
        current_time = time.time()
        
        # Check if we need to refresh token (with 5 minute buffer)
        if self._auth_header is None or current_time >= (self._auth_expires - 300):
            try:
                # Prepare credentials
                credentials = f"{settings.opensky_client_id}:{settings.opensky_client_secret}"
                encoded_credentials = b64encode(credentials.encode()).decode()
                
                # Request OAuth2 token
                token_url = "https://opensky-network.org/api/auth/token"
                headers = {
                    'Authorization': f'Basic {encoded_credentials}',
                    'Content-Type': 'application/x-www-form-urlencoded'
                }
                data = {
                    'grant_type': 'client_credentials'
                }
                
                response = await self.client.post(token_url, headers=headers, data=data)
                response.raise_for_status()
                
                token_data = response.json()
                access_token = token_data['access_token']
                expires_in = token_data.get('expires_in', 3600)  # Default 1 hour
                
                self._auth_header = f'Bearer {access_token}'
                self._auth_expires = current_time + expires_in
                
                logger.info("OpenSky authentication successful")
                
            except Exception as e:
                logger.error(f"OpenSky authentication failed: {e}")
                # Continue without authentication (may have reduced quota)
                self._auth_header = None
                self._auth_expires = 0
    
    def _calculate_bbox(self, lat: float, lon: float, radius_km: float) -> dict:
        """Calculate bounding box for given center point and radius"""
        # Approximate degrees per km (varies by latitude)
        lat_deg_per_km = 1 / 111.0
        lon_deg_per_km = 1 / (111.0 * math.cos(math.radians(lat)))
        
        lat_delta = radius_km * lat_deg_per_km
        lon_delta = radius_km * lon_deg_per_km
        
        return {
            'lat_min': lat - lat_delta,
            'lat_max': lat + lat_delta,
            'lon_min': lon - lon_delta,
            'lon_max': lon + lon_delta
        }
    
    def _quantize_timestamp(self, timestamp: datetime) -> int:
        """Quantize timestamp to reduce cache misses"""
        unix_timestamp = int(timestamp.timestamp())
        quantization = settings.plane_match_time_quantization
        return (unix_timestamp // quantization) * quantization
    
    def _calculate_line_of_sight(
        self,
        observer_pos: Tuple[float, float],
        observer_alt: float,
        target_pos: Tuple[float, float], 
        target_alt: float
    ) -> LineOfSight:
        """Calculate line of sight from observer to target"""
        
        # Calculate bearing and distance using geopy
        distance_obj = geodesic(observer_pos, target_pos)
        distance_km = distance_obj.kilometers
        bearing_deg = distance_obj.bearing
        
        # Normalize bearing to 0-360
        if bearing_deg < 0:
            bearing_deg += 360
        
        # Calculate elevation angle
        altitude_diff = target_alt - observer_alt
        if distance_km > 0:
            elevation_rad = math.atan2(altitude_diff, distance_km * 1000)  # Convert km to m
            elevation_deg = math.degrees(elevation_rad)
        else:
            elevation_deg = 90.0 if altitude_diff > 0 else -90.0
        
        return LineOfSight(
            bearing_deg=bearing_deg,
            elevation_deg=elevation_deg,
            distance_km=distance_km
        )
    
    def _calculate_angular_error(
        self,
        device_azimuth: float,
        device_pitch: float,
        aircraft_bearing: float,
        aircraft_elevation: float
    ) -> float:
        """Calculate angular error between device pointing direction and aircraft position"""
        
        # Convert degrees to radians
        dev_az_rad = math.radians(device_azimuth)
        dev_pitch_rad = math.radians(device_pitch)
        ac_bearing_rad = math.radians(aircraft_bearing)
        ac_elev_rad = math.radians(aircraft_elevation)
        
        # Convert spherical coordinates to Cartesian unit vectors
        # Device pointing direction
        dev_x = math.sin(dev_az_rad) * math.cos(dev_pitch_rad)
        dev_y = math.cos(dev_az_rad) * math.cos(dev_pitch_rad)
        dev_z = math.sin(dev_pitch_rad)
        
        # Aircraft direction
        ac_x = math.sin(ac_bearing_rad) * math.cos(ac_elev_rad)
        ac_y = math.cos(ac_bearing_rad) * math.cos(ac_elev_rad)
        ac_z = math.sin(ac_elev_rad)
        
        # Calculate dot product (cosine of angle between vectors)
        dot_product = dev_x * ac_x + dev_y * ac_y + dev_z * ac_z
        
        # Clamp dot product to valid range for acos
        dot_product = max(-1.0, min(1.0, dot_product))
        
        # Calculate angle in degrees
        angle_rad = math.acos(dot_product)
        angle_deg = math.degrees(angle_rad)
        
        return angle_deg
    
    def _calculate_confidence(
        self,
        angular_error: float,
        distance_km: float,
        altitude: float
    ) -> float:
        """Calculate confidence score for aircraft match"""
        
        # Base confidence from angular accuracy (inverse relationship)
        max_error = settings.plane_match_tolerance_deg
        angular_confidence = 1.0 - (angular_error / max_error)
        
        # Distance factor (closer is more confident, but not too close)
        if distance_km < 1.0:
            distance_factor = 0.5  # Very close might be a bird or other object
        elif distance_km < 10.0:
            distance_factor = 0.8
        elif distance_km < 50.0:
            distance_factor = 1.0  # Optimal range
        else:
            distance_factor = 0.9  # Still good but farther
        
        # Altitude factor (typical commercial aircraft altitudes are more confident)
        if altitude < 1000:  # Below typical commercial altitude
            altitude_factor = 0.7
        elif altitude < 12000:  # Typical commercial range
            altitude_factor = 1.0
        else:  # Very high altitude
            altitude_factor = 0.9
        
        # Combine factors
        confidence = angular_confidence * distance_factor * altitude_factor
        
        # Clamp to 0-1 range
        return max(0.0, min(1.0, confidence))
    
    async def close(self):
        """Clean up HTTP client"""
        await self.client.aclose()


# Global service instance
_service_instance = None

async def get_plane_match_service() -> PlaneMatchService:
    """Get global plane match service instance"""
    global _service_instance
    if _service_instance is None:
        _service_instance = PlaneMatchService()
    return _service_instance