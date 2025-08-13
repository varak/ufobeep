import asyncio
import logging
from datetime import datetime, timedelta
from typing import Dict, Optional, Tuple, Any
from uuid import uuid4
import boto3
from botocore.exceptions import ClientError, NoCredentialsError
from botocore.client import Config

from ..config.environment import settings
from ..schemas.media import (
    PresignedUploadRequest,
    PresignedUploadResponse,
    MediaFile,
    UploadStatus,
    generate_upload_id,
    sanitize_filename
)


logger = logging.getLogger(__name__)


class StorageError(Exception):
    """Base storage service exception"""
    pass


class StorageService:
    """S3/MinIO storage service for media uploads"""
    
    def __init__(self):
        self.client = None
        self._initialize_client()
    
    def _initialize_client(self):
        """Initialize S3/MinIO client"""
        try:
            # Configure boto3 client for S3-compatible storage
            self.client = boto3.client(
                's3',
                endpoint_url=settings.s3_endpoint,
                aws_access_key_id=settings.s3_access_key,
                aws_secret_access_key=settings.s3_secret_key,
                region_name=settings.s3_region,
                config=Config(
                    signature_version='s3v4',
                    retries={'max_attempts': 3},
                    max_pool_connections=50
                )
            )
            
            # Test connection
            self.client.head_bucket(Bucket=settings.s3_bucket)
            logger.info(f"Successfully connected to S3 bucket: {settings.s3_bucket}")
            
        except NoCredentialsError:
            logger.error("S3 credentials not found")
            raise StorageError("S3 credentials not configured")
        except ClientError as e:
            error_code = e.response['Error']['Code']
            if error_code == '404':
                logger.error(f"S3 bucket not found: {settings.s3_bucket}")
                raise StorageError(f"S3 bucket '{settings.s3_bucket}' not found")
            else:
                logger.error(f"Failed to connect to S3: {e}")
                raise StorageError(f"S3 connection failed: {e}")
        except Exception as e:
            logger.error(f"Unexpected error initializing storage: {e}")
            raise StorageError(f"Storage initialization failed: {e}")
    
    async def generate_presigned_upload(
        self,
        request: PresignedUploadRequest,
        user_id: Optional[str] = None,
        expires_in: int = 3600  # 1 hour
    ) -> PresignedUploadResponse:
        """Generate presigned upload URL and form fields"""
        
        try:
            # Generate unique upload ID and object key
            upload_id = generate_upload_id()
            sanitized_filename = sanitize_filename(request.filename)
            
            # Create object key with sighting-based structure
            # Structure: sightings/{sighting_id}/{filename}
            object_key = f"sightings/{request.sighting_id}/{sanitized_filename}"
            
            # Prepare conditions for the presigned POST
            conditions = [
                {"bucket": settings.s3_bucket},
                {"key": object_key},
                {"Content-Type": request.content_type},
                ["content-length-range", 1, request.size_bytes],
                ["starts-with", "$x-amz-meta-upload-id", upload_id],
                ["starts-with", "$x-amz-meta-original-filename", request.filename],
                ["starts-with", "$x-amz-meta-media-type", request.get_media_type().value],
            ]
            
            # Add user ID if provided
            if user_id:
                conditions.append(["starts-with", "$x-amz-meta-user-id", user_id])
            
            # Add checksum if provided
            if request.checksum:
                conditions.append(["starts-with", "$x-amz-meta-checksum", request.checksum])
            
            # Fields to include in the form
            fields = {
                "Content-Type": request.content_type,
                "x-amz-meta-upload-id": upload_id,
                "x-amz-meta-original-filename": request.filename,
                "x-amz-meta-media-type": request.get_media_type().value,
            }
            
            if user_id:
                fields["x-amz-meta-user-id"] = user_id
            
            if request.checksum:
                fields["x-amz-meta-checksum"] = request.checksum
            
            # Generate presigned POST
            presigned_post = self.client.generate_presigned_post(
                Bucket=settings.s3_bucket,
                Key=object_key,
                Fields=fields,
                Conditions=conditions,
                ExpiresIn=expires_in
            )
            
            expires_at = datetime.utcnow() + timedelta(seconds=expires_in)
            
            response = PresignedUploadResponse(
                upload_id=upload_id,
                upload_url=presigned_post["url"],
                fields=presigned_post["fields"],
                expires_at=expires_at,
                max_file_size=request.size_bytes
            )
            
            logger.info(f"Generated presigned upload for {sanitized_filename}, ID: {upload_id}")
            return response
            
        except Exception as e:
            logger.error(f"Failed to generate presigned upload: {e}")
            raise StorageError(f"Failed to generate upload URL: {str(e)}")
    
    async def verify_upload_completion(
        self,
        upload_id: str,
        expected_size: Optional[int] = None
    ) -> Tuple[bool, Optional[Dict[str, Any]]]:
        """Verify that upload completed successfully"""
        
        try:
            # Find the uploaded object by searching with upload_id metadata
            # Search in both old uploads/ and new sightings/ prefixes for compatibility
            prefixes_to_search = ["uploads/", "sightings/"]
            all_objects = []
            
            for prefix in prefixes_to_search:
                try:
                    objects = self.client.list_objects_v2(
                        Bucket=settings.s3_bucket,
                        Prefix=prefix
                    )
                    all_objects.extend(objects.get('Contents', []))
                except Exception as e:
                    logger.warning(f"Could not search prefix {prefix}: {e}")
                    continue
            
            uploaded_object = None
            for obj in all_objects:
                try:
                    # Get object metadata
                    response = self.client.head_object(
                        Bucket=settings.s3_bucket,
                        Key=obj['Key']
                    )
                    
                    metadata = response.get('Metadata', {})
                    if metadata.get('upload-id') == upload_id:
                        uploaded_object = {
                            'key': obj['Key'],
                            'size': obj['Size'],
                            'last_modified': obj['LastModified'],
                            'metadata': metadata,
                            'content_type': response.get('ContentType'),
                            'etag': response.get('ETag', '').strip('"')
                        }
                        break
                        
                except ClientError:
                    # Skip objects we can't read
                    continue
            
            if not uploaded_object:
                logger.warning(f"Upload not found for ID: {upload_id}")
                return False, None
            
            # Verify size if expected
            if expected_size and uploaded_object['size'] != expected_size:
                logger.warning(
                    f"Upload size mismatch for {upload_id}: "
                    f"expected {expected_size}, got {uploaded_object['size']}"
                )
                return False, uploaded_object
            
            logger.info(f"Upload verified successfully: {upload_id}")
            return True, uploaded_object
            
        except Exception as e:
            logger.error(f"Failed to verify upload {upload_id}: {e}")
            return False, None
    
    async def generate_public_url(
        self,
        object_key: str,
        expires_in: int = 86400  # 24 hours
    ) -> str:
        """Generate public URL for accessing uploaded media"""
        
        try:
            url = self.client.generate_presigned_url(
                'get_object',
                Params={
                    'Bucket': settings.s3_bucket,
                    'Key': object_key
                },
                ExpiresIn=expires_in
            )
            
            return url
            
        except Exception as e:
            logger.error(f"Failed to generate public URL for {object_key}: {e}")
            raise StorageError(f"Failed to generate public URL: {str(e)}")
    
    async def delete_object(self, object_key: str) -> bool:
        """Delete object from storage"""
        
        try:
            self.client.delete_object(
                Bucket=settings.s3_bucket,
                Key=object_key
            )
            
            logger.info(f"Deleted object: {object_key}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to delete object {object_key}: {e}")
            return False
    
    async def copy_object(
        self,
        source_key: str,
        destination_key: str,
        metadata: Optional[Dict[str, str]] = None
    ) -> bool:
        """Copy object to new location with optional metadata update"""
        
        try:
            copy_source = {
                'Bucket': settings.s3_bucket,
                'Key': source_key
            }
            
            extra_args = {}
            if metadata:
                extra_args['Metadata'] = metadata
                extra_args['MetadataDirective'] = 'REPLACE'
            
            self.client.copy_object(
                CopySource=copy_source,
                Bucket=settings.s3_bucket,
                Key=destination_key,
                **extra_args
            )
            
            logger.info(f"Copied object: {source_key} -> {destination_key}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to copy object {source_key} -> {destination_key}: {e}")
            return False
    
    async def get_object_metadata(self, object_key: str) -> Optional[Dict[str, Any]]:
        """Get metadata for an object"""
        
        try:
            response = self.client.head_object(
                Bucket=settings.s3_bucket,
                Key=object_key
            )
            
            return {
                'size': response['ContentLength'],
                'last_modified': response['LastModified'],
                'content_type': response.get('ContentType'),
                'etag': response.get('ETag', '').strip('"'),
                'metadata': response.get('Metadata', {}),
                'cache_control': response.get('CacheControl'),
                'content_encoding': response.get('ContentEncoding'),
            }
            
        except ClientError as e:
            if e.response['Error']['Code'] == '404':
                logger.warning(f"Object not found: {object_key}")
                return None
            else:
                logger.error(f"Failed to get metadata for {object_key}: {e}")
                return None
        except Exception as e:
            logger.error(f"Unexpected error getting metadata for {object_key}: {e}")
            return None
    
    async def list_uploads_by_user(
        self,
        user_id: str,
        limit: int = 100,
        prefix: str = "uploads/"
    ) -> list[Dict[str, Any]]:
        """List uploads for a specific user"""
        
        try:
            uploads = []
            paginator = self.client.get_paginator('list_objects_v2')
            
            for page in paginator.paginate(
                Bucket=settings.s3_bucket,
                Prefix=prefix,
                MaxKeys=limit
            ):
                for obj in page.get('Contents', []):
                    try:
                        # Get object metadata to check user
                        metadata_response = self.client.head_object(
                            Bucket=settings.s3_bucket,
                            Key=obj['Key']
                        )
                        
                        metadata = metadata_response.get('Metadata', {})
                        if metadata.get('user-id') == user_id:
                            uploads.append({
                                'key': obj['Key'],
                                'size': obj['Size'],
                                'last_modified': obj['LastModified'],
                                'upload_id': metadata.get('upload-id'),
                                'original_filename': metadata.get('original-filename'),
                                'media_type': metadata.get('media-type'),
                                'content_type': metadata_response.get('ContentType')
                            })
                            
                        if len(uploads) >= limit:
                            break
                            
                    except ClientError:
                        # Skip objects we can't read
                        continue
                
                if len(uploads) >= limit:
                    break
            
            return uploads
            
        except Exception as e:
            logger.error(f"Failed to list uploads for user {user_id}: {e}")
            return []
    
    async def cleanup_expired_uploads(self, older_than_hours: int = 24) -> int:
        """Clean up incomplete/abandoned uploads"""
        
        try:
            cutoff_time = datetime.utcnow() - timedelta(hours=older_than_hours)
            deleted_count = 0
            
            # List objects in uploads directory
            paginator = self.client.get_paginator('list_objects_v2')
            
            for page in paginator.paginate(
                Bucket=settings.s3_bucket,
                Prefix="uploads/"
            ):
                for obj in page.get('Contents', []):
                    if obj['LastModified'].replace(tzinfo=None) < cutoff_time:
                        try:
                            # Check if this is an incomplete upload by looking for metadata
                            metadata_response = self.client.head_object(
                                Bucket=settings.s3_bucket,
                                Key=obj['Key']
                            )
                            
                            metadata = metadata_response.get('Metadata', {})
                            
                            # If it has upload-id but no completion marker, it's incomplete
                            if 'upload-id' in metadata and 'completed-at' not in metadata:
                                await self.delete_object(obj['Key'])
                                deleted_count += 1
                                
                        except ClientError:
                            # Skip objects we can't process
                            continue
            
            if deleted_count > 0:
                logger.info(f"Cleaned up {deleted_count} expired uploads")
            
            return deleted_count
            
        except Exception as e:
            logger.error(f"Failed to cleanup expired uploads: {e}")
            return 0


# Global storage service instance
storage_service = StorageService()