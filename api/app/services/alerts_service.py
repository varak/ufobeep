"""
Alerts Service

Handles real-time alert generation, notification dispatching, 
and alert-related business logic for the UFOBeep system.
"""

import asyncio
import logging
from datetime import datetime, timedelta
from typing import List, Optional, Dict, Any
from dataclasses import dataclass
import math

logger = logging.getLogger(__name__)

# Import sightings storage
from app.routers.sightings import sightings_db


@dataclass
class AlertTrigger:
    """Configuration for when to trigger alerts"""
    min_alert_level: str = "medium"
    max_distance_km: float = 100.0
    recent_hours: int = 24
    witness_count_threshold: int = 2
    verification_score_threshold: float = 0.3


@dataclass 
class AlertNotification:
    """Alert notification to be sent"""
    alert_id: str
    recipient_type: str  # "nearby_users", "subscribers", "moderators"
    title: str
    body: str
    data: Dict[str, Any]
    priority: str  # "low", "normal", "high"
    created_at: datetime


class AlertsService:
    """Service for managing real-time alerts generation and notification"""
    
    def __init__(self):
        self.trigger_config = AlertTrigger()
        self.notification_queue: List[AlertNotification] = []
        self.processed_sightings: set = set()
        
    def should_trigger_alert(self, sighting) -> bool:
        """Determine if a sighting should trigger an alert"""
        try:
            # Check if already processed
            if sighting.id in self.processed_sightings:
                return False
            
            # Check alert level threshold
            alert_levels = ["low", "medium", "high", "critical"]
            min_level_idx = alert_levels.index(self.trigger_config.min_alert_level)
            sighting_level = sighting.alert_level.value if hasattr(sighting.alert_level, 'value') else sighting.alert_level
            current_level_idx = alert_levels.index(sighting_level)
            
            if current_level_idx < min_level_idx:
                logger.debug(f"Sighting {sighting.id} alert level {sighting_level} below threshold {self.trigger_config.min_alert_level}")
                return False
            
            # Check if recent enough
            if sighting.created_at:
                cutoff_time = datetime.utcnow() - timedelta(hours=self.trigger_config.recent_hours)
                if sighting.created_at < cutoff_time:
                    logger.debug(f"Sighting {sighting.id} too old for alert triggering")
                    return False
            
            # Check witness count for higher credibility
            if (sighting_level in ["high", "critical"] and 
                sighting.witness_count < self.trigger_config.witness_count_threshold):
                logger.debug(f"High-level sighting {sighting.id} has insufficient witnesses ({sighting.witness_count})")
                return False
            
            # Check verification score if available
            if (hasattr(sighting, 'verification_score') and 
                sighting.verification_score > 0 and 
                sighting.verification_score < self.trigger_config.verification_score_threshold):
                logger.debug(f"Sighting {sighting.id} verification score {sighting.verification_score} below threshold")
                return False
            
            # Check if sighting is public
            if hasattr(sighting, 'is_public') and not sighting.is_public:
                logger.debug(f"Sighting {sighting.id} is private, skipping alert")
                return False
            
            logger.info(f"Sighting {sighting.id} meets alert criteria: level={sighting_level}, witnesses={sighting.witness_count}")
            return True
            
        except Exception as e:
            logger.error(f"Error checking alert trigger for sighting {sighting.id}: {e}")
            return False
    
    def generate_alert_notification(self, sighting) -> AlertNotification:
        """Generate alert notification content"""
        try:
            sighting_level = sighting.alert_level.value if hasattr(sighting.alert_level, 'value') else sighting.alert_level
            
            # Create notification title and body based on alert level and category
            if sighting_level == "critical":
                title = f"🚨 CRITICAL ALERT: {sighting.category.upper()} Sighting"
                priority = "high"
            elif sighting_level == "high":
                title = f"⚠️ HIGH ALERT: {sighting.category.upper()} Sighting"
                priority = "high"
            else:
                title = f"📍 New {sighting.category.upper()} Sighting"
                priority = "normal"
            
            # Create notification body
            location_desc = "Unknown location"
            if hasattr(sighting, 'jittered_location'):
                location_desc = f"Near {sighting.jittered_location.latitude:.3f}, {sighting.jittered_location.longitude:.3f}"
            
            witness_desc = "1 witness"
            if sighting.witness_count > 1:
                witness_desc = f"{sighting.witness_count} witnesses"
            
            body = f"{sighting.title} - {location_desc} ({witness_desc})"
            
            # Create notification data payload
            data = {
                "alert_id": sighting.id,
                "sighting_id": sighting.id,
                "category": sighting.category,
                "alert_level": sighting_level,
                "title": sighting.title,
                "description": sighting.description,
                "witness_count": sighting.witness_count,
                "created_at": sighting.created_at.isoformat() if sighting.created_at else None,
                "deep_link": f"ufobeep://alert/{sighting.id}",
            }
            
            # Add location data
            if hasattr(sighting, 'jittered_location'):
                data["location"] = {
                    "latitude": sighting.jittered_location.latitude,
                    "longitude": sighting.jittered_location.longitude,
                }
            
            # Add media info if available
            if hasattr(sighting, 'media_files') and sighting.media_files:
                data["has_media"] = True
                data["media_count"] = len(sighting.media_files)
            else:
                data["has_media"] = False
                data["media_count"] = 0
            
            return AlertNotification(
                alert_id=sighting.id,
                recipient_type="nearby_users",
                title=title,
                body=body,
                data=data,
                priority=priority,
                created_at=datetime.utcnow()
            )
            
        except Exception as e:
            logger.error(f"Error generating alert notification for sighting {sighting.id}: {e}")
            raise
    
    def find_nearby_users(self, sighting, max_distance_km: float = None) -> List[str]:
        """Find users who should receive this alert based on location"""
        # TODO: In production, this would query the user database for:
        # - Users with push tokens registered
        # - Users within the specified distance of the sighting
        # - Users with notification preferences enabled
        # - Users not in "do not disturb" mode
        
        if max_distance_km is None:
            max_distance_km = self.trigger_config.max_distance_km
        
        # For now, return mock user IDs
        mock_nearby_users = [
            "user_001", "user_002", "user_003", "user_004", "user_005"
        ]
        
        logger.info(f"Found {len(mock_nearby_users)} nearby users within {max_distance_km}km of sighting {sighting.id}")
        return mock_nearby_users
    
    def queue_notification(self, notification: AlertNotification, recipient_ids: List[str]):
        """Queue notification for delivery to specific recipients"""
        try:
            # In production, this would:
            # - Store in Redis queue or message broker
            # - Send to push notification service (FCM, APNS)
            # - Log delivery attempts and results
            # - Handle retry logic for failed deliveries
            
            logger.info(f"Queuing alert notification {notification.alert_id} for {len(recipient_ids)} recipients")
            self.notification_queue.append(notification)
            
            # Mock notification sending
            for recipient_id in recipient_ids:
                logger.info(f"📱 MOCK PUSH: {recipient_id} <- {notification.title}: {notification.body}")
            
        except Exception as e:
            logger.error(f"Error queuing notification {notification.alert_id}: {e}")
    
    async def process_new_sightings(self):
        """Process new sightings for alert generation"""
        try:
            new_alerts_count = 0
            
            # Check all sightings for new ones that should trigger alerts
            for sighting_id, sighting in sightings_db.items():
                if self.should_trigger_alert(sighting):
                    # Generate alert notification
                    notification = self.generate_alert_notification(sighting)
                    
                    # Find nearby users to notify
                    nearby_users = self.find_nearby_users(sighting)
                    
                    # Queue notification for delivery
                    if nearby_users:
                        self.queue_notification(notification, nearby_users)
                        new_alerts_count += 1
                    
                    # Mark as processed
                    self.processed_sightings.add(sighting_id)
                    
                    logger.info(f"Generated alert for sighting {sighting_id}")
            
            if new_alerts_count > 0:
                logger.info(f"Processed {new_alerts_count} new alerts")
            
            return new_alerts_count
            
        except Exception as e:
            logger.error(f"Error processing new sightings: {e}")
            return 0
    
    async def cleanup_old_notifications(self):
        """Clean up old notifications from queue"""
        try:
            cutoff_time = datetime.utcnow() - timedelta(hours=24)
            initial_count = len(self.notification_queue)
            
            self.notification_queue = [
                notif for notif in self.notification_queue 
                if notif.created_at > cutoff_time
            ]
            
            cleaned_count = initial_count - len(self.notification_queue)
            if cleaned_count > 0:
                logger.info(f"Cleaned up {cleaned_count} old notifications")
                
        except Exception as e:
            logger.error(f"Error cleaning up notifications: {e}")
    
    def get_notification_stats(self) -> Dict[str, Any]:
        """Get current notification queue statistics"""
        now = datetime.utcnow()
        recent_cutoff = now - timedelta(hours=1)
        
        total_notifications = len(self.notification_queue)
        recent_notifications = len([
            notif for notif in self.notification_queue 
            if notif.created_at > recent_cutoff
        ])
        
        high_priority_count = len([
            notif for notif in self.notification_queue 
            if notif.priority == "high"
        ])
        
        return {
            "total_notifications": total_notifications,
            "recent_notifications_1h": recent_notifications,
            "high_priority_notifications": high_priority_count,
            "processed_sightings": len(self.processed_sightings),
            "queue_size": total_notifications,
            "last_processed": now.isoformat(),
        }
    
    async def run_alerts_loop(self, interval_seconds: int = 30):
        """Main alerts processing loop"""
        logger.info(f"Starting alerts processing loop (interval: {interval_seconds}s)")
        
        while True:
            try:
                # Process new sightings
                new_alerts = await self.process_new_sightings()
                
                # Clean up old notifications periodically
                if len(self.notification_queue) > 100:
                    await self.cleanup_old_notifications()
                
                # Log stats periodically
                if len(self.processed_sightings) % 10 == 0 or new_alerts > 0:
                    stats = self.get_notification_stats()
                    logger.info(f"Alerts stats: {stats}")
                
                # Wait before next iteration
                await asyncio.sleep(interval_seconds)
                
            except KeyboardInterrupt:
                logger.info("Alerts loop interrupted by user")
                break
            except Exception as e:
                logger.error(f"Error in alerts processing loop: {e}")
                # Wait a bit longer on error to avoid tight error loops
                await asyncio.sleep(interval_seconds * 2)


# Global alerts service instance
alerts_service = AlertsService()


# Convenience functions
async def trigger_alert_check():
    """Trigger a single alert processing cycle"""
    return await alerts_service.process_new_sightings()


def get_alerts_stats():
    """Get current alerts service statistics"""
    return alerts_service.get_notification_stats()