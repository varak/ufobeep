from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Header
from typing import List, Optional, Dict, Any
from pydantic import BaseModel, Field
from app.services.alerts_service import AlertsService
import asyncpg
import uuid
import logging
import json
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
            "latitude": alert.location.latitude if alert.location else (
                alert.enrichment.get("geocoding", {}).get("latitude", 0.0) if alert.enrichment else 0.0
            ),
            "longitude": alert.location.longitude if alert.location else (
                alert.enrichment.get("geocoding", {}).get("longitude", 0.0) if alert.enrichment else 0.0
            ),
            "name": alert.location.name if alert.location and alert.location.name != "Unknown Location" else (
                alert.enrichment.get("geocoding", {}).get("display_name") or
                alert.enrichment.get("geocoding", {}).get("location", "Unknown Location") if alert.enrichment else "Unknown Location"
            )
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
        "reporter_username": "MUFON" if getattr(alert, 'source', None) == "mufon" else alert.reporter_username,
        "enrichment_data": alert.enrichment or {},
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
    limit: int = 20,  # Reasonable default for pagination
    offset: int = 0,
    page: Optional[int] = None,  # Page-based pagination support
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get recent alerts - clean endpoint using service layer with distance calculation"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)

        # Handle page-based pagination
        if page is not None:
            if page < 1:
                page = 1
            offset = (page - 1) * limit

        # Get both the paginated alerts and total count
        alerts = await alerts_service.get_recent_alerts(limit=limit, offset=offset)
        total_count = await alerts_service.get_total_alerts_count()

        # Calculate pagination metadata
        current_page = (offset // limit) + 1
        total_pages = (total_count + limit - 1) // limit  # CEIL(total_count / limit)

        # Calculate distances if user location is provided
        api_alerts = [format_alert_response(alert, latitude, longitude) for alert in alerts]

        # Don't close the pool - it's shared across the service

        return {
            "success": True,
            "data": {
                "alerts": api_alerts,
                "total": total_count,
                "page": current_page,
                "totalPages": total_pages,
                "limit": limit,
                "hasNextPage": current_page < total_pages,
                "hasPrevPage": current_page > 1
            }
        }
        
    except Exception as e:
        print(f"Error getting alerts: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alerts: {str(e)}")

@router.get("/map-points")
async def get_map_points(minimal: bool = False):
    """Get ALL alert points for map display

    Args:
        minimal: If true, returns only id/lat/lng for performance with thousands of points
    """
    try:
        db_pool = await get_db()

        async with db_pool.acquire() as connection:
            if minimal:
                # Ultra-minimal for initial map load (include only coords + minimal source flag)
                query = """
                    SELECT
                        id,
                        public_latitude,
                        public_longitude,
                        LOWER(source) AS source
                    FROM sightings
                    WHERE (public_latitude != 0 OR public_longitude != 0)
                    AND public_latitude IS NOT NULL
                    AND public_longitude IS NOT NULL
                    ORDER BY created_at DESC
                """
            else:
                # Full data for popups
                query = """
                    SELECT
                        id,
                        title,
                        description,
                        public_latitude,
                        public_longitude,
                        COALESCE(
                            enrichment_data->'geocoding'->>'display_name',
                            enrichment_data->'geocoding'->>'location',
                            enrichment_data->>'location_name',
                            'Unknown Location'
                        ) as location_name,
                        created_at,
                        source,
                        media_info as media_files,
                        enrichment_data,
                        short_url
                    FROM sightings
                    WHERE (public_latitude != 0 OR public_longitude != 0)
                    AND public_latitude IS NOT NULL
                    AND public_longitude IS NOT NULL
                    ORDER BY created_at DESC
                """

            rows = await connection.fetch(query)

            map_points = []
            for row in rows:
                if minimal:
                    # Minimal payload: id + coords + tiny flag 'b' (1 = UFOBeep)
                    src = row["source"] or ''
                    is_ufb = src in ("ufobeep", "beep", "ufo_beep", "ufo-beep")
                    point = {
                        "id": str(row["id"]),
                        "location": {
                            "latitude": float(row["public_latitude"]),
                            "longitude": float(row["public_longitude"])
                        },
                        # Single-character flag: 1 for UFOBeep, null otherwise
                        "b": 1 if is_ufb else None
                    }
                else:
                    # Full data for popups
                    point = {
                        "id": str(row["id"]),
                        "title": row["title"],
                        "description": row["description"],
                        "location": {
                            "latitude": float(row["public_latitude"]),
                            "longitude": float(row["public_longitude"]),
                            "name": row["location_name"] or "Unknown Location"
                        },
                        "created_at": row["created_at"].isoformat(),
                        "source": row["source"],
                        "media_files": json.loads(row["media_files"]).get("files", []) if row["media_files"] else [],
                        "enrichment_data": row["enrichment_data"] or {},
                        "alert_level": "medium",  # Default for now
                        "short_url": row["short_url"]
                    }
                map_points.append(point)

            return {
                "success": True,
                "data": {
                    "alerts": map_points,
                    "total": len(map_points)
                }
            }

    except Exception as e:
        print(f"Error getting map points: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting map points: {str(e)}")

@router.get("/{alert_id}")
async def get_alert_by_id(
    alert_id: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get specific alert by ID"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)

        # Query alert by ID or short_url
        async with db_pool.acquire() as connection:
            # Try both UUID and short_url in a single query
            row = None
            try:
                import uuid as uuid_lib
                # Check if it's a valid UUID format
                alert_uuid = uuid_lib.UUID(alert_id)
                query = """
                    SELECT s.*, u.username as reporter_username
                    FROM sightings s
                    LEFT JOIN users u ON s.reporter_id = u.id::text
                    WHERE s.id = $1 OR s.short_url = $2
                """
                row = await connection.fetchrow(query, alert_uuid, alert_id)
            except:
                # Not a UUID, only check short_url
                query = """
                    SELECT s.*, u.username as reporter_username
                    FROM sightings s
                    LEFT JOIN users u ON s.reporter_id = u.id::text
                    WHERE s.short_url = $1
                """
                row = await connection.fetchrow(query, alert_id)

            if not row:
                raise HTTPException(status_code=404, detail="Alert not found")

            # Format the response - use correct column names
            # Parse enrichment_data if it's a string
            enrichment = row["enrichment_data"]
            if isinstance(enrichment, str):
                try:
                    enrichment = json.loads(enrichment)
                except:
                    enrichment = {}

            location_name = "Unknown Location"
            if enrichment and isinstance(enrichment, dict):
                location_name = enrichment.get("geocoding", {}).get("location_name") or \
                               enrichment.get("location_name") or \
                               "Unknown Location"

            # Generate title if missing (especially for MUFON)
            title = row["title"]
            if not title and row["source"] == "mufon" and enrichment:
                shape = enrichment.get("shape", "Unknown")
                title = f"{shape} reported"

            # Get short_url from row or generate it from ID using the canonical algorithm
            short_url = row.get("short_url")
            if not short_url:
                # Implement getShortHash from shared/get_short_hash.js
                SAFE_CHARS = '23456789abcdefghjkmnpqrstuvwxyz'
                input_str = str(row["id"])

                # Generate hash using the exact algorithm from get_short_hash.js
                hash_val = 0
                for char in input_str:
                    hash_val = ((hash_val << 5) - hash_val) + ord(char)
                    hash_val = hash_val & 0xFFFFFFFF  # Convert to 32-bit integer

                # Convert hash to base-29 using safe characters
                short_url = ''
                num = abs(hash_val)
                for _ in range(5):  # 5 characters
                    short_url = SAFE_CHARS[num % len(SAFE_CHARS)] + short_url
                    num = num // len(SAFE_CHARS)

            alert = {
                "id": str(row["id"]),
                "short_url": short_url,
                "title": title or "UFO Sighting",
                "description": row["description"] or "",
                "location": {
                    "latitude": float(row["public_latitude"]) if row["public_latitude"] else 0,
                    "longitude": float(row["public_longitude"]) if row["public_longitude"] else 0,
                    "name": location_name
                },
                "created_at": row["created_at"].isoformat() if row["created_at"] else "",
                "source": row["source"] or "",
                "username": "MUFON" if row["source"] == "mufon" else row.get("reporter_username", ""),
                "media_files": json.loads(row["media_info"]).get("files", []) if row.get("media_info") else [],
                "enrichment_data": enrichment,
                "alert_level": "medium"
            }

            # Calculate distance if user location provided
            if latitude and longitude and alert["location"]["latitude"] and alert["location"]["longitude"]:
                from math import radians, sin, cos, sqrt, atan2
                R = 6371  # Earth's radius in km
                lat1, lon1 = radians(latitude), radians(longitude)
                lat2, lon2 = radians(alert["location"]["latitude"]), radians(alert["location"]["longitude"])
                dlat = lat2 - lat1
                dlon = lon2 - lon1
                a = sin(dlat/2)**2 + cos(lat1) * cos(lat2) * sin(dlon/2)**2
                c = 2 * atan2(sqrt(a), sqrt(1-a))
                alert["distance_km"] = round(R * c, 1)

            return {
                "success": True,
                "data": alert
            }

    except HTTPException:
        raise
    except Exception as e:
        print(f"Error getting alert by ID: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alert: {str(e)}")

@router.get("/by-short-url/{short_url}")
async def get_alert_by_short_url(
    short_url: str,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None
):
    """Get specific alert by short URL - efficient endpoint to avoid fetching 1000 beeps

    ⚠️ WARNING: This endpoint uses DIFFERENT response structure than /beep/{id}
    - This returns: { data: { alert: {...} } } (nested)
    - Main endpoint returns: { data: {...} } (flat)

    Used ONLY by Next.js middleware for short URL redirects.
    DO NOT USE for new features - use /beep/{id} instead.

    TODO: Migrate middleware to use /beep/{id} and remove this endpoint.
    """
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

# REMOVED DUPLICATE ENDPOINT - already defined above
# @router.get("/{alert_id}")
# async def get_alert_details(
#     alert_id: str,
#     latitude: Optional[float] = None,
#     longitude: Optional[float] = None
# ):
#     """Get specific alert details - supports both UUID and short URL automatically"""
#     try:
#         db_pool = await get_db()
#         alerts_service = AlertsService(db_pool)
#
#         # Try to get by UUID first, then fallback to short URL
#         import uuid
#         alert = None
#
#         # Check if it looks like a UUID
#         try:
#             uuid.UUID(alert_id)
#             # Valid UUID format, try to get by ID
#             alert = await alerts_service.get_alert_by_id(alert_id)
#         except ValueError:
#             # Not a valid UUID, treat as short URL
#             alert = await alerts_service.get_alert_by_short_url(alert_id)
#
#         if not alert:
#             raise HTTPException(status_code=404, detail="Alert not found")
#
#         # Don't close the pool - it's shared across the service
#
#         return {
#             "success": True,
#             "data": format_alert_response(alert, latitude, longitude),
#             "message": "Alert found"
#         }
#
#     except HTTPException:
#         raise
#     except Exception as e:
#         print(f"Error getting alert details: {e}")
#         raise HTTPException(status_code=500, detail=f"Error getting alert details: {str(e)}")

@router.post("/{beep_id}/media")
async def upload_beep_media(
    beep_id: str,
    files: List[UploadFile] = File(...),
    source: str = Form("user_upload"),
    description: Optional[str] = Form(None),
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")
):
    """
    Single source of truth for media uploads to beeps.
    Used by mobile app and future upload scripts (NUFORC, etc).
    Uses same proven implementation as alerts endpoint.
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
        
        print(f"Media upload request: beep_id={beep_id}, files={files}, source={source}")
        print(f"Files type: {type(files)}, Files length: {len(files) if files else 'None'}")
        
        if not files:
            raise HTTPException(status_code=400, detail="No files provided")
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            # Check if beep exists
            sighting = await conn.fetchrow("""
                SELECT id, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(beep_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Beep not found")
            
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
            sighting_media_dir = media_root / beep_id
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
                    processed_urls = media_processor.process_media_file(file_path, beep_id)
                    print(f"Media processing complete for {file.filename}: {processed_urls}")
                except Exception as e:
                    print(f"Media processing failed for {file.filename}: {e}")
                    # Fallback to basic URLs if processing fails
                    processed_urls = {
                        'original': f'https://ufobeep.com/api/media/{beep_id}/{unique_filename}',
                        'thumbnail': f'https://ufobeep.com/api/media/{beep_id}/{unique_filename}',
                        'web': f'https://ufobeep.com/api/media/{beep_id}/{unique_filename}',
                        'preview': f'https://ufobeep.com/api/media/{beep_id}/{unique_filename}'
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
            """, json.dumps(sanitized_media), uuid.UUID(beep_id))
            
            # Don't close the pool - it's shared across the service
            
            response = {
                "success": True,
                "beep_id": beep_id,
                "added_files": len(new_media_files),
                "total_files": existing_media['file_count'],
                "new_media": new_media_files,
                "count": len(new_media_files),
                "timestamp": datetime.now().isoformat()
            }
            
            # Cache result for idempotency
            if idempotency_key:
                idempotency_store[idempotency_key] = response
                
            logger.info(f"Successfully uploaded {len(new_media_files)} media files to beep {beep_id}")
            return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Media upload failed for beep {beep_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")

@router.patch("/{beep_id}/media")
async def update_beep_media(beep_id: str, request: dict):
    """
    Update beep with media file names - called after individual file uploads.
    Matches the frontend expectation for PATCH /beep/{sighting_id}/media.
    """
    import json
    import uuid
    
    try:
        media_files = request.get('media_files', [])
        print(f"Updating beep {beep_id} with media files: {media_files}")
        
        if not media_files:
            raise HTTPException(status_code=400, detail="No media_files provided")
        
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            # Check if beep exists
            sighting = await conn.fetchrow("""
                SELECT id, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(beep_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Beep not found")
            
            # Get existing media info
            if sighting['media_info']:
                existing_media = json.loads(sighting['media_info'])
                if 'files' not in existing_media:
                    existing_media['files'] = []
            else:
                existing_media = {'files': [], 'file_count': 0}
            
            # Update media files list (this is what the frontend expects)
            existing_media['media_files'] = media_files
            existing_media['file_count'] = len(media_files)
            
            # Update sighting
            await conn.execute("""
                UPDATE sightings 
                SET media_info = $1,
                    updated_at = NOW()
                WHERE id = $2
            """, json.dumps(existing_media), uuid.UUID(beep_id))
        
        return {
            "success": True,
            "beep_id": beep_id,
            "media_files": media_files,
            "message": "Media files updated successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error updating beep media: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update media: {str(e)}")

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
