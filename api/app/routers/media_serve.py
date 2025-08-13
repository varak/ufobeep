from datetime import datetime
import logging

from fastapi import APIRouter, HTTPException, status
from fastapi.responses import RedirectResponse

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
    filename: str
):
    """
    Serve media files directly using permanent URLs
    
    This endpoint provides direct access to media files organized by sighting ID.
    Returns a redirect to the storage URL for efficient delivery.
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
        # Use a shorter expiry since this is for immediate access
        public_url = await storage_service.generate_public_url(
            object_key=object_key,
            expires_in=3600  # 1 hour
        )
        
        # Redirect to the storage URL for efficient delivery
        return RedirectResponse(url=public_url, status_code=302)
        
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