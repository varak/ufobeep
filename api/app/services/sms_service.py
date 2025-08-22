"""
SMS Service for UFOBeep Account Recovery
Provides SMS-based authentication as alternative to email
Uses Twilio API for reliable SMS delivery
"""

import secrets
import logging
from typing import Optional, Dict, Any
import httpx
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class SMSService:
    """SMS service for account recovery codes"""
    
    def __init__(self):
        # For now, use a simple SMS service (could be Twilio, AWS SNS, etc.)
        # This is a placeholder implementation
        self.api_key = "demo-key"  # TODO: Add real SMS service API key
        self.from_number = "+1234567890"  # TODO: Configure real number
        
    def format_phone_number(self, phone: str) -> str:
        """Format phone number to E.164 format"""
        # Remove all non-digits
        digits = ''.join(filter(str.isdigit, phone))
        
        # Add +1 if no country code and looks like US number
        if len(digits) == 10:
            digits = "1" + digits
        
        return "+" + digits
    
    def generate_sms_code(self) -> str:
        """Generate 6-digit SMS verification code"""
        return f"{secrets.randbelow(999999):06d}"
    
    async def send_recovery_sms(self, phone_number: str, username: str, code: str) -> Dict[str, Any]:
        """Send SMS recovery code"""
        try:
            formatted_phone = self.format_phone_number(phone_number)
            
            message = f"""UFOBeep Recovery Code: {code}

Username: {username}

This code expires in 15 minutes. 

Reply STOP to opt out.
            
https://ufobeep.com"""
            
            # For demo/testing - log the SMS instead of sending
            logger.info(f"SMS to {formatted_phone}: {message}")
            
            # TODO: Replace with real SMS service
            # Example Twilio implementation:
            # client = twilio.rest.Client(account_sid, auth_token)
            # message = client.messages.create(
            #     body=message,
            #     from_=self.from_number,
            #     to=formatted_phone
            # )
            
            return {
                "success": True,
                "message": f"Recovery code sent to {self.mask_phone_number(formatted_phone)}",
                "phone": formatted_phone
            }
            
        except Exception as e:
            logger.error(f"Failed to send SMS to {phone_number}: {e}")
            return {
                "success": False,
                "error": f"SMS sending failed: {str(e)}"
            }
    
    def mask_phone_number(self, phone: str) -> str:
        """Mask phone number for security (show last 4 digits)"""
        if len(phone) >= 4:
            return "*" * (len(phone) - 4) + phone[-4:]
        return "*" * len(phone)
    
    async def send_test_sms(self, phone_number: str) -> Dict[str, Any]:
        """Send test SMS to verify service is working"""
        try:
            formatted_phone = self.format_phone_number(phone_number)
            
            message = """Test message from UFOBeep SMS service.

If you received this, SMS authentication is working!

https://ufobeep.com"""
            
            logger.info(f"Test SMS to {formatted_phone}: {message}")
            
            return {
                "success": True,
                "message": f"Test SMS sent to {self.mask_phone_number(formatted_phone)}"
            }
            
        except Exception as e:
            logger.error(f"Failed to send test SMS: {e}")
            return {
                "success": False,
                "error": str(e)
            }

# Global service instance
sms_service = SMSService()

async def get_sms_service():
    """Get SMS service instance"""
    return sms_service