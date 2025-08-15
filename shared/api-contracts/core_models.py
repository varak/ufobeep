"""
Shared API Models for UFOBeep
These models define the core data structures used across the API
"""
from datetime import datetime
from enum import Enum
from typing import Optional, List, Dict, Any
from pydantic import BaseModel, Field, validator


# Enums for standardized values
class SightingCategory(str, Enum):
    UFO = "ufo"
    ANOMALY = "anomaly"
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


# Core data models
class GeoCoordinates(BaseModel):
    """Geographic coordinates"""
    latitude: float = Field(..., ge=-90.0, le=90.0)
    longitude: float = Field(..., ge=-180.0, le=180.0)
    altitude: Optional[float] = Field(None, description="Altitude in meters")
    accuracy: Optional[float] = Field(None, gt=0.0, description="GPS accuracy in meters")


class SensorData(BaseModel):
    """Comprehensive sensor data from mobile device"""
    timestamp: datetime
    location: GeoCoordinates
    
    # Compass/orientation data
    azimuth_deg: float = Field(..., ge=0.0, lt=360.0, description="Compass heading")
    pitch_deg: float = Field(..., ge=-90.0, le=90.0, description="Device tilt up/down")
    roll_deg: Optional[float] = Field(None, ge=-180.0, le=180.0, description="Device rotation")
    
    # Camera data
    hfov_deg: Optional[float] = Field(None, gt=0.0, lt=180.0, description="Horizontal field of view")
    vfov_deg: Optional[float] = Field(None, gt=0.0, lt=180.0, description="Vertical field of view")
    
    # Device metadata
    device_id: Optional[str] = None
    app_version: Optional[str] = None
    
    @validator('azimuth_deg')
    def normalize_azimuth(cls, v):
        return v % 360


class WeatherData(BaseModel):
    """Weather conditions at time of sighting"""
    temperature_c: Optional[float] = None
    humidity_percent: Optional[float] = Field(None, ge=0.0, le=100.0)
    pressure_hpa: Optional[float] = None
    wind_speed_ms: Optional[float] = Field(None, ge=0.0)
    wind_direction_deg: Optional[float] = Field(None, ge=0.0, lt=360.0)
    visibility_km: Optional[float] = Field(None, ge=0.0)
    cloud_cover_percent: Optional[float] = Field(None, ge=0.0, le=100.0)
    conditions: Optional[str] = None  # "clear", "cloudy", "rainy", etc.
    precipitation_mm: Optional[float] = Field(None, ge=0.0)


class CelestialData(BaseModel):
    """Celestial/astronomical data"""
    moon_phase: Optional[str] = None
    moon_illumination_percent: Optional[float] = Field(None, ge=0.0, le=100.0)
    moon_altitude_deg: Optional[float] = Field(None, ge=-90.0, le=90.0)
    moon_azimuth_deg: Optional[float] = Field(None, ge=0.0, lt=360.0)
    sun_altitude_deg: Optional[float] = Field(None, ge=-90.0, le=90.0)
    sun_azimuth_deg: Optional[float] = Field(None, ge=0.0, lt=360.0)
    visible_planets: List[str] = Field(default_factory=list)
    satellite_passes: List[Dict[str, Any]] = Field(default_factory=list)


class MediaFile(BaseModel):
    """Media file metadata"""
    id: str
    type: MediaType
    filename: str
    url: str
    thumbnail_url: Optional[str] = None
    size_bytes: int
    duration_seconds: Optional[float] = None  # For video/audio
    width: Optional[int] = None  # For images/video
    height: Optional[int] = None  # For images/video
    created_at: datetime
    metadata: Dict[str, Any] = Field(default_factory=dict)
    
    # Multi-media support fields
    is_primary: bool = Field(default=False, description="Primary media for display in lists")
    uploaded_by_user_id: Optional[str] = Field(None, description="User who uploaded this file")
    upload_order: int = Field(default=0, description="Order uploaded (0=original, 1=first additional)")
    display_priority: int = Field(default=0, description="Manual display priority (higher=more prominent)")
    contributed_at: Optional[datetime] = Field(None, description="When added to sighting")


class PlaneMatchResult(BaseModel):
    """Result of aircraft matching analysis"""
    is_likely_aircraft: bool
    confidence: float = Field(..., ge=0.0, le=1.0)
    matched_aircraft: Optional[Dict[str, Any]] = None
    reason: str
    checked_at: datetime


class EnrichmentData(BaseModel):
    """Additional context data for sighting"""
    weather: Optional[WeatherData] = None
    celestial: Optional[CelestialData] = None
    plane_match: Optional[PlaneMatchResult] = None
    nearby_airports: List[Dict[str, Any]] = Field(default_factory=list)
    military_activity: Optional[Dict[str, Any]] = None
    processed_at: datetime


