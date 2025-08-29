"""
Firebase Admin SDK Singleton Client

Provides idempotent Firebase initialization to prevent
"The default Firebase app already exists" errors.
"""
from __future__ import annotations
import os
import json
from typing import Optional
import firebase_admin
from firebase_admin import credentials, messaging

_APP: Optional[firebase_admin.App] = None

def init_firebase() -> firebase_admin.App:
    """
    Idempotent initializer. Safe to call many times within a process.
    Each *process* (gunicorn worker) still gets its own app, which is correct.
    """
    global _APP
    if _APP is not None:
        return _APP

    # Try to reuse default app if someone else already created it
    try:
        _APP = firebase_admin.get_app()
        print("[firebase] Using existing Firebase app")
        return _APP
    except ValueError:
        pass

    # Prefer GOOGLE_APPLICATION_CREDENTIALS; fall back to inline JSON env if provided
    gac_path = os.getenv("GOOGLE_APPLICATION_CREDENTIALS")
    inline_json = os.getenv("FIREBASE_CREDENTIALS_JSON")  # optional

    if gac_path and os.path.exists(gac_path):
        print(f"[firebase] Using credentials from {gac_path}")
        cred = credentials.Certificate(gac_path)
    elif inline_json:
        print("[firebase] Using inline credentials from environment")
        cred = credentials.Certificate(json.loads(inline_json))
    else:
        # Last resort: default creds if running on GCP; otherwise this will raise.
        print("[firebase] Using default application credentials")
        cred = credentials.ApplicationDefault()

    _APP = firebase_admin.initialize_app(cred, {
        "projectId": os.getenv("FIREBASE_PROJECT_ID", "ufobeep-app"),
    })
    print(f"[firebase] Initialized Firebase app successfully")
    return _APP

def get_messaging() -> messaging:
    """Always returns a working messaging module (forces init if needed)."""
    init_firebase()
    return messaging