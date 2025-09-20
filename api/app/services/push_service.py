"""
Push notification service for UFOBeep
Handles FCM and APNS push notifications with deep link support
"""

import json
import logging
import aiohttp
import asyncio
from typing import List, Dict, Any, Optional, Union, Tuple
from datetime import datetime, timezone
from zoneinfo import ZoneInfo
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
    BEEP = "beep"
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
    language: str = "en"  # User's preferred language - default to English for compatibility


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
            NotificationType.BEEP: "beep_notifications",
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
                            channel_id="ufobeep_beeps",
                            sound=payload.sound or "default"
                        ),
                        collapse_key=collapse_key,
                        data=payload.data or {}
                    )
                )
                
                # Send message - use modern asyncio.to_thread with timeout
                response = await asyncio.wait_for(
                    asyncio.to_thread(messaging.send, message),
                    timeout=8.0
                )
                logger.debug(f"FCM sent successfully to {target.device_id}: {response}")
                
                results.append({
                    "success": True,
                    "device_id": target.device_id,
                    "message_id": response
                })
                
            except asyncio.TimeoutError:
                logger.error(f"FCM timeout after 8s for {target.device_id}")
                results.append({
                    "success": False,
                    "device_id": target.device_id,
                    "error": "Timeout after 8s"
                })
            except Exception as e:
                error_message = str(e)
                logger.error(f"FCM failed for {target.device_id}: {error_message}")
                
                # Clean up invalid tokens to prevent future spam
                if "Requested entity was not found" in error_message:
                    logger.info(f"Invalid FCM token detected for {target.device_id}, marking token as invalid")
                    try:
                        await self._disable_invalid_token(target.device_id, target.push_token)
                    except Exception as cleanup_error:
                        logger.error(f"Failed to clean up invalid token for {target.device_id}: {cleanup_error}")
                
                results.append({
                    "success": False,
                    "device_id": target.device_id,
                    "error": error_message
                })
        
        return results
    
    async def _disable_invalid_token(self, device_id: str, push_token: str):
        """Disable invalid FCM token to prevent future failed attempts"""
        try:
            from app.services.database_service import get_database_pool
            pool = await get_database_pool()
            
            async with pool.acquire() as conn:
                result = await conn.execute(
                    """
                    UPDATE devices 
                    SET push_enabled = false, push_token = null, token_updated_at = NOW()
                    WHERE device_id = $1 AND push_token = $2
                    """,
                    device_id, push_token
                )
                logger.info(f"Disabled invalid FCM token for device {device_id}")
                
        except Exception as e:
            logger.error(f"Failed to disable invalid token: {e}")
            
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
        
    async def send_sighting_beep(
        self,
        sighting_id: str,
        title: str,
        body: str, 
        targets: List[PushTarget],
        distance_km: float,
        additional_data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Send UFO sighting beep notification"""
        # Apply DND/snooze/mute filters before sending
        targets = await self._apply_quiet_hours_and_mutes(sighting_id, targets)

        data = {
            "type": "sighting_beep",
            "sighting_id": sighting_id,
            "distance_km": str(distance_km),
            "deep_link": f"ufobeep://sighting/{sighting_id}",
            "click_action": "OPEN_SIGHTING",
            **(additional_data or {})
        }
        
        # Get user's language and use proper translations
        user_language = targets[0].language if targets else "en"

        from app.services.notification_translation_service import get_ufo_alert_title, get_sighting_notification_body
        localized_title = f"🛸 {get_ufo_alert_title(user_language)}"
        localized_body = get_sighting_notification_body(user_language)

        payload = PushPayload(
            title=localized_title,
            body=localized_body,
            data=data,
            sound="default",
            click_action="FLUTTER_NOTIFICATION_CLICK"
        )

        return await self.send_notification(
            targets=targets,
            payload=payload,
            notification_type=NotificationType.BEEP,
            collapse_key=f"sighting_{sighting_id}"
        )
        
    async def send_comment_notification(
        self,
        sighting_id: str,
        commenter_username: str,
        comment_body: str,
        targets: List[PushTarget],
        beep_title: Optional[str] = None,
        comment_id: Optional[str] = None
    ) -> Dict[str, Any]:
        """Send comment notification to followers of a beep"""
        # Apply DND/snooze/mute filters before sending
        targets = await self._apply_quiet_hours_and_mutes(sighting_id, targets)

        # Truncate comment for preview
        comment_preview = comment_body[:80] + "..." if len(comment_body) > 80 else comment_body
        
        # Create notification title
        title = f"💬 {commenter_username} commented"
        if beep_title:
            title += f" on {beep_title[:30]}..."

        data = {
            "type": "comment",
            "sighting_id": sighting_id,
            "comment_id": comment_id,
            "deep_link": f"ufobeep://beep/{sighting_id}/comments#comment-input",
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
            notification_type=NotificationType.BEEP,
            collapse_key=f"comments_{sighting_id}"
        )

    async def _apply_quiet_hours_and_mutes(self, sighting_id: str, targets: List[PushTarget]) -> List[PushTarget]:
        """Filter targets by device/user DND, snooze, and per-alert mutes"""
        if not targets:
            return targets

        try:
            from app.services.database_service import get_database_pool
            pool = await get_database_pool()
        except Exception as e:
            logger.error(f"DND filter: DB unavailable, skipping filtering: {e}")
            return targets

        user_ids = list({t.user_id for t in targets})
        device_ids = list({t.device_id for t in targets})

        device_prefs: Dict[Tuple[str, str], Dict[str, Any]] = {}
        follow_prefs: Dict[str, Dict[str, Any]] = {}

        async with pool.acquire() as conn:
            # Load device preferences and snooze
            try:
                rows = await conn.fetch(
                    """
                    SELECT user_id, device_id, timezone, preferences, snooze_until 
                    FROM devices 
                    WHERE device_id = ANY($1)
                      AND user_id = ANY($2)
                      AND is_active = true
                      AND push_enabled = true
                    """,
                    device_ids, user_ids
                )
                for r in rows:
                    key = (str(r["user_id"]), r["device_id"]) 
                    device_prefs[key] = {
                        "timezone": r.get("timezone") or "UTC",
                        "preferences": r.get("preferences") or {},
                        "snooze_until": r.get("snooze_until"),
                    }
            except Exception as e:
                logger.error(f"DND filter: failed loading device prefs: {e}")

            # Load per-alert follow mutes/snoozes
            try:
                rows = await conn.fetch(
                    """
                    SELECT user_id, mute, snooze_until
                    FROM follows
                    WHERE sighting_id = $1
                      AND user_id = ANY($2)
                    """,
                    sighting_id, user_ids
                )
                for r in rows:
                    follow_prefs[str(r["user_id"])] = {
                        "mute": r.get("mute", False),
                        "snooze_until": r.get("snooze_until"),
                    }
            except Exception as e:
                logger.error(f"DND filter: failed loading follow prefs: {e}")

        now_utc = datetime.now(timezone.utc)

        def in_dnd_window(pref: Dict[str, Any]) -> bool:
            preferences = pref.get("preferences") or {}

            # Only support Flutter format (quietHoursEnabled, quietHoursStart, quietHoursEnd)
            if not preferences.get("quietHoursEnabled"):
                return False

            start_hour = preferences.get("quietHoursStart", 22)  # Default 10 PM
            end_hour = preferences.get("quietHoursEnd", 7)       # Default 7 AM

            try:
                tzname = pref.get("timezone", "UTC")
                tz = ZoneInfo(tzname)
            except Exception:
                tz = ZoneInfo("UTC")
            local_now = now_utc.astimezone(tz)

            # Convert to minutes for comparison (ignore seconds/minutes for simplicity)
            current_hour = local_now.hour

            # Handle overnight quiet hours (e.g., 22:00 - 07:00)
            if start_hour != end_hour:
                if start_hour < end_hour:
                    # Same day range (e.g., 8:00 - 17:00)
                    return start_hour <= current_hour < end_hour
                else:
                    # Overnight range (e.g., 22:00 - 07:00)
                    return current_hour >= start_hour or current_hour < end_hour

            # If start == end, no quiet hours active
            return False

        filtered: List[PushTarget] = []
        for t in targets:
            # Per-alert mute/snooze
            f = follow_prefs.get(t.user_id)
            if f:
                if f.get("mute"):
                    continue
                su = f.get("snooze_until")
                if su and isinstance(su, datetime) and su.tzinfo is not None and su > now_utc:
                    continue
            # Device-level snooze/DND
            p = device_prefs.get((t.user_id, t.device_id))
            if p:
                # Check snooze_until (legacy format)
                su = p.get("snooze_until")
                if su and isinstance(su, datetime) and su.tzinfo is not None and su > now_utc:
                    continue

                # Check dndUntil (Flutter format)
                preferences = p.get("preferences") or {}
                dnd_until = preferences.get("dndUntil")
                if dnd_until:
                    try:
                        if isinstance(dnd_until, str):
                            dnd_until = datetime.fromisoformat(dnd_until.replace('Z', '+00:00'))
                        if isinstance(dnd_until, datetime) and dnd_until > now_utc:
                            continue
                    except Exception as e:
                        logger.warning(f"Invalid dndUntil format: {dnd_until}, error: {e}")

                # Check quiet hours
                if in_dnd_window(p):
                    continue
            filtered.append(t)

        if len(filtered) != len(targets):
            logger.info(f"DND/Snooze filtered {len(targets) - len(filtered)} of {len(targets)} targets for sighting {sighting_id}")

        return filtered


# Compatibility functions for legacy imports
async def send_to_token(token: str, data: dict, title=None, body=None):
    """Legacy compatibility function - send push notification to a specific FCM token"""
    try:
        messaging_client = get_messaging()
    except Exception as e:
        logger.error(f"Failed to get Firebase messaging client: {e}")
        return None
        
    try:
        # Create Firebase message with high priority for background delivery
        message = messaging.Message(
            notification=messaging.Notification(
                title=title,
                body=body
            ),
            data={k: str(v) for k, v in data.items()},
            token=token,
            android=messaging.AndroidConfig(
                priority="high",  # High priority for background delivery
                notification=messaging.AndroidNotification(
                    channel_id="ufobeep_beeps",
                    sound="default",
                    priority="high"  # Also set notification-level priority
                ),
                data={k: str(v) for k, v in data.items()}
            ),
            # Set message-level priority for FCM routing
            fcm_options=messaging.FCMOptions(
                analytics_label="proximity_alert"
            )
        )
        
        # Send message - use asyncio.to_thread with timeout
        response = await asyncio.wait_for(
            asyncio.to_thread(messaging.send, message),
            timeout=8.0
        )
        logger.info(f"Successfully sent message: {response}")
        return response
        
    except asyncio.TimeoutError:
        logger.error(f"FCM timeout after 8s for token")
        return None
    except Exception as e:
        logger.error(f"Failed to send FCM message: {e}")
        return None


def send_to_token_sync(token: str, data: dict, title="UFOBeep", body="New sighting nearby"):
    """Synchronous version for legacy compatibility"""
    import asyncio
    try:
        return asyncio.run(send_to_token(token, data, title, body))
    except Exception as e:
        logger.error(f"Failed to send FCM message sync: {e}")
        return None


# Global service instance
push_service = PushNotificationService()
