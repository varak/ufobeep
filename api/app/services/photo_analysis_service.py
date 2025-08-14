"""
Photo Analysis Service - Async Background Analysis
Automatically analyzes uploaded photos for planets/satellites after upload completes
"""
import asyncio
import logging
import time
import json
from datetime import datetime, timezone
from pathlib import Path
from typing import Optional, Dict, Any
import uuid

from ..routers.photo_analysis import (
    AstrometryClient, 
    HorizonsClient, 
    N2YOClient,
    PLANET_TARGETS,
    angular_separation,
    altaz_to_radec
)
from ..config.environment import settings

logger = logging.getLogger(__name__)

class PhotoAnalysisService:
    """Service for automatic photo analysis after upload"""
    
    def __init__(self, db_pool):
        self.db_pool = db_pool
        self.astrometry = None
        self.horizons = None
        self.n2yo = None
        
        # Initialize clients if API keys are available
        if settings.astrometry_api_key and settings.astrometry_api_key != "your_astrometry_key":
            self.astrometry = AstrometryClient(settings.astrometry_api_key)
        
        if settings.n2yo_api_key and settings.n2yo_api_key != "your_n2yo_key":
            self.n2yo = N2YOClient(settings.n2yo_api_key)
            
        self.horizons = HorizonsClient()
    
    async def analyze_photo_async(
        self, 
        sighting_id: str, 
        filename: str,
        file_path: str, 
        latitude: float, 
        longitude: float, 
        elevation_m: float = 0.0,
        observation_time: Optional[datetime] = None
    ):
        """
        Analyze photo asynchronously in background
        
        Args:
            sighting_id: UUID of the sighting
            filename: Original filename
            file_path: Full path to uploaded photo
            latitude: Observer latitude
            longitude: Observer longitude  
            elevation_m: Observer elevation in meters
            observation_time: UTC time of observation (defaults to now)
        """
        if observation_time is None:
            observation_time = datetime.utcnow().replace(tzinfo=timezone.utc)
        
        start_time = time.time()
        analysis_id = str(uuid.uuid4())
        
        logger.info(f"Starting async photo analysis for sighting {sighting_id}, file {filename}")
        
        # Create initial record with pending status
        await self._create_analysis_record(
            analysis_id=analysis_id,
            sighting_id=sighting_id,
            filename=filename,
            latitude=latitude,
            longitude=longitude,
            elevation_m=elevation_m,
            observation_time=observation_time,
            status="pending"
        )
        
        try:
            # Check if analysis is possible
            if not self.astrometry or not self.n2yo:
                await self._update_analysis_record(
                    analysis_id,
                    status="failed",
                    error="API keys not configured for analysis"
                )
                return
            
            # Verify file exists
            if not Path(file_path).exists():
                await self._update_analysis_record(
                    analysis_id,
                    status="failed", 
                    error=f"Photo file not found: {file_path}"
                )
                return
            
            # Run the actual analysis
            result = await self._run_analysis(
                file_path, latitude, longitude, elevation_m, observation_time
            )
            
            processing_duration = int((time.time() - start_time) * 1000)  # milliseconds
            
            if result.get("error"):
                # Analysis completed but with error
                await self._update_analysis_record(
                    analysis_id,
                    status="failed",
                    error=result["error"],
                    processing_duration_ms=processing_duration,
                    raw_analysis_data=result
                )
            else:
                # Analysis completed successfully
                await self._update_analysis_record(
                    analysis_id,
                    status="completed",
                    classification=result.get("classification"),
                    matched_object=result.get("matched_object"),
                    confidence=result.get("confidence"),
                    angular_separation_deg=result.get("angular_separation_deg"),
                    field_center_ra=result.get("plate_solve_data", {}).get("field_center_ra"),
                    field_center_dec=result.get("plate_solve_data", {}).get("field_center_dec"),
                    field_radius_deg=result.get("plate_solve_data", {}).get("field_radius_deg"),
                    astrometry_job_id=result.get("plate_solve_data", {}).get("job_id"),
                    all_matches=result.get("all_matches", []),
                    processing_duration_ms=processing_duration,
                    raw_analysis_data=result
                )
            
            logger.info(f"Photo analysis completed for {filename}: {result.get('classification', 'unknown')} - {result.get('matched_object', 'none')} (took {processing_duration}ms)")
            
        except Exception as e:
            processing_duration = int((time.time() - start_time) * 1000)
            error_msg = f"Analysis failed with exception: {str(e)}"
            logger.error(f"Photo analysis error for {filename}: {error_msg}")
            
            await self._update_analysis_record(
                analysis_id,
                status="failed",
                error=error_msg,
                processing_duration_ms=processing_duration
            )
    
    async def _run_analysis(
        self, 
        file_path: str, 
        latitude: float, 
        longitude: float, 
        elevation_m: float, 
        observation_time: datetime
    ) -> Dict[str, Any]:
        """Run the actual photo analysis (same logic as endpoint)"""
        try:
            logger.info(f"Running plate solving for {file_path}")
            
            # Step 1: Upload to Astrometry.net
            subid = await self.astrometry.upload_image(file_path)
            
            # Step 2: Poll for completion
            jobid = await self.astrometry.poll_submission(subid, max_wait=120)
            
            if not jobid:
                return {
                    "classification": "unknown",
                    "matched_object": None,
                    "confidence": 0.0,
                    "error": "Plate solving timeout - image may not contain enough stars"
                }
            
            # Step 3: Get results
            job_results = await self.astrometry.get_job_results(jobid)
            
            if not job_results or "calibration" not in job_results:
                return {
                    "classification": "unknown",
                    "matched_object": None,
                    "confidence": 0.0,
                    "error": "Plate solving failed - no star calibration found"
                }
            
            # Extract coordinates
            calibration = job_results["calibration"]
            field_ra = calibration.get("ra", 0.0)
            field_dec = calibration.get("dec", 0.0)
            field_radius = calibration.get("radius", 1.0)
            
            logger.info(f"Plate solved: RA={field_ra:.2f}, Dec={field_dec:.2f}")
            
            # Step 4: Check planets
            planet_matches = []
            for planet_name, target_id in PLANET_TARGETS.items():
                try:
                    ephemeris = await self.horizons.get_ephemeris(
                        target_id, latitude, longitude, elevation_m, observation_time
                    )
                    
                    # For now use simplified planet position check
                    # In production, parse actual ephemeris data
                    planet_ra, planet_dec = 0.0, 0.0  # Placeholder
                    
                    separation = angular_separation(field_ra, field_dec, planet_ra, planet_dec)
                    
                    if separation <= 2.0:
                        confidence = max(0.0, 1.0 - separation / 2.0)
                        planet_matches.append({
                            "name": planet_name,
                            "separation_deg": separation,
                            "confidence": confidence
                        })
                except Exception as e:
                    logger.warning(f"Error checking {planet_name}: {e}")
                    continue
            
            # Step 5: Check satellites
            satellite_matches = []
            try:
                satellites = await self.n2yo.get_satellites_above(
                    latitude, longitude, elevation_m
                )
                
                for sat in satellites[:20]:  # Top 20
                    try:
                        sat_id = sat.get("satid")
                        sat_name = sat.get("satname", f"SAT-{sat_id}")
                        
                        if not sat_id:
                            continue
                        
                        position = await self.n2yo.get_satellite_position(
                            sat_id, latitude, longitude, elevation_m
                        )
                        
                        if position:
                            sat_az = position.get("azimuth", 0.0)
                            sat_el = position.get("elevation", 0.0)
                            
                            sat_ra, sat_dec = altaz_to_radec(
                                sat_az, sat_el, latitude, longitude, observation_time
                            )
                            
                            separation = angular_separation(field_ra, field_dec, sat_ra, sat_dec)
                            
                            if separation <= 2.0:
                                confidence = max(0.0, 1.0 - separation / 2.0)
                                satellite_matches.append({
                                    "name": sat_name,
                                    "separation_deg": separation,
                                    "confidence": confidence,
                                    "sat_id": sat_id
                                })
                    except Exception as e:
                        logger.warning(f"Error checking satellite {sat.get('satname', 'unknown')}: {e}")
                        continue
            except Exception as e:
                logger.warning(f"Error getting satellites: {e}")
            
            # Step 6: Find best match
            all_matches = []
            
            for match in planet_matches:
                all_matches.append({
                    "type": "planet",
                    "name": match["name"],
                    "confidence": match["confidence"],
                    "separation_deg": match["separation_deg"]
                })
            
            for match in satellite_matches:
                all_matches.append({
                    "type": "satellite",
                    "name": match["name"],
                    "confidence": match["confidence"],
                    "separation_deg": match["separation_deg"]
                })
            
            all_matches.sort(key=lambda x: x["confidence"], reverse=True)
            
            if not all_matches:
                return {
                    "classification": "unknown",
                    "matched_object": None,
                    "confidence": 0.0,
                    "plate_solve_data": {
                        "field_center_ra": field_ra,
                        "field_center_dec": field_dec,
                        "field_radius_deg": field_radius,
                        "job_id": jobid
                    },
                    "all_matches": []
                }
            
            best_match = all_matches[0]
            
            return {
                "classification": best_match["type"],
                "matched_object": best_match["name"],
                "confidence": best_match["confidence"],
                "angular_separation_deg": best_match["separation_deg"],
                "plate_solve_data": {
                    "field_center_ra": field_ra,
                    "field_center_dec": field_dec,
                    "field_radius_deg": field_radius,
                    "job_id": jobid
                },
                "all_matches": all_matches[:5]
            }
            
        except Exception as e:
            logger.error(f"Analysis error: {e}")
            raise
    
    async def _create_analysis_record(
        self,
        analysis_id: str,
        sighting_id: str,
        filename: str,
        latitude: float,
        longitude: float,
        elevation_m: float,
        observation_time: datetime,
        status: str
    ):
        """Create initial analysis record"""
        async with self.db_pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO photo_analysis_results 
                (id, sighting_id, filename, observer_latitude, observer_longitude, 
                 observer_elevation_m, observation_time, analysis_status)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """, uuid.UUID(analysis_id), uuid.UUID(sighting_id), filename, 
                latitude, longitude, elevation_m, observation_time, status)
    
    async def _update_analysis_record(
        self,
        analysis_id: str,
        status: str,
        classification: Optional[str] = None,
        matched_object: Optional[str] = None,
        confidence: Optional[float] = None,
        angular_separation_deg: Optional[float] = None,
        field_center_ra: Optional[float] = None,
        field_center_dec: Optional[float] = None,
        field_radius_deg: Optional[float] = None,
        astrometry_job_id: Optional[str] = None,
        all_matches: Optional[list] = None,
        error: Optional[str] = None,
        processing_duration_ms: Optional[int] = None,
        raw_analysis_data: Optional[dict] = None
    ):
        """Update analysis record with results"""
        async with self.db_pool.acquire() as conn:
            await conn.execute("""
                UPDATE photo_analysis_results 
                SET analysis_status = $2,
                    classification = $3,
                    matched_object = $4,
                    confidence = $5,
                    angular_separation_deg = $6,
                    field_center_ra = $7,
                    field_center_dec = $8,
                    field_radius_deg = $9,
                    astrometry_job_id = $10,
                    all_matches = $11,
                    analysis_error = $12,
                    processing_duration_ms = $13,
                    raw_analysis_data = $14,
                    updated_at = NOW()
                WHERE id = $1
            """, uuid.UUID(analysis_id), status, classification, matched_object,
                confidence, angular_separation_deg, field_center_ra, field_center_dec,
                field_radius_deg, astrometry_job_id, 
                json.dumps(all_matches) if all_matches else None,
                error, processing_duration_ms,
                json.dumps(raw_analysis_data) if raw_analysis_data else None)

# Global service instance
photo_analysis_service = None

def get_photo_analysis_service(db_pool):
    """Get or create photo analysis service instance"""
    global photo_analysis_service
    if photo_analysis_service is None:
        photo_analysis_service = PhotoAnalysisService(db_pool)
    return photo_analysis_service