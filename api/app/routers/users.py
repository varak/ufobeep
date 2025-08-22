"""
User Management API - MP13-1
Handles user registration, username generation, and user profile management
"""

from fastapi import APIRouter, HTTPException, Depends, status
from sqlalchemy.orm import Session
from sqlalchemy.exc import IntegrityError
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
import uuid

from app.models.sighting import User, Device, DevicePlatform
from app.services.username_service import UsernameGenerator
from app.config.environment import get_db

router = APIRouter(prefix="/users", tags=["users"])


# Pydantic Models for API
class UsernameGenerationResponse(BaseModel):
    """Response for username generation"""
    username: str
    alternatives: List[str]


class UserRegistrationRequest(BaseModel):
    """Request for user registration"""
    device_id: str = Field(..., min_length=1, max_length=255, description="Device identifier")
    username: Optional[str] = Field(None, min_length=3, max_length=50, description="Custom username or None for auto-generation")
    email: Optional[str] = Field(None, description="Optional email address")
    
    # Device information
    platform: DevicePlatform
    device_name: Optional[str] = Field(None, max_length=255)
    app_version: Optional[str] = Field(None, max_length=50)
    os_version: Optional[str] = Field(None, max_length=50)
    
    # User preferences
    alert_range_km: Optional[float] = Field(50.0, ge=1.0, le=500.0)
    units_metric: Optional[bool] = Field(True)
    preferred_language: Optional[str] = Field("en", max_length=5)
    
    @validator('username')
    def validate_username(cls, v):
        if v is not None:
            is_valid, error = UsernameGenerator.is_valid_username(v)
            if not is_valid:
                raise ValueError(error)
        return v


class UserRegistrationResponse(BaseModel):
    """Response for user registration"""
    user_id: str
    username: str
    device_id: str
    is_new_user: bool
    message: str


class UserProfileResponse(BaseModel):
    """User profile information"""
    user_id: str
    username: str
    email: Optional[str]
    display_name: Optional[str]
    alert_range_km: float
    units_metric: bool
    preferred_language: str
    is_verified: bool
    created_at: datetime
    stats: dict


# API Endpoints

@router.post("/generate-username", response_model=UsernameGenerationResponse)
async def generate_username():
    """
    Generate a new unique username with alternatives
    Returns cosmic-themed username like 'cosmic.whisper.7823'
    """
    try:
        primary_username = UsernameGenerator.generate()
        alternatives = UsernameGenerator.generate_multiple(count=4)
        
        return UsernameGenerationResponse(
            username=primary_username,
            alternatives=alternatives
        )
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate username: {str(e)}"
        )


@router.post("/register", response_model=UserRegistrationResponse)
async def register_user(
    request: UserRegistrationRequest,
    db: Session = Depends(get_db)
):
    """
    Register a new user or get existing user by device ID
    Creates username-based identity for anonymous device users
    """
    try:
        # Check if user already exists with this device
        existing_device = db.query(Device).filter(Device.device_id == request.device_id).first()
        
        if existing_device:
            # User already exists, return existing user
            existing_user = existing_device.user
            return UserRegistrationResponse(
                user_id=str(existing_user.id),
                username=existing_user.username,
                device_id=request.device_id,
                is_new_user=False,
                message="Welcome back! Using existing account."
            )
        
        # Generate username if not provided
        username = request.username
        if not username:
            # Try multiple times to get a unique username
            for attempt in range(10):
                candidate = UsernameGenerator.generate()
                existing = db.query(User).filter(User.username == candidate).first()
                if not existing:
                    username = candidate
                    break
            
            if not username:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Unable to generate unique username"
                )
        
        # Create new user
        new_user = User(
            id=uuid.uuid4(),
            username=username,
            email=request.email,
            password_hash=None,  # Anonymous user
            alert_range_km=request.alert_range_km or 50.0,
            units_metric=request.units_metric or True,
            preferred_language=request.preferred_language or "en",
            is_active=True,
            is_verified=False
        )
        
        db.add(new_user)
        db.flush()  # Get the user ID
        
        # Create device record
        new_device = Device(
            id=uuid.uuid4(),
            user_id=new_user.id,
            device_id=request.device_id,
            device_name=request.device_name,
            platform=request.platform,
            app_version=request.app_version,
            os_version=request.os_version,
            is_active=True,
            last_seen=datetime.utcnow()
        )
        
        db.add(new_device)
        db.commit()
        
        return UserRegistrationResponse(
            user_id=str(new_user.id),
            username=new_user.username,
            device_id=request.device_id,
            is_new_user=True,
            message=f"Welcome to UFOBeep, {username}!"
        )
        
    except IntegrityError as e:
        db.rollback()
        if "username" in str(e):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already exists. Please choose another one."
            )
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Registration failed due to data conflict"
        )
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )


