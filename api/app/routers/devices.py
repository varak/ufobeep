from datetime import datetime, timezone
from typing import List, Optional
from uuid import uuid4
import logging

from fastapi import APIRouter, Depends, HTTPException, status
from fastapi.security import HTTPBearer
from sqlalchemy.orm import Session
from pydantic import BaseModel, Field, validator

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
    
    # Location coordinates (required for proximity alerts)
    lat: float = Field(..., ge=-90, le=90, description="Device latitude")
    lon: float = Field(..., ge=-180, le=180, description="Device longitude")
    
    @validator('lon')
    def validate_not_origin(cls, v, values):
        lat = values.get('lat', 0)
        if abs(lat) < 0.0001 and abs(v) < 0.0001:
            raise ValueError('Invalid coordinates (0,0) - device registration requires valid location')
        return v


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
    # Alert preferences
    alert_range_km: Optional[float] = Field(None, ge=1.0, le=100.0, description="Alert range in kilometers")
    # DND / Snooze
    snooze_until: Optional[str] = Field(None, description="Global snooze until ISO timestamp (UTC). Null to clear.")
    # User preferences (Flutter format)
    preferences: Optional[dict] = Field(None, description="User preferences including DND/quiet hours")


class UpdateLocationIn(BaseModel):
    lat: float = Field(..., ge=-90, le=90, description="Device latitude")  
    lon: float = Field(..., ge=-180, le=180, description="Device longitude")
    
    @validator('lon')
    def validate_not_origin(cls, v, values):
        lat = values.get('lat', 0)
        if abs(lat) < 0.0001 and abs(v) < 0.0001:
            raise ValueError('Invalid coordinates (0,0)')
        return v


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

# Database dependency - now uses shared pool
async def get_db():
    """Get database connection pool from service"""
    from app.services.database_service import get_database_pool
    return await get_database_pool()

# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token"""
    if not token or not token.credentials:
        return None
    
    try:
        from app.core.auth import verify_access_token
        payload = verify_access_token(token.credentials)
        # JWT uses "sub" (subject) field for user ID, not "user_id"
        user_id = payload.get("sub") or payload.get("user_id")
        if user_id:
            logger.debug(f"Authenticated user: {user_id}")
            return user_id
        else:
            logger.warning(f"JWT token missing user_id/sub. Payload keys: {list(payload.keys())}")
            return None
    except Exception as e:
        logger.warning(f"JWT validation failed: {e}")
        return None




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
    
    Fixed version with proper SQL parameters
    """
    try:
        # Require authenticated user - no anonymous device registration allowed
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={"error": "AUTHENTICATION_REQUIRED", "message": "Device registration requires authenticated user. Please sign in first."}
            )
        
        db_pool = await get_db()
        
        current_time = datetime.utcnow()
        
        async with db_pool.acquire() as conn:
            # Try to update existing device first - match by both device_id AND user_id
            result = await conn.execute(
                """
                UPDATE devices SET
                    push_token = $1, push_provider = $2, app_version = $3, os_version = $4, device_name = $5,
                    alert_notifications = $6, chat_notifications = $7, system_notifications = $8,
                    timezone = $9, locale = $10, lat = $11, lon = $12,
                    last_seen = $13, updated_at = $13, token_updated_at = $13, is_active = true
                WHERE device_id = $14 AND user_id = $15
                """,
                request.push_token, request.push_provider.value if request.push_provider else 'fcm',
                request.app_version, request.os_version, request.device_name,
                request.alert_notifications, request.chat_notifications, request.system_notifications,
                request.timezone, request.locale, request.lat, request.lon,
                current_time, request.device_id, user_id
            )
            
            if result == "UPDATE 0":
                # Device doesn't exist, create new one with minimal required fields
                device_record_id = await conn.fetchval(
                    """
                    INSERT INTO devices (
                        user_id, device_id, device_name, platform, app_version, os_version, 
                        push_token, push_provider, push_enabled, 
                        alert_notifications, chat_notifications, system_notifications,
                        lat, lon, is_active, last_seen, registered_at, token_updated_at, created_at, updated_at
                    ) VALUES (
                        $1, $2, $3, $4, $5, $6, $7, $8, true, $9, $10, $11, $12, $13,
                        true, $14, $14, $14, $14, $14
                    ) RETURNING id
                    """,
                    user_id, request.device_id, request.device_name, request.platform.value,
                    request.app_version, request.os_version, request.push_token,
                    request.push_provider.value if request.push_provider else 'fcm',
                    request.alert_notifications, request.chat_notifications, request.system_notifications,
                    request.lat, request.lon, current_time
                )
                logger.info(f"Created new device {request.device_id} for user {user_id}")
            else:
                # Get existing device ID for response
                device_record_id = await conn.fetchval(
                    "SELECT id FROM devices WHERE device_id = $1",
                    request.device_id
                )
                logger.info(f"Updated existing device {request.device_id}")
            
            # Create response
            mock_device = DeviceResponse(
                id=str(device_record_id),
                device_id=request.device_id,
                device_name=request.device_name,
                platform=request.platform,
                app_version=request.app_version,
                os_version=request.os_version,
                device_model=request.device_model,
                manufacturer=request.manufacturer,
                push_enabled=True,
                alert_notifications=request.alert_notifications,
                chat_notifications=request.chat_notifications,
                system_notifications=request.system_notifications,
                is_active=True,
                last_seen=current_time.isoformat(),
                timezone=request.timezone,
                locale=request.locale,
                notifications_sent=0,
                notifications_opened=0,
                registered_at=current_time.isoformat(),
                updated_at=current_time.isoformat()
            )
            
            return DeviceDetailResponse(
                success=True,
                data=mock_device,
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


@router.post("/register/anonymous", response_model=DeviceDetailResponse)
async def register_anonymous_device(request: DeviceRegistrationRequest):
    """
    Register a device anonymously for push notifications (no user authentication required)

    Allows devices to receive proximity alerts without login.
    Device will be upgraded to authenticated when user logs in.
    """
    try:
        db_pool = await get_db()
        current_time = datetime.utcnow()

        async with db_pool.acquire() as conn:
            # Check if this device already exists (anonymous or authenticated)
            existing = await conn.fetchrow(
                """
                SELECT id, user_id, push_enabled, is_active
                FROM devices
                WHERE device_id = $1
                """,
                request.device_id
            )

            if existing:
                # Update existing device (keep user_id if it exists - don't downgrade authenticated to anonymous)
                result = await conn.execute(
                    """
                    UPDATE devices SET
                        push_token = $1, push_provider = $2, app_version = $3, os_version = $4, device_name = $5,
                        alert_notifications = $6, chat_notifications = $7, system_notifications = $8,
                        timezone = $9, locale = $10, lat = $11, lon = $12,
                        last_seen = $13, updated_at = $13, token_updated_at = $13, is_active = true
                    WHERE device_id = $14
                    """,
                    request.push_token, request.push_provider.value if request.push_provider else 'fcm',
                    request.app_version, request.os_version, request.device_name,
                    request.alert_notifications, request.chat_notifications, request.system_notifications,
                    request.timezone, request.locale, request.lat, request.lon,
                    current_time, request.device_id
                )
                logger.info(f"Updated anonymous/existing device {request.device_id}")
            else:
                # Create new anonymous device (user_id = NULL)
                device_record_id = await conn.fetchval(
                    """
                    INSERT INTO devices (
                        user_id, device_id, device_name, platform, app_version, os_version,
                        push_token, push_provider, push_enabled,
                        alert_notifications, chat_notifications, system_notifications,
                        lat, lon, is_active, last_seen, registered_at, token_updated_at, created_at, updated_at
                    ) VALUES (
                        NULL, $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19
                    ) RETURNING id
                    """,
                    request.device_id, request.device_name or 'Anonymous Device',
                    request.platform.value if request.platform else 'unknown',
                    request.app_version, request.os_version,
                    request.push_token, request.push_provider.value if request.push_provider else 'fcm',
                    True,  # push_enabled
                    request.alert_notifications, request.chat_notifications, request.system_notifications,
                    request.lat, request.lon, True, current_time, current_time, current_time, current_time, current_time
                )
                logger.info(f"Created anonymous device {request.device_id} with ID {device_record_id}")

            # Fetch the device data to return
            device_data = await conn.fetchrow(
                """
                SELECT * FROM devices
                WHERE device_id = $1
                """,
                request.device_id
            )

            if not device_data:
                raise HTTPException(
                    status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
                    detail="Device registration succeeded but could not fetch device data"
                )

            # Create DeviceResponse object first
            device_response = create_device_response(device_data)

            # Return wrapped in DeviceDetailResponse format
            return DeviceDetailResponse(
                success=True,
                data=device_response,
                timestamp=current_time.isoformat()
            )

    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Failed to register anonymous device: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "ANONYMOUS_DEVICE_REGISTRATION_FAILED",
                "message": "Failed to register anonymous device"
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
        
        db_pool = await get_db()
        
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
        
        db_pool = await get_db()
        
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
            print(f"🔧 BACKEND: Received update_fields for device {target_device_id}: {update_fields}")
            if update_fields:
                set_clauses = []
                params = []
                param_idx = 1
                
                # Build updates; handle DND prefs and snooze specially
                # 1) Basic scalar fields
                scalar_fields = [
                    'device_name','push_token','push_enabled','alert_notifications',
                    'chat_notifications','system_notifications','app_version','os_version',
                    'timezone','locale','push_provider','alert_range_km'
                ]
                for field in scalar_fields:
                    if field in update_fields and update_fields[field] is not None:
                        val = update_fields[field]
                        if field == 'push_provider' and val:
                            set_clauses.append(f"push_provider = ${param_idx}")
                            params.append(val.value if hasattr(val,'value') else val)
                        else:
                            set_clauses.append(f"{field} = ${param_idx}")
                            params.append(val)
                        param_idx += 1

                # 2) Snooze
                if 'snooze_until' in update_fields:
                    set_clauses.append(f"snooze_until = ${param_idx}")
                    params.append(update_fields['snooze_until'])
                    param_idx += 1

                # 3) User preferences (direct JSONB update from Flutter)
                if 'preferences' in update_fields and update_fields['preferences']:
                    # Direct preferences update from Flutter client - clean and simple
                    prefs = update_fields['preferences']
                    print(f"🔧 BACKEND: Updating preferences for device {target_device_id}: {prefs}")

                    # Log language preference specifically for notification debugging
                    if 'language' in prefs:
                        print(f"🌍 LANGUAGE: Device {device_id} language preference updated to: {prefs['language']}")
                    else:
                        print(f"⚠️  LANGUAGE: No language preference in update for device {device_id}")

                    set_clauses.append(f"preferences = ${param_idx}::jsonb")
                    import json
                    params.append(json.dumps(prefs))
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
        
        db_pool = await get_db()
        
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
        
        db_pool = await get_db()
        current_time = datetime.utcnow()
        
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


@router.patch("/{device_id}/location")
async def update_device_location(device_id: str, request: dict):
    """Update device location for proximity alerts"""
    try:
        lat = request.get('lat')
        lon = request.get('lon')
        
        if lat is None or lon is None:
            raise HTTPException(status_code=400, detail="lat and lon are required")
        
        # Validate coordinates
        lat = float(lat)
        lon = float(lon)
        if lat == 0.0 and lon == 0.0:
            raise HTTPException(status_code=400, detail="Invalid coordinates (0,0)")
        
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            # Update device location
            result = await conn.execute("""
                UPDATE devices 
                SET lat = $1, lon = $2, updated_at = NOW()
                WHERE device_id = $3
            """, lat, lon, device_id)
            
            if result == "UPDATE 0":
                raise HTTPException(status_code=404, detail="Device not found")
        
        return {
            "success": True,
            "message": f"Device location updated to lat={lat}, lon={lon}",
            "device_id": device_id
        }
        
    except ValueError:
        raise HTTPException(status_code=400, detail="Invalid lat/lon values")
    except Exception as e:
        logger.error(f"Error updating device location: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to update location: {str(e)}")


# Debug endpoints
@router.get("/status")
async def get_device_registration_status(user_id: Optional[str] = Depends(get_current_user_id)):
    """Get current device registration status for authenticated user"""
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "Authentication required to check device status"
                }
            )
        
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            device = await conn.fetchrow(
                """
                SELECT id, device_id, platform, push_token, push_enabled,
                       last_seen, registered_at, is_active
                FROM devices 
                WHERE user_id = $1 AND is_active = true
                ORDER BY registered_at DESC 
                LIMIT 1
                """,
                user_id
            )
            
            if not device:
                return {
                    "is_registered": False,
                    "user_id": user_id,
                    "message": "No active device found for user"
                }
            
            return {
                "is_registered": True,
                "device_id": device["device_id"],
                "platform": device["platform"],
                "push_enabled": device["push_enabled"],
                "fcm_token_present": bool(device["push_token"]),
                "fcm_token_hash": device["push_token"][:8] + "..." if device["push_token"] else None,
                "last_seen_at": device["last_seen"].isoformat() if device["last_seen"] else None,
                "registered_at": device["registered_at"].isoformat(),
                "user_id": user_id
            }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error getting device status: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "DEVICE_STATUS_FAILED",
                "message": f"Failed to get device status: {str(e)}"
            }
        )


@router.get("/admin/search")
async def search_devices_admin(q: str):
    """Admin endpoint to search devices table (temporary debug tool)"""
    try:
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            results = await conn.fetch(
                """
                SELECT d.id, d.user_id, d.device_id, d.platform, 
                       d.push_enabled, d.is_active, d.registered_at, d.last_seen,
                       u.email, u.username
                FROM devices d
                LEFT JOIN users u ON d.user_id = u.id
                WHERE d.device_id ILIKE $1 
                   OR u.email ILIKE $1 
                   OR u.username ILIKE $1
                   OR CAST(d.user_id AS TEXT) ILIKE $1
                ORDER BY d.registered_at DESC
                LIMIT 50
                """,
                f"%{q}%"
            )
            
            devices = []
            for record in results:
                device_data = dict(record)
                device_data["registered_at"] = device_data["registered_at"].isoformat() if device_data["registered_at"] else None
                device_data["last_seen"] = device_data["last_seen"].isoformat() if device_data["last_seen"] else None
                devices.append(device_data)
        
        return {
            "success": True,
            "query": q,
            "results": devices,
            "count": len(devices)
        }
        
    except Exception as e:
        logger.error(f"Admin search failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail=f"Search failed: {str(e)}"
        )


@router.post("/debug/test-push")
async def send_test_push_notification(user_id: Optional[str] = Depends(get_current_user_id)):
    """Send test push notification to current user's device"""
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "Authentication required for test push"
                }
            )
        
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            device = await conn.fetchrow(
                """
                SELECT id, device_id, push_token, push_enabled, platform
                FROM devices 
                WHERE user_id = $1 AND is_active = true AND push_enabled = true
                ORDER BY last_seen DESC 
                LIMIT 1
                """,
                user_id
            )
            
            if not device:
                return {
                    "success": False,
                    "error": "No active push-enabled device found for user",
                    "user_id": user_id
                }
            
            if not device["push_token"]:
                return {
                    "success": False,
                    "error": "Device found but no FCM token available",
                    "device_id": device["device_id"]
                }
        
        # Send actual test push notification using Firebase Admin SDK
        try:
            from services.push_service import send_to_token
            
            push_result = send_to_token(
                token=device["push_token"],
                data={
                    "type": "test_push",
                    "device_id": device["device_id"],
                    "timestamp": current_time.isoformat(),
                },
                title="🔔 UFOBeep Test",
                body="Push notification system is working!"
            )
            
            if push_result:
                return {
                    "success": True,
                    "message": "Test push sent successfully",
                    "target_device": device["device_id"],
                    "platform": device["platform"],
                    "fcm_token_hash": device["push_token"][:8] + "..." if device["push_token"] else None,
                    "fcm_message_id": push_result,
                    "firebase_response": str(push_result)
                }
            else:
                return {
                    "success": False,
                    "message": "FCM send failed - check Firebase Admin SDK configuration",
                    "target_device": device["device_id"],
                    "platform": device["platform"],
                    "fcm_token_hash": device["push_token"][:8] + "..." if device["push_token"] else None,
                    "error": "Firebase Admin SDK returned None"
                }
                
        except ImportError as e:
            return {
                "success": False,
                "message": "Push service import failed",
                "target_device": device["device_id"],
                "error": f"Import error: {str(e)}"
            }
        except Exception as e:
            return {
                "success": False,
                "message": "FCM send exception",
                "target_device": device["device_id"], 
                "error": str(e)
            }
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Test push failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "TEST_PUSH_FAILED",
                "message": f"Failed to send test push: {str(e)}"
            }
        )


