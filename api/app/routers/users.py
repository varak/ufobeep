"""
User Management API - MP13-1
Handles user registration, username generation, and user profile management
"""

from fastapi import APIRouter, HTTPException, Depends, status, Request
from fastapi.security import HTTPAuthorizationCredentials
from pydantic import BaseModel, Field, validator
from typing import Optional, List
from datetime import datetime
import uuid
import asyncpg
import json
import logging

logger = logging.getLogger(__name__)

from app.services.username_service import UsernameGenerator
from app.services.user_migration_service import get_migration_service
from app.services.email_service_postfix import PostfixEmailService
from app.services.social_auth_service import SocialAuthService
from app.services.database_service import get_database_pool
from app.services.phone_service import phone_service
from app.middleware.firebase_auth import FirebaseUser, OptionalAuth, RequiredAuth
from app.core.auth import create_access_token, create_refresh_token, verify_access_token
from fastapi.security import HTTPBearer

router = APIRouter(prefix="/users", tags=["users"])
security = HTTPBearer(auto_error=False)


# Standardized auth response format
def standard_auth_response(user_data: dict, access_token: str, refresh_token: str, expires_in: int = 86400):
    """
    Standard authentication response format for all auth methods
    Ensures consistency across Google, Apple, Firebase, and Magic Link auth
    """
    # Parse login_methods if it's a JSON string
    login_methods = user_data.get("login_methods", ["email"])
    if isinstance(login_methods, str):
        try:
            login_methods = json.loads(login_methods)
        except:
            login_methods = ["email"]
    
    return {
        "success": True,
        "token_type": "Bearer", 
        "access": access_token,
        "refresh": refresh_token,
        "expires_in": expires_in,
        "user": {
            "id": str(user_data["id"]),
            "email": user_data.get("email"),
            "username": user_data.get("username"),
            "display_name": user_data.get("display_name"),
            "email_verified": bool(user_data.get("email_verified", False)),
            "login_methods": login_methods
        }
    }


# Database dependency - now uses shared pool
async def get_db() -> asyncpg.Pool:
    """Get database connection pool from service"""
    return await get_database_pool()

# Helper function to generate unique username
async def _generate_unique_username(pool: asyncpg.Pool) -> str:
    """Generate a unique username using the static UsernameGenerator methods"""
    max_attempts = 100
    for _ in range(max_attempts):
        # Generate username using static method
        username = UsernameGenerator.generate()
        
        # Check if it's unique in the database
        async with pool.acquire() as conn:
            existing_user = await conn.fetchrow(
                "SELECT username FROM users WHERE username = $1", username
            )
        
        if not existing_user:
            return username
    
    # Fallback if we can't find a unique username after max attempts
    raise HTTPException(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        detail="Unable to generate unique username after multiple attempts"
    )


# CENTRALIZED user creation function - ALL auth methods MUST use this
async def _create_new_user(
    pool: asyncpg.Pool,
    email: str = None,
    firebase_uid: str = None,
    google_id: str = None,
    apple_id: str = None,
    login_methods: list = None,
    preferred_login_method: str = "magic_link",
    profile_data: dict = None
) -> dict:
    """
    CENTRALIZED user creation with proper username and selection flag.
    ALL authentication methods MUST use this function.
    """
    if not login_methods:
        login_methods = ["magic_link"]
        
    # Generate a proper username using the existing username generator
    username = await _generate_unique_username(pool)
    user_id = uuid.uuid4()
    
    async with pool.acquire() as conn:
        await conn.execute("""
            INSERT INTO users (
                id, username, email, email_verified, firebase_uid, google_id, apple_id,
                social_profile_data, login_methods, preferred_login_method,
                needs_username_selection, created_at, last_login_at
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, FALSE, NOW(), NOW())
        """, user_id, username, email, bool(email), firebase_uid, google_id, apple_id,
             json.dumps(profile_data or {}), json.dumps(login_methods), preferred_login_method)
    
    return {
        "id": user_id,
        "username": username,
        "email": email or "",
        "email_verified": bool(email),
        "login_methods": login_methods,
        "needs_username_selection": False,
        "display_name": (profile_data or {}).get("name")
    }


# Pydantic Models for API
class UsernameGenerationResponse(BaseModel):
    """Response for username generation"""
    username: str
    alternatives: List[str]


class FirebaseUserRegistration(BaseModel):
    """Request for Firebase user registration with username"""
    username: str = Field(..., min_length=3, max_length=50, description="Desired username")
    email: Optional[str] = Field(None, description="Email address (optional)")
    display_name: Optional[str] = Field(None, description="Display name (optional)")
    alert_range_km: float = Field(50.0, ge=1, le=500, description="Alert range in kilometers")
    units_metric: bool = Field(True, description="Use metric units")
    preferred_language: str = Field("en", description="Preferred language code")


class UserProfileResponse(BaseModel):
    """Response for user profile data"""
    uid: str
    username: str
    email: Optional[str] = None
    phone_number: Optional[str] = None
    display_name: Optional[str] = None
    alert_range_km: float = 50.0
    units_metric: bool = True
    preferred_language: str = "en"
    is_verified: bool = False
    created_at: datetime
    last_active: Optional[datetime] = None

# Temporary models for backwards compatibility
class RecoveryRequest(BaseModel):
    email: Optional[str] = None
    phone: Optional[str] = None

