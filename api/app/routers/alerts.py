from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Header
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from app.services.alerts_service import AlertsService
import asyncpg
import uuid
import logging

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/alerts", tags=["alerts"])

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
    
    # Generate short URL using shared Node.js module
    from app.utils.short_url_utils import generate_short_url
    short_url = generate_short_url(str(alert.id))
    
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
        "original_language": getattr(alert, 'original_language', None),
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
            # DISABLED: Old proximity alert system - now using enrichment-based fanout
            # Notifications are sent by alert_fanout_worker after enrichment completes
            # This prevents duplicate notifications (one from old system, one from new)
            print(f"Debug: Using enrichment-based alert fanout (old proximity system disabled)")
            alert_result = {"total_alerts_sent": 0, "message": "Using enrichment-based alerts"}

        # Run enrichment synchronously for the new alert
        try:
            from app.worker import enrich_sighting
            logger.info(f"Starting enrichment for alert {alert_id}")
            success = await enrich_sighting(alert_id)
            if success:
                logger.info(f"✅ Successfully enriched alert {alert_id}")
            else:
                logger.error(f"❌ Failed to enrich alert {alert_id}")
        except Exception as e:
            logger.error(f"Failed to enrich alert {alert_id}: {e}")

        # Don't close the pool - it's shared across the service
        
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
            "data": {"jittered_location": jittered_location}
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

@router.get("/{alert_id}")
async def get_alert_details(
    alert_id: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get specific alert details - clean endpoint using service layer with distance calculation"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        alert = await alerts_service.get_alert_by_id(alert_id)
        
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

@router.post("/{alert_id}/media")
async def upload_alert_media(
    alert_id: str,
    files: List[UploadFile] = File(...),
    source: str = Form("user_upload"),
    description: Optional[str] = Form(None),
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")
):
    """
    Upload media files to an alert with idempotency support for Sprint A Multi-Media Alerts.
    
    Provides processing pipeline with duplicate prevention.
    """
    import json
    import uuid
    from datetime import datetime
    from pathlib import Path
    import shutil
    from app.services.media_processing_service import MediaProcessingService
    
    try:
        # Handle idempotency - if key exists, return cached result
        if idempotency_key:
            if idempotency_key in idempotency_store:
                logger.info(f"Returning cached result for idempotency key: {idempotency_key}")
                return idempotency_store[idempotency_key]
        
        print(f"Media upload request: alert_id={alert_id}, files={files}, source={source}")
        print(f"Files type: {type(files)}, Files length: {len(files) if files else 'None'}")
        
        if not files:
            raise HTTPException(status_code=400, detail="No files provided")
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            # Check if alert exists
            sighting = await conn.fetchrow("""
                SELECT id, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(alert_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Alert not found")
            
            # Get existing media info
            if sighting['media_info']:
                existing_media = json.loads(sighting['media_info'])
                # Ensure files key exists
                if 'files' not in existing_media:
                    existing_media['files'] = []
            else:
                existing_media = {'files': [], 'file_count': 0}
            
            # Set up media processing
            media_root = Path("/home/ufobeep/ufobeep/media")
            sighting_media_dir = media_root / alert_id
            sighting_media_dir.mkdir(parents=True, exist_ok=True)
            
            media_processor = MediaProcessingService(media_root)
            new_media_files = []
            
            for file in files:
                # Generate unique filename
                file_ext = Path(file.filename).suffix
                unique_filename = f"{uuid.uuid4()}{file_ext}"
                file_path = sighting_media_dir / unique_filename
                
                # Save original file
                with file_path.open("wb") as buffer:
                    shutil.copyfileobj(file.file, buffer)
                
                # Process media file (generate thumbnails, web versions, etc.)
                try:
                    processed_urls = media_processor.process_media_file(file_path, alert_id)
                    print(f"Media processing complete for {file.filename}: {processed_urls}")
                except Exception as e:
                    print(f"Media processing failed for {file.filename}: {e}")
                    # Fallback to basic URLs if processing fails
                    processed_urls = {
                        'original': f'https://ufobeep.com/api/media/{alert_id}/{unique_filename}',
                        'thumbnail': f'https://ufobeep.com/api/media/{alert_id}/{unique_filename}',
                        'web': f'https://ufobeep.com/api/media/{alert_id}/{unique_filename}',
                        'preview': f'https://ufobeep.com/api/media/{alert_id}/{unique_filename}'
                    }
                
                # Create media file entry with all variants
                media_entry = {
                    'id': str(uuid.uuid4()),
                    'type': 'video' if file_ext.lower() in ['.mp4', '.mov', '.avi'] else 'image',
                    'filename': unique_filename,
                    'original_name': file.filename,
                    'url': processed_urls['original'],
                    'thumbnail_url': processed_urls['thumbnail'],
                    'web_url': processed_urls['web'],
                    'preview_url': processed_urls['preview'],
                    'uploaded_at': datetime.now().isoformat(),
                    'source': source,
                    'description': description
                }
                
                # Add EXIF data if available (diplomatically extracted)
                if 'exif_data' in processed_urls:
                    media_entry['exif_data'] = processed_urls['exif_data']
                
                new_media_files.append(media_entry)
            
            # Merge with existing media
            existing_media['files'].extend(new_media_files)
            existing_media['file_count'] = len(existing_media['files'])
            
            # Sanitize JSON data to remove null bytes that break PostgreSQL
            def sanitize_for_json(obj):
                if isinstance(obj, dict):
                    return {k: sanitize_for_json(v) for k, v in obj.items()}
                elif isinstance(obj, list):
                    return [sanitize_for_json(item) for item in obj]
                elif isinstance(obj, str):
                    # Remove null bytes and other problematic characters
                    return obj.replace('\x00', '').replace('\u0000', '')
                else:
                    return obj
            
            sanitized_media = sanitize_for_json(existing_media)
            
            # Update sighting
            await conn.execute("""
                UPDATE sightings 
                SET media_info = $1,
                    updated_at = NOW()
                WHERE id = $2
            """, json.dumps(sanitized_media), uuid.UUID(alert_id))
            
            # Don't close the pool - it's shared across the service
            
            response = {
                "success": True,
                "alert_id": alert_id,
                "added_files": len(new_media_files),
                "total_files": existing_media['file_count'],
                "new_media": new_media_files
            }
            
            # Cache result for idempotency
            if idempotency_key:
                idempotency_store[idempotency_key] = response
                
            logger.info(f"Successfully uploaded {len(new_media_files)} media files to alert {alert_id}")
            return response
        
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"Error uploading media: {e}")
        print(f"Full traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Media upload failed: {str(e)}")

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