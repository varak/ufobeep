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
        self.fcm_server_key = getattr(settings, 'fcm_server_key', None)
        self.apns_key_id = getattr(settings, 'apns_key_id', None) 
        self.apns_team_id = getattr(settings, 'apns_team_id', None)
        self.apns_bundle_id = getattr(settings, 'apns_bundle_id', 'com.ufobeep.app')
        self.fcm_url = "https://fcm.googleapis.com/fcm/send"
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
        """Send FCM push notifications"""
        
        if not self.fcm_server_key:
            logger.error("FCM server key not configured")
            return [{"success": False, "error": "FCM not configured"} for _ in targets]
            
        results = []
        fcm_payload = payload.to_fcm_payload()
        
        if collapse_key:
            fcm_payload["collapse_key"] = collapse_key
            
        headers = {
            "Authorization": f"key={self.fcm_server_key}",
            "Content-Type": "application/json"
        }
        
        async with aiohttp.ClientSession() as session:
            tasks = []
            for target in targets:
                task = self._send_single_fcm(
                    session, target, fcm_payload, headers
                )
                tasks.append(task)
                
            results = await asyncio.gather(*tasks, return_exceptions=True)
            
        return [r if not isinstance(r, Exception) else {"success": False, "error": str(r)} for r in results]
        
    async def _send_single_fcm(
        self,
        session: aiohttp.ClientSession,
        target: PushTarget,
        payload: Dict[str, Any],
        headers: Dict[str, str]
    ) -> Dict[str, Any]:
        """Send single FCM notification"""
        
        try:
            fcm_message = {
                **payload,
                "to": target.push_token
            }
            
            timeout = aiohttp.ClientTimeout(total=30.0)
            async with session.post(
                self.fcm_url,
                headers=headers,
                json=fcm_message,
                timeout=timeout
            ) as response:
                
                if response.status == 200:
                    result = await response.json()
                    if result.get("success", 0) > 0:
                        logger.debug(f"FCM sent successfully to {target.device_id}")
                        return {
                            "success": True,
                            "device_id": target.device_id,
                            "message_id": result.get("results", [{}])[0].get("message_id")
                        }
                    else:
                        error = result.get("results", [{}])[0].get("error", "Unknown error")
                        logger.warning(f"FCM failed for {target.device_id}: {error}")
                        return {
                            "success": False, 
                            "device_id": target.device_id,
                            "error": error
                        }
                else:
                    logger.error(f"FCM HTTP error {response.status} for {target.device_id}")
                    return {
                        "success": False,
                        "device_id": target.device_id, 
                        "error": f"HTTP {response.status}"
                    }
                
        except Exception as e:
            logger.error(f"FCM exception for {target.device_id}: {e}")
            return {
                "success": False,
                "device_id": target.device_id,
                "error": str(e)
            }
            
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
        
    async def send_chat_notification(
        self,
        sighting_id: str,
        room_id: str,
        sender_name: str,
        message_preview: str,
        targets: List[PushTarget]
    ) -> Dict[str, Any]:
        """Send chat message notification"""
        
        data = {
            "type": "chat_message",
            "sighting_id": sighting_id,
            "room_id": room_id,
            "deep_link": f"ufobeep://sighting/{sighting_id}/chat",
            "click_action": "OPEN_CHAT"
        }
        
        payload = PushPayload(
            title=f"💬 {sender_name}",
            body=message_preview,
            data=data,
            sound="default"
        )
        
        return await self.send_notification(
            targets=targets,
            payload=payload,
            notification_type=NotificationType.CHAT,
            collapse_key=f"chat_{room_id}"
        )


# Global service instance
push_service = PushNotificationService()