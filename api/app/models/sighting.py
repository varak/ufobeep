from sqlalchemy import Column, String, Text, DateTime, Float, Integer, Boolean, JSON, Enum as SQLEnum, ForeignKey
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.orm import relationship
from sqlalchemy.dialects.postgresql import UUID, ARRAY
from datetime import datetime
from enum import Enum
import uuid

from app.config.environment import settings

Base = declarative_base()


# Enums
class SightingCategory(str, Enum):
    UFO = "ufo"
    ANOMALY = "anomaly"
    UNKNOWN = "unknown"
    PET = "pet"


class SightingClassification(str, Enum):
    UFO = "ufo"
    PET = "pet"
    OTHER = "other"


class PetStatus(str, Enum):
    MISSING = "missing"
    FOUND = "found"
    REUNITED = "reunited"
    UNKNOWN = "unknown"


class SightingStatus(str, Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    EXPLAINED = "explained"
    REJECTED = "rejected"


class AlertLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"
    CRITICAL = "critical"


class MediaType(str, Enum):
    PHOTO = "photo"
    VIDEO = "video"
    AUDIO = "audio"


class DevicePlatform(str, Enum):
    IOS = "ios"
    ANDROID = "android"
    WEB = "web"


class PushProvider(str, Enum):
    FCM = "fcm"  # Firebase Cloud Messaging (Android & iOS)
    APNS = "apns"  # Apple Push Notification Service (iOS)
    WEBPUSH = "webpush"  # Web Push (PWA)


# Database Models
class User(Base):
    """User account model"""
    __tablename__ = "users"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    username = Column(String(50), unique=True, nullable=False)
    email = Column(String(255), unique=True, nullable=True)
    password_hash = Column(String(255), nullable=True)  # Nullable for anonymous users
    
    # Profile information
    display_name = Column(String(100), nullable=True)
    bio = Column(Text, nullable=True)
    location = Column(String(255), nullable=True)
    
    # Settings
    alert_range_km = Column(Float, default=50.0, nullable=False)
    min_alert_level = Column(SQLEnum(AlertLevel), default=AlertLevel.LOW, nullable=False)
    push_notifications = Column(Boolean, default=True, nullable=False)
    email_notifications = Column(Boolean, default=False, nullable=False)
    share_location = Column(Boolean, default=True, nullable=False)
    public_profile = Column(Boolean, default=False, nullable=False)
    preferred_language = Column(String(5), default="en", nullable=False)
    units_metric = Column(Boolean, default=True, nullable=False)
    
    # Matrix integration
    matrix_user_id = Column(String(255), nullable=True)
    matrix_device_id = Column(String(255), nullable=True)
    matrix_access_token = Column(Text, nullable=True)  # Encrypted
    
    # Metadata
    is_active = Column(Boolean, default=True, nullable=False)
    is_verified = Column(Boolean, default=False, nullable=False)
    last_login = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    sightings = relationship("Sighting", back_populates="reporter", cascade="all, delete-orphan")
    media_files = relationship("MediaFile", back_populates="uploaded_by_user", cascade="all, delete-orphan")
    devices = relationship("Device", back_populates="user", cascade="all, delete-orphan")


class Device(Base):
    """Device model for push notification tokens and device management"""
    __tablename__ = "devices"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False, index=True)
    
    # Device identification
    device_id = Column(String(255), nullable=False, index=True)  # Unique device identifier
    device_name = Column(String(255), nullable=True)  # User-friendly device name
    platform = Column(SQLEnum(DevicePlatform), nullable=False)
    
    # Device information
    app_version = Column(String(50), nullable=True)
    os_version = Column(String(50), nullable=True)
    device_model = Column(String(100), nullable=True)
    manufacturer = Column(String(100), nullable=True)
    
    # Push notification configuration
    push_token = Column(Text, nullable=True)  # FCM/APNS token
    push_provider = Column(SQLEnum(PushProvider), nullable=True)
    push_enabled = Column(Boolean, default=True, nullable=False)
    
    # Notification preferences (per device)
    alert_notifications = Column(Boolean, default=True, nullable=False)
    chat_notifications = Column(Boolean, default=True, nullable=False)
    system_notifications = Column(Boolean, default=True, nullable=False)
    
    # Device status
    is_active = Column(Boolean, default=True, nullable=False)
    last_seen = Column(DateTime, nullable=True)
    timezone = Column(String(50), nullable=True)
    locale = Column(String(10), nullable=True)
    
    # Push notification statistics
    notifications_sent = Column(Integer, default=0, nullable=False)
    notifications_opened = Column(Integer, default=0, nullable=False)
    last_notification_at = Column(DateTime, nullable=True)
    
    # Registration and update tracking
    registered_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    token_updated_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    user = relationship("User", back_populates="devices")
    
    # Unique constraint for device_id per user
    __table_args__ = (
        {"extend_existing": True},
    )


