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
from app.services.user_migration_service import get_migration_service
from app.services.email_service_postfix import PostfixEmailService
from app.services.sms_service import sms_service
from app.services.database_service import get_database_pool

router = APIRouter(prefix="/users", tags=["users"])


# Database dependency - now uses shared pool
async def get_db() -> asyncpg.Pool:
    """Get database connection pool from service"""
    return await get_database_pool()


# Pydantic Models for API
class UsernameGenerationResponse(BaseModel):
    """Response for username generation"""
    username: str
    alternatives: List[str]


class RecoveryRequest(BaseModel):
    """Request for account recovery"""
    email: Optional[str] = Field(None, description="Email address for recovery")
    phone: Optional[str] = Field(None, description="Phone number for SMS recovery")


class PhoneAddRequest(BaseModel):
    """Request to add phone number"""
    device_id: str = Field(..., min_length=1, description="Device identifier")
    phone: str = Field(..., min_length=10, description="Phone number")


class PhoneVerifyRequest(BaseModel):
    """Request to verify phone number"""
    device_id: str = Field(..., min_length=1, description="Device identifier")
    code: str = Field(..., min_length=6, max_length=6, description="SMS verification code")


class TestSMSRequest(BaseModel):
    """Request to test SMS service"""
    phone: str = Field(..., min_length=10, description="Phone number to test")


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
            
            # Migrate existing sightings from device_id to username
            migration_service = await get_migration_service(pool)
            migrated_count = await migration_service.migrate_device_to_username(
                request.device_id, username
            )
            
            # Send verification email if email provided
            if request.email and request.email.strip():
                email_service = PostfixEmailService()
                token = email_service.generate_verification_token()
                
                # Save verification token
                await conn.execute("""
                    UPDATE users 
                    SET verification_token = $1, verification_sent_at = NOW() 
                    WHERE id = $2
                """, token, user_id)
                
                # Send verification email (async, don't wait)
                await email_service.send_verification_email(
                    request.email.strip(), username, token
                )
            
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
        pass  # Shared pool - don't close


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
        pass  # Shared pool - don't close


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
        pass  # Shared pool - don't close


@router.get("/migration-status")
async def get_migration_status():
    """
    Get status of device ID to username migration
    Shows progress of transitioning from device IDs to usernames
    """
    pool = await get_db()
    try:
        migration_service = await get_migration_service(pool)
        status = await migration_service.get_migration_status()
        return {
            "success": True,
            "migration_status": status
        }
    finally:
        pass  # Shared pool - don't close


@router.post("/verify-email")
async def verify_email(request: dict):
    """Verify email address with token from verification email"""
    token = request.get("token")
    if not token:
        raise HTTPException(status_code=400, detail="Token required")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by verification token
            user = await conn.fetchrow("""
                SELECT id, username, email, verification_sent_at
                FROM users 
                WHERE verification_token = $1
            """, token)
            
            if not user:
                raise HTTPException(status_code=404, detail="Invalid verification token")
            
            # Check if token is expired (24 hours)
            from datetime import datetime, timedelta
            if user['verification_sent_at'] < datetime.now() - timedelta(hours=24):
                raise HTTPException(status_code=400, detail="Verification token expired")
            
            # Mark email as verified and clear token
            await conn.execute("""
                UPDATE users 
                SET email_verified = TRUE, verification_token = NULL, verification_sent_at = NULL
                WHERE id = $1
            """, user['id'])
            
            return {
                "success": True,
                "message": f"Email verified for {user['username']}! You can now recover your account.",
                "username": user['username']
            }
    finally:
        pass  # Shared pool - don't close


@router.post("/recover-account")
async def recover_account(request: RecoveryRequest):
    """Send recovery code to verified email or SMS"""
    email = request.email.strip() if request.email else ""
    phone = request.phone.strip() if request.phone else ""
    
    if not email and not phone:
        raise HTTPException(status_code=400, detail="Email or phone number required")
    
    if email and phone:
        raise HTTPException(status_code=400, detail="Provide either email or phone, not both")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by email or phone
            if email:
                user = await conn.fetchrow("""
                    SELECT id, username, email, phone, email_verified, phone_verified 
                    FROM users 
                    WHERE email = $1
                """, email)
                auth_method = "email"
                contact_info = email
            else:
                user = await conn.fetchrow("""
                    SELECT id, username, email, phone, email_verified, phone_verified 
                    FROM users 
                    WHERE phone = $1
                """, phone)
                auth_method = "sms"
                contact_info = phone
            
            if not user:
                # Don't reveal if contact exists - security best practice
                return {
                    "success": True,
                    "message": "If this contact method is verified, a recovery code has been sent.",
                    "expires_in_minutes": 15
                }
            
            # Generate 6-digit recovery code
            import secrets
            recovery_code = f"{secrets.randbelow(999999):06d}"
            
            # Save recovery code (expires in 15 minutes)
            from datetime import datetime, timedelta
            expires_at = datetime.now() + timedelta(minutes=15)
            
            await conn.execute("""
                UPDATE users 
                SET recovery_code = $1, recovery_expires_at = $2
                WHERE id = $3
            """, recovery_code, expires_at, user['id'])
            
            # Send recovery code via appropriate method
            if auth_method == "email":
                email_service = PostfixEmailService()
                await email_service.send_recovery_email(contact_info, user['username'], recovery_code)
                message = "If this email is verified, a recovery code has been sent."
            else:
                # Send SMS
                result = await sms_service.send_recovery_sms(contact_info, user['username'], recovery_code)
                if not result["success"]:
                    # For demo, still return success to prevent contact enumeration
                    pass
                message = "If this phone number is verified, a recovery code has been sent."
            
            return {
                "success": True,
                "message": message,
                "expires_in_minutes": 15
            }
                
    finally:
        pass  # Shared pool - don't close


