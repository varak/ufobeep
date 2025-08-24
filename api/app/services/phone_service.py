"""
Phone Service for UFOBeep - Clean Firebase Integration
Handles phone number linking after Firebase verification
"""

import asyncpg
from typing import Dict, Any, Optional
from datetime import datetime


class PhoneService:
    """Clean phone service - Firebase handles SMS, we just store verified numbers"""
    
    async def link_phone_to_user(self, db_pool: asyncpg.Pool, user_id: str, phone: str) -> Dict[str, Any]:
        """Link verified phone number to user account"""
        try:
            async with db_pool.acquire() as conn:
                await conn.execute("""
                    UPDATE users 
                    SET phone = $1, phone_verified = true, updated_at = $2
                    WHERE id = $3
                """, phone, datetime.utcnow(), user_id)
                
                return {
                    'success': True,
                    'message': 'Phone number linked successfully'
                }
                
        except Exception as e:
            print(f"Error linking phone: {e}")
            return {
                'success': False,
                'error': 'Failed to link phone number'
            }


# Global instance
phone_service = PhoneService()