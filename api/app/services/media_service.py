"""
Media Service - Clean separation of media upload and photo analysis
"""
import asyncio
import json
import os
import shutil
import uuid
from datetime import datetime
from pathlib import Path
from typing import Dict, Any, Optional

from .photo_analysis_service import get_photo_analysis_service

class MediaService:
    """Service for handling media uploads and triggering analysis"""
    
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    async def upload_and_process_photo(
        self, 
        file, 
        sighting_id: str,
        media_dir: Path = Path("/home/ufobeep/ufobeep/media")
    ) -> Dict[str, Any]:
        """
        Upload photo and trigger async analysis
        
        Returns upload result immediately, analysis runs in background
        """
        # 1. Upload the file
        upload_result = await self._upload_file(file, sighting_id, media_dir)
        
        # 2. Get sighting data for analysis
        sighting_data = await self._get_sighting_data(sighting_id)
        
        # 3. Trigger async analysis (fire and forget)
        if sighting_data and sighting_data.get("sensor_data"):
            asyncio.create_task(self._trigger_photo_analysis(
                sighting_id=sighting_id,
                filename=upload_result["filename"],
                file_path=str(upload_result["file_path"]),
                sensor_data=sighting_data["sensor_data"]
            ))
        
        # 4. Return upload result immediately
        return {
            "success": True,
            "data": {
                "media_id": upload_result["media_id"],
                "url": upload_result["url"],
                "filename": upload_result["filename"],
                "size": upload_result["size"]
            },
            "message": "Media uploaded successfully",
            "timestamp": datetime.now().isoformat()
        }
    
    async def _upload_file(self, file, sighting_id: str, media_dir: Path) -> Dict[str, Any]:
        """Handle the actual file upload"""
        # Use original filename from mobile app
        original_filename = file.filename or f"UFOBeep_{int(datetime.now().timestamp() * 1000)}.jpg"
        
        # Create sighting directory
        sighting_dir = media_dir / sighting_id
        sighting_dir.mkdir(parents=True, exist_ok=True)
        
        # Save file
        file_path = sighting_dir / original_filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        file_size = os.path.getsize(file_path)
        
        # Create media record
        base_url = "https://api.ufobeep.com"
        media_info = {
            "id": str(uuid.uuid4()),
            "type": "image",
            "url": f"{base_url}/media/{sighting_id}/{original_filename}",
            "thumbnail_url": f"{base_url}/media/{sighting_id}/{original_filename}",
            "filename": original_filename,
            "size": file_size,
            "content_type": file.content_type,
            "uploaded_at": datetime.now().isoformat()
        }
        
        # Update sighting with media info
        await self._update_sighting_media(sighting_id, media_info)
        
        return {
            "media_id": media_info["id"],
            "url": media_info["url"], 
            "filename": original_filename,
            "size": file_size,
            "file_path": file_path
        }
    
    async def _get_sighting_data(self, sighting_id: str) -> Optional[Dict[str, Any]]:
        """Get sighting data for analysis"""
        async with self.db_pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT sensor_data, created_at FROM sightings WHERE id = $1",
                uuid.UUID(sighting_id)
            )
            
            if row:
                return {
                    "sensor_data": row["sensor_data"],
                    "created_at": row["created_at"]
                }
            return None
    
    async def _update_sighting_media(self, sighting_id: str, media_info: Dict[str, Any]):
        """Update sighting with media information"""
        async with self.db_pool.acquire() as conn:
            # Get existing media
            existing_media = await conn.fetchval(
                "SELECT media_info FROM sightings WHERE id = $1",
                uuid.UUID(sighting_id)
            )
            
            if existing_media:
                if isinstance(existing_media, str):
                    media_data = json.loads(existing_media)
                else:
                    media_data = existing_media
                if "files" not in media_data:
                    media_data["files"] = []
                media_data["files"].append(media_info)
            else:
                media_data = {
                    "files": [media_info],
                    "file_count": 1
                }
            
            await conn.execute(
                "UPDATE sightings SET media_info = $1 WHERE id = $2",
                json.dumps(media_data),
                uuid.UUID(sighting_id)
            )
    
    async def _trigger_photo_analysis(
        self, 
        sighting_id: str, 
        filename: str, 
        file_path: str, 
        sensor_data: Dict[str, Any]
    ):
        """Trigger async photo analysis"""
        try:
            # Parse sensor data
            if isinstance(sensor_data, str):
                sensor_data = json.loads(sensor_data)
            
            latitude = sensor_data.get("latitude")
            longitude = sensor_data.get("longitude")
            
            if latitude is None or longitude is None:
                print(f"No GPS coordinates for analysis: {sighting_id}")
                return
            
            # Get analysis service and run analysis
            analysis_service = get_photo_analysis_service(self.db_pool)
            await analysis_service.analyze_photo_async(
                sighting_id=sighting_id,
                filename=filename, 
                file_path=file_path,
                latitude=float(latitude),
                longitude=float(longitude),
                elevation_m=sensor_data.get("altitude", 0.0)
            )
            
        except Exception as e:
            print(f"Error triggering photo analysis for {sighting_id}: {e}")

# Global service instance
media_service = None

def get_media_service(db_pool):
    """Get or create media service instance"""
    global media_service
    if media_service is None:
        media_service = MediaService(db_pool)
    return media_service