from fastapi import FastAPI, HTTPException, UploadFile, File, Form, Request
from fastapi.responses import HTMLResponse
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config.environment import settings
from app.routers import plane_match, media, devices
import asyncpg
import json
from datetime import datetime
import uuid
import os
import shutil
from pathlib import Path
import logging

# Set up logging
logger = logging.getLogger(__name__)

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
    
    # Initialize database connection
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
        
        # Create sightings table if it doesn't exist
        async with db_pool.acquire() as conn:
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS sightings (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    title TEXT NOT NULL,
                    description TEXT NOT NULL,
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
            
            # Create email interests table
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
            
            # Create users table
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
            
            # Create device platform and push provider enums
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
            
            # Create devices table  
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
            
            # Create indexes for devices table
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
app.include_router(media.router)
app.include_router(devices.router)

# Disable complex routers for now - just get basic endpoints working

# Database-backed endpoints
@app.get("/alerts")
async def get_alerts():
    try:
        async with db_pool.acquire() as conn:
            # Get recent sightings as alerts
            rows = await conn.fetch("""
                SELECT 
                    id::text as id,
                    title,
                    description,
                    category,
                    alert_level,
                    status,
                    witness_count,
                    is_public,
                    tags,
                    created_at,
                    sensor_data,
                    media_info,
                    enrichment_data
                FROM sightings 
                WHERE is_public = true 
                ORDER BY created_at DESC 
                LIMIT 20
            """)
            
            alerts = []
            for row in rows:
                # Extract coordinates and location name from enrichment or sensor data
                latitude = 0.0
                longitude = 0.0
                location_name = "Unknown Location"
                
                # Try enrichment data first (it has processed location)
                if row["enrichment_data"]:
                    enrichment = row["enrichment_data"]
                    if isinstance(enrichment, str):
                        enrichment = json.loads(enrichment)
                    if "location" in enrichment:
                        latitude = float(enrichment["location"].get("latitude", 0))
                        longitude = float(enrichment["location"].get("longitude", 0))
                        location_name = enrichment["location"].get("name", "Unknown Location")
                
                # Fall back to sensor data if no enrichment location
                if latitude == 0.0 and longitude == 0.0 and row["sensor_data"]:
                    sensor_data = row["sensor_data"]
                    if isinstance(sensor_data, str):
                        sensor_data = json.loads(sensor_data) 
                    if "latitude" in sensor_data and sensor_data["latitude"] is not None:
                        latitude = float(sensor_data["latitude"])
                    if "longitude" in sensor_data and sensor_data["longitude"] is not None:
                        longitude = float(sensor_data["longitude"])
                
                # Process media info
                media_files = []
                if row["media_info"]:
                    try:
                        # media_info might be a string or dict depending on how it's stored
                        if isinstance(row["media_info"], str):
                            media_info = json.loads(row["media_info"])
                        else:
                            media_info = row["media_info"]
                        
                        if isinstance(media_info, dict) and "files" in media_info:
                            for media_file in media_info["files"]:
                                media_files.append({
                                    "id": media_file.get("id", ""),
                                    "type": media_file.get("type", "image"),
                                    "url": media_file.get("url", ""),
                                    "thumbnail_url": media_file.get("thumbnail_url", ""),
                                    "filename": media_file.get("filename", ""),
                                    "size": media_file.get("size", 0),
                                    "width": media_file.get("width", 0),
                                    "height": media_file.get("height", 0),
                                    "uploaded_at": media_file.get("uploaded_at", row["created_at"].isoformat())
                                })
                    except (json.JSONDecodeError, TypeError) as e:
                        print(f"Error processing media_info: {e}")
                        # Continue without media files if parsing fails
                
                # Extract enrichment data for the response
                enrichment_info = {}
                if row["enrichment_data"]:
                    try:
                        if isinstance(row["enrichment_data"], str):
                            enrichment_info = json.loads(row["enrichment_data"])
                        else:
                            enrichment_info = row["enrichment_data"]
                    except:
                        pass
                
                alert = {
                    "id": row["id"],
                    "title": row["title"],
                    "description": row["description"],
                    "category": row["category"],
                    "alert_level": row["alert_level"],  # Use snake_case as expected by mobile app
                    "status": row["status"],
                    "witness_count": row["witness_count"],  # Use snake_case
                    "created_at": row["created_at"].isoformat(),  # Use snake_case as expected
                    "location": {  # Mobile app expects nested location object
                        "latitude": latitude,
                        "longitude": longitude,
                        "name": location_name  # Add location name from reverse geocoding
                    },
                    "distance_km": 0.0,  # Mobile app expects this field name
                    "bearing_deg": 0.0,  # Mobile app expects this field name
                    "view_count": 0,
                    "verification_score": 0.0,
                    "media_files": media_files,  # Include actual media files
                    "tags": row["tags"] or [],
                    "is_public": row["is_public"],  # Use snake_case
                    "submitted_at": row["created_at"].isoformat(),
                    "processed_at": row["created_at"].isoformat(),
                    "matrix_room_id": "",
                    "reporter_id": "",
                    "enrichment": enrichment_info  # Include enrichment data
                }
                
                alerts.append(alert)
            
            return {
                "success": True,
                "data": {
                    "alerts": alerts,
                    "total_count": len(alerts),
                    "offset": 0,
                    "limit": 20,
                    "has_more": False
                },
                "message": f"Found {len(alerts)} alerts" if alerts else "No alerts available",
                "timestamp": datetime.now().isoformat()
            }
    except Exception as e:
        print(f"Error fetching alerts: {e}")
        return {
            "success": False,
            "data": {"alerts": [], "total_count": 0, "offset": 0, "limit": 20, "has_more": False},
            "message": f"Error fetching alerts: {str(e)}",
            "timestamp": datetime.now().isoformat()
        }

async def generate_enrichment_data(sensor_data):
    """Generate enrichment data for a sighting using the enrichment service."""
    # Import here to avoid circular imports
    from app.services.enrichment_service import (
        enrichment_orchestrator, 
        EnrichmentContext, 
        initialize_enrichment_processors
    )
    
    # Initialize processors if not already done
    if not enrichment_orchestrator.processors:
        initialize_enrichment_processors()
    
    # Check if we have location data
    if not sensor_data or "latitude" not in sensor_data or "longitude" not in sensor_data:
        # Return basic enrichment without location-based data
        return {
            "status": "completed",
            "processed_at": datetime.now().isoformat(),
            "error": "No location data available for enrichment",
        }
    
    try:
        # Create enrichment context
        context = EnrichmentContext(
            sighting_id=str(uuid.uuid4()),  # Temporary ID for processing
            latitude=float(sensor_data["latitude"]),
            longitude=float(sensor_data["longitude"]),
            altitude=sensor_data.get("altitude"),
            timestamp=datetime.now(),
            azimuth_deg=sensor_data.get("azimuth_deg", 0),
            pitch_deg=sensor_data.get("pitch_deg", 0),
            roll_deg=sensor_data.get("roll_deg"),
            category="ufo",  # Default category
            title="",  # Will be filled by actual sighting data
            description=""  # Will be filled by actual sighting data
        )
        
        # Run enrichment processors
        enrichment_results = await enrichment_orchestrator.enrich_sighting(context)
        
        # Process results into the expected format
        enrichment = {
            "status": "completed",
            "processed_at": datetime.now().isoformat(),
        }
        
        # Add location info with location name if available
        enrichment["location"] = {
            "latitude": context.latitude,
            "longitude": context.longitude,
            "altitude": context.altitude or 0,
            "accuracy": sensor_data.get("accuracy", 0)
        }
        
        # Extract geocoding data if available
        if "geocoding" in enrichment_results and enrichment_results["geocoding"].success:
            geocoding_data = enrichment_results["geocoding"].data
            enrichment["location"]["name"] = geocoding_data.get("location_name", "Unknown Location")
            enrichment["location"]["city"] = geocoding_data.get("city", "")
            enrichment["location"]["state"] = geocoding_data.get("state", "")
            enrichment["location"]["country"] = geocoding_data.get("country", "")
            enrichment["location"]["formatted_address"] = geocoding_data.get("formatted_address", "")
        else:
            enrichment["location"]["name"] = "Unknown Location"
        
        # Extract weather data if available
        if "weather" in enrichment_results and enrichment_results["weather"].success:
            weather_data = enrichment_results["weather"].data
            enrichment["weather"] = {
                # Basic weather conditions
                "condition": weather_data.get("weather_main", "Clear"),
                "description": weather_data.get("weather_description", "Clear sky"),
                "icon_code": weather_data.get("weather_icon", "01d"),
                
                # Temperature data
                "temperature": weather_data.get("temperature_c", 0),
                "feels_like": weather_data.get("feels_like_c", 0),
                "dew_point": weather_data.get("dew_point_c", 0),
                
                # Atmospheric conditions
                "pressure": weather_data.get("pressure_hpa", 1013),
                "humidity": weather_data.get("humidity_percent", 0),
                "visibility": weather_data.get("visibility_km", 10.0),
                "cloud_coverage": weather_data.get("cloud_cover_percent", 0),
                "uv_index": weather_data.get("uvi", 0),
                
                # Wind data
                "wind_speed": weather_data.get("wind_speed_ms", 0),
                "wind_direction": weather_data.get("wind_direction_deg", 0),
                "wind_gust": weather_data.get("wind_gust_ms", 0),
                
                # Sun times (Unix timestamps)
                "sunrise": weather_data.get("sunrise", 0),
                "sunset": weather_data.get("sunset", 0),
                
                # Precipitation (if available)
                "rain_1h": weather_data.get("rain_1h_mm", 0),
                "snow_1h": weather_data.get("snow_1h_mm", 0),
                
                # Timing
                "timestamp": weather_data.get("dt", 0),
                "timezone_offset": weather_data.get("timezone_offset", 0),
                
                # Computed observation quality
                "observation_quality": _calculate_observation_quality(weather_data)
            }
        else:
            # Fallback weather data
            enrichment["weather"] = {
                # Basic weather conditions
                "condition": "Clear",
                "description": "Weather data unavailable",
                "icon_code": "01d",
                
                # Temperature data
                "temperature": 0,
                "feels_like": 0,
                "dew_point": 0,
                
                # Atmospheric conditions
                "pressure": 1013,
                "humidity": 0,
                "visibility": 10.0,
                "cloud_coverage": 0,
                "uv_index": 0,
                
                # Wind data
                "wind_speed": 0,
                "wind_direction": 0,
                "wind_gust": 0,
                
                # Sun times
                "sunrise": 0,
                "sunset": 0,
                
                # Precipitation
                "rain_1h": 0,
                "snow_1h": 0,
                
                # Timing
                "timestamp": 0,
                "timezone_offset": 0,
                
                # Observation quality
                "observation_quality": "unknown"
            }
        
        # Extract celestial data if available
        if "celestial" in enrichment_results and enrichment_results["celestial"].success:
            celestial_data = enrichment_results["celestial"].data
            summary = celestial_data.get("summary", {})
            enrichment["celestial"] = {
                "moon_phase": celestial_data.get("moon", {}).get("phase", 0.5),
                "moon_phase_name": summary.get("moon_phase_name", "Unknown"),
                "visible_planets": summary.get("visible_planets", []),
                "bright_stars": summary.get("visible_bright_stars", 0),
                "observation_quality": summary.get("observation_quality", "unknown")
            }
        else:
            # Fallback celestial data
            enrichment["celestial"] = {
                "moon_phase": 0.5,
                "moon_phase_name": "Unknown",
                "visible_planets": [],
                "bright_stars": 0,
                "observation_quality": "unknown"
            }
        
        # Extract satellite data if available
        if "satellites" in enrichment_results and enrichment_results["satellites"].success:
            satellite_data = enrichment_results["satellites"].data
            summary = satellite_data.get("summary", {})
            enrichment["satellite_check"] = {
                "visible_satellites": summary.get("total_visible_passes", 0),
                "starlink_present": len(satellite_data.get("starlink_passes", [])) > 0,
                "iss_visible": len(satellite_data.get("iss_passes", [])) > 0,
                "brightest_magnitude": summary.get("brightest_magnitude"),
                "next_pass": summary.get("next_bright_pass")
            }
        else:
            # Fallback satellite data
            enrichment["satellite_check"] = {
                "visible_satellites": 0,
                "starlink_present": False,
                "iss_visible": False,
                "brightest_magnitude": None,
                "next_pass": None
            }
        
        # Add plane match placeholder (this would integrate with existing plane_match service)
        enrichment["plane_match"] = {
            "is_plane": False,
            "confidence": 0.0,
            "nearby_flights": []
        }
        
        # Add processing summary
        successful_processors = sum(1 for result in enrichment_results.values() if result.success)
        total_processors = len(enrichment_results)
        enrichment["processing_summary"] = {
            "total_processors": total_processors,
            "successful_processors": successful_processors,
            "failed_processors": total_processors - successful_processors,
            "processor_results": {
                name: {"success": result.success, "error": result.error}
                for name, result in enrichment_results.items()
            }
        }
        
        return enrichment
        
    except Exception as e:
        logger.error(f"Error in enrichment processing: {e}")
        # Return fallback enrichment data
        return {
            "status": "failed",
            "processed_at": datetime.now().isoformat(),
            "error": str(e),
            "location": {
                "latitude": sensor_data.get("latitude", 0),
                "longitude": sensor_data.get("longitude", 0),
                "altitude": sensor_data.get("altitude", 0),
                "accuracy": sensor_data.get("accuracy", 0),
                "name": "Unknown Location"
            }
        }

@app.post("/sightings")
async def create_sighting(request: dict = None):
    try:
        if not request:
            raise HTTPException(status_code=400, detail="Request body required")
        
        # Extract data from request
        title = request.get("title", "")
        description = request.get("description", "")
        category = request.get("category", "ufo")
        witness_count = request.get("witness_count", 1)
        is_public = request.get("is_public", True)
        tags = request.get("tags", [])
        media_info = request.get("media_info", {})
        sensor_data = request.get("sensor_data", {})
        
        # Validate required fields
        if not title or len(title.strip()) < 5:
            raise HTTPException(status_code=400, detail="Title must be at least 5 characters")
        if not description or len(description.strip()) < 10:
            raise HTTPException(status_code=400, detail="Description must be at least 10 characters")
        
        # Generate enrichment data
        enrichment_data = await generate_enrichment_data(sensor_data)
        
        # Insert into database with enrichment
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

@app.post("/media/upload")
async def upload_media(
    file: UploadFile = File(...),
    sighting_id: str = Form(...)
):
    try:
        # Validate file type
        if not file.content_type or not file.content_type.startswith('image/'):
            raise HTTPException(status_code=400, detail="Only image files are allowed")
        
        # Generate unique filename
        file_extension = os.path.splitext(file.filename)[1] if file.filename else '.jpg'
        unique_filename = f"{uuid.uuid4()}{file_extension}"
        
        # Save file
        file_path = MEDIA_DIR / "images" / unique_filename
        with open(file_path, "wb") as buffer:
            shutil.copyfileobj(file.file, buffer)
        
        # Get file info
        file_size = os.path.getsize(file_path)
        
        # Create media record with full URLs
        base_url = "https://api.ufobeep.com"  # Use environment config in production
        media_info = {
            "id": str(uuid.uuid4()),
            "type": "image",
            "url": f"{base_url}/static/images/{unique_filename}",
            "thumbnail_url": f"{base_url}/static/images/{unique_filename}",  # Same for now, could generate thumbnail
            "filename": file.filename or unique_filename,
            "size": file_size,
            "content_type": file.content_type,
            "uploaded_at": datetime.now().isoformat()
        }
        
        # Update sighting with media info
        async with db_pool.acquire() as conn:
            # Get existing media_info
            existing_media = await conn.fetchval(
                "SELECT media_info FROM sightings WHERE id = $1", 
                uuid.UUID(sighting_id)
            )
            
            if existing_media:
                # Add to existing files - parse JSON if it's a string
                if isinstance(existing_media, str):
                    media_data = json.loads(existing_media)
                else:
                    media_data = existing_media
                if "files" not in media_data:
                    media_data["files"] = []
                media_data["files"].append(media_info)
            else:
                # Create new media data
                media_data = {
                    "files": [media_info],
                    "file_count": 1
                }
            
            # Update database
            await conn.execute(
                "UPDATE sightings SET media_info = $1 WHERE id = $2",
                json.dumps(media_data),
                uuid.UUID(sighting_id)
            )
        
        return {
            "success": True,
            "data": {
                "media_id": media_info["id"],
                "url": media_info["url"],
                "filename": media_info["filename"],
                "size": file_size
            },
            "message": "Media uploaded successfully",
            "timestamp": datetime.now().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        print(f"Error uploading media: {e}")
        # Clean up file if it exists
        if 'file_path' in locals() and os.path.exists(file_path):
            os.remove(file_path)
        raise HTTPException(status_code=500, detail=f"Error uploading media: {str(e)}")

# Email Interest Signup Endpoints
@app.post("/api/v1/emails/interest", response_class=HTMLResponse)
async def submit_email_interest_form(
    request: Request,
    email: str = Form(...),
    source: str = Form(default="app_download_page"),
    latitude: float = Form(None),
    longitude: float = Form(None),
    accuracy: float = Form(None)
):
    """Handle form submission for email interest - adds email to database and returns thank you page"""
    try:
        # Get client IP address
        client_ip = request.client.host
        if "x-forwarded-for" in request.headers:
            # Handle proxy/load balancer forwarded IPs
            client_ip = request.headers["x-forwarded-for"].split(",")[0].strip()
        elif "x-real-ip" in request.headers:
            client_ip = request.headers["x-real-ip"]
        
        # Get location data from IP using a free IP geolocation service
        location_data = None
        try:
            import aiohttp
            async with aiohttp.ClientSession() as session:
                # Using ipapi.co for free IP geolocation (1000 requests/month)
                async with session.get(f"http://ipapi.co/{client_ip}/json/", timeout=5) as response:
                    if response.status == 200:
                        location_data = await response.json()
                        # Only keep relevant fields
                        if location_data and not location_data.get('error'):
                            location_data = {
                                'city': location_data.get('city'),
                                'region': location_data.get('region'),
                                'country': location_data.get('country_name'),
                                'country_code': location_data.get('country_code'),
                                'latitude': location_data.get('latitude'),
                                'longitude': location_data.get('longitude'),
                                'timezone': location_data.get('timezone'),
                                'org': location_data.get('org')  # ISP info
                            }
        except Exception as e:
            print(f"Failed to get location for IP {client_ip}: {e}")
            location_data = None

        # Calculate location comparison if both IP and GPS data are available
        location_comparison = None
        if location_data and latitude is not None and longitude is not None:
            try:
                ip_lat = location_data.get('latitude')
                ip_lng = location_data.get('longitude')
                if ip_lat and ip_lng:
                    # Calculate distance between IP location and GPS location using Haversine formula
                    import math
                    def haversine_distance(lat1, lon1, lat2, lon2):
                        R = 6371  # Earth's radius in kilometers
                        dlat = math.radians(lat2 - lat1)
                        dlon = math.radians(lon2 - lon1)
                        a = (math.sin(dlat/2)**2 + 
                             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                             math.sin(dlon/2)**2)
                        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                        return R * c
                    
                    distance_km = haversine_distance(ip_lat, ip_lng, latitude, longitude)
                    location_comparison = {
                        'ip_coordinates': [ip_lat, ip_lng],
                        'gps_coordinates': [latitude, longitude],
                        'distance_km': round(distance_km, 2),
                        'ip_city': location_data.get('city'),
                        'ip_region': location_data.get('region'),
                        'ip_country': location_data.get('country'),
                        'accuracy_meters': accuracy
                    }
            except Exception as e:
                print(f"Failed to calculate location comparison: {e}")

        async with db_pool.acquire() as conn:
            # Try to insert the email with IP and GPS location data
            await conn.execute(
                """
                INSERT INTO email_interests (email, source, ip_address, ip_location_data, 
                                           gps_latitude, gps_longitude, gps_accuracy, location_comparison) 
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8) 
                """,
                email, source, client_ip, 
                json.dumps(location_data) if location_data else None,
                latitude, longitude, accuracy,
                json.dumps(location_comparison) if location_comparison else None
            )
        
        # Return success HTML page
        return HTMLResponse(content=f"""
        <!DOCTYPE html>
        <html lang="en">
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0">
            <title>Thanks for Your Interest!</title>
            <style>
                body {{
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    background: #0a0a0a;
                    color: #e5e5e5;
                    margin: 0;
                    padding: 0;
                    min-height: 100vh;
                    display: flex;
                    align-items: center;
                    justify-content: center;
                }}
                .container {{
                    text-align: center;
                    max-width: 500px;
                    padding: 40px 20px;
                }}
                .icon {{
                    font-size: 64px;
                    margin-bottom: 20px;
                }}
                h1 {{
                    color: #3b82f6;
                    margin-bottom: 16px;
                    font-size: 2rem;
                }}
                p {{
                    color: #9ca3af;
                    margin-bottom: 20px;
                    line-height: 1.6;
                }}
                .email {{
                    color: #3b82f6;
                    font-weight: 600;
                }}
                .back-link {{
                    display: inline-block;
                    margin-top: 20px;
                    color: #3b82f6;
                    text-decoration: none;
                    padding: 10px 20px;
                    border: 1px solid #3b82f6;
                    border-radius: 8px;
                    transition: all 0.3s ease;
                }}
                .back-link:hover {{
                    background: #3b82f6;
                    color: white;
                }}
            </style>
        </head>
        <body>
            <div class="container">
                <div class="icon">🎉</div>
                <h1>Thanks for Your Interest!</h1>
                <p>We've successfully added <span class="email">{email}</span> to our notification list.</p>
                <p>You'll be among the first to know when the UFOBeep mobile app launches!</p>
                <a href="/app" class="back-link">← Back to App Page</a>
            </div>
        </body>
        </html>
        """, status_code=200)
        
    except Exception as e:
        # Check if it's a unique violation (email already exists)
        if "duplicate key value" in str(e) or "unique" in str(e).lower():
            return HTMLResponse(content=f"""
            <!DOCTYPE html>
            <html lang="en">
            <head>
                <meta charset="UTF-8">
                <meta name="viewport" content="width=device-width, initial-scale=1.0">
                <title>Already Registered!</title>
                <style>
                    body {{
                        font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                        background: #0a0a0a;
                        color: #e5e5e5;
                        margin: 0;
                        padding: 0;
                        min-height: 100vh;
                        display: flex;
                        align-items: center;
                        justify-content: center;
                    }}
                    .container {{
                        text-align: center;
                        max-width: 500px;
                        padding: 40px 20px;
                    }}
                    .icon {{
                        font-size: 64px;
                        margin-bottom: 20px;
                    }}
                    h1 {{
                        color: #f59e0b;
                        margin-bottom: 16px;
                        font-size: 2rem;
                    }}
                    p {{
                        color: #9ca3af;
                        margin-bottom: 20px;
                        line-height: 1.6;
                    }}
                    .email {{
                        color: #f59e0b;
                        font-weight: 600;
                    }}
                    .back-link {{
                        display: inline-block;
                        margin-top: 20px;
                        color: #3b82f6;
                        text-decoration: none;
                        padding: 10px 20px;
                        border: 1px solid #3b82f6;
                        border-radius: 8px;
                        transition: all 0.3s ease;
                    }}
                    .back-link:hover {{
                        background: #3b82f6;
                        color: white;
                    }}
                </style>
            </head>
            <body>
                <div class="container">
                    <div class="icon">✅</div>
                    <h1>You're Already on the List!</h1>
                    <p>The email <span class="email">{email}</span> is already registered for notifications.</p>
                    <p>We'll make sure to notify you when the UFOBeep app launches!</p>
                    <a href="/app" class="back-link">← Back to App Page</a>
                </div>
            </body>
            </html>
            """, status_code=200)
        else:
            # Generic error
            print(f"Error saving email: {e}")
            raise HTTPException(status_code=500, detail=f"Failed to save email: {str(e)}")
    finally:
        if conn:
            await conn.close()

@app.get("/api/v1/emails/count")
async def get_interest_count():
    """Get count of interested users"""
    try:
        async with db_pool.acquire() as conn:
            result = await conn.fetchrow("SELECT COUNT(*) as count FROM email_interests")
            count = result['count'] if result else 0
            
            return {"count": count}
        
    except Exception as e:
        print(f"Error getting email count: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get count: {str(e)}")

@app.get("/test/openweather/{lat}/{lng}")
async def test_openweather_api(lat: float, lng: float):
    """Test OpenWeather API calls with real coordinates"""
    try:
        # Test weather API
        import aiohttp
        api_key = settings.openweather_api_key
        
        if not api_key or api_key == "dummy":
            return {"error": "OpenWeather API key not configured"}
        
        weather_data = {}
        geocoding_data = {}
        
        async with aiohttp.ClientSession() as session:
            # Test current weather API
            weather_url = f"https://api.openweathermap.org/data/2.5/weather"
            weather_params = {
                'lat': lat,
                'lon': lng,
                'appid': api_key,
                'units': 'metric'
            }
            
            async with session.get(weather_url, params=weather_params) as response:
                if response.status == 200:
                    weather_data = await response.json()
                else:
                    weather_data = {"error": f"HTTP {response.status}: {await response.text()}"}
            
            # Test reverse geocoding API  
            geocode_url = f"http://api.openweathermap.org/geo/1.0/reverse"
            geocode_params = {
                'lat': lat,
                'lon': lng,
                'limit': 1,
                'appid': api_key
            }
            
            async with session.get(geocode_url, params=geocode_params) as response:
                if response.status == 200:
                    geocoding_data = await response.json()
                else:
                    geocoding_data = {"error": f"HTTP {response.status}: {await response.text()}"}
        
        return {
            "coordinates": {"lat": lat, "lng": lng},
            "weather": weather_data,
            "geocoding": geocoding_data,
            "api_key_configured": bool(api_key and api_key != "dummy")
        }
        
    except Exception as e:
        print(f"Error testing OpenWeather API: {e}")
        return {"error": str(e)}

def _calculate_observation_quality(weather_data):
    """Calculate observation quality for UFO sightings based on weather conditions"""
    try:
        # Get key weather parameters
        visibility = weather_data.get("visibility_km", 10.0)
        cloud_cover = weather_data.get("cloud_cover_percent", 0)
        humidity = weather_data.get("humidity_percent", 50)
        wind_speed = weather_data.get("wind_speed_ms", 0)
        precipitation = weather_data.get("rain_1h_mm", 0) + weather_data.get("snow_1h_mm", 0)
        
        # Calculate quality score (0-100)
        score = 100
        
        # Visibility impact (most important)
        if visibility < 1.0:
            score -= 60  # Very poor visibility
        elif visibility < 5.0:
            score -= 30  # Poor visibility
        elif visibility < 8.0:
            score -= 15  # Moderate visibility
        # visibility >= 8km is excellent (no penalty)
        
        # Cloud cover impact
        if cloud_cover > 80:
            score -= 25  # Mostly cloudy
        elif cloud_cover > 50:
            score -= 15  # Partly cloudy
        elif cloud_cover > 25:
            score -= 5   # Few clouds
        # < 25% cloud cover is good (no penalty)
        
        # Precipitation impact
        if precipitation > 0:
            score -= 20  # Any precipitation reduces visibility
        
        # High humidity can cause haze
        if humidity > 85:
            score -= 10  # Very humid
        elif humidity > 70:
            score -= 5   # Humid
        
        # Wind can affect stability for observation
        if wind_speed > 10:
            score -= 10  # Very windy
        elif wind_speed > 5:
            score -= 5   # Windy
        
        # Ensure score stays within bounds
        score = max(0, min(100, score))
        
        # Convert to qualitative rating
        if score >= 90:
            return "excellent"
        elif score >= 75:
            return "very_good" 
        elif score >= 60:
            return "good"
        elif score >= 40:
            return "fair"
        elif score >= 25:
            return "poor"
        else:
            return "very_poor"
            
    except Exception:
        return "unknown"
