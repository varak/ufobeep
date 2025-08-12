from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from app.config.environment import settings
from app.routers import plane_match
import asyncpg
import json
from datetime import datetime
import uuid

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
                    sensor_data
                FROM sightings 
                WHERE is_public = true 
                ORDER BY created_at DESC 
                LIMIT 20
            """)
            
            alerts = []
            for row in rows:
                alert = {
                    "id": row["id"],
                    "title": row["title"],
                    "description": row["description"],
                    "category": row["category"],
                    "alertLevel": row["alert_level"],
                    "status": row["status"],
                    "witnessCount": row["witness_count"],
                    "createdAt": row["created_at"].isoformat(),
                    "latitude": 0.0,  # Default to 0.0 instead of null
                    "longitude": 0.0,  # Default to 0.0 instead of null
                    "distance": 0.0,  # Default to 0.0 instead of null
                    "bearing": 0.0,   # Default to 0.0 instead of null
                    "viewCount": 0,
                    "verificationScore": 0.0,
                    "mediaFiles": [],
                    "tags": row["tags"] or [],
                    "isPublic": row["is_public"],
                    "submittedAt": row["created_at"].isoformat(),
                    "processedAt": row["created_at"].isoformat(),
                    "matrixRoomId": "",  # Default empty string
                    "reporterId": ""     # Default empty string
                }
                
                # Extract coordinates from sensor data if available
                if row["sensor_data"]:
                    sensor_data = row["sensor_data"]
                    if "latitude" in sensor_data and sensor_data["latitude"] is not None:
                        alert["latitude"] = float(sensor_data["latitude"])
                    if "longitude" in sensor_data and sensor_data["longitude"] is not None:
                        alert["longitude"] = float(sensor_data["longitude"])
                
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

# Import and include Emails router (keep this one - it's simple)
try:
    from app.routers import emails
    app.include_router(emails.router)
except ImportError as e:
    print(f"Warning: Could not import emails router: {e}")
