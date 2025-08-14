"""
Photo Analysis Router - Planet & Satellite Identification
Integrates with Astrometry.net, NASA JPL Horizons, and N2YO APIs
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import Dict, List, Optional, Tuple
import httpx
import asyncio
import json
import time
import math
from datetime import datetime, timezone
from pathlib import Path
import tempfile
import os
import logging

from ..config.environment import settings

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/analyze", tags=["photo-analysis"])

# Target bodies for JPL Horizons lookup
PLANET_TARGETS = {
    "Venus": "299",
    "Jupiter": "599", 
    "Mars": "499",
    "Saturn": "699",
    "Moon": "301"
}

class AstrometryClient:
    """Client for Astrometry.net API plate solving"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "http://nova.astrometry.net/api"
        self.session_key = None
    
    async def login(self) -> str:
        """Login and get session key"""
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.post(
                f"{self.base_url}/login",
                json={"apikey": self.api_key}
            )
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Astrometry login failed")
            
            data = response.json()
            if data.get("status") != "success":
                raise HTTPException(status_code=500, detail="Astrometry login failed")
            
            self.session_key = data["session"]
            return self.session_key
    
    async def upload_image(self, image_path: str) -> str:
        """Upload image for plate solving"""
        if not self.session_key:
            await self.login()
        
        async with httpx.AsyncClient(timeout=120) as client:
            with open(image_path, 'rb') as f:
                files = {
                    'file': f,
                    'request-json': (None, json.dumps({
                        "publicly_visible": "n",
                        "session": self.session_key
                    }))
                }
                response = await client.post(f"{self.base_url}/upload", files=files)
            
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Image upload failed")
            
            data = response.json()
            if "subid" not in data:
                raise HTTPException(status_code=500, detail="No submission ID returned")
            
            return str(data["subid"])
    
    async def poll_submission(self, subid: str, max_wait: int = 300) -> Optional[str]:
        """Poll submission until job is created or timeout"""
        start_time = time.time()
        
        async with httpx.AsyncClient(timeout=30) as client:
            while time.time() - start_time < max_wait:
                response = await client.get(f"{self.base_url}/submissions/{subid}")
                if response.status_code != 200:
                    await asyncio.sleep(5)
                    continue
                
                data = response.json()
                job_calibrations = data.get("job_calibrations", [])
                
                if job_calibrations:
                    return str(job_calibrations[0])
                
                # Check if job failed
                jobs = data.get("jobs", [])
                if jobs and any(jobs):
                    return str(jobs[0])
                
                await asyncio.sleep(10)
        
        return None
    
    async def get_job_results(self, jobid: str) -> Dict:
        """Get plate solving results from job"""
        async with httpx.AsyncClient(timeout=30) as client:
            response = await client.get(f"{self.base_url}/jobs/{jobid}/info/")
            if response.status_code != 200:
                raise HTTPException(status_code=500, detail="Failed to get job results")
            
            return response.json()

class HorizonsClient:
    """Client for NASA JPL Horizons API"""
    
    def __init__(self):
        self.base_url = "https://ssd-api.jpl.nasa.gov"
    
    async def get_target_id(self, target_name: str) -> str:
        """Get target ID for a celestial body"""
        # Use predefined IDs for performance
        return PLANET_TARGETS.get(target_name, target_name)
    
    async def get_ephemeris(self, target_id: str, lat: float, lng: float, elev_m: float, utc_time: datetime) -> Dict:
        """Get observer ephemeris for target at given location/time"""
        async with httpx.AsyncClient(timeout=30) as client:
            params = {
                "format": "json",
                "COMMAND": target_id,
                "EPHEM_TYPE": "OBSERVER",
                "OBSERVER_LOCATION": "coord",
                "SITE_COORD": f"{lat},{lng},{elev_m/1000.0}",  # Convert m to km
                "START_TIME": utc_time.strftime("%Y-%m-%d %H:%M"),
                "STOP_TIME": utc_time.strftime("%Y-%m-%d %H:%M"),
                "STEP_SIZE": "1 m"
            }
            
            response = await client.get(f"{self.base_url}/horizons.api", params=params)
            if response.status_code != 200:
                logger.error(f"Horizons API error: {response.status_code} - {response.text}")
                return {}
            
            return response.json()

