"""
Phone Service for UFOBeep - Clean Firebase Integration
Handles phone number linking after Firebase verification
"""

import asyncpg
from typing import Dict, Any, Optional
from datetime import datetime


class PhoneService:
    """Clean phone service - Firebase handles SMS, we just store verified numbers"""
    
    async def link_phone_to_user(self, db_pool: asyncpg.Pool, firebase_uid: str, phone: str) -> Dict[str, Any]:
        """Link verified phone number to user account"""
        try:
            async with db_pool.acquire() as conn:
                # First check if phone is already assigned to another user
                existing = await conn.fetchrow("""
                    SELECT id, firebase_uid FROM users 
                    WHERE phone = $1
                """, phone)
                
                if existing and existing['firebase_uid'] != firebase_uid:
                    return {
                        'success': False,
                        'error': 'Phone number already assigned to another account'
                    }
                
                # Update phone number for the user (by firebase_uid, not user_id)
                result = await conn.execute("""
                    UPDATE users 
                    SET phone = $1, phone_verified = true, updated_at = $2
                    WHERE firebase_uid = $3
                """, phone, datetime.utcnow(), firebase_uid)
                
                if result == "UPDATE 0":
                    return {
                        'success': False,
                        'error': 'User not found'
                    }
                
                return {
                    'success': True,
                    'message': 'Phone number linked successfully'
                }
                
        except Exception as e:
            print(f"Error linking phone: {e}")
            return {
                'success': False,
                'error': f'Failed to link phone number: {str(e)}'
            }


# Global instance
phone_service = PhoneService()