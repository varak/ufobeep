from datetime import datetime
from typing import List, Optional
import logging

from fastapi import APIRouter, Depends, HTTPException, status, Query
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session

from app.config.environment import settings

logger = logging.getLogger(__name__)

# Import shared models
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'shared', 'api-contracts'))

try:
    from core_models import (
        SightingStatus,
        AlertLevel,
        GeoCoordinates,
    )
except ImportError:
    logger.warning("Could not import shared models, using local definitions")
    # Fallback to local definitions if shared models not available
    from pydantic import BaseModel, Field
    from enum import Enum
    
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


# Router configuration
router = APIRouter(
    prefix="/alerts",
    tags=["alerts"],
    responses={
        404: {"description": "Alert not found"},
        400: {"description": "Bad request"},
        422: {"description": "Validation error"},
    }
)

security = HTTPBearer(auto_error=False)

# Import sightings storage from sightings router
from app.routers.sightings import sightings_db


# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    if token and token.credentials:
        # TODO: Implement actual JWT validation
        return "anonymous_user"
    return None


def sighting_to_alert(sighting, is_owner: bool = False):
    """Convert a sighting to an alert format for the mobile app"""
    
    # Basic alert data
    alert_data = {
        "id": sighting.id,
        "title": sighting.title,
        "description": sighting.description,
        "category": sighting.category,
        "status": sighting.status.value if hasattr(sighting.status, 'value') else sighting.status,
        "alert_level": sighting.alert_level.value if hasattr(sighting.alert_level, 'value') else sighting.alert_level,
        "witness_count": sighting.witness_count,
        "view_count": sighting.view_count,
        "verification_score": sighting.verification_score,
        "submitted_at": sighting.submitted_at.isoformat() if sighting.submitted_at else None,
        "created_at": sighting.created_at.isoformat() if sighting.created_at else None,
        "updated_at": sighting.updated_at.isoformat() if sighting.updated_at else None,
        "processed_at": sighting.processed_at.isoformat() if sighting.processed_at else None,
    }
    
    # Location data - always use jittered coordinates for privacy
    if hasattr(sighting, 'jittered_location'):
        alert_data["location"] = {
            "latitude": sighting.jittered_location.latitude,
            "longitude": sighting.jittered_location.longitude,
            "altitude": sighting.jittered_location.altitude,
            "accuracy": sighting.jittered_location.accuracy,
        }
    elif hasattr(sighting, 'sensor_data') and hasattr(sighting.sensor_data, 'location'):
        # Fallback to sensor data location if no jittered location
        alert_data["location"] = {
            "latitude": sighting.sensor_data.location.latitude,
            "longitude": sighting.sensor_data.location.longitude,
            "altitude": sighting.sensor_data.location.altitude,
            "accuracy": sighting.sensor_data.location.accuracy,
        }
    
    # Sensor orientation data (non-sensitive)
    if hasattr(sighting, 'sensor_data'):
        alert_data["sensor_data"] = {
            "timestamp": sighting.sensor_data.timestamp.isoformat() if sighting.sensor_data.timestamp else None,
            "azimuth_deg": sighting.sensor_data.azimuth_deg,
            "pitch_deg": sighting.sensor_data.pitch_deg,
        }
        
        # Include additional sensor data for owners
        if is_owner and hasattr(sighting.sensor_data, 'roll_deg'):
            alert_data["sensor_data"]["roll_deg"] = sighting.sensor_data.roll_deg
            alert_data["sensor_data"]["hfov_deg"] = getattr(sighting.sensor_data, 'hfov_deg', None)
            alert_data["sensor_data"]["vfov_deg"] = getattr(sighting.sensor_data, 'vfov_deg', None)
    
    # Media files (if any)
    if hasattr(sighting, 'media_files') and sighting.media_files:
        alert_data["media_files"] = []
        for media in sighting.media_files:
            # Construct proper API endpoint URL instead of direct storage URL
            # Extract sighting ID and filename from the storage URL if needed
            api_base_url = settings.API_BASE_URL if hasattr(settings, 'API_BASE_URL') else "https://api.ufobeep.com"
            
            # Construct the proper media API endpoint URL
            media_url = f"{api_base_url}/media/{sighting.id}/{media.filename}"
            
            media_data = {
                "id": media.id,
                "type": media.type,
                "filename": media.filename,
                "url": media_url,  # Use the API endpoint URL
                "content_type": media.content_type,
                "size_bytes": media.size_bytes,
            }
            alert_data["media_files"].append(media_data)
    else:
        alert_data["media_files"] = []
    
    # Matrix room ID for chat functionality
    if hasattr(sighting, 'matrix_room_id'):
        alert_data["matrix_room_id"] = sighting.matrix_room_id
    
    # Reporter ID only for owners
    if is_owner and hasattr(sighting, 'reporter_id'):
        alert_data["reporter_id"] = sighting.reporter_id
    else:
        alert_data["reporter_id"] = None
    
    # Tags if available
    if hasattr(sighting, 'tags'):
        alert_data["tags"] = sighting.tags if sighting.tags else []
    else:
        alert_data["tags"] = []
    
    # Public visibility
    if hasattr(sighting, 'is_public'):
        alert_data["is_public"] = sighting.is_public
    else:
        alert_data["is_public"] = True
    
    return alert_data


