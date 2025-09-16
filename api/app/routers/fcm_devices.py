from fastapi import APIRouter, HTTPException, status
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
import pygeohash
import asyncpg
import logging
import sys
import os

from app.services.push_service import send_to_token

logger = logging.getLogger(__name__)
router = APIRouter()

# Database connection pool (will be initialized in main.py)
db_pool = None

class RegisterDeviceRequest(BaseModel):
    device_id: str = Field(..., min_length=3, max_length=128)
    fcm_token: str = Field(..., min_length=20)
    platform: str = Field('android', pattern='^(android|ios)$')
    lat: Optional[float] = None
    lon: Optional[float] = None

@router.post("/register/device")
async def register_device(request: RegisterDeviceRequest):
    """Register or update device FCM token and location"""
    try:
        geohash_val = None
        if request.lat is not None and request.lon is not None:
            # Generate 7-character geohash for proximity queries
            geohash_val = pygeohash.encode(request.lat, request.lon, precision=7)

        async with db_pool.acquire() as conn:
            # Check if device already exists (simplified for Phase 0)
            existing = await conn.fetchrow(
                "SELECT id FROM devices WHERE device_id = $1 AND is_active = true",
                request.device_id
            )
            
            if existing:
                # Update existing device
                await conn.execute("""
                    UPDATE devices SET
                      push_token = $1,
                      platform = $2,
                      lat = $3,
                      lon = $4,
                      geohash = $5,
                      last_seen = $6,
                      updated_at = $6
                    WHERE device_id = $7
                """, request.fcm_token, request.platform, request.lat, request.lon, geohash_val, datetime.utcnow(), request.device_id)
            else:
                # No anonymous users allowed - require authentication
                raise HTTPException(
                    status_code=status.HTTP_401_UNAUTHORIZED,
                    detail={"error": "AUTHENTICATION_REQUIRED", "message": "Device registration requires authenticated user. Please sign in first."}
                )

        logger.info(f"Registered device {request.device_id} with platform {request.platform}")
        
        return {
            "ok": True, 
            "device_id": request.device_id, 
            "geohash": geohash_val,
            "message": "Device registered successfully"
        }
        
    except Exception as e:
        logger.error(f"Error registering device {request.device_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to register device: {str(e)}")

@router.post("/register/anonymous")
async def register_anonymous_device(request: RegisterDeviceRequest):
    """Register or update anonymous device FCM token and location for proximity alerts only"""
    try:
        geohash_val = None
        if request.lat is not None and request.lon is not None:
            # Generate 7-character geohash for proximity queries
            geohash_val = pygeohash.encode(request.lat, request.lon, precision=7)

        async with db_pool.acquire() as conn:
            # Check if anonymous device already exists
            existing = await conn.fetchrow(
                "SELECT id FROM devices WHERE device_id = $1 AND user_id IS NULL AND is_active = true",
                request.device_id
            )

            if existing:
                # Update existing anonymous device
                await conn.execute("""
                    UPDATE devices SET
                      push_token = $1,
                      platform = $2,
                      lat = $3,
                      lon = $4,
                      geohash = $5,
                      last_seen = $6,
                      updated_at = $6
                    WHERE device_id = $7 AND user_id IS NULL
                """, request.fcm_token, request.platform, request.lat, request.lon, geohash_val, datetime.utcnow(), request.device_id)
            else:
                # Create new anonymous device (user_id = NULL)
                await conn.execute("""
                    INSERT INTO devices (
                        device_id, device_name, platform, push_token, lat, lon, geohash,
                        push_provider, push_enabled, alert_notifications, last_seen
                    ) VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                """,
                    request.device_id,
                    "Anonymous Device",
                    request.platform,
                    request.fcm_token,
                    request.lat,
                    request.lon,
                    geohash_val,
                    'fcm',
                    True,
                    True,  # Enable proximity alerts
                    datetime.utcnow()
                )

        logger.info(f"Registered anonymous device {request.device_id} with platform {request.platform}")

        return {
            "ok": True,
            "device_id": request.device_id,
            "geohash": geohash_val,
            "message": "Anonymous device registered successfully for proximity alerts"
        }

    except Exception as e:
        logger.error(f"Failed to register anonymous device: {e}")
        raise HTTPException(
            status_code=500,
            detail={
                "error": "ANONYMOUS_DEVICE_REGISTRATION_FAILED",
                "message": "Failed to register anonymous device"
            }
        )

