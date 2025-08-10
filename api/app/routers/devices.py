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
        IOS = "ios"
        ANDROID = "android"
        WEB = "web"
    
    class PushProvider(str, Enum):
        FCM = "fcm"
        APNS = "apns"
        WEBPUSH = "webpush"


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
    prefix="/v1/devices",
    tags=["devices"],
    responses={
        404: {"description": "Device not found"},
        400: {"description": "Bad request"},
        403: {"description": "Access denied"},
        422: {"description": "Validation error"},
    }
)

security = HTTPBearer(auto_error=False)

# In-memory device storage (replace with database in production)
devices_db = {}
device_by_user = {}  # user_id -> list of device_ids


# Dependencies
async def get_current_user_id(token: Optional[str] = Depends(security)) -> Optional[str]:
    """Extract user ID from JWT token (simplified for now)"""
    if token and token.credentials:
        # TODO: Implement actual JWT validation
        return "anonymous_user"
    return None


def create_device_response(device_data: dict) -> DeviceResponse:
    """Convert device data to API response format"""
    return DeviceResponse(
        id=device_data["id"],
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
    """
    try:
        if not user_id:
            raise HTTPException(
                status_code=status.HTTP_401_UNAUTHORIZED,
                detail={
                    "error": "AUTHENTICATION_REQUIRED",
                    "message": "User authentication required for device registration"
                }
            )
        
        # Generate device record ID
        device_record_id = f"device_{uuid4().hex[:12]}"
        
        # Check if device already exists for this user
        user_devices = device_by_user.get(user_id, [])
        existing_device_id = None
        
        for device_id in user_devices:
            if devices_db[device_id]["device_id"] == request.device_id:
                existing_device_id = device_id
                break
        
        current_time = datetime.utcnow()
        
        if existing_device_id:
            # Update existing device
            device_data = devices_db[existing_device_id]
            device_data.update({
                "device_name": request.device_name or device_data.get("device_name"),
                "app_version": request.app_version,
                "os_version": request.os_version,
                "push_token": request.push_token,
                "push_provider": request.push_provider.value if request.push_provider else None,
                "alert_notifications": request.alert_notifications,
                "chat_notifications": request.chat_notifications,
                "system_notifications": request.system_notifications,
                "timezone": request.timezone,
                "locale": request.locale,
                "last_seen": current_time,
                "updated_at": current_time,
                "token_updated_at": current_time if request.push_token else device_data.get("token_updated_at"),
                "is_active": True,
            })
            
            logger.info(f"Updated device {request.device_id} for user {user_id}")
            device_response = create_device_response(device_data)
            
        else:
            # Create new device
            device_data = {
                "id": device_record_id,
                "user_id": user_id,
                "device_id": request.device_id,
                "device_name": request.device_name,
                "platform": request.platform.value,
                "app_version": request.app_version,
                "os_version": request.os_version,
                "device_model": request.device_model,
                "manufacturer": request.manufacturer,
                "push_token": request.push_token,
                "push_provider": request.push_provider.value if request.push_provider else None,
                "push_enabled": True,
                "alert_notifications": request.alert_notifications,
                "chat_notifications": request.chat_notifications,
                "system_notifications": request.system_notifications,
                "is_active": True,
                "last_seen": current_time,
                "timezone": request.timezone,
                "locale": request.locale,
                "notifications_sent": 0,
                "notifications_opened": 0,
                "registered_at": current_time,
                "token_updated_at": current_time if request.push_token else None,
                "created_at": current_time,
                "updated_at": current_time,
            }
            
            devices_db[device_record_id] = device_data
            
            # Update user device mapping
            if user_id not in device_by_user:
                device_by_user[user_id] = []
            device_by_user[user_id].append(device_record_id)
            
            logger.info(f"Registered new device {request.device_id} for user {user_id}")
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
        
        user_devices = device_by_user.get(user_id, [])
        devices = []
        
        for device_id in user_devices:
            device_data = devices_db.get(device_id)
            if device_data and device_data["is_active"]:
                devices.append(create_device_response(device_data))
        
        # Sort by registration date (newest first)
        devices.sort(key=lambda x: x.registered_at, reverse=True)
        
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
        
        # Find device by device_id and verify ownership
        user_devices = device_by_user.get(user_id, [])
        target_device_id = None
        
        for db_device_id in user_devices:
            device = devices_db.get(db_device_id)
            if device and device["device_id"] == device_id:
                target_device_id = db_device_id
                break
        
        if not target_device_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "DEVICE_NOT_FOUND",
                    "message": f"Device {device_id} not found for user"
                }
            )
        
        device_data = devices_db[target_device_id]
        current_time = datetime.utcnow()
        
        # Update provided fields
        update_fields = request.dict(exclude_unset=True)
        for field, value in update_fields.items():
            if field == "push_provider" and value:
                device_data[field] = value.value
            else:
                device_data[field] = value
        
        device_data["updated_at"] = current_time
        device_data["last_seen"] = current_time
        
        if "push_token" in update_fields:
            device_data["token_updated_at"] = current_time
        
        logger.info(f"Updated device {device_id} for user {user_id}")
        
        device_response = create_device_response(device_data)
        
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
        
        # Find and deactivate device
        user_devices = device_by_user.get(user_id, [])
        target_device_id = None
        
        for db_device_id in user_devices:
            device = devices_db.get(db_device_id)
            if device and device["device_id"] == device_id:
                target_device_id = db_device_id
                break
        
        if not target_device_id:
            raise HTTPException(
                status_code=status.HTTP_404_NOT_FOUND,
                detail={
                    "error": "DEVICE_NOT_FOUND",
                    "message": f"Device {device_id} not found"
                }
            )
        
        devices_db[target_device_id]["is_active"] = False
        devices_db[target_device_id]["updated_at"] = datetime.utcnow()
        
        logger.info(f"Unregistered device {device_id} for user {user_id}")
        
        return {
            "success": True,
            "message": "Device unregistered successfully",
            "timestamp": datetime.utcnow().isoformat()
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
        
        # Find and update device last_seen
        user_devices = device_by_user.get(user_id, [])
        target_device_id = None
        
        for db_device_id in user_devices:
            device = devices_db.get(db_device_id)
            if device and device["device_id"] == device_id:
                target_device_id = db_device_id
                break
        
        if target_device_id:
            devices_db[target_device_id]["last_seen"] = datetime.utcnow()
        
        return {
            "success": True,
            "timestamp": datetime.utcnow().isoformat()
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
    return {
        "status": "healthy",
        "total_devices": len(devices_db),
        "active_devices": len([d for d in devices_db.values() if d["is_active"]]),
        "timestamp": datetime.utcnow().isoformat()
    }