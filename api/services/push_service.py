import logging
from app.core.firebase_client import get_messaging

logger = logging.getLogger(__name__)

def send_to_token(token: str, data: dict, title="UFOBeep", body="New sighting nearby"):
    """Send push notification to a specific FCM token"""
    try:
        messaging = get_messaging()
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
    
    try:
        messaging = get_messaging()
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
        
        # Try send_multicast first, fallback to individual sends
        try:
            response = messaging.send_multicast(msg)
            logger.info(f"Successfully sent to {response.success_count}/{len(tokens)} devices")
            
            # Log failed tokens for debugging
            if response.failure_count > 0:
                for idx, result in enumerate(response.responses):
                    if not result.success:
                        logger.warning(f"Failed to send to token {idx}: {result.exception}")
            
            return response.responses
        except AttributeError:
            # Fallback for older Firebase SDK versions
            logger.warning("send_multicast not available, using individual sends")
            responses = []
            for token in tokens:
                try:
                    individual_msg = messaging.Message(
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
                    response = messaging.send(individual_msg)
                    responses.append(type('MockResponse', (), {'success': True, 'message_id': response})())
                    logger.info(f"Individual send successful: {response}")
                except Exception as e:
                    responses.append(type('MockResponse', (), {'success': False, 'exception': str(e)})())
                    logger.error(f"Individual send failed: {e}")
            
            success_count = sum(1 for r in responses if r.success)
            logger.info(f"Fallback individual sends: {success_count}/{len(tokens)} successful")
            return responses
        
    except Exception as e:
        logger.error(f"Failed to send FCM multicast: {e}")
        return []