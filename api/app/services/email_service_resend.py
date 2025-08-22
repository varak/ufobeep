"""
Email Service using Resend - MP14
Production-ready email service with excellent deliverability
Handles spikes gracefully, tracks analytics, prevents spam
"""

import os
import secrets
import logging
from typing import Optional, Dict
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

# Install: pip install resend
try:
    import resend
    RESEND_AVAILABLE = True
except ImportError:
    RESEND_AVAILABLE = False
    logger.warning("Resend not installed. Run: pip install resend")

class ResendEmailService:
    """Production email service using Resend API"""
    
    def __init__(self):
        self.api_key = os.getenv("RESEND_API_KEY", "")
        self.from_email = "UFOBeep <alerts@ufobeep.com>"  # You'll verify this domain in Resend
        self.base_url = "https://ufobeep.com"
        
        if RESEND_AVAILABLE and self.api_key:
            resend.api_key = self.api_key
            self.enabled = True
            logger.info("Resend email service initialized")
        else:
            self.enabled = False
            logger.warning("Resend email service disabled (no API key or library)")
    
    def generate_verification_token(self) -> str:
        """Generate a secure random verification token"""
        return secrets.token_urlsafe(32)
    
    async def send_verification_email(self, 
                                     to_email: str, 
                                     username: str, 
                                     token: str) -> Dict:
        """
        Send verification email with tracking
        Returns: {"success": bool, "id": "email_id", "error": "error_msg"}
        """
        if not self.enabled:
            return {"success": False, "error": "Email service not configured"}
        
        try:
            verification_url = f"{self.base_url}/verify?token={token}"
            
            # Resend handles both HTML and text automatically
            response = resend.Emails.send({
                "from": self.from_email,
                "to": to_email,
                "subject": f"Welcome to UFOBeep, {username}! 🛸",
                "html": f"""
                <div style="font-family: system-ui, -apple-system, sans-serif; max-width: 600px; margin: 0 auto;">
                    <div style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); padding: 40px; text-align: center; border-radius: 10px 10px 0 0;">
                        <h1 style="color: white; margin: 0; font-size: 32px;">🛸 UFOBeep</h1>
                        <p style="color: rgba(255,255,255,0.9); margin-top: 10px;">Real-time UFO Alert Network</p>
                    </div>
                    
                    <div style="background: white; padding: 40px; border: 1px solid #e5e7eb; border-top: none;">
                        <h2 style="color: #111827; margin-top: 0;">Welcome, {username}!</h2>
                        
                        <p style="color: #6b7280; line-height: 1.6;">
                            You're almost ready to join thousands of sky watchers worldwide. 
                            Verify your email to unlock these features:
                        </p>
                        
                        <ul style="color: #6b7280; line-height: 1.8;">
                            <li>🔄 <strong>Account Recovery</strong> - Never lose your username</li>
                            <li>📱 <strong>Multi-Device Sync</strong> - Same account on all devices</li>
                            <li>🔔 <strong>Email Alerts</strong> - Get notified of nearby sightings (optional)</li>
                            <li>⭐ <strong>Verified Badge</strong> - Build trust in the community</li>
                        </ul>
                        
                        <div style="text-align: center; margin: 35px 0;">
                            <a href="{verification_url}" 
                               style="background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); 
                                      color: white; 
                                      padding: 14px 35px; 
                                      text-decoration: none; 
                                      border-radius: 6px; 
                                      font-weight: 600;
                                      display: inline-block;
                                      box-shadow: 0 4px 6px rgba(0,0,0,0.1);">
                                Verify Email Address
                            </a>
                        </div>
                        
                        <p style="color: #9ca3af; font-size: 14px; text-align: center;">
                            Button not working? Copy this link:<br>
                            <code style="background: #f3f4f6; padding: 8px; border-radius: 4px; font-size: 12px;">
                                {verification_url}
                            </code>
                        </p>
                    </div>
                    
                    <div style="background: #f9fafb; padding: 20px; text-align: center; border-radius: 0 0 10px 10px; border: 1px solid #e5e7eb; border-top: none;">
                        <p style="color: #9ca3af; font-size: 12px; margin: 0;">
                            This link expires in 24 hours. Didn't sign up? You can safely ignore this email.
                        </p>
                    </div>
                </div>
                """,
                "tags": [
                    {"name": "category", "value": "verification"},
                    {"name": "username", "value": username}
                ]
            })
            
            logger.info(f"Verification email sent to {to_email}: {response['id']}")
            return {"success": True, "id": response["id"]}
            
        except Exception as e:
            logger.error(f"Failed to send verification email: {e}")
            return {"success": False, "error": str(e)}
    
    async def send_recovery_email(self, 
                                 to_email: str, 
                                 username: str, 
                                 recovery_code: str) -> Dict:
        """Send account recovery email"""
        if not self.enabled:
            return {"success": False, "error": "Email service not configured"}
        
        try:
            response = resend.Emails.send({
                "from": self.from_email,
                "to": to_email,
                "subject": "Your UFOBeep Account Recovery Code",
                "html": f"""
                <div style="font-family: system-ui, -apple-system, sans-serif; max-width: 600px; margin: 0 auto;">
                    <div style="background: #1f2937; padding: 40px; text-align: center; border-radius: 10px 10px 0 0;">
                        <h1 style="color: white; margin: 0;">🛸 Account Recovery</h1>
                    </div>
                    
                    <div style="background: white; padding: 40px; border: 1px solid #e5e7eb;">
                        <p style="color: #6b7280;">Your UFOBeep username is:</p>
                        
                        <div style="background: #f3f4f6; padding: 20px; border-radius: 8px; text-align: center; margin: 20px 0;">
                            <h2 style="color: #111827; margin: 0; font-size: 28px; font-family: monospace;">
                                {username}
                            </h2>
                        </div>
                        
                        <p style="color: #6b7280;">Recovery code (enter in app):</p>
                        
                        <div style="background: #fef3c7; padding: 15px; border-radius: 8px; text-align: center; margin: 20px 0; border: 2px solid #fbbf24;">
                            <code style="font-size: 24px; letter-spacing: 2px; color: #92400e; font-weight: bold;">
                                {recovery_code}
                            </code>
                        </div>
                        
                        <ol style="color: #6b7280; line-height: 1.8;">
                            <li>Open UFOBeep app</li>
                            <li>Tap "I have an account"</li>
                            <li>Enter the recovery code above</li>
                            <li>Your account will be restored!</li>
                        </ol>
                    </div>
                    
                    <div style="background: #f9fafb; padding: 20px; text-align: center; border-radius: 0 0 10px 10px;">
                        <p style="color: #9ca3af; font-size: 12px; margin: 0;">
                            Code expires in 15 minutes for security. Need help? Reply to this email.
                        </p>
                    </div>
                </div>
                """,
                "tags": [
                    {"name": "category", "value": "recovery"},
                    {"name": "username", "value": username}
                ]
            })
            
            logger.info(f"Recovery email sent to {to_email}: {response['id']}")
            return {"success": True, "id": response["id"]}
            
        except Exception as e:
            logger.error(f"Failed to send recovery email: {e}")
            return {"success": False, "error": str(e)}
    
    async def send_alert_notification(self,
                                     to_email: str,
                                     username: str,
                                     alert_data: Dict) -> Dict:
        """Send alert notification email (future feature)"""
        if not self.enabled:
            return {"success": False, "error": "Email service not configured"}
        
        try:
            location = alert_data.get("location", "your area")
            distance = alert_data.get("distance_km", "nearby")
            
            response = resend.Emails.send({
                "from": self.from_email,
                "to": to_email,
                "subject": f"🛸 UFO Alert {distance}km from you!",
                "html": f"""
                <div style="font-family: system-ui, -apple-system, sans-serif;">
                    <h2>New UFO sighting near {location}!</h2>
                    <p>Hi {username},</p>
                    <p>A UFO has been reported {distance}km from your location.</p>
                    <a href="https://ufobeep.com/alerts/{alert_data.get('id')}" 
                       style="background: #10b981; color: white; padding: 10px 20px; text-decoration: none; border-radius: 5px; display: inline-block;">
                        View Alert
                    </a>
                    <p style="color: #6b7280; font-size: 12px; margin-top: 20px;">
                        You're receiving this because you enabled email alerts. 
                        <a href="https://ufobeep.com/unsubscribe">Unsubscribe</a>
                    </p>
                </div>
                """,
                "tags": [
                    {"name": "category", "value": "alert"},
                    {"name": "alert_id", "value": alert_data.get("id", "")}
                ]
            })
            
            return {"success": True, "id": response["id"]}
            
        except Exception as e:
            logger.error(f"Failed to send alert email: {e}")
            return {"success": False, "error": str(e)}

# Global service instance
email_service = None

async def get_email_service():
    """Get or create email service instance"""
    global email_service
    if email_service is None:
        email_service = ResendEmailService()
    return email_service