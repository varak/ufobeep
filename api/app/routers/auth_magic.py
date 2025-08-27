from fastapi import APIRouter, HTTPException, Depends, Request, BackgroundTasks
from sqlalchemy.orm import Session
from sqlalchemy import and_, func
from datetime import datetime, timezone, timedelta
from pydantic import BaseModel, EmailStr
import secrets
import hashlib
import logging
from typing import Optional

from app.core.database import get_db
from app.models import MagicLink, MagicLinkAttempt, User
from app.core.auth import create_access_token
from app.config.environment import settings
from app.services.email_service_postfix import get_email_service

logger = logging.getLogger(__name__)

router = APIRouter(prefix="/auth/magic", tags=["magic-link-auth"])


# Request/Response Models
class MagicLinkStartRequest(BaseModel):
    email: EmailStr


class MagicLinkStartResponse(BaseModel):
    success: bool
    message: str
    rate_limit_reset: Optional[int] = None


class MagicLinkCompleteRequest(BaseModel):
    token: str


class MagicLinkCompleteResponse(BaseModel):
    success: bool
    message: str
    access_token: Optional[str] = None
    user_id: Optional[str] = None
    username: Optional[str] = None
    email: Optional[str] = None
    is_new_user: bool = False


# Configuration
MAGIC_LINK_EXPIRY_MINUTES = 15
RATE_LIMIT_WINDOW_MINUTES = 5
MAX_ATTEMPTS_PER_WINDOW = 3
TOKEN_LENGTH = 32


def get_client_ip(request: Request) -> str:
    """Extract client IP address from request"""
    forwarded = request.headers.get("X-Forwarded-For")
    if forwarded:
        return forwarded.split(",")[0].strip()
    return request.client.host if request.client else "unknown"


def check_rate_limit(email: str, ip_address: str, db: Session) -> bool:
    """Check if email/IP has exceeded rate limits"""
    cutoff = datetime.now(timezone.utc) - timedelta(minutes=RATE_LIMIT_WINDOW_MINUTES)
    
    # Check attempts for this email in the time window
    email_attempts = db.query(func.count(MagicLinkAttempt.id)).filter(
        and_(
            MagicLinkAttempt.email == email,
            MagicLinkAttempt.created_at >= cutoff
        )
    ).scalar()
    
    # Check attempts from this IP in the time window
    ip_attempts = db.query(func.count(MagicLinkAttempt.id)).filter(
        and_(
            MagicLinkAttempt.ip_address == ip_address,
            MagicLinkAttempt.created_at >= cutoff
        )
    ).scalar()
    
    return email_attempts < MAX_ATTEMPTS_PER_WINDOW and ip_attempts < MAX_ATTEMPTS_PER_WINDOW


def create_magic_link_token() -> tuple[str, str]:
    """Create a secure magic link token and its hash"""
    # Generate a secure random token
    token = secrets.token_urlsafe(TOKEN_LENGTH)
    
    # Create hash for database storage
    token_hash = hashlib.sha256(token.encode()).hexdigest()
    
    return token, token_hash


