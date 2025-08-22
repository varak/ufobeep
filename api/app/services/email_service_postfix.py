"""
Email Service using Postfix - MP14
Simple email verification using local Postfix installation
No external dependencies or API keys required
"""

import smtplib
import secrets
import logging
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from datetime import datetime, timedelta
from typing import Optional

logger = logging.getLogger(__name__)

class PostfixEmailService:
    """Production email service using properly configured Postfix"""
    
    def __init__(self, 
                 smtp_host: str = "localhost",
                 smtp_port: int = 25,
                 from_email: str = "alerts@ufobeep.com",
                 from_name: str = "Alert Network"):
        self.smtp_host = smtp_host
        self.smtp_port = smtp_port
        self.from_email = from_email
        self.from_name = from_name
        self.base_url = "https://ufobeep.com"
        
        # Your server has proper DNS setup:
        # ✅ MX: mail.ufobeep.com  
        # ✅ SPF: v=spf1 a mx ip4:107.152.35.6 ~all
        # ✅ DKIM: OpenDKIM configured
        # This means EXCELLENT deliverability!
    
    def generate_verification_token(self) -> str:
        """Generate a secure random verification token"""
        return secrets.token_urlsafe(32)
    
    async def send_verification_email(self, 
                                     to_email: str, 
                                     username: str, 
                                     token: str) -> bool:
        """Send email verification link"""
        try:
            subject = "Account verification required"
            
            # HTML email body
            html_body = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body {{ font-family: Arial, sans-serif; background: #1a1a1a; color: #ffffff; }}
                    .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                    .header {{ text-align: center; padding: 20px; }}
                    .content {{ background: #2a2a2a; padding: 30px; border-radius: 10px; }}
                    .button {{ 
                        display: inline-block; 
                        padding: 15px 30px; 
                        background: #00ff88; 
                        color: #000000; 
                        text-decoration: none; 
                        border-radius: 5px; 
                        font-weight: bold;
                        margin: 20px 0;
                    }}
                    .footer {{ text-align: center; margin-top: 30px; color: #888; font-size: 12px; }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1>🛸 UFOBeep</h1>
                    </div>
                    <div class="content">
                        <h2>Welcome, {username}!</h2>
                        <p>Thanks for joining UFOBeep, the global UFO alert network.</p>
                        <p>Please verify your email address to enable account recovery. This will allow you to:</p>
                        <ul>
                            <li>Recover your username if you reinstall the app</li>
                            <li>Use the same account on multiple devices</li>
                            <li>Receive important alerts via email (optional)</li>
                        </ul>
                        <center>
                            <a href="{self.base_url}/verify?token={token}" class="button">
                                Verify Email Address
                            </a>
                        </center>
                        <p style="color: #888; font-size: 14px;">
                            Or copy this link: {self.base_url}/verify?token={token}
                        </p>
                        <p style="color: #888; font-size: 12px;">
                            This link expires in 24 hours. If you didn't create a UFOBeep account, 
                            you can safely ignore this email.
                        </p>
                    </div>
                    <div class="footer">
                        <p>UFOBeep - Real-time UFO Alert Network</p>
                        <p>This email was sent from {self.from_email}</p>
                    </div>
                </div>
            </body>
            </html>
            """
            
            # Plain text fallback
            text_body = f"""
            Welcome to UFOBeep, {username}!
            
            Please verify your email address by clicking this link:
            {self.base_url}/verify?token={token}
            
            This will allow you to:
            - Recover your username if you reinstall the app
            - Use the same account on multiple devices
            - Receive important alerts via email (optional)
            
            This link expires in 24 hours.
            
            If you didn't create a UFOBeep account, you can safely ignore this email.
            
            - The UFOBeep Team
            """
            
            return await self._send_email(to_email, subject, html_body, text_body)
            
        except Exception as e:
            logger.error(f"Failed to send verification email to {to_email}: {e}")
            return False
    
    async def send_recovery_email(self, 
                                 to_email: str, 
                                 username: str, 
                                 token: str) -> bool:
        """Send account recovery email"""
        try:
            subject = "Account recovery code"
            
            html_body = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body {{ font-family: Arial, sans-serif; background: #1a1a1a; color: #ffffff; }}
                    .container {{ max-width: 600px; margin: 0 auto; padding: 20px; }}
                    .content {{ background: #2a2a2a; padding: 30px; border-radius: 10px; }}
                    .username {{ 
                        background: #00ff88; 
                        color: #000000; 
                        padding: 10px 20px; 
                        border-radius: 5px; 
                        font-size: 24px; 
                        font-weight: bold;
                        display: inline-block;
                        margin: 20px 0;
                    }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="content">
                        <h2>🛸 Account Recovery</h2>
                        <p>Your UFOBeep username is:</p>
                        <center>
                            <span class="username">{username}</span>
                        </center>
                        <p>To complete recovery on your device, click this link from your phone:</p>
                        <p><a href="ufobeep://recover?token={token}">Open UFOBeep App</a></p>
                        <p style="color: #888; font-size: 12px;">
                            Or use this recovery code in the app: <code>{token[:8]}</code>
                        </p>
                    </div>
                </div>
            </body>
            </html>
            """
            
            text_body = f"""
            UFOBeep Account Recovery
            
            Your username is: {username}
            
            Recovery code: {token[:8]}
            
            Open the UFOBeep app and enter this code to recover your account.
            """
            
            return await self._send_email(to_email, subject, html_body, text_body)
            
        except Exception as e:
            logger.error(f"Failed to send recovery email to {to_email}: {e}")
            return False
    
    async def _send_email(self, 
                         to_email: str, 
                         subject: str, 
                         html_body: str, 
                         text_body: str) -> bool:
        """Send email using local Postfix"""
        try:
            # Create message
            msg = MIMEMultipart('alternative')
            msg['Subject'] = subject
            msg['From'] = f"{self.from_name} <{self.from_email}>"
            msg['To'] = to_email
            msg['Date'] = datetime.now().strftime("%a, %d %b %Y %H:%M:%S +0000")
            
            # Attach parts
            text_part = MIMEText(text_body, 'plain')
            html_part = MIMEText(html_body, 'html')
            msg.attach(text_part)
            msg.attach(html_part)
            
            # Send via local Postfix
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                # No authentication needed for localhost
                server.send_message(msg)
            
            logger.info(f"Email sent successfully to {to_email}")
            return True
            
        except Exception as e:
            logger.error(f"Failed to send email via Postfix: {e}")
            return False
    
    async def test_postfix_connection(self) -> bool:
        """Test if Postfix is accessible"""
        try:
            with smtplib.SMTP(self.smtp_host, self.smtp_port) as server:
                # Just test connection
                server.noop()
            logger.info("Postfix connection successful")
            return True
        except Exception as e:
            logger.error(f"Postfix connection failed: {e}")
            return False

# Global service instance
email_service = PostfixEmailService()

async def get_email_service():
    """Get email service instance"""
    return email_service