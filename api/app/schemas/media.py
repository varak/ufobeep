from datetime import datetime
from enum import Enum
from typing import Optional, Dict, Any
from pydantic import BaseModel, Field, validator
import hashlib
import mimetypes


class MediaType(str, Enum):
    PHOTO = "photo"
    VIDEO = "video"
    AUDIO = "audio"


class UploadStatus(str, Enum):
    PENDING = "pending"
    UPLOADING = "uploading"
    COMPLETED = "completed"
    FAILED = "failed"


class PresignedUploadRequest(BaseModel):
    """Request to get a presigned upload URL"""
    filename: str = Field(..., min_length=1, max_length=255)
    content_type: str = Field(..., max_length=100)
    size_bytes: int = Field(..., gt=0, le=52428800)  # Max 50MB
    checksum: Optional[str] = Field(None, description="MD5 or SHA256 checksum")
    
    @validator('filename')
    def validate_filename(cls, v):
        """Validate filename has allowed extension"""
        allowed_extensions = {
            # Images
            '.jpg', '.jpeg', '.png', '.gif', '.webp', '.heic', '.heif',
            # Videos 
            '.mp4', '.mov', '.avi', '.mkv', '.webm', '.m4v',
            # Audio
            '.mp3', '.wav', '.aac', '.ogg', '.m4a', '.flac'
        }
        
        # Get file extension
        filename_lower = v.lower()
        has_allowed_ext = any(filename_lower.endswith(ext) for ext in allowed_extensions)
        
        if not has_allowed_ext:
            raise ValueError(f"File extension not allowed. Allowed: {', '.join(allowed_extensions)}")
        
        return v
    
    @validator('content_type')
    def validate_content_type(cls, v):
        """Validate content type matches filename"""
        allowed_types = {
            # Images
            'image/jpeg', 'image/jpg', 'image/png', 'image/gif', 
            'image/webp', 'image/heic', 'image/heif',
            # Videos
            'video/mp4', 'video/quicktime', 'video/x-msvideo', 
            'video/x-matroska', 'video/webm',
            # Audio
            'audio/mpeg', 'audio/wav', 'audio/aac', 
            'audio/ogg', 'audio/x-m4a', 'audio/flac'
        }
        
        if v not in allowed_types:
            raise ValueError(f"Content type not allowed: {v}")
        
        return v
    
    def get_media_type(self) -> MediaType:
        """Determine media type from content type"""
        if self.content_type.startswith('image/'):
            return MediaType.PHOTO
        elif self.content_type.startswith('video/'):
            return MediaType.VIDEO
        elif self.content_type.startswith('audio/'):
            return MediaType.AUDIO
        else:
            # Fallback - should not happen due to validation
            return MediaType.PHOTO


class PresignedUploadResponse(BaseModel):
    """Response containing presigned upload information"""
    upload_id: str
    upload_url: str
    fields: Dict[str, str] = Field(description="Form fields for multipart upload")
    expires_at: datetime
    max_file_size: int
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class MediaUploadCompleteRequest(BaseModel):
    """Request to mark upload as complete"""
    upload_id: str = Field(..., min_length=1, max_length=100)
    media_type: MediaType
    metadata: Optional[Dict[str, Any]] = Field(default_factory=dict)
    
    @validator('metadata')
    def validate_metadata(cls, v):
        """Ensure metadata doesn't contain sensitive information"""
        if v is None:
            return {}
        
        # Remove potentially sensitive fields
        sensitive_keys = {'password', 'token', 'secret', 'key', 'auth'}
        safe_metadata = {}
        
        for key, value in v.items():
            if not any(sensitive_word in key.lower() for sensitive_word in sensitive_keys):
                # Convert to string representation for safety
                if isinstance(value, (str, int, float, bool)):
                    safe_metadata[key] = value
                else:
                    safe_metadata[key] = str(value)
        
        return safe_metadata


class MediaFile(BaseModel):
    """Complete media file record"""
    id: str
    upload_id: str
    type: MediaType
    filename: str
    original_filename: str
    url: str
    thumbnail_url: Optional[str] = None
    size_bytes: int
    content_type: str
    checksum: Optional[str] = None
    
    # Media-specific fields
    duration_seconds: Optional[float] = None  # For video/audio
    width: Optional[int] = None  # For images/video
    height: Optional[int] = None  # For images/video
    format: Optional[str] = None  # File format details
    
    # Metadata and timestamps
    metadata: Dict[str, Any] = Field(default_factory=dict)
    uploaded_by: Optional[str] = None  # User ID
    uploaded_at: datetime
    created_at: datetime
    updated_at: datetime
    
    # Status and processing
    status: UploadStatus = UploadStatus.COMPLETED
    processing_status: Optional[str] = None  # For future processing pipeline
    
    class Config:
        json_encoders = {
            datetime: lambda v: v.isoformat()
        }


