"""
Media attachment management for sightings
Allows adding photos/videos to existing sightings
"""
from fastapi import APIRouter, HTTPException, UploadFile, File, Form
from typing import List, Optional
import asyncpg
import json
import uuid
from datetime import datetime
from pathlib import Path
import shutil

router = APIRouter(prefix="/sightings", tags=["sighting-media"])

@router.post("/{sighting_id}/media")
async def add_media_to_sighting(
    sighting_id: str,
    files: List[UploadFile] = File(...),
    source: str = Form("user_upload"),
    description: Optional[str] = Form(None)
):
    """Add media files to an existing sighting"""
    
    # Get database connection
    db_pool = await asyncpg.create_pool(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db",
        min_size=1,
        max_size=5
    )
    
    try:
        async with db_pool.acquire() as conn:
            # Check if sighting exists
            sighting = await conn.fetchrow("""
                SELECT id, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Sighting not found")
            
            # Get existing media info
            existing_media = json.loads(sighting['media_info']) if sighting['media_info'] else {'files': []}
            
            # Save uploaded files
            media_root = Path("/home/ufobeep/ufobeep/media")
            sighting_media_dir = media_root / sighting_id
            sighting_media_dir.mkdir(parents=True, exist_ok=True)
            
            new_media_files = []
            
            for file in files:
                # Generate unique filename
                file_ext = Path(file.filename).suffix
                unique_filename = f"{uuid.uuid4()}{file_ext}"
                file_path = sighting_media_dir / unique_filename
                
                # Save file
                with file_path.open("wb") as buffer:
                    shutil.copyfileobj(file.file, buffer)
                
                # Add to media list
                new_media_files.append({
                    'id': str(uuid.uuid4()),
                    'type': 'video' if file_ext.lower() in ['.mp4', '.mov', '.avi'] else 'image',
                    'filename': unique_filename,
                    'original_name': file.filename,
                    'url': f'https://api.ufobeep.com/media/{sighting_id}/{unique_filename}',
                    'thumbnail_url': f'https://api.ufobeep.com/media/{sighting_id}/{unique_filename}?thumb=true',
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
            """, json.dumps(existing_media), uuid.UUID(sighting_id))
            
            return {
                "success": True,
                "sighting_id": sighting_id,
                "added_files": len(new_media_files),
                "total_files": existing_media['file_count'],
                "new_media": new_media_files
            }
            
    finally:
        await db_pool.close()

@router.delete("/{sighting_id}/media/{media_id}")
async def remove_media_from_sighting(
    sighting_id: str,
    media_id: str
):
    """Remove a media file from a sighting"""
    
    db_pool = await asyncpg.create_pool(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db",
        min_size=1,
        max_size=5
    )
    
    try:
        async with db_pool.acquire() as conn:
            # Get sighting
            sighting = await conn.fetchrow("""
                SELECT id, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Sighting not found")
            
            # Get media info
            media_info = json.loads(sighting['media_info']) if sighting['media_info'] else {'files': []}
            
            # Find and remove media
            original_count = len(media_info['files'])
            media_info['files'] = [f for f in media_info['files'] if f.get('id') != media_id]
            
            if len(media_info['files']) == original_count:
                raise HTTPException(status_code=404, detail="Media file not found")
            
            media_info['file_count'] = len(media_info['files'])
            
            # Update sighting
            await conn.execute("""
                UPDATE sightings 
                SET media_info = $1,
                    updated_at = NOW()
                WHERE id = $2
            """, json.dumps(media_info), uuid.UUID(sighting_id))
            
            return {
                "success": True,
                "sighting_id": sighting_id,
                "media_id": media_id,
                "remaining_files": media_info['file_count']
            }
            
    finally:
        await db_pool.close()

@router.get("/{sighting_id}/media")
async def get_sighting_media(sighting_id: str):
    """Get all media files for a sighting"""
    
    db_pool = await asyncpg.create_pool(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db",
        min_size=1,
        max_size=5
    )
    
    try:
        async with db_pool.acquire() as conn:
            # Get sighting
            sighting = await conn.fetchrow("""
                SELECT id, title, media_info FROM sightings WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting:
                raise HTTPException(status_code=404, detail="Sighting not found")
            
            media_info = json.loads(sighting['media_info']) if sighting['media_info'] else {'files': []}
            
            return {
                "success": True,
                "sighting_id": sighting_id,
                "sighting_title": sighting['title'],
                "media_count": len(media_info.get('files', [])),
                "media_files": media_info.get('files', [])
            }
            
    finally:
        await db_pool.close()