class UserRegistrationRequest(BaseModel):
    device_id: str
    platform: str
    alert_range_km: float = 50.0
    units_metric: bool = True
    preferred_language: str = "en"
    username: Optional[str] = None
    email: Optional[str] = None

class UserRegistrationResponse(BaseModel):
    user_id: str
    username: str
    device_id: str
    is_new_user: bool
    message: str
    
    @validator('username')
    def validate_username(cls, v):
        if v is not None:
            is_valid, error = UsernameGenerator.is_valid_username(v)
            if not is_valid:
                raise ValueError(error)
        return v


# JWT Authentication dependency
async def get_current_user_from_jwt(token: Optional[HTTPAuthorizationCredentials] = Depends(security)):
    """Verify JWT token and return user information"""
    if not token:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authorization header required"
        )
    
    try:
        # Verify the JWT token
        payload = verify_access_token(token.credentials)
        user_id = payload.get("sub") or payload.get("user_id")
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid token payload"
            )
        
        # Get user information from database
        pool = await get_database_pool()
        async with pool.acquire() as conn:
            user = await conn.fetchrow("""
                SELECT id, username, email, display_name, is_active, is_verified,
                       alert_range_km, units_metric, preferred_language, created_at, last_login
                FROM users 
                WHERE id = $1 AND is_active = true
            """, uuid.UUID(user_id))
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found or inactive"
                )
            
            return user
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"JWT authentication failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid or expired token"
        )


@router.get("/me")
async def get_current_user(current_user = Depends(get_current_user_from_jwt)):
    """Get current user information from JWT token"""
    return {
        "success": True,
        "user": {
            "id": str(current_user["id"]),
            "username": current_user["username"],
            "email": current_user["email"],
            "display_name": current_user["display_name"],
            "is_active": current_user["is_active"],
            "is_verified": current_user["is_verified"],
            "alert_range_km": current_user["alert_range_km"],
            "units_metric": current_user["units_metric"],
            "preferred_language": current_user["preferred_language"],
            "created_at": current_user["created_at"].isoformat() if current_user["created_at"] else None,
            "last_login": current_user["last_login"].isoformat() if current_user["last_login"] else None
        }
    }


@router.put("/me/alert-range")
async def update_alert_range(
    request: Request,
    current_user = Depends(get_current_user_from_jwt)
):
    """Update user's alert range for proximity notifications"""
    from app.services.database_service import get_database_pool

    # Get alert_range_km from request body (sent as raw float)
    alert_range_km = await request.json()

    # Validate range
    if not isinstance(alert_range_km, (int, float)):
        raise HTTPException(
            status_code=422,
            detail="Alert range must be a number"
        )

    if not (1 <= alert_range_km <= 10000):
        raise HTTPException(
            status_code=400,
            detail="Alert range must be between 1 and 10000 km"
        )

    db = await get_database_pool()
    async with db.acquire() as conn:
        await conn.execute(
            "UPDATE users SET alert_range_km = $1 WHERE id = $2",
            float(alert_range_km),
            current_user["id"]
        )

    return {"success": True, "alert_range_km": alert_range_km}




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


class UserStatsResponse(BaseModel):
    """User statistics for MP13-6"""
    total_alerts_created: int
    total_witnesses_confirmed: int
    total_media_uploaded: int
    account_age_days: int
    recent_activity: dict
    visibility_settings: dict


class AlertHistoryResponse(BaseModel):
    """User alert history for MP13-6"""
    alerts: List[dict]
    total_count: int
    page: int
    per_page: int


class UsernameRegenerateRequest(BaseModel):
    """Request to regenerate username"""
    device_id: str
    force_regenerate: bool = False


class VisibilitySettingsRequest(BaseModel):
    """Privacy settings for alert visibility - MP13-6"""
    show_username_in_alerts: bool = True
    allow_witness_confirmations: bool = True
    public_profile_visible: bool = False
    alert_history_public: bool = False


# API Endpoints

