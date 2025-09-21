"""
Alerts Service - Clean business logic for UFO sightings/alerts
Extracts all the database and business logic from HTTP endpoints
"""
import json
import uuid
import math
import logging
from datetime import datetime, timezone
from typing import List, Dict, Optional, Tuple
from dataclasses import dataclass
from ..utils.short_url_utils import generate_short_url

logger = logging.getLogger(__name__)

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
    reporter_id: Optional[str] = None
    reporter_username: Optional[str] = None
    media_files: List[Dict] = None
    enrichment: Dict = None
    comment_count: int = 0
    source: Optional[str] = None
    occurred_at: Optional[datetime] = None
    external_url: Optional[str] = None
    short_url: Optional[str] = None

class AlertsService:
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    async def get_total_alerts_count(self, source: Optional[str] = None, max_distance_km: Optional[float] = None, user_latitude: Optional[float] = None, user_longitude: Optional[float] = None) -> int:
        """Get total count of public alerts with optional filtering"""
        async with self.db_pool.acquire() as conn:
            # Build WHERE clause based on filters
            where_conditions = ["s.is_public = true"]
            params = []
            param_index = 1

            # Source filtering
            if source == 'ufobeep':
                where_conditions.append(f"(s.source IS NULL OR s.source != 'mufon')")
            elif source == 'mufon':
                where_conditions.append(f"s.source = 'mufon'")
            elif source:
                where_conditions.append(f"s.source = ${param_index}")
                params.append(source)
                param_index += 1

            # Distance filtering (if user location provided)
            if max_distance_km and user_latitude and user_longitude:
                where_conditions.append(f"""
                    ST_DWithin(
                        ST_GeogFromText('POINT(' || s.public_longitude || ' ' || s.public_latitude || ')'),
                        ST_GeogFromText('POINT({user_longitude} {user_latitude})'),
                        {max_distance_km * 1000}
                    )
                """)

            where_clause = " AND ".join(where_conditions)

            query = f"""
                SELECT COUNT(*) FROM sightings s
                WHERE {where_clause}
            """

            return await conn.fetchval(query, *params)
    
    async def get_recent_alerts(self, limit: int = 20, offset: int = 0, source: Optional[str] = None, max_distance_km: Optional[float] = None, user_latitude: Optional[float] = None, user_longitude: Optional[float] = None) -> List[Alert]:
        """Get recent public alerts with clean data structure and filtering"""
        async with self.db_pool.acquire() as conn:
            # Build WHERE clause with filters - same logic as get_total_alerts_count
            where_conditions = ["s.is_public = true"]
            params = []
            param_index = 1

            # Source filtering
            if source == 'ufobeep':
                where_conditions.append("(s.source IS NULL OR s.source != 'mufon')")
            elif source == 'mufon':
                where_conditions.append("s.source = 'mufon'")
            elif source:
                where_conditions.append(f"s.source = ${param_index}")
                params.append(source)
                param_index += 1

            # Distance filtering (if user location provided)
            if max_distance_km and user_latitude and user_longitude:
                where_conditions.append(f"""
                    ST_DWithin(
                        ST_GeogFromText('POINT(' || s.public_longitude || ' ' || s.public_latitude || ')'),
                        ST_GeogFromText('POINT({user_longitude} {user_latitude})'),
                        {max_distance_km * 1000}
                    )
                """)

            where_clause = " AND ".join(where_conditions)

            # Add LIMIT and OFFSET parameters
            params.extend([limit, offset])
            limit_param = f"${param_index}"
            offset_param = f"${param_index + 1}"

            query = f"""
                SELECT s.id::text, s.title, s.description, s.category, s.alert_level,
                       s.witness_count, s.created_at, s.reporter_id, s.sensor_data, s.media_info, s.enrichment_data,
                       u.username as reporter_username, s.source,
                       COALESCE(s.occurred_at, s.created_at) as occurred_at, s.external_url,
                       COALESCE(c.comment_count, 0) as comment_count, s.short_url
                FROM sightings s
                LEFT JOIN users u ON s.reporter_id = u.id::text
                LEFT JOIN (
                    SELECT sighting_id, COUNT(*) as comment_count
                    FROM comments
                    GROUP BY sighting_id
                ) c ON s.id = c.sighting_id
                WHERE {where_clause}
                ORDER BY s.created_at DESC
                LIMIT {limit_param} OFFSET {offset_param}
            """

            rows = await conn.fetch(query, *params)
            
            alerts = []
            for row in rows:
                location = self._extract_location(row["sensor_data"], row["enrichment_data"])
                
                # Debug logging for location extraction
                print(f"DEBUG: Alert {row['id'][:8]}... source={row['source']}, location={location}")
                
                # Allow MUFON alerts without location data
                if location or row["source"] == "mufon":
                    alerts.append(Alert(
                        id=row["id"],
                        title=row["title"],
                        description=row["description"],
                        category=row["category"] or "ufo",
                        location=location,
                        witness_count=row["witness_count"] or 1,
                        alert_level=row["alert_level"] or "low",
                        created_at=row["created_at"],
                        reporter_id=row["reporter_id"],
                        reporter_username=row["reporter_username"],
                        media_files=self._process_media(row["media_info"], row["id"]),
                        enrichment=self._process_enrichment(row["enrichment_data"]),
                        comment_count=row["comment_count"],
                        source=row["source"],
                        occurred_at=row["occurred_at"],
                        external_url=row["external_url"],
                        short_url=row["short_url"]
                    ))
            
            return alerts
    
    async def get_alert_by_id(self, alert_id: str) -> Optional[Alert]:
        """Get single alert by ID"""
        async with self.db_pool.acquire() as conn:
            row = await conn.fetchrow("""
                SELECT s.id::text, s.title, s.description, s.category, s.alert_level,
                       s.witness_count, s.created_at, s.reporter_id, s.sensor_data, s.media_info, s.enrichment_data,
                       u.username as reporter_username, s.source, s.occurred_at, s.external_url,
                       COALESCE(c.comment_count, 0) as comment_count, s.short_url
                FROM sightings s
                LEFT JOIN users u ON s.reporter_id = u.id::text
                LEFT JOIN (
                    SELECT sighting_id, COUNT(*) as comment_count 
                    FROM comments 
                    GROUP BY sighting_id
                ) c ON s.id = c.sighting_id
                WHERE s.id = $1 AND s.is_public = true
            """, uuid.UUID(alert_id))
            
            if not row:
                return None
                
            location = self._extract_location(row["sensor_data"], row["enrichment_data"])
            
            # Allow MUFON alerts without location data
            if not location and row["source"] == "mufon":
                location = AlertLocation(latitude=0.0, longitude=0.0, name="")
            elif not location:
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
                reporter_id=row["reporter_id"],
                reporter_username=row["reporter_username"],
                media_files=self._process_media(row["media_info"], row["id"]),
                enrichment=self._process_enrichment(row["enrichment_data"]),
                comment_count=row["comment_count"],
                source=row["source"],
                occurred_at=row["occurred_at"],
                external_url=row["external_url"],
                short_url=row["short_url"]
            )
    
    async def get_alert_by_short_url(self, short_url: str) -> Optional[Alert]:
        """Get single alert by short_url for efficient direct access"""
        async with self.db_pool.acquire() as conn:
            row = await conn.fetchrow("""
                SELECT s.id::text, s.title, s.description, s.category, s.alert_level,
                       s.witness_count, s.created_at, s.reporter_id, s.sensor_data, s.media_info, s.enrichment_data,
                       u.username as reporter_username, s.source, s.occurred_at, s.external_url,
                       COALESCE(c.comment_count, 0) as comment_count, s.short_url
                FROM sightings s
                LEFT JOIN users u ON s.reporter_id = u.id::text
                LEFT JOIN (
                    SELECT sighting_id, COUNT(*) as comment_count 
                    FROM comments 
                    GROUP BY sighting_id
                ) c ON s.id = c.sighting_id
                WHERE s.short_url = $1 AND s.is_public = true
            """, short_url)
            
            if not row:
                return None
                
            location = self._extract_location(row["sensor_data"], row["enrichment_data"])
            
            # Allow MUFON alerts without location data
            if not location and row["source"] == "mufon":
                location = AlertLocation(latitude=0.0, longitude=0.0, name="")
            elif not location:
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
                reporter_id=row["reporter_id"],
                reporter_username=row["reporter_username"],
                media_files=self._process_media(row["media_info"], row["id"]),
                enrichment=self._process_enrichment(row["enrichment_data"]),
                comment_count=row["comment_count"],
                source=row["source"],
                occurred_at=row["occurred_at"],
                external_url=row["external_url"],
                short_url=row["short_url"]
            )
    
    def _extract_location(self, sensor_data, enrichment_data) -> Optional[AlertLocation]:
        """Extract location from sensor/enrichment data - unified logic"""

        # For regular beeps: Use sensor data FIRST for accurate GPS coordinates
        # This fixes the 12.1km distance issue where geocoded city center was used instead of actual location
        if sensor_data:
            sensor = self._parse_json(sensor_data)
            if sensor:
                lat, lng = self._extract_coords_from_sensor(sensor)
                
                # Get location name from enrichment if available
                location_name = "Unknown Location"
                if enrichment_data:
                    enrichment = self._parse_json(enrichment_data)
                    if enrichment and "geocoding" in enrichment:
                        geocoding = enrichment["geocoding"]
                        if geocoding:
                            location_name = geocoding.get("location_name") or geocoding.get("location") or geocoding.get("formatted_address") or geocoding.get("display_name") or ""
                
                # Otherwise try to get from sensor data
                if not location_name:
                    if sensor.get("location", {}).get("name"):
                        location_name = sensor["location"]["name"]
                    elif sensor.get("location_name"):
                        location_name = sensor["location_name"]
                
                if self._valid_coords(lat, lng):
                    return AlertLocation(
                        latitude=lat,
                        longitude=lng,
                        name=location_name,
                        accuracy=sensor.get("location", {}).get("accuracy", 50.0)
                    )
        
        # Fall back to enrichment data if no sensor data (for MUFON imports)
        if enrichment_data:
            enrichment = self._parse_json(enrichment_data)
            if enrichment and "geocoding" in enrichment:
                geocoding = enrichment["geocoding"]
                if geocoding:
                    lat = geocoding.get("latitude")
                    lng = geocoding.get("longitude")
                    location_name = geocoding.get("location_name") or geocoding.get("location") or geocoding.get("formatted_address") or geocoding.get("display_name", "Unknown Location")
                    if self._valid_coords(lat, lng):
                        return AlertLocation(
                            latitude=float(lat),
                            longitude=float(lng),
                            name=location_name,
                            accuracy=50.0
                        )

        # Fallback to enrichment data for MUFON imports (no sensor data available)
        if enrichment_data:
            enrichment = self._parse_json(enrichment_data)
            if enrichment and "geocoding" in enrichment:
                geocoding = enrichment["geocoding"]
                if geocoding:
                    lat = geocoding.get("latitude")
                    lng = geocoding.get("longitude")
                    location_name = geocoding.get("location_name") or geocoding.get("location") or geocoding.get("formatted_address") or geocoding.get("display_name") or ""
                    if self._valid_coords(lat, lng):
                        return AlertLocation(
                            latitude=float(lat),
                            longitude=float(lng),
                            name=location_name,
                            accuracy=50.0  # Default for MUFON
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
                    media_url = f"https://ufobeep.com/api/media/{sighting_id}/{filename}"
                    
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
    
    async def get_user_id_by_username(self, conn, username: str) -> str:
        """
        Get existing user ID by username.
        Returns the user's UUID primary key (users.id) to use as reporter_id.
        """
        if not username:
            return None
            
        clean_username = username.strip()[:64]
        user_id = await conn.fetchval(
            "SELECT id FROM users WHERE username = $1",
            clean_username
        )
        return str(user_id) if user_id else None

    async def _ensure_mufon_user(self, conn, username: str) -> str:
        """
        Ensure MUFON user exists in database, create if not.
        Returns the user's UUID primary key.
        """
        clean_username = username.strip()[:64]
        
        # Try to get existing user first
        user_id = await conn.fetchval(
            "SELECT id FROM users WHERE username = $1",
            clean_username
        )
        
        if user_id:
            return str(user_id)
        
        # Create MUFON user
        user_id = await conn.fetchval("""
            INSERT INTO users (username, email, created_at) 
            VALUES ($1, $2, NOW()) 
            RETURNING id
        """, clean_username, f"{clean_username.lower()}@mufon.com")
        
        return str(user_id)


    async def create_alert(self, title: str = None, description: str = None, 
                          category: str = "ufo", witness_count: int = 1,
                          is_public: bool = True, tags: List[str] = None,
                          media_info: Dict = None, sensor_data: Dict = None,
                          enrichment_data: Dict = None, alert_level: str = "normal",
                          device_id: str = None, username: str = None,
                          source: str = None, source_id: str = None, 
                          external_url: str = None, latitude: float = None, 
                          longitude: float = None, occurred_at: str = None,
                          external_id: str = None) -> str:
        """Create new alert/sighting"""
        async with self.db_pool.acquire() as conn:
            # Get existing user by username or use device_id directly
            reporter_id = None
            if username:
                reporter_id = await self.get_user_id_by_username(conn, username)
                print(f"create_alert: username={username} reporter_id={reporter_id}")
            elif device_id:
                # For mobile app: use device_id directly as reporter_id
                reporter_id = device_id
                print(f"create_alert: using device_id as reporter_id={reporter_id}")

            # For MUFON imports, create the user if it doesn't exist
            if not reporter_id and source == "mufon" and username:
                reporter_id = await self._ensure_mufon_user(conn, username)
                print(f"create_alert: created/found MUFON user reporter_id={reporter_id}")

            if not reporter_id:
                print(f"WARNING: No reporter_id found for username={username}, device_id={device_id}")
                # Don't raise error - allow creation with null reporter_id for backward compatibility
            
            # Parse occurred_at if provided
            occurred_at_timestamp = None
            if occurred_at:
                try:
                    from datetime import datetime
                    occurred_at_timestamp = datetime.fromisoformat(occurred_at.replace('Z', '+00:00'))
                except Exception as e:
                    print(f"Warning: Failed to parse occurred_at '{occurred_at}': {e}")

            # SINGLE SOURCE OF TRUTH: Generate short_url BEFORE any branching
            temp_id = external_id or str(uuid.uuid4())
            short_url = generate_short_url(temp_id)
            if not short_url:
                raise Exception(f"Failed to generate short URL for temp_id: {temp_id}")
            print(f"Generated short URL: {short_url} for temp_id: {temp_id}")

            # Check for existing record by external_id for MUFON/NUFORC imports  
            existing_alert = None
            if external_id and source in ["mufon", "nuforc"]:
                existing_alert = await conn.fetchval("""
                    SELECT id FROM sightings WHERE external_id = $1
                """, external_id)
                
                if existing_alert:
                    # Update existing record
                    print(f"Updating existing {source} record with external_id: {external_id}")
                    await conn.execute("""
                        UPDATE sightings SET
                            title = $1, description = $2, category = $3, witness_count = $4,
                            is_public = $5, tags = $6, media_info = $7, sensor_data = $8,
                            enrichment_data = $9, alert_level = $10, status = $11, reporter_id = $12,
                            source = $13, external_url = $14, public_latitude = $15, public_longitude = $16,
                            occurred_at = $17, updated_at = NOW()
                        WHERE external_id = $18
                    """, title, description, category, witness_count, is_public,
                        tags or [], json.dumps(media_info or {}), 
                        json.dumps(sensor_data or {}), json.dumps(enrichment_data or {}),
                        alert_level, "verified", reporter_id, source, external_url, latitude, longitude,
                        occurred_at_timestamp, external_id)
                    alert_id = str(existing_alert)

            # Unified INSERT logic for both new MUFON and regular alerts
            if not existing_alert:
                insert_source = source or "ufobeep"
                insert_status = "verified" if source in ["mufon", "nuforc"] else "created"
                action_desc = f"Creating new {insert_source} record" + (f" with external_id: {external_id}" if external_id else " with pre-generated short_url")
                print(action_desc)
                
                # Build fields dict dynamically - much more maintainable than positional params
                fields = {
                    'title': title,
                    'description': description,
                    'category': category,
                    'witness_count': witness_count,
                    'is_public': is_public,
                    'tags': tags or [],
                    'media_info': json.dumps(media_info or {}),
                    'sensor_data': json.dumps(sensor_data or {}),
                    'enrichment_data': json.dumps(enrichment_data or {}),
                    'alert_level': alert_level,
                    'status': insert_status,
                    'reporter_id': reporter_id,
                    'source': insert_source,
                    'external_url': external_url,
                    'public_latitude': latitude,
                    'public_longitude': longitude,
                    'occurred_at': occurred_at_timestamp,
                    'short_url': short_url,
                    'external_id': external_id
                }
                
                # Remove None values to avoid database constraints
                fields = {k: v for k, v in fields.items() if v is not None}
                
                # Generate dynamic query - no more parameter counting hell
                columns = ', '.join(fields.keys())
                placeholders = ', '.join(f'${i+1}' for i in range(len(fields)))
                values = list(fields.values())
                
                query = f"INSERT INTO sightings ({columns}) VALUES ({placeholders}) RETURNING id"
                alert_id = await conn.fetchval(query, *values)
            
            return str(alert_id)
    
    async def create_beep(self, device_id: str, location: Dict = None, 
                         description: str = None, username: str = None,
                         title: str = None, source: str = None, 
                         enrichment_data: Dict = None, occurred_at: str = None,
                         external_id: str = None) -> Tuple[str, Dict]:
        """Create beep with location privacy - single create_alert call"""
        
        # Handle location and jittering
        sensor_data = {}
        lat = lng = jittered_lat = jittered_lng = 0.0
        
        if location:
            lat = float(location['latitude'])
            lng = float(location['longitude'])
            
            # Apply privacy jittering for regular alerts (not MUFON)
            if source != "mufon":
                import random
                import math
                jitter_radius = 100 / 111000  # 111km per degree latitude  
                angle = random.uniform(0, 2 * math.pi)
                distance = random.uniform(0, jitter_radius)
                
                jittered_lat = lat + (distance * math.cos(angle))
                jittered_lng = lng + (distance * math.sin(angle))
            else:
                # No jittering for MUFON alerts
                jittered_lat = lat
                jittered_lng = lng
            
            # Build sensor data with location info
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
        elif source != "mufon":
            raise ValueError("Location required for non-MUFON alerts")
        
        # Single create_alert call for all cases
        alert_id = await self.create_alert(
            title=title,
            description=description,
            category="ufo",
            witness_count=1,
            is_public=True,
            sensor_data=sensor_data,
            enrichment_data=enrichment_data,
            alert_level="normal",
            device_id=device_id,
            username=username,
            source=source,
            latitude=lat if location else None,
            longitude=lng if location else None,
            occurred_at=occurred_at,
            external_id=external_id
        )
        
        # Auto-follow the alert for the creator so they get notifications
        # Skip for MUFON imports (historical data shouldn't trigger notifications)
        if username and source != "mufon":
            try:
                await self._auto_follow_alert(alert_id, username)
            except Exception as e:
                print(f"Auto-follow failed for alert {alert_id}: {e}")
                # Continue without auto-follow if database unavailable
        
        # Call enrichment service after alert creation
        try:
            if source == "mufon" and enrichment_data:
                # For MUFON: directly save the enrichment data we already have in memory
                async with self.db_pool.acquire() as conn:
                    await conn.execute("""
                        UPDATE sightings 
                        SET enrichment_data = $1
                        WHERE id = $2
                    """, json.dumps(enrichment_data), uuid.UUID(alert_id))
            elif source != "mufon":
                await self._enrich_alert(alert_id, lat, lng, description)
        except Exception as e:
            print(f"Enrichment failed for alert {alert_id}: {e}")
            # Continue without enrichment if database unavailable
        
        return alert_id, {"lat": jittered_lat, "lng": jittered_lng}
    
    async def _auto_follow_alert(self, alert_id: str, username: str):
        """Auto-follow an alert for the creator so they get comment notifications"""
        async with self.db_pool.acquire() as conn:
            # Get user ID from username
            user_id = await self.get_user_id_by_username(conn, username)
            if user_id:
                # Insert follow record (ignore if already exists)
                await conn.execute("""
                    INSERT INTO follows (sighting_id, user_id) 
                    VALUES ($1, $2) 
                    ON CONFLICT (sighting_id, user_id) DO NOTHING
                """, alert_id, user_id)
                print(f"Auto-followed alert {alert_id} for user {username} ({user_id})")
            else:
                print(f"Could not auto-follow alert {alert_id}: user {username} not found")
    
    async def _enrich_alert(self, alert_id: str, latitude: float, longitude: float, description: str = None):
        """Call enrichment service for weather and reverse geocoding"""
        try:
            
            from app.services.enrichment_service import enrichment_orchestrator, initialize_enrichment_processors, EnrichmentContext
            
            # Initialize processors if not already done
            if not enrichment_orchestrator.processors:
                initialize_enrichment_processors()
            
            # Create enrichment context
            context = EnrichmentContext(
                sighting_id=alert_id,
                latitude=latitude,
                longitude=longitude,
                altitude=None,
                timestamp=datetime.utcnow(),
                azimuth_deg=0.0,
                pitch_deg=0.0,
                category="ufo",
                description=description  # Now content analysis will work
            )
            
            # Run enrichment
            enrichment_start = datetime.utcnow()
            logger.info(f"📡 API ENRICHMENT TRIGGER: Starting enrichment for sighting {alert_id}")
            results = await enrichment_orchestrator.enrich_sighting(context)
            enrichment_time = int((datetime.utcnow() - enrichment_start).total_seconds() * 1000)
            logger.info(f"📡 API ENRICHMENT COMPLETE: Sighting {alert_id} enrichment finished ({enrichment_time}ms)")
            
            # Save enrichment results to database - MERGE with existing enrichment data
            new_enrichment_data = {}
            for processor_name, result in results.items():
                if result.success and result.data:
                    new_enrichment_data[processor_name] = result.data
            
            # Update sighting with enrichment data - merge instead of replace
            async with self.db_pool.acquire() as conn:
                # Get existing enrichment data first
                existing_row = await conn.fetchrow("""
                    SELECT enrichment_data FROM sightings WHERE id = $1
                """, uuid.UUID(alert_id))
                
                # Merge existing with new enrichment data
                existing_enrichment = {}
                if existing_row and existing_row['enrichment_data']:
                    existing_enrichment = self._parse_json(existing_row['enrichment_data']) or {}
                
                # Merge: existing data takes precedence, new data fills in missing keys
                merged_enrichment = {**new_enrichment_data, **existing_enrichment}
                
                await conn.execute("""
                    UPDATE sightings 
                    SET enrichment_data = $1
                    WHERE id = $2
                """, json.dumps(merged_enrichment), uuid.UUID(alert_id))
            
            print(f"Enrichment completed for alert {alert_id}: {list(merged_enrichment.keys())}")
            
        except Exception as e:
            print(f"Enrichment failed for alert {alert_id}: {e}")
            # Don't fail the alert creation if enrichment fails
    
    async def confirm_witness(self, sighting_id: str, device_id: str, 
                            witness_data: Dict) -> Dict:
        """Handle witness confirmation with all the complex logic"""
        async with self.db_pool.acquire() as conn:
            # Check if sighting exists
            sighting = await conn.fetchrow("""
                SELECT id, witness_count, created_at, sensor_data, enrichment_data
                FROM sightings WHERE id = $1
            """, sighting_id)
            
            if not sighting:
                raise ValueError("Sighting not found")
            
            # Check time window restriction (MP13-5) - configurable via environment
            from app.config.environment import settings
            time_window_minutes = settings.witness_confirmation_time_window_minutes
            
            # Check if sighting is within time window using database comparison
            is_within_window = await conn.fetchval("""
                SELECT (NOW() - created_at) < INTERVAL '%s minutes' 
                FROM sightings 
                WHERE id = $1
            """ % time_window_minutes, uuid.UUID(sighting_id))
            
            if not is_within_window:
                raise ValueError(f"Witness confirmation window has closed. You can only confirm sightings within {time_window_minutes} minutes of occurrence.")
            
            # Check if device already confirmed this sighting
            existing = await conn.fetchrow("""
                SELECT device_id FROM witness_confirmations 
                WHERE sighting_id = $1 AND device_id = $2
            """, sighting_id, device_id)
            
            if existing:
                raise ValueError("Device already confirmed as witness")
            
            # Anti-spam protection (MP13-5) - rate limiting per user
            recent_confirmations = await conn.fetchval("""
                SELECT COUNT(*) FROM witness_confirmations 
                WHERE device_id = $1 AND confirmed_at > NOW() - INTERVAL '1 hour'
            """, device_id)
            
            max_confirmations_per_hour = settings.witness_confirmation_rate_limit_per_hour
            if recent_confirmations >= max_confirmations_per_hour:
                raise ValueError(f"Rate limit exceeded. You can only confirm {max_confirmations_per_hour} sightings per hour.")
            
            # Check distance if location data is provided
            if witness_data.get('latitude') and witness_data.get('longitude'):
                sensor = self._parse_json(sighting['sensor_data'])
                if sensor and 'location' in sensor:
                    orig_lat = sensor['location'].get('latitude')
                    orig_lng = sensor['location'].get('longitude')
                    if orig_lat and orig_lng:
                        # Calculate distance using Haversine formula
                        import math
                        lat1, lng1 = float(orig_lat), float(orig_lng)
                        lat2, lng2 = float(witness_data['latitude']), float(witness_data['longitude'])
                        
                        dlat = math.radians(lat2 - lat1)
                        dlng = math.radians(lng2 - lng1)
                        a = (math.sin(dlat/2) * math.sin(dlat/2) + 
                             math.cos(math.radians(lat1)) * math.cos(math.radians(lat2)) * 
                             math.sin(dlng/2) * math.sin(dlng/2))
                        c = 2 * math.atan2(math.sqrt(a), math.sqrt(1-a))
                        distance_km = 6371 * c  # Earth radius in km
                        
                        # Get actual visibility for this sighting to calculate max distance
                        max_distance_km = 50.0  # Default 2x 25km visibility
                        enrichment = self._parse_json(sighting['enrichment_data'])
                        if enrichment:
                            weather_data = enrichment.get('weather', {})
                            visibility_km = weather_data.get('visibility_km')
                            if visibility_km is not None:
                                # Use 2x the actual visibility for this sighting
                                max_distance_km = visibility_km * 2.0
                        
                        # Check if user is within 2x the actual visibility distance
                        if distance_km > max_distance_km:
                            raise ValueError(f"Witness location too far from sighting ({distance_km:.1f}km). Must be within {max_distance_km:.1f}km (2x visibility) to confirm.")
            
            # Insert witness confirmation with typed parameters (no JSON extraction)
            await conn.execute("""
                INSERT INTO witness_confirmations 
                (sighting_id, device_id, witness_latitude, witness_longitude, 
                 witness_altitude, location_accuracy, still_visible, confirmation_data)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """, 
                uuid.UUID(sighting_id), 
                device_id,
                float(witness_data["latitude"]),
                float(witness_data["longitude"]),
                float(witness_data["altitude"]) if witness_data.get("altitude") is not None else None,
                float(witness_data["accuracy"]) if witness_data.get("accuracy") is not None else None,
                witness_data.get("still_visible", True),
                json.dumps(witness_data)
            )
            
            # Update witness count
            new_count = await conn.fetchval("""
                UPDATE sightings 
                SET witness_count = witness_count + 1 
                WHERE id = $1 
                RETURNING witness_count
            """, uuid.UUID(sighting_id))
            
            # Auto-follow the sighting for the witness so they get comment notifications
            await self._auto_follow_for_witness(conn, sighting_id, device_id)
            
            # Add automatic "I saw it" comment to trigger comment notifications
            # This will automatically notify all followers (including the original reporter) via the existing comment system
            await self._add_confirmation_comment(conn, sighting_id, device_id)
            
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
                "confirmation_time": datetime.now(timezone.utc).isoformat(),
                "sighting_age_minutes": int((datetime.now(timezone.utc) - sighting['created_at']).total_seconds() / 60)
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
            time_since = datetime.now(timezone.utc) - sighting['created_at']
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

    async def _notify_original_reporter_of_confirmation(self, conn, sighting_id: str, witness_device_id: str, witness_count: int):
        """Send a beep notification to the original reporter when someone confirms their sighting"""
        try:
            # Get the original reporter's user ID
            sighting_info = await conn.fetchrow("""
                SELECT reporter_id 
                FROM sightings 
                WHERE id = $1
            """, uuid.UUID(sighting_id))
            
            if not sighting_info or not sighting_info['reporter_id']:
                print(f"⚠️ No reporter found for sighting {sighting_id}")
                return
            
            # Get the original reporter's device info from user ID
            device_info = await conn.fetchrow("""
                SELECT push_token, device_id 
                FROM devices 
                WHERE user_id = $1 AND is_active = true
                ORDER BY updated_at DESC LIMIT 1
            """, sighting_info['reporter_id'])
            
            if not device_info or device_info['device_id'] == witness_device_id:
                # No device found, or same device confirming
                print(f"⚠️ Original reporter device not found or same device confirming")
                return
            
            if not device_info or not device_info['push_token']:
                print(f"⚠️ Original reporter device {device_info['device_id'] if device_info else 'unknown'} has no FCM token")
                return
                
            # Note: Witness confirmation notifications are handled by the comment system
            # When someone clicks "I see it too", it auto-adds a comment which triggers 
            # comment notifications to followers (including the original reporter)
            print(f"📝 Witness confirmation will be handled by auto-comment notification system")
            
            print(f"✅ Sent confirmation beep to original reporter {device_info['device_id']}")
            
        except Exception as e:
            print(f"❌ Failed to notify original reporter: {e}")
            # Don't fail the confirmation if notification fails

    async def _auto_follow_for_witness(self, conn, sighting_id: str, device_id: str):
        """Auto-follow a sighting for a witness so they get comment notifications"""
        try:
            # Get user ID from device ID
            user_id = await conn.fetchval("""
                SELECT user_id 
                FROM devices 
                WHERE device_id = $1 AND is_active = true
            """, device_id)
            
            if not user_id:
                print(f"⚠️ Could not find user for device {device_id}, skipping auto-follow")
                return
            
            # Insert follow record (ignore if already exists)
            await conn.execute("""
                INSERT INTO follows (sighting_id, user_id) 
                VALUES ($1, $2) 
                ON CONFLICT (sighting_id, user_id) DO NOTHING
            """, uuid.UUID(sighting_id), user_id)
            
            print(f"✅ Auto-followed sighting {sighting_id} for witness device {device_id}")
            
        except Exception as e:
            print(f"❌ Failed to auto-follow for witness: {e}")
            # Don't fail the confirmation if auto-follow fails

    async def _add_confirmation_comment(self, conn, sighting_id: str, device_id: str):
        """Add automatic 'I saw it' comment directly in database with proper notifications"""
        from datetime import datetime, timezone
        from app.services.notify import notify_users
        import uuid
        
        try:
            # Get user info from device ID
            user_info = await conn.fetchrow("""
                SELECT d.user_id, u.username 
                FROM devices d
                JOIN users u ON d.user_id = u.id
                WHERE d.device_id = $1 AND d.is_active = true
            """, device_id)
            
            if not user_info:
                print(f"⚠️ Could not find user for device {device_id}, skipping confirmation comment")
                return
            
            # Insert comment directly into database
            now = datetime.now(timezone.utc)
            comment_row = await conn.fetchrow("""
                INSERT INTO comments(sighting_id, user_id, body, media_url, created_at) 
                VALUES ($1, $2, $3, $4, $5) 
                RETURNING id
            """, uuid.UUID(sighting_id), user_info['user_id'], "I saw it too! ✅", None, now)
            
            # Get all followers of this sighting (excluding the commenter)
            follower_rows = await conn.fetch("""
                SELECT user_id FROM follows 
                WHERE sighting_id = $1 AND user_id != $2
            """, uuid.UUID(sighting_id), user_info['user_id'])
            
            # Send notifications using unified system
            print(f"DEBUG: Confirmation comment - user_info={user_info}, follower_rows={follower_rows}")
            if follower_rows:
                try:
                    follower_user_ids = [row["user_id"] for row in follower_rows]
                    print(f"DEBUG: Sending confirmation comment notification to {len(follower_user_ids)} followers")
                    sent = await notify_users(
                        self.db_pool,
                        follower_user_ids,
                        title=f"💬 {user_info['username']} commented",
                        body="I saw it too! ✅",
                        data={
                            "type": "comment",
                            "comment_id": str(comment_row["id"]),
                            "sighting_id": sighting_id,
                        },
                    )
                    print(f"DEBUG: Confirmation comment notify_users returned {sent}")
                except Exception as e:
                    print(f"DEBUG: Exception in confirmation comment notify_users: {e}")
            else:
                print("DEBUG: No followers found for confirmation comment notification")
                
            print(f"✅ Added confirmation comment {comment_row['id']} for user {user_info['username']} directly")
            
        except Exception as e:
            print(f"❌ Failed to add confirmation comment: {e}")
            # Don't fail the confirmation if comment fails
    