@router.get("", response_model=dict)
async def list_alerts(
    limit: int = Query(default=20, ge=1, le=100),
    offset: int = Query(default=0, ge=0),
    category: Optional[str] = Query(default=None),
    min_alert_level: Optional[str] = Query(default=None),
    max_distance_km: Optional[float] = Query(default=None, ge=0.1, le=500.0),
    latitude: Optional[float] = Query(default=None, ge=-90.0, le=90.0),
    longitude: Optional[float] = Query(default=None, ge=-180.0, le=180.0),
    recent_hours: Optional[int] = Query(default=None, ge=1, le=168),  # Max 7 days
    verified_only: bool = Query(default=False),
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get alerts feed for the mobile app
    
    Returns a paginated list of sighting alerts with filtering capabilities.
    This is the primary endpoint for the mobile app's alerts/home screen.
    """
    try:
        from datetime import datetime, timedelta
        import math
        
        # Filter alerts based on criteria
        filtered_alerts = []
        current_time = datetime.utcnow()
        
        for sighting in sightings_db.values():
            # Skip private sightings unless owner
            if hasattr(sighting, 'is_public') and not sighting.is_public:
                if not user_id or sighting.reporter_id != user_id:
                    continue
            
            # Apply category filter
            if category and sighting.category != category:
                continue
            
            # Apply verification filter
            if verified_only and sighting.status != SightingStatus.VERIFIED:
                continue
            
            # Apply alert level filter
            if min_alert_level:
                alert_levels = ["low", "medium", "high", "critical"]
                min_level_idx = alert_levels.index(min_alert_level)
                current_level_idx = alert_levels.index(sighting.alert_level.value)
                if current_level_idx < min_level_idx:
                    continue
            
            # Apply time filter
            if recent_hours and sighting.created_at:
                cutoff_time = current_time - timedelta(hours=recent_hours)
                if sighting.created_at < cutoff_time:
                    continue
            
            # Apply distance filter (if coordinates provided)
            if max_distance_km and latitude is not None and longitude is not None:
                if hasattr(sighting, 'jittered_location'):
                    sighting_lat = sighting.jittered_location.latitude
                    sighting_lng = sighting.jittered_location.longitude
                elif hasattr(sighting, 'sensor_data') and hasattr(sighting.sensor_data, 'location'):
                    sighting_lat = sighting.sensor_data.location.latitude
                    sighting_lng = sighting.sensor_data.location.longitude
                else:
                    continue  # Skip if no location data
                
                # Calculate distance using Haversine formula
                def haversine_distance(lat1, lon1, lat2, lon2):
                    R = 6371  # Earth's radius in kilometers
                    dlat = math.radians(lat2 - lat1)
                    dlon = math.radians(lon2 - lon1)
                    a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                         math.sin(dlon/2) * math.sin(dlon/2))
                    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                    return R * c
                
                distance = haversine_distance(latitude, longitude, sighting_lat, sighting_lng)
                if distance > max_distance_km:
                    continue
            
            # Convert sighting to alert format
            is_owner = (user_id and hasattr(sighting, 'reporter_id') and sighting.reporter_id == user_id)
            alert_data = sighting_to_alert(sighting, is_owner)
            
            # Add distance if coordinates were provided
            if latitude is not None and longitude is not None and alert_data.get("location"):
                def haversine_distance(lat1, lon1, lat2, lon2):
                    R = 6371  # Earth's radius in kilometers
                    dlat = math.radians(lat2 - lat1)
                    dlon = math.radians(lon2 - lon1)
                    a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                         math.sin(dlon/2) * math.sin(dlon/2))
                    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                    return R * c
                
                distance = haversine_distance(
                    latitude, longitude, 
                    alert_data["location"]["latitude"], 
                    alert_data["location"]["longitude"]
                )
                alert_data["distance_km"] = round(distance, 2)
            
            filtered_alerts.append(alert_data)
        
        # Sort by creation time (newest first), then by alert level (highest first)
        def sort_key(alert):
            alert_level_priority = {"critical": 4, "high": 3, "medium": 2, "low": 1}
            created_at = datetime.fromisoformat(alert["created_at"]) if alert.get("created_at") else datetime.min
            alert_priority = alert_level_priority.get(alert.get("alert_level", "low"), 1)
            return (-created_at.timestamp(), -alert_priority)
        
        filtered_alerts.sort(key=sort_key)
        
        # Apply pagination
        total_count = len(filtered_alerts)
        paginated_alerts = filtered_alerts[offset:offset + limit]
        
        # Response metadata
        has_more = (offset + limit) < total_count
        
        logger.info(f"Retrieved {len(paginated_alerts)} alerts (total: {total_count}) for user {user_id or 'anonymous'}")
        
        return {
            "success": True,
            "data": {
                "alerts": paginated_alerts,
                "total_count": total_count,
                "offset": offset,
                "limit": limit,
                "has_more": has_more,
                "filters_applied": {
                    "category": category,
                    "min_alert_level": min_alert_level,
                    "max_distance_km": max_distance_km,
                    "recent_hours": recent_hours,
                    "verified_only": verified_only,
                    "location_provided": latitude is not None and longitude is not None,
                },
            },
            "message": f"Retrieved {len(paginated_alerts)} alerts",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to list alerts: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ALERTS_LIST_FAILED",
                "message": "Failed to retrieve alerts"
            }
        )


@router.get("/{alert_id}", response_model=dict)
async def get_alert_details(
    alert_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get detailed alert information
    
    Returns full alert details for the mobile app's alert detail screen.
    This is essentially a wrapper around the sighting detail endpoint.
    """
    try:
        # Check if sighting/alert exists
        sighting = sightings_db.get(alert_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "ALERT_NOT_FOUND",
                    "message": f"Alert {alert_id} not found"
                }
            )
        
        # Check if user can view this alert
        if hasattr(sighting, 'is_public') and not sighting.is_public:
            if not user_id or sighting.reporter_id != user_id:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail={
                        "error": "ACCESS_DENIED",
                        "message": "This alert is private"
                    }
                )
        
        # Increment view count
        sighting.view_count += 1
        sighting.updated_at = datetime.utcnow()
        
        # Determine if user is the owner
        is_owner = (user_id and hasattr(sighting, 'reporter_id') and sighting.reporter_id == user_id)
        
        # Convert to alert format
        alert_data = sighting_to_alert(sighting, is_owner)
        
        logger.info(f"Retrieved alert details {alert_id} (view count: {sighting.view_count})")
        
        return {
            "success": True,
            "data": alert_data,
            "message": "Alert details retrieved successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to retrieve alert details {alert_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ALERT_DETAILS_FAILED",
                "message": "Failed to retrieve alert details"
            }
        )


