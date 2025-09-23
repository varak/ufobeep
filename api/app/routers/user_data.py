"""
User Data Management API
Handles user data capture, GDPR compliance, and analytics
"""

from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional
import logging
from datetime import datetime

from app.database import get_db
from app.models import User
from app.core.auth import get_current_user
from pydantic import BaseModel

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/users",
    tags=["user-data"]
)

class DeviceDataUpdate(BaseModel):
    device_model: Optional[str] = None
    device_manufacturer: Optional[str] = None
    os_version: Optional[str] = None
    app_version: Optional[str] = None
    device_language: Optional[str] = None
    timezone: Optional[str] = None
    screen_resolution: Optional[str] = None
    device_memory_gb: Optional[int] = None
    storage_available_gb: Optional[int] = None
    network_type: Optional[str] = None
    battery_optimization_enabled: Optional[bool] = None
    location_permission_type: Optional[str] = None

class MarketingConsentUpdate(BaseModel):
    marketing_consent: bool
    consent_source: str = "manual"  # 'google_signin', 'magic_link', 'manual'

class UserDataExport(BaseModel):
    user_profile: Dict[str, Any]
    device_data: Dict[str, Any]
    beeps: List[Dict[str, Any]]
    comments: List[Dict[str, Any]]
    follows: List[Dict[str, Any]]
    analytics: List[Dict[str, Any]]

@router.put("/me/device-data")
async def update_device_data(
    device_data: DeviceDataUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update current user's device data"""

    update_fields = {}

    # Only update fields that are provided
    for field, value in device_data.dict(exclude_unset=True).items():
        if hasattr(current_user, field):
            setattr(current_user, field, value)
            update_fields[field] = value

    # Always update last active time when device data is updated
    current_user.last_active_at = datetime.now()
    update_fields["last_active_at"] = datetime.now()

    db.commit()

    logger.info(f"Updated device data for user {current_user.username}: {list(update_fields.keys())}")

    return {"success": True, "updated_fields": list(update_fields.keys())}

@router.put("/me/marketing-consent")
async def update_marketing_consent(
    consent_data: MarketingConsentUpdate,
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Update user's marketing email consent (GDPR compliance)"""

    current_user.marketing_consent = consent_data.marketing_consent

    # If consenting, add to email marketing table
    if consent_data.marketing_consent and current_user.email:
        from app.models import EmailMarketing

        # Check if already exists
        existing = db.query(EmailMarketing).filter(
            EmailMarketing.user_id == current_user.id
        ).first()

        if not existing:
            marketing_record = EmailMarketing(
                email=current_user.email,
                user_id=current_user.id,
                consent_source=consent_data.consent_source
            )
            db.add(marketing_record)

    db.commit()

    logger.info(f"Updated marketing consent for {current_user.username}: {consent_data.marketing_consent}")

    return {"success": True, "marketing_consent": consent_data.marketing_consent}

@router.get("/me/export")
async def export_user_data(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Export all user data (GDPR compliance)"""

    from app.models import Sighting, Comment, Follow, AnalyticsEvent

    # Get user's beeps/sightings
    beeps = db.query(Sighting).filter(Sighting.reporter_id == str(current_user.id)).all()

    # Get user's comments
    comments = db.query(Comment).filter(Comment.user_id == current_user.id).all()

    # Get user's follows
    follows = db.query(Follow).filter(Follow.user_id == current_user.id).all()

    # Get analytics events (if table exists)
    try:
        analytics = db.query(AnalyticsEvent).filter(AnalyticsEvent.user_id == current_user.id).all()
    except:
        analytics = []

    export_data = {
        "user_profile": {
            "id": str(current_user.id),
            "username": current_user.username,
            "email": current_user.email,
            "display_name": current_user.display_name,
            "bio": current_user.bio,
            "location": current_user.location,
            "created_at": current_user.created_at.isoformat() if current_user.created_at else None,
            "last_login_at": current_user.last_login_at.isoformat() if current_user.last_login_at else None,
            "marketing_consent": current_user.marketing_consent,
            "preferred_language": current_user.preferred_language
        },
        "device_data": {
            "device_model": current_user.device_model,
            "device_manufacturer": current_user.device_manufacturer,
            "os_version": current_user.os_version,
            "app_version": current_user.app_version,
            "device_language": current_user.device_language,
            "timezone": current_user.timezone,
            "screen_resolution": current_user.screen_resolution,
            "device_memory_gb": current_user.device_memory_gb,
            "storage_available_gb": current_user.storage_available_gb,
            "network_type": current_user.network_type,
            "location_permission_type": current_user.location_permission_type,
            "acquisition_source": current_user.acquisition_source,
            "acquisition_campaign": current_user.acquisition_campaign
        },
        "beeps": [
            {
                "id": str(beep.id),
                "title": beep.title,
                "description": beep.description,
                "created_at": beep.created_at.isoformat() if beep.created_at else None,
                "location": beep.location
            }
            for beep in beeps
        ],
        "comments": [
            {
                "id": str(comment.id),
                "content": comment.content,
                "created_at": comment.created_at.isoformat() if comment.created_at else None,
                "sighting_id": str(comment.sighting_id)
            }
            for comment in comments
        ],
        "follows": [
            {
                "sighting_id": str(follow.sighting_id),
                "created_at": follow.created_at.isoformat() if follow.created_at else None
            }
            for follow in follows
        ],
        "analytics": [
            {
                "event_type": event.event_type,
                "event_data": event.event_data,
                "created_at": event.created_at.isoformat() if event.created_at else None
            }
            for event in analytics
        ]
    }

    logger.info(f"Exported data for user {current_user.username}")

    return export_data

@router.delete("/me")
async def delete_user_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """Delete user account completely (GDPR compliance)"""

    username = current_user.username

    # Delete user (cascades to related data via foreign keys)
    db.delete(current_user)
    db.commit()

    logger.info(f"User {username} deleted their account")

    return {"success": True, "message": "Account deleted successfully"}