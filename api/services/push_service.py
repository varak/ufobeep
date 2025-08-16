import firebase_admin
from firebase_admin import credentials, messaging
import os
import logging

logger = logging.getLogger(__name__)

_app = None

def init_fcm():
    """Initialize Firebase Admin SDK if not already initialized"""
    global _app
    if _app is None:
        creds_path = os.environ.get("GOOGLE_APPLICATION_CREDENTIALS")
        if not creds_path:
            logger.error("GOOGLE_APPLICATION_CREDENTIALS not set")
            return False
        
        if not os.path.exists(creds_path):
            logger.error(f"Firebase credentials file not found: {creds_path}")
            return False
            
        try:
            cred = credentials.Certificate(creds_path)
            _app = firebase_admin.initialize_app(cred)
            logger.info("Firebase Admin SDK initialized successfully")
            return True
        except Exception as e:
            logger.error(f"Failed to initialize Firebase Admin SDK: {e}")
            return False
    return True

def send_to_token(token: str, data: dict, title="UFOBeep", body="New sighting nearby"):
    """Send push notification to a specific FCM token"""
    if not init_fcm():
        logger.error("FCM not initialized, cannot send push")
        return None
        
    try:
        msg = messaging.Message(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in data.items()},
            token=token,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    channel_id='ufobeep_alerts',
                    sound='default'
                )
            ),
            apns=messaging.APNSConfig(
                headers={'apns-priority': '10'},
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='default', 
                        content_available=True,
                        alert=messaging.ApsAlert(title=title, body=body)
                    )
                )
            ),
        )
        
        response = messaging.send(msg)
        logger.info(f"Successfully sent message: {response}")
        return response
        
    except Exception as e:
        logger.error(f"Failed to send FCM message: {e}")
        return None

def send_to_tokens(tokens: list, data: dict, title="UFOBeep", body="New sighting nearby"):
    """Send push notification to multiple FCM tokens"""
    if not tokens:
        return []
        
    if not init_fcm():
        logger.error("FCM not initialized, cannot send push")
        return []
    
    try:
        msg = messaging.MulticastMessage(
            notification=messaging.Notification(title=title, body=body),
            data={k: str(v) for k, v in data.items()},
            tokens=tokens,
            android=messaging.AndroidConfig(
                priority='high',
                notification=messaging.AndroidNotification(
                    channel_id='ufobeep_alerts',
                    sound='default'
                )
            ),
            apns=messaging.APNSConfig(
                headers={'apns-priority': '10'},
                payload=messaging.APNSPayload(
                    aps=messaging.Aps(
                        sound='default', 
                        content_available=True,
                        alert=messaging.ApsAlert(title=title, body=body)
                    )
                )
            ),
        )
        
        response = messaging.send_multicast(msg)
        logger.info(f"Successfully sent to {response.success_count}/{len(tokens)} devices")
        
        # Log failed tokens for debugging
        if response.failure_count > 0:
            for idx, result in enumerate(response.responses):
                if not result.success:
                    logger.warning(f"Failed to send to token {idx}: {result.exception}")
        
        return response.responses
        
    except Exception as e:
        logger.error(f"Failed to send FCM multicast: {e}")
        return []