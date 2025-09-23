"""
Admin User Management API
Provides admin access to user data for marketing and analytics
"""

from fastapi import APIRouter, Depends, HTTPException, Query
from typing import List, Optional, Dict, Any
import logging
from datetime import datetime, timedelta
import asyncpg
import uuid

from app.services.database_service import get_database_pool
from app.middleware.firebase_auth import RequiredAuth, FirebaseUser
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
async def get_db() -> asyncpg.Pool:
    """Get database connection pool from service"""
    return await get_database_pool()

@router.get("/", response_model=List[UserSummary])
async def get_users(
    pool: asyncpg.Pool = Depends(get_db),
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
    pool: asyncpg.Pool = Depends(get_db)
):
    """Delete user account completely with comprehensive cleanup (GDPR compliance)"""

    async with pool.acquire() as conn:
        # First check if user exists and get username
        user_record = await conn.fetchrow("""
            SELECT username FROM users WHERE id = $1
        """, user_id)

        if not user_record:
            raise HTTPException(status_code=404, detail="User not found")

        username = user_record['username']

        async with conn.transaction():
            # STEP 1: Delete all comments made by this user (anywhere on platform)
            comments_deleted = await conn.execute("""
                DELETE FROM comments WHERE user_id = $1
            """, user_id)
            comments_count = int(comments_deleted.split()[-1]) if comments_deleted.split()[-1].isdigit() else 0

            # STEP 2: Get all sightings by this user to delete their media and beeps
            sightings = await conn.fetch("""
                SELECT id::text FROM sightings WHERE reporter_id = $1
            """, user_id)

            # STEP 3: Delete all user's sightings using comprehensive cleanup
            total_deleted_files = 0
            total_freed_bytes = 0
            total_sightings_deleted = 0
            deleted_records = {"comments": comments_count}

            if sightings:
                # Import admin service for comprehensive sighting deletion
                from app.services.admin_service import AdminService
                admin_service = AdminService(pool)

                # Delete each sighting with full cleanup
                for sighting in sightings:
                    sighting_id = sighting['id']
                    try:
                        result = await admin_service.delete_sighting(sighting_id)
                        if result['success']:
                            total_sightings_deleted += 1
                            total_deleted_files += result['deleted_files']
                            total_freed_bytes += result['freed_bytes']

                            # Aggregate deleted records
                            for table, count in result['deleted_records'].items():
                                if isinstance(count, int):
                                    deleted_records[table] = deleted_records.get(table, 0) + count
                    except Exception as e:
                        logger.error(f"Error deleting sighting {sighting_id}: {e}")

            # STEP 4: Delete any remaining user data (follows, notifications, etc.)
            user_related_tables = [
                'follows',
                'alert_deliveries',
                'alert_notifications'
            ]

            for table in user_related_tables:
                try:
                    result = await conn.execute(f"""
                        DELETE FROM {table} WHERE user_id = $1
                    """, user_id)
                    count = int(result.split()[-1]) if result.split()[-1].isdigit() else 0
                    if count > 0:
                        deleted_records[table] = count
                except Exception as e:
                    logger.error(f"Error deleting from {table}: {e}")

            # STEP 5: Finally delete the user record itself
            user_deleted = await conn.execute("""
                DELETE FROM users WHERE id = $1
            """, user_id)
            user_deletion_success = "DELETE 1" in user_deleted

            if not user_deletion_success:
                raise HTTPException(status_code=500, detail="Failed to delete user record")

            logger.info(f"Admin: Comprehensively deleted user {username} ({user_id}) - "
                       f"{total_sightings_deleted} sightings, {comments_count} comments, "
                       f"{total_deleted_files} files, {round(total_freed_bytes / (1024 * 1024), 2)}MB freed")

            return {
                "success": True,
                "message": f"User {username} deleted successfully with comprehensive cleanup",
                "details": {
                    "user_id": user_id,
                    "username": username,
                    "sightings_deleted": total_sightings_deleted,
                    "comments_deleted": comments_count,
                    "files_deleted": total_deleted_files,
                    "storage_freed_mb": round(total_freed_bytes / (1024 * 1024), 2),
                    "deleted_records": deleted_records
                }
            }

@router.get("/{user_id}/export")
async def export_user_data(
    user_id: str,
    pool: asyncpg.Pool = Depends(get_db),
    format: str = Query("json", description="Export format: json or csv")
):
    """Export all user data for GDPR compliance"""

    async with pool.acquire() as conn:
        # Get user details
        user = await conn.fetchrow("""
            SELECT * FROM users WHERE id = $1
        """, user_id)

        if not user:
            raise HTTPException(status_code=404, detail="User not found")

        # Get user's sightings
        sightings = await conn.fetch("""
            SELECT * FROM sightings WHERE reporter_id = $1
        """, user_id)

        # Get user's comments
        comments = await conn.fetch("""
            SELECT c.*, s.title as sighting_title
            FROM comments c
            LEFT JOIN sightings s ON c.sighting_id = s.id
            WHERE c.user_id = $1
        """, user_id)

        # Get user's follows
        follows = await conn.fetch("""
            SELECT f.*, s.title as sighting_title
            FROM follows f
            LEFT JOIN sightings s ON f.sighting_id = s.id
            WHERE f.user_id = $1
        """, user_id)

        # Prepare export data
        export_data = {
            "user_profile": dict(user) if user else {},
            "sightings": [dict(s) for s in sightings],
            "comments": [dict(c) for c in comments],
            "follows": [dict(f) for f in follows],
            "export_timestamp": datetime.now().isoformat(),
            "total_records": {
                "sightings": len(sightings),
                "comments": len(comments),
                "follows": len(follows)
            }
        }

        if format == "csv":
            import csv
            import io

            # Create CSV with multiple sheets for different data types
            output = io.StringIO()

            # User profile
            writer = csv.writer(output)
            writer.writerow(["=== USER PROFILE ==="])
            if user:
                for key, value in user.items():
                    writer.writerow([key, str(value) if value is not None else ""])

            writer.writerow([])
            writer.writerow(["=== SIGHTINGS ==="])
            if sightings:
                # Headers
                headers = list(sightings[0].keys()) if sightings else []
                writer.writerow(headers)
                # Data
                for sighting in sightings:
                    writer.writerow([str(sighting[h]) if sighting[h] is not None else "" for h in headers])

            writer.writerow([])
            writer.writerow(["=== COMMENTS ==="])
            if comments:
                headers = list(comments[0].keys()) if comments else []
                writer.writerow(headers)
                for comment in comments:
                    writer.writerow([str(comment[h]) if comment[h] is not None else "" for h in headers])

            csv_data = output.getvalue()
            output.close()

            logger.info(f"Admin: Exported user data for {user['username']} as CSV")

            from fastapi.responses import Response
            return Response(
                content=csv_data,
                media_type="text/csv",
                headers={"Content-Disposition": f"attachment; filename=user_data_{user['username']}_{datetime.now().strftime('%Y%m%d')}.csv"}
            )

        else:  # JSON format
            logger.info(f"Admin: Exported user data for {user['username']} as JSON")
            return export_data