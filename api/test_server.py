from fastapi import FastAPI, HTTPException
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel
from typing import List, Optional
from datetime import datetime
import uuid
import math
import random

# Simple FastAPI app for testing alerts functionality
app = FastAPI(
    title="UFOBeep Test API",
    description="Real-time UFO and anomaly sighting alert system API (Test Version)",
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

def jitter_coordinates(lat: float, lng: float):
    """Apply privacy jittering to coordinates"""
    min_jitter = 100  # 100m
    max_jitter = 300  # 300m
    
    # Convert meters to approximate degrees
    lat_jitter_deg = random.uniform(min_jitter, max_jitter) / 111000
    lng_jitter_deg = random.uniform(min_jitter, max_jitter) / (111000 * abs(math.cos(math.radians(lat))))
    
    # Apply random direction
    lat_jitter = random.choice([-1, 1]) * lat_jitter_deg
    lng_jitter = random.choice([-1, 1]) * lng_jitter_deg
    
    jittered_lat = max(-90.0, min(90.0, lat + lat_jitter))
    jittered_lng = max(-180.0, min(180.0, lng + lng_jitter))
    
    return {
        "latitude": jittered_lat,
        "longitude": jittered_lng,
        "altitude": None,
        "accuracy": None
    }

def determine_alert_level(submission: SightingSubmission):
    """Determine alert level based on sighting characteristics"""
    score = 0
    
    # Base score by category
    if submission.category == "ufo":
        score += 3
    elif submission.category == "anomaly": 
        score += 2
    else:
        score += 1
    
    # Multiple witnesses increase score
    if submission.witness_count > 5:
        score += 2
    elif submission.witness_count > 2:
        score += 1
    
    # Media files increase score
    score += len(submission.media_files)
    
    # Duration increases score
    if submission.duration_seconds:
        if submission.duration_seconds > 300:  # 5+ minutes
            score += 2
        elif submission.duration_seconds > 60:  # 1+ minute
            score += 1
    
    # Convert score to alert level
    if score >= 8:
        return "critical"
    elif score >= 5:
        return "high"
    elif score >= 3:
        return "medium"
    else:
        return "low"

def sighting_to_alert(sighting):
    """Convert a sighting to an alert format for the mobile app"""
    return {
        "id": sighting["id"],
        "title": sighting["title"],
        "description": sighting["description"],
        "category": sighting["category"],
        "status": sighting["status"],
        "alert_level": sighting["alert_level"],
        "witness_count": sighting["witness_count"],
        "view_count": sighting["view_count"],
        "verification_score": sighting.get("verification_score", 0.0),
        "location": sighting["jittered_location"],
        "sensor_data": {
            "timestamp": sighting["sensor_data"]["timestamp"],
            "azimuth_deg": sighting["sensor_data"]["azimuth_deg"],
            "pitch_deg": sighting["sensor_data"]["pitch_deg"],
        },
        "media_files": [],
        "tags": sighting.get("tags", []),
        "is_public": sighting.get("is_public", True),
        "created_at": sighting["created_at"],
        "submitted_at": sighting.get("submitted_at", sighting["created_at"]),
        "processed_at": sighting.get("processed_at"),
        "matrix_room_id": None,
        "reporter_id": None,
    }

@app.get("/")
async def root():
    return {"message": "UFOBeep Test API is running"}

@app.get("/ping")
async def ping():
    return {"message": "pong"}

@app.post("/v1/sightings")
async def create_sighting(submission: SightingSubmission):
    try:
        # Generate unique sighting ID
        sighting_id = f"sighting_{uuid.uuid4().hex[:12]}"
        
        # Apply coordinate jittering for privacy
        jittered_location = jitter_coordinates(
            submission.sensor_data.latitude,
            submission.sensor_data.longitude
        )
        
        # Determine alert level
        alert_level = determine_alert_level(submission)
        
        # Store sighting (in production: save to database)
        sighting = {
            "id": sighting_id,
            "title": submission.title,
            "description": submission.description,
            "category": submission.category,
            "sensor_data": submission.sensor_data.dict(),
            "media_files": submission.media_files,
            "status": "pending",
            "alert_level": alert_level,
            "jittered_location": jittered_location,
            "witness_count": submission.witness_count,
            "view_count": 0,
            "verification_score": 0.0,
            "tags": submission.tags,
            "is_public": submission.is_public,
            "submitted_at": submission.submitted_at.isoformat(),
            "created_at": datetime.utcnow().isoformat(),
        }
        
        sightings_db[sighting_id] = sighting
        
        return {
            "success": True,
            "data": {
                "sighting_id": sighting_id,
                "status": "created",
                "alert_level": alert_level,
                "jittered_location": jittered_location
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

# ALERTS ENDPOINTS
@app.get("/v1/alerts")
async def list_alerts(
    limit: int = 20,
    offset: int = 0,
    category: Optional[str] = None,
    min_alert_level: Optional[str] = None,
    max_distance_km: Optional[float] = None,
    latitude: Optional[float] = None,
    longitude: Optional[float] = None,
    recent_hours: Optional[int] = None,
    verified_only: bool = False,
):
    try:
        from datetime import datetime, timedelta
        
        # Filter alerts based on criteria
        filtered_alerts = []
        current_time = datetime.utcnow()
        
        for sighting in sightings_db.values():
            # Apply category filter
            if category and sighting["category"] != category:
                continue
            
            # Apply verification filter
            if verified_only and sighting["status"] != "verified":
                continue
            
            # Apply alert level filter
            if min_alert_level:
                alert_levels = ["low", "medium", "high", "critical"]
                min_level_idx = alert_levels.index(min_alert_level)
                current_level_idx = alert_levels.index(sighting["alert_level"])
                if current_level_idx < min_level_idx:
                    continue
            
            # Apply time filter
            if recent_hours:
                created_at = datetime.fromisoformat(sighting["created_at"])
                cutoff_time = current_time - timedelta(hours=recent_hours)
                if created_at < cutoff_time:
                    continue
            
            # Apply distance filter (if coordinates provided)
            if max_distance_km and latitude is not None and longitude is not None:
                sighting_lat = sighting["jittered_location"]["latitude"]
                sighting_lng = sighting["jittered_location"]["longitude"]
                
                # Calculate distance using Haversine formula
                def haversine_distance(lat1, lon1, lat2, lon2):
                    R = 6371  # Earth's radius in kilometers
                    dlat = math.radians(lat2 - lat1)
                    dlon = math.radians(lon2 - lon1)
                    a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                         math.sin(dlon/2) * math.sin(dlon/2))
                    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                    return R * c
                
                distance = haversine_distance(latitude, longitude, sighting_lat, sighting_lng)
                if distance > max_distance_km:
                    continue
            
            # Convert sighting to alert format
            alert_data = sighting_to_alert(sighting)
            
            # Add distance if coordinates were provided
            if latitude is not None and longitude is not None:
                sighting_lat = sighting["jittered_location"]["latitude"]
                sighting_lng = sighting["jittered_location"]["longitude"]
                
                def haversine_distance(lat1, lon1, lat2, lon2):
                    R = 6371  # Earth's radius in kilometers
                    dlat = math.radians(lat2 - lat1)
                    dlon = math.radians(lon2 - lon1)
                    a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                         math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                         math.sin(dlon/2) * math.sin(dlon/2))
                    c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                    return R * c
                
                distance = haversine_distance(latitude, longitude, sighting_lat, sighting_lng)
                alert_data["distance_km"] = round(distance, 2)
            
            filtered_alerts.append(alert_data)
        
        # Sort by creation time (newest first), then by alert level (highest first)
        def sort_key(alert):
            alert_level_priority = {"critical": 4, "high": 3, "medium": 2, "low": 1}
            created_at = datetime.fromisoformat(alert["created_at"])
            alert_priority = alert_level_priority.get(alert["alert_level"], 1)
            return (-created_at.timestamp(), -alert_priority)
        
        filtered_alerts.sort(key=sort_key)
        
        # Apply pagination
        total_count = len(filtered_alerts)
        paginated_alerts = filtered_alerts[offset:offset + limit]
        
        return {
            "success": True,
            "data": {
                "alerts": paginated_alerts,
                "total_count": total_count,
                "offset": offset,
                "limit": limit,
                "has_more": (offset + limit) < total_count,
                "filters_applied": {
                    "category": category,
                    "min_alert_level": min_alert_level,
                    "max_distance_km": max_distance_km,
                    "recent_hours": recent_hours,
                    "verified_only": verified_only,
                    "location_provided": latitude is not None and longitude is not None,
                },
            },
            "message": f"Retrieved {len(paginated_alerts)} alerts",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "ALERTS_LIST_FAILED",
                "message": "Failed to retrieve alerts",
                "details": str(e)
            }
        )