@router.get("/by-device/{device_id}", response_model=UserRegistrationResponse)
async def get_user_by_device(device_id: str, db: Session = Depends(get_db)):
    """
    Get user information by device ID
    Used for existing users to retrieve their username and user ID
    """
    device = db.query(Device).filter(Device.device_id == device_id).first()
    
    if not device:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Device not found. Please register first."
        )
    
    user = device.user
    return UserRegistrationResponse(
        user_id=str(user.id),
        username=user.username,
        device_id=device_id,
        is_new_user=False,
        message="User found"
    )


@router.get("/profile/{username}", response_model=UserProfileResponse)
async def get_user_profile(username: str, db: Session = Depends(get_db)):
    """
    Get user profile by username
    Returns public profile information
    """
    user = db.query(User).filter(User.username == username).first()
    
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found"
        )
    
    # Calculate user stats
    from sqlalchemy import func
    from app.models.sighting import Sighting, WitnessConfirmation
    
    sighting_count = db.query(func.count(Sighting.id)).filter(Sighting.reporter_id == user.id).scalar() or 0
    witness_count = db.query(func.count(WitnessConfirmation.id)).filter(WitnessConfirmation.user_id == user.id).scalar() or 0
    
    stats = {
        "sightings_reported": sighting_count,
        "sightings_witnessed": witness_count,
        "total_engagement": sighting_count + witness_count,
        "member_since": user.created_at.strftime("%Y-%m")
    }
    
    return UserProfileResponse(
        user_id=str(user.id),
        username=user.username,
        email=user.email if user.public_profile else None,
        display_name=user.display_name,
        alert_range_km=user.alert_range_km,
        units_metric=user.units_metric,
        preferred_language=user.preferred_language,
        is_verified=user.is_verified,
        created_at=user.created_at,
        stats=stats
    )


@router.post("/validate-username")
async def validate_username(username: str, db: Session = Depends(get_db)):
    """
    Validate if a username is available and properly formatted
    """
    # Check format
    is_valid, error_message = UsernameGenerator.is_valid_username(username)
    if not is_valid:
        return {
            "valid": False,
            "available": False,
            "error": error_message
        }
    
    # Check availability
    existing = db.query(User).filter(User.username == username).first()
    available = existing is None
    
    return {
        "valid": True,
        "available": available,
        "error": None if available else "Username already taken"
    }


@router.post("/migrate-device-to-user")
async def migrate_device_to_user(device_id: str, db: Session = Depends(get_db)):
    """
    Migrate an anonymous device ID to the new user system
    Creates a user account for existing device data
    """
    try:
        # Check if device already has a user
        existing_device = db.query(Device).filter(Device.device_id == device_id).first()
        if existing_device:
            return {
                "success": True,
                "message": "Device already has user account",
                "username": existing_device.user.username,
                "user_id": str(existing_device.user.id)
            }
        
        # Use database function to create user for device
        result = db.execute(
            "SELECT get_or_create_user_by_device_id(:device_id)",
            {"device_id": device_id}
        ).scalar()
        
        if result:
            db.commit()
            
            # Get the created user
            user = db.query(User).filter(User.id == result).first()
            
            return {
                "success": True,
                "message": "Device migrated to user system",
                "username": user.username,
                "user_id": str(user.id)
            }
        else:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Failed to migrate device"
            )
            
    except Exception as e:
        db.rollback()
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Migration failed: {str(e)}"
        )