class MediaFile(Base):
    """Media file model"""
    __tablename__ = "media_files"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    upload_id = Column(String(100), unique=True, nullable=False, index=True)
    
    # File information
    type = Column(SQLEnum(MediaType), nullable=False)
    filename = Column(String(255), nullable=False)
    original_filename = Column(String(255), nullable=False)
    url = Column(Text, nullable=False)
    thumbnail_url = Column(Text, nullable=True)
    
    # File metadata
    size_bytes = Column(Integer, nullable=False)
    content_type = Column(String(100), nullable=False)
    checksum = Column(String(64), nullable=True)
    
    # Media-specific fields
    duration_seconds = Column(Float, nullable=True)  # For video/audio
    width = Column(Integer, nullable=True)  # For images/video
    height = Column(Integer, nullable=True)  # For images/video
    format_details = Column(String(100), nullable=True)
    
    # Processing status
    processing_status = Column(String(50), default="completed", nullable=False)
    processing_error = Column(Text, nullable=True)
    
    # Metadata and relationships
    metadata = Column(JSON, default=dict, nullable=False)
    uploaded_by = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    sighting_id = Column(UUID(as_uuid=True), ForeignKey("sightings.id"), nullable=True)
    
    # Timestamps
    uploaded_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    uploaded_by_user = relationship("User", back_populates="media_files")
    sighting = relationship("Sighting", back_populates="media_files")


class Sighting(Base):
    """Main sighting model"""
    __tablename__ = "sightings"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    
    # Basic information
    title = Column(String(200), nullable=False)
    description = Column(Text, nullable=False)
    category = Column(SQLEnum(SightingCategory), nullable=False)
    classification = Column(SQLEnum(SightingClassification), nullable=True)
    
    # Pet-specific metadata (only populated when classification = 'pet')
    pet_type = Column(String(100), nullable=True)  # dog, cat, bird, etc.
    color_markings = Column(Text, nullable=True)  # description of pet appearance
    collar_tag_info = Column(Text, nullable=True)  # collar description, tag info
    pet_status = Column(SQLEnum(PetStatus), nullable=True)  # missing, found, etc.
    cross_streets = Column(String(500), nullable=True)  # nearest cross streets
    
    # Status and classification
    status = Column(SQLEnum(SightingStatus), default=SightingStatus.PENDING, nullable=False)
    alert_level = Column(SQLEnum(AlertLevel), default=AlertLevel.LOW, nullable=False)
    verification_score = Column(Float, default=0.0, nullable=False)
    
    # Location data (exact coordinates - encrypted)
    exact_latitude = Column(Float, nullable=False)  # Encrypted in production
    exact_longitude = Column(Float, nullable=False)  # Encrypted in production
    exact_altitude = Column(Float, nullable=True)
    location_accuracy = Column(Float, nullable=True)
    
    # Public location data (jittered for privacy)
    public_latitude = Column(Float, nullable=False)
    public_longitude = Column(Float, nullable=False)
    
    # Sensor data
    sensor_timestamp = Column(DateTime, nullable=False)
    azimuth_deg = Column(Float, nullable=False)
    pitch_deg = Column(Float, nullable=False)
    roll_deg = Column(Float, nullable=True)
    hfov_deg = Column(Float, nullable=True)
    vfov_deg = Column(Float, nullable=True)
    device_id = Column(String(255), nullable=True)
    app_version = Column(String(50), nullable=True)
    
    # Sighting details
    duration_seconds = Column(Integer, nullable=True)
    witness_count = Column(Integer, default=1, nullable=False)
    tags = Column(ARRAY(String), default=list, nullable=False)
    
    # Privacy and visibility
    is_public = Column(Boolean, default=True, nullable=False)
    reporter_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    # Engagement metrics
    view_count = Column(Integer, default=0, nullable=False)
    like_count = Column(Integer, default=0, nullable=False)
    comment_count = Column(Integer, default=0, nullable=False)
    
    # Matrix integration
    matrix_room_id = Column(String(255), nullable=True, index=True)
    matrix_room_alias = Column(String(255), nullable=True)
    
    # Enrichment data (JSON fields)
    weather_data = Column(JSON, nullable=True)
    celestial_data = Column(JSON, nullable=True)
    satellite_data = Column(JSON, nullable=True)
    plane_match_data = Column(JSON, nullable=True)
    enrichment_metadata = Column(JSON, default=dict, nullable=False)
    
    # Timestamps
    submitted_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    processed_at = Column(DateTime, nullable=True)
    verified_at = Column(DateTime, nullable=True)
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    reporter = relationship("User", back_populates="sightings")
    media_files = relationship("MediaFile", back_populates="sighting", cascade="all, delete-orphan")
    comments = relationship("SightingComment", back_populates="sighting", cascade="all, delete-orphan")
    reactions = relationship("SightingReaction", back_populates="sighting", cascade="all, delete-orphan")


