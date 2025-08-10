import pytest
from datetime import datetime, timedelta
from fastapi.testclient import TestClient
from unittest.mock import AsyncMock, patch, MagicMock

from main import app
from schemas.media import (
    PresignedUploadRequest,
    MediaUploadCompleteRequest,
    MediaType
)


client = TestClient(app)


class TestMediaUpload:
    """Test media upload endpoints"""
    
    def setup_method(self):
        """Setup test data"""
        self.sample_upload_request = {
            "filename": "test_image.jpg",
            "content_type": "image/jpeg",
            "size_bytes": 1024000,  # 1MB
            "checksum": "abcd1234efgh5678"
        }
        
        self.sample_upload_id = "upload_1234567890_abcdef123456"
        
        self.mock_presigned_response = {
            "upload_id": self.sample_upload_id,
            "upload_url": "https://s3.example.com/bucket/uploads/2024/01/upload_123/test_image.jpg",
            "fields": {
                "key": "uploads/2024/01/upload_123/test_image.jpg",
                "Content-Type": "image/jpeg",
                "x-amz-meta-upload-id": self.sample_upload_id
            },
            "expires_at": (datetime.utcnow() + timedelta(hours=1)).isoformat(),
            "max_file_size": 1024000
        }
    
    @patch('routers.media.storage_service')
    def test_create_presigned_upload_success(self, mock_storage_service):
        """Test successful presigned upload creation"""
        
        # Mock storage service response
        mock_storage_service.generate_presigned_upload = AsyncMock(
            return_value=type('obj', (object,), self.mock_presigned_response)()
        )
        
        response = client.post("/v1/media/presign", json=self.sample_upload_request)
        
        assert response.status_code == 200
        data = response.json()
        
        assert "upload_id" in data
        assert "upload_url" in data
        assert "fields" in data
        assert "expires_at" in data
        assert data["max_file_size"] == 1024000
        
        # Verify storage service was called
        mock_storage_service.generate_presigned_upload.assert_called_once()
    
    def test_create_presigned_upload_invalid_file_type(self):
        """Test presigned upload with invalid file type"""
        
        invalid_request = self.sample_upload_request.copy()
        invalid_request["filename"] = "document.pdf"  # Not allowed
        invalid_request["content_type"] = "application/pdf"
        
        response = client.post("/v1/media/presign", json=invalid_request)
        
        assert response.status_code == 422
        data = response.json()
        assert "detail" in data
    
    def test_create_presigned_upload_file_too_large(self):
        """Test presigned upload with file too large"""
        
        large_request = self.sample_upload_request.copy()
        large_request["size_bytes"] = 100 * 1024 * 1024  # 100MB (too large)
        
        response = client.post("/v1/media/presign", json=large_request)
        
        assert response.status_code == 413
        data = response.json()
        assert data["detail"]["error"] == "FILE_TOO_LARGE"
    
    @patch('routers.media.storage_service')
    @patch('routers.media.upload_registry')
    def test_complete_media_upload_success(self, mock_registry, mock_storage_service):
        """Test successful media upload completion"""
        
        # Setup mock registry
        mock_registry.get.return_value = {
            "user_id": None,
            "filename": "test_image.jpg",
            "content_type": "image/jpeg",
            "size_bytes": 1024000,
            "checksum": "abcd1234",
            "media_type": MediaType.PHOTO,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(hours=1),
            "status": "pending"
        }
        
        # Mock storage verification
        mock_object_info = {
            "key": "uploads/2024/01/upload_123/test_image.jpg",
            "size": 1024000,
            "last_modified": datetime.utcnow(),
            "metadata": {"checksum": "abcd1234"}
        }
        
        mock_storage_service.verify_upload_completion = AsyncMock(
            return_value=(True, mock_object_info)
        )
        mock_storage_service.generate_public_url = AsyncMock(
            return_value="https://cdn.example.com/media/test_image.jpg"
        )
        
        complete_request = {
            "upload_id": self.sample_upload_id,
            "media_type": "photo",
            "metadata": {"description": "Test image"}
        }
        
        response = client.post("/v1/media/complete", json=complete_request)
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["id"] == f"media_{self.sample_upload_id}"
        assert data["type"] == "photo"
        assert data["filename"] == "test_image.jpg"
        assert data["url"] == "https://cdn.example.com/media/test_image.jpg"
        assert data["size_bytes"] == 1024000
        assert data["metadata"]["description"] == "Test image"
    
    @patch('routers.media.upload_registry')
    def test_complete_media_upload_not_found(self, mock_registry):
        """Test completion of non-existent upload"""
        
        mock_registry.get.return_value = None
        
        complete_request = {
            "upload_id": "nonexistent_upload",
            "media_type": "photo"
        }
        
        response = client.post("/v1/media/complete", json=complete_request)
        
        assert response.status_code == 404
        data = response.json()
        assert data["detail"]["error"] == "UPLOAD_NOT_FOUND"
    
    @patch('routers.media.storage_service')
    def test_bulk_presigned_upload_success(self, mock_storage_service):
        """Test successful bulk presigned upload creation"""
        
        # Mock storage responses
        mock_storage_service.generate_presigned_upload = AsyncMock(
            side_effect=[
                type('obj', (object,), {
                    **self.mock_presigned_response,
                    "upload_id": "upload_1_123"
                })(),
                type('obj', (object,), {
                    **self.mock_presigned_response, 
                    "upload_id": "upload_2_456"
                })()
            ]
        )
        
        bulk_request = {
            "files": [
                {
                    "filename": "image1.jpg",
                    "content_type": "image/jpeg", 
                    "size_bytes": 1024000
                },
                {
                    "filename": "video1.mp4",
                    "content_type": "video/mp4",
                    "size_bytes": 5120000
                }
            ],
            "sighting_id": "sighting_123"
        }
        
        response = client.post("/v1/media/bulk-presign", json=bulk_request)
        
        assert response.status_code == 200
        data = response.json()
        
        assert len(data["uploads"]) == 2
        assert "batch_id" in data
        assert data["total_max_size"] == 6144000  # Sum of file sizes
        assert "expires_at" in data
    
    def test_bulk_presigned_upload_quota_exceeded(self):
        """Test bulk upload with total size exceeding quota"""
        
        bulk_request = {
            "files": [
                {
                    "filename": "large1.mp4",
                    "content_type": "video/mp4",
                    "size_bytes": 30 * 1024 * 1024  # 30MB
                },
                {
                    "filename": "large2.mp4", 
                    "content_type": "video/mp4",
                    "size_bytes": 30 * 1024 * 1024  # 30MB - Total 60MB
                }
            ]
        }
        
        response = client.post("/v1/media/bulk-presign", json=bulk_request)
        
        assert response.status_code == 413
        data = response.json()
        assert data["detail"]["error"] == "BULK_QUOTA_EXCEEDED"
    
    @patch('routers.media.upload_registry')
    def test_get_upload_status(self, mock_registry):
        """Test getting upload status"""
        
        mock_registry.get.return_value = {
            "user_id": None,
            "filename": "test.jpg",
            "size_bytes": 1024000,
            "media_type": MediaType.PHOTO,
            "created_at": datetime.utcnow(),
            "expires_at": datetime.utcnow() + timedelta(hours=1),
            "status": "completed"
        }
        
        response = client.get(f"/v1/media/uploads/{self.sample_upload_id}/status")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["upload_id"] == self.sample_upload_id
        assert data["status"] == "completed"
        assert data["filename"] == "test.jpg"
        assert data["size_bytes"] == 1024000
    
    @patch('routers.media.upload_registry')
    def test_cancel_upload(self, mock_registry):
        """Test cancelling an upload"""
        
        mock_upload_info = {
            "user_id": None,
            "status": "pending",
            "filename": "test.jpg"
        }
        mock_registry.get.return_value = mock_upload_info
        
        response = client.delete(f"/v1/media/uploads/{self.sample_upload_id}")
        
        assert response.status_code == 200
        data = response.json()
        
        assert data["upload_id"] == self.sample_upload_id
        assert data["status"] == "cancelled"
        
        # Verify upload was marked as cancelled
        assert mock_upload_info["status"] == "cancelled"
        assert "cancelled_at" in mock_upload_info
    
    def test_media_health_check(self):
        """Test media service health check"""
        
        response = client.get("/v1/media/health")
        
        # Should return 200 even if storage is not actually configured
        assert response.status_code == 200
        data = response.json()
        
        assert "status" in data
        assert "timestamp" in data


