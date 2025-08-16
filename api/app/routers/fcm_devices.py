from fastapi import APIRouter, HTTPException
from pydantic import BaseModel, Field
from datetime import datetime
from typing import Optional
import pygeohash
import asyncpg
import logging
import sys
import os

# Add path for push service
sys.path.append(os.path.join(os.path.dirname(__file__), '..', '..'))
from services.push_service import send_to_token

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
                      platform = $2::text::device_platform,
                      last_seen = $3,
                      updated_at = $3
                    WHERE device_id = $4
                """, request.fcm_token, request.platform, datetime.utcnow(), request.device_id)
            else:
                # Create anonymous user first for new device
                anon_user_id = await conn.fetchval("""
                    INSERT INTO users (username, display_name, alert_range_km, min_alert_level, push_notifications, email_notifications, is_active)
                    VALUES ($1, $2, 50.0, 'low', true, false, true)
                    RETURNING id
                """, f"anon_{request.device_id[:8]}", "Anonymous User")
                
                # Create new device
                await conn.execute("""
                    INSERT INTO devices (
                        user_id, device_id, platform, push_token, push_provider,
                        push_enabled, alert_notifications, chat_notifications, system_notifications,
                        is_active, last_seen, registered_at, updated_at
                    ) VALUES (
                        $1, $2, $3::text::device_platform, $4, 'fcm',
                        true, true, true, true,
                        true, $5, $5, $5
                    )
                """, anon_user_id, request.device_id, request.platform, request.fcm_token, datetime.utcnow())

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

def set_db_pool(pool):
    """Set the database connection pool (called from main.py)"""
    global db_pool
    db_pool = pool