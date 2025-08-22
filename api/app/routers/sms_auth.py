"""
SMS Authentication API - MP14-SMS
Handles SMS-based authentication and phone number management
"""

from fastapi import APIRouter, HTTPException, Depends
from pydantic import BaseModel, Field
from typing import Optional
from datetime import datetime, timedelta
import asyncpg

from app.services.sms_service import sms_service
from app.services.database_service import get_database_pool

router = APIRouter(prefix="/sms", tags=["sms-auth"])


# Database dependency
async def get_db() -> asyncpg.Pool:
    """Get database connection pool from service"""
    return await get_database_pool()


# Pydantic Models
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


@router.post("/add-phone")
async def add_phone_number(request: PhoneAddRequest):
    """Add phone number to user account"""
    # Format phone number
    formatted_phone = sms_service.format_phone_number(request.phone)
    
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device
            user = await conn.fetchrow("""
                SELECT u.id, u.username 
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, request.device_id)
            
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            
            # Check if phone is already used by another user
            existing = await conn.fetchrow("""
                SELECT id FROM users WHERE phone = $1 AND id != $2
            """, formatted_phone, user['id'])
            
            if existing:
                raise HTTPException(status_code=400, detail="Phone number already registered")
            
            # Generate SMS verification code
            verification_code = sms_service.generate_sms_code()
            
            # Save phone and code to user
            expires_at = datetime.now() + timedelta(minutes=15)
            
            await conn.execute("""
                UPDATE users 
                SET phone = $1, phone_verified = false, recovery_code = $2, recovery_expires_at = $3
                WHERE id = $4
            """, formatted_phone, verification_code, expires_at, user['id'])
            
            # Send verification SMS
            result = await sms_service.send_recovery_sms(formatted_phone, user['username'], verification_code)
            
            return {
                "success": True,
                "message": f"Verification code sent to {sms_service.mask_phone_number(formatted_phone)}",
                "phone": formatted_phone,
                "expires_in_minutes": 15
            }
            
    finally:
        pass


@router.post("/verify-phone")
async def verify_phone_number(request: PhoneVerifyRequest):
    """Verify phone number with SMS code"""
    pool = await get_db()
    try:
        async with pool.acquire() as conn:
            # Get user from device
            user = await conn.fetchrow("""
                SELECT u.id, u.username, u.phone, u.recovery_code, u.recovery_expires_at
                FROM users u
                JOIN user_devices ud ON u.id = ud.user_id
                WHERE ud.device_id = $1
            """, request.device_id)
            
            if not user:
                raise HTTPException(status_code=404, detail="User not found")
            
            if not user['recovery_code'] or user['recovery_code'] != request.code:
                raise HTTPException(status_code=400, detail="Invalid verification code")
            
            # Check if code expired
            if user['recovery_expires_at'] < datetime.now():
                raise HTTPException(status_code=400, detail="Verification code expired")
            
            # Mark phone as verified and clear code
            await conn.execute("""
                UPDATE users 
                SET phone_verified = true, recovery_code = NULL, recovery_expires_at = NULL
                WHERE id = $1
            """, user['id'])
            
            return {
                "success": True,
                "message": "Phone number verified successfully",
                "phone": sms_service.mask_phone_number(user['phone'])
            }
            
    finally:
        pass


@router.post("/test")
async def test_sms_service(request: TestSMSRequest):
    """Test SMS service (admin only)"""
    result = await sms_service.send_test_sms(request.phone)
    return result