from datetime import datetime
from typing import List, Optional
from uuid import uuid4
import logging
import asyncio

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks, Query
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session

from app.config.environment import settings
from app.schemas.media import MediaFile
from app.services.storage_service import storage_service


logger = logging.getLogger(__name__)

# Import shared models
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'shared', 'api-contracts'))

try:
    from core_models import (
        SightingSubmission,
        Sighting,
        SightingStatus,
        AlertLevel,
        GeoCoordinates,
        SensorData
    )
except ImportError:
    logger.warning("Could not import shared models, using local definitions")
    # Fallback to local definitions if shared models not available
    from pydantic import BaseModel, Field
    from enum import Enum
    
    class SightingCategory(str, Enum):
        UFO = "ufo"
        ANOMALY = "anomaly"
        UNKNOWN = "unknown"
    
    class SightingStatus(str, Enum):
        PENDING = "pending"
        VERIFIED = "verified"
        EXPLAINED = "explained"
        REJECTED = "rejected"
    
    class AlertLevel(str, Enum):
        LOW = "low"
        MEDIUM = "medium"
        HIGH = "high"
        CRITICAL = "critical"
    
    class GeoCoordinates(BaseModel):
        latitude: float = Field(..., ge=-90.0, le=90.0)
        longitude: float = Field(..., ge=-180.0, le=180.0)
        altitude: Optional[float] = None
        accuracy: Optional[float] = None
    
    class SensorData(BaseModel):
        timestamp: datetime
        location: GeoCoordinates
        azimuth_deg: float = Field(..., ge=0.0, lt=360.0)
        pitch_deg: float = Field(..., ge=-90.0, le=90.0)
        roll_deg: Optional[float] = None
        hfov_deg: Optional[float] = None
        vfov_deg: Optional[float] = None
        device_id: Optional[str] = None
        app_version: Optional[str] = None
    
    class SightingSubmission(BaseModel):
        title: str = Field(..., min_length=5, max_length=200)
        description: str = Field(..., min_length=10, max_length=2000)
        category: SightingCategory
        sensor_data: SensorData
        media_files: List[str] = Field(default_factory=list)
        reporter_id: Optional[str] = None
        duration_seconds: Optional[int] = None
        witness_count: int = Field(default=1, ge=1, le=100)
        tags: List[str] = Field(default_factory=list)
        is_public: bool = Field(default=True)
        submitted_at: datetime = Field(default_factory=datetime.utcnow)
    
    # Enrichment data models
    class WeatherData(BaseModel):
        temperature_c: Optional[float] = None
        feels_like_c: Optional[float] = None
        humidity_percent: Optional[int] = None
        pressure_hpa: Optional[float] = None
        wind_speed_ms: Optional[float] = None
        wind_direction_deg: Optional[int] = None
        visibility_km: Optional[float] = None
        cloud_cover_percent: Optional[int] = None
        weather_condition: Optional[str] = None
        weather_description: Optional[str] = None
        precipitation_mm: Optional[float] = None
        uv_index: Optional[float] = None
        sunrise: Optional[str] = None
        sunset: Optional[str] = None
        
    class CelestialSummary(BaseModel):
        twilight_type: Optional[str] = None
        sun_altitude_deg: Optional[float] = None
        moon_phase_name: Optional[str] = None
        moon_illumination: Optional[float] = None
        visible_planets: Optional[List[str]] = None
        visible_bright_stars: Optional[int] = None
        observation_quality: Optional[str] = None
        
    class CelestialData(BaseModel):
        sun: Optional[dict] = None
        moon: Optional[dict] = None
        planets: Optional[dict] = None
        bright_stars: Optional[List[dict]] = None
        summary: Optional[CelestialSummary] = None
        
    class SatellitePass(BaseModel):
        satellite_name: str
        norad_id: Optional[int] = None
        pass_start_utc: str
        pass_end_utc: str
        max_elevation_deg: float
        max_elevation_time_utc: str
        brightness_magnitude: Optional[float] = None
        direction: Optional[str] = None
        is_visible_pass: bool = False
        
    class SatelliteData(BaseModel):
        iss_passes: List[SatellitePass] = Field(default_factory=list)
        starlink_passes: List[SatellitePass] = Field(default_factory=list)
        other_satellites: List[SatellitePass] = Field(default_factory=list)
        summary: Optional[dict] = None
        
    class ContentAnalysis(BaseModel):
        is_safe: bool = True
        toxicity_score: float = 0.0
        spam_score: float = 0.0
        classification: Optional[dict] = None
        sentiment: Optional[dict] = None
        language_detected: str = "en"
        confidence: float = 0.5
        analysis_method: str = "basic"
        
    class EnrichmentData(BaseModel):
        weather: Optional[WeatherData] = None
        celestial: Optional[CelestialData] = None
        satellites: Optional[SatelliteData] = None
        content_analysis: Optional[ContentAnalysis] = None
        processing_metadata: Optional[dict] = None
        
    class MatrixRoomData(BaseModel):
        room_id: Optional[str] = None
        room_alias: Optional[str] = None
        join_url: Optional[str] = None
        matrix_to_url: Optional[str] = None

    class Sighting(BaseModel):
        id: str
        title: str
        description: str
        category: SightingCategory
        sensor_data: SensorData
        media_files: List[MediaFile] = Field(default_factory=list)
        status: SightingStatus = SightingStatus.PENDING
        jittered_location: GeoCoordinates
        alert_level: AlertLevel = AlertLevel.LOW
        reporter_id: Optional[str] = None
        witness_count: int = Field(default=1)
        view_count: int = Field(default=0)
        verification_score: float = Field(default=0.0, ge=0.0, le=1.0)
        matrix_room_id: Optional[str] = None
        submitted_at: datetime
        processed_at: Optional[datetime] = None
        verified_at: Optional[datetime] = None
        created_at: datetime = Field(default_factory=datetime.utcnow)
        updated_at: datetime = Field(default_factory=datetime.utcnow)
        # Enrichment data
        enrichment: Optional[EnrichmentData] = None
        # Matrix room data
        matrix_room: Optional[MatrixRoomData] = None


