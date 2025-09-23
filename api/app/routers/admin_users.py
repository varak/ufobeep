"""
Admin User Management API
Provides admin access to user data for marketing and analytics
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from sqlalchemy.orm import Session
from typing import List, Optional, Dict, Any
import logging
from datetime import datetime, timedelta
import asyncpg
import uuid

from app.services.database_service import get_database_pool
from app.middleware.firebase_auth import RequiredAuth, FirebaseUser
from app.database import get_db
from app.models import User
from pydantic import BaseModel

logger = logging.getLogger(__name__)

router = APIRouter(
    prefix="/admin/users",
    tags=["admin-users"]
)

# Pydantic models for API responses
class UserSummary(BaseModel):
    id: str
    username: str
    email: Optional[str]
    device_model: Optional[str]
    device_manufacturer: Optional[str]
    os_version: Optional[str]
    app_version: Optional[str]
    acquisition_source: Optional[str]
    marketing_consent: bool
    created_at: datetime
    last_active_at: Optional[datetime]

class UserDetail(UserSummary):
    device_language: Optional[str]
    timezone: Optional[str]
    screen_resolution: Optional[str]
    device_memory_gb: Optional[int]
    storage_available_gb: Optional[int]
    network_type: Optional[str]
    battery_optimization_enabled: Optional[bool]
    location_permission_type: Optional[str]
    google_id: Optional[str]
    social_profile_data: Optional[Dict]
    profile_photo_url: Optional[str]
    acquisition_campaign: Optional[str]
    first_login_at: Optional[datetime]

class UserStats(BaseModel):
    total_users: int
    active_users_7d: int
    active_users_30d: int
    marketing_consent_count: int
    top_devices: List[Dict[str, Any]]
    top_acquisition_sources: List[Dict[str, Any]]
    language_breakdown: List[Dict[str, Any]]

# Database dependency - now uses shared pool
async def get_db_pool() -> asyncpg.Pool:
    """Get database connection pool from service"""
    return await get_database_pool()

@router.get("/", response_model=List[UserSummary])
async def get_users(
    db: Session = Depends(get_db),
    skip: int = Query(0, description="Number of users to skip"),
    limit: int = Query(100, description="Number of users to return"),
    search: Optional[str] = Query(None, description="Search by username or email"),
    device_model: Optional[str] = Query(None, description="Filter by device model"),
    acquisition_source: Optional[str] = Query(None, description="Filter by acquisition source"),
    marketing_consent: Optional[bool] = Query(None, description="Filter by marketing consent")
):
    """Get paginated list of users with filtering"""

    query = db.query(User)

    # Apply filters
    if search:
        query = query.filter(
            (User.username.ilike(f"%{search}%")) |
            (User.email.ilike(f"%{search}%"))
        )

    if device_model:
        query = query.filter(User.device_model.ilike(f"%{device_model}%"))

    if acquisition_source:
        query = query.filter(User.acquisition_source == acquisition_source)

    if marketing_consent is not None:
        query = query.filter(User.marketing_consent == marketing_consent)

    # Order by most recent
    query = query.order_by(User.created_at.desc())

    # Apply pagination
    users = query.offset(skip).limit(limit).all()

    logger.info(f"Admin: Retrieved {len(users)} users (skip={skip}, limit={limit})")

    return [UserSummary(
        id=str(user.id),
        username=user.username,
        email=user.email,
        device_model=user.device_model,
        device_manufacturer=user.device_manufacturer,
        os_version=user.os_version,
        app_version=user.app_version,
        acquisition_source=user.acquisition_source,
        marketing_consent=user.marketing_consent or False,
        created_at=user.created_at,
        last_active_at=user.last_active_at
    ) for user in users]

@router.get("/{user_id}", response_model=UserDetail)
async def get_user_detail(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Get detailed information for a specific user"""

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    logger.info(f"Admin: Retrieved detailed info for user {user.username}")

    return UserDetail(
        id=str(user.id),
        username=user.username,
        email=user.email,
        device_model=user.device_model,
        device_manufacturer=user.device_manufacturer,
        os_version=user.os_version,
        app_version=user.app_version,
        device_language=user.device_language,
        timezone=user.timezone,
        screen_resolution=user.screen_resolution,
        device_memory_gb=user.device_memory_gb,
        storage_available_gb=user.storage_available_gb,
        network_type=user.network_type,
        battery_optimization_enabled=user.battery_optimization_enabled,
        location_permission_type=user.location_permission_type,
        google_id=user.google_id,
        social_profile_data=user.social_profile_data,
        profile_photo_url=user.profile_photo_url,
        acquisition_source=user.acquisition_source,
        acquisition_campaign=user.acquisition_campaign,
        marketing_consent=user.marketing_consent or False,
        created_at=user.created_at,
        first_login_at=user.first_login_at,
        last_active_at=user.last_active_at
    )

@router.get("/stats/overview", response_model=UserStats)
async def get_user_stats(db: Session = Depends(get_db)):
    """Get user statistics for admin dashboard"""

    from sqlalchemy import func, text

    # Total users
    total_users = db.query(func.count(User.id)).scalar()

    # Active users (7 and 30 days)
    week_ago = datetime.now() - timedelta(days=7)
    month_ago = datetime.now() - timedelta(days=30)

    active_7d = db.query(func.count(User.id)).filter(User.last_active_at >= week_ago).scalar()
    active_30d = db.query(func.count(User.id)).filter(User.last_active_at >= month_ago).scalar()

    # Marketing consent count
    marketing_count = db.query(func.count(User.id)).filter(User.marketing_consent == True).scalar()

    # Top devices
    top_devices = db.execute(text("""
        SELECT device_model, device_manufacturer, COUNT(*) as count
        FROM users
        WHERE device_model IS NOT NULL
        GROUP BY device_model, device_manufacturer
        ORDER BY count DESC
        LIMIT 10
    """)).fetchall()

    # Top acquisition sources
    top_sources = db.execute(text("""
        SELECT acquisition_source, COUNT(*) as count
        FROM users
        WHERE acquisition_source IS NOT NULL
        GROUP BY acquisition_source
        ORDER BY count DESC
    """)).fetchall()

    # Language breakdown
    languages = db.execute(text("""
        SELECT device_language, COUNT(*) as count
        FROM users
        WHERE device_language IS NOT NULL
        GROUP BY device_language
        ORDER BY count DESC
        LIMIT 15
    """)).fetchall()

    logger.info(f"Admin: Generated user statistics - {total_users} total users")

    return UserStats(
        total_users=total_users,
        active_users_7d=active_7d or 0,
        active_users_30d=active_30d or 0,
        marketing_consent_count=marketing_count or 0,
        top_devices=[
            {"model": row.device_model, "manufacturer": row.device_manufacturer, "count": row.count}
            for row in top_devices
        ],
        top_acquisition_sources=[
            {"source": row.acquisition_source, "count": row.count}
            for row in top_sources
        ],
        language_breakdown=[
            {"language": row.device_language, "count": row.count}
            for row in languages
        ]
    )

@router.get("/export/marketing-emails")
async def export_marketing_emails(
    db: Session = Depends(get_db),
    format: str = Query("csv", description="Export format: csv or json")
):
    """Export email addresses with marketing consent for campaigns"""

    from sqlalchemy import text

    # Get users with marketing consent
    marketing_users = db.execute(text("""
        SELECT u.email, u.username, u.created_at, u.device_language, u.acquisition_source
        FROM users u
        WHERE u.marketing_consent = TRUE
        AND u.email IS NOT NULL
        ORDER BY u.created_at DESC
    """)).fetchall()

    if format == "csv":
        import csv
        import io

        output = io.StringIO()
        writer = csv.writer(output)
        writer.writerow(["email", "username", "created_at", "language", "source"])

        for user in marketing_users:
            writer.writerow([
                user.email,
                user.username,
                user.created_at.isoformat() if user.created_at else "",
                user.device_language or "en",
                user.acquisition_source or "unknown"
            ])

        csv_data = output.getvalue()
        output.close()

        logger.info(f"Admin: Exported {len(marketing_users)} marketing emails as CSV")

        from fastapi.responses import Response
        return Response(
            content=csv_data,
            media_type="text/csv",
            headers={"Content-Disposition": f"attachment; filename=ufobeep_marketing_emails_{datetime.now().strftime('%Y%m%d')}.csv"}
        )

    else:  # JSON format
        export_data = [
            {
                "email": user.email,
                "username": user.username,
                "created_at": user.created_at.isoformat() if user.created_at else None,
                "language": user.device_language or "en",
                "source": user.acquisition_source or "unknown"
            }
            for user in marketing_users
        ]

        logger.info(f"Admin: Exported {len(marketing_users)} marketing emails as JSON")
        return {"users": export_data, "total": len(export_data)}

@router.post("/update-device-data")
async def update_user_device_data(
    user_id: str,
    device_data: Dict[str, Any],
    db: Session = Depends(get_db)
):
    """Update user device data (called from mobile app)"""

    user = db.query(User).filter(User.id == user_id).first()

    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    # Update device fields if provided
    update_fields = {}

    if "device_model" in device_data:
        update_fields["device_model"] = device_data["device_model"]
    if "device_manufacturer" in device_data:
        update_fields["device_manufacturer"] = device_data["device_manufacturer"]
    if "os_version" in device_data:
        update_fields["os_version"] = device_data["os_version"]
    if "app_version" in device_data:
        update_fields["app_version"] = device_data["app_version"]
    if "device_language" in device_data:
        update_fields["device_language"] = device_data["device_language"]
    if "timezone" in device_data:
        update_fields["timezone"] = device_data["timezone"]
    if "screen_resolution" in device_data:
        update_fields["screen_resolution"] = device_data["screen_resolution"]
    if "device_memory_gb" in device_data:
        update_fields["device_memory_gb"] = device_data["device_memory_gb"]
    if "storage_available_gb" in device_data:
        update_fields["storage_available_gb"] = device_data["storage_available_gb"]
    if "network_type" in device_data:
        update_fields["network_type"] = device_data["network_type"]
    if "battery_optimization_enabled" in device_data:
        update_fields["battery_optimization_enabled"] = device_data["battery_optimization_enabled"]
    if "location_permission_type" in device_data:
        update_fields["location_permission_type"] = device_data["location_permission_type"]

    # Update last active time
    update_fields["last_active_at"] = datetime.now()

    # Apply updates
    for field, value in update_fields.items():
        setattr(user, field, value)

    db.commit()

    logger.info(f"Updated device data for user {user.username}: {list(update_fields.keys())}")

    return {"success": True, "updated_fields": list(update_fields.keys())}

@router.delete("/{user_id}")
async def delete_user_account(
    user_id: str,
    db: Session = Depends(get_db)
):
    """Delete user account completely with comprehensive cleanup (GDPR compliance) - Uses comprehensive GDPR API"""

    # Get user to verify they exist and get username
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    username = user.username

    try:
        # Import and use the comprehensive GDPR deletion function
        from app.routers.user_data import delete_user_account as gdpr_delete

        # Call the comprehensive deletion function directly
        deletion_result = await gdpr_delete(current_user=user, db=db)

        # Transform the GDPR deletion result to match admin interface expectations
        admin_result = {
            "success": deletion_result.get("success", True),
            "message": f"User {username} deleted successfully with comprehensive GDPR cleanup",
            "details": {
                "user_id": user_id,
                "username": username,
                "sightings_deleted": deletion_result.get("deleted_data", {}).get("sightings", 0),
                "comments_deleted": deletion_result.get("deleted_data", {}).get("comments", 0),
                "files_deleted": deletion_result.get("deleted_data", {}).get("media_files", 0),
                "storage_freed_mb": 0,  # TODO: Calculate from media files if available
                "deleted_records": {
                    "sightings": deletion_result.get("deleted_data", {}).get("sightings", 0),
                    "comments": deletion_result.get("deleted_data", {}).get("comments", 0),
                    "devices": deletion_result.get("deleted_data", {}).get("devices", 0),
                    "follows": deletion_result.get("deleted_data", {}).get("follows", 0),
                    "alerts": deletion_result.get("deleted_data", {}).get("alerts", 0),
                    "magic_links": deletion_result.get("deleted_data", {}).get("magic_links", 0),
                    "marketing_records": deletion_result.get("deleted_data", {}).get("marketing_records", 0),
                    "analytics_events": deletion_result.get("deleted_data", {}).get("analytics_events", 0),
                    "media_files": deletion_result.get("deleted_data", {}).get("media_files", 0)
                }
            }
        }

        # Log comprehensive deletion details
        total_records = sum(admin_result["details"]["deleted_records"].values())
        logger.info(f"Admin: Comprehensive GDPR deletion for user {username} ({user_id}) - "
                   f"{admin_result['details']['sightings_deleted']} sightings, "
                   f"{admin_result['details']['comments_deleted']} comments, "
                   f"{admin_result['details']['files_deleted']} media files, "
                   f"{total_records} total records deleted")

        return admin_result

    except Exception as e:
        logger.error(f"Error in comprehensive GDPR deletion for user {username}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to delete user account comprehensively: {str(e)}")

@router.get("/{user_id}/export")
async def export_user_data(
    user_id: str,
    db: Session = Depends(get_db),
    format: str = Query("json", description="Export format: json or csv")
):
    """Export all user data for GDPR compliance - Uses comprehensive GDPR API"""

    # Get user to verify they exist
    user = db.query(User).filter(User.id == user_id).first()
    if not user:
        raise HTTPException(status_code=404, detail="User not found")

    try:
        # Import and use the comprehensive export function
        from app.routers.user_data import export_user_data as gdpr_export

        # Call the comprehensive export function directly
        export_data = await gdpr_export(current_user=user, db=db)

        if format == "csv":
            import csv
            import io

            # Create comprehensive CSV export
            output = io.StringIO()
            writer = csv.writer(output)

            # Export metadata
            writer.writerow(["=== EXPORT METADATA ==="])
            for key, value in export_data["export_metadata"].items():
                writer.writerow([key, str(value)])

            writer.writerow([])
            writer.writerow(["=== USER PROFILE ==="])
            for key, value in export_data["user_profile"].items():
                writer.writerow([key, str(value) if value is not None else ""])

            writer.writerow([])
            writer.writerow(["=== USER SETTINGS ==="])
            for key, value in export_data["user_settings"].items():
                writer.writerow([key, str(value) if value is not None else ""])

            writer.writerow([])
            writer.writerow(["=== DEVICE DATA ==="])
            for key, value in export_data["device_data"].items():
                writer.writerow([key, str(value) if value is not None else ""])

            writer.writerow([])
            writer.writerow(["=== BEEPS/SIGHTINGS ==="])
            if export_data["beeps"]:
                headers = list(export_data["beeps"][0].keys())
                writer.writerow(headers)
                for beep in export_data["beeps"]:
                    writer.writerow([str(beep[h]) if beep[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== COMMENTS ==="])
            if export_data["comments"]:
                headers = list(export_data["comments"][0].keys())
                writer.writerow(headers)
                for comment in export_data["comments"]:
                    writer.writerow([str(comment[h]) if comment[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== FOLLOWS ==="])
            if export_data["follows"]:
                headers = list(export_data["follows"][0].keys())
                writer.writerow(headers)
                for follow in export_data["follows"]:
                    writer.writerow([str(follow[h]) if follow[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== DEVICES ==="])
            if export_data["devices"]:
                headers = list(export_data["devices"][0].keys())
                writer.writerow(headers)
                for device in export_data["devices"]:
                    writer.writerow([str(device[h]) if device[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== MEDIA FILES ==="])
            if export_data["media_files"]:
                headers = list(export_data["media_files"][0].keys())
                writer.writerow(headers)
                for media in export_data["media_files"]:
                    writer.writerow([str(media[h]) if media[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== AUTHENTICATION HISTORY ==="])
            if export_data["authentication_history"]:
                headers = list(export_data["authentication_history"][0].keys())
                writer.writerow(headers)
                for auth in export_data["authentication_history"]:
                    writer.writerow([str(auth[h]) if auth[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== ALERTS ==="])
            if export_data["alerts"]:
                headers = list(export_data["alerts"][0].keys())
                writer.writerow(headers)
                for alert in export_data["alerts"]:
                    writer.writerow([str(alert[h]) if alert[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== ANALYTICS ==="])
            if export_data["analytics"]:
                headers = list(export_data["analytics"][0].keys())
                writer.writerow(headers)
                for event in export_data["analytics"]:
                    writer.writerow([str(event[h]) if event[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== EMAIL MARKETING ==="])
            if export_data["email_marketing"]:
                headers = list(export_data["email_marketing"][0].keys())
                writer.writerow(headers)
                for marketing in export_data["email_marketing"]:
                    writer.writerow([str(marketing[h]) if marketing[h] is not None else "" for h in headers])

            csv_data = output.getvalue()
            output.close()

            logger.info(f"Admin: Comprehensive GDPR export for {user.username} as CSV - {export_data['export_metadata']['total_beeps']} beeps, {export_data['export_metadata']['total_comments']} comments")

            from fastapi.responses import Response
            return Response(
                content=csv_data,
                media_type="text/csv",
                headers={"Content-Disposition": f"attachment; filename=comprehensive_user_data_{user.username}_{datetime.now().strftime('%Y%m%d')}.csv"}
            )

        else:  # JSON format
            logger.info(f"Admin: Comprehensive GDPR export for {user.username} as JSON - {export_data['export_metadata']['total_beeps']} beeps, {export_data['export_metadata']['total_comments']} comments")
            return export_data

    except Exception as e:
        logger.error(f"Error in comprehensive GDPR export for user {user.username}: {str(e)}")
        raise HTTPException(status_code=500, detail=f"Failed to export comprehensive user data: {str(e)}")