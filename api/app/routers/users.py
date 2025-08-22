"""
User Management API - MP13-1
Handles user registration, username generation, and user profile management
"""

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
import uuid
import asyncpg
import json

from app.services.username_service import UsernameGenerator

router = APIRouter(prefix="/users", tags=["users"])


# Database dependency
async def get_db():
    """Get database connection pool"""
    return await asyncpg.create_pool(
        host="localhost", port=5432, user="ufobeep_user", 
        password="ufopostpass", database="ufobeep_db",
        min_size=1, max_size=10
    )


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
    platform: str = Field(..., description="Device platform (ios, android, web)")
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
async def register_user(request: UserRegistrationRequest):
    """
    Register a new user or get existing user by device ID
    Creates username-based identity for anonymous device users
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Check if device already exists
            existing_device = await conn.fetchrow(
                "SELECT device_id, user_id FROM user_devices WHERE device_id = $1",
                request.device_id
            )
            
            if existing_device:
                # Get the existing user
                existing_user = await conn.fetchrow(
                    "SELECT id, username FROM users WHERE id = $1",
                    existing_device['user_id']
                )
                return UserRegistrationResponse(
                    user_id=str(existing_user['id']),
                    username=existing_user['username'],
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
                    existing = await conn.fetchrow(
                        "SELECT username FROM users WHERE username = $1",
                        candidate
                    )
                    if not existing:
                        username = candidate
                        break
                
                if not username:
                    raise HTTPException(
                        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                        detail="Unable to generate unique username"
                    )
            
            # Create new user
            user_id = uuid.uuid4()
            await conn.execute("""
                INSERT INTO users (
                    id, username, email, alert_range_km, units_metric, 
                    preferred_language, is_active, is_verified, created_at, updated_at
                )
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, NOW(), NOW())
            """, user_id, username, request.email, 
                request.alert_range_km or 50.0,
                request.units_metric if request.units_metric is not None else True,
                request.preferred_language or "en", True, False)
            
            # Create simple device mapping - create table if not exists
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS user_devices (
                    device_id TEXT PRIMARY KEY,
                    user_id UUID NOT NULL REFERENCES users(id),
                    device_info JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # Store device mapping with JSON info
            device_info = {
                "platform": request.platform,
                "device_name": request.device_name,
                "app_version": request.app_version,
                "os_version": request.os_version
            }
            
            await conn.execute("""
                INSERT INTO user_devices (device_id, user_id, device_info)
                VALUES ($1, $2, $3)
            """, request.device_id, user_id, json.dumps(device_info))
            
            return UserRegistrationResponse(
                user_id=str(user_id),
                username=username,
                device_id=request.device_id,
                is_new_user=True,
                message=f"Welcome to UFOBeep, {username}!"
            )
            
    except Exception as e:
        if "username" in str(e) and "unique" in str(e).lower():
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already exists. Please choose another one."
            )
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Registration failed: {str(e)}"
        )
    finally:
        await pool.close()


@router.get("/by-device/{device_id}", response_model=UserRegistrationResponse)
async def get_user_by_device(device_id: str):
    """
    Get user information by device ID  
    Used for existing users to retrieve their username and user ID
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            device_user = await conn.fetchrow("""
                SELECT ud.device_id, u.id, u.username 
                FROM user_devices ud 
                JOIN users u ON ud.user_id = u.id 
                WHERE ud.device_id = $1
            """, device_id)
            
            if not device_user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="Device not found. Please register first."
                )
            
            return UserRegistrationResponse(
                user_id=str(device_user['id']),
                username=device_user['username'],
                device_id=device_id,
                is_new_user=False,
                message="User found"
            )
    finally:
        await pool.close()


@router.post("/validate-username")
async def validate_username(request: dict):
    """
    Validate if a username is available and properly formatted
    """
    username = request.get("username", "")
    
    # Check format
    is_valid, error_message = UsernameGenerator.is_valid_username(username)
    if not is_valid:
        return {
            "valid": False,
            "available": False,
            "error": error_message
        }
    
    # Check availability
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            existing = await conn.fetchrow(
                "SELECT username FROM users WHERE username = $1",
                username
            )
            available = existing is None
            
            return {
                "valid": True,
                "available": available,
                "error": None if available else "Username already taken"
            }
    finally:
        await pool.close()