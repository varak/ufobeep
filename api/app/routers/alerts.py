from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import List, Optional
from app.services.alerts_service import AlertsService
import asyncpg

router = APIRouter(prefix="/alerts", tags=["alerts"])

# Shared utilities
async def get_db():
    """Get database connection pool"""
    return await asyncpg.create_pool(
        host="localhost", port=5432, user="ufobeep_user", 
        password="ufopostpass", database="ufobeep_db",
        min_size=1, max_size=10
    )

def format_alert_response(alert):
    """Format alert data for API response"""
    return {
        "id": alert.id,
        "title": alert.title,
        "description": alert.description,
        "category": alert.category,
        "alert_level": alert.alert_level,
        "status": "active",
        "witness_count": alert.witness_count,
        "created_at": alert.created_at.isoformat(),
        "location": {
            "latitude": alert.location.latitude,
            "longitude": alert.location.longitude,
            "name": alert.location.name
        },
        "distance_km": 0.0,
        "bearing_deg": 0.0,
        "view_count": 0,
        "verification_score": 0.0,
        "media_files": alert.media_files or [],
        "tags": [],
        "is_public": True,
        "submitted_at": alert.created_at.isoformat(),
        "processed_at": alert.created_at.isoformat(),
        "matrix_room_id": "",
        "reporter_id": "",
        "enrichment": alert.enrichment or {},
        "photo_analysis": [],
        "total_confirmations": alert.witness_count,
        "can_confirm_witness": True
    }

# Alert endpoints
@router.post("")
async def create_alert(request: dict):
    """Create new alert - unified endpoint replacing /beep/anonymous"""
    print(f"Alert creation request: {request}")
    
    # Validate input
    device_id = request.get('device_id')
    if not device_id:
        raise HTTPException(status_code=400, detail="device_id is required")
    
    location = request.get('location')
    if not location or location.get('latitude') is None or location.get('longitude') is None:
        raise HTTPException(status_code=400, detail="location with latitude and longitude required")
    
    # Create alert
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        
        alert_id, jittered_location = await alerts_service.create_anonymous_beep(
            device_id=device_id,
            location=location,
            description=request.get('description', '')
        )
        
        # Send proximity alerts (critical for notifying nearby devices)
        has_pending_media = request.get('has_media', False)
        print(f"Debug: has_pending_media={has_pending_media}, alert_id={alert_id}")
        
        if not has_pending_media:
            print(f"Debug: Attempting to send proximity alerts for {alert_id}")
            try:
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
        
        # Format response like original /beep/anonymous for compatibility
        total_alerted = alert_result.get("total_alerts_sent", 0)
        if total_alerted == 0:
            alert_message = "Your beep was recorded but no nearby devices found."
        else:
            alert_message = f"Your beep alerted {total_alerted} people nearby!"
        
        return {
            "sighting_id": alert_id,
            "message": "Anonymous beep sent successfully", 
            "alert_message": alert_message,
            "alert_stats": {"total_alerted": total_alerted, "radius_km": 25},
            "witness_count": 1,
            "location_jittered": True,
            "proximity_alerts": alert_result,
            # Also include new format for compatibility
            "success": True,
            "data": {"alert_id": alert_id, "jittered_location": jittered_location}
        }
        
    except Exception as e:
        print(f"Error creating alert: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating alert: {str(e)}")

@router.get("")
async def get_alerts(limit: int = 20, offset: int = 0):
    """Get recent alerts - clean endpoint using service layer"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        alerts = await alerts_service.get_recent_alerts(limit=limit)
        
        api_alerts = [format_alert_response(alert) for alert in alerts]
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": {"alerts": api_alerts},
            "total": len(api_alerts),
            "limit": limit,
            "offset": offset
        }
        
    except Exception as e:
        print(f"Error getting alerts: {e}")
        raise HTTPException(status_code=500, detail=f"Error getting alerts: {str(e)}")

@router.get("/{alert_id}")
async def get_alert_details(alert_id: str):
    """Get specific alert details - clean endpoint using service layer"""
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        alert = await alerts_service.get_alert_by_id(alert_id)
        
        if not alert:
            raise HTTPException(status_code=404, detail="Alert not found")
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": format_alert_response(alert),
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
    description: Optional[str] = Form(None)
):
    """Upload media files to an alert with processing pipeline"""
    import json
    import uuid
    from datetime import datetime
    from pathlib import Path
    import shutil
    from app.services.media_processing_service import MediaProcessingService
    
    try:
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
                        'original': f'https://api.ufobeep.com/media/{alert_id}/{unique_filename}',
                        'thumbnail': f'https://api.ufobeep.com/media/{alert_id}/{unique_filename}',
                        'web': f'https://api.ufobeep.com/media/{alert_id}/{unique_filename}',
                        'preview': f'https://api.ufobeep.com/media/{alert_id}/{unique_filename}'
                    }
                
                # Create media file entry with all variants
                new_media_files.append({
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
                })
            
            # Merge with existing media
            existing_media['files'].extend(new_media_files)
            existing_media['file_count'] = len(existing_media['files'])
            
            # Update sighting
            await conn.execute("""
                UPDATE sightings 
                SET media_info = $1,
                    updated_at = NOW()
                WHERE id = $2
            """, json.dumps(existing_media), uuid.UUID(alert_id))
            
            # Don't close the pool - it's shared across the service
            
            return {
                "success": True,
                "alert_id": alert_id,
                "added_files": len(new_media_files),
                "total_files": existing_media['file_count'],
                "new_media": new_media_files
            }
        
    except HTTPException:
        raise
    except Exception as e:
        import traceback
        print(f"Error uploading media: {e}")
        print(f"Full traceback: {traceback.format_exc()}")
        raise HTTPException(status_code=500, detail=f"Media upload failed: {str(e)}")

@router.post("/{alert_id}/witnesses")
async def add_witness(alert_id: str, request: dict):
    """Add witness confirmation to alert - RESTful endpoint"""
    device_id = request.get("device_id")
    if not device_id:
        raise HTTPException(status_code=400, detail="device_id is required")
    
    try:
        db_pool = await get_db()
        alerts_service = AlertsService(db_pool)
        result = await alerts_service.confirm_witness(
            sighting_id=alert_id,
            device_id=device_id,
            witness_data=request
        )
        
        # Don't close the pool - it's shared across the service
        
        return {
            "success": True,
            "data": result,
            "message": "Witness confirmed successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error confirming witness: {e}")
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