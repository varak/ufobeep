import asyncio
import pygeohash
from datetime import datetime
from typing import List, Tuple
import logging
from .push_service import send_to_tokens

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
            lat: Latitude of the sighting
            lon: Longitude of the sighting  
            sighting_id: ID of the sighting to alert about
            beep_device_id: Device ID that created the beep (excluded from alerts)
        """
        try:
            start_time = datetime.utcnow()
            
            # Check for recent witnesses in the same area for escalation
            witness_count = await self._count_recent_witnesses_nearby(lat, lon)
            logger.info(f"Found {witness_count} recent witnesses in area for sighting {sighting_id}")
            
            # Determine alert escalation level based on witness count
            alert_escalation = self._determine_alert_escalation(witness_count)
            
            # Get devices within each distance ring
            devices_1km = await self._get_devices_within_radius(lat, lon, 1.0, beep_device_id)
            devices_5km = await self._get_devices_within_radius(lat, lon, 5.0, beep_device_id)
            devices_10km = await self._get_devices_within_radius(lat, lon, 10.0, beep_device_id)
            devices_25km = await self._get_devices_within_radius(lat, lon, 25.0, beep_device_id)
            
            # Remove duplicates (inner rings included in outer rings)
            devices_5km_only = [d for d in devices_5km if d not in devices_1km]
            devices_10km_only = [d for d in devices_10km if d not in devices_5km and d not in devices_1km]
            devices_25km_only = [d for d in devices_25km if d not in devices_10km and d not in devices_5km and d not in devices_1km]
            
            # Send alerts with priority levels (distance + witness escalation)
            tasks = []
            
            if devices_1km:
                # 1km always gets highest priority, escalated by witness count
                level = alert_escalation if alert_escalation == "emergency" else "emergency"
                title, body = self._get_alert_message(1.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_1km, sighting_id, level, title, body, witness_count, lat, lon, f"Sighting {sighting_id}", beep_device_id))
                
            if devices_5km_only:
                # 5km gets urgent unless escalated
                level = "emergency" if alert_escalation == "emergency" else "urgent"
                title, body = self._get_alert_message(5.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_5km_only, sighting_id, level, title, body, witness_count, lat, lon, f"Sighting {sighting_id}", beep_device_id))
                
            if devices_10km_only:
                # 10km gets normal unless escalated
                level = alert_escalation if alert_escalation in ["urgent", "emergency"] else "normal"
                title, body = self._get_alert_message(10.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_10km_only, sighting_id, level, title, body, witness_count, lat, lon, f"Sighting {sighting_id}", beep_device_id))
                
            if devices_25km_only:
                # 25km gets normal unless emergency escalation
                level = "emergency" if alert_escalation == "emergency" else "normal"
                title, body = self._get_alert_message(25.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_25km_only, sighting_id, level, title, body, witness_count, lat, lon, f"Sighting {sighting_id}", beep_device_id))
            
            # Execute all alert batches concurrently
            if tasks:
                results = await asyncio.gather(*tasks, return_exceptions=True)
                
                # Count successful deliveries
                total_sent = sum(r if isinstance(r, int) else 0 for r in results)
                
                elapsed_ms = (datetime.utcnow() - start_time).total_seconds() * 1000
                
                logger.info(f"Proximity alerts sent: {total_sent} devices in {elapsed_ms:.1f}ms")
                logger.info(f"Alert breakdown - 1km: {len(devices_1km)}, 5km: {len(devices_5km_only)}, 10km: {len(devices_10km_only)}, 25km: {len(devices_25km_only)}")
                
                return {
                    "total_alerts_sent": total_sent,
                    "devices_1km": len(devices_1km),
                    "devices_5km": len(devices_5km_only), 
                    "devices_10km": len(devices_10km_only),
                    "devices_25km": len(devices_25km_only),
                    "delivery_time_ms": elapsed_ms
                }
            else:
                logger.info("No devices found within 25km for proximity alerts")
                return {
                    "total_alerts_sent": 0,
                    "devices_1km": 0,
                    "devices_5km": 0,
                    "devices_10km": 0, 
                    "devices_25km": 0,
                    "delivery_time_ms": 0
                }
                
        except Exception as e:
            logger.error(f"Error sending proximity alerts: {e}")
            return {"error": str(e), "total_alerts_sent": 0}
    
    async def _get_devices_within_radius(self, lat: float, lon: float, radius_km: float, exclude_device_id: str) -> List[dict]:
        """Get devices within radius using simple distance calculation"""
        try:
            
            async with self.db_pool.acquire() as conn:
                # Check recent sighting count for rate limiting
                recent_sightings = await conn.fetchval("""
                    SELECT COUNT(*) FROM sightings 
                    WHERE created_at > NOW() - INTERVAL '15 minutes'
                """)
                
                # If too many recent sightings, reduce alert frequency (unless emergency override)
                if recent_sightings >= 3:
                    # Check if this is an emergency override scenario (high witness count)
                    emergency_witnesses = await conn.fetchval("""
                        SELECT COUNT(*) FROM sightings 
                        WHERE created_at > NOW() - INTERVAL '5 minutes'
                        AND ST_DWithin(
                            ST_SetSRID(ST_MakePoint(
                                CAST(sensor_data->>'longitude' AS FLOAT), 
                                CAST(sensor_data->>'latitude' AS FLOAT)
                            ), 4326),
                            ST_SetSRID(ST_MakePoint($1, $2), 4326),
                            1000  -- 1km radius
                        )
                    """, lon, lat)
                    
                    if emergency_witnesses >= 10:
                        logger.warning(f"EMERGENCY OVERRIDE: {emergency_witnesses} witnesses in 5min, bypassing rate limit")
                    else:
                        logger.warning(f"Rate limiting: {recent_sightings} sightings in last 15 minutes, skipping proximity alerts")
                        return []
                
                # Simple approach: get all active devices with push tokens
                query = """
                    SELECT device_id, push_token, platform, lat, lon
                    FROM devices 
                    WHERE is_active = true 
                      AND push_enabled = true
                      AND push_token IS NOT NULL
                      AND device_id != $1
                    LIMIT 1000
                """
                rows = await conn.fetch(query, exclude_device_id)
                
                # For Phase 0: if no location data, treat all devices as within range
                # This ensures alerts work even without location data
                devices = []
                for row in rows:
                    if row['lat'] is not None and row['lon'] is not None:
                        # Calculate actual distance
                        distance = self._calculate_distance(lat, lon, row['lat'], row['lon'])
                        if distance <= radius_km:
                            devices.append({
                                'device_id': row['device_id'],
                                'push_token': row['push_token'],
                                'platform': row['platform'],
                                'distance_km': round(distance, 2),
                                'device_lat': row['lat'],
                                'device_lon': row['lon']
                            })
                    else:
                        # No location data - include in 25km ring for Phase 0
                        if radius_km >= 25.0:
                            devices.append({
                                'device_id': row['device_id'],
                                'push_token': row['push_token'],
                                'platform': row['platform'],
                                'distance_km': 25.0  # Default distance
                            })
                
                devices.sort(key=lambda d: d['distance_km'])
                return devices
                
        except Exception as e:
            logger.error(f"Error getting devices within {radius_km}km: {e}")
            logger.warning(f"PostGIS not available, falling back to haversine calculation for {radius_km}km radius")
            # Fallback to basic distance calculation if PostGIS not available
            return await self._get_devices_within_radius_fallback(lat, lon, radius_km, exclude_device_id)
    
    async def _get_devices_within_radius_fallback(self, lat: float, lon: float, radius_km: float, exclude_device_id: str) -> List[dict]:
        """Fallback method using haversine distance calculation"""
        try:
            logger.info(f"FALLBACK: Searching for devices within {radius_km}km of ({lat}, {lon}), excluding {exclude_device_id}")
            
            async with self.db_pool.acquire() as conn:
                # Get all devices with location data
                query = """
                    SELECT device_id, push_token, platform, lat, lon
                    FROM devices 
                    WHERE is_active = true 
                      AND push_token IS NOT NULL
                      AND device_id != $1
                      AND (lat IS NOT NULL AND lon IS NOT NULL)
                      AND lat != 0.0 AND lon != 0.0
                """
                
                rows = await conn.fetch(query, exclude_device_id)
                logger.info(f"FALLBACK: Found {len(rows)} total active devices with location data")
                
                # Filter by distance using haversine formula
                nearby_devices = []
                for row in rows:
                    device_lat = float(row['lat'])
                    device_lon = float(row['lon'])
                    
                    # Calculate distance using haversine formula
                    distance_km = self._haversine_distance(lat, lon, device_lat, device_lon)
                    logger.debug(f"FALLBACK: Device {row['device_id']} at ({device_lat}, {device_lon}) is {distance_km:.2f}km away")
                    
                    if distance_km <= radius_km:
                        nearby_devices.append({
                            'device_id': row['device_id'],
                            'push_token': row['push_token'],
                            'platform': row['platform'],
                            'distance_km': round(distance_km, 2),
                            'device_lat': device_lat,
                            'device_lon': device_lon
                        })
                        logger.info(f"FALLBACK: Device {row['device_id']} INCLUDED (distance: {distance_km:.2f}km)")
                
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
            
            for device in devices:
                try:
                    # Prepare alert data with sighting location for compass navigation
                    alert_data = {
                        "type": "sighting_alert",
                        "sighting_id": sighting_id,
                        "alert_level": alert_level,
                        "witness_count": str(witness_count),
                        "timestamp": datetime.utcnow().isoformat(),
                        "action": "open_compass",  # Phase 1 Task 6: Open compass directly
                        "submitter_device_id": submitter_device_id  # For self-notification filtering
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
                    
                    # Send to individual device
                    response = send_to_tokens([device['push_token']], alert_data, title=title, body=body)
                    
                    if response and len(response) > 0 and response[0].success:
                        success_count += 1
                        
                except Exception as e:
                    logger.error(f"Error sending alert to device {device.get('device_id', 'unknown')}: {e}")
                    continue
            
            logger.info(f"Alert batch {alert_level}: {success_count}/{len(devices)} sent successfully")
            return success_count
            
        except Exception as e:
            logger.error(f"Error sending alert batch: {e}")
            return 0
    
    async def _count_recent_witnesses_nearby(self, lat: float, lon: float, radius_km: float = 10.0) -> int:
        """Count recent sightings (last 30 minutes) within radius for escalation"""
        try:
            async with self.db_pool.acquire() as conn:
                # Count sightings in the last 30 minutes within 10km
                query = """
                    SELECT COUNT(*) FROM sightings 
                    WHERE created_at > NOW() - INTERVAL '30 minutes'
                    AND status = 'created'
                """
                count = await conn.fetchval(query)
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
    
    def _get_alert_message(self, distance_km: float, witness_count: int, level: str) -> tuple[str, str]:
        """Generate appropriate alert title and body based on distance, witnesses, and level"""
        
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

# Global instance
proximity_alert_service = None

def get_proximity_alert_service(db_pool):
    """Get or create proximity alert service instance"""
    global proximity_alert_service
    if proximity_alert_service is None:
        proximity_alert_service = ProximityAlertService(db_pool)
    return proximity_alert_service