@router.post("/update-location", status_code=204)
async def update_location(body: UpdateLocationIn, user_id: Optional[str] = Depends(get_current_user_id)):
    """Update device location for the current user"""
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED", 
                    "message": "Authentication required for location update"
                }
            )

        # Additional validation for coordinates
        if not (-90 <= body.lat <= 90 and -180 <= body.lon <= 180):
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
                detail={
                    "error": "INVALID_COORDINATES",
                    "message": "Bad coordinates - lat must be -90 to 90, lon must be -180 to 180"
                }
            )
        
        if abs(body.lat) < 0.0001 and abs(body.lon) < 0.0001:
            raise HTTPException(
                status_code=status.HTTP_422_UNPROCESSABLE_ENTITY, 
                detail={
                    "error": "INVALID_ORIGIN",
                    "message": "Invalid (0,0) coordinates - real location required"
                }
            )

        db_pool = await get_db()
        now = datetime.now(timezone.utc)
        
        async with db_pool.acquire() as conn:
            # Update all active devices for this user
            result = await conn.execute(
                """
                UPDATE devices 
                SET lat = $1, lon = $2, last_seen = $3
                WHERE user_id = $4 AND push_enabled = TRUE
                """,
                body.lat, body.lon, now, user_id
            )
            
            logger.info(f"Updated location for user {user_id}: lat={body.lat}, lon={body.lon}")
        
        # Return 204 No Content on success
        return None
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Location update failed: {e}")
        raise HTTPException(
            status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
            detail={
                "error": "LOCATION_UPDATE_FAILED",
                "message": f"Failed to update location: {str(e)}"
            }
        )


