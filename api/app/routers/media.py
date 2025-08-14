from datetime import datetime
from typing import List, Optional
import logging
import uuid

from fastapi import APIRouter, Depends, HTTPException, status, BackgroundTasks
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session

from ..config.environment import settings
from ..schemas.media import (
    PresignedUploadRequest,
    PresignedUploadResponse,
    MediaUploadCompleteRequest,
    MediaFile,
    BulkUploadRequest,
    BulkUploadResponse,
    UploadError
)
from ..services.filesystem_storage import filesystem_storage


logger = logging.getLogger(__name__)

# Router configuration
router = APIRouter(
    prefix="/media",
    tags=["media"],
    responses={
        404: {"description": "Media not found"},
        400: {"description": "Bad request"},
        413: {"description": "File too large"},
        429: {"description": "Too many requests"},
    }
)

security = HTTPBearer(auto_error=False)

# In-memory upload tracking (replace with Redis in production)
upload_registry = {}


# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    # TODO: Implement actual JWT validation
    # For now, return None (anonymous uploads allowed)
    if token and token.credentials:
        # Placeholder - would validate JWT and extract user_id
        return "anonymous_user"
    return None


def validate_file_quota(user_id: Optional[str], file_size: int) -> bool:
    """Validate user hasn't exceeded upload quotas"""
    # TODO: Implement actual quota checking
    # For now, just check against global max size
    return file_size <= settings.max_upload_size


# Endpoints
@router.post("/presign", response_model=PresignedUploadResponse)
async def create_presigned_upload(
    request: PresignedUploadRequest,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Generate presigned upload URL for direct client upload to S3/MinIO
    
    This endpoint allows clients to upload files directly to storage without
    going through the API server, reducing server load and improving performance.
    """
    try:
        # Validate file size against limits
        if not validate_file_quota(user_id, request.size_bytes):
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail={
                    "error": "FILE_TOO_LARGE",
                    "message": f"File size {request.size_bytes} bytes exceeds limit of {settings.max_upload_size} bytes",
                    "max_size_bytes": settings.max_upload_size
                }
            )
        
        # Generate presigned upload
        response = await filesystem_storage.generate_presigned_upload(
            request=request,
            user_id=user_id,
            expires_in=3600  # 1 hour
        )
        
        # Track upload in registry for completion verification
        upload_registry[response.upload_id] = {
            "user_id": user_id,
            "filename": request.filename,
            "content_type": request.content_type,
            "size_bytes": request.size_bytes,
            "checksum": request.checksum,
            "media_type": request.get_media_type(),
            "created_at": datetime.utcnow(),
            "expires_at": response.expires_at,
            "status": "pending"
        }
        
        logger.info(f"Generated presigned upload: {response.upload_id} for user: {user_id}")
        
        return response
        
    except Exception as e:
        logger.error(f"Unexpected error during presign: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "INTERNAL_ERROR", 
                "message": "Failed to generate upload URL"
            }
        )


@router.post("/complete", response_model=MediaFile)
async def complete_media_upload(
    request: MediaUploadCompleteRequest,
    background_tasks: BackgroundTasks,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Mark upload as complete and create media file record
    
    This endpoint should be called after successful direct upload to storage
    to verify the upload and create a media file record in the database.
    """
    try:
        # Check if upload exists in registry
        upload_info = upload_registry.get(request.upload_id)
        if not upload_info:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "UPLOAD_NOT_FOUND",
                    "message": f"Upload ID {request.upload_id} not found"
                }
            )
        
        # Verify user authorization (if upload was created by authenticated user)
        if upload_info.get("user_id") != user_id:
            if upload_info.get("user_id") is not None or user_id is not None:
                raise HTTPException(
                    status_code=status.HTTP_403_FORBIDDEN,
                    detail={
                        "error": "ACCESS_DENIED",
                        "message": "Not authorized to complete this upload"
                    }
                )
        
        # Verify upload completion in storage
        is_complete, object_info = await filesystem_storage.verify_upload_completion(
            upload_id=request.upload_id,
            expected_size=upload_info.get("size_bytes")
        )
        
        if not is_complete:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail={
                    "error": "UPLOAD_NOT_COMPLETE",
                    "message": "Upload not found in storage or verification failed"
                }
            )
        
        # Generate public URL for the uploaded file
        public_url = await filesystem_storage.generate_public_url(
            object_key=object_info["key"],
            expires_in=604800  # 1 week (MaxIO maximum)
        )
        
        # Create media file record
        media_file = MediaFile(
            id=f"media_{request.upload_id}",
            upload_id=request.upload_id,
            type=request.media_type,
            filename=object_info["key"].split("/")[-1],
            original_filename=upload_info["filename"],
            url=public_url,
            size_bytes=object_info["size"],
            content_type=object_info.get("content_type", upload_info["content_type"]),
            checksum=object_info.get("metadata", {}).get("checksum"),
            file_metadata=request.metadata or {},
            uploaded_by=user_id,
            uploaded_at=object_info["last_modified"],
            created_at=datetime.utcnow(),
            updated_at=datetime.utcnow()
        )
        
        # Media file record will be saved when used in sighting creation
        
        # Update registry
        upload_info.update({
            "status": "completed",
            "completed_at": datetime.utcnow(),
            "media_file": media_file.dict()
        })
        
        # Schedule cleanup of expired uploads in background
        background_tasks.add_task(cleanup_expired_uploads)
        
        logger.info(f"Upload completed successfully: {request.upload_id}")
        
        return media_file
        
    except HTTPException:
        # Re-raise HTTP exceptions
        raise
    except Exception as e:
        logger.error(f"Unexpected error completing upload {request.upload_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "INTERNAL_ERROR",
                "message": "Failed to complete upload"
            }
        )


