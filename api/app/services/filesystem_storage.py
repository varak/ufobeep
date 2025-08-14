import os
import shutil
import logging
from pathlib import Path
from typing import Dict, Optional, Tuple, Any
from datetime import datetime, timedelta

from ..schemas.media import (
    PresignedUploadRequest,
    PresignedUploadResponse,
    MediaFile,
    UploadStatus,
    generate_upload_id,
    sanitize_filename
)

logger = logging.getLogger(__name__)

# Storage root directory
STORAGE_ROOT = Path("/home/ufobeep/ufobeep/media")

class FilesystemStorageService:
    """Filesystem-based storage service for media uploads"""
    
    def __init__(self):
        # Ensure storage root exists
        STORAGE_ROOT.mkdir(parents=True, exist_ok=True)
    
    async def create_presigned_upload(
        self,
        request: PresignedUploadRequest,
        user_id: Optional[str] = None,
        expires_in: int = 3600
    ) -> PresignedUploadResponse:
        """
        Create a presigned upload - for filesystem, we just return upload info
        The actual upload will be handled by the /complete endpoint
        """
        upload_id = generate_upload_id()
        sanitized_filename = sanitize_filename(request.filename)
        
        # Create directory for this sighting
        sighting_dir = STORAGE_ROOT / request.sighting_id
        sighting_dir.mkdir(parents=True, exist_ok=True)
        
        # Return upload response pointing to our direct upload endpoint
        return PresignedUploadResponse(
            upload_id=upload_id,
            upload_url="https://api.ufobeep.com/media/upload",  # Direct upload endpoint
            expires_at=datetime.utcnow(),  # Not used for filesystem
            max_file_size=50 * 1024 * 1024,  # 50MB
            fields={
                "sighting_id": request.sighting_id,
                "filename": sanitized_filename
            }
        )
    
    async def verify_upload_completion(
        self,
        upload_id: str,
        expected_size: Optional[int] = None
    ) -> Tuple[bool, Optional[Dict[str, Any]]]:
        """
        Verify upload completion - for filesystem, check if file exists
        """
        # For filesystem uploads, we'll check after the file is actually saved
        # This is called after complete_upload, so return success
        return True, {"upload_id": upload_id, "verified": True}
    
    async def get_object_metadata(self, object_key: str) -> Optional[Dict[str, Any]]:
        """Get metadata for an object (file path relative to storage root)"""
        file_path = STORAGE_ROOT / object_key
        if not file_path.exists():
            return None
        
        stat = file_path.stat()
        return {
            "content_type": self._get_content_type(file_path),
            "size": stat.st_size,
            "last_modified": datetime.fromtimestamp(stat.st_mtime),
        }
    
    async def generate_public_url(
        self,
        object_key: str,
        expires_in: int = 3600
    ) -> str:
        """Generate public URL - for filesystem, return API endpoint URL"""
        # Parse object_key like "sightings/{sighting_id}/{filename}"
        parts = object_key.split('/')
        if len(parts) >= 3 and parts[0] == 'sightings':
            sighting_id = parts[1]
            filename = parts[2]
            return f"https://api.ufobeep.com/media/{sighting_id}/{filename}"
        return f"https://api.ufobeep.com/media/{object_key}"
    
    def _get_content_type(self, file_path: Path) -> str:
        """Determine content type from file extension"""
        suffix = file_path.suffix.lower()
        content_types = {
            '.jpg': 'image/jpeg',
            '.jpeg': 'image/jpeg', 
            '.png': 'image/png',
            '.gif': 'image/gif',
            '.mp4': 'video/mp4',
            '.mov': 'video/quicktime',
        }
        return content_types.get(suffix, 'application/octet-stream')
    
    async def save_uploaded_file(
        self,
        sighting_id: str,
        filename: str,
        file_content: bytes
    ) -> str:
        """Save uploaded file content to filesystem"""
        sanitized_filename = sanitize_filename(filename)
        sighting_dir = STORAGE_ROOT / sighting_id
        sighting_dir.mkdir(parents=True, exist_ok=True)
        
        file_path = sighting_dir / sanitized_filename
        
        # Write file content
        with open(file_path, 'wb') as f:
            f.write(file_content)
        
        logger.info(f"Saved file: {file_path} ({len(file_content)} bytes)")
        return str(file_path)
    
    async def cleanup_expired_uploads(self, older_than_hours: int = 24) -> int:
        """Clean up expired uploads from filesystem"""
        try:
            cutoff_time = datetime.utcnow() - timedelta(hours=older_than_hours)
            deleted_count = 0
            
            # Look for empty sighting directories older than cutoff
            for sighting_dir in STORAGE_ROOT.iterdir():
                if sighting_dir.is_dir():
                    try:
                        # Check if directory is empty and old
                        if not any(sighting_dir.iterdir()):
                            stat = sighting_dir.stat()
                            if datetime.fromtimestamp(stat.st_mtime) < cutoff_time:
                                sighting_dir.rmdir()
                                deleted_count += 1
                    except (OSError, StopIteration):
                        continue
            
            if deleted_count > 0:
                logger.info(f"Cleaned up {deleted_count} empty directories")
            
            return deleted_count
            
        except Exception as e:
            logger.error(f"Failed to cleanup expired uploads: {e}")
            return 0

# Create singleton instance
filesystem_storage = FilesystemStorageService()