@router.post("/generate-username", response_model=UsernameGenerationResponse)
async def generate_username(pool: asyncpg.Pool = Depends(get_db)):
    """
    Generate a new unique username with alternatives
    Returns cosmic-themed username like 'cosmic.whisper.7823'
    """
    try:
        # Generate primary unique username
        primary_username = await _generate_unique_username(pool)
        alternatives = []
        
        # Generate 4 alternative unique usernames
        for _ in range(4):
            try:
                alt_username = await _generate_unique_username(pool)
                if alt_username not in alternatives and alt_username != primary_username:
                    alternatives.append(alt_username)
            except HTTPException:
                # If we can't generate more unique alternatives, that's ok
                break
        
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
            # Use atomic transaction to prevent race conditions
            async with conn.transaction():
                # First, try to get existing device-user mapping with row lock
                existing_device = await conn.fetchrow(
                    "SELECT device_id, user_id FROM user_devices WHERE device_id = $1 FOR UPDATE",
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
                
                # If no existing device found, create new user atomically
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
                        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                        last_seen_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                    )
                """)
                
                # Store device mapping with JSON info (atomic insert)
                device_info = {
                    "platform": request.platform,
                    "device_name": getattr(request, 'device_name', 'Unknown'),
                    "app_version": getattr(request, 'app_version', '1.0.0'),
                    "os_version": getattr(request, 'os_version', 'Unknown')
                }
                
                try:
                    await conn.execute("""
                        INSERT INTO user_devices (device_id, user_id, device_info)
                        VALUES ($1, $2, $3)
                    """, request.device_id, user_id, json.dumps(device_info))
                except Exception as e:
                    # If device was inserted by another request, return that user instead
                    if "duplicate key" in str(e).lower():
                        # Get the existing user for this device
                        existing_device = await conn.fetchrow(
                            "SELECT user_id FROM user_devices WHERE device_id = $1",
                            request.device_id
                        )
                        if existing_device:
                            existing_user = await conn.fetchrow(
                                "SELECT id, username FROM users WHERE id = $1",
                                existing_device['user_id']
                            )
                            return UserRegistrationResponse(
                                user_id=str(existing_user['id']),
                                username=existing_user['username'],
                                device_id=request.device_id,
                                is_new_user=False,
                                message="Welcome back! Account recovered during race condition."
                            )
                    raise e
                
                # Migrate existing sightings from device_id to username (inside transaction)
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
                    
                    # Send verification email (async, don't wait - outside transaction)
                    try:
                        await email_service.send_verification_email(
                            request.email.strip(), username, token
                        )
                    except Exception as email_error:
                        print(f"Email sending failed: {email_error}")
                        # Don't fail registration due to email issues
                
                return UserRegistrationResponse(
                    user_id=str(user_id),
                    username=username,
                    device_id=request.device_id,
                    is_new_user=True,
                    message=f"Welcome to UFOBeep, {username}! (Migrated {migrated_count} existing alerts)"
                )
            
    except Exception as e:
        error_str = str(e).lower()
        
        # Handle specific database constraint violations
        if "username" in error_str and ("unique" in error_str or "duplicate" in error_str):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already taken. Please try generating a new one."
            )
        elif "email" in error_str and ("unique" in error_str or "duplicate" in error_str):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This email is already registered. Try account recovery or use a different email."
            )
        elif "device_id" in error_str and ("unique" in error_str or "duplicate" in error_str):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="This device is already registered. Try account recovery."
            )
        elif "duplicate key" in error_str or "violates unique constraint" in error_str:
            if "email" in error_str:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="This email is already registered. Try account recovery or use a different email."
                )
            elif "username" in error_str:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Username already taken. Please try generating a new one."
                )
            else:
                raise HTTPException(
                    status_code=status.HTTP_409_CONFLICT,
                    detail="Account already exists. Please try account recovery instead."
                )
        elif "connection" in error_str or "database" in error_str:
            raise HTTPException(
                status_code=status.HTTP_503_SERVICE_UNAVAILABLE,
                detail="Registration temporarily unavailable. Please try again in a moment."
            )
        else:
            # Generic error - don't expose technical details to users
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail="Registration failed. Please try again or contact support if the problem persists."
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


# MP13-6 Profile Management Endpoints

@router.get("/stats/{device_id}", response_model=UserStatsResponse)
async def get_user_stats(device_id: str):
    """
    Get user statistics for profile display - MP13-6
    Shows alert history, activity, and account information
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device ID
            user = await conn.fetchrow("""
                SELECT u.id, u.username, u.created_at, u.visibility_settings
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, device_id)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            user_id = user['id']
            
            # Get alert statistics
            alerts_stats = await conn.fetchrow("""
                SELECT 
                    COUNT(*) as total_alerts,
                    COUNT(CASE WHEN media_files != '[]' THEN 1 END) as media_alerts
                FROM sightings 
                WHERE reporter_id = $1::text
            """, str(user_id))
            
            # Get witness confirmation stats
            witness_stats = await conn.fetchrow("""
                SELECT COUNT(*) as confirmations
                FROM witness_confirmations 
                WHERE device_id = $1
            """, device_id)
            
            # Calculate account age
            from datetime import datetime
            account_age = (datetime.now() - user['created_at']).days
            
            # Recent activity (last 30 days)
            recent_activity = await conn.fetchrow("""
                SELECT 
                    COUNT(CASE WHEN created_at > NOW() - INTERVAL '30 days' THEN 1 END) as alerts_last_30_days,
                    COUNT(CASE WHEN created_at > NOW() - INTERVAL '7 days' THEN 1 END) as alerts_last_7_days
                FROM sightings 
                WHERE reporter_id = $1::text
            """, str(user_id))
            
            # Visibility settings
            visibility_settings = user['visibility_settings'] or {}
            if isinstance(visibility_settings, str):
                import json
                visibility_settings = json.loads(visibility_settings)
            
            return UserStatsResponse(
                total_alerts_created=alerts_stats['total_alerts'] or 0,
                total_witnesses_confirmed=witness_stats['confirmations'] or 0,
                total_media_uploaded=alerts_stats['media_alerts'] or 0,
                account_age_days=account_age,
                recent_activity={
                    "alerts_last_30_days": recent_activity['alerts_last_30_days'] or 0,
                    "alerts_last_7_days": recent_activity['alerts_last_7_days'] or 0
                },
                visibility_settings=visibility_settings
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get user stats: {str(e)}"
        )
    finally:
        pass


@router.get("/alerts/{device_id}", response_model=AlertHistoryResponse)
async def get_user_alert_history(device_id: str, page: int = 1, per_page: int = 20):
    """
    Get user's alert history for profile display - MP13-6
    Shows paginated list of user's created alerts
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device ID
            user = await conn.fetchrow("""
                SELECT u.id, u.username
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, device_id)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            user_id = str(user['id'])
            offset = (page - 1) * per_page
            
            # Get total count
            total_count = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings WHERE reporter_id = $1
            """, user_id)
            
            # Get paginated alerts
            alerts = await conn.fetch("""
                SELECT 
                    id, title, description, latitude, longitude,
                    location_name, media_files, created_at, alert_level,
                    is_verified, witness_count
                FROM sightings 
                WHERE reporter_id = $1
                ORDER BY created_at DESC
                LIMIT $2 OFFSET $3
            """, user_id, per_page, offset)
            
            # Format alerts for response
            formatted_alerts = []
            for alert in alerts:
                alert_dict = dict(alert)
                # Parse media_files JSON
                media_files = alert_dict.get('media_files', [])
                if isinstance(media_files, str):
                    import json
                    try:
                        media_files = json.loads(media_files)
                    except:
                        media_files = []
                
                alert_dict['media_files'] = media_files
                alert_dict['media_count'] = len(media_files)
                formatted_alerts.append(alert_dict)
            
            return AlertHistoryResponse(
                alerts=formatted_alerts,
                total_count=total_count or 0,
                page=page,
                per_page=per_page
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get alert history: {str(e)}"
        )
    finally:
        pass


@router.post("/set-username", response_model=UserRegistrationResponse)
async def set_username(request: dict, current_user = Depends(get_current_user_from_jwt)):
    """Set specific username for user"""
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        chosen_username = request['username']
        user_id = current_user['id']
        
        # Check if username is already taken
        existing = await conn.fetchrow(
            "SELECT username FROM users WHERE username = $1 AND id != $2",
            chosen_username, user_id
        )
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="Username already taken"
            )
        
        # Update username for authenticated user
        await conn.execute("""
            UPDATE users 
            SET username = $1, updated_at = NOW()
            WHERE id = $2
        """, chosen_username, user_id)
        
        return UserRegistrationResponse(
            user_id=str(user_id),
            username=chosen_username,
            device_id=request.get('device_id', ''),
            is_new_user=False,
            message=f"Username updated! You are now {chosen_username}"
        )

