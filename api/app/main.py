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

@app.get("/v1/ping")
def ping():
    return {"message": "pong"}

# Include routers
app.include_router(plane_match.router)

# Import and include media router
try:
    from routers import media
    app.include_router(media.router)
except ImportError as e:
    print(f"Warning: Could not import media router: {e}")
