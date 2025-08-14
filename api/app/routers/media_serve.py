from datetime import datetime
import logging
import httpx
from io import BytesIO

from fastapi import APIRouter, HTTPException, status, Query
from fastapi.responses import RedirectResponse, StreamingResponse
from PIL import Image

from ..services.storage_service import storage_service

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


@router.get("/{sighting_id}/{filename}")
async def serve_media_file(
    sighting_id: str,
    filename: str,
    thumbnail: bool = Query(False, description="Return web-optimized thumbnail"),
    width: int = Query(800, description="Thumbnail width"),
    height: int = Query(600, description="Thumbnail height")
):
    """
    Serve media files directly using permanent URLs with optional thumbnail generation
    
    This endpoint provides direct access to media files organized by sighting ID.
    Proxies content through HTTPS to avoid mixed content issues.
    """
    try:
        # Construct the object key using our sighting-based structure
        object_key = f"sightings/{sighting_id}/{filename}"
        
        # Check if the file exists
        metadata = await storage_service.get_object_metadata(object_key)
        if not metadata:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "FILE_NOT_FOUND",
                    "message": f"Media file not found: {filename}"
                }
            )
        
        # Generate a presigned URL for direct access
        public_url = await storage_service.generate_public_url(
            object_key=object_key,
            expires_in=3600  # 1 hour
        )
        
        # For web browsers, proxy the content to avoid mixed content issues
        # This ensures HTTPS delivery and enables thumbnail generation
        async with httpx.AsyncClient() as client:
            response = await client.get(public_url)
            
            if response.status_code != 200:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={
                        "error": "FILE_ACCESS_ERROR",
                        "message": "Failed to access media file from storage"
                    }
                )
            
            content_type = metadata.get('content_type', 'application/octet-stream')
            original_content = response.content
            
            # If thumbnail is requested and it's an image, generate thumbnail
            if thumbnail and content_type.startswith('image/'):
                try:
                    # Open image with PIL
                    image = Image.open(BytesIO(original_content))
                    
                    # Fix image orientation based on EXIF data
                    try:
                        from PIL import ExifTags
                        from PIL.ExifTags import ORIENTATION
                        if hasattr(image, 'getexif'):
                            exif = image.getexif()
                            if exif is not None:
                                orientation = exif.get(ORIENTATION)
                                if orientation == 3:
                                    image = image.rotate(180, expand=True)
                                elif orientation == 6:
                                    image = image.rotate(270, expand=True)
                                elif orientation == 8:
                                    image = image.rotate(90, expand=True)
                        elif hasattr(image, '_getexif'):
                            # Fallback for older PIL versions
                            exif = image._getexif()
                            if exif is not None:
                                orientation = exif.get(ORIENTATION)
                                if orientation == 3:
                                    image = image.rotate(180, expand=True)
                                elif orientation == 6:
                                    image = image.rotate(270, expand=True)
                                elif orientation == 8:
                                    image = image.rotate(90, expand=True)
                    except Exception as e:
                        # If EXIF processing fails, continue without rotation
                        logger.debug(f"EXIF processing failed for {filename}: {e}")
                        pass
                    
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
            
            # Return original content proxied through HTTPS
            return StreamingResponse(
                BytesIO(original_content),
                media_type=content_type,
                headers={
                    "Cache-Control": "public, max-age=3600",
                    "Content-Length": str(len(original_content))
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