from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Header
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from app.services.alerts_service import AlertsService
import asyncpg
import uuid
import logging
from datetime import datetime

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/beep", tags=["beep"])

class WitnessLocation(BaseModel):
    latitude: float
    longitude: float
    altitude: Optional[float] = None
    accuracy: Optional[float] = None

class WitnessConfirmation(BaseModel):
    device_id: str = Field(..., description="Device UUID")
    witness_type: str = Field(default="visual")
    confirmed: bool = Field(default=True)
    # Support either flat fields OR nested location
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    altitude: Optional[float] = None
    accuracy: Optional[float] = None
    location: Optional[WitnessLocation] = None
    still_visible: Optional[bool] = Field(default=True)
    quick_action: Optional[bool] = Field(default=False)

# In-memory store for idempotency keys (in production would use Redis)
idempotency_store = {}

# Shared utilities  
async def get_db():
    """Get database connection pool from shared service"""
    from app.services.database_service import get_database_pool
    return await get_database_pool()

def format_alert_response(alert, user_lat=None, user_lon=None):
    """Format alert data for API response with optional distance calculation and short URL"""
    
    # Calculate distance if user location and alert location are provided
    distance_km = 0.0
    bearing_deg = 0.0
    
    if (user_lat is not None and user_lon is not None and 
        alert.location and alert.location.latitude and alert.location.longitude):
        # Haversine distance formula
        import math
        
        lat1, lon1 = math.radians(user_lat), math.radians(user_lon)
        lat2, lon2 = math.radians(alert.location.latitude), math.radians(alert.location.longitude)
        
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        distance_km = 6371 * c  # Earth radius in km
        
        # Calculate bearing
        y = math.sin(dlon) * math.cos(lat2)
        x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon)
        bearing_deg = (math.degrees(math.atan2(y, x)) + 360) % 360
    
    # Use stored short_url from database (much faster than generating)
    short_url = alert.short_url or ""
    
    response = {
        "id": alert.id,
        "title": alert.title,
        "description": alert.description,
        "category": alert.category,
        "alert_level": alert.alert_level,
        "status": "active",
        "witness_count": alert.witness_count,
        "created_at": alert.created_at.isoformat(),
        "location": {
            "latitude": alert.location.latitude if alert.location else 0.0,
            "longitude": alert.location.longitude if alert.location else 0.0,
            "name": alert.location.name if alert.location else "Unknown Location"
        },
        "distance_km": round(distance_km, 2),
        "bearing_deg": round(bearing_deg, 1),
        "view_count": 0,
        "verification_score": 0.0,
        "media_files": alert.media_files or [],
        "tags": [],
        "is_public": True,
        "submitted_at": alert.created_at.isoformat(),
        "processed_at": alert.created_at.isoformat(),
        "matrix_room_id": "",
        "reporter_id": alert.reporter_id or "",
        "reporter_username": alert.reporter_username,
        "enrichment": alert.enrichment or {},
        "photo_analysis": [],
        "total_confirmations": alert.witness_count,
        "can_confirm_witness": True,
        "comment_count": getattr(alert, 'comment_count', 0),
        "source": getattr(alert, 'source', None),
        "occurred_at": alert.occurred_at.isoformat() if alert.occurred_at else None,
        "external_url": getattr(alert, 'external_url', None),
        "short_url": short_url
    }
    
    # Add MUFON-specific UI widget hiding for frontend
    if getattr(alert, 'source', None) == "mufon":
        response.update({
            "hide_witness_section": True,
            "hide_witness_widget": True,
            "hide_location_widget": True,
            "hide_time_modal": True,
            "disable_time_pin": True,
            "hide_map_widget": True,
            "hide_map_section": True,
            "show_map": False,
            "show_witness_count": False,
            "show_location_pin": False,
            "can_confirm_witness": False,
            "comments_enabled": False
        })
    
    return response

