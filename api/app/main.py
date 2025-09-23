from contextlib import asynccontextmanager
from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.middleware.request_middleware import RequestTimeoutMiddleware, ErrorHandlingMiddleware
from app.config.environment import settings
from app.routers import plane_match, media_serve, devices, emails, photo_analysis, mufon, users, firebase_users, auth_magic, comments, share_cards, media_uploads
from app.routers import admin_simple as admin
# TODO: Fix admin_users and user_data routers to use asyncpg pattern
# from app.routers import admin_users, user_data
from routers import feeds as feeds_router
from app.services.media_service import get_media_service
from app.services.alerts_service import AlertsService
from app.schemas.media import guess_media_type_from_filename
import asyncpg
import asyncio
import json
from datetime import datetime
from typing import Tuple, Optional
import uuid
from uuid import uuid4
import os
import shutil
from pathlib import Path
import logging

# Set up logging
logger = logging.getLogger(__name__)

def process_media_files(media_info, sighting_id: str) -> list:
    """Shared function to process media files for both list and detail endpoints"""
    media_files = []
    if media_info:
        try:
            if isinstance(media_info, str):
                media_info = json.loads(media_info)
            
            if isinstance(media_info, dict) and "files" in media_info:
                for media_file in media_info["files"]:
                    filename = media_file.get("filename", "")
                    media_type = media_file.get("type") or guess_media_type_from_filename(filename).value
                    
                    # Use new URL structure if available, fallback to old
                    url = media_file.get("url") or f"https://ufobeep.com/api/media/{sighting_id}/{filename}"
                    thumbnail_url = media_file.get("thumbnail_url") or (f"{url}?thumbnail=true" if media_type == "video" else url)
                    web_url = media_file.get("web_url", url)
                    preview_url = media_file.get("preview_url", thumbnail_url)
                    
                    media_files.append({
                        "id": media_file.get("id", ""),
                        "type": media_type,
                        "url": url,
                        "thumbnail_url": thumbnail_url,
                        "web_url": web_url,
                        "preview_url": preview_url,
                        "filename": filename,
                        "size": media_file.get("size", 0),
                        "width": media_file.get("width", 0),
                        "height": media_file.get("height", 0),
                        "uploaded_at": media_file.get("uploaded_at", "")
                    })
        except:
            pass
    return media_files

def extract_coordinates_from_sensor_data(sensor_data: dict) -> Tuple[Optional[float], Optional[float]]:
    """Extract latitude and longitude from sensor data, handling both formats"""
    if not sensor_data:
        return None, None
    

    if "location" in sensor_data and isinstance(sensor_data["location"], dict):
        location = sensor_data["location"]
        lat = location.get("latitude")
        lng = location.get("longitude")
        if lat is not None and lng is not None:
            return float(lat), float(lng)
    

    lat = sensor_data.get("latitude")
    lng = sensor_data.get("longitude")
    if lat is not None and lng is not None:
        return float(lat), float(lng)
    
    return None, None

# Database connection - now using proper service
from app.services.database_service import database_service

# Media storage configuration
MEDIA_DIR = Path("media")
MEDIA_DIR.mkdir(exist_ok=True)
(MEDIA_DIR / "images").mkdir(exist_ok=True)
(MEDIA_DIR / "thumbnails").mkdir(exist_ok=True)

