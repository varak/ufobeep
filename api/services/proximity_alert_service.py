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
                tasks.append(self._send_alert_batch(devices_1km, sighting_id, level, title, body, witness_count))
                
            if devices_5km_only:
                # 5km gets urgent unless escalated
                level = "emergency" if alert_escalation == "emergency" else "urgent"
                title, body = self._get_alert_message(5.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_5km_only, sighting_id, level, title, body, witness_count))
                
            if devices_10km_only:
                # 10km gets normal unless escalated
                level = alert_escalation if alert_escalation in ["urgent", "emergency"] else "normal"
                title, body = self._get_alert_message(10.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_10km_only, sighting_id, level, title, body, witness_count))
                
            if devices_25km_only:
                # 25km gets normal unless emergency escalation
                level = "emergency" if alert_escalation == "emergency" else "normal"
                title, body = self._get_alert_message(25.0, witness_count, level)
                tasks.append(self._send_alert_batch(devices_25km_only, sighting_id, level, title, body, witness_count))
            
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
                
                # If too many recent sightings, reduce alert frequency
                if recent_sightings >= 3:
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
                                'distance_km': round(distance, 2)
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
            # Fallback to basic distance calculation if PostGIS not available
            return await self._get_devices_within_radius_fallback(lat, lon, radius_km, exclude_device_id)
    
    async def _get_devices_within_radius_fallback(self, lat: float, lon: float, radius_km: float, exclude_device_id: str) -> List[dict]:
        """Fallback method using basic distance calculation"""
        try:
            async with self.db_pool.acquire() as conn:
                # Get all devices with location data
                query = """
                    SELECT device_id, push_token, platform, lat, lon
                    FROM devices 
                    WHERE is_active = true 
                      AND push_token IS NOT NULL
                      AND device_id != $1
                      AND (lat IS NOT NULL AND lon IS NOT NULL)
                """
                
                rows = await conn.fetch(query, exclude_device_id)
                
                devices = []
                for row in rows:
                    distance = self._calculate_distance(lat, lon, row['lat'], row['lon'])
                    if distance <= radius_km:
                        devices.append({
                            'device_id': row['device_id'],
                            'push_token': row['push_token'], 
                            'platform': row['platform'],
                            'distance_km': round(distance, 2)
                        })
                
                # Sort by distance (closest first)
                devices.sort(key=lambda d: d['distance_km'])
                return devices
                
        except Exception as e:
            logger.error(f"Error in fallback device lookup: {e}")
            return []
    
    def _calculate_distance(self, lat1: float, lon1: float, lat2: float, lon2: float) -> float:
        """Calculate distance between two points using Haversine formula"""
        import math
        
        # Convert to radians
        lat1, lon1, lat2, lon2 = map(math.radians, [lat1, lon1, lat2, lon2])
        
        # Haversine formula
        dlat = lat2 - lat1
        dlon = lon2 - lon1
        a = math.sin(dlat/2)**2 + math.cos(lat1) * math.cos(lat2) * math.sin(dlon/2)**2
        c = 2 * math.asin(math.sqrt(a))
        
        # Earth radius in kilometers
        earth_radius_km = 6371.0
        return earth_radius_km * c
    
    async def _send_alert_batch(self, devices: List[dict], sighting_id: str, alert_level: str, title: str, body: str, witness_count: int = 1) -> int:
        """Send alerts to a batch of devices"""
        if not devices:
            return 0
            
        try:
            # Extract tokens for batch sending
            tokens = [device['push_token'] for device in devices]
            
            # Prepare alert data with witness escalation info
            alert_data = {
                "type": "sighting_alert",  # Changed to match mobile handler
                "sighting_id": sighting_id,
                "alert_level": alert_level,
                "witness_count": str(witness_count),  # Mobile expects string
                "timestamp": datetime.utcnow().isoformat(),
                "action": "open_alert"
            }
            
            # Send to all devices in batch
            responses = send_to_tokens(tokens, alert_data, title=title, body=body)
            
            # Count successful sends
            success_count = sum(1 for response in responses if response and response.success)
            
            logger.info(f"Alert batch {alert_level}: {success_count}/{len(tokens)} sent successfully")
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