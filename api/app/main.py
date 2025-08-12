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
    allow_origins=settings.cors_origins,
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

# Mount static files for media serving
app.mount("/media", StaticFiles(directory="media"), name="media")

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
                    media_info
                FROM sightings 
                WHERE is_public = true 
                ORDER BY created_at DESC 
                LIMIT 20
            """)
            
            alerts = []
            for row in rows:
                # Extract coordinates from sensor data
                latitude = 0.0
                longitude = 0.0
                if row["sensor_data"]:
                    sensor_data = row["sensor_data"]
                    if "latitude" in sensor_data and sensor_data["latitude"] is not None:
                        latitude = float(sensor_data["latitude"])
                    if "longitude" in sensor_data and sensor_data["longitude"] is not None:
                        longitude = float(sensor_data["longitude"])
                
                # Process media info
                media_files = []
                if row["media_info"]:
                    media_info = row["media_info"]
                    if "files" in media_info:
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
                        "longitude": longitude
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
                    "reporter_id": ""
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
        
        # Insert into database
        async with db_pool.acquire() as conn:
            sighting_id = await conn.fetchval("""
                INSERT INTO sightings 
                (title, description, category, witness_count, is_public, tags, media_info, sensor_data, alert_level, status)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10)
                RETURNING id
            """, title.strip(), description.strip(), category, witness_count, is_public, 
                tags, json.dumps(media_info), json.dumps(sensor_data), "low", "created")
        
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
            "url": f"{base_url}/media/images/{unique_filename}",
            "thumbnail_url": f"{base_url}/media/images/{unique_filename}",  # Same for now, could generate thumbnail
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
                # Add to existing files
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