@asynccontextmanager
async def lifespan(app: FastAPI):
    # Startup
    settings.log_configuration()
    
    # CRITICAL: Initialize Firebase EXACTLY ONCE at startup
    from app.core.firebase_client import init_firebase
    try:
        init_firebase()
        print("✅ Firebase initialized successfully at startup")
    except Exception as e:
        print(f"❌ Firebase startup initialization failed: {e}")
    
    try:
        # Initialize database service with production settings
        await database_service.initialize_pool(
            host="localhost",
            port=5432,
            user="ufobeep_user",
            password="ufopostpass",
            database="ufobeep_db",
            min_size=2,
            max_size=20,
            command_timeout=60
        )
        print("Database connection pool created successfully")
        
        async with database_service.pool.acquire() as conn:

            try:
                await conn.execute("ALTER TABLE sightings ALTER COLUMN title DROP NOT NULL")
                await conn.execute("ALTER TABLE sightings ALTER COLUMN description DROP NOT NULL")
                print("✅ Updated sightings table to allow NULL titles and descriptions")
            except Exception as e:
                print(f"Note: Column constraint update failed (table may not exist yet): {e}")
            
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS sightings (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    title TEXT,
                    description TEXT,
                    category TEXT DEFAULT 'ufo',
                    witness_count INTEGER DEFAULT 1,
                    is_public BOOLEAN DEFAULT true,
                    tags TEXT[] DEFAULT '{}',
                    media_info JSONB,
                    sensor_data JSONB,
                    alert_level TEXT DEFAULT 'low',
                    status TEXT DEFAULT 'created',
                    enrichment_data JSONB,
                    reporter_id UUID REFERENCES users(id),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)

            # Add reporter_id column if it doesn't exist
            try:
                await conn.execute("""
                    ALTER TABLE sightings ADD COLUMN IF NOT EXISTS reporter_id UUID REFERENCES users(id)
                """)
                print("✅ Added reporter_id column to sightings table")
            except Exception as e:
                if "already exists" in str(e).lower():
                    print("✅ reporter_id column already exists in sightings table")
                else:
                    print(f"Note: reporter_id column setup warning: {e}")
            

            await conn.execute("""
                CREATE TABLE IF NOT EXISTS email_interests (
                    id SERIAL PRIMARY KEY,
                    email TEXT NOT NULL UNIQUE,
                    source TEXT DEFAULT 'app_download_page',
                    ip_address INET,
                    ip_location_data JSONB,
                    gps_latitude DECIMAL(10,8),
                    gps_longitude DECIMAL(11,8),
                    gps_accuracy DECIMAL(10,2),
                    location_comparison JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            

            await conn.execute("""
                CREATE TABLE IF NOT EXISTS users (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    username VARCHAR(50) UNIQUE NOT NULL,
                    email VARCHAR(255) UNIQUE,
                    password_hash VARCHAR(255),
                    display_name VARCHAR(100),
                    bio TEXT,
                    location VARCHAR(255),
                    alert_range_km FLOAT DEFAULT 50.0 NOT NULL,
                    min_alert_level TEXT DEFAULT 'low' NOT NULL,
                    push_notifications BOOLEAN DEFAULT true NOT NULL,
                    email_notifications BOOLEAN DEFAULT false NOT NULL,
                    share_location BOOLEAN DEFAULT true NOT NULL,
                    public_profile BOOLEAN DEFAULT false NOT NULL,
                    preferred_language VARCHAR(5) DEFAULT 'en' NOT NULL,
                    units_metric BOOLEAN DEFAULT true NOT NULL,
                    matrix_user_id VARCHAR(255),
                    matrix_device_id VARCHAR(255),
                    matrix_access_token TEXT,
                    is_active BOOLEAN DEFAULT true NOT NULL,
                    is_verified BOOLEAN DEFAULT false NOT NULL,
                    last_login TIMESTAMP WITH TIME ZONE,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
                )
            """)
            

            try:
                await conn.execute("""
                    CREATE TYPE device_platform AS ENUM ('ios', 'android', 'web')
                """)
            except asyncpg.DuplicateObjectError:
                pass
            
            try:
                await conn.execute("""
                    CREATE TYPE push_provider AS ENUM ('fcm', 'apns', 'webpush')
                """)
            except asyncpg.DuplicateObjectError:
                pass
            

            await conn.execute("""
                CREATE TABLE IF NOT EXISTS devices (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
                    device_id VARCHAR(255) NOT NULL,
                    device_name VARCHAR(255),
                    platform device_platform NOT NULL,
                    app_version VARCHAR(50),
                    os_version VARCHAR(50),
                    device_model VARCHAR(100),
                    manufacturer VARCHAR(100),
                    push_token TEXT,
                    push_provider push_provider,
                    push_enabled BOOLEAN DEFAULT true NOT NULL,
                    alert_notifications BOOLEAN DEFAULT true NOT NULL,
                    chat_notifications BOOLEAN DEFAULT true NOT NULL,
                    system_notifications BOOLEAN DEFAULT true NOT NULL,
                    is_active BOOLEAN DEFAULT true NOT NULL,
                    last_seen TIMESTAMP WITH TIME ZONE,
                    timezone VARCHAR(50),
                    locale VARCHAR(10),
                    notifications_sent INTEGER DEFAULT 0 NOT NULL,
                    notifications_opened INTEGER DEFAULT 0 NOT NULL,
                    last_notification_at TIMESTAMP WITH TIME ZONE,
                    registered_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
                    token_updated_at TIMESTAMP WITH TIME ZONE,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL,
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW() NOT NULL
                )
            """)
            

            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_devices_user_id ON devices(user_id)
            """)
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_devices_device_id ON devices(device_id)
            """)
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_devices_active_push ON devices(is_active, push_enabled) 
                WHERE push_token IS NOT NULL
            """)
            
            # Add index for short_url lookups for efficient beep/by-short-url endpoint
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_sightings_short_url ON sightings(short_url)
                WHERE short_url IS NOT NULL
            """)
            
            # Create magic link tables
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS magic_links (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    email VARCHAR(255) NOT NULL,
                    hashed_nonce VARCHAR(255) NOT NULL UNIQUE,
                    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
                    used BOOLEAN DEFAULT false NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    user_agent VARCHAR(500),
                    ip_address VARCHAR(45)
                )
            """)
            
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_magic_links_email ON magic_links(email)
            """)
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_magic_links_nonce ON magic_links(hashed_nonce)
            """)
            
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS magic_link_attempts (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    email VARCHAR(255) NOT NULL,
                    ip_address VARCHAR(45) NOT NULL,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    success BOOLEAN DEFAULT false
                )
            """)
            
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_magic_link_attempts_email ON magic_link_attempts(email)
            """)
            await conn.execute("""
                CREATE INDEX IF NOT EXISTS idx_magic_link_attempts_ip ON magic_link_attempts(ip_address)
            """)
            
            # Add jti column to magic_links table if it doesn't exist
            try:
                await conn.execute("""
                    ALTER TABLE magic_links ADD COLUMN jti VARCHAR(255) UNIQUE
                """)
                await conn.execute("""
                    CREATE INDEX IF NOT EXISTS idx_magic_links_jti ON magic_links(jti)
                """)
                print("✅ Added jti column to magic_links table")
            except Exception as e:
                if "already exists" in str(e).lower() or "duplicate" in str(e).lower():
                    print("✅ JTI column already exists in magic_links table")
                else:
                    print(f"Magic links JTI column setup warning: {e}")

            # Create photo_analysis_results table if not exists
            try:
                await conn.execute("""
                    CREATE TABLE IF NOT EXISTS photo_analysis_results (
                        id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                        sighting_id UUID NOT NULL,
                        filename VARCHAR(255) NOT NULL,
                        classification VARCHAR(50),
                        matched_object VARCHAR(100),
                        confidence DECIMAL(5,4),
                        analysis_status VARCHAR(20) DEFAULT 'pending',
                        analysis_error TEXT,
                        processing_duration_ms INTEGER,
                        created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                        updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                    )
                """)
                print("✅ Photo analysis table created/verified")
            except Exception as e:
                print(f"Photo analysis table setup warning: {e}")
            

            from app.services.metrics_service import initialize_metrics_service
            await initialize_metrics_service(database_service.pool)
            
        print("Database tables initialized")

        
        # Initialize notification system with shared database pool
        try:
            from app.lifecycle import on_startup
            await on_startup(app)
            print("✅ Notification system initialized")
        except Exception as e:
            print(f"❌ Notification system initialization failed: {e}")
            import traceback
            print(f"Full traceback: {traceback.format_exc()}")
    except Exception as e:
        print(f"Database initialization failed: {e}")
    
    yield
    
    # Shutdown
    from app.lifecycle import on_shutdown
    await on_shutdown(app)
    await database_service.close()

