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

    # Firebase Admin Python supports Multicast
    message = messaging.MulticastMessage(
        tokens=tokens,
        notification=messaging.Notification(title=title, body=body),
        data={k: str(v) for k, v in (data or {}).items()},
    )

    response = messaging.send_multicast(message, dry_run=False)
    to_invalidate: List[str] = []

    # Classify known "token is bad" cases:
    for idx, res in enumerate(response.responses):
        if not res.success:
            code = getattr(res.exception, "code", "")
            msg = str(res.exception)
            if ("registration-token-not-registered" in code) or \
               ("UNREGISTERED" in code) or \
               ("Requested entity was not found" in msg):
                if idx < len(tokens):
                    to_invalidate.append(tokens[idx])

    return response.success_count, to_invalidate