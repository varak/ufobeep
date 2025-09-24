import asyncio
import pygeohash
from datetime import datetime
from typing import List, Tuple
import logging
from app.services.push_service import send_to_token

from app.routers.admin import rate_limit_enabled, rate_limit_threshold
# DND/snooze now handled by database dnd_until column check in spatial query

logger = logging.getLogger(__name__)

class ProximityAlertService:
    """
    Phase 0 Proximity Alert System - Instant geohash-based fanout
    
    Delivers push notifications to devices within radius rings:
    - 1km: IMMEDIATE priority (emergency level)
    - 5km: HIGH priority (urgent level) 
    - 10km: MEDIUM priority (normal level)
    - 25km: LOW priority (normal level)
    
    Uses 7-character geohash for fast proximity lookup.
    """
    
    def __init__(self, db_pool):
        self.db_pool = db_pool
        
    async def send_proximity_alerts(self, lat: float, lon: float, sighting_id: str, beep_device_id: str):
        """
        Send proximity alerts to nearby devices based on distance rings and witness escalation
        
        Args:
            lat: Latitude of the sighting (from sensor_data - used for logging only)
            lon: Longitude of the sighting (from sensor_data - used for logging only)
            sighting_id: ID of the sighting to alert about
            beep_device_id: Device ID that created the beep (excluded from alerts)
        """
        try:
            start_time = datetime.utcnow()
            
            # Get device coordinates for consistent proximity calculations
            # This fixes the 12.1km coordinate mismatch issue
            device_coords = await self._get_device_coordinates(beep_device_id)
            if not device_coords:
                logger.warning(f"No device coordinates found for {beep_device_id}, using sensor_data coordinates")
                device_lat, device_lon = lat, lon
            else:
                device_lat, device_lon = device_coords['lat'], device_coords['lon']
                logger.info(f"Using device coordinates ({device_lat:.6f}, {device_lon:.6f}) instead of sensor_data coordinates ({lat:.6f}, {lon:.6f})")
            
            # Start with 1 witness (the original reporter who just submitted this sighting)
            # Then add any additional witness confirmations from the area
            additional_witnesses = await self._count_recent_witnesses_nearby(device_lat, device_lon)
            witness_count = 1 + additional_witnesses  # Original reporter + confirmations
            logger.info(f"Total witnesses for sighting {sighting_id}: {witness_count} (1 original + {additional_witnesses} confirmations)")
            
            # Determine alert escalation level based on witness count
            alert_escalation = self._determine_alert_escalation(witness_count)
            
            # Get all devices within their individual alert ranges (single efficient query)
            all_devices = await self._get_devices_within_custom_ranges(device_lat, device_lon, beep_device_id, witness_count)
            
            # Send alerts to all devices within their custom ranges
            if all_devices:
                # Determine priority based on distance and escalation
                for device in all_devices:
                    distance = device['distance_km']
                    if distance <= 5:
                        device['priority'] = "emergency"
                    elif distance <= 15:
                        device['priority'] = "emergency" if alert_escalation == "emergency" else "urgent"
                    else:
                        device['priority'] = alert_escalation if alert_escalation in ["urgent", "emergency"] else "normal"

                # Send all alerts in one batch (more efficient than multiple batches)
                title, body = self._get_alert_message(0, witness_count, alert_escalation)
                total_sent = await self._send_alert_batch(all_devices, sighting_id, alert_escalation, title, body, witness_count, device_lat, device_lon, "UFO Sighting", beep_device_id)

                elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000

                logger.info(f"Proximity alerts sent: {total_sent} devices in {elapsed_ms:.1f}ms")
                logger.info(f"Device breakdown - Total: {len(all_devices)} devices within custom ranges")

                return {
                    "total_alerts_sent": total_sent,
                    "total_devices": len(all_devices),
                    "delivery_time_ms": elapsed_ms
                }
            else:
                logger.info("No devices found within custom alert ranges")
                return {
                    "total_alerts_sent": 0,
                    "total_devices": 0,
                    "delivery_time_ms": 0
                }
                
        except Exception as e:
            logger.error(f"Error sending proximity alerts: {e}")
            return {"error": str(e), "total_alerts_sent": 0}
    
    async def _get_devices_within_custom_ranges(self, lat: float, lon: float, exclude_device_id: str, witness_count: int = 1) -> List[dict]:
        """Get all devices within their individual alert ranges - single efficient query"""
        try:
            async with self.db_pool.acquire() as conn:
                # Check if rate limiting is enabled via admin panel
                if rate_limit_enabled:
                    # Check recent sighting count for rate limiting
                    recent_sightings = await conn.fetchval("""
                        SELECT COUNT(*) FROM sightings
                        WHERE created_at > NOW() - INTERVAL '15 minutes'
                    """)

                    # If too many recent sightings, reduce alert frequency (unless emergency override)
                    if recent_sightings >= rate_limit_threshold:
                        # Check if this is an emergency override scenario (high witness count)
                        emergency_witnesses = await conn.fetchval("""
                            SELECT COUNT(*) FROM sightings
                            WHERE created_at > NOW() - INTERVAL '5 minutes'
                            AND ST_DWithin(
                                location,
                                ST_Point($2, $1)::geography,
                                15000
                            )
                        """, lat, lon)

                        if emergency_witnesses < 3:
                            logger.info(f"Rate limiting: {recent_sightings} sightings in 15min (threshold: {rate_limit_threshold}), emergency witnesses: {emergency_witnesses}")
                            return []
                        else:
                            logger.info(f"Emergency override: {emergency_witnesses} witnesses in 5min, bypassing rate limit")
                else:
                    logger.info("Rate limiting disabled - sending proximity alerts regardless of frequency")

                # SINGLE EFFICIENT QUERY: Get all active devices within their custom ranges
                query = """
                    SELECT device_id, push_token, platform, lat, lon,
                           alert_range_km, preferences, snooze_until, dnd_until,
                           ST_Distance(location, ST_Point($2, $1)::geography) / 1000.0 as distance_km
                    FROM devices
                    WHERE is_active = true
                      AND push_enabled = true
                      AND push_token IS NOT NULL
                      AND device_id != $3
                      AND location IS NOT NULL
                      AND (last_seen IS NULL OR last_seen > NOW() - INTERVAL '24 hours')
                      AND (snooze_until IS NULL OR snooze_until <= NOW())
                      AND (dnd_until IS NULL OR dnd_until <= NOW())
                      AND ST_DWithin(location, ST_Point($2, $1)::geography, 200000)
                      AND ST_Distance(location, ST_Point($2, $1)::geography) / 1000.0 <= COALESCE(alert_range_km, 30.0)
                    ORDER BY distance_km
                """
                rows = await conn.fetch(query, lat, lon, exclude_device_id)

                # Convert to device list with all needed info
                devices = []
                for row in rows:
                    devices.append({
                        'device_id': row['device_id'],
                        'push_token': row['push_token'],
                        'platform': row['platform'],
                        'distance_km': round(float(row['distance_km']), 2),
                        'device_lat': row['lat'],
                        'device_lon': row['lon'],
                        'user_alert_range': row['alert_range_km'] or 30.0,
                        'preferences': row['preferences']
                    })
                    logger.debug(f"PROXIMITY: Device {row['device_id']} included (distance: {row['distance_km']:.2f}km, range: {row['alert_range_km']}km)")

                logger.info(f"Found {len(devices)} devices within custom alert ranges")
                return devices

        except Exception as e:
            logger.error(f"Error getting devices within custom ranges: {e}")
            return []

    async def _get_devices_within_radius(self, lat: float, lon: float, radius_km: float, exclude_device_id: str, witness_count: int = 1) -> List[dict]:
        """Get devices within radius using simple distance calculation"""
        try:
            
            async with self.db_pool.acquire() as conn:
                # Check if rate limiting is enabled via admin panel
                if rate_limit_enabled:
                    # Check recent sighting count for rate limiting
                    recent_sightings = await conn.fetchval("""
                        SELECT COUNT(*) FROM sightings 
                        WHERE created_at > NOW() - INTERVAL '15 minutes'
                    """)
                    
                    # If too many recent sightings, reduce alert frequency (unless emergency override)
                    if recent_sightings >= rate_limit_threshold:
                        # Check if this is an emergency override scenario (high witness count)
                        # Use the same coordinate system as proximity calculations
                        emergency_witnesses = await conn.fetchval("""
                            SELECT COUNT(*) FROM sightings 
                            WHERE created_at > NOW() - INTERVAL '5 minutes'
                            AND ST_DWithin(
                                ST_SetSRID(ST_MakePoint(
                                    CAST(sensor_data->>'longitude' AS FLOAT), 
                                    CAST(sensor_data->>'latitude' AS FLOAT)
                                ), 4326),
                                ST_SetSRID(ST_MakePoint($1, $2), 4326),
                                5000  -- 5km radius (expanded from 1km)
                            )
                        """, lon, lat)
                        
                        if emergency_witnesses >= 10:
                            logger.warning(f"EMERGENCY OVERRIDE: {emergency_witnesses} witnesses in 5min, bypassing rate limit")
                        else:
                            logger.warning(f"Rate limiting: {recent_sightings} sightings in last 15 minutes, skipping proximity alerts")
                            return []
                else:
                    logger.info("Rate limiting disabled - sending proximity alerts regardless of frequency")
                
                # SPATIAL QUERY: Get devices within 200km using PostGIS spatial index
                # Includes SQL-level DND and quiet hours checking for optimal scaling
                query = """
                    SELECT DISTINCT ON (device_id)
                        device_id, push_token, platform, lat, lon,
                        alert_range_km, preferences, snooze_until, dnd_until,
                        ST_Distance(location, ST_Point($2, $1)::geography) / 1000.0 as distance_km
                    FROM devices
                    WHERE is_active = true
                      AND push_enabled = true
                      AND push_token IS NOT NULL
                      AND device_id != $3
                      AND location IS NOT NULL
                      AND (last_seen IS NULL OR last_seen > NOW() - INTERVAL '24 hours')
                      AND (snooze_until IS NULL OR snooze_until <= NOW())
                      AND (dnd_until IS NULL OR dnd_until <= NOW())
                      AND ST_DWithin(location, ST_Point($2, $1)::geography, 200000)
                    ORDER BY device_id, (push_token IS NOT NULL) DESC, updated_at DESC, distance_km
                """
                rows = await conn.fetch(query, lat, lon, exclude_device_id)
                
                # Filter devices based on user preferences and proximity
                devices = []
                current_time = datetime.utcnow()
                
                for row in rows:
                    # Parse user preferences
                    user_alert_range = row['alert_range_km'] or 30.0  # Visible default: 30km

                    # DND/snooze is now handled by database query (dnd_until column)
                    # No need for complex preferences.dnd logic
                    
                    # Use database-calculated distance (no Python calculations needed)
                    distance_km = float(row['distance_km'])

                    # Respect user's alert range preference
                    if distance_km <= user_alert_range:
                        devices.append({
                            'device_id': row['device_id'],
                            'push_token': row['push_token'],
                            'platform': row['platform'],
                            'distance_km': round(distance_km, 2),
                            'device_lat': row['lat'],
                            'device_lon': row['lon'],
                            'user_alert_range': user_alert_range,
                            'preferences': row['preferences']
                        })
                        logger.debug(f"SPATIAL: Device {row['device_id']} INCLUDED (distance: {distance_km:.2f}km, user range: {user_alert_range}km)")
                    else:
                        # No location data - include only if user's range >= 25km (fallback for no-location devices)
                        if user_alert_range >= 25.0:
                            devices.append({
                                'device_id': row['device_id'],
                                'push_token': row['push_token'],
                                'platform': row['platform'],
                                'distance_km': 25.0,  # Default distance for no-location devices
                                'user_alert_range': user_alert_range,
                                'preferences': row['preferences']
                            })
                
                devices.sort(key=lambda d: d['distance_km'])
                return devices
                
        except Exception as e:
            logger.error(f"Error getting devices within {radius_km}km: {e}")
            # No fallback - fail properly so we can debug PostGIS issues
            raise e
    
    # Removed fallback method - PostGIS should work or fail properly
    
    def _haversine_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate the great circle distance between two points on earth in kilometers"""
        import math
        
        # Convert latitude and longitude from degrees to radians
        lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
        
        # Haversine formula
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        # Radius of earth in kilometers
        r = 6371.0
        
        return c * r
    
    def _calculate_bearing(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate the bearing from point 1 to point 2 in degrees (0-360)"""
        import math
        
        # Convert latitude and longitude from degrees to radians
        lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
        
        # Calculate bearing
        dlon = lon2 - lon1
        y = math.sin(dlon) * math.cos(lat2)
        x = math.cos(lat1) * math.sin(lat2) - math.sin(lat1) * math.cos(lat2) * math.cos(dlon)
        
        # Convert to degrees and normalize to 0-360
        bearing = math.atan2(y, x)
        bearing = math.degrees(bearing)
        bearing = (bearing + 360) % 360
        
        return bearing
    
    def _calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using haversine formula (alias for consistency)"""
        return self._haversine_distance(lat1, lon1, lat2, lon2)
    
    async def _send_alert_batch(self, devices: List[dict], sighting_id: str, alert_level: str, title: str, body: str, witness_count: int = 1, sighting_lat: float = None, sighting_lon: float = None, location_name: str = None, submitter_device_id: str = None) -> int:
        """Send alerts to a batch of devices with individualized bearing calculations"""
        if not devices:
            return 0
            
        try:
            # Send individualized alerts with device-specific bearing and distance
            success_count = 0
            
            for device in devices:
                try:
                    # Skip self-notification
                    if device['device_id'] == submitter_device_id:
                        logger.debug(f"Skipping self-notification for device {device['device_id']}")
                        continue
                        
                    # Prepare alert data with sighting location for compass navigation
                    alert_data = {
                        "type": "sighting_alert",
                        "sighting_id": sighting_id,
                        "alert_level": alert_level,
                        "witness_count": str(witness_count),
                        "timestamp": datetime.utcnow().isoformat(),
                        "action": "open_compass",  # Phase 1 Task 6: Open compass directly
                        "submitter_device_id": submitter_device_id,  # For self-notification filtering
                        "refresh_alerts": "true"  # Trigger alerts tab refresh in receiving apps
                    }
                    
                    # Add location data for compass navigation if available
                    if sighting_lat is not None and sighting_lon is not None:
                        alert_data.update({
                            "latitude": str(sighting_lat),
                            "longitude": str(sighting_lon),
                            "location_name": location_name or "UFO Sighting"
                        })
                        
                        # Add device-specific distance
                        if 'distance_km' in device:
                            alert_data["distance"] = str(device['distance_km'])
                        
                        # Calculate bearing from device to sighting if we have device location
                        if 'device_lat' in device and 'device_lon' in device and device['device_lat'] is not None and device['device_lon'] is not None:
                            bearing = self._calculate_bearing(
                                device['device_lat'], device['device_lon'],
                                sighting_lat, sighting_lon
                            )
                            alert_data["bearing"] = str(round(bearing, 1))
                    
                    # Get device preferences for language (handle both dict and JSON string)
                    device_prefs = device.get('preferences', {})
                    if isinstance(device_prefs, str):
                        try:
                            import json
                            device_prefs = json.loads(device_prefs)
                        except:
                            device_prefs = {}
                    user_language = device_prefs.get('language', 'en')

                    # Log language detection for debugging
                    logger.info(f"🌍 NOTIFICATION: Device {device['device_id']} - detected language: {user_language} (from prefs: {device_prefs})")

                    device_title, device_body = self._get_alert_message(5.0, witness_count, alert_level, user_language)

                    # Send to individual device using Firebase service
                    response = await send_to_token(device['push_token'], alert_data, title=device_title, body=device_body)
                    
                    if response:
                        success_count += 1
                        logger.debug(f"Successfully sent to device {device['device_id']}")
                    else:
                        logger.warning(f"Failed to send to device {device['device_id']}")
                        
                except Exception as e:
                    logger.error(f"Error sending alert to device {device.get('device_id', 'unknown')}: {e}")
                    continue
            
            logger.info(f"Alert batch {alert_level}: {success_count}/{len(devices)} sent successfully")
            return success_count
            
        except Exception as e:
            logger.error(f"Error sending alert batch: {e}")
            return 0
    
    async def _count_recent_witnesses_nearby(self, lat: float, lon: float, radius_km: float = 10.0) -> int:
        """Count actual witness confirmations (not original sightings) within radius for escalation"""
        try:
            async with self.db_pool.acquire() as conn:
                # Count ONLY witness confirmations, not the original sighting reports
                # This prevents counting the original reporter as multiple witnesses
                query = """
                    SELECT COUNT(DISTINCT wc.device_id) 
                    FROM witness_confirmations wc
                    JOIN sightings s ON wc.sighting_id = s.id
                    WHERE wc.created_at > NOW() - INTERVAL '30 minutes'
                    AND ST_DWithin(
                        s.location::geography,
                        ST_MakePoint($1, $2)::geography,
                        $3 * 1000  -- Convert km to meters
                    )
                """
                count = await conn.fetchval(query, lon, lat, radius_km)
                return count or 0
        except Exception as e:
            logger.error(f"Error counting recent witnesses: {e}")
            return 0
    
    def _determine_alert_escalation(self, witness_count: int) -> str:
        """Determine alert escalation level based on witness count"""
        if witness_count >= 10:
            return "emergency"  # Mass sighting - emergency siren
        elif witness_count >= 3:
            return "urgent"     # Multiple witnesses - urgent warble
        else:
            return "normal"     # Single witness - normal beep
    
    def _get_alert_message(self, distance_km: float, witness_count: int, level: str, user_language: str = "en") -> tuple[str, str]:
        """Generate appropriate alert title and body based on distance, witnesses, and level"""

        # Import translation service
        from app.services.notification_translation_service import get_ufo_alert_title, get_sighting_notification_body

        # Simple approach: just use UFO Alert + notification body in user's language
        title = f"🛸 {get_ufo_alert_title(user_language)}"
        body = get_sighting_notification_body(user_language)

        return title, body

        # OLD HARDCODED ENGLISH CODE BELOW - KEEPING FOR REFERENCE BUT NOT USING
        # Witness description
        if witness_count >= 10:
            witness_desc = f"MASS SIGHTING - {witness_count} witnesses"
        elif witness_count >= 3:
            witness_desc = f"Multiple witnesses ({witness_count})"
        elif witness_count == 2:
            witness_desc = "2nd witness"
        else:
            witness_desc = "New sighting"
        
        # Distance description
        if distance_km <= 1.0:
            location_desc = "VERY CLOSE"
        elif distance_km <= 5.0:
            location_desc = "nearby"
        elif distance_km <= 10.0:
            location_desc = "in your area"
        else:
            location_desc = f"within {int(distance_km)}km"
        
        # Generate title and body based on level
        if level == "emergency":
            if witness_count >= 10:
                title = f"🚨 MASS UFO SIGHTING {location_desc.upper()}"
                body = f"EMERGENCY: {witness_count} witnesses reporting something in the sky {location_desc}!"
            else:
                title = f"🚨 UFO EMERGENCY {location_desc.upper()}"
                body = f"Emergency: Something is happening {location_desc} - {witness_desc.lower()}"
        elif level == "urgent":
            title = f"⚡ UFO Sighting {location_desc.title()}"
            body = f"Urgent: {witness_desc} - Look up now!"
        else:
            title = f"👁 UFO Alert {location_desc.title()}"
            body = f"{witness_desc} - Something reported {location_desc}"
        
        return title, body
    
    async def _get_device_coordinates(self, device_id: str):
        """Get device coordinates from the devices table"""
        try:
            async with self.db_pool.acquire() as conn:
                result = await conn.fetchrow("""
                    SELECT lat, lon FROM devices 
                    WHERE device_id = $1 AND lat IS NOT NULL AND lon IS NOT NULL
                """, device_id)
                if result:
                    return {'lat': result['lat'], 'lon': result['lon']}
                return None
        except Exception as e:
            logger.error(f"Error getting device coordinates for {device_id}: {e}")
            return None
    
    async def _get_user_ids_for_devices(self, device_ids: List[str]) -> List[str]:
        """Get user IDs for a list of device IDs"""
        try:
            async with self.db_pool.acquire() as conn:
                rows = await conn.fetch("""
                    SELECT DISTINCT user_id FROM devices 
                    WHERE device_id = ANY($1::text[]) AND user_id IS NOT NULL
                """, device_ids)
                return [str(row['user_id']) for row in rows]
        except Exception as e:
            logger.error(f"Error getting user IDs for devices: {e}")
            return []

# Global instance
proximity_alert_service = None

def get_proximity_alert_service(db_pool):
    """Get or create proximity alert service instance"""
    global proximity_alert_service
    if proximity_alert_service is None:
        proximity_alert_service = ProximityAlertService(db_pool)
    return proximity_alert_service