class SightingComment(Base):
    """Comments on sightings"""
    __tablename__ = "sighting_comments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sighting_id = Column(UUID(as_uuid=True), ForeignKey("sightings.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=True)
    
    # Comment content
    content = Column(Text, nullable=False)
    is_anonymous = Column(Boolean, default=False, nullable=False)
    
    # Moderation
    is_deleted = Column(Boolean, default=False, nullable=False)
    is_hidden = Column(Boolean, default=False, nullable=False)
    moderation_reason = Column(String(255), nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    
    # Relationships
    sighting = relationship("Sighting", back_populates="comments")
    user = relationship("User")


class SightingReaction(Base):
    """User reactions to sightings (likes, etc.)"""
    __tablename__ = "sighting_reactions"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sighting_id = Column(UUID(as_uuid=True), ForeignKey("sightings.id"), nullable=False)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    
    # Reaction type
    reaction_type = Column(String(20), default="like", nullable=False)  # like, dislike, interesting, etc.
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    
    # Relationships
    sighting = relationship("Sighting", back_populates="reactions")
    user = relationship("User")
    
    # Unique constraint to prevent duplicate reactions
    __table_args__ = (
        {"extend_existing": True},
    )


class SightingEnrichment(Base):
    """Enrichment processing status and results"""
    __tablename__ = "sighting_enrichments"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    sighting_id = Column(UUID(as_uuid=True), ForeignKey("sightings.id"), nullable=False, unique=True)
    
    # Processing status
    weather_status = Column(String(20), default="pending", nullable=False)  # pending, completed, failed
    celestial_status = Column(String(20), default="pending", nullable=False)
    plane_match_status = Column(String(20), default="pending", nullable=False)
    satellite_status = Column(String(20), default="pending", nullable=False)
    
    # Processing results
    weather_result = Column(JSON, nullable=True)
    celestial_result = Column(JSON, nullable=True)
    plane_match_result = Column(JSON, nullable=True)
    satellite_result = Column(JSON, nullable=True)
    
    # Processing metadata
    processing_attempts = Column(Integer, default=0, nullable=False)
    last_error = Column(Text, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False)
    updated_at = Column(DateTime, default=datetime.utcnow, onupdate=datetime.utcnow, nullable=False)
    completed_at = Column(DateTime, nullable=True)
    
    # Relationship
    sighting = relationship("Sighting")


class Alert(Base):
    """Alert notifications sent to users"""
    __tablename__ = "alerts"
    
    id = Column(UUID(as_uuid=True), primary_key=True, default=uuid.uuid4)
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id"), nullable=False)
    sighting_id = Column(UUID(as_uuid=True), ForeignKey("sightings.id"), nullable=False)
    
    # Alert details
    alert_type = Column(String(50), default="new_sighting", nullable=False)
    title = Column(String(200), nullable=False)
    message = Column(Text, nullable=False)
    
    # Delivery status
    is_sent = Column(Boolean, default=False, nullable=False)
    is_read = Column(Boolean, default=False, nullable=False)
    delivery_method = Column(String(20), nullable=True)  # push, email, sms
    
    # Distance from user's location when alert was generated
    distance_km = Column(Float, nullable=True)
    
    # Timestamps
    created_at = Column(DateTime, default=datetime.utcnow, nullable=False, index=True)
    sent_at = Column(DateTime, nullable=True)
    read_at = Column(DateTime, nullable=True)
    
    # Relationships
    user = relationship("User")
    sighting = relationship("Sighting")


# Index definitions for performance
from sqlalchemy import Index

# Indexes for common queries
Index('idx_sightings_location', Sighting.public_latitude, Sighting.public_longitude)
Index('idx_sightings_created_status', Sighting.created_at, Sighting.status)
Index('idx_sightings_category_alert', Sighting.category, Sighting.alert_level)
Index('idx_sightings_public_created', Sighting.is_public, Sighting.created_at)
Index('idx_media_upload_id', MediaFile.upload_id)
Index('idx_alerts_user_created', Alert.user_id, Alert.created_at)
Index('idx_comments_sighting_created', SightingComment.sighting_id, SightingComment.created_at)
Index('idx_devices_user_platform', Device.user_id, Device.platform)
Index('idx_devices_active_push', Device.is_active, Device.push_enabled)
Index('idx_devices_last_seen', Device.last_seen)