"""
Push notification service for UFOBeep
Handles FCM and APNS push notifications with deep link support
"""

import json
import logging
import aiohttp
import asyncio
from typing import List, Dict, Any, Optional, Union
from datetime import datetime
from enum import Enum
from dataclasses import dataclass, asdict

# Firebase Admin SDK for modern FCM API
from firebase_admin import messaging
from app.core.firebase_client import get_messaging

try:
    from app.config.environment import settings
except ImportError:
    # Fallback for testing
    class MockSettings:
        fcm_server_key = None
        apns_key_id = None
        apns_team_id = None
        apns_bundle_id = 'com.ufobeep.app'
        max_fanout_distance_km = 100.0
        min_fanout_distance_km = 0.1
        max_targets_per_fanout = 1000
    settings = MockSettings()

logger = logging.getLogger(__name__)


class NotificationType(str, Enum):
    """Push notification types"""
    ALERT = "alert"
    CHAT = "chat" 
    SYSTEM = "system"


class PushProvider(str, Enum):
    """Push notification providers"""
    FCM = "fcm"
    APNS = "apns"
    WEBPUSH = "webpush"


@dataclass
class PushPayload:
    """Push notification payload"""
    title: str
    body: str
    data: Dict[str, Any]
    badge_count: Optional[int] = None
    sound: Optional[str] = "default"
    click_action: Optional[str] = None
    
    def to_fcm_payload(self) -> Dict[str, Any]:
        """Convert to FCM format"""
        payload = {
            "notification": {
                "title": self.title,
                "body": self.body,
            },
            "data": {str(k): str(v) for k, v in self.data.items()},
            "android": {
                "notification": {
                    "click_action": self.click_action or "FLUTTER_NOTIFICATION_CLICK",
                    "sound": self.sound,
                },
                "priority": "high"
            }
        }
        
        if self.badge_count is not None:
            payload["notification"]["badge"] = str(self.badge_count)
            
        return payload
    
    def to_apns_payload(self) -> Dict[str, Any]:
        """Convert to APNS format"""
        aps = {
            "alert": {
                "title": self.title,
                "body": self.body
            },
            "sound": self.sound or "default"
        }
        
        if self.badge_count is not None:
            aps["badge"] = self.badge_count
            
        payload = {
            "aps": aps,
            **self.data
        }
        
        return payload


@dataclass  
class PushTarget:
    """Push notification target device"""
    device_id: str
    push_token: str
    provider: PushProvider
    platform: str
    user_id: str
    preferences: Dict[str, bool]


