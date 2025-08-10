from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid

# Simple FastAPI app for testing
app = FastAPI(
    title="UFOBeep API",
    description="Real-time UFO and anomaly sighting alert system API",
    version="1.0.0",
    debug=True,
)

# CORS middleware
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, be more restrictive
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Simple models
class SensorData(BaseModel):
    timestamp: datetime
    latitude: float
    longitude: float
    azimuth_deg: float
    pitch_deg: float
    roll_deg: Optional[float] = None
    hfov_deg: Optional[float] = None
    vfov_deg: Optional[float] = None
    device_id: Optional[str] = None
    app_version: Optional[str] = None

class SightingSubmission(BaseModel):
    title: str
    description: str
    category: str
    sensor_data: SensorData
    media_files: List[str] = []
    duration_seconds: Optional[int] = None
    witness_count: int = 1
    tags: List[str] = []
    is_public: bool = True
    submitted_at: datetime

# In-memory storage for testing
sightings_db = {}

@app.get("/")
async def root():
    return {"message": "UFOBeep API is running"}

@app.get("/ping")
async def ping():
    return {"message": "pong"}

@app.post("/v1/sightings")
async def create_sighting(submission: SightingSubmission):
    try:
        # Generate unique sighting ID
        sighting_id = f"sighting_{uuid.uuid4().hex[:12]}"
        
        # Store sighting (in production: save to database)
        sightings_db[sighting_id] = {
            "id": sighting_id,
            "title": submission.title,
            "description": submission.description,
            "category": submission.category,
            "status": "pending",
            "created_at": datetime.utcnow().isoformat(),
        }
        
        return {
            "success": True,
            "data": {
                "sighting_id": sighting_id,
                "status": "created",
                "alert_level": "low",
            },
            "message": "Sighting created successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "SIGHTING_CREATE_FAILED",
                "message": "Failed to create sighting",
                "details": str(e)
            }
        )

@app.get("/v1/sightings")
async def list_sightings(limit: int = 20, offset: int = 0):
    try:
        # Return stored sightings
        all_sightings = list(sightings_db.values())
        paginated = all_sightings[offset:offset + limit]
        
        return {
            "success": True,
            "data": paginated,
            "total_count": len(all_sightings),
            "offset": offset,
            "limit": limit,
            "has_more": (offset + limit) < len(all_sightings),
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "SIGHTING_LIST_FAILED",
                "message": "Failed to retrieve sightings"
            }
        )

# Simple media upload endpoints for testing
class PresignedUploadRequest(BaseModel):
    filename: str
    content_type: str
    size_bytes: int

@app.post("/v1/media/presign")
async def create_presigned_upload(request: PresignedUploadRequest):
    try:
        upload_id = f"upload_{uuid.uuid4().hex[:12]}"
        
        # Mock presigned upload response
        return {
            "success": True,
            "data": {
                "upload_id": upload_id,
                "upload_url": f"http://localhost:8000/mock-upload/{upload_id}",
                "fields": {
                    "key": f"uploads/{upload_id}/{request.filename}",
                    "Content-Type": request.content_type,
                },
            },
            "message": "Presigned upload URL created",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "PRESIGN_FAILED", 
                "message": "Failed to create presigned upload URL"
            }
        )

class MediaUploadCompleteRequest(BaseModel):
    upload_id: str
    media_type: str

@app.post("/v1/media/complete")
async def complete_media_upload(request: MediaUploadCompleteRequest):
    try:
        media_id = f"media_{uuid.uuid4().hex[:12]}"
        
        # Mock completed upload response
        return {
            "success": True,
            "data": {
                "id": media_id,
                "upload_id": request.upload_id,
                "type": request.media_type,
                "filename": f"file_{media_id}",
                "url": f"http://localhost:8000/media/{media_id}",
                "size_bytes": 1024000,
                "content_type": "image/jpeg",
                "uploaded_at": datetime.utcnow().isoformat(),
            },
            "message": "Upload completed successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "UPLOAD_COMPLETE_FAILED",
                "message": "Failed to complete upload"
            }
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)