# Initialize FastAPI app with environment configuration and lifespan
app = FastAPI(
    title=settings.app_name,
    description="Real-time UFO and anomaly sighting alert system API",
    version=settings.app_version,
    debug=settings.debug,
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
    lifespan=lifespan,
)

# Request handling middleware (order matters - first added, last executed)
app.add_middleware(RequestTimeoutMiddleware, timeout_seconds=30)
app.add_middleware(ErrorHandlingMiddleware)

# CORS middleware with environment-based origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
)

@app.get("/healthz")
async def healthz():
    """Enhanced health check with database pool status and notification queue monitoring"""
    health_data = {"ok": True, "timestamp": datetime.now().isoformat()}
    
    # Add database pool health
    try:
        db_health = await database_service.health_check()
        health_data["database"] = db_health
        if not db_health.get("healthy", False):
            health_data["ok"] = False
    except Exception as e:
        health_data["database"] = {"healthy": False, "error": str(e)}
        health_data["ok"] = False
    
    # Add notification queue health
    try:
        if hasattr(app.state, 'notify_queue') and hasattr(app.state, 'notify_task'):
            queue_size = app.state.notify_queue.qsize()
            worker_alive = not app.state.notify_task.done()
            
            health_data["notifications"] = {
                "queue_size": queue_size,
                "worker_running": worker_alive,
                "healthy": worker_alive and queue_size < 500  # Consider unhealthy if queue backs up
            }
            
            if not health_data["notifications"]["healthy"]:
                health_data["ok"] = False
                
        else:
            health_data["notifications"] = {
                "healthy": False,
                "error": "Notification system not initialized"
            }
            health_data["ok"] = False
            
    except Exception as e:
        health_data["notifications"] = {"healthy": False, "error": str(e)}
        health_data["ok"] = False
    
    return health_data

