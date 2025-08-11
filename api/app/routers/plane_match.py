from fastapi import APIRouter, HTTPException, Depends
from fastapi.responses import JSONResponse
import logging

from ..schemas.plane_match import PlaneMatchRequest, PlaneMatchResponse
from ..services.plane_match_service import get_plane_match_service, PlaneMatchService

logger = logging.getLogger(__name__)

router = APIRouter(prefix="", tags=["plane-match"])


@router.post("/plane-match", response_model=PlaneMatchResponse)
async def match_plane(
    request: PlaneMatchRequest,
    service: PlaneMatchService = Depends(get_plane_match_service)
) -> PlaneMatchResponse:
    """
    Analyze sensor data to determine if captured object is likely an aircraft.
    
    This endpoint:
    1. Receives device sensor data (UTC, GPS, azimuth, pitch, roll, HFOV)
    2. Queries OpenSky Network API for nearby aircraft
    3. Calculates line-of-sight matches using geometric analysis
    4. Returns the best aircraft match within tolerance, if any
    
    Args:
        request: Sensor data and optional metadata from mobile device
        
    Returns:
        PlaneMatchResponse with match results and confidence score
        
    Raises:
        HTTPException: For validation errors or service failures
    """
    try:
        logger.info(f"Processing plane match request for location {request.sensor_data.latitude:.4f},{request.sensor_data.longitude:.4f}")
        
        # Validate sensor data
        if not _is_valid_sensor_data(request.sensor_data):
            raise HTTPException(
                status_code=400,
                detail="Invalid sensor data provided"
            )
        
        # Perform plane matching analysis
        result = await service.match_plane(request.sensor_data)
        
        logger.info(f"Plane match result: is_plane={result.is_plane}, confidence={result.confidence:.2f}")
        
        return result
        
    except HTTPException:
        # Re-raise HTTP exceptions as-is
        raise
    except Exception as e:
        logger.error(f"Unexpected error in plane matching: {e}")
        raise HTTPException(
            status_code=500,
            detail="Internal server error during plane matching analysis"
        )


@router.get("/plane-match/health")
async def plane_match_health(
    service: PlaneMatchService = Depends(get_plane_match_service)
):
    """
    Health check endpoint for plane matching service.
    
    Returns service status and configuration information.
    """
    try:
        from ..config.environment import settings
        
        return JSONResponse({
            "status": "healthy",
            "plane_match_enabled": settings.plane_match_enabled,
            "radius_km": settings.plane_match_radius_km,
            "tolerance_deg": settings.plane_match_tolerance_deg,
            "cache_ttl": settings.plane_match_cache_ttl,
            "time_quantization": settings.plane_match_time_quantization,
            "opensky_configured": bool(settings.opensky_client_id and settings.opensky_client_secret)
        })
        
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return JSONResponse(
            status_code=503,
            content={"status": "unhealthy", "error": str(e)}
        )


def _is_valid_sensor_data(sensor_data) -> bool:
    """Validate that sensor data contains minimum required information"""
    
    # Check required fields
    if not all([
        sensor_data.utc,
        sensor_data.latitude is not None,
        sensor_data.longitude is not None,
        sensor_data.azimuth_deg is not None,
        sensor_data.pitch_deg is not None
    ]):
        return False
    
    # Check coordinate ranges
    if not (-90 <= sensor_data.latitude <= 90):
        return False
    if not (-180 <= sensor_data.longitude <= 180):
        return False
    if not (0 <= sensor_data.azimuth_deg < 360):
        return False
    if not (-90 <= sensor_data.pitch_deg <= 90):
        return False
    
    # Check optional fields if present
    if sensor_data.roll_deg is not None:
        if not (-180 <= sensor_data.roll_deg <= 180):
            return False
    
    if sensor_data.hfov_deg is not None:
        if not (0 < sensor_data.hfov_deg < 180):
            return False
    
    if sensor_data.accuracy is not None:
        if sensor_data.accuracy <= 0:
            return False
    
    return True