@app.get("/v1/alerts/nearby")
async def get_nearby_alerts(
    latitude: float,
    longitude: float,
    radius_km: float = 50.0,
    limit: int = 50,
    recent_hours: Optional[int] = 24,
    min_alert_level: Optional[str] = None,
):
    try:
        from datetime import datetime, timedelta
        
        nearby_alerts = []
        current_time = datetime.utcnow()
        cutoff_time = current_time - timedelta(hours=recent_hours) if recent_hours else None
        
        def haversine_distance(lat1, lon1, lat2, lon2):
            R = 6371  # Earth's radius in kilometers
            dlat = math.radians(lat2 - lat1)
            dlon = math.radians(lon2 - lon1)
            a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                 math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                 math.sin(dlon/2) * math.sin(dlon/2))
            c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
            return R * c
        
        def calculate_bearing(lat1, lon1, lat2, lon2):
            lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
            dlon = lon2 - lon1
            y = math.sin(dlon) * math.cos(lat2)
            x = (math.cos(lat1) * math.sin(lat2) - 
                 math.sin(lat1) * math.cos(lat2) * math.cos(dlon))
            bearing = math.atan2(y, x)
            bearing = math.degrees(bearing)
            bearing = (bearing + 360) % 360  # Normalize to 0-360
            return bearing
        
        for sighting in sightings_db.values():
            # Apply time filter
            if cutoff_time:
                created_at = datetime.fromisoformat(sighting["created_at"])
                if created_at < cutoff_time:
                    continue
            
            # Get sighting location
            sighting_lat = sighting["jittered_location"]["latitude"]
            sighting_lng = sighting["jittered_location"]["longitude"]
            
            # Calculate distance
            distance = haversine_distance(latitude, longitude, sighting_lat, sighting_lng)
            if distance > radius_km:
                continue
            
            # Apply alert level filter
            if min_alert_level:
                alert_levels = ["low", "medium", "high", "critical"]
                min_level_idx = alert_levels.index(min_alert_level)
                current_level_idx = alert_levels.index(sighting["alert_level"])
                if current_level_idx < min_level_idx:
                    continue
            
            # Convert to alert format (minimal data for performance)
            alert_data = {
                "id": sighting["id"],
                "title": sighting["title"],
                "category": sighting["category"],
                "alert_level": sighting["alert_level"],
                "distance_km": round(distance, 2),
                "location": {
                    "latitude": sighting_lat,
                    "longitude": sighting_lng,
                },
                "created_at": sighting["created_at"],
                "view_count": sighting["view_count"],
                "witness_count": sighting["witness_count"],
                "bearing_deg": round(calculate_bearing(latitude, longitude, sighting_lat, sighting_lng), 1),
            }
            
            nearby_alerts.append(alert_data)
        
        # Sort by distance (nearest first), then by alert level
        def sort_key(alert):
            alert_level_priority = {"critical": 4, "high": 3, "medium": 2, "low": 1}
            distance = alert.get("distance_km", float('inf'))
            alert_priority = alert_level_priority.get(alert.get("alert_level", "low"), 1)
            return (distance, -alert_priority)
        
        nearby_alerts.sort(key=sort_key)
        
        # Apply limit
        limited_alerts = nearby_alerts[:limit]
        
        return {
            "success": True,
            "data": {
                "alerts": limited_alerts,
                "total_count": len(nearby_alerts),
                "search_radius_km": radius_km,
                "search_center": {
                    "latitude": latitude,
                    "longitude": longitude
                },
                "filters_applied": {
                    "recent_hours": recent_hours,
                    "min_alert_level": min_alert_level,
                },
            },
            "message": f"Found {len(limited_alerts)} nearby alerts",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "NEARBY_ALERTS_FAILED",
                "message": "Failed to retrieve nearby alerts"
            }
        )