@app.get("/ping")
def ping():
    return {"message": "pong"}

# Mount static files for media serving (use /static to avoid conflict with /media/upload)
app.mount("/static", StaticFiles(directory="media"), name="media")
# Mount well-known files for App Links and AASA verification
app.mount("/.well-known", StaticFiles(directory="static/.well-known"), name="wellknown")

# Include routers
app.include_router(plane_match.router)
app.include_router(media_serve.router)  # Keep for serving files
app.include_router(admin.router)
app.include_router(devices.router)
app.include_router(emails.router)
app.include_router(photo_analysis.router)
app.include_router(mufon.router)

# Include beep router for unified beep/sighting endpoints
from app.routers import beep
app.include_router(beep.router)

# Removed alerts router - all requests should use /beep/ endpoints only

# Include engagement tracking router
from app.routers import beep_engagement
app.include_router(beep_engagement.router)

# Include user management router for MP13-1 username system
app.include_router(users.router)
# Include Firebase user management for authentication
app.include_router(firebase_users.router)
# Include magic link authentication router
app.include_router(auth_magic.router)
# Include MP16 routers for comments and share cards
app.include_router(comments.router)
app.include_router(share_cards.router)
# Include WebSocket router for real-time updates
from app.routers import websockets
app.include_router(websockets.router)
# Include MP16 media uploads with idempotency
app.include_router(media_uploads.router)
# Include feeds router for data ingestion
app.include_router(feeds_router.router)

