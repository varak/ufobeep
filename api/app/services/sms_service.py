"""
SMS Service for UFOBeep Account Recovery
Provides SMS-based authentication as alternative to email
Uses Twilio API for reliable SMS delivery
"""

import secrets
import logging
import os
from typing import Optional, Dict, Any
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

try:
    from twilio.rest import Client
    TWILIO_AVAILABLE = True
except ImportError:
    logger.warning("Twilio not available - SMS will only log messages")
    TWILIO_AVAILABLE = False

class SMSService:
    """SMS service for account recovery codes"""
    
    def __init__(self):
        self.account_sid = os.getenv('TWILIO_ACCOUNT_SID')
        self.auth_token = os.getenv('TWILIO_AUTH_TOKEN') 
        self.from_number = os.getenv('TWILIO_PHONE_NUMBER', '+1234567890')
        
        # Initialize Twilio client if credentials are available
        self.client = None
        if TWILIO_AVAILABLE and self.account_sid and self.auth_token:
            try:
                self.client = Client(self.account_sid, self.auth_token)
                logger.info("Twilio SMS service initialized")
            except Exception as e:
                logger.error(f"Failed to initialize Twilio client: {e}")
                self.client = None
        else:
            logger.warning("Twilio credentials not configured - SMS will only log messages")
        
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
            
            message_body = f"""UFOBeep Recovery Code: {code}

Username: {username}

This code expires in 15 minutes. 

Reply STOP to opt out.
            
https://ufobeep.com"""
            
            if self.client:
                # Send via Twilio
                try:
                    message = self.client.messages.create(
                        body=message_body,
                        from_=self.from_number,
                        to=formatted_phone
                    )
                    logger.info(f"SMS sent successfully to {self.mask_phone_number(formatted_phone)}, SID: {message.sid}")
                    
                    return {
                        "success": True,
                        "message": f"Recovery code sent to {self.mask_phone_number(formatted_phone)}",
                        "phone": formatted_phone,
                        "twilio_sid": message.sid
                    }
                except Exception as twilio_error:
                    logger.error(f"Twilio SMS failed to {formatted_phone}: {twilio_error}")
                    return {
                        "success": False,
                        "error": f"SMS sending failed: {str(twilio_error)}"
                    }
            else:
                # Fallback: log the message (for development/testing)
                logger.info(f"SMS to {formatted_phone}: {message_body}")
                logger.warning("Twilio not configured - SMS logged only")
                
                return {
                    "success": True,
                    "message": f"Recovery code logged for {self.mask_phone_number(formatted_phone)} (Twilio not configured)",
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
            
            message_body = """Test message from UFOBeep SMS service.

If you received this, SMS authentication is working!

https://ufobeep.com"""
            
            if self.client:
                # Send via Twilio
                try:
                    message = self.client.messages.create(
                        body=message_body,
                        from_=self.from_number,
                        to=formatted_phone
                    )
                    logger.info(f"Test SMS sent successfully to {self.mask_phone_number(formatted_phone)}, SID: {message.sid}")
                    
                    return {
                        "success": True,
                        "message": f"Test SMS sent to {self.mask_phone_number(formatted_phone)}",
                        "twilio_sid": message.sid
                    }
                except Exception as twilio_error:
                    logger.error(f"Twilio test SMS failed to {formatted_phone}: {twilio_error}")
                    return {
                        "success": False,
                        "error": f"Test SMS failed: {str(twilio_error)}"
                    }
            else:
                # Fallback: log the message
                logger.info(f"Test SMS to {formatted_phone}: {message_body}")
                logger.warning("Twilio not configured - test SMS logged only")
                
                return {
                    "success": True,
                    "message": f"Test SMS logged for {self.mask_phone_number(formatted_phone)} (Twilio not configured)"
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