@app.get("/v1/alerts/health")
async def alerts_health_check():
    """Check alerts service health"""
    total_alerts = len(sightings_db)
    pending_alerts = len([s for s in sightings_db.values() if s["status"] == "pending"])
    high_priority_alerts = len([s for s in sightings_db.values() if s["alert_level"] in ["high", "critical"]])
    
    return {
        "status": "healthy",
        "total_alerts": total_alerts,
        "pending_alerts": pending_alerts,
        "high_priority_alerts": high_priority_alerts,
        "timestamp": datetime.utcnow().isoformat()
    }

@app.get("/v1/alerts/{alert_id}")
async def get_alert_details(alert_id: str):
    try:
        # Check if sighting/alert exists
        sighting = sightings_db.get(alert_id)
        if not sighting:
            raise HTTPException(
                status_code=404,
                detail={
                    "error": "ALERT_NOT_FOUND",
                    "message": f"Alert {alert_id} not found"
                }
            )
        
        # Increment view count
        sighting["view_count"] += 1
        
        # Convert to alert format
        alert_data = sighting_to_alert(sighting)
        
        return {
            "success": True,
            "data": alert_data,
            "message": "Alert details retrieved successfully",
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except HTTPException:
        raise
    except Exception as e:
        raise HTTPException(
            status_code=500,
            detail={
                "error": "ALERT_DETAILS_FAILED",
                "message": "Failed to retrieve alert details"
            }
        )

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)