"""
Email Service using Brevo (Sendinblue) - MP14
Best free tier: 300 emails/day, 9000/month FREE
No credit card required, scales to unlimited for $25/mo
"""

import os
import secrets
import logging
import requests
from typing import Optional, Dict
from datetime import datetime, timedelta

logger = logging.getLogger(__name__)

class BrevoEmailService:
    """Production email service using Brevo API - best free tier available"""
    
    def __init__(self):
        self.api_key = os.getenv("BREVO_API_KEY", "")
        self.api_url = "https://api.brevo.com/v3/smtp/email"
        self.from_email = "alerts@ufobeep.com"
        self.from_name = "UFOBeep"
        self.base_url = "https://ufobeep.com"
        
        if self.api_key:
            self.enabled = True
            self.headers = {
                "accept": "application/json",
                "api-key": self.api_key,
                "content-type": "application/json"
            }
            logger.info("Brevo email service initialized")
        else:
            self.enabled = False
            logger.warning("Brevo email service disabled (no API key)")
            logger.info("Get your FREE API key at: https://app.brevo.com/settings/keys/api")
    
    def generate_verification_token(self) -> str:
        """Generate a secure random verification token"""
        return secrets.token_urlsafe(32)
    
    def generate_recovery_code(self) -> str:
        """Generate a 6-digit recovery code"""
        return f"{secrets.randbelow(999999):06d}"
    
    async def send_verification_email(self, 
                                     to_email: str, 
                                     username: str, 
                                     token: str) -> Dict:
        """
        Send verification email using Brevo
        FREE: 300 emails/day, 9000/month
        """
        if not self.enabled:
            return {
                "success": False, 
                "error": "Email service not configured. Set BREVO_API_KEY in .env"
            }
        
        try:
            verification_url = f"{self.base_url}/verify?token={token}"
            
            payload = {
                "sender": {
                    "name": self.from_name,
                    "email": self.from_email
                },
                "to": [
                    {
                        "email": to_email,
                        "name": username
                    }
                ],
                "subject": f"Welcome to UFOBeep, {username}! 🛸",
                "htmlContent": f"""
                <!DOCTYPE html>
                <html>
                <head>
                    <meta charset="UTF-8">
                    <meta name="viewport" content="width=device-width, initial-scale=1.0">
                </head>
                <body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif;">
                    <div style="max-width: 600px; margin: 0 auto; background: #000000;">
                        <!-- Header with gradient -->
                        <div style="background: linear-gradient(135deg, #00ff88 0%, #0088ff 100%); padding: 40px 20px; text-align: center;">
                            <h1 style="color: white; margin: 0; font-size: 36px; text-shadow: 0 2px 4px rgba(0,0,0,0.3);">
                                🛸 UFOBeep
                            </h1>
                            <p style="color: rgba(255,255,255,0.95); margin: 10px 0 0 0; font-size: 16px;">
                                Global UFO Alert Network
                            </p>
                        </div>
                        
                        <!-- Main content -->
                        <div style="background: #1a1a1a; padding: 40px 30px; color: #ffffff;">
                            <h2 style="color: #00ff88; margin-top: 0; font-size: 24px;">
                                Welcome aboard, {username}!
                            </h2>
                            
                            <p style="color: #cccccc; line-height: 1.6; font-size: 16px;">
                                You're one click away from joining thousands of sky watchers worldwide. 
                                Verify your email to unlock:
                            </p>
                            
                            <div style="background: #2a2a2a; border-left: 4px solid #00ff88; padding: 20px; margin: 25px 0; border-radius: 4px;">
                                <ul style="color: #cccccc; line-height: 2; margin: 0; padding-left: 20px; font-size: 15px;">
                                    <li><strong style="color: #00ff88;">Account Recovery</strong> - Never lose access</li>
                                    <li><strong style="color: #00ff88;">Multi-Device Sync</strong> - Use on all devices</li>
                                    <li><strong style="color: #00ff88;">Priority Alerts</strong> - Get notified first</li>
                                    <li><strong style="color: #00ff88;">Verified Status</strong> - Build trust</li>
                                </ul>
                            </div>
                            
                            <div style="text-align: center; margin: 35px 0;">
                                <a href="{verification_url}" 
                                   style="display: inline-block;
                                          background: linear-gradient(135deg, #00ff88 0%, #00cc66 100%);
                                          color: #000000;
                                          padding: 16px 40px;
                                          text-decoration: none;
                                          border-radius: 50px;
                                          font-weight: bold;
                                          font-size: 16px;
                                          box-shadow: 0 4px 15px rgba(0,255,136,0.4);
                                          text-transform: uppercase;
                                          letter-spacing: 1px;">
                                    Verify Email Address
                                </a>
                            </div>
                            
                            <p style="color: #666666; font-size: 13px; text-align: center; margin-top: 30px;">
                                Can't click? Copy this link:<br>
                                <code style="color: #00ff88; background: #2a2a2a; padding: 8px; border-radius: 4px; font-size: 11px; word-break: break-all;">
                                    {verification_url}
                                </code>
                            </p>
                        </div>
                        
                        <!-- Footer -->
                        <div style="background: #0a0a0a; padding: 25px; text-align: center; border-top: 1px solid #2a2a2a;">
                            <p style="color: #666666; font-size: 12px; margin: 0 0 10px 0;">
                                This link expires in 24 hours for security.
                            </p>
                            <p style="color: #444444; font-size: 11px; margin: 0;">
                                Didn't sign up? Safely ignore this email.<br>
                                © 2025 UFOBeep - Real-time UFO Alerts
                            </p>
                        </div>
                    </div>
                </body>
                </html>
                """,
                "textContent": f"""
                Welcome to UFOBeep, {username}!
                
                You're one click away from joining thousands of sky watchers worldwide.
                
                Verify your email address:
                {verification_url}
                
                This will unlock:
                • Account Recovery - Never lose access
                • Multi-Device Sync - Use on all devices  
                • Priority Alerts - Get notified first
                • Verified Status - Build trust
                
                This link expires in 24 hours.
                
                Didn't sign up? You can safely ignore this email.
                
                - The UFOBeep Team
                """,
                "tags": ["verification", "welcome"],
                "params": {
                    "USERNAME": username,
                    "VERIFICATION_URL": verification_url
                }
            }
            
            response = requests.post(self.api_url, json=payload, headers=self.headers)
            
            if response.status_code == 201:
                result = response.json()
                logger.info(f"Verification email sent to {to_email}: {result.get('messageId')}")
                return {"success": True, "id": result.get("messageId")}
            else:
                error = response.json()
                logger.error(f"Brevo API error: {error}")
                return {"success": False, "error": error.get("message", "Unknown error")}
                
        except Exception as e:
            logger.error(f"Failed to send verification email: {e}")
            return {"success": False, "error": str(e)}
    
    async def send_recovery_email(self, 
                                 to_email: str, 
                                 username: str, 
                                 recovery_code: str) -> Dict:
        """Send account recovery email with 6-digit code"""
        if not self.enabled:
            return {"success": False, "error": "Email service not configured"}
        
        try:
            payload = {
                "sender": {
                    "name": self.from_name,
                    "email": self.from_email
                },
                "to": [
                    {
                        "email": to_email,
                        "name": username
                    }
                ],
                "subject": "🔑 Your UFOBeep Recovery Code",
                "htmlContent": f"""
                <body style="margin: 0; padding: 0; font-family: -apple-system, system-ui, sans-serif; background: #000;">
                    <div style="max-width: 500px; margin: 0 auto;">
                        <div style="background: #1a1a1a; padding: 40px 30px; text-align: center;">
                            <h1 style="color: #00ff88; margin: 0 0 20px 0;">Account Recovery</h1>
                            
                            <p style="color: #999; margin-bottom: 10px;">Your username:</p>
                            <div style="background: #000; padding: 15px; border-radius: 8px; margin-bottom: 30px;">
                                <h2 style="color: #00ff88; margin: 0; font-family: monospace; font-size: 24px;">
                                    {username}
                                </h2>
                            </div>
                            
                            <p style="color: #999; margin-bottom: 10px;">Recovery code:</p>
                            <div style="background: #00ff88; padding: 20px; border-radius: 8px;">
                                <h1 style="color: #000; margin: 0; font-size: 36px; letter-spacing: 8px; font-family: monospace;">
                                    {recovery_code}
                                </h1>
                            </div>
                            
                            <p style="color: #666; font-size: 14px; margin-top: 20px; line-height: 1.6;">
                                Enter this code in the UFOBeep app<br>
                                Valid for 15 minutes
                            </p>
                        </div>
                    </div>
                </body>
                """,
                "textContent": f"""
                UFOBeep Account Recovery
                
                Your username: {username}
                Recovery code: {recovery_code}
                
                Enter this code in the app to recover your account.
                Valid for 15 minutes.
                
                - UFOBeep Team
                """
            }
            
            response = requests.post(self.api_url, json=payload, headers=self.headers)
            
            if response.status_code == 201:
                result = response.json()
                logger.info(f"Recovery email sent to {to_email}")
                return {"success": True, "id": result.get("messageId")}
            else:
                error = response.json()
                return {"success": False, "error": error.get("message")}
                
        except Exception as e:
            logger.error(f"Failed to send recovery email: {e}")
            return {"success": False, "error": str(e)}
    
    async def test_connection(self) -> Dict:
        """Test Brevo API connection and get account info"""
        if not self.enabled:
            return {"success": False, "error": "No API key configured"}
        
        try:
            # Get account info to verify API key
            response = requests.get(
                "https://api.brevo.com/v3/account",
                headers={"api-key": self.api_key, "accept": "application/json"}
            )
            
            if response.status_code == 200:
                data = response.json()
                plan = data.get("plan", [{}])[0]
                return {
                    "success": True,
                    "company": data.get("companyName", "Unknown"),
                    "email": data.get("email"),
                    "plan_type": plan.get("type", "free"),
                    "credits_remaining": plan.get("creditsRemaining"),
                    "daily_limit": 300,  # Free tier limit
                    "monthly_limit": 9000  # Free tier limit
                }
            else:
                return {"success": False, "error": "Invalid API key"}
                
        except Exception as e:
            return {"success": False, "error": str(e)}

# Global service instance
email_service = None

async def get_email_service():
    """Get or create email service instance"""
    global email_service
    if email_service is None:
        email_service = BrevoEmailService()
    return email_service

# Quick setup instructions
"""
BREVO SETUP (5 minutes):

1. Sign up FREE (no credit card): https://app.brevo.com/
2. Verify your sender domain: ufobeep.com
3. Get API key: https://app.brevo.com/settings/keys/api
4. Add to .env: BREVO_API_KEY=xkeysib-xxxxxxxxxxxxx
5. That's it! 300 free emails/day

BENEFITS:
✅ 300 emails/day FREE (3x more than others)
✅ 9,000 emails/month FREE
✅ No credit card required
✅ Excellent deliverability
✅ Built-in analytics
✅ Scales to unlimited for $25/mo

RADIO SPIKE READY:
- Free tier handles 300 signups/day
- Instant upgrade to unlimited if needed
- No code changes required
"""