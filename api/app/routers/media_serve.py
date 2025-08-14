import os
import logging
from pathlib import Path
from io import BytesIO

from fastapi import APIRouter, HTTPException, status, Query
from fastapi.responses import FileResponse, StreamingResponse
from PIL import Image

logger = logging.getLogger(__name__)

# Router for direct media serving
router = APIRouter(
    prefix="/media",
    tags=["media-serve"],
    responses={
        404: {"description": "Media not found"},
        500: {"description": "Media access error"},
    }
)

# Media storage directory
MEDIA_ROOT = Path("/home/ufobeep/ufobeep/media")

@router.get("/{sighting_id}/")
async def list_sighting_media(sighting_id: str):
    """
    List all media files for a specific sighting
    
    Returns JSON list of all media files available for the sighting ID.
    """
    try:
        # Construct the sighting directory path
        sighting_dir = MEDIA_ROOT / sighting_id
        
        # Check if the directory exists
        if not sighting_dir.exists() or not sighting_dir.is_dir():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "SIGHTING_NOT_FOUND",
                    "message": f"No media found for sighting: {sighting_id}"
                }
            )
        
        # List all files in the directory
        media_files = []
        for file_path in sighting_dir.iterdir():
            if file_path.is_file():
                # Get file stats
                stat = file_path.stat()
                
                media_files.append({
                    "filename": file_path.name,
                    "url": f"https://api.ufobeep.com/media/{sighting_id}/{file_path.name}",
                    "thumbnail_url": f"https://api.ufobeep.com/media/{sighting_id}/{file_path.name}?thumbnail=true",
                    "size_bytes": stat.st_size,
                    "modified_at": stat.st_mtime,
                    "is_image": file_path.suffix.lower() in ('.jpg', '.jpeg', '.png', '.gif', '.bmp'),
                    "is_video": file_path.suffix.lower() in ('.mp4', '.mov', '.avi', '.mkv')
                })
        
        return {
            "success": True,
            "sighting_id": sighting_id,
            "media_count": len(media_files),
            "media_files": sorted(media_files, key=lambda x: x["filename"])
        }
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"Error listing media for sighting {sighting_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "MEDIA_LIST_ERROR",
                "message": "Failed to list media files"
            }
        )

@router.get("/{sighting_id}/{filename}")
@router.head("/{sighting_id}/{filename}")
async def serve_media_file(
    sighting_id: str,
    filename: str,
    thumbnail: bool = Query(False, description="Return web-optimized thumbnail"),
    width: int = Query(800, description="Thumbnail width"),
    height: int = Query(600, description="Thumbnail height")
):
    """
    Serve media files directly from local filesystem with optional thumbnail generation
    
    This endpoint provides direct access to media files organized by sighting ID.
    Files are stored at: /home/ufobeep/ufobeep/media/{sighting_id}/{filename}
    """
    try:
        # Construct the file path
        file_path = MEDIA_ROOT / sighting_id / filename
        
        # Check if the file exists
        if not file_path.exists() or not file_path.is_file():
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "FILE_NOT_FOUND",
                    "message": f"Media file not found: {filename}"
                }
            )
        
        # If thumbnail is requested and it's an image, generate thumbnail
        if thumbnail and filename.lower().endswith(('.jpg', '.jpeg', '.png', '.gif', '.bmp')):
            try:
                # Open image with PIL
                with open(file_path, 'rb') as f:
                    image = Image.open(f)
                    image.load()  # Ensure image is fully loaded
                
                # Fix image orientation based on EXIF data only
                try:
                    if hasattr(image, 'getexif'):
                        exif = image.getexif()
                        if exif:
                            orientation = exif.get(274)  # 274 is ORIENTATION tag
                            if orientation:
                                logger.info(f"EXIF orientation found: {orientation}")
                                # Use transpose methods for correct EXIF rotation
                                if orientation == 2:
                                    image = image.transpose(Image.FLIP_LEFT_RIGHT)
                                elif orientation == 3:
                                    image = image.transpose(Image.ROTATE_180)
                                elif orientation == 4:
                                    image = image.transpose(Image.FLIP_TOP_BOTTOM)
                                elif orientation == 5:
                                    image = image.transpose(Image.FLIP_LEFT_RIGHT)
                                    image = image.transpose(Image.ROTATE_90)
                                elif orientation == 6:
                                    # RightTop - rotate 90 CW
                                    image = image.transpose(Image.ROTATE_270)
                                elif orientation == 7:
                                    image = image.transpose(Image.FLIP_LEFT_RIGHT)
                                    image = image.transpose(Image.ROTATE_270)
                                elif orientation == 8:
                                    # LeftBottom - rotate 90 CCW
                                    image = image.transpose(Image.ROTATE_90)
                except Exception as e:
                    logger.debug(f"EXIF processing failed for {filename}: {e}")
                
                # Convert RGBA to RGB for JPEG compatibility
                if image.mode == 'RGBA':
                    background = Image.new('RGB', image.size, (255, 255, 255))
                    background.paste(image, mask=image.split()[-1])
                    image = background
                
                # Calculate aspect ratio preserving thumbnail size
                image.thumbnail((width, height), Image.Resampling.LANCZOS)
                
                # Save as JPEG for web optimization
                thumbnail_io = BytesIO()
                image.save(thumbnail_io, format='JPEG', quality=85, optimize=True)
                thumbnail_content = thumbnail_io.getvalue()
                
                return StreamingResponse(
                    BytesIO(thumbnail_content),
                    media_type="image/jpeg",
                    headers={
                        "Cache-Control": "public, max-age=3600",
                        "Content-Length": str(len(thumbnail_content))
                    }
                )
                
            except Exception as e:
                logger.warning(f"Failed to generate thumbnail for {filename}: {e}")
                # Fall back to original image
                pass
        
        # Return original file directly
        return FileResponse(
            file_path,
            headers={
                "Cache-Control": "public, max-age=3600"
            }
        )
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"Error serving media file {sighting_id}/{filename}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "MEDIA_ACCESS_ERROR",
                "message": "Failed to access media file"
            }
        )