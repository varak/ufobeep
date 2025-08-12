"""
Alert fanout worker for UFOBeep
Processes new sightings and sends push notifications to nearby users
"""

import asyncio
import logging
import math
from typing import List, Dict, Any, Optional, Tuple
from datetime import datetime, timedelta
from dataclasses import dataclass

try:
    # Try to import the new FCM v1 service first
    from app.services.push_service_v1 import push_service, PushTarget, PushProvider, NotificationType
    from app.config.environment import settings
except ImportError:
    try:
        # Fallback to legacy push service
        from app.services.push_service import push_service, PushTarget, PushProvider, NotificationType
        from app.config.environment import settings
    except ImportError:
        # Fallback for testing
        class MockSettings:
            max_fanout_distance_km = 100.0
            min_fanout_distance_km = 0.1
            max_targets_per_fanout = 1000
        settings = MockSettings()
    
    from dataclasses import dataclass
    from enum import Enum
    
    class PushProvider(str, Enum):
        FCM = "fcm"
        APNS = "apns"
        WEBPUSH = "webpush"
    
    class NotificationType(str, Enum):
        ALERT = "alert"
        CHAT = "chat"
        SYSTEM = "system"
    
    @dataclass
    class PushTarget:
        device_id: str
        push_token: str
        provider: PushProvider
        platform: str
        user_id: str
        preferences: Dict[str, bool]
    
    class MockPushService:
        async def send_sighting_alert(self, **kwargs):
            return {
                "total_sent": len(kwargs.get("targets", [])),
                "total_failed": 0,
                "fcm_results": [],
                "apns_results": []
            }
    
    push_service = MockPushService()

logger = logging.getLogger(__name__)


@dataclass
class UserLocation:
    """User location and alert preferences"""
    user_id: str
    latitude: float
    longitude: float
    alert_range_km: float
    max_alerts_per_hour: int = 10
    alert_notifications_enabled: bool = True


@dataclass
class SightingEvent:
    """New sighting event data"""
    sighting_id: str
    latitude: float
    longitude: float
    title: str
    description: str
    shape: Optional[str] = None
    confidence_score: Optional[float] = None
    created_at: datetime = None


