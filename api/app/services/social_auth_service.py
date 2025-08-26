"""
Social authentication service for Google and Apple Sign-In
Handles OAuth token verification and user profile extraction
"""

import json
import secrets
import httpx
import os
from typing import Dict, Optional, Tuple
from datetime import datetime, timedelta


class SocialAuthService:
    """Service for handling social authentication (Google, Apple)"""
    
    def __init__(self):
        self.google_client_id = os.environ.get("GOOGLE_CLIENT_ID")
        self.apple_team_id = os.environ.get("APPLE_TEAM_ID")
        self.apple_key_id = os.environ.get("APPLE_KEY_ID")
        
    async def verify_google_token(self, id_token: str) -> Optional[Dict]:
        """
        Verify Google OAuth ID token and extract user information
        
        Args:
            id_token: Google OAuth ID token from client
            
        Returns:
            Dict with user info (email, name, google_id) or None if invalid
        """
        try:
            # Verify token with Google's tokeninfo endpoint
            async with httpx.AsyncClient() as client:
                response = await client.get(
                    f"https://oauth2.googleapis.com/tokeninfo?id_token={id_token}"
                )
                
                if response.status_code != 200:
                    return None
                    
                token_data = response.json()
                
                # Verify audience (client ID)
                if token_data.get("aud") != self.google_client_id:
                    return None
                    
                # Verify token is not expired
                exp = int(token_data.get("exp", 0))
                if datetime.utcnow().timestamp() > exp:
                    return None
                    
                return {
                    "google_id": token_data.get("sub"),
                    "email": token_data.get("email"),
                    "name": token_data.get("name"),
                    "picture": token_data.get("picture"),
                    "verified_email": token_data.get("email_verified", False)
                }
                
        except Exception as e:
            print(f"Error verifying Google token: {e}")
            return None
    
    async def verify_apple_token(self, id_token: str, user_id: str) -> Optional[Dict]:
        """
        Verify Apple Sign-In ID token and extract user information
        
        Args:
            id_token: Apple Sign-In ID token from client
            user_id: Apple user identifier
            
        Returns:
            Dict with user info (email, name, apple_id) or None if invalid
        """
        try:
            # Apple Sign-In verification is more complex, requires JWT verification
            # For now, basic validation - in production would use PyJWT with Apple's public keys
            
            # Decode JWT payload (without verification for MVP)
            import base64
            
            # Split JWT and decode payload
            parts = id_token.split('.')
            if len(parts) != 3:
                return None
                
            # Decode payload (add padding if needed)
            payload = parts[1]
            payload += '=' * (4 - len(payload) % 4)
            decoded = base64.urlsafe_b64decode(payload)
            token_data = json.loads(decoded)
            
            # Basic validation
            if token_data.get("sub") != user_id:
                return None
                
            # Check expiration
            exp = int(token_data.get("exp", 0))
            if datetime.utcnow().timestamp() > exp:
                return None
                
            return {
                "apple_id": token_data.get("sub"),
                "email": token_data.get("email"),
                # Apple doesn't always provide email (privacy feature)
                "name": None,  # Apple provides this separately in first login
                "verified_email": True  # Apple emails are always verified
            }
            
        except Exception as e:
            print(f"Error verifying Apple token: {e}")
            return None
    
    def generate_username_from_social(self, profile_data: Dict) -> str:
        """
        Generate a cosmic username from social profile data
        
        Args:
            profile_data: User profile from social provider
            
        Returns:
            Generated username like 'cosmic-whisper-7823'
        """
        from ..services.username_service import UsernameService
        
        username_service = UsernameService()
        
        # Try to use name for inspiration, but still generate randomly
        name_hint = profile_data.get("name", "").lower().replace(" ", "") if profile_data.get("name") else None
        
        return username_service.generate_username(name_hint=name_hint)
    
    def generate_magic_link_token(self) -> Tuple[str, datetime]:
        """
        Generate secure magic link token with expiration
        
        Returns:
            Tuple of (token, expiration_datetime)
        """
        # Generate cryptographically secure random token
        token = secrets.token_urlsafe(32)
        
        # Set expiration (15 minutes from now)
        expiry = datetime.utcnow() + timedelta(minutes=15)
        
        return token, expiry
    
    async def send_magic_link_email(self, email: str, username: str, token: str):
        """
        Send magic link login email to user
        
        Args:
            email: User's email address
            username: User's cosmic username
            token: Magic link token
        """
        from ..services.email_service_postfix import PostfixEmailService
        
        email_service = PostfixEmailService()
        
        # Magic link URL
        magic_link = f"https://ufobeep.com/auth/magic?token={token}"
        
        # Email template
        subject = "🛸 Login to UFOBeep"
        
        html_content = f"""
        <html>
        <body style="font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif; line-height: 1.6; color: #333;">
            <div style="max-width: 600px; margin: 0 auto; padding: 20px;">
                <h2 style="color: #6366f1; margin-bottom: 20px;">🛸 Login to UFOBeep</h2>
                
                <p>Hi <strong>{username}</strong>,</p>
                
                <p>Click the button below to securely login to your UFOBeep account:</p>
                
                <div style="text-align: center; margin: 30px 0;">
                    <a href="{magic_link}" 
                       style="background: #6366f1; color: white; padding: 15px 30px; 
                              border-radius: 8px; text-decoration: none; font-weight: 600;
                              display: inline-block;">
                        Login to UFOBeep
                    </a>
                </div>
                
                <p style="color: #666; font-size: 14px;">
                    <strong>Security note:</strong> This link expires in 15 minutes and can only be used once.
                    If you didn't request this login, you can safely ignore this email.
                </p>
                
                <p style="color: #666; font-size: 12px; margin-top: 30px; border-top: 1px solid #eee; padding-top: 20px;">
                    UFOBeep - Real-time sighting alerts<br>
                    <a href="https://ufobeep.com" style="color: #6366f1;">ufobeep.com</a>
                </p>
            </div>
        </body>
        </html>
        """
        
        # Also send as plain text for better deliverability
        text_content = f"""Hi {username},

Click this link to securely login to your UFOBeep account:

{magic_link}

This link expires in 15 minutes and can only be used once.
If you didn't request this login, you can safely ignore this email.

--
UFOBeep - Real-time sighting alerts
https://ufobeep.com
"""
        
        # Professional HTML template that looks good and avoids spam triggers
        simple_html = f"""<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
</head>
<body style="margin: 0; padding: 0; font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, sans-serif; background-color: #f6f6f6;">
    <table width="100%" cellpadding="0" cellspacing="0" style="background-color: #f6f6f6; padding: 20px 0;">
        <tr>
            <td align="center">
                <table width="600" cellpadding="0" cellspacing="0" style="background-color: #ffffff; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1);">
                    <!-- Header -->
                    <tr>
                        <td style="padding: 30px 40px; text-align: center; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); border-radius: 8px 8px 0 0;">
                            <h1 style="margin: 0; color: #ffffff; font-size: 32px;">🛸 UFOBeep</h1>
                            <p style="margin: 5px 0 0; color: #ffffff; font-size: 14px; opacity: 0.95;">Real-time Sighting Alerts</p>
                        </td>
                    </tr>
                    
                    <!-- Content -->
                    <tr>
                        <td style="padding: 40px 40px 30px;">
                            <h2 style="margin: 0 0 20px; color: #333333; font-size: 24px; font-weight: 600;">Welcome back, {username}!</h2>
                            
                            <p style="margin: 0 0 25px; color: #666666; font-size: 16px; line-height: 1.5;">
                                You requested a secure login link. Click the button below to access your UFOBeep account:
                            </p>
                            
                            <!-- CTA Button -->
                            <table width="100%" cellpadding="0" cellspacing="0">
                                <tr>
                                    <td align="center" style="padding: 0 0 25px;">
                                        <a href="{magic_link}" style="display: inline-block; padding: 14px 32px; background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: #ffffff; text-decoration: none; font-size: 16px; font-weight: 600; border-radius: 50px; box-shadow: 0 4px 12px rgba(102, 126, 234, 0.4);">
                                            Sign In to UFOBeep
                                        </a>
                                    </td>
                                </tr>
                            </table>
                            
                            <p style="margin: 0 0 20px; color: #999999; font-size: 14px; line-height: 1.5;">
                                Or copy and paste this link in your browser:<br>
                                <span style="color: #667eea; word-break: break-all; font-size: 12px;">{magic_link}</span>
                            </p>
                            
                            <!-- Security Notice -->
                            <table width="100%" cellpadding="0" cellspacing="0" style="border-top: 1px solid #eeeeee; padding-top: 20px; margin-top: 25px;">
                                <tr>
                                    <td>
                                        <p style="margin: 0; color: #999999; font-size: 13px; line-height: 1.5;">
                                            <strong>🔒 Security Notice:</strong><br>
                                            • This link expires in 15 minutes<br>
                                            • It can only be used once<br>
                                            • Never share this link with anyone
                                        </p>
                                    </td>
                                </tr>
                            </table>
                        </td>
                    </tr>
                    
                    <!-- Footer -->
                    <tr>
                        <td style="padding: 20px 40px; background-color: #f8f9fa; border-radius: 0 0 8px 8px; text-align: center; border-top: 1px solid #eeeeee;">
                            <p style="margin: 0 0 5px; color: #999999; font-size: 12px;">
                                Didn't request this? You can safely ignore this email.
                            </p>
                            <p style="margin: 0; color: #999999; font-size: 12px;">
                                © 2025 UFOBeep · <a href="https://ufobeep.com" style="color: #667eea; text-decoration: none;">ufobeep.com</a>
                            </p>
                        </td>
                    </tr>
                </table>
            </td>
        </tr>
    </table>
</body>
</html>"""
        
        await email_service.send_html_email(
            to_email=email,
            subject=subject,
            html_content=simple_html
        )