@router.post("/bulk-presign", response_model=BulkUploadResponse)
async def create_bulk_presigned_uploads(
    request: BulkUploadRequest,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Generate multiple presigned upload URLs for bulk upload
    
    Useful for uploading multiple media files for a single sighting.
    """
    try:
        # Calculate total size
        total_size = sum(file_req.size_bytes for file_req in request.files)
        
        # Validate total quota
        if not validate_file_quota(user_id, total_size):
            raise HTTPException(
                status_code=status.HTTP_413_REQUEST_ENTITY_TOO_LARGE,
                detail={
                    "error": "BULK_QUOTA_EXCEEDED",
                    "message": f"Total size {total_size} bytes exceeds limits",
                    "total_size_bytes": total_size,
                    "max_size_bytes": settings.max_upload_size
                }
            )
        
        # Generate presigned uploads for each file
        uploads = []
        batch_id = f"batch_{datetime.utcnow().strftime('%Y%m%d_%H%M%S')}_{len(request.files)}"
        
        for file_request in request.files:
            response = await filesystem_storage.generate_presigned_upload(
                request=file_request,
                user_id=user_id,
                expires_in=3600
            )
            uploads.append(response)
            
            # Track in registry with batch info
            upload_registry[response.upload_id] = {
                "user_id": user_id,
                "filename": file_request.filename,
                "content_type": file_request.content_type,
                "size_bytes": file_request.size_bytes,
                "checksum": file_request.checksum,
                "media_type": file_request.get_media_type(),
                "batch_id": batch_id,
                "sighting_id": request.sighting_id,
                "created_at": datetime.utcnow(),
                "expires_at": response.expires_at,
                "status": "pending"
            }
        
        # Create bulk response
        bulk_response = BulkUploadResponse(
            uploads=uploads,
            batch_id=batch_id,
            expires_at=uploads[0].expires_at if uploads else datetime.utcnow(),
            total_max_size=total_size
        )
        
        logger.info(f"Generated bulk presigned uploads: {batch_id} with {len(uploads)} files")
        
        return bulk_response
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to create bulk presigned uploads: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "BULK_UPLOAD_ERROR",
                "message": "Failed to generate bulk upload URLs"
            }
        )


@router.get("/uploads/{upload_id}/status")
async def get_upload_status(
    upload_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Check the status of an upload
    
    Returns upload progress and completion status.
    """
    upload_info = upload_registry.get(upload_id)
    if not upload_info:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "error": "UPLOAD_NOT_FOUND",
                "message": f"Upload ID {upload_id} not found"
            }
        )
    
    # Check authorization
    if upload_info.get("user_id") != user_id:
        if upload_info.get("user_id") is not None or user_id is not None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "ACCESS_DENIED",
                    "message": "Not authorized to view this upload"
                }
            )
    
    # Check if upload exists in storage
    if upload_info["status"] == "pending":
        is_complete, object_info = await filesystem_storage.verify_upload_completion(upload_id)
        if is_complete:
            upload_info["status"] = "completed"
            upload_info["completed_at"] = datetime.utcnow()
    
    return {
        "upload_id": upload_id,
        "status": upload_info["status"],
        "filename": upload_info["filename"],
        "size_bytes": upload_info["size_bytes"],
        "media_type": upload_info["media_type"].value,
        "created_at": upload_info["created_at"].isoformat(),
        "expires_at": upload_info["expires_at"].isoformat(),
        "completed_at": upload_info.get("completed_at", {}).isoformat() if upload_info.get("completed_at") else None
    }


@router.delete("/uploads/{upload_id}")
async def cancel_upload(
    upload_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Cancel a pending upload and clean up resources
    """
    upload_info = upload_registry.get(upload_id)
    if not upload_info:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail={
                "error": "UPLOAD_NOT_FOUND",
                "message": f"Upload ID {upload_id} not found"
            }
        )
    
    # Check authorization
    if upload_info.get("user_id") != user_id:
        if upload_info.get("user_id") is not None or user_id is not None:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail={
                    "error": "ACCESS_DENIED",
                    "message": "Not authorized to cancel this upload"
                }
            )
    
    # Mark as cancelled
    upload_info["status"] = "cancelled"
    upload_info["cancelled_at"] = datetime.utcnow()
    
    logger.info(f"Upload cancelled: {upload_id}")
    
    return {
        "upload_id": upload_id,
        "status": "cancelled",
        "message": "Upload cancelled successfully"
    }


# Background tasks
async def cleanup_expired_uploads():
    """Clean up expired uploads from registry and storage"""
    try:
        current_time = datetime.utcnow()
        expired_uploads = []
        
        for upload_id, upload_info in upload_registry.items():
            if (upload_info["status"] == "pending" and 
                current_time > upload_info["expires_at"]):
                expired_uploads.append(upload_id)
        
        # Remove from registry
        for upload_id in expired_uploads:
            del upload_registry[upload_id]
        
        # Clean up storage
        if expired_uploads:
            deleted_count = await filesystem_storage.cleanup_expired_uploads(
                older_than_hours=1
            )
            logger.info(f"Cleaned up {deleted_count} expired uploads from storage")
            
    except Exception as e:
        logger.error(f"Error during upload cleanup: {e}")


# Health check endpoint
@router.get("/health")
async def media_health_check():
    """Check media service health"""
    try:
        # Test storage connection
        # This is a simple test - in production you might want more comprehensive checks
        await filesystem_storage.get_object_metadata("nonexistent-test-key")
        
        return {
            "status": "healthy",
            "storage": "connected",
            "pending_uploads": len([u for u in upload_registry.values() if u["status"] == "pending"]),
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        return {
            "status": "degraded",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }