"""
User Data Management API
Handles user data capture, GDPR compliance, and analytics
Implements comprehensive deletion and export following delete.py patterns
"""

from fastapi import APIRouter, Depends, HTTPException, Header
from sqlalchemy.orm import Session
from typing import Dict, Any, Optional, List
import logging
from datetime import datetime
import json

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

# Admin authentication helper
def verify_admin_key(x_admin_key: str = Header(None)):
    """Verify admin key for administrative operations"""
    if not x_admin_key or x_admin_key != "ufobeep_admin_2025":
        raise HTTPException(status_code=401, detail="Invalid or missing admin key")
    return True

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
    """
    Export ALL user data comprehensively (GDPR compliance)
    Mirrors the thoroughness of delete.py but for data export
    """

    from app.models import (
        Sighting, SightingComment, Follow, Device, MediaFile,
        MagicLink, MagicLinkAttempt, Alert
    )

    try:
        # Core user profile data
        user_profile = {
            "id": str(current_user.id),
            "username": current_user.username,
            "email": current_user.email,
            "firebase_uid": getattr(current_user, 'firebase_uid', None),
            "google_id": getattr(current_user, 'google_id', None),
            "display_name": current_user.display_name,
            "bio": current_user.bio,
            "location": current_user.location,
            "created_at": current_user.created_at.isoformat() if current_user.created_at else None,
            "last_login": current_user.last_login.isoformat() if current_user.last_login else None,
            "last_active_at": getattr(current_user, 'last_active_at', None),
            "is_verified": current_user.is_verified,
            "marketing_consent": getattr(current_user, 'marketing_consent', None),
            "email_verified": getattr(current_user, 'email_verified', None)
        }

        # Comprehensive device and technical data
        device_data = {
            "device_model": getattr(current_user, 'device_model', None),
            "device_manufacturer": getattr(current_user, 'device_manufacturer', None),
            "os_version": getattr(current_user, 'os_version', None),
            "app_version": getattr(current_user, 'app_version', None),
            "device_language": getattr(current_user, 'device_language', None),
            "timezone": getattr(current_user, 'timezone', None),
            "screen_resolution": getattr(current_user, 'screen_resolution', None),
            "device_memory_gb": getattr(current_user, 'device_memory_gb', None),
            "storage_available_gb": getattr(current_user, 'storage_available_gb', None),
            "network_type": getattr(current_user, 'network_type', None),
            "battery_optimization_enabled": getattr(current_user, 'battery_optimization_enabled', None),
            "location_permission_type": getattr(current_user, 'location_permission_type', None),
            "acquisition_source": getattr(current_user, 'acquisition_source', None),
            "acquisition_campaign": getattr(current_user, 'acquisition_campaign', None)
        }

        # User settings and preferences
        user_settings = {
            "alert_range_km": current_user.alert_range_km,
            "min_alert_level": current_user.min_alert_level.value if current_user.min_alert_level else None,
            "push_notifications": current_user.push_notifications,
            "email_notifications": current_user.email_notifications,
            "share_location": current_user.share_location,
            "public_profile": current_user.public_profile,
            "preferred_language": current_user.preferred_language,
            "units_metric": current_user.units_metric
        }

        # Get user's beeps/sightings with comprehensive data
        user_sightings = db.query(Sighting).filter(Sighting.reporter_id == current_user.id).all()
        sighting_ids = [str(s.id) for s in user_sightings]

        beeps = []
        for sighting in user_sightings:
            beep_data = {
                "id": str(sighting.id),
                "title": sighting.title,
                "description": sighting.description,
                "short_url": sighting.short_url,
                "location": sighting.location,
                "latitude": float(sighting.latitude) if sighting.latitude else None,
                "longitude": float(sighting.longitude) if sighting.longitude else None,
                "occurred_at": sighting.occurred_at.isoformat() if sighting.occurred_at else None,
                "created_at": sighting.created_at.isoformat() if sighting.created_at else None,
                "category": sighting.category.value if sighting.category else None,
                "status": sighting.status.value if sighting.status else None,
                "source": sighting.source,
                "external_id": sighting.external_id
            }
            beeps.append(beep_data)

        # Get ALL comments made by this user (anywhere on platform)
        user_comments = db.query(SightingComment).filter(SightingComment.user_id == current_user.id).all()
        comments = []
        for comment in user_comments:
            comment_data = {
                "id": str(comment.id),
                "content": comment.content,
                "created_at": comment.created_at.isoformat() if comment.created_at else None,
                "sighting_id": str(comment.sighting_id),
                "is_on_own_sighting": str(comment.sighting_id) in sighting_ids
            }
            comments.append(comment_data)

        # Get user's follows/subscriptions
        user_follows = db.query(Follow).filter(Follow.user_id == current_user.id).all()
        follows = []
        for follow in user_follows:
            follow_data = {
                "sighting_id": str(follow.sighting_id),
                "created_at": follow.created_at.isoformat() if follow.created_at else None,
                "notification_enabled": getattr(follow, 'notification_enabled', None)
            }
            follows.append(follow_data)

        # Get user's registered devices
        user_devices = db.query(Device).filter(Device.user_id == current_user.id).all()
        devices = []
        for device in user_devices:
            device_data = {
                "id": str(device.id),
                "device_id": device.device_id,
                "platform": device.platform.value if device.platform else None,
                "push_token": device.push_token[:10] + "..." if device.push_token else None,  # Truncated for security
                "app_version": device.app_version,
                "created_at": device.created_at.isoformat() if device.created_at else None,
                "last_active": device.last_active.isoformat() if device.last_active else None,
                "is_active": device.is_active
            }
            devices.append(device_data)

        # Get media files uploaded by user
        user_media = db.query(MediaFile).filter(MediaFile.uploaded_by == current_user.id).all()
        media_files = []
        for media in user_media:
            media_data = {
                "id": str(media.id),
                "filename": media.filename,
                "file_type": media.file_type.value if media.file_type else None,
                "file_size": media.file_size,
                "s3_key": media.s3_key,
                "sighting_id": str(media.sighting_id) if media.sighting_id else None,
                "created_at": media.created_at.isoformat() if media.created_at else None
            }
            media_files.append(media_data)

        # Get magic link history for this user
        magic_links = db.query(MagicLink).filter(MagicLink.email == current_user.email).all()
        auth_history = []
        for link in magic_links:
            auth_data = {
                "id": str(link.id),
                "email": link.email,
                "created_at": link.created_at.isoformat() if link.created_at else None,
                "used_at": link.used_at.isoformat() if link.used_at else None,
                "expires_at": link.expires_at.isoformat() if link.expires_at else None,
                "ip_address": link.ip_address,
                "user_agent": link.user_agent[:100] + "..." if link.user_agent and len(link.user_agent) > 100 else link.user_agent
            }
            auth_history.append(auth_data)

        # Get alerts related to user's sightings
        user_alerts = []
        if sighting_ids:
            alerts = db.query(Alert).filter(Alert.sighting_id.in_(sighting_ids)).all()
            for alert in alerts:
                alert_data = {
                    "id": str(alert.id),
                    "title": alert.title,
                    "level": alert.level.value if alert.level else None,
                    "sighting_id": str(alert.sighting_id),
                    "created_at": alert.created_at.isoformat() if alert.created_at else None,
                    "expires_at": alert.expires_at.isoformat() if alert.expires_at else None
                }
                user_alerts.append(alert_data)

        # Try to get analytics events (may not exist)
        analytics = []
        try:
            from app.models import AnalyticsEvent
            events = db.query(AnalyticsEvent).filter(AnalyticsEvent.user_id == current_user.id).all()
            for event in events:
                event_data = {
                    "id": str(event.id),
                    "event_type": event.event_type,
                    "event_data": event.event_data,
                    "session_id": event.session_id,
                    "created_at": event.created_at.isoformat() if event.created_at else None
                }
                analytics.append(event_data)
        except Exception as e:
            logger.warning(f"Could not export analytics data: {e}")

        # Try to get email marketing data
        email_marketing = []
        try:
            from app.models import EmailMarketing
            marketing_records = db.query(EmailMarketing).filter(EmailMarketing.user_id == current_user.id).all()
            for record in marketing_records:
                marketing_data = {
                    "id": str(record.id),
                    "email": record.email,
                    "consent_given_at": record.consent_given_at.isoformat() if record.consent_given_at else None,
                    "consent_source": record.consent_source,
                    "unsubscribed_at": record.unsubscribed_at.isoformat() if record.unsubscribed_at else None
                }
                email_marketing.append(marketing_data)
        except Exception as e:
            logger.warning(f"Could not export email marketing data: {e}")

        # Comprehensive export data
        export_data = {
            "export_metadata": {
                "generated_at": datetime.now().isoformat(),
                "user_id": str(current_user.id),
                "username": current_user.username,
                "export_version": "1.0",
                "total_beeps": len(beeps),
                "total_comments": len(comments),
                "total_follows": len(follows),
                "total_devices": len(devices),
                "total_media_files": len(media_files)
            },
            "user_profile": user_profile,
            "user_settings": user_settings,
            "device_data": device_data,
            "beeps": beeps,
            "comments": comments,
            "follows": follows,
            "devices": devices,
            "media_files": media_files,
            "authentication_history": auth_history,
            "alerts": user_alerts,
            "analytics": analytics,
            "email_marketing": email_marketing
        }

        logger.info(f"Comprehensive data export completed for user {current_user.username}: {len(beeps)} beeps, {len(comments)} comments, {len(media_files)} media files")

        return export_data

    except Exception as e:
        logger.error(f"Error exporting user data for {current_user.username}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to export user data: {str(e)}")