# Alert endpoints
@router.post("")
async def create_alert(request: dict, idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")):
    """
    Create new alert with idempotency support for Sprint A Multi-Media Alerts.
    
    Unified endpoint replacing /beep/anonymous with duplicate prevention.
    """
    try:
        # Handle idempotency - if key exists, return cached result
        if idempotency_key:
            if idempotency_key in idempotency_store:
                logger.info(f"Returning cached result for idempotency key: {idempotency_key}")
                return idempotency_store[idempotency_key]
        
        print(f"Alert creation request: {request}")
        
        # Validate input
        device_id = request.get('device_id')
        if not device_id:
            raise HTTPException(status_code=400, detail="device_id is required")
        
        location = request.get('location')
        source = request.get('source')
        
        # Allow MUFON alerts without location data since they don't use notifications
        if source != "mufon":
            if not location or location.get('latitude') is None or location.get('longitude') is None:
                raise HTTPException(status_code=400, detail="location with latitude and longitude required")
        
        # All users have usernames now
        username = request.get('username')
        
        print(f"Creating alert - device_id: {device_id}, username: {username}")
        
        # Create alert
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        
        alert_id, jittered_location = await alerts_service.create_beep(
            device_id=device_id,
            location=location,
            description=request.get('description', ''),
            username=username,
            title=request.get('title'),
            source=request.get('source'),
            enrichment_data=request.get('enrichment_data'),
            occurred_at=request.get('occurred_at'),
            external_id=request.get('external_id')
        )
        
        # Send proximity alerts (critical for notifying nearby devices)
        has_pending_media = request.get('has_media', False)
        print(f"Debug: has_pending_media={has_pending_media}, alert_id={alert_id}")
        
        if not has_pending_media:
            print(f"Debug: Attempting to send proximity alerts for {alert_id}")
            try:
                # Use consistent import approach
                from services.proximity_alert_service import get_proximity_alert_service
                proximity_service = get_proximity_alert_service(db_pool)
                print(f"Debug: Proximity service initialized, calling send_proximity_alerts")
                alert_result = await proximity_service.send_proximity_alerts(
                    jittered_location["lat"], jittered_location["lng"], alert_id, device_id
                )
                print(f"Debug: Proximity alerts completed: {alert_result}")
            except Exception as e:
                print(f"Warning: Failed to send proximity alerts: {e}")
                alert_result = {"total_alerts_sent": 0, "message": "Alerts failed"}
        else:
            print(f"Debug: Media pending, deferring proximity alerts")
            alert_result = {"total_alerts_sent": 0, "alerts_deferred": True}
        
        # Don't close the pool - it's shared across the service
        
        # Get the created alert to include short_url in response
        alert = await alerts_service.get_alert_by_id(alert_id)
        
        # Format response like original /beep/anonymous for compatibility
        total_alerted = alert_result.get("total_alerts_sent", 0)
        if total_alerted == 0:
            alert_message = "Your beep was recorded but no nearby devices found."
        else:
            alert_message = f"Your beep alerted {total_alerted} people nearby!"
        
        response = {
            "sighting_id": alert_id,
            "message": "Anonymous beep sent successfully", 
            "alert_message": alert_message,
            "alert_stats": {"total_alerted": total_alerted, "radius_km": 25},
            "witness_count": 1,
            "location_jittered": True,
            "proximity_alerts": alert_result,
            "success": True,
            "data": {"jittered_location": jittered_location},
            "short_url": alert.short_url if alert else ""
        }
        
        # Cache result for idempotency
        if idempotency_key:
            idempotency_store[idempotency_key] = response
            
        logger.info(f"Successfully created alert {alert_id}")
        return response
        
    except Exception as e:
        print(f"Error creating alert: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating alert: {str(e)}")

@router.get("")
async def get_alerts(
    limit: int = 500,  # Increased from 20 to show all alerts
    offset: int = 0,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get recent alerts - clean endpoint using service layer with distance calculation"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        
        # Get both the paginated alerts and total count
        alerts = await alerts_service.get_recent_alerts(limit=limit, offset=offset)
        total_count = await alerts_service.get_total_alerts_count()
        
        # Calculate distances if user location is provided
        api_alerts = [format_alert_response(alert, latitude, longitude) for alert in alerts]
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": {
                "alerts": api_alerts,
                "total": total_count,
                "page": (offset // limit) + 1,
                "limit": limit
            }
        }
        
    except Exception as e:
        print(f"Error getting alerts: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alerts: {str(e)}")

@router.get("/by-short-url/{short_url}")
async def get_alert_by_short_url(
    short_url: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get specific alert by short URL - efficient endpoint to avoid fetching 1000 beeps"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        alert = await alerts_service.get_alert_by_short_url(short_url)
        
        if not alert:
            raise HTTPException(status_code=404, detail="Alert not found")
        
        return {
            "success": True,
            "data": {
                "alert": format_alert_response(alert, latitude, longitude)
            }
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error getting alert by short URL: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alert by short URL: {str(e)}")

@router.get("/{alert_id}")
async def get_alert_details(
    alert_id: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get specific alert details - supports both UUID and short URL automatically"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        
        # Try to get by UUID first, then fallback to short URL
        import uuid
        alert = None
        
        # Check if it looks like a UUID
        try:
            uuid.UUID(alert_id)
            # Valid UUID format, try to get by ID
            alert = await alerts_service.get_alert_by_id(alert_id)
        except ValueError:
            # Not a valid UUID, treat as short URL
            alert = await alerts_service.get_alert_by_short_url(alert_id)
        
        if not alert:
            raise HTTPException(status_code=404, detail="Alert not found")
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": format_alert_response(alert, latitude, longitude),
            "message": "Alert found"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error getting alert details: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alert details: {str(e)}")

@router.post("/{beep_id}/media")
async def upload_beep_media(
    beep_id: str,
    files: List[UploadFile] = File(...),
    source: str = Form("user_upload"),
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")
):
    """
    Single source of truth for media uploads to beeps.
    Used by mobile app and future upload scripts (NUFORC, etc).
    """
    from app.services.media_service import get_media_service
    
    try:
        # Handle idempotency - if key exists, return cached result
        if idempotency_key:
            if idempotency_key in idempotency_store:
                logger.info(f"Returning cached result for idempotency key: {idempotency_key}")
                return idempotency_store[idempotency_key]
        
        if not files:
            raise HTTPException(status_code=400, detail="No files provided")
            
        # Check if beep exists
        db_pool = await get_db()
        async with db_pool.acquire() as conn:
            beep = await conn.fetchrow("""
                SELECT id FROM sightings WHERE id = $1
            """, uuid.uuid4() if beep_id == 'test' else uuid.UUID(beep_id))
            
            if not beep:
                raise HTTPException(status_code=404, detail="Beep not found")
        
        # Use existing media service for actual upload
        media_service = get_media_service()
        uploaded_media = []
        
        for file in files:
            # Generate unique media ID
            media_id = str(uuid.uuid4())
            
            # Upload file using existing media service
            upload_result = await media_service.upload_file(
                file=file,
                media_id=media_id,
                source=source
            )
            
            # Format response for consistency
            media_item = {
                "id": media_id,
                "filename": file.filename,
                "url": upload_result.get("url", f"https://ufobeep.com/api/media/{media_id}"),
                "thumbnail_url": upload_result.get("thumbnail_url"),
                "type": upload_result.get("type", "unknown"),
                "size": upload_result.get("size", 0),
                "width": upload_result.get("width"),
                "height": upload_result.get("height"),
                "uploaded_at": datetime.now().isoformat()
            }
            
            uploaded_media.append(media_item)
        
        response = {
            "success": True,
            "beep_id": beep_id,
            "media": uploaded_media,
            "count": len(uploaded_media),
            "timestamp": datetime.now().isoformat()
        }
        
        # Cache result for idempotency
        if idempotency_key:
            idempotency_store[idempotency_key] = response
            
        logger.info(f"Successfully uploaded {len(uploaded_media)} media files to beep {beep_id}")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Media upload failed for beep {beep_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.post("/{alert_id}/witnesses")
async def add_witness(alert_id: str, payload: WitnessConfirmation):
    """Add witness confirmation to alert - RESTful endpoint"""
    try:
        # Normalize: prefer nested location, fallback to flat fields
        if payload.location:
            lat = payload.location.latitude
            lon = payload.location.longitude
            alt = payload.location.altitude
            acc = payload.location.accuracy
        else:
            lat = payload.latitude
            lon = payload.longitude
            alt = payload.altitude
            acc = payload.accuracy

        if lat is None or lon is None:
            raise HTTPException(status_code=422, detail="latitude/longitude required")

        # Create normalized witness data
        witness_data: Dict[str, Any] = {
            "device_id": payload.device_id,
            "witness_type": payload.witness_type,
            "confirmed": payload.confirmed,
            "latitude": lat,
            "longitude": lon,
            "altitude": alt,
            "accuracy": acc,
            "still_visible": payload.still_visible,
            "quick_action": payload.quick_action,
        }
        
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        result = await alerts_service.confirm_witness(
            sighting_id=alert_id,
            device_id=payload.device_id,
            witness_data=witness_data
        )
        
        return {
            "success": True,
            "data": result,
            "message": "Witness confirmed successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error confirming witness: {e}")
        raise HTTPException(status_code=500, detail=f"Error confirming witness: {str(e)}")

@router.get("/{alert_id}/witnesses/{device_id}")
async def get_witness(alert_id: str, device_id: str):
    """Get specific witness status - RESTful endpoint"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        result = await alerts_service.get_witness_status(alert_id, device_id)
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": result,
            "message": "Witness status retrieved"
        }
        
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    except Exception as e:
        print(f"Error getting witness status: {e}")
        raise HTTPException(status_code=500, detail=str(e))

@router.get("/{alert_id}/witness-aggregation")
async def get_witness_aggregation(alert_id: str):
    """Get witness aggregation data for an alert"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        result = await alerts_service.get_witness_aggregation(alert_id)
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": result,
            "message": "Witness aggregation retrieved"
        }
        
    except Exception as e:
        print(f"Error getting witness aggregation: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting witness aggregation: {str(e)}")

@router.post("/send/{alert_id}")
async def send_alert_beep(alert_id: str, request: dict):
    """Trigger proximity alerts for an alert - called by mobile app after media upload"""
    try:
        device_id = request.get('device_id', 'unknown')
        
        db_pool = await get_db()
        
        # Get location from request body
        location = request.get('location', {})
        if not location.get('latitude') or not location.get('longitude'):
            raise HTTPException(status_code=400, detail="Location data required in request body")
        
        latitude = location['latitude']
        longitude = location['longitude']
        
        # Trigger proximity alerts
        print(f"Debug: Sending beep alerts for {alert_id} from device {device_id}")
        from services.proximity_alert_service import get_proximity_alert_service
        
        proximity_service = get_proximity_alert_service(db_pool)
        alert_result = await proximity_service.send_proximity_alerts(
            latitude, longitude, alert_id, device_id
        )
        print(f"Debug: Beep proximity alerts sent: {alert_result}")
        
        return {
            "success": True,
            "data": alert_result,
            "message": f"Beep sent to {alert_result.get('total_alerts_sent', 0)} nearby devices"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error sending alert beep: {e}")
        raise HTTPException(status_code=500, detail=f"Error sending alert beep: {str(e)}")