class AlertFanoutWorker:
    """Worker for fanning out sighting alerts to nearby users"""
    
    def __init__(self):
        self.max_fanout_distance_km = getattr(settings, 'max_fanout_distance_km', 100.0)
        self.min_fanout_distance_km = getattr(settings, 'min_fanout_distance_km', 0.1)
        self.max_targets_per_fanout = getattr(settings, 'max_targets_per_fanout', 1000)
        self.rate_limit_window_minutes = 60
        self.user_alert_history = {}  # In production, use Redis or database
        
    def calculate_distance_km(
        self, 
        lat1: float, lon1: float, 
        lat2: float, lon2: float
    ) -> float:
        """Calculate distance between two points using Haversine formula"""
        
        # Convert to radians
        lat1_rad = math.radians(lat1)
        lon1_rad = math.radians(lon1)
        lat2_rad = math.radians(lat2)
        lon2_rad = math.radians(lon2)
        
        # Haversine formula
        dlat = lat2_rad - lat1_rad
        dlon = lon2_rad - lon1_rad
        
        a = (math.sin(dlat/2)**2 + 
             math.cos(lat1_rad) * math.cos(lat2_rad) * math.sin(dlon/2)**2)
        c = 2 * math.asin(math.sqrt(a))
        
        # Earth radius in kilometers
        earth_radius_km = 6371.0
        distance = earth_radius_km * c
        
        return distance
        
    async def process_new_sighting(
        self,
        sighting: SightingEvent,
        user_locations: List[UserLocation],
        device_registry: Dict[str, List[Dict[str, Any]]]
    ) -> Dict[str, Any]:
        """Process a new sighting and send alerts to nearby users"""
        
        logger.info(f"Processing fanout for sighting {sighting.sighting_id}")
        
        # Find users within alert range
        nearby_users = self._find_nearby_users(sighting, user_locations)
        logger.info(f"Found {len(nearby_users)} users within range")
        
        if not nearby_users:
            return {
                "sighting_id": sighting.sighting_id,
                "nearby_users": 0,
                "notifications_sent": 0,
                "message": "No users within alert range"
            }
            
        # Apply rate limiting
        rate_limited_users = self._apply_rate_limiting(nearby_users)
        logger.info(f"After rate limiting: {len(rate_limited_users)} users")
        
        # Get push targets for users
        push_targets = self._get_push_targets(rate_limited_users, device_registry)
        logger.info(f"Found {len(push_targets)} push targets")
        
        if not push_targets:
            return {
                "sighting_id": sighting.sighting_id,
                "nearby_users": len(nearby_users),
                "notifications_sent": 0,
                "message": "No valid push targets"
            }
            
        # Create notification content
        notification_title, notification_body = self._create_notification_content(sighting)
        
        # Send push notifications
        results = await push_service.send_sighting_alert(
            sighting_id=sighting.sighting_id,
            title=notification_title,
            body=notification_body,
            targets=push_targets,
            distance_km=0.0,  # Will be calculated per target
            additional_data={
                "shape": sighting.shape,
                "confidence_score": str(sighting.confidence_score) if sighting.confidence_score else None,
                "timestamp": sighting.created_at.isoformat() if sighting.created_at else None
            }
        )
        
        # Update rate limiting history
        self._update_alert_history(rate_limited_users, sighting.sighting_id)
        
        logger.info(
            f"Fanout complete for {sighting.sighting_id}: "
            f"{results['total_sent']} sent, {results['total_failed']} failed"
        )
        
        return {
            "sighting_id": sighting.sighting_id,
            "nearby_users": len(nearby_users),
            "rate_limited_users": len(rate_limited_users), 
            "push_targets": len(push_targets),
            "notifications_sent": results["total_sent"],
            "notifications_failed": results["total_failed"],
            "fcm_results": results.get("fcm_results", []),
            "apns_results": results.get("apns_results", [])
        }
        
    def _find_nearby_users(
        self,
        sighting: SightingEvent,
        user_locations: List[UserLocation]
    ) -> List[Tuple[UserLocation, float]]:
        """Find users within alert range of the sighting"""
        
        nearby_users = []
        
        for user_location in user_locations:
            if not user_location.alert_notifications_enabled:
                continue
                
            distance_km = self.calculate_distance_km(
                sighting.latitude, sighting.longitude,
                user_location.latitude, user_location.longitude
            )
            
            # Check if within user's preferred range and system limits
            if (self.min_fanout_distance_km <= distance_km <= self.max_fanout_distance_km and
                distance_km <= user_location.alert_range_km):
                nearby_users.append((user_location, distance_km))
                
        # Sort by distance (closest first) and limit
        nearby_users.sort(key=lambda x: x[1])
        return nearby_users[:self.max_targets_per_fanout]
        
    def _apply_rate_limiting(
        self,
        nearby_users: List[Tuple[UserLocation, float]]
    ) -> List[Tuple[UserLocation, float]]:
        """Apply per-user rate limiting"""
        
        rate_limited = []
        current_time = datetime.utcnow()
        cutoff_time = current_time - timedelta(minutes=self.rate_limit_window_minutes)
        
        for user_location, distance in nearby_users:
            user_id = user_location.user_id
            
            # Get recent alert history for user
            user_history = self.user_alert_history.get(user_id, [])
            
            # Remove old alerts outside the window
            recent_alerts = [
                alert_time for alert_time in user_history 
                if alert_time > cutoff_time
            ]
            
            # Check if under rate limit
            if len(recent_alerts) < user_location.max_alerts_per_hour:
                rate_limited.append((user_location, distance))
            else:
                logger.debug(f"Rate limited user {user_id}: {len(recent_alerts)} alerts in last hour")
                
        return rate_limited
        
    def _get_push_targets(
        self,
        nearby_users: List[Tuple[UserLocation, float]],
        device_registry: Dict[str, List[Dict[str, Any]]]
    ) -> List[PushTarget]:
        """Convert nearby users to push targets"""
        
        push_targets = []
        
        for user_location, distance in nearby_users:
            user_id = user_location.user_id
            user_devices = device_registry.get(user_id, [])
            
            for device in user_devices:
                if (device.get("is_active", False) and 
                    device.get("push_enabled", False) and
                    device.get("push_token") and
                    device.get("alert_notifications", True)):
                    
                    # Determine push provider
                    provider_str = device.get("push_provider", "fcm")
                    try:
                        provider = PushProvider(provider_str)
                    except ValueError:
                        provider = PushProvider.FCM
                        
                    push_target = PushTarget(
                        device_id=device["device_id"],
                        push_token=device["push_token"],
                        provider=provider,
                        platform=device.get("platform", "unknown"),
                        user_id=user_id,
                        preferences={
                            "alert_notifications": device.get("alert_notifications", True),
                            "chat_notifications": device.get("chat_notifications", True), 
                            "system_notifications": device.get("system_notifications", True)
                        }
                    )
                    
                    push_targets.append(push_target)
                    
        return push_targets
        
    def _create_notification_content(self, sighting: SightingEvent) -> Tuple[str, str]:
        """Create notification title and body"""
        
        # Create engaging title
        shape_emoji = {
            "circle": "⭕",
            "triangle": "🔺", 
            "diamond": "🔶",
            "disc": "💿",
            "sphere": "⚪",
            "cylinder": "🥫",
            "unknown": "🛸"
        }.get(sighting.shape or "unknown", "🛸")
        
        title = f"{shape_emoji} UFO Sighting Nearby"
        
        # Create informative body
        if sighting.shape:
            body = f"{sighting.shape.title()} formation reported"
        else:
            body = "Unidentified aerial phenomenon reported"
            
        # Add distance context in the worker that has user location
        # For now, use generic messaging
        body += " in your area. Tap to view details."
        
        return title, body
        
    def _update_alert_history(
        self,
        rate_limited_users: List[Tuple[UserLocation, float]],
        sighting_id: str
    ):
        """Update alert history for rate limiting"""
        
        current_time = datetime.utcnow()
        
        for user_location, _ in rate_limited_users:
            user_id = user_location.user_id
            
            if user_id not in self.user_alert_history:
                self.user_alert_history[user_id] = []
                
            self.user_alert_history[user_id].append(current_time)
            
            # Keep only recent history to prevent memory bloat
            cutoff_time = current_time - timedelta(minutes=self.rate_limit_window_minutes)
            self.user_alert_history[user_id] = [
                alert_time for alert_time in self.user_alert_history[user_id]
                if alert_time > cutoff_time
            ]