# Simple admin endpoints for user data viewing
@app.get("/api/admin/users/stats")
async def admin_user_stats(request: Request):
    """Get basic user statistics"""
    admin_key = request.headers.get("X-Admin-Key")
    if admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=403, detail="Admin access required")

    try:
        async with database_service.pool.acquire() as conn:
            total_users = await conn.fetchval("SELECT COUNT(*) FROM users")

            return {
                "total_users": total_users or 0,
                "active_users_7d": 0,  # TODO: Implement when we have last_active_at data
                "active_users_30d": 0,
                "marketing_consent_count": 0  # TODO: Implement when we capture consent
            }
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/admin/users")
async def admin_users_list(request: Request, search: str = "", limit: int = 50):
    """Get users list for admin"""
    admin_key = request.headers.get("X-Admin-Key")
    if admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=403, detail="Admin access required")

    try:
        async with database_service.pool.acquire() as conn:
            if search:
                users = await conn.fetch("""
                    SELECT u.id, u.username, u.email, u.created_at, u.last_login,
                           d.device_model, d.manufacturer as device_manufacturer,
                           d.os_version, d.app_version
                    FROM users u
                    LEFT JOIN devices d ON u.id = d.user_id
                    WHERE u.username ILIKE $1 OR u.email ILIKE $1
                    ORDER BY u.created_at DESC
                    LIMIT $2
                """, f"%{search}%", limit)
            else:
                users = await conn.fetch("""
                    SELECT u.id, u.username, u.email, u.created_at, u.last_login,
                           d.device_model, d.manufacturer as device_manufacturer,
                           d.os_version, d.app_version
                    FROM users u
                    LEFT JOIN devices d ON u.id = d.user_id
                    ORDER BY u.created_at DESC
                    LIMIT $1
                """, limit)

            return [
                {
                    "id": str(user["id"]),
                    "username": user["username"],
                    "email": user["email"],
                    "device_model": user["device_model"],
                    "device_manufacturer": user["device_manufacturer"],
                    "os_version": user["os_version"],
                    "app_version": user["app_version"],
                    "acquisition_source": None,  # Not available in current schema
                    "marketing_consent": False,  # Not available in current schema
                    "created_at": user["created_at"].isoformat() if user["created_at"] else None,
                    "last_active_at": user["last_login"].isoformat() if user["last_login"] else None
                }
                for user in users
            ]
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/api/admin/users/{user_id}/export/test")
async def admin_export_user_data_test(user_id: str, request: Request):
    """Test endpoint for debugging"""
    admin_key = request.headers.get("X-Admin-Key")
    if admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=403, detail="Admin access required")

    return {"test": "working", "user_id": user_id, "timestamp": datetime.now().isoformat()}