# Router configuration
router = APIRouter(
    prefix="/v1/sightings",
    tags=["sightings"],
    responses={
        404: {"description": "Sighting not found"},
        400: {"description": "Bad request"},
        403: {"description": "Access denied"},
        422: {"description": "Validation error"},
    }
)

security = HTTPBearer(auto_error=False)

# In-memory sighting storage (replace with database in production)
sightings_db = {}


# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    if token and token.credentials:
        # TODO: Implement actual JWT validation
        return "anonymous_user"
    return None


def jitter_coordinates(lat: float, lng: float) -> GeoCoordinates:
    """Apply privacy jittering to coordinates"""
    import random
    
    # Jitter by 100-300 meters as configured
    min_jitter = settings.public_coord_jitter_min  # 100m
    max_jitter = settings.public_coord_jitter_max  # 300m
    
    # Convert meters to approximate degrees
    # 1 degree latitude ≈ 111,000 meters
    # 1 degree longitude varies by latitude
    lat_jitter_deg = random.uniform(min_jitter, max_jitter) / 111000
    lng_jitter_deg = random.uniform(min_jitter, max_jitter) / (111000 * abs(math.cos(math.radians(lat))))
    
    # Apply random direction
    import math
    lat_jitter = random.choice([-1, 1]) * lat_jitter_deg
    lng_jitter = random.choice([-1, 1]) * lng_jitter_deg
    
    jittered_lat = max(-90.0, min(90.0, lat + lat_jitter))
    jittered_lng = max(-180.0, min(180.0, lng + lng_jitter))
    
    return GeoCoordinates(
        latitude=jittered_lat,
        longitude=jittered_lng,
        altitude=None,  # Don't expose altitude for privacy
        accuracy=None   # Don't expose accuracy for privacy
    )


