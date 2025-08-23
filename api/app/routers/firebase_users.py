"""
Firebase User Management API
Handles user registration and profile management with Firebase Authentication
Replaces device ID system with Firebase UID + username system
"""

from fastapi import APIRouter, HTTPException, Depends, status
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime
import asyncpg
import uuid

from app.services.username_service import UsernameGenerator
from app.services.database_service import get_database_pool
from app.middleware.firebase_auth import FirebaseUser, OptionalAuth, RequiredAuth

router = APIRouter(prefix="/firebase-users", tags=["firebase-users"])

# Database dependency
async def get_db() -> asyncpg.Pool:
    return await get_database_pool()

# Pydantic Models
class UsernameRequest(BaseModel):
    """Request to set username for Firebase user"""
    username: str = Field(..., min_length=3, max_length=50, description="Desired username")

class ProfileUpdateRequest(BaseModel):
    """Request to update user profile"""
    display_name: Optional[str] = Field(None, max_length=100)
    alert_range_km: Optional[float] = Field(None, ge=1, le=500)
    units_metric: Optional[bool] = None
    preferred_language: Optional[str] = Field(None, max_length=5)

class UserProfileResponse(BaseModel):
    """Response for user profile"""
    uid: str
    username: Optional[str] = None
    email: Optional[str] = None
    phone_number: Optional[str] = None
    display_name: Optional[str] = None
    alert_range_km: float = 50.0
    units_metric: bool = True
    preferred_language: str = "en"
    email_verified: bool = False
    phone_verified: bool = False
    created_at: datetime
    last_active: Optional[datetime] = None

@router.post("/set-username")
async def set_username(
    request: UsernameRequest,
    firebase_user: FirebaseUser = RequiredAuth,
    db: asyncpg.Pool = Depends(get_db)
):
    """Set username for authenticated Firebase user"""
    try:
        username_generator = UsernameGenerator()
        
        # Validate username availability
        if not await username_generator.is_username_available(request.username, db):
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail=f"Username '{request.username}' is already taken"
            )
        
        # Check if user already has a username
        existing = await db.fetchrow(
            "SELECT username FROM users WHERE firebase_uid = $1",
            firebase_user.uid
        )
        
        if existing:
            raise HTTPException(
                status_code=status.HTTP_409_CONFLICT,
                detail="User already has a username. Use update endpoint to change it."
            )
        
        # Insert new user record
        await db.execute("""
            INSERT INTO users (
                firebase_uid, username, email, phone_number, 
                created_at, last_active, alert_range_km, 
                units_metric, preferred_language
            ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
        """, 
            firebase_user.uid,
            request.username,
            firebase_user.email,
            firebase_user.phone,
            datetime.utcnow(),
            datetime.utcnow(),
            50.0,  # default alert range
            True,  # default metric units
            "en"   # default language
        )
        
        return {
            "success": True,
            "message": f"Username '{request.username}' set successfully",
            "uid": firebase_user.uid,
            "username": request.username
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to set username: {str(e)}"
        )

@router.get("/profile", response_model=UserProfileResponse)
async def get_profile(
    firebase_user: FirebaseUser = RequiredAuth,
    db: asyncpg.Pool = Depends(get_db)
):
    """Get user profile by Firebase UID"""
    try:
        user_record = await db.fetchrow("""
            SELECT 
                firebase_uid, username, email, phone_number, 
                display_name, alert_range_km, units_metric, 
                preferred_language, email_verified, phone_verified,
                created_at, last_active
            FROM users 
            WHERE firebase_uid = $1
        """, firebase_user.uid)
        
        if not user_record:
            # User exists in Firebase but not in our database yet
            # This is normal for new anonymous users
            return UserProfileResponse(
                uid=firebase_user.uid,
                username=None,
                email=firebase_user.email,
                phone_number=firebase_user.phone,
                created_at=datetime.utcnow()
            )
        
        return UserProfileResponse(
            uid=user_record['firebase_uid'],
            username=user_record['username'],
            email=user_record['email'],
            phone_number=user_record['phone_number'],
            display_name=user_record['display_name'],
            alert_range_km=float(user_record['alert_range_km']),
            units_metric=user_record['units_metric'],
            preferred_language=user_record['preferred_language'],
            email_verified=user_record['email_verified'] or False,
            phone_verified=user_record['phone_verified'] or False,
            created_at=user_record['created_at'],
            last_active=user_record['last_active']
        )
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to get profile: {str(e)}"
        )

@router.put("/profile")
async def update_profile(
    request: ProfileUpdateRequest,
    firebase_user: FirebaseUser = RequiredAuth,
    db: asyncpg.Pool = Depends(get_db)
):
    """Update user profile"""
    try:
        # Build update query dynamically
        update_fields = []
        values = []
        param_count = 1
        
        if request.display_name is not None:
            update_fields.append(f"display_name = ${param_count}")
            values.append(request.display_name)
            param_count += 1
            
        if request.alert_range_km is not None:
            update_fields.append(f"alert_range_km = ${param_count}")
            values.append(request.alert_range_km)
            param_count += 1
            
        if request.units_metric is not None:
            update_fields.append(f"units_metric = ${param_count}")
            values.append(request.units_metric)
            param_count += 1
            
        if request.preferred_language is not None:
            update_fields.append(f"preferred_language = ${param_count}")
            values.append(request.preferred_language)
            param_count += 1
        
        if not update_fields:
            raise HTTPException(
                status_code=status.HTTP_400_BAD_REQUEST,
                detail="No fields to update"
            )
        
        # Add last_active update
        update_fields.append(f"last_active = ${param_count}")
        values.append(datetime.utcnow())
        param_count += 1
        
        # Add UID for WHERE clause
        values.append(firebase_user.uid)
        
        query = f"""
            UPDATE users 
            SET {', '.join(update_fields)}
            WHERE firebase_uid = ${param_count}
        """
        
        result = await db.execute(query, *values)
        
        if result == "UPDATE 0":
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail="User profile not found"
            )
        
        return {
            "success": True,
            "message": "Profile updated successfully"
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to update profile: {str(e)}"
        )

@router.post("/username/generate")
async def generate_username(db: asyncpg.Pool = Depends(get_db)):
    """Generate username suggestions (public endpoint)"""
    try:
        username_generator = UsernameGenerator()
        username_response = await username_generator.generate_username(db)
        
        return {
            "username": username_response["username"],
            "alternatives": username_response["alternatives"]
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to generate username: {str(e)}"
        )

@router.post("/username/validate")
async def validate_username(
    request: UsernameRequest,
    db: asyncpg.Pool = Depends(get_db)
):
    """Validate username availability (public endpoint)"""
    try:
        username_generator = UsernameGenerator()
        
        # Check format
        if not username_generator.is_valid_format(request.username):
            return {
                "valid": False,
                "available": False,
                "message": "Username must be 3-50 characters, letters, numbers, dots, dashes only"
            }
        
        # Check availability  
        available = await username_generator.is_username_available(request.username, db)
        
        return {
            "valid": True,
            "available": available,
            "message": "Username is available" if available else "Username is already taken"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to validate username: {str(e)}"
        )

@router.delete("/account")
async def delete_account(
    firebase_user: FirebaseUser = RequiredAuth,
    db: asyncpg.Pool = Depends(get_db)
):
    """Delete user account and all associated data"""
    try:
        # Delete user data (cascade should handle related records)
        result = await db.execute(
            "DELETE FROM users WHERE firebase_uid = $1",
            firebase_user.uid
        )
        
        return {
            "success": True,
            "message": "Account deleted successfully"
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Failed to delete account: {str(e)}"
        )