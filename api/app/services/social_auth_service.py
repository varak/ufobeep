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
        
        await email_service.send_html_email(
            to_email=email,
            subject=subject,
            html_content=html_content
        )