async def validate_media_files(media_file_ids: List[str]) -> List[MediaFile]:
    """Validate that media files exist and are accessible"""
    # TODO: Query actual media database
    # For now, return mock media files
    media_files = []
    
    for media_id in media_file_ids:
        # Mock media file - in production, query from database
        mock_media = MediaFile(
            id=media_id,
            upload_id=f"upload_{media_id}",
            type="photo",
            filename=f"media_{media_id}.jpg",
            original_filename=f"photo_{media_id}.jpg", 
            url=f"https://cdn.ufobeep.com/media/{media_id}.jpg",
            size_bytes=1024000,
            content_type="image/jpeg",
            uploaded_at=datetime.utcnow(),
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        media_files.append(mock_media)
    
    return media_files


def prepare_enrichment_data(sighting) -> Optional[EnrichmentData]:
    """Convert database enrichment data to API format"""
    try:
        enrichment_data = {}
        
        # Weather data
        if hasattr(sighting, 'weather_data') and sighting.weather_data:
            enrichment_data['weather'] = WeatherData(**sighting.weather_data)
        
        # Celestial data
        if hasattr(sighting, 'celestial_data') and sighting.celestial_data:
            celestial_raw = sighting.celestial_data
            celestial_data = CelestialData(
                sun=celestial_raw.get('sun'),
                moon=celestial_raw.get('moon'),
                planets=celestial_raw.get('planets'),
                bright_stars=celestial_raw.get('bright_stars'),
                summary=CelestialSummary(**celestial_raw.get('summary', {})) if celestial_raw.get('summary') else None
            )
            enrichment_data['celestial'] = celestial_data
        
        # Satellite data  
        if hasattr(sighting, 'satellite_data') and sighting.satellite_data:
            satellite_raw = sighting.satellite_data
            satellite_passes = []
            
            # Process ISS passes
            iss_passes = [SatellitePass(**pass_data) for pass_data in satellite_raw.get('iss_passes', [])]
            
            # Process Starlink passes
            starlink_passes = [SatellitePass(**pass_data) for pass_data in satellite_raw.get('starlink_passes', [])]
            
            # Process other satellites
            other_passes = [SatellitePass(**pass_data) for pass_data in satellite_raw.get('other_satellites', [])]
            
            enrichment_data['satellites'] = SatelliteData(
                iss_passes=iss_passes,
                starlink_passes=starlink_passes,
                other_satellites=other_passes,
                summary=satellite_raw.get('summary')
            )
        
        # Content analysis from enrichment metadata
        if hasattr(sighting, 'enrichment_metadata') and sighting.enrichment_metadata:
            metadata = sighting.enrichment_metadata
            if 'content_analysis' in metadata:
                content_raw = metadata['content_analysis']
                enrichment_data['content_analysis'] = ContentAnalysis(**content_raw)
            
            # Processing metadata
            enrichment_data['processing_metadata'] = {
                k: v for k, v in metadata.items() 
                if k not in ['content_analysis', 'satellite_data']
            }
        
        return EnrichmentData(**enrichment_data) if enrichment_data else None
        
    except Exception as e:
        logger.error(f"Error preparing enrichment data: {e}")
        return None


def prepare_matrix_room_data(sighting) -> Optional[MatrixRoomData]:
    """Convert database Matrix room data to API format"""
    try:
        if hasattr(sighting, 'matrix_room_id') and sighting.matrix_room_id:
            from app.config.environment import settings
            
            matrix_room_data = {
                'room_id': sighting.matrix_room_id,
                'room_alias': getattr(sighting, 'matrix_room_alias', None),
                'join_url': f"{settings.matrix_base_url}/#/room/{sighting.matrix_room_id}",
                'matrix_to_url': f"https://matrix.to/#/{sighting.matrix_room_id}"
            }
            
            return MatrixRoomData(**matrix_room_data)
        
        return None
        
    except Exception as e:
        logger.error(f"Error preparing Matrix room data: {e}")
        return None


def determine_alert_level(submission: SightingSubmission) -> AlertLevel:
    """Determine alert level based on sighting characteristics"""
    score = 0
    
    # Base score by category
    if submission.category == "ufo":
        score += 3
    elif submission.category == "anomaly": 
        score += 2
    else:
        score += 1
    
    # Multiple witnesses increase score
    if submission.witness_count > 5:
        score += 2
    elif submission.witness_count > 2:
        score += 1
    
    # Media files increase score
    score += len(submission.media_files)
    
    # Duration increases score
    if submission.duration_seconds:
        if submission.duration_seconds > 300:  # 5+ minutes
            score += 2
        elif submission.duration_seconds > 60:  # 1+ minute
            score += 1
    
    # Convert score to alert level
    if score >= 8:
        return AlertLevel.CRITICAL
    elif score >= 5:
        return AlertLevel.HIGH
    elif score >= 3:
        return AlertLevel.MEDIUM
    else:
        return AlertLevel.LOW


# Endpoints
@router.post("", response_model=dict)
async def create_sighting(
    submission: SightingSubmission,
    background_tasks: BackgroundTasks,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Create a new sighting report
    
    This endpoint accepts sighting submissions from the mobile app and creates
    a new sighting record with privacy-protected coordinates and alert classification.
    """
    try:
        # Generate unique sighting ID
        sighting_id = f"sighting_{uuid4().hex[:12]}"
        
        # Validate media files if provided
        media_files = []
        if submission.media_files:
            media_files = await validate_media_files(submission.media_files)
            logger.info(f"Validated {len(media_files)} media files for sighting {sighting_id}")
        
        # Apply coordinate jittering for privacy
        jittered_location = jitter_coordinates(
            submission.sensor_data.location.latitude,
            submission.sensor_data.location.longitude
        )
        
        # Determine alert level
        alert_level = determine_alert_level(submission)
        
        # Create sighting record
        sighting = Sighting(
            id=sighting_id,
            title=submission.title,
            description=submission.description,
            category=submission.category,
            sensor_data=submission.sensor_data,
            media_files=media_files,
            status=SightingStatus.PENDING,
            jittered_location=jittered_location,
            alert_level=alert_level,
            reporter_id=user_id or submission.reporter_id,
            witness_count=submission.witness_count,
            view_count=0,
            verification_score=0.0,
            submitted_at=submission.submitted_at,
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        # Store sighting (in production: save to database)
        sightings_db[sighting_id] = sighting
        
        # Schedule background processing
        background_tasks.add_task(process_sighting_async, sighting_id)
        
        logger.info(f"Created sighting {sighting_id} by user {user_id} with alert level {alert_level}")
        
        return {
            "success": True,
            "data": {
                "sighting_id": sighting_id,
                "status": "created",
                "alert_level": alert_level.value,
                "jittered_location": jittered_location.dict()
            },
            "message": "Sighting created successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to create sighting: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SIGHTING_CREATE_FAILED",
                "message": "Failed to create sighting",
                "details": str(e)
            }
        )


@router.get("/{sighting_id}", response_model=dict)
async def get_sighting(
    sighting_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get sighting details by ID
    
    Returns full sighting information. Private details are only shown
    to the sighting reporter.
    """
    try:
        # Check if sighting exists
        sighting = sightings_db.get(sighting_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "SIGHTING_NOT_FOUND",
                    "message": f"Sighting {sighting_id} not found"
                }
            )
        
        # Increment view count
        sighting.view_count += 1
        sighting.updated_at = datetime.utcnow()
        
        # Determine if user can see private details
        is_owner = (user_id and sighting.reporter_id == user_id)
        
        # Prepare response data with enrichment
        response_data = sighting.dict()
        
        # Add enrichment data
        enrichment_data = prepare_enrichment_data(sighting)
        if enrichment_data:
            response_data["enrichment"] = enrichment_data.dict()
            
        # Add Matrix room data
        matrix_room_data = prepare_matrix_room_data(sighting)
        if matrix_room_data:
            response_data["matrix_room"] = matrix_room_data.dict()
        
        # Hide private details for non-owners
        if not is_owner:
            # Remove exact sensor data, keep only jittered location
            response_data["sensor_data"] = {
                "timestamp": sighting.sensor_data.timestamp.isoformat(),
                "location": sighting.jittered_location.dict(),
                # Keep non-sensitive orientation data
                "azimuth_deg": sighting.sensor_data.azimuth_deg,
                "pitch_deg": sighting.sensor_data.pitch_deg
            }
            # Remove reporter ID
            response_data["reporter_id"] = None
        
        logger.info(f"Retrieved sighting {sighting_id} (view count: {sighting.view_count})")
        
        return {
            "success": True,
            "data": response_data,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to retrieve sighting {sighting_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SIGHTING_RETRIEVAL_FAILED",
                "message": "Failed to retrieve sighting"
            }
        )


@router.put("/{sighting_id}", response_model=dict)
async def update_sighting(
    sighting_id: str,
    updates: dict,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Update sighting details (owner only)
    
    Allows the sighting reporter to update certain fields like title,
    description, tags, and public visibility.
    """
    try:
        # Check if sighting exists
        sighting = sightings_db.get(sighting_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "SIGHTING_NOT_FOUND",
                    "message": f"Sighting {sighting_id} not found"
                }
            )
        
        # Check authorization
        if not user_id or sighting.reporter_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "ACCESS_DENIED",
                    "message": "Only the reporter can update this sighting"
                }
            )
        
        # Apply allowed updates
        allowed_fields = {"title", "description", "tags", "is_public"}
        for field, value in updates.items():
            if field in allowed_fields:
                if field == "title" and len(value) < 5:
                    raise HTTPException(
                        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                        detail={"error": "VALIDATION_ERROR", "message": "Title too short"}
                    )
                if field == "description" and len(value) < 10:
                    raise HTTPException(
                        status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                        detail={"error": "VALIDATION_ERROR", "message": "Description too short"}
                    )
                
                setattr(sighting, field, value)
        
        sighting.updated_at = datetime.utcnow()
        
        logger.info(f"Updated sighting {sighting_id} by user {user_id}")
        
        return {
            "success": True,
            "data": {"sighting_id": sighting_id, "updated_at": sighting.updated_at.isoformat()},
            "message": "Sighting updated successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to update sighting {sighting_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SIGHTING_UPDATE_FAILED",
                "message": "Failed to update sighting"
            }
        )


@router.delete("/{sighting_id}")
async def delete_sighting(
    sighting_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Delete a sighting (owner only)
    
    Permanently removes a sighting and associated media files.
    This action cannot be undone.
    """
    try:
        # Check if sighting exists
        sighting = sightings_db.get(sighting_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "SIGHTING_NOT_FOUND",
                    "message": f"Sighting {sighting_id} not found"
                }
            )
        
        # Check authorization
        if not user_id or sighting.reporter_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "ACCESS_DENIED",
                    "message": "Only the reporter can delete this sighting"
                }
            )
        
        # TODO: Delete associated media files from storage
        # TODO: Delete from Matrix chat room
        # TODO: Delete from database
        
        # Remove from in-memory storage
        del sightings_db[sighting_id]
        
        logger.info(f"Deleted sighting {sighting_id} by user {user_id}")
        
        return {
            "success": True,
            "message": "Sighting deleted successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to delete sighting {sighting_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SIGHTING_DELETE_FAILED",
                "message": "Failed to delete sighting"
            }
        )