class SightingSubmission(BaseModel):
    """Complete sighting submission from mobile app"""
    title: str = Field(..., min_length=5, max_length=200)
    description: str = Field(..., min_length=10, max_length=2000)
    category: SightingCategory
    
    # Core data
    sensor_data: SensorData
    media_files: List[str] = Field(default_factory=list)  # Media file IDs
    
    # User context
    reporter_id: Optional[str] = None
    duration_seconds: Optional[int] = Field(None, gt=0)
    witness_count: int = Field(default=1, ge=1, le=100)
    
    # Additional details
    tags: List[str] = Field(default_factory=list, max_items=10)
    is_public: bool = Field(default=True)
    
    submitted_at: datetime = Field(default_factory=datetime.utcnow)


class Sighting(BaseModel):
    """Complete sighting record (server-side)"""
    id: str
    
    # From submission
    title: str
    description: str
    category: SightingCategory
    sensor_data: SensorData
    media_files: List[MediaFile] = Field(default_factory=list)
    
    # Processing results
    status: SightingStatus = SightingStatus.PENDING
    enrichment: Optional[EnrichmentData] = None
    
    # Computed fields
    jittered_location: GeoCoordinates  # Privacy-protected coordinates
    alert_level: AlertLevel = AlertLevel.LOW
    
    # Metadata
    reporter_id: Optional[str] = None
    witness_count: int = Field(default=1)
    view_count: int = Field(default=0)
    verification_score: float = Field(default=0.0, ge=0.0, le=1.0)
    
    # Matrix chat room
    matrix_room_id: Optional[str] = None
    
    # Timestamps
    submitted_at: datetime
    processed_at: Optional[datetime] = None
    verified_at: Optional[datetime] = None
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


class AlertsQuery(BaseModel):
    """Query parameters for alerts feed"""
    # Geographic filtering
    center_lat: Optional[float] = Field(None, ge=-90.0, le=90.0)
    center_lng: Optional[float] = Field(None, ge=-180.0, le=180.0)
    radius_km: Optional[float] = Field(None, gt=0.0, le=1000.0)
    
    # Content filtering
    category: Optional[SightingCategory] = None
    status: Optional[SightingStatus] = None
    min_alert_level: Optional[AlertLevel] = None
    verified_only: bool = Field(default=False)
    
    # Pagination
    offset: int = Field(default=0, ge=0)
    limit: int = Field(default=20, ge=1, le=100)
    
    # Time filtering
    since: Optional[datetime] = None
    until: Optional[datetime] = None


class AlertsFeed(BaseModel):
    """Response for alerts feed"""
    sightings: List[Sighting]
    total_count: int
    has_more: bool
    query: AlertsQuery
    generated_at: datetime = Field(default_factory=datetime.utcnow)


class UserProfile(BaseModel):
    """User profile and preferences"""
    user_id: str
    
    # Alert preferences
    alert_range_km: float = Field(default=50.0, gt=0.0, le=1000.0)
    min_alert_level: AlertLevel = AlertLevel.LOW
    categories: List[SightingCategory] = Field(default_factory=lambda: list(SightingCategory))
    
    # Notification settings
    push_notifications: bool = Field(default=True)
    email_notifications: bool = Field(default=False)
    quiet_hours_start: Optional[str] = None  # "22:00"
    quiet_hours_end: Optional[str] = None    # "08:00"
    
    # Privacy settings
    share_location: bool = Field(default=True)
    public_profile: bool = Field(default=False)
    
    # App settings
    preferred_language: str = Field(default="en")
    units_metric: bool = Field(default=True)
    
    # Matrix integration
    matrix_user_id: Optional[str] = None
    matrix_device_id: Optional[str] = None
    
    created_at: datetime = Field(default_factory=datetime.utcnow)
    updated_at: datetime = Field(default_factory=datetime.utcnow)


# API Response wrappers
class APIResponse(BaseModel):
    """Standard API response wrapper"""
    success: bool
    message: Optional[str] = None
    timestamp: datetime = Field(default_factory=datetime.utcnow)


class DataResponse(APIResponse):
    """API response with data payload"""
    data: Any = None


class ErrorResponse(APIResponse):
    """API error response"""
    success: bool = Field(default=False)
    error_code: Optional[str] = None
    details: Optional[Dict[str, Any]] = None


class PaginatedResponse(APIResponse):
    """Paginated API response"""
    data: List[Any] = Field(default_factory=list)
    total_count: int
    offset: int
    limit: int
    has_more: bool