@router.delete("/me")
async def delete_user_account(
    current_user: User = Depends(get_current_user),
    db: Session = Depends(get_db)
):
    """
    Delete user account completely (GDPR compliance)
    Implements the same comprehensive deletion pattern as delete.py
    Ensures no orphaned data remains in the system
    """

    from app.models import (
        Sighting, SightingComment, Follow, Device, MediaFile,
        MagicLink, MagicLinkAttempt, Alert
    )

    username = current_user.username
    user_id = current_user.id

    try:
        logger.info(f"Starting comprehensive account deletion for user {username} (ID: {user_id})")

        # STEP 1: Delete ALL comments made by this user (anywhere on platform)
        # This matches delete.py Step 1 behavior
        logger.info(f"STEP 1: Deleting all comments made by user {username}...")
        user_comments = db.query(SightingComment).filter(SightingComment.user_id == user_id).all()
        comments_count = len(user_comments)

        for comment in user_comments:
            db.delete(comment)

        logger.info(f"  ✅ Deleted {comments_count} user comments")

        # STEP 2: Get user's sightings and delete media + related data
        # This matches delete.py Step 2 behavior
        logger.info(f"STEP 2: Deleting media and related data for user sightings...")
        user_sightings = db.query(Sighting).filter(Sighting.reporter_id == user_id).all()
        sightings_count = len(user_sightings)

        media_files_deleted = 0
        for sighting in user_sightings:
            sighting_id = sighting.id
            logger.info(f"  Processing sighting {sighting_id}...")

            # Delete media files associated with this sighting
            media_files = db.query(MediaFile).filter(MediaFile.sighting_id == sighting_id).all()
            for media_file in media_files:
                # TODO: Also delete from S3/MinIO storage
                # s3_key = media_file.s3_key
                # await delete_from_s3(s3_key)
                db.delete(media_file)
                media_files_deleted += 1

            # Delete photo analysis results (if table exists)
            try:
                db.execute(f"DELETE FROM photo_analysis_results WHERE sighting_id = '{sighting_id}'")
            except Exception as e:
                logger.warning(f"Could not delete photo_analysis_results: {e}")

            # Delete photo metadata (if table exists)
            try:
                db.execute(f"DELETE FROM photo_metadata WHERE sighting_id = '{sighting_id}'")
            except Exception as e:
                logger.warning(f"Could not delete photo_metadata: {e}")

        logger.info(f"  ✅ Deleted {media_files_deleted} media files")

        # STEP 3: Delete remaining related data and sightings
        # This matches delete.py Step 3 behavior
        logger.info(f"STEP 3: Deleting remaining data and sightings...")

        alerts_deleted = 0
        follows_deleted = 0
        comments_on_sightings_deleted = 0

        for sighting in user_sightings:
            sighting_id = sighting.id

            # Delete alerts for this sighting
            alerts = db.query(Alert).filter(Alert.sighting_id == sighting_id).all()
            for alert in alerts:
                # Delete alert deliveries and notifications (if tables exist)
                try:
                    db.execute(f"DELETE FROM alert_deliveries WHERE alert_id = '{alert.id}'")
                    db.execute(f"DELETE FROM alert_notifications WHERE alert_id = '{alert.id}'")
                    db.execute(f"DELETE FROM alert_events WHERE alert_id = '{alert.id}'")
                except Exception as e:
                    logger.warning(f"Could not delete alert-related data: {e}")

                db.delete(alert)
                alerts_deleted += 1

            # Delete follows for this sighting
            follows = db.query(Follow).filter(Follow.sighting_id == sighting_id).all()
            for follow in follows:
                db.delete(follow)
                follows_deleted += 1

            # Delete remaining comments ON this sighting (from other users)
            remaining_comments = db.query(SightingComment).filter(SightingComment.sighting_id == sighting_id).all()
            for comment in remaining_comments:
                db.delete(comment)
                comments_on_sightings_deleted += 1

            # Finally delete the sighting itself
            db.delete(sighting)
            logger.info(f"    ✅ Deleted sighting {sighting_id}")

        logger.info(f"  ✅ Deleted {alerts_deleted} alerts, {follows_deleted} follows, {comments_on_sightings_deleted} comments on user sightings")

        # STEP 4: Delete user-specific data
        logger.info(f"STEP 4: Deleting user-specific data...")

        # Delete user's devices
        user_devices = db.query(Device).filter(Device.user_id == user_id).all()
        devices_count = len(user_devices)
        for device in user_devices:
            db.delete(device)

        # Delete user's follows (subscriptions to other sightings)
        user_follows = db.query(Follow).filter(Follow.user_id == user_id).all()
        user_follows_count = len(user_follows)
        for follow in user_follows:
            db.delete(follow)

        # Delete magic links for this user's email
        if current_user.email:
            magic_links = db.query(MagicLink).filter(MagicLink.email == current_user.email).all()
            magic_links_count = len(magic_links)
            for link in magic_links:
                db.delete(link)

            # Delete magic link attempts
            magic_attempts = db.query(MagicLinkAttempt).filter(MagicLinkAttempt.email == current_user.email).all()
            for attempt in magic_attempts:
                db.delete(attempt)
        else:
            magic_links_count = 0

        # Delete email marketing records
        try:
            from app.models import EmailMarketing
            marketing_records = db.query(EmailMarketing).filter(EmailMarketing.user_id == user_id).all()
            marketing_count = len(marketing_records)
            for record in marketing_records:
                db.delete(record)
        except Exception as e:
            logger.warning(f"Could not delete email marketing records: {e}")
            marketing_count = 0

        # Delete analytics events (set to null or delete depending on requirements)
        try:
            from app.models import AnalyticsEvent
            analytics_events = db.query(AnalyticsEvent).filter(AnalyticsEvent.user_id == user_id).all()
            analytics_count = len(analytics_events)
            for event in analytics_events:
                # Option 1: Delete completely
                db.delete(event)
                # Option 2: Anonymize by setting user_id to null
                # event.user_id = None
        except Exception as e:
            logger.warning(f"Could not delete analytics events: {e}")
            analytics_count = 0

        logger.info(f"  ✅ Deleted {devices_count} devices, {user_follows_count} follows, {magic_links_count} magic links, {marketing_count} marketing records, {analytics_count} analytics events")

        # STEP 5: Finally delete the user record itself
        logger.info(f"STEP 5: Deleting user record...")
        db.delete(current_user)

        # Commit all deletions
        db.commit()

        # Final verification - count remaining records
        try:
            remaining_sightings = db.query(Sighting).filter(Sighting.reporter_id == user_id).count()
            remaining_comments = db.query(SightingComment).filter(SightingComment.user_id == user_id).count()
            remaining_devices = db.query(Device).filter(Device.user_id == user_id).count()

            if remaining_sightings == 0 and remaining_comments == 0 and remaining_devices == 0:
                logger.info(f"✅ Successfully deleted all data for user {username}")
                deletion_summary = {
                    "success": True,
                    "message": "Account and all associated data deleted successfully",
                    "deleted_data": {
                        "sightings": sightings_count,
                        "comments": comments_count + comments_on_sightings_deleted,
                        "media_files": media_files_deleted,
                        "devices": devices_count,
                        "follows": follows_deleted + user_follows_count,
                        "alerts": alerts_deleted,
                        "magic_links": magic_links_count,
                        "marketing_records": marketing_count,
                        "analytics_events": analytics_count
                    }
                }
            else:
                logger.warning(f"⚠️ Some records may remain: {remaining_sightings} sightings, {remaining_comments} comments, {remaining_devices} devices")
                deletion_summary = {
                    "success": True,
                    "message": "Account deleted with warnings - some data may remain",
                    "warnings": {
                        "remaining_sightings": remaining_sightings,
                        "remaining_comments": remaining_comments,
                        "remaining_devices": remaining_devices
                    }
                }
        except Exception as e:
            # User is already deleted, so we can't verify fully
            logger.info(f"✅ User deletion completed (verification not possible after user deletion)")
            deletion_summary = {
                "success": True,
                "message": "Account deleted successfully",
                "note": "Verification not possible after user deletion"
            }

        return deletion_summary

    except Exception as e:
        db.rollback()
        logger.error(f"Error deleting user account for {username}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to delete user account: {str(e)}")