@router.get("", response_model=dict)
async def list_sightings(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    category: Optional[str] = Query(default=None),
    status: Optional[str] = Query(default=None),
    min_alert_level: Optional[str] = Query(default=None),
    verified_only: bool = Query(default=False),
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    List sightings with filtering and pagination
    
    Returns a paginated list of public sightings matching the specified filters.
    """
    try:
        # Filter sightings based on criteria
        filtered_sightings = []
        
        for sighting in sightings_db.values():
            # Skip private sightings unless owner
            if hasattr(sighting, 'is_public') and not sighting.is_public:
                if not user_id or sighting.reporter_id != user_id:
                    continue
            
            # Apply filters
            if category and sighting.category != category:
                continue
            if status and sighting.status != status:
                continue
            if verified_only and sighting.status != SightingStatus.VERIFIED:
                continue
            if min_alert_level:
                alert_levels = ["low", "medium", "high", "critical"]
                min_level_idx = alert_levels.index(min_alert_level)
                current_level_idx = alert_levels.index(sighting.alert_level.value)
                if current_level_idx < min_level_idx:
                    continue
            
            filtered_sightings.append(sighting)
        
        # Sort by creation time (newest first)
        filtered_sightings.sort(key=lambda x: x.created_at, reverse=True)
        
        # Apply pagination
        total_count = len(filtered_sightings)
        paginated_sightings = filtered_sightings[offset:offset + limit]
        
        # Prepare response data (hide private details)
        sighting_data = []
        for sighting in paginated_sightings:
            data = sighting.dict()
            
            # Add enrichment data
            enrichment_data = prepare_enrichment_data(sighting)
            if enrichment_data:
                data["enrichment"] = enrichment_data.dict()
                
            # Add Matrix room data  
            matrix_room_data = prepare_matrix_room_data(sighting)
            if matrix_room_data:
                data["matrix_room"] = matrix_room_data.dict()
            
            # Always use jittered location for public listings
            data["sensor_data"] = {
                "timestamp": sighting.sensor_data.timestamp.isoformat(),
                "location": sighting.jittered_location.dict(),
                "azimuth_deg": sighting.sensor_data.azimuth_deg,
                "pitch_deg": sighting.sensor_data.pitch_deg
            }
            # Hide reporter ID in listings
            data["reporter_id"] = None
            sighting_data.append(data)
        
        return {
            "success": True,
            "data": sighting_data,
            "total_count": total_count,
            "offset": offset,
            "limit": limit,
            "has_more": (offset + limit) < total_count,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to list sightings: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "SIGHTING_LIST_FAILED",
                "message": "Failed to retrieve sightings"
            }
        )


# Background processing
async def process_sighting_async(sighting_id: str):
    """Process sighting in background (enrichment, notifications, etc.)"""
    try:
        logger.info(f"Starting background processing for sighting {sighting_id}")
        
        sighting = sightings_db.get(sighting_id)
        if not sighting:
            logger.error(f"Sighting {sighting_id} not found for processing")
            return
        
        # Trigger enrichment pipeline
        try:
            from app.worker import trigger_enrichment
            await trigger_enrichment(sighting_id)
            logger.info(f"Triggered enrichment for sighting {sighting_id}")
        except Exception as e:
            logger.error(f"Failed to trigger enrichment for sighting {sighting_id}: {e}")
        
        # Create Matrix chat room
        try:
            from app.services.matrix_service import create_sighting_matrix_room
            room_info = await create_sighting_matrix_room(
                sighting_id=sighting_id,
                sighting_title=sighting.title,
                reporter_user_id=sighting.reporter_id
            )
            
            if room_info:
                # Update sighting with Matrix room information
                sighting.matrix_room_id = room_info['room_id']
                sighting.matrix_room_alias = room_info['room_alias']
                logger.info(f"Created Matrix room {room_info['room_id']} for sighting {sighting_id}")
            else:
                logger.warning(f"Failed to create Matrix room for sighting {sighting_id}")
                
        except Exception as e:
            logger.error(f"Matrix room creation failed for sighting {sighting_id}: {e}")
        
        # TODO: Send push notifications to nearby users
        # TODO: Update search indexes
        
        # Mark as processed
        sighting.processed_at = datetime.utcnow()
        sighting.updated_at = datetime.utcnow()
        
        logger.info(f"Completed background processing for sighting {sighting_id}")
        
    except Exception as e:
        logger.error(f"Background processing failed for sighting {sighting_id}: {e}")


# Enrichment endpoint
@router.post("/{sighting_id}/enrich")
async def trigger_sighting_enrichment(
    sighting_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Manually trigger enrichment for a sighting (owner only)
    
    Useful for re-processing a sighting with updated enrichment data
    or for testing the enrichment pipeline.
    """
    try:
        # Check if sighting exists
        sighting = sightings_db.get(sighting_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "SIGHTING_NOT_FOUND",
                    "message": f"Sighting {sighting_id} not found"
                }
            )
        
        # Check authorization - only owner can trigger enrichment
        if not user_id or sighting.reporter_id != user_id:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "ACCESS_DENIED",
                    "message": "Only the reporter can trigger enrichment"
                }
            )
        
        # Trigger enrichment
        try:
            from app.worker import trigger_enrichment
            await trigger_enrichment(sighting_id)
            
            logger.info(f"Manually triggered enrichment for sighting {sighting_id} by user {user_id}")
            
            return {
                "success": True,
                "data": {
                    "sighting_id": sighting_id,
                    "enrichment_status": "queued"
                },
                "message": "Enrichment queued successfully",
                "timestamp": datetime.utcnow().isoformat()
            }
            
        except Exception as e:
            logger.error(f"Failed to queue enrichment for sighting {sighting_id}: {e}")
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={
                    "error": "ENRICHMENT_QUEUE_FAILED",
                    "message": "Failed to queue enrichment",
                    "details": str(e)
                }
            )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to trigger enrichment for sighting {sighting_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ENRICHMENT_TRIGGER_FAILED",
                "message": "Failed to trigger enrichment"
            }
        )


# Health check
@router.get("/health")
async def sightings_health_check():
    """Check sightings service health"""
    return {
        "status": "healthy",
        "total_sightings": len(sightings_db),
        "pending_sightings": len([s for s in sightings_db.values() if s.status == SightingStatus.PENDING]),
        "timestamp": datetime.utcnow().isoformat()
    }