@router.post("/regenerate-username", response_model=UserRegistrationResponse)
async def regenerate_username(request: UsernameRegenerateRequest):
    """
    Regenerate username for existing user - MP13-6
    Allows users to get a new cosmic-themed username
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device ID
            user = await conn.fetchrow("""
                SELECT u.id, u.username
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, request.device_id)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            # Generate new unique username
            new_username = None
            for attempt in range(10):
                candidate = UsernameGenerator.generate()
                existing = await conn.fetchrow(
                    "SELECT username FROM users WHERE username = $1",
                    candidate
                )
                if not existing:
                    new_username = candidate
                    break
            
            if not new_username:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Unable to generate unique username"
                )
            
            # Update username
            await conn.execute("""
                UPDATE users 
                SET username = $1, updated_at = NOW()
                WHERE id = $2
            """, new_username, user['id'])
            
            return UserRegistrationResponse(
                user_id=str(user['id']),
                username=new_username,
                device_id=request.device_id,
                is_new_user=False,
                message=f"Username updated! You are now {new_username}"
            )
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to regenerate username: {str(e)}"
        )
    finally:
        pass


@router.post("/visibility-settings")
async def update_visibility_settings(device_id: str, settings: VisibilitySettingsRequest):
    """
    Update user privacy/visibility settings - MP13-6
    Controls how user information appears in alerts and public profiles
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device ID
            user = await conn.fetchrow("""
                SELECT u.id
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, device_id)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            # Convert settings to JSON
            settings_dict = {
                "show_username_in_alerts": settings.show_username_in_alerts,
                "allow_witness_confirmations": settings.allow_witness_confirmations,
                "public_profile_visible": settings.public_profile_visible,
                "alert_history_public": settings.alert_history_public,
                "updated_at": datetime.now().isoformat()
            }
            
            # Update visibility settings
            await conn.execute("""
                UPDATE users 
                SET visibility_settings = $1, updated_at = NOW()
                WHERE id = $2
            """, json.dumps(settings_dict), user['id'])
            
            return {
                "success": True,
                "message": "Privacy settings updated successfully",
                "settings": settings_dict
            }
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update visibility settings: {str(e)}"
        )
    finally:
        pass