class TestMediaSchemas:
    """Test media schema validation"""
    
    def test_presigned_upload_request_validation(self):
        """Test PresignedUploadRequest validation"""
        
        # Valid request
        valid_data = {
            "filename": "test.jpg",
            "content_type": "image/jpeg", 
            "size_bytes": 1024000
        }
        
        request = PresignedUploadRequest(**valid_data)
        assert request.filename == "test.jpg"
        assert request.get_media_type() == MediaType.PHOTO
        
        # Invalid filename extension
        with pytest.raises(ValueError, match="File extension not allowed"):
            PresignedUploadRequest(
                filename="test.exe",
                content_type="application/x-executable",
                size_bytes=1024
            )
        
        # Invalid content type
        with pytest.raises(ValueError, match="Content type not allowed"):
            PresignedUploadRequest(
                filename="test.jpg",
                content_type="application/pdf",
                size_bytes=1024
            )
        
        # File too large
        with pytest.raises(ValueError):
            PresignedUploadRequest(
                filename="test.jpg",
                content_type="image/jpeg",
                size_bytes=100 * 1024 * 1024  # 100MB
            )
    
    def test_media_type_detection(self):
        """Test media type detection from content type"""
        
        photo_request = PresignedUploadRequest(
            filename="photo.jpg",
            content_type="image/jpeg",
            size_bytes=1024
        )
        assert photo_request.get_media_type() == MediaType.PHOTO
        
        video_request = PresignedUploadRequest(
            filename="video.mp4", 
            content_type="video/mp4",
            size_bytes=5120000
        )
        assert video_request.get_media_type() == MediaType.VIDEO
        
        audio_request = PresignedUploadRequest(
            filename="audio.mp3",
            content_type="audio/mpeg", 
            size_bytes=2048000
        )
        assert audio_request.get_media_type() == MediaType.AUDIO
    
    def test_metadata_sanitization(self):
        """Test metadata sanitization in upload completion"""
        
        request_data = {
            "upload_id": "test_123",
            "media_type": MediaType.PHOTO,
            "metadata": {
                "description": "Test image",
                "password": "secret123",  # Should be removed
                "token": "abc123",        # Should be removed
                "camera_model": "iPhone 12",  # Should be kept
                "location": "San Francisco"   # Should be kept
            }
        }
        
        request = MediaUploadCompleteRequest(**request_data)
        
        # Sensitive keys should be removed
        assert "password" not in request.metadata
        assert "token" not in request.metadata
        
        # Safe keys should be kept
        assert request.metadata["description"] == "Test image"
        assert request.metadata["camera_model"] == "iPhone 12"
        assert request.metadata["location"] == "San Francisco"


