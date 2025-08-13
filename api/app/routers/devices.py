from datetime import datetime
from typing import List, Optional
from uuid import uuid4
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field

from app.config.environment import settings

logger = logging.getLogger(__name__)

# Import shared models
import sys
import os
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..', '..', 'shared', 'api-contracts'))

try:
    from app.models.sighting import Device, DevicePlatform, PushProvider, User
except ImportError:
    logger.warning("Could not import Device models, using local definitions")
    # Fallback to local definitions if models not available
    from pydantic import BaseModel
    from enum import Enum
    
    class DevicePlatform(str, Enum):
        ios = "ios"
        android = "android"
        web = "web"
    
    class PushProvider(str, Enum):
        fcm = "fcm"
        apns = "apns"
        webpush = "webpush"


# Request/Response models
class DeviceRegistrationRequest(BaseModel):
    device_id: str = Field(..., description="Unique device identifier")
    device_name: Optional[str] = Field(None, description="User-friendly device name")
    platform: DevicePlatform = Field(..., description="Device platform")
    
    # Device information
    app_version: Optional[str] = Field(None, description="App version")
    os_version: Optional[str] = Field(None, description="Operating system version")
    device_model: Optional[str] = Field(None, description="Device model")
    manufacturer: Optional[str] = Field(None, description="Device manufacturer")
    
    # Push notification configuration
    push_token: Optional[str] = Field(None, description="Push notification token")
    push_provider: Optional[PushProvider] = Field(None, description="Push provider")
    
    # Preferences
    alert_notifications: bool = Field(default=True, description="Enable alert notifications")
    chat_notifications: bool = Field(default=True, description="Enable chat notifications")
    system_notifications: bool = Field(default=True, description="Enable system notifications")
    
    # Locale settings
    timezone: Optional[str] = Field(None, description="Device timezone")
    locale: Optional[str] = Field(None, description="Device locale")


class DeviceUpdateRequest(BaseModel):
    device_name: Optional[str] = None
    push_token: Optional[str] = None
    push_provider: Optional[PushProvider] = None
    push_enabled: Optional[bool] = None
    alert_notifications: Optional[bool] = None
    chat_notifications: Optional[bool] = None
    system_notifications: Optional[bool] = None
    app_version: Optional[str] = None
    os_version: Optional[str] = None
    timezone: Optional[str] = None
    locale: Optional[str] = None


class DeviceResponse(BaseModel):
    id: str
    device_id: str
    device_name: Optional[str]
    platform: DevicePlatform
    app_version: Optional[str]
    os_version: Optional[str]
    device_model: Optional[str]
    manufacturer: Optional[str]
    push_enabled: bool
    alert_notifications: bool
    chat_notifications: bool
    system_notifications: bool
    is_active: bool
    last_seen: Optional[str]
    timezone: Optional[str]
    locale: Optional[str]
    notifications_sent: int
    notifications_opened: int
    registered_at: str
    updated_at: str


class DeviceListResponse(BaseModel):
    success: bool
    data: List[DeviceResponse]
    total_count: int
    timestamp: str


class DeviceDetailResponse(BaseModel):
    success: bool
    data: DeviceResponse
    timestamp: str


# Router configuration
router = APIRouter(
    prefix="/devices",
    tags=["devices"],
    responses={
        404: {"description": "Device not found"},
        400: {"description": "Bad request"},
        403: {"description": "Access denied"},
        422: {"description": "Validation error"},
    }
)

security = HTTPBearer(auto_error=False)

# Database imports
import asyncpg

# Database connection (using global db_pool from main.py)
db_pool = None

def get_db_pool():
    """Get database pool from main.py"""
    from app.main import db_pool as main_db_pool
    return main_db_pool

# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    if token and token.credentials:
        # TODO: Implement actual JWT validation
        return "anonymous_user"
    return None


