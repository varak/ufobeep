"""
Push notification service for UFOBeep using FCM HTTP v1 API
Handles FCM push notifications with OAuth2 authentication
"""

import json
import logging
import aiohttp
import asyncio
from typing import List, Dict, Any, Optional
from datetime import datetime, timedelta
from enum import Enum
from dataclasses import dataclass
import os
from pathlib import Path

logger = logging.getLogger(__name__)

# Google auth for FCM v1
try:
    from google.auth.transport.requests import Request
    from google.oauth2 import service_account
    GOOGLE_AUTH_AVAILABLE = True
except ImportError:
    GOOGLE_AUTH_AVAILABLE = False
    logger.warning("google-auth not installed. Install with: pip install google-auth")
    Request = None
    service_account = None


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
    
    def to_fcm_v1_message(self, token: str) -> Dict[str, Any]:
        """Convert to FCM v1 format"""
        message = {
            "token": token,
            "notification": {
                "title": self.title,
                "body": self.body
            },
            "data": {str(k): str(v) for k, v in self.data.items()},
            "android": {
                "priority": "high",
                "notification": {
                    "click_action": self.click_action or "FLUTTER_NOTIFICATION_CLICK",
                    "sound": self.sound or "default"
                }
            },
            "apns": {
                "payload": {
                    "aps": {
                        "alert": {
                            "title": self.title,
                            "body": self.body
                        },
                        "sound": self.sound or "default"
                    }
                }
            }
        }
        
        if self.badge_count is not None:
            message["apns"]["payload"]["aps"]["badge"] = self.badge_count
            
        return {"message": message}


@dataclass  
class PushTarget:
    """Push notification target device"""
    device_id: str
    push_token: str
    provider: PushProvider
    platform: str
    user_id: str
    preferences: Dict[str, bool]