@router.get("/visibility-settings/{device_id}")
async def get_visibility_settings(device_id: str):
    """
    Get current user visibility settings - MP13-6
    """
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            user = await conn.fetchrow("""
                SELECT u.visibility_settings
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, device_id)
            
            if not user:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail="User not found"
                )
            
            # Default settings if none exist
            default_settings = {
                "show_username_in_alerts": True,
                "allow_witness_confirmations": True,
                "public_profile_visible": False,
                "alert_history_public": False
            }
            
            current_settings = user['visibility_settings']
            if isinstance(current_settings, str):
                import json
                current_settings = json.loads(current_settings)
            
            # Merge with defaults
            settings = {**default_settings, **(current_settings or {})}
            
            return {
                "success": True,
                "settings": settings
            }
            
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get visibility settings: {str(e)}"
        )
    finally:
        pass



# MP15: Enhanced Authentication - Social Login Endpoints

class SocialLoginRequest(BaseModel):
    """Request for social login (Google/Apple)"""
    token: str = Field(..., description="OAuth ID token from social provider")
    device_id: str = Field(..., description="Device identifier") 
    platform: str = Field(..., description="Platform (android/ios)")
    user_id: Optional[str] = Field(None, description="Apple user ID (Apple Sign-In only)")


class MagicLinkRequest(BaseModel):
    """Request for magic link login"""
    email: str = Field(..., description="Email address")
    device_id: str = Field(..., description="Device identifier")


class SetPasswordRequest(BaseModel):
    """Request to set password for authenticated user"""
    password: str = Field(..., min_length=8, description="New password")
    device_id: str = Field(..., description="Device identifier")


@router.post("/auth/google")
async def google_login(request: SocialLoginRequest):
    """
    Authenticate with Google OAuth token - MP15
    Creates new account or links to existing account
    Returns standardized JWT response
    """
    social_service = SocialAuthService()
    
    # Verify Google token and extract profile
    profile = await social_service.verify_google_token(request.token)
    if not profile:
        raise HTTPException(status_code=400, detail="Invalid Google token")
    
    if not profile.get("email"):
        raise HTTPException(status_code=400, detail="Google account must have email")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            async with conn.transaction():
                # Check if user exists by email (case-insensitive)
                user = await conn.fetchrow("""
                    SELECT id, username, email, google_id, login_methods, email_verified, display_name
                    FROM users 
                    WHERE LOWER(email) = LOWER($1)
                    FOR UPDATE
                """, profile["email"])
                
                if user:
                    # Existing user - link Google account if not already linked
                    login_methods = user["login_methods"] if user["login_methods"] else ["magic_link"]
                    if isinstance(login_methods, str):
                        login_methods = json.loads(login_methods)
                    
                    # Update Google ID and verify email if needed
                    if not user["google_id"]:
                        await conn.execute("""
                            UPDATE users 
                            SET google_id = $1, social_profile_data = $2, email_verified = TRUE, last_login_at = NOW()
                            WHERE id = $3
                        """, profile["google_id"], json.dumps(profile), user["id"])
                    elif user["google_id"] != profile["google_id"]:
                        # Email linked to different Google account
                        raise HTTPException(
                            status_code=409, 
                            detail="This email is linked to a different Google account"
                        )
                    else:
                        # Just update last login
                        await conn.execute("""
                            UPDATE users SET last_login_at = NOW() WHERE id = $1
                        """, user["id"])
                    
                    # Add 'google' to login_methods if not present
                    if "google" not in login_methods:
                        login_methods.append("google")
                        await conn.execute("""
                            UPDATE users SET login_methods = $1 WHERE id = $2
                        """, json.dumps(login_methods), user["id"])
                    
                    # Create updated user dict for response
                    user_data = dict(user)
                    user_data["login_methods"] = login_methods
                    user_data["email_verified"] = True
                    
                else:
                    # New user - use centralized creation function
                    user_data = await _create_new_user(
                        pool=pool,
                        email=profile["email"],
                        google_id=profile["google_id"],
                        login_methods=["google", "magic_link"],
                        preferred_login_method="google",
                        profile_data=profile
                    )
                
                # Link device if not already linked
                await conn.execute("""
                    INSERT INTO user_devices (user_id, device_id, created_at)
                    VALUES ($1, $2, NOW())
                    ON CONFLICT (device_id) DO UPDATE SET 
                        user_id = EXCLUDED.user_id
                """, user_data["id"], request.device_id)
                
                # Create JWT tokens
                access_token = create_access_token(data={"sub": str(user_data["id"])})
                refresh_token = create_refresh_token(data={"sub": str(user_data["id"])})
                
                return standard_auth_response(user_data, access_token, refresh_token)
                
    finally:
        pass  # Shared pool - don't close


@router.post("/auth/firebase")
async def firebase_auth(
    request: SocialLoginRequest,
    firebase_user: FirebaseUser = RequiredAuth,
    pool: asyncpg.Pool = Depends(get_db)
):
    """
    Authenticate with Firebase ID token - MP15
    Creates new account or links to existing account automatically
    """
    try:
        async with pool.acquire() as conn:
            async with conn.transaction():
                # Check if user already exists by Firebase UID
                user = await conn.fetchrow("""
                    SELECT id, username, email, firebase_uid, login_methods, email_verified, display_name
                    FROM users
                    WHERE firebase_uid = $1
                    FOR UPDATE
                """, firebase_user.uid)

                if user:
                    # Existing user found by firebase_uid - update last_active
                    await conn.execute("""
                        UPDATE users
                        SET last_login_at = NOW()
                        WHERE id = $1
                    """, user["id"])

                    # Create JWT tokens for existing user
                    access_token = create_access_token(data={"sub": str(user["id"])})
                    refresh_token = create_refresh_token(data={"sub": str(user["id"])})

                    return standard_auth_response(dict(user), access_token, refresh_token)

                # Not found by firebase_uid - check if user exists by email (magic link case)
                if firebase_user.email:
                    user_by_email = await conn.fetchrow("""
                        SELECT id, username, email, firebase_uid, login_methods, email_verified, display_name
                        FROM users
                        WHERE LOWER(email) = LOWER($1)
                        FOR UPDATE
                    """, firebase_user.email)

                    if user_by_email:
                        # User exists with this email but no firebase_uid - link the account
                        login_methods = user_by_email["login_methods"] if user_by_email["login_methods"] else ["magic_link"]
                        if isinstance(login_methods, str):
                            login_methods = json.loads(login_methods)

                        if "firebase" not in login_methods:
                            login_methods.append("firebase")

                        # Update user with firebase_uid and login methods
                        await conn.execute("""
                            UPDATE users
                            SET firebase_uid = $1, login_methods = $2, email_verified = TRUE, last_login_at = NOW()
                            WHERE id = $3
                        """, firebase_user.uid, json.dumps(login_methods), user_by_email["id"])

                        # Create updated user dict for response
                        user_data = dict(user_by_email)
                        user_data["firebase_uid"] = firebase_user.uid
                        user_data["login_methods"] = login_methods
                        user_data["email_verified"] = True

                        # Create JWT tokens
                        access_token = create_access_token(data={"sub": str(user_data["id"])})
                        refresh_token = create_refresh_token(data={"sub": str(user_data["id"])})

                        return standard_auth_response(user_data, access_token, refresh_token)

                # No existing user found - create new user
                user_data = await _create_new_user(
                    pool=pool,
                    email=firebase_user.email or "",
                    firebase_uid=firebase_user.uid,
                    login_methods=["firebase"],
                    preferred_login_method="firebase"
                )

                # Create JWT tokens for new user
                access_token = create_access_token(data={"sub": str(user_data["id"])})
                refresh_token = create_refresh_token(data={"sub": str(user_data["id"])})

                return standard_auth_response(user_data, access_token, refresh_token)

    except Exception as e:
        logger.exception("Firebase authentication error")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Firebase authentication failed: {str(e)}"
        )


@router.post("/auth/apple")
async def apple_auth(
    request: SocialLoginRequest,
    pool: asyncpg.Pool = Depends(get_db)
):
    """
    Authenticate with Apple Sign-In - MP15
    Creates new account or links to existing account automatically
    Returns standardized JWT response
    """
    try:
        # Verify Apple token using social auth service
        social_service = SocialAuthService()
        profile = await social_service.verify_apple_token(request.token, request.user_id)
        
        if not profile:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail="Invalid Apple token"
            )
        
        email = profile.get("email")
        apple_id = profile.get("apple_id")
        
        async with pool.acquire() as conn:
            async with conn.transaction():
                # Check if user already exists by email (case-insensitive)
                user = await conn.fetchrow("""
                    SELECT id, username, email, login_methods, email_verified, display_name
                    FROM users 
                    WHERE LOWER(email) = LOWER($1)
                    FOR UPDATE
                """, email)
                
                if user:
                    # Existing user - update login methods and last_active
                    login_methods = user["login_methods"] if user["login_methods"] else ["magic_link"]
                    if isinstance(login_methods, str):
                        login_methods = json.loads(login_methods)
                    
                    if "apple" not in login_methods:
                        login_methods.append("apple")
                        await conn.execute("""
                            UPDATE users 
                            SET login_methods = $1, last_login_at = NOW(), email_verified = TRUE
                            WHERE id = $2
                        """, json.dumps(login_methods), user["id"])
                    else:
                        await conn.execute("""
                            UPDATE users SET last_login_at = NOW() WHERE id = $1
                        """, user["id"])
                    
                    # Create updated user dict for response
                    user_data = dict(user)
                    user_data["login_methods"] = login_methods
                    user_data["email_verified"] = True
                    
                else:
                    # New user - use centralized creation function
                    user_data = await _create_new_user(
                        pool=pool,
                        email=email,
                        apple_id=profile.get("apple_id", profile.get("sub")),
                        login_methods=["apple", "magic_link"],
                        preferred_login_method="apple",
                        profile_data=profile
                    )
                
                # Create JWT tokens
                access_token = create_access_token(data={"sub": str(user_data["id"])})
                refresh_token = create_refresh_token(data={"sub": str(user_data["id"])})
                
                return standard_auth_response(user_data, access_token, refresh_token)
                
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Apple authentication failed: {str(e)}"
        )


@router.post("/request-magic-link")
async def request_magic_link(request: MagicLinkRequest):
    """
    Send magic link to user's email for passwordless login - MP15
    """
    email = request.email.strip().lower()
    print(f"Magic link requested for email: {email}")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by email
            user = await conn.fetchrow("""
                SELECT id, username, email, email_verified
                FROM users 
                WHERE email = $1
            """, email)
            
            if not user:
                print(f"No user found for email: {email} - creating new user")
                # New user - use centralized creation function
                user_data = await _create_new_user(
                    pool=pool,
                    email=email,
                    login_methods=["magic_link"],
                    preferred_login_method="magic_link"
                )
                print(f"Created new user: {user_data['username']}")
                user = {
                    "id": user_data["id"],
                    "username": user_data["username"], 
                    "email": email,
                    "email_verified": user_data["email_verified"]
                }
            
            print(f"User ready: {user['username']} (verified: {user['email_verified']})")
            
            # Generate magic link token
            social_service = SocialAuthService()
            token, expiry = social_service.generate_magic_link_token()
            
            # Save token to database
            await conn.execute("""
                UPDATE users 
                SET magic_link_token = $1, magic_link_expires_at = $2
                WHERE id = $3
            """, token, expiry, user["id"])
            
            print(f"Token saved, sending email to {email}")
            
            # Send magic link email
            try:
                await social_service.send_magic_link_email(
                    email, user["username"], token
                )
                print(f"Magic link email sent successfully to {email}")
            except Exception as e:
                print(f"Failed to send magic link email: {e}")
                raise
            
            return {
                "success": True,
                "message": "Magic link sent to your email.",
                "expires_in_minutes": 15
            }
            
    finally:
        pass  # Shared pool - don't close


@router.post("/verify-magic-link")
async def verify_magic_link(request: dict):
    """
    Verify magic link token and log user in - MP15
    """
    token = request.get("token")
    if not token:
        raise HTTPException(status_code=400, detail="Token is required")
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by magic link token that hasn't expired
            user = await conn.fetchrow("""
                SELECT id, username, email, magic_link_token, magic_link_expires_at
                FROM users 
                WHERE magic_link_token = $1 AND magic_link_expires_at > NOW()
            """, token)
            
            if not user:
                return {
                    "success": False,
                    "message": "Invalid or expired magic link. Please request a new one."
                }
            
            # Clear the magic link token (one-time use)
            await conn.execute("""
                UPDATE users 
                SET magic_link_token = NULL, 
                    magic_link_expires_at = NULL,
                    email_verified = TRUE,
                    last_login_at = NOW()
                WHERE id = $1
            """, user["id"])
            
            # Get user login methods
            user_full = await conn.fetchrow("""
                SELECT id, username, email, email_verified, login_methods, needs_username_selection, display_name
                FROM users WHERE id = $1
            """, user["id"])
            
            # Create JWT tokens 
            access_token = create_access_token(data={"sub": str(user_full["id"])})
            refresh_token = create_refresh_token(data={"sub": str(user_full["id"])})
            
            # Return standardized auth response
            return standard_auth_response(dict(user_full), access_token, refresh_token)
            
    finally:
        pass  # Shared pool - don't close


@router.post("/set-password")
async def set_password(request: SetPasswordRequest):
    """
    Set password for authenticated user - MP15
    Requires user to be logged in via device_id
    """
    import bcrypt
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Find user by device_id
            user = await conn.fetchrow("""
                SELECT u.id, u.username, u.login_methods
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, request.device_id)
            
            if not user:
                raise HTTPException(status_code=404, detail="User not found or not logged in")
            
            # Hash password
            password_hash = bcrypt.hashpw(request.password.encode('utf-8'), bcrypt.gensalt())
            
            # Update user with password and add to login methods
            login_methods = user["login_methods"] if user["login_methods"] else ["magic_link"]
            if isinstance(login_methods, str):
                login_methods = json.loads(login_methods)
            if "password" not in login_methods:
                login_methods.append("password")
            
            await conn.execute("""
                UPDATE users 
                SET password_hash = $1, login_methods = $2, preferred_login_method = 'password'
                WHERE id = $3
            """, password_hash.decode('utf-8'), json.dumps(login_methods), user["id"])
            
            return {
                "success": True,
                "message": f"Password set for {user['username']}",
                "login_methods": login_methods
            }
            
    finally:
        pass  # Shared pool - don't close


