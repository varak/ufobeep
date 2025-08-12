from fastapi import FastAPI, HTTPException, UploadFile, File, Form
from fastapi.middleware.cors import CORSMiddleware
from fastapi.staticfiles import StaticFiles
from app.config.environment import settings
from app.routers import plane_match
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
        print("Sightings table initialized")
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
                "condition": weather_data.get("weather_main", "Clear"),
                "description": weather_data.get("weather_description", "Clear sky"),
                "temperature": weather_data.get("temperature_c", 0),
                "humidity": weather_data.get("humidity_percent", 0),
                "wind_speed": weather_data.get("wind_speed_ms", 0),
                "wind_direction": weather_data.get("wind_direction_deg", 0),
                "visibility": weather_data.get("visibility_km", 10.0),
                "cloud_coverage": weather_data.get("cloud_cover_percent", 0),
                "icon_code": weather_data.get("weather_icon", "01d")
            }
        else:
            # Fallback weather data
            enrichment["weather"] = {
                "condition": "Clear",
                "description": "Weather data unavailable",
                "temperature": 0,
                "humidity": 0,
                "wind_speed": 0,
                "wind_direction": 0,
                "visibility": 10.0,
                "cloud_coverage": 0,
                "icon_code": "01d"
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

# Import and include Emails router (keep this one - it's simple)
try:
    from app.routers import emails
    app.include_router(emails.router)
except ImportError as e:
    print(f"Warning: Could not import emails router: {e}")