async def get_or_create_anonymous_user(device_id: str) -> str:
    """Create or find anonymous user for device registration"""
    db_pool = get_db_pool()
    if not db_pool:
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={"error": "DATABASE_UNAVAILABLE", "message": "Database connection unavailable"}
        )
    
    async with db_pool.acquire() as conn:
        # Look for existing anonymous user for this device
        existing_user = await conn.fetchval(
            """
            SELECT u.id FROM users u
            JOIN devices d ON u.id = d.user_id
            WHERE d.device_id = $1 AND u.username LIKE 'anon_%'
            AND d.is_active = true
            LIMIT 1
            """,
            device_id
        )
        
        if existing_user:
            return str(existing_user)
        
        # Create new anonymous user
        anonymous_username = f"anon_{device_id[:8]}_{int(datetime.utcnow().timestamp())}"
        
        user_id = await conn.fetchval(
            """
            INSERT INTO users (
                username, display_name, alert_range_km, min_alert_level,
                push_notifications, email_notifications, is_active
            ) VALUES (
                $1, $2, 50.0, 'low', true, false, true
            ) RETURNING id
            """,
            anonymous_username,
            f"Anonymous User"
        )
        
        logger.info(f"Created anonymous user {anonymous_username} for device {device_id}")
        return str(user_id)


def create_device_response(device_data: dict) -> DeviceResponse:
    """Convert device data to API response format"""
    return DeviceResponse(
        id=str(device_data["id"]),
        device_id=device_data["device_id"],
        device_name=device_data.get("device_name"),
        platform=DevicePlatform(device_data["platform"]),
        app_version=device_data.get("app_version"),
        os_version=device_data.get("os_version"),
        device_model=device_data.get("device_model"),
        manufacturer=device_data.get("manufacturer"),
        push_enabled=device_data["push_enabled"],
        alert_notifications=device_data["alert_notifications"],
        chat_notifications=device_data["chat_notifications"],
        system_notifications=device_data["system_notifications"],
        is_active=device_data["is_active"],
        last_seen=device_data["last_seen"].isoformat() if device_data.get("last_seen") else None,
        timezone=device_data.get("timezone"),
        locale=device_data.get("locale"),
        notifications_sent=device_data.get("notifications_sent", 0),
        notifications_opened=device_data.get("notifications_opened", 0),
        registered_at=device_data["registered_at"].isoformat(),
        updated_at=device_data["updated_at"].isoformat(),
    )