class UploadProgressUpdate(BaseModel):
    """Update upload progress (for future WebSocket implementation)"""
    upload_id: str
    bytes_uploaded: int
    total_bytes: int
    status: UploadStatus
    error_message: Optional[str] = None
    
    @property
    def progress_percent(self) -> float:
        """Calculate upload progress percentage"""
        if self.total_bytes <= 0:
            return 0.0
        return min(100.0, (self.bytes_uploaded / self.total_bytes) * 100.0)


class MediaProcessingRequest(BaseModel):
    """Request to process uploaded media (future feature)"""
    media_id: str
    operations: Dict[str, Any] = Field(
        description="Processing operations (resize, transcode, etc.)"
    )
    callback_url: Optional[str] = None


class MediaMetadata(BaseModel):
    """Extracted metadata from media files"""
    # Common metadata
    file_size: int
    content_type: str
    checksum: str
    created_at: datetime
    
    # Image metadata
    width: Optional[int] = None
    height: Optional[int] = None
    color_space: Optional[str] = None
    orientation: Optional[int] = None
    camera_make: Optional[str] = None
    camera_model: Optional[str] = None
    
    # Location metadata (if available and not stripped)
    gps_latitude: Optional[float] = None
    gps_longitude: Optional[float] = None
    gps_altitude: Optional[float] = None
    
    # Video metadata
    duration_seconds: Optional[float] = None
    frame_rate: Optional[float] = None
    video_codec: Optional[str] = None
    audio_codec: Optional[str] = None
    bitrate: Optional[int] = None
    
    # Audio metadata
    sample_rate: Optional[int] = None
    channels: Optional[int] = None
    artist: Optional[str] = None
    title: Optional[str] = None
    album: Optional[str] = None


class BulkUploadRequest(BaseModel):
    """Request for bulk upload presigned URLs"""
    files: list[PresignedUploadRequest] = Field(..., min_items=1, max_items=10)
    sighting_id: Optional[str] = None  # Associate with specific sighting


class BulkUploadResponse(BaseModel):
    """Response for bulk upload request"""
    uploads: list[PresignedUploadResponse]
    batch_id: str
    expires_at: datetime
    total_max_size: int


# Error response models
class UploadError(BaseModel):
    """Upload error details"""
    code: str
    message: str
    details: Optional[Dict[str, Any]] = None
    upload_id: Optional[str] = None


class ValidationError(BaseModel):
    """Validation error details"""
    field: str
    message: str
    rejected_value: Any


# Utility functions for schema validation
def generate_upload_id() -> str:
    """Generate unique upload ID"""
    import uuid
    import time
    
    # Combine timestamp and UUID for uniqueness
    timestamp = int(time.time() * 1000)  # milliseconds
    unique_id = str(uuid.uuid4()).replace('-', '')[:12]
    
    return f"upload_{timestamp}_{unique_id}"


def calculate_checksum(file_content: bytes, algorithm: str = "md5") -> str:
    """Calculate file checksum"""
    if algorithm.lower() == "md5":
        return hashlib.md5(file_content).hexdigest()
    elif algorithm.lower() == "sha256":
        return hashlib.sha256(file_content).hexdigest()
    else:
        raise ValueError(f"Unsupported checksum algorithm: {algorithm}")


def guess_media_type_from_filename(filename: str) -> MediaType:
    """Guess media type from filename extension"""
    content_type, _ = mimetypes.guess_type(filename)
    
    if content_type:
        if content_type.startswith('image/'):
            return MediaType.PHOTO
        elif content_type.startswith('video/'):
            return MediaType.VIDEO  
        elif content_type.startswith('audio/'):
            return MediaType.AUDIO
    
    # Fallback to photo
    return MediaType.PHOTO


def sanitize_filename(filename: str) -> str:
    """Sanitize filename for safe storage"""
    import re
    
    # Remove or replace problematic characters
    filename = re.sub(r'[<>:"/\\|?*]', '_', filename)
    
    # Limit length
    name, ext = filename.rsplit('.', 1) if '.' in filename else (filename, '')
    if len(name) > 200:
        name = name[:200]
    
    return f"{name}.{ext}" if ext else name