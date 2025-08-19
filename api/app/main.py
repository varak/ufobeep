from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config.environment import settings
from app.routers import plane_match, media_serve, devices, emails, photo_analysis, mufon
from app.routers import admin_simple as admin
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
                    url = media_file.get("url") or f"https://api.ufobeep.com/media/{sighting_id}/{filename}"
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

# Initialize FastAPI app with environment configuration
app = FastAPI(
    title=settings.app_name,
    description="Real-time UFO and anomaly sighting alert system API",
    version=settings.app_version,
    debug=settings.debug,
    docs_url="/docs" if settings.debug else None,
    redoc_url="/redoc" if settings.debug else None,
)

# CORS middleware with environment-based origins
app.add_middleware(
    CORSMiddleware,
    allow_origins=settings.cors_origins_list,
    allow_credentials=True,
    allow_methods=["GET", "POST", "PUT", "DELETE", "PATCH", "OPTIONS"],
    allow_headers=["*"],
)

# Database connection
db_pool = None

# Media storage configuration
MEDIA_DIR = Path("media")
MEDIA_DIR.mkdir(exist_ok=True)
(MEDIA_DIR / "images").mkdir(exist_ok=True)
(MEDIA_DIR / "thumbnails").mkdir(exist_ok=True)

# Log configuration on startup
@app.on_event("startup")
async def startup_event():
    global db_pool
    settings.log_configuration()
    

    try:
        db_pool = await asyncpg.create_pool(
            host="localhost",
            port=5432,
            user="ufobeep_user",
            password="ufopostpass",
            database="ufobeep_db",
            min_size=1,
            max_size=10
        )
        print("Database connection pool created successfully")
        
        

        async with db_pool.acquire() as conn:

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
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            

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
            

            await run_photo_analysis_migration()
            

            from app.services.metrics_service import initialize_metrics_service
            await initialize_metrics_service(db_pool)
            
        print("Database tables initialized")
    except Exception as e:
        print(f"Database initialization failed: {e}")

@app.on_event("shutdown")
async def shutdown_event():
    global db_pool
    if db_pool:
        await db_pool.close()

@app.get("/healthz")
def healthz():
    return {"ok": True}

@app.get("/ping")
def ping():
    return {"message": "pong"}

# Mount static files for media serving (use /static to avoid conflict with /media/upload)
app.mount("/static", StaticFiles(directory="media"), name="media")

# Include routers
app.include_router(plane_match.router)
app.include_router(media_serve.router)  # Keep for serving files
app.include_router(admin.router)
app.include_router(devices.router)
app.include_router(emails.router)
app.include_router(photo_analysis.router)
app.include_router(mufon.router)

# Include alerts router for unified alert/sighting endpoints
from app.routers import alerts
app.include_router(alerts.router)

# Include engagement tracking router
from app.routers import beep_engagement
app.include_router(beep_engagement.router)

# Clean unified alerts architecture using alerts.router

# Duplicate alert endpoints removed - now handled by alerts.router

async def generate_enrichment_data(sensor_data, use_metric=True):
    """Generate enrichment data for a sighting - now using clean service layer with unit conversion"""
    from app.services.enrichment_service import EnrichmentDataGenerator
    
    enrichment_service = EnrichmentDataGenerator(use_metric=use_metric)
    return await enrichment_service.generate_enrichment_data(sensor_data)

@app.post("/sightings")
async def create_sighting(request: dict = None):
    try:
        if not request:
            raise HTTPException(status_code=400, detail="Request body required")
        

        title = request.get("title", "")
        description = request.get("description", "")
        category = request.get("category", "ufo")
        witness_count = request.get("witness_count", 1)
        is_public = request.get("is_public", True)
        tags = request.get("tags", [])
        media_info = request.get("media_info", {})
        sensor_data = request.get("sensor_data", {})
        

        if not title or len(title.strip()) < 5:
            raise HTTPException(status_code=400, detail="Title must be at least 5 characters")
        if not description or len(description.strip()) < 10:
            raise HTTPException(status_code=400, detail="Description must be at least 10 characters")
        

        enrichment_data = await generate_enrichment_data(sensor_data)
        

        async with db_pool.acquire() as conn:
            sighting_id = await conn.fetchval("""
                INSERT INTO sightings 
                (title, description, category, witness_count, is_public, tags, media_info, sensor_data, enrichment_data, alert_level, status)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                RETURNING id
            """, title.strip(), description.strip(), category, witness_count, is_public, 
                tags, json.dumps(media_info), json.dumps(sensor_data), json.dumps(enrichment_data), "low", "created")
        
        return {
            "success": True,
            "data": {
                "sighting_id": str(sighting_id),
                "status": "created",
                "alert_level": "low"
            },
            "message": "Sighting created successfully",
            "timestamp": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error creating sighting: {e}")
        raise HTTPException(status_code=500, detail=f"Error creating sighting: {str(e)}")
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
        proximity_service = get_proximity_alert_service(db_pool)
        result = await proximity_service.send_proximity_alerts(
            request.get("lat", 36.24), request.get("lng", -115.24),
            "test-alert", request.get("device_id", "admin"), emergency_mode=True
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
@app.get("/analysis/status/{sighting_id}")
async def get_analysis_status(sighting_id: str):
    """Get photo analysis status for a sighting"""
    try:
        async with db_pool.acquire() as conn:
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