# Endpoints
@router.post("/register", response_model=DeviceDetailResponse)
async def register_device(
    request: DeviceRegistrationRequest,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Register or update a device for push notifications
    
    This endpoint handles device registration and token updates.
    If the device already exists, it will be updated with new information.
    Creates anonymous users automatically for devices without authentication.
    """
    try:
        # If no user_id, create or find anonymous user for this device
        if not user_id:
            user_id = await get_or_create_anonymous_user(request.device_id)
        
        db_pool = get_db_pool()
        if not db_pool:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "DATABASE_UNAVAILABLE", "message": "Database connection unavailable"}
            )
        
        current_time = datetime.utcnow()
        
        async with db_pool.acquire() as conn:
            # Check if device already exists for this user
            existing_device = await conn.fetchrow(
                """
                SELECT id, device_name, token_updated_at, created_at
                FROM devices 
                WHERE user_id = $1 AND device_id = $2 AND is_active = true
                """,
                user_id, request.device_id
            )
            
            if existing_device:
                # Update existing device
                device_record_id = existing_device['id']
                await conn.execute(
                    """
                    UPDATE devices SET
                        device_name = COALESCE($1, device_name),
                        app_version = $2,
                        os_version = $3,
                        push_token = $4,
                        push_provider = $5,
                        alert_notifications = $6,
                        chat_notifications = $7,
                        system_notifications = $8,
                        timezone = $9,
                        locale = $10,
                        last_seen = $11,
                        updated_at = $11,
                        token_updated_at = CASE WHEN $4 IS NOT NULL THEN $11 ELSE token_updated_at END,
                        is_active = true
                    WHERE id = $12
                    """,
                    request.device_name,
                    request.app_version,
                    request.os_version,
                    request.push_token,
                    request.push_provider.value if request.push_provider else None,
                    request.alert_notifications,
                    request.chat_notifications,
                    request.system_notifications,
                    request.timezone,
                    request.locale,
                    current_time,
                    device_record_id
                )
                
                logger.info(f"Updated device {request.device_id} for user {user_id}")
                
            else:
                # Create new device
                device_record_id = await conn.fetchval(
                    """
                    INSERT INTO devices (
                        user_id, device_id, device_name, platform,
                        app_version, os_version, device_model, manufacturer,
                        push_token, push_provider, push_enabled,
                        alert_notifications, chat_notifications, system_notifications,
                        is_active, last_seen, timezone, locale,
                        notifications_sent, notifications_opened,
                        registered_at, token_updated_at, created_at, updated_at
                    ) VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11,
                        $12, $13, $14, $15, $16, $17, $18, $19, $20,
                        $21, $22, $21, $21
                    ) RETURNING id
                    """,
                    user_id,
                    request.device_id,
                    request.device_name,
                    request.platform.value,
                    request.app_version,
                    request.os_version,
                    request.device_model,
                    request.manufacturer,
                    request.push_token,
                    request.push_provider.value if request.push_provider else None,
                    True,  # push_enabled
                    request.alert_notifications,
                    request.chat_notifications,
                    request.system_notifications,
                    True,  # is_active
                    current_time,  # last_seen
                    request.timezone,
                    request.locale,
                    0,  # notifications_sent
                    0,  # notifications_opened
                    current_time,  # registered_at (parameter 21)
                    current_time   # token_updated_at (parameter 22)
                )
                
                logger.info(f"Registered new device {request.device_id} for user {user_id}")
            
            # Fetch the complete device record for response
            device_record = await conn.fetchrow(
                """
                SELECT id, user_id, device_id, device_name, platform,
                       app_version, os_version, device_model, manufacturer,
                       push_token, push_provider, push_enabled,
                       alert_notifications, chat_notifications, system_notifications,
                       is_active, last_seen, timezone, locale,
                       notifications_sent, notifications_opened,
                       registered_at, token_updated_at, created_at, updated_at
                FROM devices WHERE id = $1
                """,
                device_record_id
            )
            
            # Convert database record to response format
            device_data = dict(device_record)
            device_response = create_device_response(device_data)
        
        return DeviceDetailResponse(
            success=True,
            data=device_response,
            timestamp=current_time.isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to register device: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "DEVICE_REGISTRATION_FAILED",
                "message": "Failed to register device"
            }
        )


@router.get("", response_model=DeviceListResponse)
async def list_user_devices(user_id: Optional[str] = Depends(get_current_user_id)):
    """
    List all devices registered for the authenticated user
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required"
                }
            )
        
        db_pool = get_db_pool()
        if not db_pool:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "DATABASE_UNAVAILABLE", "message": "Database connection unavailable"}
            )
        
        async with db_pool.acquire() as conn:
            device_records = await conn.fetch(
                """
                SELECT id, user_id, device_id, device_name, platform,
                       app_version, os_version, device_model, manufacturer,
                       push_token, push_provider, push_enabled,
                       alert_notifications, chat_notifications, system_notifications,
                       is_active, last_seen, timezone, locale,
                       notifications_sent, notifications_opened,
                       registered_at, token_updated_at, created_at, updated_at
                FROM devices 
                WHERE user_id = $1 AND is_active = true
                ORDER BY registered_at DESC
                """,
                user_id
            )
            
            devices = []
            for record in device_records:
                device_data = dict(record)
                devices.append(create_device_response(device_data))
        
        logger.info(f"Retrieved {len(devices)} devices for user {user_id}")
        
        return DeviceListResponse(
            success=True,
            data=devices,
            total_count=len(devices),
            timestamp=datetime.utcnow().isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to list devices: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "DEVICE_LIST_FAILED",
                "message": "Failed to retrieve devices"
            }
        )


