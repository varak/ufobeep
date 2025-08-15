"""
Media management endpoints for multi-media functionality
"""
from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel
from typing import Optional, List
import asyncpg
from datetime import datetime

router = APIRouter(prefix="/media", tags=["media-management"])

class SetPrimaryRequest(BaseModel):
    """Request to set media as primary for a sighting"""
    pass

class UpdatePriorityRequest(BaseModel):
    """Request to update display priority of media"""
    priority: int

class MediaResponse(BaseModel):
    """Response for media operations"""
    success: bool
    message: str
    media_id: str
    is_primary: bool

# Database connection helper
async def get_db_connection():
    """Get database connection"""
    return await asyncpg.connect(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db"
    )

@router.put("/{media_id}/set-primary")
async def set_primary_media(
    media_id: str,
    request: SetPrimaryRequest,
    # TODO: Add user authentication
    # current_user_id: Optional[str] = Depends(get_current_user)
):
    """Set a media file as the primary display image for its sighting"""
    
    conn = await get_db_connection()
    try:
        # Get media info and verify it exists
        media_info = await conn.fetchrow("""
            SELECT m.sighting_id, m.is_primary, s.reporter_id
            FROM media_files m
            JOIN sightings s ON m.sighting_id = s.id
            WHERE m.id = $1
        """, media_id)
        
        if not media_info:
            raise HTTPException(status_code=404, detail="Media file not found")
        
        sighting_id = media_info['sighting_id']
        current_is_primary = media_info['is_primary']
        
        # TODO: Check user permissions (reporter or admin)
        # reporter_id = media_info['reporter_id']
        # if current_user_id != reporter_id and not is_admin(current_user_id):
        #     raise HTTPException(status_code=403, detail="Not authorized to modify this sighting")
        
        if current_is_primary:
            return MediaResponse(
                success=True,
                message="Media is already primary",
                media_id=media_id,
                is_primary=True
            )
        
        # Use transaction to ensure atomicity
        async with conn.transaction():
            # Remove primary flag from current primary media
            await conn.execute("""
                UPDATE media_files 
                SET is_primary = FALSE 
                WHERE sighting_id = $1 AND is_primary = TRUE
            """, sighting_id)
            
            # Set this media as primary
            await conn.execute("""
                UPDATE media_files 
                SET is_primary = TRUE, 
                    display_priority = 999,
                    updated_at = NOW()
                WHERE id = $1
            """, media_id)
        
        return MediaResponse(
            success=True,
            message="Media set as primary",
            media_id=media_id,
            is_primary=True
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to set primary media: {str(e)}")
    finally:
        await conn.close()

@router.put("/{media_id}/priority")
async def update_media_priority(
    media_id: str,
    request: UpdatePriorityRequest,
    # TODO: Add user authentication
    # current_user_id: Optional[str] = Depends(get_current_user)
):
    """Update display priority of a media file"""
    
    conn = await get_db_connection()
    try:
        # Get media info and verify permissions
        media_info = await conn.fetchrow("""
            SELECT m.sighting_id, s.reporter_id
            FROM media_files m
            JOIN sightings s ON m.sighting_id = s.id
            WHERE m.id = $1
        """, media_id)
        
        if not media_info:
            raise HTTPException(status_code=404, detail="Media file not found")
        
        # TODO: Check user permissions
        
        # Update priority
        await conn.execute("""
            UPDATE media_files 
            SET display_priority = $1,
                updated_at = NOW()
            WHERE id = $2
        """, request.priority, media_id)
        
        return MediaResponse(
            success=True,
            message="Media priority updated",
            media_id=media_id,
            is_primary=False  # Priority change doesn't affect primary status
        )
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to update priority: {str(e)}")
    finally:
        await conn.close()

@router.get("/sighting/{sighting_id}/media")
async def get_sighting_media(
    sighting_id: str,
    order_by: str = "priority"  # "priority", "upload_order", "created_at"
):
    """Get all media for a sighting in specified order"""
    
    # Determine ORDER BY clause
    order_clauses = {
        "priority": "display_priority DESC, upload_order ASC",
        "upload_order": "upload_order ASC, created_at ASC", 
        "created_at": "created_at ASC, upload_order ASC"
    }
    
    if order_by not in order_clauses:
        raise HTTPException(status_code=400, detail="Invalid order_by parameter")
    
    conn = await get_db_connection()
    try:
        media_files = await conn.fetch(f"""
            SELECT id, type, filename, url, thumbnail_url, size_bytes,
                   duration_seconds, width, height, created_at,
                   is_primary, uploaded_by_user_id, upload_order, 
                   display_priority, contributed_at
            FROM media_files 
            WHERE sighting_id = $1
            ORDER BY {order_clauses[order_by]}
        """, sighting_id)
        
        return {
            "success": True,
            "sighting_id": sighting_id,
            "media_files": [dict(media) for media in media_files],
            "total_count": len(media_files),
            "primary_count": len([m for m in media_files if m['is_primary']])
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get media: {str(e)}")
    finally:
        await conn.close()

@router.get("/sighting/{sighting_id}/primary")
async def get_primary_media(sighting_id: str):
    """Get the primary media file for a sighting"""
    
    conn = await get_db_connection()
    try:
        primary_media = await conn.fetchrow("""
            SELECT id, type, filename, url, thumbnail_url, size_bytes,
                   duration_seconds, width, height, created_at,
                   is_primary, uploaded_by_user_id, upload_order, 
                   display_priority, contributed_at
            FROM media_files 
            WHERE sighting_id = $1 AND is_primary = TRUE
        """, sighting_id)
        
        if not primary_media:
            # Fallback to first media file if no primary set
            primary_media = await conn.fetchrow("""
                SELECT id, type, filename, url, thumbnail_url, size_bytes,
                       duration_seconds, width, height, created_at,
                       is_primary, uploaded_by_user_id, upload_order, 
                       display_priority, contributed_at
                FROM media_files 
                WHERE sighting_id = $1
                ORDER BY upload_order ASC, created_at ASC
                LIMIT 1
            """, sighting_id)
        
        if not primary_media:
            raise HTTPException(status_code=404, detail="No media found for sighting")
        
        return {
            "success": True,
            "sighting_id": sighting_id,
            "primary_media": dict(primary_media)
        }
        
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to get primary media: {str(e)}")
    finally:
        await conn.close()