@router.post("/verify-recovery")
async def verify_recovery_code(request: dict):
    """Use recovery code to restore account on new device"""
    recovery_code = request.get("recovery_code", "").strip()
    new_device_id = request.get("device_id", "").strip()
    
    if not recovery_code or not new_device_id:
        raise HTTPException(status_code=400, detail="Recovery code and device_id required")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by recovery code
            user = await conn.fetchrow("""
                SELECT id, username, email, recovery_expires_at
                FROM users 
                WHERE recovery_code = $1
            """, recovery_code)
            
            if not user:
                raise HTTPException(status_code=404, detail="Invalid recovery code")
            
            # Check if code is expired
            from datetime import datetime
            if user['recovery_expires_at'] < datetime.now():
                raise HTTPException(status_code=400, detail="Recovery code expired")
            
            # Link new device to existing user account
            device_info = {
                "platform": "recovered",
                "recovery_date": datetime.now().isoformat()
            }
            
            # Use INSERT ... ON CONFLICT to handle device_id already existing
            await conn.execute("""
                INSERT INTO user_devices (device_id, user_id, device_info)
                VALUES ($1, $2, $3)
                ON CONFLICT (device_id) DO UPDATE SET 
                    user_id = EXCLUDED.user_id,
                    device_info = EXCLUDED.device_info
            """, new_device_id, user['id'], json.dumps(device_info))
            
            # Clear recovery code (single use)
            await conn.execute("""
                UPDATE users 
                SET recovery_code = NULL, recovery_expires_at = NULL
                WHERE id = $1
            """, user['id'])
            
            return {
                "success": True,
                "message": f"Account recovered! Welcome back, {user['username']}",
                "user_id": str(user['id']),
                "username": user['username'],
                "email": user['email'],
                "device_id": new_device_id
            }
            
    finally:
        pass  # Shared pool - don't close


@router.post("/debug-user")
async def debug_user(request: dict):
    """Debug endpoint to check user verification status"""
    username = request.get("username", "").strip()
    password = request.get("password", "").strip()
    
    if password != "ufopostpass":
        raise HTTPException(status_code=403, detail="Access denied")
    
    if not username:
        raise HTTPException(status_code=400, detail="Username required")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            user = await conn.fetchrow("""
                SELECT id, username, email, email_verified, verification_token, 
                       verification_sent_at, created_at
                FROM users 
                WHERE username = $1
            """, username)
            
            if not user:
                return {"error": "User not found"}
            
            return {
                "user_id": str(user['id']),
                "username": user['username'],
                "email": user['email'],
                "email_verified": user['email_verified'],
                "has_verification_token": bool(user['verification_token']),
                "verification_sent_at": str(user['verification_sent_at']) if user['verification_sent_at'] else None,
                "created_at": str(user['created_at'])
            }
                
    finally:
        pass  # Shared pool - don't close


@router.post("/test-email")
async def test_email(request: dict):
    """Test email sending capability"""
    email = request.get("email", "").strip()
    password = request.get("password", "").strip()
    
    if password != "ufopostpass":
        raise HTTPException(status_code=403, detail="Access denied")
    
    if not email:
        raise HTTPException(status_code=400, detail="Email required")
    
    try:
        email_service = PostfixEmailService()
        success = await email_service.send_verification_email(
            email, "test.user.123", "test-token-12345"
        )
        
        return {
            "success": success,
            "message": "Test email sent" if success else "Email sending failed"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }


@router.post("/setup-email-dkim")
async def setup_email_dkim(request: dict):
    """Set up DKIM for proper email delivery"""
    password = request.get("password", "").strip()
    
    if password != "ufopostpass":
        raise HTTPException(status_code=403, detail="Access denied")
    
    try:
        import subprocess
        import os
        
        # Run the DKIM setup script
        script_path = "/home/ufobeep/ufobeep/fix_email_deliverability.sh"
        
        if not os.path.exists(script_path):
            return {
                "success": False,
                "error": "Setup script not found",
                "script_path": script_path
            }
        
        # Execute the setup script
        result = subprocess.run(
            ["bash", script_path],
            capture_output=True,
            text=True,
            timeout=300  # 5 minute timeout
        )
        
        return {
            "success": result.returncode == 0,
            "returncode": result.returncode,
            "stdout": result.stdout,
            "stderr": result.stderr
        }
        
    except subprocess.TimeoutExpired:
        return {
            "success": False,
            "error": "Setup script timed out"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e)
        }