@router.put("/{device_id}", response_model=DeviceDetailResponse)
async def update_device(
    device_id: str,
    request: DeviceUpdateRequest,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Update device settings and push token
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required"
                }
            )
        
        db_pool = get_db_pool()
        if not db_pool:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "DATABASE_UNAVAILABLE", "message": "Database connection unavailable"}
            )
        
        current_time = datetime.utcnow()
        
        async with db_pool.acquire() as conn:
            # Find device by device_id and verify ownership
            target_device = await conn.fetchrow(
                """
                SELECT id FROM devices 
                WHERE user_id = $1 AND device_id = $2 AND is_active = true
                """,
                user_id, device_id
            )
            
            if not target_device:
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={
                        "error": "DEVICE_NOT_FOUND",
                        "message": f"Device {device_id} not found for user"
                    }
                )
            
            target_device_id = target_device['id']
            
            # Build update query dynamically based on provided fields
            update_fields = request.dict(exclude_unset=True)
            if update_fields:
                set_clauses = []
                params = []
                param_idx = 1
                
                for field, value in update_fields.items():
                    if field == "push_provider" and value:
                        set_clauses.append(f"push_provider = ${param_idx}")
                        params.append(value.value)
                    else:
                        set_clauses.append(f"{field} = ${param_idx}")
                        params.append(value)
                    param_idx += 1
                
                # Always update timestamps
                set_clauses.append(f"updated_at = ${param_idx}")
                params.append(current_time)
                param_idx += 1
                
                set_clauses.append(f"last_seen = ${param_idx}")
                params.append(current_time)
                param_idx += 1
                
                # Update token timestamp if push_token was provided
                if "push_token" in update_fields:
                    set_clauses.append(f"token_updated_at = ${param_idx}")
                    params.append(current_time)
                    param_idx += 1
                
                # Add device ID as final parameter
                params.append(target_device_id)
                
                query = f"""
                UPDATE devices SET {', '.join(set_clauses)}
                WHERE id = ${param_idx}
                """
                
                await conn.execute(query, *params)
            
            # Fetch updated device record
            device_record = await conn.fetchrow(
                """
                SELECT id, user_id, device_id, device_name, platform,
                       app_version, os_version, device_model, manufacturer,
                       push_token, push_provider, push_enabled,
                       alert_notifications, chat_notifications, system_notifications,
                       is_active, last_seen, timezone, locale,
                       notifications_sent, notifications_opened,
                       registered_at, token_updated_at, created_at, updated_at
                FROM devices WHERE id = $1
                """,
                target_device_id
            )
            
            device_data = dict(device_record)
            device_response = create_device_response(device_data)
        
        logger.info(f"Updated device {device_id} for user {user_id}")
        
        return DeviceDetailResponse(
            success=True,
            data=device_response,
            timestamp=current_time.isoformat()
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to update device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "DEVICE_UPDATE_FAILED",
                "message": "Failed to update device"
            }
        )


@router.delete("/{device_id}")
async def unregister_device(
    device_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Unregister a device (mark as inactive)
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required"
                }
            )
        
        db_pool = get_db_pool()
        if not db_pool:
            raise HTTPException(
                status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                detail={"error": "DATABASE_UNAVAILABLE", "message": "Database connection unavailable"}
            )
        
        current_time = datetime.utcnow()
        
        async with db_pool.acquire() as conn:
            # Find and deactivate device
            result = await conn.execute(
                """
                UPDATE devices SET 
                    is_active = false, 
                    updated_at = $1
                WHERE user_id = $2 AND device_id = $3 AND is_active = true
                """,
                current_time, user_id, device_id
            )
            
            # Check if any rows were affected
            if result == "UPDATE 0":
                raise HTTPException(
                    status_code=status.HTTP_404_NOT_FOUND,
                    detail={
                        "error": "DEVICE_NOT_FOUND",
                        "message": f"Device {device_id} not found"
                    }
                )
        
        logger.info(f"Unregistered device {device_id} for user {user_id}")
        
        return {
            "success": True,
            "message": "Device unregistered successfully",
            "timestamp": current_time.isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to unregister device {device_id}: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "DEVICE_UNREGISTER_FAILED",
                "message": "Failed to unregister device"
            }
        )


@router.post("/{device_id}/heartbeat")
async def device_heartbeat(
    device_id: str,
    user_id: Optional[str] = Depends(get_current_user_id)
):
    """
    Update device last seen timestamp (heartbeat)
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required"
                }
            )
        
        db_pool = get_db_pool()
        current_time = datetime.utcnow()
        
        if db_pool:
            async with db_pool.acquire() as conn:
                await conn.execute(
                    """
                    UPDATE devices SET last_seen = $1 
                    WHERE user_id = $2 AND device_id = $3 AND is_active = true
                    """,
                    current_time, user_id, device_id
                )
        
        return {
            "success": True,
            "timestamp": current_time.isoformat()
        }
        
    except Exception as e:
        logger.error(f"Failed to update device heartbeat: {e}")
        return {
            "success": False,
            "timestamp": datetime.utcnow().isoformat()
        }


# Health check
@router.get("/health")
async def devices_health_check():
    """Check devices service health"""
    try:
        db_pool = get_db_pool()
        if not db_pool:
            return {
                "status": "unhealthy",
                "error": "Database unavailable",
                "timestamp": datetime.utcnow().isoformat()
            }
        
        async with db_pool.acquire() as conn:
            # Get device counts
            total_devices = await conn.fetchval(
                "SELECT COUNT(*) FROM devices"
            )
            active_devices = await conn.fetchval(
                "SELECT COUNT(*) FROM devices WHERE is_active = true"
            )
        
        return {
            "status": "healthy",
            "total_devices": total_devices,
            "active_devices": active_devices,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }