"""
Alerts Service - Clean business logic for UFO sightings/alerts
Extracts all the database and business logic from HTTP endpoints
"""
import json
import uuid
import math
from datetime import datetime
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass

@dataclass
class AlertLocation:
    latitude: float
    longitude: float
    name: str = "Unknown Location"
    accuracy: float = 50.0

@dataclass
class Alert:
    id: str
    title: Optional[str]
    description: Optional[str]
    category: str
    location: AlertLocation
    witness_count: int
    alert_level: str
    created_at: datetime
    media_files: List[Dict] = None
    enrichment: Dict = None

class AlertsService:
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    async def get_recent_alerts(self, limit: int = 20) -> List[Alert]:
        """Get recent public alerts with clean data structure"""
        async with self.db_pool.acquire() as conn:
            rows = await conn.fetch("""
                SELECT id::text, title, description, category, alert_level, 
                       witness_count, created_at, sensor_data, media_info, enrichment_data
                FROM sightings 
                WHERE is_public = true 
                ORDER BY created_at DESC 
                LIMIT $1
            """, limit)
            
            alerts = []
            for row in rows:
                location = self._extract_location(row["sensor_data"], row["enrichment_data"])
                if location:  # Only include alerts with valid locations
                    alerts.append(Alert(
                        id=row["id"],
                        title=row["title"],
                        description=row["description"],
                        category=row["category"] or "ufo",
                        location=location,
                        witness_count=row["witness_count"] or 1,
                        alert_level=row["alert_level"] or "low",
                        created_at=row["created_at"],
                        media_files=self._process_media(row["media_info"], row["id"]),
                        enrichment=self._process_enrichment(row["enrichment_data"])
                    ))
            
            return alerts
    
    async def get_alert_by_id(self, alert_id: str) -> Optional[Alert]:
        """Get single alert by ID"""
        async with self.db_pool.acquire() as conn:
            row = await conn.fetchrow("""
                SELECT id::text, title, description, category, alert_level,
                       witness_count, created_at, sensor_data, media_info, enrichment_data
                FROM sightings 
                WHERE id = $1 AND is_public = true
            """, uuid.UUID(alert_id))
            
            if not row:
                return None
                
            location = self._extract_location(row["sensor_data"], row["enrichment_data"])
            if not location:
                return None
                
            return Alert(
                id=row["id"],
                title=row["title"],
                description=row["description"],
                category=row["category"] or "ufo",
                location=location,
                witness_count=row["witness_count"] or 1,
                alert_level=row["alert_level"] or "low",
                created_at=row["created_at"],
                media_files=self._process_media(row["media_info"], row["id"]),
                enrichment=self._process_enrichment(row["enrichment_data"])
            )
    
    def _extract_location(self, sensor_data, enrichment_data) -> Optional[AlertLocation]:
        """Extract location from sensor/enrichment data - unified logic"""
        # Try enrichment data first (has processed location name)
        if enrichment_data:
            enrichment = self._parse_json(enrichment_data)
            if enrichment and "location" in enrichment:
                loc = enrichment["location"]
                lat = loc.get("latitude")
                lng = loc.get("longitude")
                if self._valid_coords(lat, lng):
                    return AlertLocation(
                        latitude=float(lat),
                        longitude=float(lng),
                        name=loc.get("name", "Unknown Location"),
                        accuracy=loc.get("accuracy", 50.0)
                    )
        
        # Fall back to sensor data
        if sensor_data:
            sensor = self._parse_json(sensor_data)
            if sensor:
                lat, lng = self._extract_coords_from_sensor(sensor)
                if self._valid_coords(lat, lng):
                    return AlertLocation(
                        latitude=lat,
                        longitude=lng,
                        name="Unknown Location"
                    )
        
        return None
    
    def _extract_coords_from_sensor(self, sensor_data: dict) -> Tuple[Optional[float], Optional[float]]:
        """Extract coords from sensor data - handles both formats"""
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
    
    def _valid_coords(self, lat, lng) -> bool:
        """Check if coordinates are valid"""
        return (lat is not None and lng is not None and 
                lat != 0.0 and lng != 0.0 and
                -90 <= lat <= 90 and -180 <= lng <= 180)
    
    def _parse_json(self, data) -> Optional[dict]:
        """Safely parse JSON data"""
        if not data:
            return None
        try:
            if isinstance(data, str):
                return json.loads(data)
            return data
        except:
            return None
    
    def _process_media(self, media_info, sighting_id: str) -> List[Dict]:
        """Process media files into clean format"""
        media_files = []
        if media_info:
            media = self._parse_json(media_info)
            if media and isinstance(media, dict) and "files" in media:
                for media_file in media["files"]:
                    filename = media_file.get("filename", "")
                    media_url = f"https://api.ufobeep.com/media/{sighting_id}/{filename}"
                    
                    # Determine media type
                    media_type = media_file.get("type", "image")
                    if not media_type or media_type == "unknown":
                        media_type = "video" if any(ext in filename.lower() for ext in ['.mp4', '.mov', '.avi']) else "image"
                    
                    # Use new URL structure if available, fallback to old
                    thumbnail_url = media_file.get("thumbnail_url") or (f"{media_url}?thumbnail=true" if media_type == "video" else media_url)
                    web_url = media_file.get("web_url", media_url)
                    preview_url = media_file.get("preview_url", thumbnail_url)
                    
                    media_entry = {
                        "type": media_type,
                        "url": media_url,
                        "thumbnail_url": thumbnail_url,
                        "web_url": web_url,
                        "preview_url": preview_url,
                        "filename": filename
                    }
                    
                    # Include EXIF data if available (for plate solving)
                    if 'exif_data' in media_file:
                        media_entry['exif_data'] = media_file['exif_data']
                    
                    media_files.append(media_entry)
        return media_files
    
    def _process_enrichment(self, enrichment_data) -> Dict:
        """Process enrichment data into clean format"""
        if not enrichment_data:
            return {}
        
        enrichment = self._parse_json(enrichment_data)
        return enrichment if enrichment else {}
    
    async def create_alert(self, title: str = None, description: str = None, 
                          category: str = "ufo", witness_count: int = 1,
                          is_public: bool = True, tags: List[str] = None,
                          media_info: Dict = None, sensor_data: Dict = None,
                          enrichment_data: Dict = None, alert_level: str = "normal") -> str:
        """Create new alert/sighting"""
        async with self.db_pool.acquire() as conn:
            alert_id = await conn.fetchval("""
                INSERT INTO sightings 
                (title, description, category, witness_count, is_public, tags, 
                 media_info, sensor_data, enrichment_data, alert_level, status)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                RETURNING id
            """, title, description, category, witness_count, is_public,
                tags or [], json.dumps(media_info or {}), 
                json.dumps(sensor_data or {}), json.dumps(enrichment_data or {}),
                alert_level, "created")
            
            return str(alert_id)
    
    async def create_anonymous_beep(self, device_id: str, location: Dict, 
                                   description: str = None) -> Tuple[str, Dict]:
        """Create anonymous beep with location privacy"""
        # Validate location
        lat = float(location['latitude'])
        lng = float(location['longitude'])
        if lat == 0.0 and lng == 0.0:
            raise ValueError("Invalid GPS coordinates (0,0)")
        
        # Apply privacy jittering (100m radius)
        import random
        import math
        jitter_radius = 100 / 111000  # 111km per degree latitude
        angle = random.uniform(0, 2 * math.pi)
        distance = random.uniform(0, jitter_radius)
        
        jittered_lat = lat + (distance * math.cos(angle))
        jittered_lng = lng + (distance * math.sin(angle))
        
        # Build sensor data
        sensor_data = {
            'location': {
                'latitude': jittered_lat,
                'longitude': jittered_lng,
                'accuracy': location.get('accuracy', 50.0),
                'original_latitude': lat,
                'original_longitude': lng
            },
            'device_id': device_id,
            'timestamp': datetime.utcnow().isoformat()
        }
        
        # Create alert
        alert_id = await self.create_alert(
            title=None,
            description=description,
            category="ufo",
            witness_count=1,
            is_public=True,
            sensor_data=sensor_data,
            alert_level="normal"
        )
        
        return alert_id, {"lat": jittered_lat, "lng": jittered_lng}
    
    async def confirm_witness(self, sighting_id: str, device_id: str, 
                            witness_data: Dict) -> Dict:
        """Handle witness confirmation with all the complex logic"""
        async with self.db_pool.acquire() as conn:
            # Check if sighting exists
            sighting = await conn.fetchrow("""
                SELECT id, witness_count, created_at, sensor_data, enrichment_data
                FROM sightings WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting:
                raise ValueError("Sighting not found")
            
            # Check if device already confirmed
            existing = await conn.fetchrow("""
                SELECT device_id FROM witness_confirmations 
                WHERE sighting_id = $1 AND device_id = $2
            """, uuid.UUID(sighting_id), device_id)
            
            if existing:
                raise ValueError("Device already confirmed as witness")
            
            # Insert witness confirmation
            await conn.execute("""
                INSERT INTO witness_confirmations 
                (sighting_id, device_id, confirmation_data, confirmed_at)
                VALUES ($1, $2, $3, NOW())
            """, uuid.UUID(sighting_id), device_id, json.dumps(witness_data))
            
            # Update witness count
            new_count = await conn.fetchval("""
                UPDATE sightings 
                SET witness_count = witness_count + 1 
                WHERE id = $1 
                RETURNING witness_count
            """, uuid.UUID(sighting_id))
            
            # Get confirmation stats
            confirmations = await conn.fetch("""
                SELECT device_id, confirmed_at, confirmation_data
                FROM witness_confirmations 
                WHERE sighting_id = $1 
                ORDER BY confirmed_at DESC
            """, uuid.UUID(sighting_id))
            
            return {
                "confirmed": True,
                "new_witness_count": new_count,
                "total_confirmations": len(confirmations),
                "confirmation_time": datetime.utcnow().isoformat(),
                "sighting_age_minutes": int((datetime.utcnow() - sighting['created_at']).total_seconds() / 60)
            }
    
    async def get_witness_aggregation(self, sighting_id: str) -> Dict:
        """Get witness aggregation data with clean business logic"""
        async with self.db_pool.acquire() as conn:
            # Get sighting details
            sighting = await conn.fetchrow("""
                SELECT id, title, description, witness_count, created_at, 
                       sensor_data, enrichment_data
                FROM sightings WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting:
                raise ValueError("Sighting not found")
            
            # Get all witness confirmations
            confirmations = await conn.fetch("""
                SELECT device_id, confirmed_at, confirmation_data
                FROM witness_confirmations 
                WHERE sighting_id = $1 
                ORDER BY confirmed_at ASC
            """, uuid.UUID(sighting_id))
            
            # Process confirmations data
            processed_confirmations = []
            for conf in confirmations:
                conf_data = self._parse_json(conf['confirmation_data']) or {}
                processed_confirmations.append({
                    'device_id': conf['device_id'][:8] + '...',  # Privacy
                    'confirmed_at': conf['confirmed_at'].isoformat(),
                    'confidence': conf_data.get('confidence', 'medium'),
                    'has_description': bool(conf_data.get('description')),
                    'has_location': bool(conf_data.get('location'))
                })
            
            # Calculate stats
            time_since = datetime.utcnow() - sighting['created_at']
            minutes_since = int(time_since.total_seconds() / 60)
            
            return {
                "sighting_id": sighting_id,
                "total_witnesses": len(confirmations),
                "witness_count": sighting['witness_count'],
                "confirmations": processed_confirmations,
                "sighting_age_minutes": minutes_since,
                "created_at": sighting['created_at'].isoformat(),
                "credibility_score": min(100, len(confirmations) * 10)
            }
    
    async def get_witness_status(self, sighting_id: str, device_id: str) -> Dict:
        """Check if device has confirmed this sighting"""
        async with self.db_pool.acquire() as conn:
            confirmation = await conn.fetchrow("""
                SELECT device_id, confirmed_at 
                FROM witness_confirmations 
                WHERE sighting_id = $1 AND device_id = $2
            """, uuid.UUID(sighting_id), device_id)
            
            return {
                "has_confirmed": bool(confirmation),
                "confirmed_at": confirmation['confirmed_at'].isoformat() if confirmation else None,
                "device_id": device_id,
                "sighting_id": sighting_id
            }