class PushNotificationServiceV1:
    """Service for sending push notifications via FCM v1 API"""
    
    def __init__(self):
        self.service_account_file = os.environ.get(
            'FCM_SERVICE_ACCOUNT_FILE',
            '/home/ufobeep/ufobeep/firebase-service-account.json'
        )
        self.fcm_v1_url = None
        self.credentials = None
        self.access_token = None
        self.token_expiry = None
        self._initialize_credentials()
        
    def _initialize_credentials(self):
        """Initialize Google OAuth2 credentials from service account"""
        try:
            if not GOOGLE_AUTH_AVAILABLE:
                logger.error("Google auth library not available")
                return
                
            if not Path(self.service_account_file).exists():
                logger.error(f"Service account file not found: {self.service_account_file}")
                return
                
            # Load service account credentials
            self.credentials = service_account.Credentials.from_service_account_file(
                self.service_account_file,
                scopes=['https://www.googleapis.com/auth/firebase.messaging']
            )
            
            # Get project ID from service account
            with open(self.service_account_file, 'r') as f:
                service_account_info = json.load(f)
                project_id = service_account_info.get('project_id')
                
            if project_id:
                self.fcm_v1_url = f"https://fcm.googleapis.com/v1/projects/{project_id}/messages:send"
                logger.info(f"FCM v1 initialized for project: {project_id}")
            else:
                logger.error("Project ID not found in service account file")
                
        except Exception as e:
            logger.error(f"Failed to initialize FCM v1 credentials: {e}")
            
    async def _get_access_token(self) -> Optional[str]:
        """Get or refresh OAuth2 access token"""
        try:
            if not self.credentials:
                return None
                
            # Check if token needs refresh
            if not self.access_token or not self.token_expiry or datetime.utcnow() >= self.token_expiry:
                # Refresh the token
                self.credentials.refresh(Request())
                self.access_token = self.credentials.token
                # Token typically expires in 1 hour, refresh 5 minutes early
                self.token_expiry = datetime.utcnow() + timedelta(minutes=55)
                logger.info("FCM access token refreshed")
                
            return self.access_token
            
        except Exception as e:
            logger.error(f"Failed to get FCM access token: {e}")
            return None
            
    async def send_notification(
        self,
        targets: List[PushTarget],
        payload: PushPayload,
        notification_type: NotificationType,
        collapse_key: Optional[str] = None
    ) -> Dict[str, Any]:
        """Send push notification to multiple targets using FCM v1"""
        
        results = {
            "total_sent": 0,
            "total_failed": 0,
            "fcm_results": [],
            "errors": []
        }
        
        if not self.fcm_v1_url:
            logger.error("FCM v1 not configured")
            results["errors"].append("FCM v1 not configured")
            return results
            
        # Get access token
        access_token = await self._get_access_token()
        if not access_token:
            logger.error("Failed to get FCM access token")
            results["errors"].append("Authentication failed")
            return results
            
        # Filter targets based on notification preferences
        filtered_targets = self._filter_targets_by_preferences(targets, notification_type)
        
        if not filtered_targets:
            logger.info("No valid targets after preference filtering")
            return results
            
        # Send to each target
        headers = {
            "Authorization": f"Bearer {access_token}",
            "Content-Type": "application/json"
        }
        
        async with aiohttp.ClientSession() as session:
            tasks = []
            for target in filtered_targets:
                # Only send to FCM tokens (not APNS directly)
                if target.provider == PushProvider.FCM:
                    task = self._send_single_fcm_v1(
                        session, target, payload, headers
                    )
                    tasks.append(task)
                    
            if tasks:
                fcm_results = await asyncio.gather(*tasks, return_exceptions=True)
                
                for result in fcm_results:
                    if isinstance(result, Exception):
                        results["fcm_results"].append({"success": False, "error": str(result)})
                        results["total_failed"] += 1
                    else:
                        results["fcm_results"].append(result)
                        if result.get("success"):
                            results["total_sent"] += 1
                        else:
                            results["total_failed"] += 1
                            
        logger.info(
            f"Push notifications sent: {results['total_sent']} success, "
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
        
    async def _send_single_fcm_v1(
        self,
        session: aiohttp.ClientSession,
        target: PushTarget,
        payload: PushPayload,
        headers: Dict[str, str]
    ) -> Dict[str, Any]:
        """Send single FCM v1 notification"""
        
        try:
            message = payload.to_fcm_v1_message(target.push_token)
            
            async with session.post(
                self.fcm_v1_url,
                headers=headers,
                json=message,
                timeout=aiohttp.ClientTimeout(total=30)
            ) as response:
                
                if response.status == 200:
                    data = await response.json()
                    logger.debug(f"FCM v1 success for device {target.device_id}")
                    return {
                        "success": True,
                        "device_id": target.device_id,
                        "message_id": data.get("name")
                    }
                else:
                    error_text = await response.text()
                    logger.error(f"FCM v1 failed for device {target.device_id}: {error_text}")
                    return {
                        "success": False,
                        "device_id": target.device_id,
                        "error": error_text,
                        "status_code": response.status
                    }
                    
        except asyncio.TimeoutError:
            logger.error(f"FCM v1 timeout for device {target.device_id}")
            return {
                "success": False,
                "device_id": target.device_id,
                "error": "Request timeout"
            }
        except Exception as e:
            logger.error(f"FCM v1 error for device {target.device_id}: {e}")
            return {
                "success": False,
                "device_id": target.device_id,
                "error": str(e)
            }
            
    async def send_sighting_alert(
        self,
        sighting_id: str,
        title: str,
        body: str,
        targets: List[PushTarget],
        distance_km: float,
        additional_data: Optional[Dict[str, Any]] = None
    ) -> Dict[str, Any]:
        """Send sighting alert notification to nearby users"""
        
        # Prepare notification data
        data = {
            "type": "sighting_alert",
            "sighting_id": sighting_id,
            "distance_km": str(distance_km),
            "timestamp": datetime.utcnow().isoformat(),
            "click_action": "FLUTTER_NOTIFICATION_CLICK"
        }
        
        if additional_data:
            data.update(additional_data)
            
        payload = PushPayload(
            title=title,
            body=body,
            data=data,
            click_action="FLUTTER_NOTIFICATION_CLICK"
        )
        
        return await self.send_notification(
            targets=targets,
            payload=payload,
            notification_type=NotificationType.ALERT,
            collapse_key=f"sighting_{sighting_id}"
        )


# Global service instance  
push_service = PushNotificationServiceV1()


# Test function
async def test_fcm_v1():
    """Test FCM v1 push notification"""
    
    test_target = PushTarget(
        device_id="test_device",
        push_token="YOUR_TEST_FCM_TOKEN_HERE",
        provider=PushProvider.FCM,
        platform="android",
        user_id="test_user",
        preferences={
            "alert_notifications": True,
            "chat_notifications": True,
            "system_notifications": True
        }
    )
    
    result = await push_service.send_sighting_alert(
        sighting_id="test_001",
        title="🛸 UFO Sighting Nearby",
        body="Triangle formation reported 2.5km away. Tap to view details.",
        targets=[test_target],
        distance_km=2.5,
        additional_data={
            "shape": "triangle",
            "confidence_score": "0.85"
        }
    )
    
    print(f"Test result: {result}")
    return result


if __name__ == "__main__":
    logging.basicConfig(level=logging.INFO)
    asyncio.run(test_fcm_v1())