# Mock data functions for testing
def get_mock_user_locations() -> List[UserLocation]:
    """Get mock user locations for testing"""
    return [
        UserLocation(
            user_id="user_001",
            latitude=37.7749,  # San Francisco
            longitude=-122.4194,
            alert_range_km=50.0,
            max_alerts_per_hour=5,
            alert_notifications_enabled=True
        ),
        UserLocation(
            user_id="user_002", 
            latitude=37.7849,  # 1km north
            longitude=-122.4194,
            alert_range_km=25.0,
            max_alerts_per_hour=10,
            alert_notifications_enabled=True
        ),
        UserLocation(
            user_id="user_003",
            latitude=40.7589,  # New York (too far)
            longitude=-73.9851,
            alert_range_km=100.0,
            max_alerts_per_hour=20,
            alert_notifications_enabled=True
        )
    ]
    

def get_mock_device_registry() -> Dict[str, List[Dict[str, Any]]]:
    """Get mock device registry for testing"""
    return {
        "user_001": [
            {
                "id": "device_abc123",
                "device_id": "ios_device_001",
                "device_name": "iPhone 15 Pro",
                "platform": "ios",
                "push_token": "mock_fcm_token_001",
                "push_provider": "fcm",
                "push_enabled": True,
                "alert_notifications": True,
                "chat_notifications": True,
                "system_notifications": False,
                "is_active": True
            }
        ],
        "user_002": [
            {
                "id": "device_def456",
                "device_id": "android_device_002", 
                "device_name": "Pixel 8 Pro",
                "platform": "android",
                "push_token": "mock_fcm_token_002",
                "push_provider": "fcm", 
                "push_enabled": True,
                "alert_notifications": True,
                "chat_notifications": False,
                "system_notifications": True,
                "is_active": True
            }
        ],
        "user_003": [
            {
                "id": "device_ghi789",
                "device_id": "ios_device_003",
                "device_name": "iPhone 14",
                "platform": "ios", 
                "push_token": "mock_apns_token_003",
                "push_provider": "apns",
                "push_enabled": True,
                "alert_notifications": True,
                "chat_notifications": True,
                "system_notifications": True,
                "is_active": True
            }
        ]
    }


# Global worker instance  
alert_fanout_worker = AlertFanoutWorker()


# Test function
async def test_alert_fanout():
    """Test the alert fanout functionality"""
    
    logger.info("🧪 Testing Alert Fanout Worker")
    
    # Mock sighting in San Francisco
    sighting = SightingEvent(
        sighting_id="sighting_test_001",
        latitude=37.7849,  # Close to user_001 and user_002
        longitude=-122.4194,
        title="Triangle Formation",
        description="Three bright lights in triangle formation moving silently",
        shape="triangle",
        confidence_score=0.85,
        created_at=datetime.utcnow()
    )
    
    user_locations = get_mock_user_locations()
    device_registry = get_mock_device_registry()
    
    results = await alert_fanout_worker.process_new_sighting(
        sighting=sighting,
        user_locations=user_locations, 
        device_registry=device_registry
    )
    
    logger.info("Alert fanout test results:")
    logger.info(f"  - Sighting ID: {results['sighting_id']}")
    logger.info(f"  - Nearby users: {results['nearby_users']}")
    logger.info(f"  - Rate limited users: {results['rate_limited_users']}")
    logger.info(f"  - Push targets: {results['push_targets']}")
    logger.info(f"  - Notifications sent: {results['notifications_sent']}")
    logger.info(f"  - Notifications failed: {results['notifications_failed']}")
    
    return results


if __name__ == "__main__":
    # Configure logging
    logging.basicConfig(
        level=logging.INFO,
        format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
    )
    
    # Run test
    asyncio.run(test_alert_fanout())