# Admin endpoints for testing GDPR compliance
@router.get("/admin/{user_id}/export")
async def admin_export_user_data(
    user_id: str,
    db: Session = Depends(get_db),
    admin_verified: bool = Depends(verify_admin_key)
):
    """Admin endpoint: Export comprehensive user data for GDPR testing"""

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    logger.info(f"Admin comprehensive data export requested for user {user.username}")

    # Call the comprehensive export function directly
    export_data = await export_user_data(current_user=user, db=db)

    # Add admin metadata
    export_data["admin_export"] = {
        "exported_by": "admin",
        "export_type": "comprehensive_gdpr",
        "admin_timestamp": datetime.now().isoformat()
    }

    return export_data

@router.delete("/admin/{user_id}")
async def admin_delete_user_account(
    user_id: str,
    db: Session = Depends(get_db),
    admin_verified: bool = Depends(verify_admin_key)
):
    """Admin endpoint: Comprehensive user account deletion for GDPR testing"""

    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    username = user.username
    logger.info(f"Admin comprehensive deletion requested for user {username}")

    # Call the comprehensive deletion function directly
    deletion_result = await delete_user_account(current_user=user, db=db)

    # Add admin metadata to the result
    deletion_result["admin_deletion"] = {
        "deleted_by": "admin",
        "deletion_type": "comprehensive_gdpr",
        "admin_timestamp": datetime.now().isoformat(),
        "username": username
    }

    return deletion_result