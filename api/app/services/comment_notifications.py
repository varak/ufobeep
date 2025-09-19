"""
Comment notification service for UFOBeep
Sends push notifications when users comment on followed alerts
"""

import logging
from typing import List, Dict, Any, Optional
from app.services.push_service import push_service, PushTarget, PushProvider
from app.services.database_service import get_database_pool

logger = logging.getLogger(__name__)


class CommentNotificationService:
    """Service for sending comment notifications to alert followers"""
    
    async def notify_comment_posted(
        self,
        sighting_id: str,
        commenter_user_id: str,
        commenter_username: str,
        comment_body: str,
        comment_id: str = None,
        db_pool=None
    ) -> Dict[str, Any]:
        """
        Send push notifications to all followers of a sighting when a comment is posted

        Args:
            sighting_id: The sighting that was commented on
            commenter_user_id: The user who posted the comment
            commenter_username: Username of the commenter
            comment_body: The comment text
            comment_id: The ID of the comment for deep linking

        Returns:
            Dict with notification results
        """
        
        try:
            logger.info(f"🔔 Processing comment notification for sighting {sighting_id} by {commenter_username}")
            
            # Get all followers of this sighting (excluding the commenter)
            followers = await self._get_sighting_followers(sighting_id, exclude_user_id=commenter_user_id, db_pool=db_pool)
            logger.info(f"🔔 Found {len(followers)} followers for sighting {sighting_id}")
            
            if not followers:
                logger.info(f"No followers to notify for sighting {sighting_id}")
                return {"total_notifications": 0, "success": True}
            
            # Get alert title for context
            alert_title = await self._get_sighting_title(sighting_id, db_pool=db_pool)
            
            # Get push targets for all followers
            targets = await self._get_push_targets_for_users([f['user_id'] for f in followers], db_pool=db_pool)
            logger.info(f"🔔 Found {len(targets)} push targets for notification")
            
            if not targets:
                logger.info(f"No valid push targets found for sighting {sighting_id} followers")
                return {"total_notifications": 0, "success": True}
            
            # Send push notifications
            result = await push_service.send_comment_notification(
                sighting_id=sighting_id,
                commenter_username=commenter_username,
                comment_body=comment_body,
                targets=targets,
                alert_title=alert_title,
                comment_id=comment_id
            )
            
            logger.info(
                f"Comment notification sent for sighting {sighting_id}: "
                f"{result['total_sent']} sent, {result['total_failed']} failed"
            )
            
            return {
                "total_notifications": result['total_sent'],
                "total_failed": result['total_failed'],
                "success": True,
                "details": result
            }
            
        except Exception as e:
            logger.error(f"Failed to send comment notifications for sighting {sighting_id}: {e}")
            import traceback
            logger.error(f"Full traceback: {traceback.format_exc()}")
            print(f"❌ Comment notification error: {e}")
            print(f"Full traceback: {traceback.format_exc()}")
            return {"total_notifications": 0, "success": False, "error": str(e)}
    
    async def _get_sighting_followers(self, sighting_id: str, exclude_user_id: str = None, db_pool=None) -> List[Dict[str, Any]]:
        """Get all users following a sighting"""
        
        pool = db_pool or await get_database_pool()
        async with pool.acquire() as conn:
            if exclude_user_id:
                rows = await conn.fetch(
                    "SELECT user_id FROM follows WHERE sighting_id = $1 AND user_id != $2",
                    sighting_id, exclude_user_id
                )
            else:
                rows = await conn.fetch(
                    "SELECT user_id FROM follows WHERE sighting_id = $1",
                    sighting_id
                )
        
        return [{"user_id": row["user_id"]} for row in rows]
    
    async def _get_sighting_title(self, sighting_id: str, db_pool=None) -> Optional[str]:
        """Get the title of a sighting for notification context"""
        
        pool = db_pool or await get_database_pool()
        async with pool.acquire() as conn:
            row = await conn.fetchrow(
                "SELECT title, description FROM sightings WHERE id = $1",
                sighting_id
            )
            
            if row:
                # Use title if available, otherwise truncate description
                if row["title"]:
                    return row["title"]
                elif row["description"]:
                    desc = row["description"][:50]
                    return f"{desc}..." if len(row["description"]) > 50 else desc
        
        return None
    
    async def _get_push_targets_for_users(self, user_ids: List[str], db_pool=None) -> List[PushTarget]:
        """Get active push targets for a list of user IDs"""
        
        if not user_ids:
            return []
        
        pool = db_pool or await get_database_pool()
        async with pool.acquire() as conn:
            # Get active devices with push tokens AND user language preferences
            rows = await conn.fetch("""
                SELECT
                    d.device_id,
                    d.push_token,
                    d.push_provider,
                    d.platform,
                    d.user_id,
                    d.alert_notifications,
                    d.chat_notifications,
                    d.system_notifications,
                    d.preferences,
                    COALESCE(d.preferences->>'language', 'en') as user_language
                FROM devices d
                WHERE d.user_id = ANY($1)
                AND d.is_active = true
                AND d.push_enabled = true
                AND d.push_token IS NOT NULL
                AND d.push_token != ''
            """, user_ids)
        
        targets = []
        for row in rows:
            # Convert push_provider string to enum
            try:
                provider = PushProvider(row["push_provider"])
            except (ValueError, TypeError):
                provider = PushProvider.FCM  # Default to FCM
            
            # Handle both old columns and new JSONB preferences
            prefs_json = row.get("preferences") or {}
            preferences = {
                "alert_notifications": prefs_json.get("alert_notifications", row.get("alert_notifications", True)),
                "chat_notifications": prefs_json.get("chat_notifications", row.get("chat_notifications", True)),
                "system_notifications": prefs_json.get("system_notifications", row.get("system_notifications", True))
            }
            
            target = PushTarget(
                device_id=row["device_id"],
                push_token=row["push_token"],
                provider=provider,
                platform=row["platform"],
                user_id=row["user_id"],
                preferences=preferences,
                language=row["user_language"]
            )
            targets.append(target)
        
        return targets


# Global service instance
comment_notification_service = CommentNotificationService()