class PushNotificationService:
    """Service for sending push notifications via FCM and APNS"""
    
    def __init__(self):
        # APNS configuration (legacy FCM server key no longer needed with Firebase Admin SDK)
        self.apns_key_id = getattr(settings, 'apns_key_id', None) 
        self.apns_team_id = getattr(settings, 'apns_team_id', None)
        self.apns_bundle_id = getattr(settings, 'apns_bundle_id', 'com.ufobeep.app')
        self.apns_url = "https://api.push.apple.com/3/device"
        
    async def send_notification(
        self,
        targets: List[PushTarget],
        payload: PushPayload,
        notification_type: NotificationType,
        collapse_key: Optional[str] = None
    ) -> Dict[str, Any]:
        """Send push notification to multiple targets"""
        
        results = {
            "total_sent": 0,
            "total_failed": 0,
            "fcm_results": [],
            "apns_results": [],
            "errors": []
        }
        
        # Filter targets based on notification preferences
        filtered_targets = self._filter_targets_by_preferences(targets, notification_type)
        
        if not filtered_targets:
            logger.info("No valid targets after preference filtering")
            return results
            
        # Group targets by provider
        fcm_targets = [t for t in filtered_targets if t.provider == PushProvider.FCM]
        apns_targets = [t for t in filtered_targets if t.provider == PushProvider.APNS]
        
        # Send FCM notifications
        if fcm_targets:
            fcm_results = await self._send_fcm_notifications(
                fcm_targets, payload, collapse_key
            )
            results["fcm_results"] = fcm_results
            results["total_sent"] += sum(1 for r in fcm_results if r.get("success"))
            results["total_failed"] += sum(1 for r in fcm_results if not r.get("success"))
            
        # Send APNS notifications  
        if apns_targets:
            apns_results = await self._send_apns_notifications(
                apns_targets, payload, collapse_key
            )
            results["apns_results"] = apns_results
            results["total_sent"] += sum(1 for r in apns_results if r.get("success"))
            results["total_failed"] += sum(1 for r in apns_results if not r.get("success"))
            
        logger.info(
            f"Push notification sent: {results['total_sent']} success, "
            f"{results['total_failed']} failed"
        )
        
        return results
        
    def _filter_targets_by_preferences(
        self, 
        targets: List[PushTarget], 
        notification_type: NotificationType
    ) -> List[PushTarget]:
        """Filter targets based on notification preferences"""
        
        filtered = []
        preference_key_map = {
            NotificationType.ALERT: "alert_notifications",
            NotificationType.CHAT: "chat_notifications", 
            NotificationType.SYSTEM: "system_notifications"
        }
        
        preference_key = preference_key_map.get(notification_type)
        if not preference_key:
            return targets
            
        for target in targets:
            if target.preferences.get(preference_key, True):
                filtered.append(target)
            else:
                logger.debug(
                    f"Skipping device {target.device_id} - "
                    f"{preference_key} disabled"
                )
                
        return filtered
        
    async def _send_fcm_notifications(
        self,
        targets: List[PushTarget],
        payload: PushPayload,
        collapse_key: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Send FCM push notifications using Firebase Admin SDK"""
        
        try:
            messaging_client = get_messaging()
        except Exception as e:
            logger.error(f"Failed to get Firebase messaging client: {e}")
            return [{"success": False, "error": "Firebase not configured"} for _ in targets]
            
        results = []
        
        for target in targets:
            try:
                # Create Firebase message
                message = messaging.Message(
                    notification=messaging.Notification(
                        title=payload.title,
                        body=payload.body
                    ),
                    data=payload.data or {},
                    token=target.push_token,
                    android=messaging.AndroidConfig(
                        notification=messaging.AndroidNotification(
                            channel_id="ufobeep_alerts",
                            sound=payload.sound or "default"
                        ),
                        collapse_key=collapse_key,
                        data=payload.data or {}
                    )
                )
                
                # Send message
                response = messaging.send(message)
                logger.debug(f"FCM sent successfully to {target.device_id}: {response}")
                
                results.append({
                    "success": True,
                    "device_id": target.device_id,
                    "message_id": response
                })
                
            except Exception as e:
                logger.error(f"FCM failed for {target.device_id}: {e}")
                results.append({
                    "success": False,
                    "device_id": target.device_id,
                    "error": str(e)
                })
        
        return results
            
    async def _send_apns_notifications(
        self,
        targets: List[PushTarget], 
        payload: PushPayload,
        collapse_key: Optional[str] = None
    ) -> List[Dict[str, Any]]:
        """Send APNS push notifications"""
        
        # For now, return mock success since APNS requires complex JWT signing
        # In production, this would use proper APNS HTTP/2 API with JWT tokens
        logger.info(f"APNS notifications would be sent to {len(targets)} devices")
        
        results = []
        for target in targets:
            results.append({
                "success": True,
                "device_id": target.device_id,
                "message_id": f"apns_mock_{target.device_id}_{datetime.utcnow().timestamp()}"
            })
            
        return results
        
    async def send_sighting_alert(
        self,
        sighting_id: str,
        title: str,
        body: str, 
        targets: List[PushTarget],
        distance_km: float,
        additional_data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Send UFO sighting alert notification"""
        
        data = {
            "type": "sighting_alert",
            "sighting_id": sighting_id,
            "distance_km": str(distance_km),
            "deep_link": f"ufobeep://sighting/{sighting_id}",
            "click_action": "OPEN_SIGHTING",
            **(additional_data or {})
        }
        
        payload = PushPayload(
            title=title,
            body=body,
            data=data,
            sound="default",
            click_action="FLUTTER_NOTIFICATION_CLICK"
        )
        
        return await self.send_notification(
            targets=targets,
            payload=payload,
            notification_type=NotificationType.ALERT,
            collapse_key=f"sighting_{sighting_id}"
        )
        
    async def send_comment_notification(
        self,
        sighting_id: str,
        commenter_username: str,
        comment_body: str,
        targets: List[PushTarget],
        alert_title: Optional[str] = None
    ) -> Dict[str, Any]:
        """Send comment notification to followers of an alert"""
        
        # Truncate comment for preview
        comment_preview = comment_body[:80] + "..." if len(comment_body) > 80 else comment_body
        
        # Create notification title
        title = f"💬 {commenter_username} commented"
        if alert_title:
            title += f" on {alert_title[:30]}..."
        
        data = {
            "type": "comment_notification",
            "sighting_id": sighting_id,
            "deep_link": f"ufobeep://alert/{sighting_id}/comments",
            "click_action": "OPEN_COMMENTS"
        }
        
        payload = PushPayload(
            title=title,
            body=comment_preview,
            data=data,
            sound="default"
        )
        
        return await self.send_notification(
            targets=targets,
            payload=payload,
            notification_type=NotificationType.CHAT,  # Using CHAT type for comment notifications
            collapse_key=f"comments_{sighting_id}"
        )


# Global service instance
push_service = PushNotificationService()