@app.get("/api/admin/users/{user_id}/export")
async def admin_export_user_data(user_id: str, request: Request, format: str = "json"):
    """Admin endpoint: Export comprehensive user data for GDPR testing"""
    admin_key = request.headers.get("X-Admin-Key")
    if admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=403, detail="Admin access required")

    try:
        async with database_service.pool.acquire() as conn:
            # Get user data (only columns that exist)
            user_data = await conn.fetchrow("""
                SELECT id, username, email, display_name, bio, location,
                       created_at, last_login, is_verified,
                       preferred_language, alert_range_km, min_alert_level,
                       push_notifications, email_notifications, share_location,
                       public_profile, units_metric, is_active
                FROM users WHERE id = $1
            """, user_id)

            if not user_data:
                raise HTTPException(status_code=404, detail="User not found")

            # Get user's sightings (only existing columns)
            sightings = await conn.fetch("""
                SELECT id, title, description, category, witness_count, is_public,
                       tags, media_info, sensor_data, alert_level, status,
                       created_at, updated_at, enrichment_data, reporter_id,
                       source
                FROM sightings WHERE reporter_id = $1
            """, user_id)

            # Get user's comments
            comments = await conn.fetch("""
                SELECT c.id, c.body, c.created_at, c.sighting_id, c.media_url,
                       s.title as sighting_title
                FROM comments c
                LEFT JOIN sightings s ON c.sighting_id = s.id
                WHERE c.user_id = $1
            """, user_id)

            # Get user's devices
            devices = await conn.fetch("""
                SELECT device_id, device_name, platform, app_version, os_version,
                       device_model, manufacturer, push_token, push_enabled,
                       is_active, last_seen, timezone, locale, created_at, updated_at
                FROM devices WHERE user_id = $1
            """, user_id)

            # Get user's follows
            follows = await conn.fetch("""
                SELECT f.sighting_id, f.created_at, s.title as sighting_title
                FROM follows f
                LEFT JOIN sightings s ON f.sighting_id = s.id
                WHERE f.user_id = $1
            """, user_id)

            # Prepare comprehensive export data
            export_data = {
                "export_metadata": {
                    "generated_at": datetime.now().isoformat(),
                    "user_id": str(user_data["id"]),
                    "username": user_data["username"],
                    "export_version": "1.0",
                    "total_beeps": len(sightings),
                    "total_comments": len(comments),
                    "total_follows": len(follows),
                    "total_devices": len(devices)
                },
                "user_profile": {
                    "id": str(user_data["id"]),
                    "username": user_data["username"],
                    "email": user_data["email"],
                    "display_name": user_data["display_name"],
                    "bio": user_data["bio"],
                    "location": user_data["location"],
                    "created_at": user_data["created_at"].isoformat() if user_data["created_at"] else None,
                    "last_login": user_data["last_login"].isoformat() if user_data["last_login"] else None,
                    "is_verified": user_data["is_verified"],
                    "preferred_language": user_data["preferred_language"],
                    "is_active": user_data["is_active"]
                },
                "user_settings": {
                    "alert_range_km": float(user_data["alert_range_km"]) if user_data["alert_range_km"] else None,
                    "min_alert_level": user_data["min_alert_level"],
                    "push_notifications": user_data["push_notifications"],
                    "email_notifications": user_data["email_notifications"],
                    "share_location": user_data["share_location"],
                    "public_profile": user_data["public_profile"],
                    "units_metric": user_data["units_metric"]
                },
                "beeps": [dict(s) for s in sightings],
                "comments": [dict(c) for c in comments],
                "devices": [dict(d) for d in devices],
                "follows": [dict(f) for f in follows],
                "admin_export": {
                    "exported_by": "admin",
                    "export_type": "comprehensive_gdpr",
                    "admin_timestamp": datetime.now().isoformat()
                }
            }

            if format == "csv":
                import csv
                import io
                from fastapi.responses import Response

                output = io.StringIO()
                writer = csv.writer(output)

                # Export metadata
                writer.writerow(["=== EXPORT METADATA ==="])
                for key, value in export_data["export_metadata"].items():
                    writer.writerow([key, str(value)])

                writer.writerow([])
                writer.writerow(["=== USER PROFILE ==="])
                for key, value in export_data["user_profile"].items():
                    writer.writerow([key, str(value) if value is not None else ""])

                writer.writerow([])
                writer.writerow(["=== USER SETTINGS ==="])
                for key, value in export_data["user_settings"].items():
                    writer.writerow([key, str(value) if value is not None else ""])

                writer.writerow([])
                writer.writerow(["=== BEEPS/SIGHTINGS ==="])
                if export_data["beeps"]:
                    headers = list(export_data["beeps"][0].keys())
                    writer.writerow(headers)
                    for beep in export_data["beeps"]:
                        writer.writerow([str(beep[h]) if beep[h] is not None else "" for h in headers])

                writer.writerow([])
                writer.writerow(["=== COMMENTS ==="])
                if export_data["comments"]:
                    headers = list(export_data["comments"][0].keys())
                    writer.writerow(headers)
                    for comment in export_data["comments"]:
                        writer.writerow([str(comment[h]) if comment[h] is not None else "" for h in headers])

                csv_data = output.getvalue()
                output.close()

                return Response(
                    content=csv_data,
                    media_type="text/csv",
                    headers={"Content-Disposition": f"attachment; filename=comprehensive_user_data_{user_data['username']}_{datetime.now().strftime('%Y%m%d')}.csv"}
                )

            return export_data

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to export user data: {str(e)}")