async def send_magic_link_email(email: str, token: str, background_tasks: BackgroundTasks):
    """Send magic link email using PostfixEmailService"""
    async def send_email():
        try:
            email_service = await get_email_service()
            
            # Create both app link and web fallback
            app_link = f"ufobeep://auth/magic?token={token}"
            web_link = f"https://api.ufobeep.com/auth/magic/complete?token={token}"
            
            # Create professional email content using UFOBeep theme
            html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Sign In</title>
    <style>
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif; 
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
            background: #ffffff;
            border-radius: 10px 10px 0 0;
        }}
        .content {{ 
            background: #ffffff; 
            padding: 40px; 
            border-radius: 0 0 10px 10px; 
            box-shadow: 0 4px 20px rgba(0,0,0,0.1);
            border: 1px solid #e0e0e0;
            border-top: none;
        }}
        .app-button {{ 
            display: inline-block; 
            padding: 16px 32px; 
            background: #00ff88; 
            color: #000000; 
            text-decoration: none; 
            border-radius: 8px; 
            font-weight: bold;
            font-size: 18px;
            margin: 20px 0;
            box-shadow: 0 3px 10px rgba(0,255,136,0.3);
            transition: background 0.3s ease;
        }}
        .app-button:hover {{
            background: #00d973;
        }}
        .web-fallback {{
            background: #f8f9fa;
            border: 1px solid #dee2e6;
            border-radius: 8px;
            padding: 20px;
            margin: 20px 0;
        }}
        .web-button {{
            display: inline-block;
            background: #007bff;
            color: #ffffff;
            padding: 12px 24px;
            text-decoration: none;
            border-radius: 6px;
            font-weight: 600;
            font-size: 16px;
            margin: 10px 0;
        }}
        .web-button:hover {{
            background: #0056b3;
        }}
        .footer {{ 
            text-align: center; 
            margin-top: 30px; 
            color: #666; 
            font-size: 14px; 
        }}
        .logo {{
            font-size: 32px;
            font-weight: bold;
            color: #00ff88;
            margin: 0;
            text-decoration: none;
        }}
        .tagline {{
            color: #666;
            font-size: 16px;
            margin: 8px 0;
        }}
        h2 {{ 
            color: #333; 
            margin: 0 0 20px 0;
            font-size: 24px;
        }}
        p {{ 
            color: #555; 
            line-height: 1.6;
            font-size: 16px;
            margin: 16px 0;
        }}
        .security-note {{
            background: #f8f9fa;
            border-left: 4px solid #00ff88;
            padding: 15px;
            margin: 20px 0;
            font-size: 14px;
            color: #666;
        }}
        .link-text {{
            color: #007bff;
            font-size: 14px;
            word-break: break-all;
            background: #f8f9fa;
            padding: 10px;
            border-radius: 4px;
            border: 1px solid #dee2e6;
            font-family: 'Courier New', monospace;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <div class="logo">🛸 UFOBeep</div>
            <div class="tagline">Real-time sighting alerts</div>
        </div>
        <div class="content">
            <h2>Sign in to your account</h2>
            <p>Click the button below to securely sign in to UFOBeep. This magic link will expire in 15 minutes for your security.</p>
            
            <center>
                <a href="{app_link}" class="app-button">
                    📱 Open UFOBeep App
                </a>
            </center>
            
            <div class="web-fallback">
                <h3 style="margin: 0 0 12px 0; color: #333; font-size: 16px;">Can't open the app?</h3>
                <p style="margin: 0 0 12px 0; color: #666; font-size: 14px;">
                    Use this web link instead:
                </p>
                <center>
                    <a href="{web_link}" class="web-button">
                        🌐 Sign in via Web
                    </a>
                </center>
                <div class="link-text" style="margin-top: 12px;">
                    {web_link}
                </div>
            </div>
            
            <div class="security-note">
                <strong>Security Notice:</strong> This magic link is unique to you and will expire in 15 minutes. 
                If you didn't request this sign-in link, you can safely ignore this email.
            </div>
        </div>
        <div class="footer">
            <p>UFOBeep - Real-time UFO Alert Network</p>
            <p>This email was sent from noreply@ufobeep.com</p>
        </div>
    </div>
</body>
</html>
            """
            
            # Send using PostfixEmailService
            success = await email_service.send_html_email(
                to_email=email,
                subject="Sign in to UFOBeep - Magic Link",
                html_content=html_content
            )
            
            if success:
                logger.info(f"Magic link email sent successfully to {email}")
            else:
                logger.error(f"Failed to send magic link email to {email}")
                
        except Exception as e:
            logger.error(f"Error in magic link email background task: {str(e)}")
    
    background_tasks.add_task(send_email)


@router.post("/start", response_model=MagicLinkStartResponse)
async def start_magic_link(
    request: MagicLinkStartRequest,
    http_request: Request,
    background_tasks: BackgroundTasks,
    db: Session = Depends(get_db)
):
    """
    Start magic link authentication process.
    Sends a secure link to the provided email address.
    """
    try:
        email = request.email.lower().strip()
        ip_address = get_client_ip(http_request)
        user_agent = http_request.headers.get("User-Agent", "")
        
        logger.info(f"Magic link requested for email: {email} from IP: {ip_address}")
        
        # Check rate limits
        if not check_rate_limit(email, ip_address, db):
            logger.warning(f"Rate limit exceeded for email: {email}, IP: {ip_address}")
            
            # Log the attempt
            attempt = MagicLinkAttempt(
                email=email,
                ip_address=ip_address,
                success=False
            )
            db.add(attempt)
            db.commit()
            
            raise HTTPException(
                status_code=429,
                detail={
                    "message": "Too many attempts. Please wait before requesting another magic link.",
                    "rate_limit_reset": RATE_LIMIT_WINDOW_MINUTES * 60
                }
            )
        
        # Clean up expired magic links for this email
        cutoff = datetime.now(timezone.utc)
        db.query(MagicLink).filter(
            and_(
                MagicLink.email == email,
                MagicLink.expires_at <= cutoff
            )
        ).delete()
        
        # Invalidate any existing unused magic links for this email
        db.query(MagicLink).filter(
            and_(
                MagicLink.email == email,
                MagicLink.used == False
            )
        ).update({"used": True})
        
        # Generate new magic link
        token, token_hash = create_magic_link_token()
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=MAGIC_LINK_EXPIRY_MINUTES)
        
        # Create magic link record
        magic_link = MagicLink(
            email=email,
            hashed_nonce=token_hash,
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address
        )
        
        db.add(magic_link)
        db.commit()
        
        # Send email in background
        send_magic_link_email(email, token, background_tasks)
        
        # Log successful attempt
        attempt = MagicLinkAttempt(
            email=email,
            ip_address=ip_address,
            success=True
        )
        db.add(attempt)
        db.commit()
        
        logger.info(f"Magic link created and email queued for: {email}")
        
        return MagicLinkStartResponse(
            success=True,
            message="Magic link sent! Check your email and click the link to sign in."
        )
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error creating magic link: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Failed to send magic link. Please try again."
        )


@router.get("/complete")
async def complete_magic_link(
    token: str,
    request: Request,
    db: Session = Depends(get_db)
):
    """
    Complete magic link authentication.
    This handles both app deep links and web fallback.
    """
    try:
        token_hash = hashlib.sha256(token.encode()).hexdigest()
        ip_address = get_client_ip(request)
        
        logger.info(f"Magic link completion attempted from IP: {ip_address}")
        
        # Find the magic link
        magic_link = db.query(MagicLink).filter(
            and_(
                MagicLink.hashed_nonce == token_hash,
                MagicLink.used == False
            )
        ).first()
        
        if not magic_link:
            logger.warning(f"Invalid or expired magic link token from IP: {ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired magic link"
            )
        
        if magic_link.is_expired:
            logger.warning(f"Expired magic link for email: {magic_link.email}")
            raise HTTPException(
                status_code=400,
                detail="Magic link has expired. Please request a new one."
            )
        
        # Mark as used
        magic_link.used = True
        
        # Find or create user
        user = db.query(User).filter(User.email == magic_link.email).first()
        is_new_user = user is None
        
        if is_new_user:
            # Create new user
            user = User(
                username=f"user_{secrets.token_hex(4)}",  # Temporary username
                email=magic_link.email,
                is_verified=True,
                last_login=datetime.utcnow()
            )
            db.add(user)
            logger.info(f"Created new user for email: {magic_link.email}")
        else:
            # Update existing user
            user.last_login = datetime.utcnow()
            user.is_verified = True
            logger.info(f"User login for existing email: {magic_link.email}")
        
        db.commit()
        
        # Create access token
        access_token = create_access_token(data={"sub": str(user.id)})
        
        # Check if this looks like a mobile app request
        user_agent = request.headers.get("User-Agent", "").lower()
        is_mobile_app = any(term in user_agent for term in ["ufobeep", "android", "ios", "mobile"])
        
        if is_mobile_app:
            # Return JSON for mobile app
            return MagicLinkCompleteResponse(
                success=True,
                message="Successfully signed in!",
                access_token=access_token,
                user_id=str(user.id),
                username=user.username,
                email=user.email,
                is_new_user=is_new_user
            )
        else:
            # Redirect to web app with token
            from fastapi.responses import RedirectResponse
            web_url = f"https://ufobeep.com/auth/callback?token={access_token}&user_id={user.id}&username={user.username}&is_new_user={is_new_user}"
            return RedirectResponse(url=web_url)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"Error completing magic link: {str(e)}")
        raise HTTPException(
            status_code=500,
            detail="Authentication failed. Please try again."
        )


@router.post("/complete", response_model=MagicLinkCompleteResponse)
async def complete_magic_link_post(
    request: MagicLinkCompleteRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """
    Alternative POST endpoint for magic link completion.
    Used by mobile apps that prefer POST requests.
    """
    return await complete_magic_link(request.token, http_request, db)