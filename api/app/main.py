from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from app.config.environment import settings
from app.routers import plane_match

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

# Log configuration on startup
@app.on_event("startup")
async def startup_event():
    settings.log_configuration()

@app.get("/healthz")
def healthz():
    return {"ok": True}

@app.get("/ping")
def ping():
    return {"message": "pong"}

# Include routers
app.include_router(plane_match.router)

# Disable complex routers for now - just get basic endpoints working

# Basic endpoints for mobile app testing
@app.get("/alerts")
def get_alerts():
    return {
        "success": True,
        "data": {
            "alerts": [],
            "total_count": 0,
            "offset": 0,
            "limit": 20,
            "has_more": False
        },
        "message": "No alerts available",
        "timestamp": "2025-08-11T15:30:00Z"
    }

@app.post("/sightings")
def create_sighting(request: dict = None):
    return {
        "success": True,
        "data": {
            "sighting_id": "test_sighting_123",
            "status": "created",
            "alert_level": "low"
        },
        "message": "Sighting created successfully",
        "timestamp": "2025-08-11T15:30:00Z"
    }

# Import and include Emails router (keep this one - it's simple)
try:
    from app.routers import emails
    app.include_router(emails.router)
except ImportError as e:
    print(f"Warning: Could not import emails router: {e}")