@app.delete("/api/admin/users/{user_id}")
async def admin_delete_user_account(user_id: str, request: Request):
    """Admin endpoint: Comprehensive user account deletion for GDPR testing"""
    admin_key = request.headers.get("X-Admin-Key")
    if admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=403, detail="Admin access required")

    try:
        async with database_service.pool.acquire() as conn:
            async with conn.transaction():
                # Get username first
                user_record = await conn.fetchrow("SELECT username FROM users WHERE id = $1", user_id)
                if not user_record:
                    raise HTTPException(status_code=404, detail="User not found")

                username = user_record['username']

                # STEP 1: Delete all comments made by this user
                comments_deleted = await conn.execute("DELETE FROM comments WHERE user_id = $1", user_id)
                comments_count = int(comments_deleted.split()[-1]) if comments_deleted.split()[-1].isdigit() else 0

                # STEP 2: Get user's sightings
                sightings = await conn.fetch("SELECT id FROM sightings WHERE reporter_id = $1", user_id)
                sightings_count = len(sightings)

                # STEP 3: Delete media and related data for each sighting
                media_files_deleted = 0
                for sighting in sightings:
                    sighting_id = sighting['id']

                    # Delete media files
                    media_deleted = await conn.execute("DELETE FROM media_files WHERE sighting_id = $1", sighting_id)
                    media_files_deleted += int(media_deleted.split()[-1]) if media_deleted.split()[-1].isdigit() else 0

                # STEP 4: Delete follows, alerts for user's sightings
                follows_deleted = 0
                alerts_deleted = 0
                for sighting in sightings:
                    sighting_id = sighting['id']

                    follows_result = await conn.execute("DELETE FROM follows WHERE sighting_id = $1", sighting_id)
                    follows_deleted += int(follows_result.split()[-1]) if follows_result.split()[-1].isdigit() else 0

                    alerts_result = await conn.execute("DELETE FROM alerts WHERE sighting_id = $1", sighting_id)
                    alerts_deleted += int(alerts_result.split()[-1]) if alerts_result.split()[-1].isdigit() else 0

                # STEP 5: Delete user's sightings
                sightings_deleted = await conn.execute("DELETE FROM sightings WHERE reporter_id = $1", user_id)
                final_sightings_count = int(sightings_deleted.split()[-1]) if sightings_deleted.split()[-1].isdigit() else 0

                # STEP 6: Delete user's devices
                devices_deleted = await conn.execute("DELETE FROM user_devices WHERE user_id = $1", user_id)
                devices_count = int(devices_deleted.split()[-1]) if devices_deleted.split()[-1].isdigit() else 0

                # STEP 7: Delete user's follows
                user_follows_deleted = await conn.execute("DELETE FROM follows WHERE user_id = $1", user_id)
                user_follows_count = int(user_follows_deleted.split()[-1]) if user_follows_deleted.split()[-1].isdigit() else 0

                # STEP 8: Delete email marketing records
                email_marketing_deleted = await conn.execute("DELETE FROM email_marketing WHERE user_id = $1", user_id)
                email_marketing_count = int(email_marketing_deleted.split()[-1]) if email_marketing_deleted.split()[-1].isdigit() else 0

                # STEP 9: Delete analytics events
                analytics_deleted = await conn.execute("DELETE FROM analytics_events WHERE user_id = $1", user_id)
                analytics_count = int(analytics_deleted.split()[-1]) if analytics_deleted.split()[-1].isdigit() else 0

                # STEP 10: Delete any media files uploaded by this user
                user_media_deleted = await conn.execute("DELETE FROM media_files WHERE uploaded_by_user_id = $1", user_id)
                user_media_count = int(user_media_deleted.split()[-1]) if user_media_deleted.split()[-1].isdigit() else 0

                # STEP 11: Finally delete the user
                user_deleted = await conn.execute("DELETE FROM users WHERE id = $1", user_id)
                user_deletion_success = "DELETE 1" in user_deleted

                if not user_deletion_success:
                    raise HTTPException(status_code=500, detail="Failed to delete user record")

                return {
                    "success": True,
                    "message": f"User {username} deleted successfully with comprehensive cleanup",
                    "details": {
                        "user_id": user_id,
                        "username": username,
                        "sightings_deleted": final_sightings_count,
                        "comments_deleted": comments_count,
                        "files_deleted": media_files_deleted,
                        "storage_freed_mb": 0,
                        "deleted_records": {
                            "sightings": final_sightings_count,
                            "comments": comments_count,
                            "devices": devices_count,
                            "follows": follows_deleted + user_follows_count,
                            "alerts": alerts_deleted,
                            "media_files": media_files_deleted + user_media_count,
                            "email_marketing": email_marketing_count,
                            "analytics_events": analytics_count
                        }
                    }
                }

    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete user account: {str(e)}")

