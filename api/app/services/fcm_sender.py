"""
Unified FCM sender using Firebase Admin SDK.
Single synchronous send mechanism for all notification types.
"""

from typing import Dict, List, Tuple
import firebase_admin
from firebase_admin import messaging

def _ensure_firebase():
    """Ensure Firebase app is initialized"""
    try:
        firebase_admin.get_app()
    except ValueError:
        firebase_admin.initialize_app()

def send_to_tokens(tokens: List[str],
                   title: str,
                   body: str,
                   data: Dict[str, str]) -> Tuple[int, List[str]]:
    """
    Synchronous FCM send to multiple tokens.
    
    Returns:
        Tuple of (success_count, tokens_to_invalidate)
    """
    if not tokens:
        return 0, []

    _ensure_firebase()

    success_count = 0
    to_invalidate: List[str] = []
    
    # Send to each token individually (compatible with all Firebase Admin SDK versions)
    for token in tokens:
        try:
            message = messaging.Message(
                notification=messaging.Notification(title=title, body=body),
                data={k: str(v) for k, v in (data or {}).items()},
                android=messaging.AndroidConfig(
                    priority='high',
                    notification=messaging.AndroidNotification(
                        sound='default',
                        channel_id='ufobeep_beeps'
                    )
                ),
                apns=messaging.APNSConfig(
                    payload=messaging.APNSPayload(
                        aps=messaging.Aps(
                            sound='default',
                            badge=1
                        )
                    )
                ),
                token=token
            )
            
            # This sends synchronously
            messaging.send(message)
            success_count += 1
            
        except Exception as e:
            error_msg = str(e)
            # Check if token is invalid
            if ("Requested entity was not found" in error_msg) or \
               ("registration-token-not-registered" in error_msg) or \
               ("UNREGISTERED" in error_msg):
                to_invalidate.append(token)

    return success_count, to_invalidate