# Integration test fixtures
@pytest.fixture
def mock_s3_client():
    """Mock S3 client for testing"""
    mock_client = MagicMock()
    
    # Mock successful presigned POST generation
    mock_client.generate_presigned_post.return_value = {
        "url": "https://test-bucket.s3.amazonaws.com/",
        "fields": {
            "key": "uploads/2024/01/test/file.jpg",
            "Content-Type": "image/jpeg"
        }
    }
    
    # Mock successful head_bucket
    mock_client.head_bucket.return_value = True
    
    # Mock list_objects_v2 for verification
    mock_client.list_objects_v2.return_value = {
        "Contents": [
            {
                "Key": "uploads/2024/01/test/file.jpg",
                "Size": 1024000,
                "LastModified": datetime.utcnow()
            }
        ]
    }
    
    # Mock head_object for metadata
    mock_client.head_object.return_value = {
        "ContentLength": 1024000,
        "LastModified": datetime.utcnow(),
        "ContentType": "image/jpeg",
        "Metadata": {
            "upload-id": "test_123",
            "original-filename": "file.jpg"
        }
    }
    
    return mock_client


@pytest.fixture  
def mock_storage_service(mock_s3_client):
    """Mock storage service with mocked S3 client"""
    with patch('services.storage_service.boto3.client', return_value=mock_s3_client):
        from services.storage_service import StorageService
        return StorageService()