# Clean unified alerts architecture using alerts.router

# Duplicate alert endpoints removed - now handled by alerts.router

async def generate_enrichment_data(sensor_data, use_metric=True):
    """Generate enrichment data for a sighting - now using clean service layer with unit conversion"""
    from app.services.enrichment_service import EnrichmentDataGenerator
    
    enrichment_service = EnrichmentDataGenerator(use_metric=use_metric)
    return await enrichment_service.generate_enrichment_data(sensor_data)

# OLD endpoints removed - now handled by alerts.router

# OLD witness-confirm endpoint removed - now handled by alerts.router
# OLD witness-status endpoint removed - now handled by alerts.router

# OLD witness-aggregation endpoint removed - now handled by alerts.router
@app.post("/admin/test/alert")
async def admin_test_alert(request: dict):
    """Admin test alert - simplified"""
    if request.get("admin_key") != "ufobeep_test_key_2025":
        raise HTTPException(status_code=403, detail="Admin access required")
    try:
        from services.proximity_alert_service import get_proximity_alert_service
        proximity_service = get_proximity_alert_service(database_service.pool)
        result = await proximity_service.send_proximity_alerts(
            request.get("lat", 36.24), request.get("lng", -115.24),
            "test-alert", request.get("device_id", "admin")
        )
        return {"success": True, "alerts_sent": result.get("total_alerts_sent", 0)}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.post("/admin/test/single")
async def admin_test_single(request: dict):
    """Admin test single device - simplified"""
    if request.get("admin_key") != "ufobeep_test_key_2025":
        raise HTTPException(status_code=403, detail="Admin access required")
    try:

        return {"success": True, "message": "Test notification sent"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/debug/fcm")
async def debug_fcm():
    """Debug FCM initialization status"""
    try:
        from app.core.firebase_client import get_messaging
        messaging = get_messaging()
        return {
            "success": True,
            "firebase_initialized": messaging is not None,
            "message": "Firebase messaging client available"
        }
    except Exception as e:
        return {
            "success": False,
            "error": str(e),
            "message": "Firebase messaging client failed"
        }
@app.get("/analysis/status/{sighting_id}")
async def get_analysis_status(sighting_id: str):
    """Get photo analysis status for a sighting"""
    try:
        async with database_service.pool.acquire() as conn:
            results = await conn.fetch("""
                SELECT filename, classification, matched_object, confidence, 
                       analysis_status, analysis_error, processing_duration_ms,
                       created_at, updated_at
                FROM photo_analysis_results 
                WHERE sighting_id = $1
                ORDER BY created_at DESC
            """, uuid.UUID(sighting_id))
            
            analysis_results = []
            for row in results:
                analysis_results.append({
                    "filename": row["filename"],
                    "classification": row["classification"],
                    "matched_object": row["matched_object"], 
                    "confidence": float(row["confidence"]) if row["confidence"] else None,
                    "status": row["analysis_status"],
                    "error": row["analysis_error"],
                    "processing_duration_ms": row["processing_duration_ms"],
                    "started_at": row["created_at"].isoformat(),
                    "updated_at": row["updated_at"].isoformat()
                })
            
            return {
                "success": True,
                "sighting_id": sighting_id,
                "analysis_count": len(analysis_results),
                "results": analysis_results
            }
            
    except Exception as e:
        print(f"Error getting analysis status: {e}")
        return {
            "success": False,
            "error": str(e),
            "sighting_id": sighting_id,
            "analysis_count": 0,
            "results": []
        }
