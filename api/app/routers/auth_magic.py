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
    firebase_custom_token: Optional[str] = None


# Configuration
MAGIC_LINK_EXPIRY_MINUTES = 30  # Extended for better reliability
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


def create_magic_link_token() -> tuple[str, str, str]:
    """Create a secure JWT magic link token with jti"""
    import uuid
    from app.core.auth import create_access_token
    
    # Generate unique jti (JWT ID) for server-side tracking
    jti = str(uuid.uuid4())
    
    # Create JWT token with jti and short expiration
    expires_delta = timedelta(minutes=MAGIC_LINK_EXPIRY_MINUTES)
    token_data = {
        "jti": jti,
        "type": "magic_link",
        "exp": datetime.now(timezone.utc) + expires_delta
    }
    
    jwt_token = create_access_token(data=token_data, expires_delta=expires_delta)
    
    # Create hash of jti for database storage (not the full JWT)
    jti_hash = hashlib.sha256(jti.encode()).hexdigest()
    
    return jwt_token, jti_hash, jti


async def send_magic_link_email(email: str, token: str, background_tasks: BackgroundTasks):
    """Send magic link email using PostfixEmailService"""
    async def send_email():
        try:
            email_service = await get_email_service()
            
            # Create magic link that completes auth and opens app
            magic_link = f"https://api.ufobeep.com/auth/magic/complete?token={token}"
            
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
            <p>Click the button below to securely sign in to UFOBeep. This magic link will expire in 30 minutes for your security.</p>
            
            <center>
                <a href="{magic_link}" class="app-button">
                    🔑 Complete Sign In
                </a>
            </center>
            
            <div class="web-fallback">
                <h3 style="margin: 0 0 12px 0; color: #333; font-size: 16px;">Alternative:</h3>
                <p style="margin: 0 0 12px 0; color: #666; font-size: 14px;">
                    Copy and paste this link in your browser:
                </p>
                <div class="link-text" style="margin-top: 12px;">
                    {magic_link}
                </div>
            </div>
            
            <div class="security-note">
                <strong>Security Notice:</strong> This magic link is unique to you and will expire in 30 minutes. 
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
        
        # Check rate limits (temporarily disabled for debugging)
        # TODO: Re-enable rate limiting after debugging
        if False and not check_rate_limit(email, ip_address, db):
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
        
        # Generate new magic link JWT with jti
        jwt_token, jti_hash, jti = create_magic_link_token()
        expires_at = datetime.now(timezone.utc) + timedelta(minutes=MAGIC_LINK_EXPIRY_MINUTES)
        
        # Create magic link record with jti tracking
        magic_link = MagicLink(
            email=email,
            hashed_nonce=jti_hash,  # Store hashed jti
            jti=jti,  # Store actual jti for lookup
            expires_at=expires_at,
            user_agent=user_agent,
            ip_address=ip_address
        )
        
        db.add(magic_link)
        db.commit()
        
        # Send email in background with JWT token
        await send_magic_link_email(email, jwt_token, background_tasks)
        
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
        from app.core.auth import verify_access_token
        from jose import JWTError
        
        ip_address = get_client_ip(request)
        logger.info(f"Magic link completion attempted from IP: {ip_address}")
        
        # Verify JWT token and extract jti
        try:
            payload = verify_access_token(token)
            jti = payload.get("jti")
            token_type = payload.get("type")
            
            if not jti or token_type != "magic_link":
                logger.warning(f"MAGIC_LINK_ERROR: BAD_TOKEN_TYPE - jti={jti}, type={token_type}, IP={ip_address}")
                raise HTTPException(
                    status_code=400,
                    detail="Invalid magic link token"
                )
                
        except JWTError as e:
            error_str = str(e).lower()
            if "expired" in error_str:
                error_code = "EXPIRED"
            elif "signature" in error_str:
                error_code = "BAD_SIG"  
            elif "audience" in error_str or "issuer" in error_str:
                error_code = "BAD_AUD"
            else:
                error_code = "BAD_TOKEN"
            logger.warning(f"MAGIC_LINK_ERROR: {error_code} - {str(e)}, IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired magic link"
            )
        
        # Find the magic link by jti
        magic_link = db.query(MagicLink).filter(
            and_(
                MagicLink.jti == jti,
                MagicLink.used == False
            )
        ).first()
        
        if not magic_link:
            logger.warning(f"MAGIC_LINK_ERROR: NOT_FOUND_OR_USED - jti={jti[:8]}..., IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Invalid or already used magic link"
            )
        
        if magic_link.is_expired:
            logger.warning(f"MAGIC_LINK_ERROR: LINK_EXPIRED - email={magic_link.email}, expires_at={magic_link.expires_at}, IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Magic link has expired. Please request a new one."
            )
        
        # Find or create user BEFORE marking as used
        user = db.query(User).filter(User.email == magic_link.email).first()
        is_new_user = user is None
        
        if is_new_user:
            # Create new user with collision-resistant username
            max_retries = 5
            for attempt in range(max_retries):
                try:
                    # Use longer random string to avoid collisions
                    random_suffix = secrets.token_hex(8)  # 16 characters instead of 8
                    username = f"user_{random_suffix}"
                    
                    user = User(
                        username=username,
                        email=magic_link.email,
                        is_verified=True,
                        last_login=datetime.utcnow()
                    )
                    db.add(user)
                    db.flush()  # This will raise error if username collision occurs
                    logger.info(f"MAGIC_LINK_SUCCESS: NEW_USER - email={magic_link.email}, username={username}, IP={ip_address}")
                    break
                except Exception as e:
                    error_msg = str(e).lower()
                    if ("unique" in error_msg or "duplicate" in error_msg) and attempt < max_retries - 1:
                        # Username collision, try again with different random string
                        logger.warning(f"MAGIC_LINK_RETRY: USERNAME_COLLISION - attempt={attempt+1}, email={magic_link.email}, error={str(e)}, IP={ip_address}")
                        db.rollback()
                        continue
                    else:
                        # Non-collision error or max retries exceeded
                        logger.error(f"MAGIC_LINK_ERROR: USER_CREATION_FAILED - {str(e)}, email={magic_link.email}, attempt={attempt+1}, IP={ip_address}, full_error={repr(e)}")
                        db.rollback()  # Ensure clean state
                        raise HTTPException(
                            status_code=500,
                            detail=f"Failed to create user account: {str(e)}. Please try again."
                        )
        else:
            # Update existing user
            user.last_login = datetime.utcnow()
            user.is_verified = True
            logger.info(f"MAGIC_LINK_SUCCESS: EXISTING_USER - email={magic_link.email}, IP={ip_address}")
        
        # Create access token
        access_token = create_access_token(data={"sub": str(user.id)})
        
        # Only mark as used after successful session creation
        magic_link.used = True
        db.commit()
        
        logger.info(f"MAGIC_LINK_COMPLETE: SUCCESS - user_id={user.id}, jti={jti[:8]}..., IP={ip_address}")
        
        # Check if this looks like a mobile browser
        user_agent = request.headers.get("User-Agent", "").lower()
        is_mobile = any(term in user_agent for term in ["android", "iphone", "ipad", "mobile"])
        
        if is_mobile:
            # Create app deep link with auth data
            app_deep_link = f"ufobeep://auth/complete?token={access_token}&user_id={user.id}&username={user.username}&email={user.email}&is_new_user={is_new_user}"
            
            # Return HTML page that tries to open app, falls back to download
            from fastapi.responses import HTMLResponse
            html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Opening UFOBeep...</title>
    <style>
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #0f1419; 
            color: #ccd6f6; 
            margin: 0; 
            padding: 20px;
            text-align: center;
        }}
        .container {{ 
            max-width: 400px; 
            margin: 50px auto; 
            padding: 40px 20px;
            background: #1a1f2e;
            border-radius: 12px;
        }}
        .logo {{ 
            font-size: 32px; 
            color: #00d4ff; 
            margin-bottom: 20px;
        }}
        .message {{ 
            font-size: 18px; 
            margin-bottom: 30px;
        }}
        .download-btn {{ 
            display: inline-block;
            background: #00ff88;
            color: #0f1419;
            padding: 16px 32px;
            text-decoration: none;
            border-radius: 8px;
            font-weight: bold;
            font-size: 16px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🛸 UFOBeep</div>
        <div class="message">
            Authentication successful!<br>
            Opening the app...
        </div>
        <a href="https://ufobeep.com/downloads/ufobeep-latest.apk" class="download-btn">
            Download App if Not Installed
        </a>
    </div>
    
    <script>
        // Try to open the app immediately
        window.location.href = "{app_deep_link}";
        
        // Fallback: try again after a short delay
        setTimeout(function() {{
            window.location.href = "{app_deep_link}";
        }}, 1000);
    </script>
</body>
</html>
            """
            return HTMLResponse(content=html_content)
        else:
            # Desktop browser - show instructions
            from fastapi.responses import HTMLResponse
            html_content = f"""
<!DOCTYPE html>
<html>
<head>
    <meta charset="utf-8">
    <title>UFOBeep Sign In Complete</title>
    <style>
        body {{ 
            font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, Arial, sans-serif;
            background: #0f1419; 
            color: #ccd6f6; 
            margin: 0; 
            padding: 20px;
            text-align: center;
        }}
        .container {{ 
            max-width: 500px; 
            margin: 50px auto; 
            padding: 40px;
            background: #1a1f2e;
            border-radius: 12px;
        }}
        .logo {{ 
            font-size: 36px; 
            color: #00d4ff; 
            margin-bottom: 20px;
        }}
    </style>
</head>
<body>
    <div class="container">
        <div class="logo">🛸 UFOBeep</div>
        <h2>Sign In Successful!</h2>
        <p>Your account <strong>{user.username}</strong> has been authenticated.</p>
        <p>Please open the UFOBeep app on your mobile device to continue.</p>
        <a href="https://ufobeep.com/downloads/ufobeep-latest.apk" style="color: #00ff88;">Download UFOBeep App</a>
    </div>
</body>
</html>
            """
            return HTMLResponse(content=html_content)
        
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


@router.get("/status")
async def magic_link_status(
    jti: str,
    request: Request,
    db: Session = Depends(get_db)
):
    """
    Debug endpoint to check magic link token status.
    Returns validity and reason for any failures.
    """
    try:
        ip_address = get_client_ip(request)
        logger.info(f"Magic link status check - jti={jti[:8]}..., IP={ip_address}")
        
        # Find the magic link by jti
        magic_link = db.query(MagicLink).filter(MagicLink.jti == jti).first()
        
        if not magic_link:
            return {
                "valid": False,
                "reason": "NOT_FOUND",
                "message": "Magic link not found",
                "jti": jti[:8] + "...",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        
        # Check expiration
        if magic_link.is_expired:
            return {
                "valid": False,
                "reason": "EXPIRED", 
                "message": f"Magic link expired at {magic_link.expires_at}",
                "email": magic_link.email,
                "expires_at": magic_link.expires_at.isoformat(),
                "jti": jti[:8] + "...",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        
        # Check if already used
        if magic_link.used:
            return {
                "valid": False,
                "reason": "ALREADY_USED",
                "message": "Magic link has already been used",
                "email": magic_link.email,
                "jti": jti[:8] + "...",
                "timestamp": datetime.now(timezone.utc).isoformat()
            }
        
        # Valid and unused
        return {
            "valid": True,
            "reason": "VALID",
            "message": "Magic link is valid and unused",
            "email": magic_link.email,
            "expires_at": magic_link.expires_at.isoformat(),
            "jti": jti[:8] + "...",
            "timestamp": datetime.now(timezone.utc).isoformat()
        }
        
    except Exception as e:
        logger.error(f"Error checking magic link status: {str(e)}")
        return {
            "valid": False,
            "reason": "ERROR",
            "message": f"Status check failed: {str(e)}",
            "jti": jti[:8] + "..." if len(jti) > 8 else jti,
            "timestamp": datetime.now(timezone.utc).isoformat()
        }


@router.post("/complete/app", response_model=MagicLinkCompleteResponse)
async def complete_magic_link_app(
    request: MagicLinkCompleteRequest,
    http_request: Request,
    db: Session = Depends(get_db)
):
    """
    Mobile app token exchange endpoint for HTTPS App Links.
    Exchanges JWT token for user session data and Firebase custom token.
    ChatGPT's recommended approach for token-only HTTPS deep links.
    """
    try:
        from app.core.auth import verify_access_token, create_access_token
        from jose import JWTError
        import firebase_admin
        from firebase_admin import auth as firebase_auth
        
        ip_address = get_client_ip(http_request)
        logger.info(f"App token exchange attempted from IP: {ip_address}")
        
        # Verify JWT token and extract jti
        try:
            payload = verify_access_token(request.token)
            jti = payload.get("jti")
            token_type = payload.get("type")
            
            if not jti or token_type != "magic_link":
                logger.warning(f"APP_TOKEN_EXCHANGE: BAD_TOKEN_TYPE - jti={jti}, type={token_type}, IP={ip_address}")
                raise HTTPException(
                    status_code=400,
                    detail="Invalid magic link token"
                )
                
        except JWTError as e:
            error_str = str(e).lower()
            if "expired" in error_str:
                error_code = "EXPIRED"
            elif "signature" in error_str:
                error_code = "BAD_SIG"  
            elif "audience" in error_str or "issuer" in error_str:
                error_code = "BAD_AUD"
            else:
                error_code = "BAD_TOKEN"
            logger.warning(f"APP_TOKEN_EXCHANGE: {error_code} - {str(e)}, IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Invalid or expired magic link"
            )
        
        # Find the magic link by jti
        magic_link = db.query(MagicLink).filter(
            and_(
                MagicLink.jti == jti,
                MagicLink.used == False
            )
        ).first()
        
        if not magic_link:
            logger.warning(f"APP_TOKEN_EXCHANGE: NOT_FOUND_OR_USED - jti={jti[:8]}..., IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Invalid or already used magic link"
            )
        
        if magic_link.is_expired:
            logger.warning(f"APP_TOKEN_EXCHANGE: LINK_EXPIRED - email={magic_link.email}, expires_at={magic_link.expires_at}, IP={ip_address}")
            raise HTTPException(
                status_code=400,
                detail="Magic link has expired. Please request a new one."
            )
        
        # Find or create user BEFORE marking as used
        user = db.query(User).filter(User.email == magic_link.email).first()
        is_new_user = user is None
        
        if is_new_user:
            # Create new user with collision-resistant username
            max_retries = 5
            for attempt in range(max_retries):
                try:
                    # Use longer random string to avoid collisions
                    random_suffix = secrets.token_hex(8)  # 16 characters
                    username = f"user_{random_suffix}"
                    
                    user = User(
                        username=username,
                        email=magic_link.email,
                        is_verified=True,
                        last_login=datetime.utcnow()
                    )
                    db.add(user)
                    db.flush()  # This will raise error if username collision occurs
                    logger.info(f"APP_TOKEN_EXCHANGE: NEW_USER - email={magic_link.email}, username={username}, IP={ip_address}")
                    break
                except Exception as e:
                    error_msg = str(e).lower()
                    if ("unique" in error_msg or "duplicate" in error_msg) and attempt < max_retries - 1:
                        # Username collision, try again with different random string
                        logger.warning(f"APP_TOKEN_EXCHANGE: USERNAME_COLLISION - attempt={attempt+1}, email={magic_link.email}, error={str(e)}, IP={ip_address}")
                        db.rollback()
                        continue
                    else:
                        # Non-collision error or max retries exceeded
                        logger.error(f"APP_TOKEN_EXCHANGE: USER_CREATION_FAILED - {str(e)}, email={magic_link.email}, attempt={attempt+1}, IP={ip_address}")
                        db.rollback()
                        raise HTTPException(
                            status_code=500,
                            detail=f"Failed to create user account: {str(e)}. Please try again."
                        )
        else:
            # Update existing user
            user.last_login = datetime.utcnow()
            user.is_verified = True
            logger.info(f"APP_TOKEN_EXCHANGE: EXISTING_USER - email={magic_link.email}, IP={ip_address}")
        
        # Create new access token for app session
        access_token = create_access_token(data={"sub": str(user.id)})
        
        # Create Firebase custom token for authentication
        firebase_custom_token = None
        try:
            firebase_custom_token = firebase_auth.create_custom_token(str(user.id))
            # Convert bytes to string if needed
            if isinstance(firebase_custom_token, bytes):
                firebase_custom_token = firebase_custom_token.decode('utf-8')
            logger.info(f"APP_TOKEN_EXCHANGE: FIREBASE_TOKEN_CREATED - user_id={user.id}, IP={ip_address}")
        except Exception as e:
            logger.warning(f"APP_TOKEN_EXCHANGE: FIREBASE_TOKEN_FAILED - {str(e)}, user_id={user.id}, IP={ip_address}")
            # Continue without Firebase token - not critical for basic auth
        
        # Only mark as used after successful session creation
        magic_link.used = True
        db.commit()
        
        logger.info(f"APP_TOKEN_EXCHANGE: SUCCESS - user_id={user.id}, jti={jti[:8]}..., IP={ip_address}")
        
        # Return user session data for app authentication
        response_data = {
            "success": True,
            "message": "Authentication successful",
            "user_id": str(user.id),
            "username": user.username,
            "email": user.email,
            "access_token": access_token,
            "is_new_user": is_new_user
        }
        
        # Add Firebase token if available
        if firebase_custom_token:
            response_data["firebase_custom_token"] = firebase_custom_token
        
        return MagicLinkCompleteResponse(**response_data)
        
    except HTTPException:
        raise
    except Exception as e:
        logger.error(f"APP_TOKEN_EXCHANGE: ERROR - {str(e)}, IP={ip_address}")
        raise HTTPException(
            status_code=500,
            detail="Token exchange failed. Please try again."
        )