@router.post("/link-phone")
async def link_phone_number(
    request: dict,
    firebase_user: FirebaseUser = RequiredAuth,
    db: asyncpg.Pool = Depends(get_db)
):
    """Link Firebase-verified phone number to user account"""
    phone = request.get("phone")
    if not phone:
        raise HTTPException(status_code=400, detail="Phone number required")
    
    result = await phone_service.link_phone_to_user(db, firebase_user.uid, phone)
    if not result["success"]:
        raise HTTPException(status_code=400, detail=result["error"])
    
    return result


@router.get("/{user_id}/subscriptions")
async def get_user_subscriptions(user_id: str, current_user = Depends(get_current_user_from_jwt)):
    """Get all alerts that a user is following for notifications"""
    # Only allow users to see their own subscriptions
    if str(current_user['id']) != user_id:
        raise HTTPException(status_code=403, detail="Access denied")
    
    pool = await get_database_pool()
    async with pool.acquire() as conn:
        # Get followed alerts with sighting details
        subscriptions = await conn.fetch("""
            SELECT
                f.sighting_id,
                f.created_at as followed_at,
                s.title,
                s.description,
                COALESCE(
                    enrichment_data->'geocoding'->>'display_name',
                    enrichment_data->'geocoding'->>'location',
                    enrichment_data->'geocoding'->>'location_name',
                    enrichment_data->'weather'->>'city',
                    enrichment_data->>'location_name',
                    'Unknown Location'
                ) as location_name,
                s.lat as latitude,
                s.lon as longitude,
                s.created_at as sighting_created_at,
                (SELECT COUNT(*) FROM comments c WHERE c.sighting_id = s.id) as comment_count
            FROM follows f
            JOIN sightings s ON f.sighting_id = s.id
            WHERE f.user_id = $1
            ORDER BY f.created_at DESC
        """, uuid.UUID(user_id))
        
        # Format subscriptions for response
        formatted_subs = []
        for sub in subscriptions:
            title = sub['title'] or 'UFOBeep Alert'
            
            formatted_subs.append({
                'sighting_id': str(sub['sighting_id']),
                'title': title,
                'location_name': sub['location_name'] or 'Unknown Location',
                'comment_count': sub['comment_count'],
                'followed_at': sub['followed_at'].isoformat(),
                'sighting_created_at': sub['sighting_created_at'].isoformat(),
            })
        
        return {
            'subscriptions': formatted_subs,
            'total_count': len(formatted_subs)
        }