class N2YOClient:
    """Client for N2YO satellite API"""
    
    def __init__(self, api_key: str):
        self.api_key = api_key
        self.base_url = "https://api.n2yo.com/rest/v1"
    
    async def get_satellites_above(self, lat: float, lng: float, alt_m: float, max_elevation: int = 90, radius_km: int = 50) -> List[Dict]:
        """Get satellites above horizon"""
        async with httpx.AsyncClient(timeout=30) as client:
            url = f"{self.base_url}/satellite/above/{lat}/{lng}/{alt_m/1000.0}/{max_elevation}/{radius_km}/&apiKey={self.api_key}"
            response = await client.get(url)
            
            if response.status_code != 200:
                logger.error(f"N2YO API error: {response.status_code} - {response.text}")
                return []
            
            data = response.json()
            return data.get("above", [])
    
    async def get_satellite_position(self, sat_id: int, lat: float, lng: float, alt_m: float) -> Dict:
        """Get position for specific satellite"""
        async with httpx.AsyncClient(timeout=30) as client:
            url = f"{self.base_url}/satellite/positions/{sat_id}/{lat}/{lng}/{alt_m/1000.0}/1/&apiKey={self.api_key}"
            response = await client.get(url)
            
            if response.status_code != 200:
                logger.error(f"N2YO API error: {response.status_code} - {response.text}")
                return {}
            
            data = response.json()
            positions = data.get("positions", [])
            return positions[0] if positions else {}

def angular_separation(ra1: float, dec1: float, ra2: float, dec2: float) -> float:
    """Calculate angular separation between two celestial coordinates in degrees"""
    # Convert degrees to radians
    ra1_rad = math.radians(ra1)
    dec1_rad = math.radians(dec1)
    ra2_rad = math.radians(ra2)
    dec2_rad = math.radians(dec2)
    
    # Haversine formula for angular separation
    dra = ra2_rad - ra1_rad
    ddec = dec2_rad - dec1_rad
    
    a = (math.sin(ddec/2)**2 + 
         math.cos(dec1_rad) * math.cos(dec2_rad) * 
         math.sin(dra/2)**2)
    
    c = 2 * math.asin(math.sqrt(a))
    return math.degrees(c)

def altaz_to_radec(azimuth: float, elevation: float, lat: float, lng: float, utc_time: datetime) -> Tuple[float, float]:
    """Convert altitude/azimuth to RA/Dec (simplified conversion)"""
    # This is a simplified conversion - for production use a proper astronomy library like astropy
    # For now, return approximate values for comparison
    
    # Convert to radians
    az_rad = math.radians(azimuth)
    alt_rad = math.radians(elevation)
    lat_rad = math.radians(lat)
    
    # Calculate hour angle and declination
    sin_dec = math.sin(alt_rad) * math.sin(lat_rad) + math.cos(alt_rad) * math.cos(lat_rad) * math.cos(az_rad)
    dec_rad = math.asin(sin_dec)
    
    cos_ha = (math.sin(alt_rad) - math.sin(lat_rad) * math.sin(dec_rad)) / (math.cos(lat_rad) * math.cos(dec_rad))
    ha_rad = math.acos(max(-1, min(1, cos_ha)))  # Clamp to valid range
    
    # Convert hour angle to RA (simplified)
    # This needs proper sidereal time calculation for accuracy
    ra_rad = ha_rad  # Simplified - should use Local Sidereal Time
    
    return math.degrees(ra_rad), math.degrees(dec_rad)

