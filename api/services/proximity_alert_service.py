import asyncio
import pygeohash
from datetime import datetime
from typing import List, Tuple
import logging
from app.services.push_service import send_to_token

from app.routers.admin import rate_limit_enabled, rate_limit_threshold
from app.utils.dnd_utils import is_in_quiet_window, is_dnd_active, should_override_quiet_hours

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
            
            # Get devices within each distance ring using device coordinates (expanded for weather visibility)
            devices_5km = await self._get_devices_within_radius(device_lat, device_lon, 5.0, beep_device_id, witness_count)
            devices_15km = await self._get_devices_within_radius(device_lat, device_lon, 15.0, beep_device_id, witness_count)
            devices_40km = await self._get_devices_within_radius(device_lat, device_lon, 40.0, beep_device_id, witness_count)
            devices_100km = await self._get_devices_within_radius(device_lat, device_lon, 100.0, beep_device_id, witness_count)
            
            # Remove duplicates (inner rings included in outer rings)
            devices_15km_only = [d for d in devices_15km if d not in devices_5km]
            devices_40km_only = [d for d in devices_40km if d not in devices_15km and d not in devices_5km]
            devices_100km_only = [d for d in devices_100km if d not in devices_40km and d not in devices_15km and d not in devices_5km]
            
            # Send alerts with priority levels (distance + witness escalation)
            tasks = []
            
            if devices_5km:
                # 5km: Close range - highest priority, escalated by witness count
                level = alert_escalation if alert_escalation == "emergency" else "emergency"
                title, body = self._get_alert_message(5.0, witness_count, level)  # Default English for batch
                tasks.append(self._send_alert_batch(devices_5km, sighting_id, level, title, body, witness_count, device_lat, device_lon, "UFO Sighting", beep_device_id))
                
            if devices_15km_only:
                # 15km: Local visibility - urgent unless escalated
                level = "emergency" if alert_escalation == "emergency" else "urgent"
                title, body = self._get_alert_message(15.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_15km_only, sighting_id, level, title, body, witness_count, device_lat, device_lon, "UFO Sighting", beep_device_id))
                
            if devices_40km_only:
                # 40km: Regional visibility - normal unless escalated
                level = alert_escalation if alert_escalation in ["urgent", "emergency"] else "normal"
                title, body = self._get_alert_message(40.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_40km_only, sighting_id, level, title, body, witness_count, device_lat, device_lon, "UFO Sighting", beep_device_id))
                
            if devices_100km_only:
                # 100km: Horizon visibility - normal unless emergency escalation
                level = "emergency" if alert_escalation == "emergency" else "normal"
                title, body = self._get_alert_message(100.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_100km_only, sighting_id, level, title, body, witness_count, device_lat, device_lon, "UFO Sighting", beep_device_id))
            
            # Execute all alert batches concurrently
            if tasks:
                results = await asyncio.gather(*tasks, return_exceptions=True)
                
                # Count successful deliveries
                total_sent = sum(r if isinstance(r, int) else 0 for r in results)
                
                elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
                
                logger.info(f"Proximity alerts sent: {total_sent} devices in {elapsed_ms:.1f}ms")
                logger.info(f"Alert breakdown - 5km: {len(devices_5km)}, 15km: {len(devices_15km_only)}, 40km: {len(devices_40km_only)}, 100km: {len(devices_100km_only)}")
                
                return {
                    "total_alerts_sent": total_sent,
                    "devices_5km": len(devices_5km),
                    "devices_15km": len(devices_15km_only), 
                    "devices_40km": len(devices_40km_only),
                    "devices_100km": len(devices_100km_only),
                    "delivery_time_ms": elapsed_ms
                }
            else:
                logger.info("No devices found within 100km for proximity alerts")
                return {
                    "total_alerts_sent": 0,
                    "devices_5km": 0,
                    "devices_15km": 0,
                    "devices_40km": 0, 
                    "devices_100km": 0,
                    "delivery_time_ms": 0
                }
                
        except Exception as e:
            logger.error(f"Error sending proximity alerts: {e}")
            return {"error": str(e), "total_alerts_sent": 0}
    
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
                
                # Get devices with user preferences for DND, quiet hours, and alert range
                query = """
                    SELECT DISTINCT ON (device_id)
                        device_id, push_token, platform, lat, lon,
                        alert_range_km, preferences, snooze_until
                    FROM devices
                    WHERE is_active = true
                      AND push_enabled = true
                      AND push_token IS NOT NULL
                      AND device_id != $1
                      AND (last_seen IS NULL OR last_seen > NOW() - INTERVAL '24 hours')
                      AND (snooze_until IS NULL OR snooze_until <= NOW())
                    ORDER BY device_id, updated_at DESC
                    LIMIT 1000
                """
                rows = await conn.fetch(query, exclude_device_id)
                
                # Filter devices based on user preferences and proximity
                devices = []
                current_time = datetime.utcnow()
                
                for row in rows:
                    # Parse user preferences
                    user_alert_range = row['alert_range_km'] or 10.0  # Default 10km if not set
                    preferences = row['preferences'] or {}
                    dnd_settings = preferences.get('dnd', {}) if isinstance(preferences, dict) else {}
                    
                    # Check quiet hours with emergency override
                    in_quiet_hours = False
                    if dnd_settings.get('enabled'):
                        quiet_start = dnd_settings.get('start')  # e.g. "22:00"
                        quiet_end = dnd_settings.get('end')      # e.g. "07:00"
                        device_timezone = preferences.get('timezone')
                        
                        in_quiet_hours = is_in_quiet_window(
                            current_time, quiet_start, quiet_end, device_timezone
                        )
                        
                        # Check emergency override
                        if in_quiet_hours and should_override_quiet_hours(witness_count):
                            in_quiet_hours = False  # Override quiet hours for high-witness events
                            logger.info(f"Emergency override: {witness_count} witnesses bypasses quiet hours for device {row['device_id']}")
                    
                    # Skip if in quiet hours (unless overridden)
                    if in_quiet_hours:
                        logger.debug(f"Skipping device {row['device_id']} due to quiet hours")
                        continue
                    
                    # Check distance against user's preferred range
                    if row['lat'] is not None and row['lon'] is not None:
                        # Calculate actual distance
                        distance = self._calculate_distance(lat, lon, row['lat'], row['lon'])
                        
                        # Respect user's alert range preference instead of hardcoded radius_km
                        if distance <= user_alert_range:
                            devices.append({
                                'device_id': row['device_id'],
                                'push_token': row['push_token'],
                                'platform': row['platform'],
                                'distance_km': round(distance, 2),
                                'device_lat': row['lat'],
                                'device_lon': row['lon'],
                                'user_alert_range': user_alert_range,
                                'quiet_hours_bypassed': in_quiet_hours == False and dnd_settings.get('enabled')
                            })
                    else:
                        # No location data - include only if user's range >= 25km (fallback for no-location devices)
                        if user_alert_range >= 25.0:
                            devices.append({
                                'device_id': row['device_id'],
                                'push_token': row['push_token'],
                                'platform': row['platform'],
                                'distance_km': 25.0,  # Default distance for no-location devices
                                'user_alert_range': user_alert_range
                            })
                
                devices.sort(key=lambda d: d['distance_km'])
                return devices
                
        except Exception as e:
            logger.error(f"Error getting devices within {radius_km}km: {e}")
            logger.warning(f"PostGIS not available, falling back to haversine calculation for {radius_km}km radius")
            # Fallback to basic distance calculation if PostGIS not available
            return await self._get_devices_within_radius_fallback(lat, lon, radius_km, exclude_device_id, witness_count)
    
    async def _get_devices_within_radius_fallback(self, lat: float, lon: float, radius_km: float, exclude_device_id: str, witness_count: int = 1) -> List[dict]:
        """Fallback method using haversine distance calculation"""
        try:
            logger.info(f"FALLBACK: Searching for devices within {radius_km}km of ({lat}, {lon}), excluding {exclude_device_id}")
            
            async with self.db_pool.acquire() as conn:
                # Get all devices with location data AND recent activity (24h freshness)  
                query = """
                    SELECT
                        device_id, push_token, platform, lat, lon,
                        alert_range_km, preferences, snooze_until
                    FROM devices
                    WHERE is_active = true
                      AND push_token IS NOT NULL
                      AND device_id != $1
                      AND (lat IS NOT NULL AND lon IS NOT NULL)
                      AND lat != 0.0 AND lon != 0.0
                      AND (last_seen IS NULL OR last_seen > NOW() - INTERVAL '24 hours')
                      AND (snooze_until IS NULL OR snooze_until <= NOW())
                """
                
                rows = await conn.fetch(query, exclude_device_id)
                logger.info(f"FALLBACK: Found {len(rows)} total active devices with location data")
                
                # Filter by user preferences and distance
                nearby_devices = []
                current_time = datetime.utcnow()
                
                for row in rows:
                    # Parse user preferences
                    user_alert_range = row['alert_range_km'] or 10.0  # Default 10km if not set
                    preferences = row['preferences'] or {}
                    dnd_settings = preferences.get('dnd', {}) if isinstance(preferences, dict) else {}
                    
                    # Check quiet hours with emergency override
                    in_quiet_hours = False
                    if dnd_settings.get('enabled'):
                        quiet_start = dnd_settings.get('start')  # e.g. "22:00"
                        quiet_end = dnd_settings.get('end')      # e.g. "07:00"
                        device_timezone = preferences.get('timezone')
                        
                        in_quiet_hours = is_in_quiet_window(
                            current_time, quiet_start, quiet_end, device_timezone
                        )
                        
                        # Check emergency override
                        if in_quiet_hours and should_override_quiet_hours(witness_count):
                            in_quiet_hours = False  # Override quiet hours for high-witness events
                            logger.info(f"FALLBACK Emergency override: {witness_count} witnesses bypasses quiet hours for device {row['device_id']}")
                    
                    # Skip if in quiet hours (unless overridden)
                    if in_quiet_hours:
                        logger.debug(f"FALLBACK: Skipping device {row['device_id']} due to quiet hours")
                        continue
                    
                    device_lat = float(row['lat'])
                    device_lon = float(row['lon'])
                    
                    # Calculate distance using haversine formula
                    distance_km = self._haversine_distance(lat, lon, device_lat, device_lon)
                    logger.debug(f"FALLBACK: Device {row['device_id']} at ({device_lat}, {device_lon}) is {distance_km:.2f}km away")
                    
                    # Respect user's alert range preference instead of hardcoded radius_km
                    if distance_km <= user_alert_range:
                        nearby_devices.append({
                            'device_id': row['device_id'],
                            'push_token': row['push_token'],
                            'platform': row['platform'],
                            'distance_km': round(distance_km, 2),
                            'device_lat': device_lat,
                            'device_lon': device_lon,
                            'user_alert_range': user_alert_range
                        })
                        logger.info(f"FALLBACK: Device {row['device_id']} INCLUDED (distance: {distance_km:.2f}km, user range: {user_alert_range}km)")
                
                logger.warning(f"FALLBACK RESULT: Found {len(nearby_devices)} devices within {radius_km}km")
                return nearby_devices
                
        except Exception as e:
            logger.error(f"Error in fallback device radius query: {e}")
            return []
    
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
            
            logger.info(f"TEMP DEBUG: Sending to {len(devices)} devices with old approach")
            
            for device in devices:
                try:
                    # Skip self-notification
                    if device['device_id'] == submitter_device_id:
                        logger.info(f"TEMP DEBUG: Skipping self-notification for device {device['device_id']}")
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
                    
                    # Debug what preferences are actually available
                    device_prefs = device.get('preferences', {})
                    print(f"🔍 DEVICE {device['device_id']}: prefs = {device_prefs}")

                    user_language = device_prefs.get('language', 'en')
                    print(f"🔍 DEVICE {device['device_id']}: detected language = {user_language}")

                    device_title, device_body = self._get_alert_message(5.0, witness_count, alert_level, user_language)
                    print(f"🔍 DEVICE {device['device_id']}: sending {device_title}")

                    # Send to individual device using Firebase service
                    response = await send_to_token(device['push_token'], alert_data, title=device_title, body=device_body)
                    
                    if response:
                        success_count += 1
                        logger.info(f"TEMP DEBUG: Successfully sent to device {device['device_id']}")
                    else:
                        logger.warning(f"TEMP DEBUG: Failed to send to device {device['device_id']}")
                        
                except Exception as e:
                    logger.error(f"Error sending alert to device {device.get('device_id', 'unknown')}: {e}")
                    continue
            
            logger.info(f"Alert batch {alert_level}: {success_count}/{len(devices)} sent successfully via old approach")
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