@router.get("/debug/jwt")
async def validate_jwt_debug(token: Optional[str] = Depends(security)):
    """Debug endpoint to validate and decode JWT token"""
    if not token or not token.credentials:
        return {
            "valid": False,
            "error": "No token provided",
            "token_present": bool(token),
            "credentials_present": bool(token.credentials if token else False)
        }
    
    try:
        from app.core.auth import verify_access_token
        payload = verify_access_token(token.credentials)
        
        return {
            "valid": True,
            "user_id": payload.get("user_id"),
            "exp": payload.get("exp"),
            "iat": payload.get("iat"),
            "token_type": payload.get("type", "access"),
            "token_length": len(token.credentials),
            "token_preview": token.credentials[:20] + "..." if len(token.credentials) > 20 else token.credentials
        }
        
    except Exception as e:
        return {
            "valid": False,
            "error": str(e),
            "error_type": type(e).__name__,
            "token_length": len(token.credentials),
            "token_preview": token.credentials[:20] + "..." if len(token.credentials) > 20 else token.credentials
        }


# Health check
@router.get("/health")
async def devices_health_check():
    """Check devices service health"""
    try:
        db_pool = await get_db()
        
        async with db_pool.acquire() as conn:
            # Get device counts
            total_devices = await conn.fetchval(
                "SELECT COUNT(*) FROM devices"
            )
            active_devices = await conn.fetchval(
                "SELECT COUNT(*) FROM devices WHERE is_active = true"
            )
            recent_registrations = await conn.fetchval(
                "SELECT COUNT(*) FROM devices WHERE registered_at > NOW() - INTERVAL '24 hours'"
            )
            push_enabled_devices = await conn.fetchval(
                "SELECT COUNT(*) FROM devices WHERE push_enabled = true AND is_active = true"
            )
        
        return {
            "status": "healthy",
            "total_devices": total_devices,
            "active_devices": active_devices,
            "recent_registrations_24h": recent_registrations,
            "push_enabled_devices": push_enabled_devices,
            "timestamp": datetime.utcnow().isoformat()
        }
    except Exception as e:
        logger.error(f"Health check failed: {e}")
        return {
            "status": "unhealthy",
            "error": str(e),
            "timestamp": datetime.utcnow().isoformat()
        }