class PushTestRequest(BaseModel):
    device_id: str

@router.post("/push/test")
async def push_test(request: PushTestRequest):
    """Send test push notification to a specific device"""
    try:
        async with db_pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT push_token, platform FROM devices WHERE device_id = $1 AND is_active = true", 
                request.device_id
            )
            
        if not row:
            raise HTTPException(status_code=404, detail="Device not registered")

        # Prepare push data
        push_data = {
            "type": "test",
            "device_id": request.device_id,
            "timestamp": datetime.utcnow().isoformat()
        }

        # Send push notification
        response = send_to_token(
            row["push_token"], 
            push_data,
            title="UFOBeep Test", 
            body="This is a test push from the server."
        )

        if response:
            logger.info(f"Test push sent to device {request.device_id}: {response}")
            return {
                "ok": True, 
                "message": "Test push sent successfully",
                "fcm_response": response,
                "device_platform": row["platform"]
            }
        else:
            raise HTTPException(status_code=500, detail="Failed to send push notification")
            
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error sending test push to {request.device_id}: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to send test push: {str(e)}")

@router.get("/devices/stats")
async def device_stats():
    """Get basic device registration statistics"""
    try:
        async with db_pool.acquire() as conn:
            stats = await conn.fetchrow("""
                SELECT 
                    COUNT(*) as total_devices,
                    COUNT(*) FILTER (WHERE platform = 'android') as android_devices,
                    COUNT(*) FILTER (WHERE platform = 'ios') as ios_devices,
                    COUNT(*) FILTER (WHERE push_token IS NOT NULL) as devices_with_push_token,
                    MAX(updated_at) as last_registration
                FROM devices
                WHERE is_active = true
            """)
            
        return {
            "total_devices": stats["total_devices"],
            "android_devices": stats["android_devices"], 
            "ios_devices": stats["ios_devices"],
            "devices_with_push_token": stats["devices_with_push_token"],
            "last_registration": stats["last_registration"].isoformat() if stats["last_registration"] else None
        }
        
    except Exception as e:
        logger.error(f"Error getting device stats: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get device stats: {str(e)}")

@router.post("/proximity/test")
async def test_proximity_alerts(request: dict):
    """Test proximity alert system for a specific location"""
    try:
        lat = request.get('lat', 47.61)
        lon = request.get('lon', -122.33)
        exclude_device_id = request.get('exclude_device_id', 'test_exclude')
        
        from services.proximity_alert_service import get_proximity_alert_service
        proximity_service = get_proximity_alert_service(db_pool)
        
        # Test getting devices without sending alerts
        devices_1km = await proximity_service._get_devices_within_radius(lat, lon, 1.0, exclude_device_id)
        devices_5km = await proximity_service._get_devices_within_radius(lat, lon, 5.0, exclude_device_id)
        devices_10km = await proximity_service._get_devices_within_radius(lat, lon, 10.0, exclude_device_id)
        devices_25km = await proximity_service._get_devices_within_radius(lat, lon, 25.0, exclude_device_id)
        
        return {
            "test_location": {"lat": lat, "lon": lon},
            "devices_1km": len(devices_1km),
            "devices_5km": len(devices_5km),
            "devices_10km": len(devices_10km), 
            "devices_25km": len(devices_25km),
            "sample_devices_25km": devices_25km[:3] if devices_25km else []
        }
        
    except Exception as e:
        logger.error(f"Error testing proximity alerts: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to test proximity alerts: {str(e)}")

def set_db_pool(pool):
    """Set the database connection pool (called from main.py)"""
    global db_pool
    db_pool = pool