@router.get("/nearby", response_model=dict)
async def get_nearby_alerts(
    latitude: float = Query(..., ge=-90.0, le=90.0),
    longitude: float = Query(..., ge=-180.0, le=180.0),
    radius_km: float = Query(default=50.0, ge=0.1, le=500.0),
    limit: int = Query(default=50, ge=1, le=100),
    recent_hours: Optional[int] = Query(default=24, ge=1, le=168),
    min_alert_level: Optional[str] = Query(default=None),
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get nearby alerts for compass/map functionality
    
    Optimized endpoint for getting alerts within a specific radius
    of the user's current location for compass and map displays.
    """
    try:
        import math
        from datetime import datetime, timedelta
        
        nearby_alerts = []
        current_time = datetime.utcnow()
        cutoff_time = current_time - timedelta(hours=recent_hours) if recent_hours else None
        
        def haversine_distance(lat1, lon1, lat2, lon2):
            R = 6371  # Earth's radius in kilometers
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                 math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                 math.sin(dlon/2) * math.sin(dlon/2))
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
            return R * c
        
        for sighting in sightings_db.values():
            # Skip private sightings unless owner
            if hasattr(sighting, 'is_public') and not sighting.is_public:
                if not user_id or sighting.reporter_id != user_id:
                    continue
            
            # Apply time filter
            if cutoff_time and sighting.created_at and sighting.created_at < cutoff_time:
                continue
            
            # Get sighting location
            if hasattr(sighting, 'jittered_location'):
                sighting_lat = sighting.jittered_location.latitude
                sighting_lng = sighting.jittered_location.longitude
            elif hasattr(sighting, 'sensor_data') and hasattr(sighting.sensor_data, 'location'):
                sighting_lat = sighting.sensor_data.location.latitude
                sighting_lng = sighting.sensor_data.location.longitude
            else:
                continue  # Skip if no location data
            
            # Calculate distance
            distance = haversine_distance(latitude, longitude, sighting_lat, sighting_lng)
            if distance > radius_km:
                continue
            
            # Apply alert level filter
            if min_alert_level:
                alert_levels = ["low", "medium", "high", "critical"]
                min_level_idx = alert_levels.index(min_alert_level)
                current_level_idx = alert_levels.index(sighting.alert_level.value)
                if current_level_idx < min_level_idx:
                    continue
            
            # Convert to alert format (minimal data for performance)
            is_owner = (user_id and hasattr(sighting, 'reporter_id') and sighting.reporter_id == user_id)
            alert_data = {
                "id": sighting.id,
                "title": sighting.title,
                "category": sighting.category,
                "alert_level": sighting.alert_level.value if hasattr(sighting.alert_level, 'value') else sighting.alert_level,
                "distance_km": round(distance, 2),
                "location": {
                    "latitude": sighting_lat,
                    "longitude": sighting_lng,
                },
                "created_at": sighting.created_at.isoformat() if sighting.created_at else None,
                "view_count": sighting.view_count,
                "witness_count": sighting.witness_count,
            }
            
            # Add azimuth/bearing calculation for compass
            def calculate_bearing(lat1, lon1, lat2, lon2):
                lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
                dlon = lon2 - lon1
                y = math.sin(dlon) * math.cos(lat2)
                x = (math.cos(lat1) * math.sin(lat2) - 
                     math.sin(lat1) * math.cos(lat2) * math.cos(dlon))
                bearing = math.atan2(y, x)
                bearing = math.degrees(bearing)
                bearing = (bearing + 360) % 360  # Normalize to 0-360
                return bearing
            
            alert_data["bearing_deg"] = round(calculate_bearing(latitude, longitude, sighting_lat, sighting_lng), 1)
            
            nearby_alerts.append(alert_data)
        
        # Sort by distance (nearest first), then by alert level
        def sort_key(alert):
            alert_level_priority = {"critical": 4, "high": 3, "medium": 2, "low": 1}
            distance = alert.get("distance_km", float('inf'))
            alert_priority = alert_level_priority.get(alert.get("alert_level", "low"), 1)
            return (distance, -alert_priority)
        
        nearby_alerts.sort(key=sort_key)
        
        # Apply limit
        limited_alerts = nearby_alerts[:limit]
        
        logger.info(f"Found {len(limited_alerts)} nearby alerts within {radius_km}km of {latitude},{longitude}")
        
        return {
            "success": True,
            "data": {
                "alerts": limited_alerts,
                "total_count": len(nearby_alerts),
                "search_radius_km": radius_km,
                "search_center": {
                    "latitude": latitude,
                    "longitude": longitude
                },
                "filters_applied": {
                    "recent_hours": recent_hours,
                    "min_alert_level": min_alert_level,
                },
            },
            "message": f"Found {len(limited_alerts)} nearby alerts",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to get nearby alerts: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "NEARBY_ALERTS_FAILED",
                "message": "Failed to retrieve nearby alerts"
            }
        )


@router.post("/trigger", response_model=dict)
async def trigger_alert_processing():
    """
    Manually trigger alert processing cycle
    
    Useful for testing and manual alert generation.
    In production, this would be called automatically by the background worker.
    """
    try:
        from app.services.alerts_service import trigger_alert_check
        
        new_alerts_count = await trigger_alert_check()
        
        return {
            "success": True,
            "data": {
                "new_alerts_generated": new_alerts_count,
                "processed_at": datetime.utcnow().isoformat()
            },
            "message": f"Alert processing triggered, generated {new_alerts_count} new alerts",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to trigger alert processing: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ALERT_TRIGGER_FAILED",
                "message": "Failed to trigger alert processing"
            }
        )


@router.get("/stats", response_model=dict)
async def get_alerts_stats():
    """
    Get alerts system statistics
    
    Returns information about the alerts processing system,
    notification queue, and processing metrics.
    """
    try:
        from app.services.alerts_service import get_alerts_stats
        
        stats = get_alerts_stats()
        
        # Add additional stats from sightings database
        total_sightings = len(sightings_db)
        pending_sightings = len([s for s in sightings_db.values() if s.status == SightingStatus.PENDING])
        high_priority_sightings = len([
            s for s in sightings_db.values() 
            if s.alert_level in [AlertLevel.HIGH, AlertLevel.CRITICAL]
        ])
        
        stats.update({
            "sighting_stats": {
                "total_sightings": total_sightings,
                "pending_sightings": pending_sightings,
                "high_priority_sightings": high_priority_sightings,
            }
        })
        
        return {
            "success": True,
            "data": stats,
            "message": "Alerts statistics retrieved successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to retrieve alerts stats: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ALERTS_STATS_FAILED",
                "message": "Failed to retrieve alerts statistics"
            }
        )


@router.get("/{alert_id}/aggregation", response_model=dict)
async def get_witness_aggregation(
    alert_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get witness aggregation analysis for an alert
    
    Returns triangulation results, consensus metrics, and heat map data
    for admin dashboard and detailed analysis.
    """
    try:
        # Check if sighting/alert exists
        sighting = sightings_db.get(alert_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "ALERT_NOT_FOUND",
                    "message": f"Alert {alert_id} not found"
                }
            )
        
        # Import witness aggregation service
        from app.services.witness_aggregation_service import get_witness_aggregation_service
        from app.database import get_db_pool
        
        # Get database pool (placeholder - replace with actual db pool)
        db_pool = None  # TODO: Get actual database pool
        if not db_pool:
            # Return mock data for now since we don't have postgres connection yet
            return {
                "success": True,
                "data": {
                    "sighting_id": alert_id,
                    "triangulation": {
                        "object_latitude": None,
                        "object_longitude": None,
                        "confidence_score": 0.0,
                        "consensus_quality": "insufficient",
                        "estimated_radius_meters": None
                    },
                    "summary": {
                        "total_witnesses": 0,
                        "agreement_percentage": 0.0,
                        "should_escalate": False
                    },
                    "witness_points": []
                },
                "message": "No witness data available yet (mock response)",
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Get witness aggregation service
        aggregation_service = get_witness_aggregation_service(db_pool)
        
        # Analyze consensus
        analysis_result = await aggregation_service.analyze_sighting_consensus(alert_id)
        
        # Get heat map data for admin dashboard
        heat_map_data = await aggregation_service.get_witness_heat_map_data(alert_id)
        
        logger.info(f"Retrieved witness aggregation for {alert_id}: {analysis_result.witness_count} witnesses, confidence {analysis_result.confidence_score:.2f}")
        
        return {
            "success": True,
            "data": heat_map_data,
            "message": f"Witness aggregation analysis complete",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get witness aggregation for {alert_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "AGGREGATION_FAILED",
                "message": "Failed to retrieve witness aggregation data"
            }
        )


@router.get("/{alert_id}/witnesses", response_model=dict)
async def get_alert_witnesses(
    alert_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Get all witness confirmations for an alert
    
    Returns list of witnesses with their locations, bearings, and timestamps
    for analysis and admin dashboard visualization.
    """
    try:
        # Check if sighting/alert exists
        sighting = sightings_db.get(alert_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "ALERT_NOT_FOUND",
                    "message": f"Alert {alert_id} not found"
                }
            )
        
        # Import witness aggregation service
        from app.services.witness_aggregation_service import get_witness_aggregation_service
        from app.database import get_db_pool
        
        # Get database pool (placeholder - replace with actual db pool)
        db_pool = None  # TODO: Get actual database pool
        if not db_pool:
            # Return mock data for now
            return {
                "success": True,
                "data": {
                    "sighting_id": alert_id,
                    "witnesses": [],
                    "total_count": 0
                },
                "message": "No witness data available yet (mock response)",
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Get witness aggregation service
        aggregation_service = get_witness_aggregation_service(db_pool)
        
        # Get witnesses from database
        async with db_pool.acquire() as conn:
            witnesses = await aggregation_service._get_witnesses(conn, alert_id)
        
        # Format witness data for API response
        witness_data = []
        for witness in witnesses:
            witness_data.append({
                "device_id": witness.device_id,
                "latitude": witness.latitude,
                "longitude": witness.longitude,
                "bearing_deg": witness.bearing_deg,
                "timestamp": witness.timestamp.isoformat(),
                "accuracy": witness.accuracy,
                "altitude": witness.altitude,
                "still_visible": witness.still_visible
            })
        
        logger.info(f"Retrieved {len(witnesses)} witnesses for alert {alert_id}")
        
        return {
            "success": True,
            "data": {
                "sighting_id": alert_id,
                "witnesses": witness_data,
                "total_count": len(witnesses)
            },
            "message": f"Retrieved {len(witnesses)} witnesses",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to get witnesses for {alert_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "WITNESSES_FAILED",
                "message": "Failed to retrieve witness data"
            }
        )


@router.post("/{alert_id}/escalate", response_model=dict)
async def manual_escalate_alert(
    alert_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Manually escalate an alert based on witness consensus
    
    Triggers the escalation process for alerts that meet witness
    aggregation criteria or require manual admin intervention.
    """
    try:
        # Check if sighting/alert exists
        sighting = sightings_db.get(alert_id)
        if not sighting:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "ALERT_NOT_FOUND",
                    "message": f"Alert {alert_id} not found"
                }
            )
        
        # Import witness aggregation service
        from app.services.witness_aggregation_service import get_witness_aggregation_service
        from app.database import get_db_pool
        
        # Get database pool (placeholder - replace with actual db pool)
        db_pool = None  # TODO: Get actual database pool
        if not db_pool:
            # Mock escalation for now
            logger.info(f"Mock escalation triggered for alert {alert_id} by user {user_id}")
            return {
                "success": True,
                "data": {
                    "alert_id": alert_id,
                    "escalated": True,
                    "escalation_reason": "Manual admin escalation (mock)",
                    "new_alert_level": "high"
                },
                "message": "Alert escalated successfully (mock response)",
                "timestamp": datetime.utcnow().isoformat()
            }
        
        # Get witness aggregation service
        aggregation_service = get_witness_aggregation_service(db_pool)
        
        # Analyze consensus to determine if escalation is justified
        analysis_result = await aggregation_service.analyze_sighting_consensus(alert_id)
        
        # Determine escalation reason
        if analysis_result.should_escalate:
            escalation_reason = f"Automatic: {analysis_result.witness_count} witnesses, {analysis_result.confidence_score:.2f} confidence"
        else:
            escalation_reason = f"Manual admin override: {analysis_result.witness_count} witnesses"
        
        # Update alert level in sighting
        current_level = sighting.alert_level
        if current_level == AlertLevel.LOW:
            new_level = AlertLevel.MEDIUM
        elif current_level == AlertLevel.MEDIUM:
            new_level = AlertLevel.HIGH
        elif current_level == AlertLevel.HIGH:
            new_level = AlertLevel.CRITICAL
        else:
            new_level = current_level  # Already at critical
        
        sighting.alert_level = new_level
        sighting.updated_at = datetime.utcnow()
        
        logger.info(f"Escalated alert {alert_id} from {current_level.value} to {new_level.value}: {escalation_reason}")
        
        return {
            "success": True,
            "data": {
                "alert_id": alert_id,
                "escalated": True,
                "escalation_reason": escalation_reason,
                "previous_alert_level": current_level.value,
                "new_alert_level": new_level.value,
                "witness_count": analysis_result.witness_count,
                "confidence_score": analysis_result.confidence_score
            },
            "message": f"Alert escalated from {current_level.value} to {new_level.value}",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to escalate alert {alert_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ESCALATION_FAILED",
                "message": "Failed to escalate alert"
            }
        )


# Health check
@router.get("/health")
async def alerts_health_check():
    """Check alerts service health"""
    try:
        from app.services.alerts_service import get_alerts_stats
        
        # Get alerts service stats
        alerts_stats = get_alerts_stats()
        
        # Get basic sightings stats
        total_alerts = len(sightings_db)
        pending_alerts = len([s for s in sightings_db.values() if s.status == SightingStatus.PENDING])
        high_priority_alerts = len([s for s in sightings_db.values() if s.alert_level in [AlertLevel.HIGH, AlertLevel.CRITICAL]])
        
        return {
            "status": "healthy",
            "total_alerts": total_alerts,
            "pending_alerts": pending_alerts,
            "high_priority_alerts": high_priority_alerts,
            "processing_stats": alerts_stats,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        logger.error(f"Alerts health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }