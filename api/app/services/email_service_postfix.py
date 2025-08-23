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
                 from_email: str = "support@ufobeep.com",
                 from_name: str = "UFOBeep Support"):
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
                    body {{ 
                        font-family: Arial, sans-serif; 
                        background: #f5f5f5; 
                        color: #333333; 
                        margin: 0; 
                        padding: 0;
                    }}
                    .container {{ 
                        max-width: 600px; 
                        margin: 0 auto; 
                        padding: 20px; 
                        background: #f5f5f5;
                    }}
                    .header {{ 
                        text-align: center; 
                        padding: 20px 0;
                    }}
                    .content {{ 
                        background: #ffffff; 
                        padding: 40px; 
                        border-radius: 10px; 
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                        border: 1px solid #e0e0e0;
                    }}
                    .button {{ 
                        display: inline-block; 
                        padding: 15px 30px; 
                        background: #00ff88; 
                        color: #000000; 
                        text-decoration: none; 
                        border-radius: 8px; 
                        font-weight: bold;
                        font-size: 16px;
                        margin: 20px 0;
                        box-shadow: 0 2px 5px rgba(0,255,136,0.3);
                    }}
                    .button:hover {{
                        background: #00d973;
                    }}
                    .footer {{ 
                        text-align: center; 
                        margin-top: 30px; 
                        color: #666; 
                        font-size: 14px; 
                    }}
                    h1 {{ 
                        color: #333; 
                        margin: 0;
                        font-size: 32px;
                    }}
                    h2 {{ 
                        color: #333; 
                        margin-bottom: 20px;
                        font-size: 24px;
                    }}
                    p {{ 
                        color: #555; 
                        line-height: 1.6;
                        font-size: 16px;
                    }}
                    ul {{
                        color: #555;
                        line-height: 1.8;
                    }}
                    li {{
                        margin-bottom: 8px;
                    }}
                    .link-text {{
                        color: #007bff;
                        font-size: 14px;
                        word-break: break-all;
                        background: #f8f9fa;
                        padding: 8px;
                        border-radius: 4px;
                        border: 1px solid #dee2e6;
                    }}
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
                                ✅ Verify Email Address
                            </a>
                        </center>
                        <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                            <strong>Alternative:</strong> Copy and paste this link in your browser:
                        </p>
                        <div class="link-text">
                            {self.base_url}/verify?token={token}
                        </div>
                        <p style="color: #888; font-size: 14px; margin-top: 30px;">
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
            subject = "Your account access code"
            
            html_body = f"""
            <!DOCTYPE html>
            <html>
            <head>
                <style>
                    body {{ 
                        font-family: Arial, sans-serif; 
                        background: #f5f5f5; 
                        color: #333333; 
                        margin: 0; 
                        padding: 0;
                    }}
                    .container {{ 
                        max-width: 600px; 
                        margin: 0 auto; 
                        padding: 20px; 
                        background: #f5f5f5;
                    }}
                    .header {{ 
                        text-align: center; 
                        padding: 20px 0;
                    }}
                    .content {{ 
                        background: #ffffff; 
                        padding: 40px; 
                        border-radius: 10px; 
                        box-shadow: 0 2px 10px rgba(0,0,0,0.1);
                        border: 1px solid #e0e0e0;
                    }}
                    .username {{ 
                        background: #00ff88; 
                        color: #000000; 
                        padding: 12px 24px; 
                        border-radius: 8px; 
                        font-size: 28px; 
                        font-weight: bold;
                        display: inline-block;
                        margin: 20px 0;
                        letter-spacing: 1px;
                        box-shadow: 0 2px 5px rgba(0,255,136,0.3);
                    }}
                    .recovery-button {{
                        display: inline-block;
                        background: #007bff;
                        color: #ffffff;
                        padding: 15px 30px;
                        text-decoration: none;
                        border-radius: 8px;
                        font-weight: bold;
                        font-size: 16px;
                        margin: 20px 0;
                        box-shadow: 0 2px 5px rgba(0,123,255,0.3);
                    }}
                    .recovery-button:hover {{
                        background: #0056b3;
                    }}
                    .code {{
                        background: #f8f9fa;
                        border: 2px solid #00ff88;
                        color: #000000;
                        padding: 8px 12px;
                        border-radius: 5px;
                        font-family: 'Courier New', monospace;
                        font-weight: bold;
                        font-size: 18px;
                        letter-spacing: 2px;
                    }}
                    .footer {{ 
                        text-align: center; 
                        margin-top: 30px; 
                        color: #666; 
                        font-size: 14px; 
                    }}
                    h2 {{ 
                        color: #333; 
                        margin-bottom: 20px;
                        font-size: 24px;
                    }}
                    p {{ 
                        color: #555; 
                        line-height: 1.6;
                        font-size: 16px;
                    }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="header">
                        <h1 style="color: #333; margin: 0;">🛸 UFOBeep</h1>
                    </div>
                    <div class="content">
                        <h2>Account Recovery</h2>
                        <p>Your UFOBeep username is:</p>
                        <center>
                            <span class="username">{username}</span>
                        </center>
                        <p>To complete recovery on your device, tap the button below from your phone:</p>
                        <center>
                            <a href="ufobeep://recover?token={token}" class="recovery-button">
                                📱 Open UFOBeep App
                            </a>
                        </center>
                        <p style="margin-top: 30px; padding-top: 20px; border-top: 1px solid #eee;">
                            <strong>Alternative:</strong> Open the UFOBeep app and enter this recovery code:
                        </p>
                        <center>
                            <span class="code">{token[:8]}</span>
                        </center>
                        <p style="color: #888; font-size: 14px; margin-top: 30px;">
                            This recovery code expires in 15 minutes. If you didn't request account recovery, you can safely ignore this email.
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