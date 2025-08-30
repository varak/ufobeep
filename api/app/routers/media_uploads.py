import os
import logging
import uuid
from datetime import datetime
from pathlib import Path
from typing import List, Optional

from fastapi import APIRouter, HTTPException, UploadFile, File, Form, Header, Depends
from app.services.database_service import database_service
from app.services.media_service import get_media_service

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/media",
    tags=["media-uploads"],
    responses={
        400: {"description": "Invalid request"},
        409: {"description": "Duplicate upload (idempotency)"},
        500: {"description": "Upload failed"},
    }
)

# In-memory store for idempotency keys (in production would use Redis)
idempotency_store = {}

@router.post("/uploads")
async def upload_media_files(
    files: List[UploadFile] = File(...),
    source: str = Form("user_upload"),
    idempotency_key: Optional[str] = Header(None, alias="Idempotency-Key")
):
    """
    Upload media files with idempotency support for Sprint A Multi-Media Alerts.
    
    Returns media metadata that can be attached to alerts via /alerts endpoint
    or /alerts/{id}/media endpoint for additional media.
    """
    try:
        # Handle idempotency - if key exists, return cached result
        if idempotency_key:
            if idempotency_key in idempotency_store:
                logger.info(f"Returning cached result for idempotency key: {idempotency_key}")
                return idempotency_store[idempotency_key]
        
        if not files:
            raise HTTPException(status_code=400, detail="No files provided")
        
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
            
            # Format response according to MP16 test expectations
            media_item = {
                "id": media_id,
                "filename": file.filename,
                "url": upload_result.get("url", f"https://api.ufobeep.com/media/{media_id}"),
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
            "media": uploaded_media,
            "count": len(uploaded_media),
            "timestamp": datetime.now().isoformat()
        }
        
        # Cache result for idempotency
        if idempotency_key:
            idempotency_store[idempotency_key] = response
            
        logger.info(f"Successfully uploaded {len(uploaded_media)} media files")
        return response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Media upload failed: {e}")
        raise HTTPException(status_code=500, detail=f"Upload failed: {str(e)}")