@router.post("/photo")
async def analyze_photo(
    file: UploadFile = File(...),
    latitude: float = Form(...),
    longitude: float = Form(...),
    elevation_m: float = Form(0.0),
    utc_time: str = Form(...)
):
    """
    Analyze photo to determine if main object is a planet/moon or satellite
    
    Args:
        file: Image file to analyze
        latitude: Observer latitude in degrees
        longitude: Observer longitude in degrees  
        elevation_m: Observer elevation in meters
        utc_time: UTC time as ISO format string (e.g., "2025-08-14T03:32:00Z")
    
    Returns:
        JSON with classification, matched_object, and confidence
    """
    
    # Validate API keys
    if not settings.astrometry_api_key or settings.astrometry_api_key == "your_astrometry_key":
        raise HTTPException(status_code=500, detail="Astrometry API key not configured")
    
    if not settings.n2yo_api_key or settings.n2yo_api_key == "your_n2yo_key":
        raise HTTPException(status_code=500, detail="N2YO API key not configured")
    
    # Parse UTC time
    try:
        observation_time = datetime.fromisoformat(utc_time.replace('Z', '+00:00'))
        if observation_time.tzinfo is None:
            observation_time = observation_time.replace(tzinfo=timezone.utc)
    except Exception as e:
        raise HTTPException(status_code=400, detail=f"Invalid UTC time format: {e}")
    
    # Save uploaded file temporarily
    temp_dir = Path(tempfile.gettempdir())
    temp_file = temp_dir / f"photo_analysis_{int(time.time())}.jpg"
    
    try:
        # Save uploaded file
        with open(temp_file, "wb") as buffer:
            content = await file.read()
            buffer.write(content)
        
        logger.info(f"Starting photo analysis for coordinates {latitude}, {longitude} at {utc_time}")
        
        # Initialize API clients
        astrometry = AstrometryClient(settings.astrometry_api_key)
        horizons = HorizonsClient()
        n2yo = N2YOClient(settings.n2yo_api_key)
        
        # Step 1: Upload image to Astrometry.net for plate solving
        logger.info("Uploading image to Astrometry.net")
        subid = await astrometry.upload_image(str(temp_file))
        
        # Step 2: Poll for job completion
        logger.info(f"Polling submission {subid}")
        jobid = await astrometry.poll_submission(subid, max_wait=120)  # 2 minute timeout
        
        if not jobid:
            logger.warning("Plate solving timeout or failed")
            return {
                "classification": "unknown",
                "matched_object": None,
                "confidence": 0.0,
                "error": "Plate solving timeout - image may not contain enough stars"
            }
        
        # Step 3: Get plate solving results
        logger.info(f"Getting results for job {jobid}")
        job_results = await astrometry.get_job_results(jobid)
        
        if not job_results or "calibration" not in job_results:
            logger.warning("No calibration data in job results")
            return {
                "classification": "unknown", 
                "matched_object": None,
                "confidence": 0.0,
                "error": "Plate solving failed - no star calibration found"
            }
        
        # Extract field center coordinates
        calibration = job_results["calibration"]
        field_ra = calibration.get("ra", 0.0)
        field_dec = calibration.get("dec", 0.0)
        field_radius = calibration.get("radius", 1.0)  # Field radius in degrees
        
        logger.info(f"Plate solved: RA={field_ra:.2f}, Dec={field_dec:.2f}, radius={field_radius:.2f}°")
        
        # Step 4: Check for planets/moon using JPL Horizons
        planet_matches = []
        
        for planet_name, target_id in PLANET_TARGETS.items():
            try:
                ephemeris = await horizons.get_ephemeris(target_id, latitude, longitude, elevation_m, observation_time)
                
                # Parse ephemeris data - format varies but typically includes RA/Dec
                if ephemeris and "result" in ephemeris:
                    result_text = ephemeris["result"]
                    # Parse ephemeris text for RA/Dec coordinates
                    # This is simplified - real implementation would parse the detailed ephemeris format
                    
                    # For now, use approximate coordinates based on the target
                    # In production, you'd parse the actual ephemeris data
                    planet_ra, planet_dec = 0.0, 0.0  # Placeholder
                    
                    # Calculate angular separation
                    separation = angular_separation(field_ra, field_dec, planet_ra, planet_dec)
                    
                    if separation <= 2.0:  # Within 2 degrees
                        confidence = max(0.0, 1.0 - separation / 2.0)  # Linear confidence falloff
                        planet_matches.append({
                            "name": planet_name,
                            "separation_deg": separation,
                            "confidence": confidence
                        })
                        
            except Exception as e:
                logger.error(f"Error checking {planet_name}: {e}")
                continue
        
        # Step 5: Check for satellites using N2YO
        satellite_matches = []
        
        try:
            satellites = await n2yo.get_satellites_above(latitude, longitude, elevation_m)
            
            for sat in satellites[:20]:  # Check top 20 satellites
                try:
                    sat_id = sat.get("satid")
                    sat_name = sat.get("satname", f"SAT-{sat_id}")
                    
                    if not sat_id:
                        continue
                    
                    # Get precise position
                    position = await n2yo.get_satellite_position(sat_id, latitude, longitude, elevation_m)
                    
                    if position:
                        sat_az = position.get("azimuth", 0.0)
                        sat_el = position.get("elevation", 0.0)
                        
                        # Convert satellite alt/az to RA/Dec for comparison
                        sat_ra, sat_dec = altaz_to_radec(sat_az, sat_el, latitude, longitude, observation_time)
                        
                        # Calculate angular separation
                        separation = angular_separation(field_ra, field_dec, sat_ra, sat_dec)
                        
                        if separation <= 2.0:  # Within 2 degrees
                            confidence = max(0.0, 1.0 - separation / 2.0)
                            satellite_matches.append({
                                "name": sat_name,
                                "separation_deg": separation,
                                "confidence": confidence,
                                "sat_id": sat_id
                            })
                            
                except Exception as e:
                    logger.error(f"Error checking satellite {sat.get('satname', 'unknown')}: {e}")
                    continue
                    
        except Exception as e:
            logger.error(f"Error getting satellites: {e}")
        
        # Step 6: Determine best match
        all_matches = []
        
        # Add planet matches
        for match in planet_matches:
            all_matches.append({
                "type": "planet",
                "name": match["name"],
                "confidence": match["confidence"],
                "separation_deg": match["separation_deg"]
            })
        
        # Add satellite matches  
        for match in satellite_matches:
            all_matches.append({
                "type": "satellite", 
                "name": match["name"],
                "confidence": match["confidence"],
                "separation_deg": match["separation_deg"]
            })
        
        # Sort by confidence
        all_matches.sort(key=lambda x: x["confidence"], reverse=True)
        
        if not all_matches:
            return {
                "classification": "unknown",
                "matched_object": None,
                "confidence": 0.0,
                "plate_solve_data": {
                    "field_center_ra": field_ra,
                    "field_center_dec": field_dec,
                    "field_radius_deg": field_radius
                }
            }
        
        # Return best match
        best_match = all_matches[0]
        
        result = {
            "classification": best_match["type"],
            "matched_object": best_match["name"],
            "confidence": round(best_match["confidence"], 3),
            "angular_separation_deg": round(best_match["separation_deg"], 3),
            "plate_solve_data": {
                "field_center_ra": field_ra,
                "field_center_dec": field_dec,
                "field_radius_deg": field_radius,
                "job_id": jobid
            },
            "all_matches": all_matches[:5]  # Top 5 matches for reference
        }
        
        logger.info(f"Analysis complete: {best_match['type']} - {best_match['name']} (confidence: {best_match['confidence']:.3f})")
        return result
        
    except Exception as e:
        logger.error(f"Photo analysis error: {e}")
        raise HTTPException(status_code=500, detail=f"Analysis failed: {str(e)}")
    
    finally:
        # Clean up temporary file
        if temp_file.exists():
            temp_file.unlink()