@router.get("/export")
async def export_user_data(current_user = Depends(get_current_user_from_jwt)):
    """Export all user data for GDPR compliance"""
    user_id = str(current_user['id'])

    pool = await get_database_pool()
    async with pool.acquire() as conn:
        # Get user profile data
        user_data = await conn.fetchrow("""
            SELECT id, email, username, created_at, updated_at, display_name, bio,
                   preferred_language, units_metric, alert_range_km, min_alert_level,
                   push_notifications, email_notifications, share_location, public_profile
            FROM users WHERE id = $1
        """, uuid.UUID(user_id))

        if not user_data:
            raise HTTPException(status_code=404, detail="User not found")

        # Get user's sightings
        sightings = await conn.fetch("""
            SELECT id, title, description, created_at, category, witness_count,
                   status, source, occurred_at, sensor_data
            FROM sightings WHERE reporter_id = $1
            ORDER BY created_at DESC
        """, user_id)

        # Get user's comments
        comments = await conn.fetch("""
            SELECT c.id, c.body, c.created_at, s.title as sighting_title
            FROM comments c
            JOIN sightings s ON c.sighting_id = s.id
            WHERE c.user_id = $1
            ORDER BY c.created_at DESC
        """, user_id)

        # Get user's follows
        follows = await conn.fetch("""
            SELECT f.sighting_id, f.created_at, s.title as sighting_title
            FROM follows f
            JOIN sightings s ON f.sighting_id = s.id
            WHERE f.user_id = $1
            ORDER BY f.created_at DESC
        """, user_id)

        # Format export data
        export_data = {
            'user_profile': {
                'id': str(user_data['id']),
                'email': user_data['email'],
                'username': user_data['username'],
                'display_name': user_data['display_name'],
                'bio': user_data['bio'],
                'created_at': user_data['created_at'].isoformat(),
                'updated_at': user_data['updated_at'].isoformat() if user_data['updated_at'] else None,
                'preferred_language': user_data['preferred_language'],
                'units_metric': user_data['units_metric'],
                'alert_range_km': float(user_data['alert_range_km']) if user_data['alert_range_km'] else None,
                'min_alert_level': user_data['min_alert_level'],
                'push_notifications': user_data['push_notifications'],
                'email_notifications': user_data['email_notifications'],
                'share_location': user_data['share_location'],
                'public_profile': user_data['public_profile']
            },
            'sightings': [
                {
                    'id': str(s['id']),
                    'title': s['title'],
                    'description': s['description'],
                    'sensor_data': s['sensor_data'],
                    'created_at': s['created_at'].isoformat(),
                    'category': s['category'],
                    'witness_count': s['witness_count'],
                    'status': s['status'],
                    'source': s['source'],
                    'occurred_at': s['occurred_at'].isoformat() if s['occurred_at'] else None
                }
                for s in sightings
            ],
            'comments': [
                {
                    'id': str(c['id']),
                    'body': c['body'],
                    'created_at': c['created_at'].isoformat(),
                    'sighting_title': c['sighting_title']
                }
                for c in comments
            ],
            'follows': [
                {
                    'sighting_id': str(f['sighting_id']),
                    'followed_at': f['created_at'].isoformat(),
                    'sighting_title': f['sighting_title']
                }
                for f in follows
            ],
            'export_metadata': {
                'export_date': datetime.utcnow().isoformat(),
                'export_version': '1.0',
                'total_sightings': len(sightings),
                'total_comments': len(comments),
                'total_follows': len(follows)
            }
        }

        return export_data


@router.delete("/delete")
async def delete_user_account(current_user = Depends(get_current_user_from_jwt)):
    """Permanently delete user account and all associated data"""
    user_id = str(current_user['id'])

    pool = await get_database_pool()
    async with pool.acquire() as conn:
        async with conn.transaction():
            # Verify user exists
            user_exists = await conn.fetchval("""
                SELECT EXISTS(SELECT 1 FROM users WHERE id = $1)
            """, uuid.UUID(user_id))

            if not user_exists:
                raise HTTPException(status_code=404, detail="User not found")

            # Get user's sightings to delete related data
            user_sightings = await conn.fetch("""
                SELECT id FROM sightings WHERE reporter_id = $1
            """, user_id)

            sighting_ids = [str(s['id']) for s in user_sightings]

            # Delete in correct order to avoid foreign key constraints
            if sighting_ids:
                # Delete follows for user's sightings
                await conn.execute("""
                    DELETE FROM follows WHERE sighting_id = ANY($1)
                """, sighting_ids)

                # Delete comments on user's sightings
                await conn.execute("""
                    DELETE FROM comments WHERE sighting_id = ANY($1)
                """, sighting_ids)

                # Delete media files for user's sightings
                await conn.execute("""
                    DELETE FROM media_files WHERE sighting_id = ANY($1)
                """, sighting_ids)

            # Delete user's comments on other sightings
            await conn.execute("""
                DELETE FROM comments WHERE user_id = $1
            """, user_id)

            # Delete user's follows of other sightings
            await conn.execute("""
                DELETE FROM follows WHERE user_id = $1
            """, user_id)

            # Delete user's sightings
            await conn.execute("""
                DELETE FROM sightings WHERE reporter_id = $1
            """, user_id)

            # Finally delete the user
            await conn.execute("""
                DELETE FROM users WHERE id = $1
            """, uuid.UUID(user_id))

        return {"message": "Account deleted successfully"}