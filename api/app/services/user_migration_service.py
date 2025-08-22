"""
User Migration Service - MP13-3
Handles migration of device_ids to usernames in alerts/sightings
"""

import asyncpg
import logging

logger = logging.getLogger(__name__)

class UserMigrationService:
    """Service to migrate device IDs to usernames in existing data"""
    
    def __init__(self, db_pool):
        self.db_pool = db_pool
    
    async def migrate_device_to_username(self, device_id: str, username: str) -> int:
        """
        Update all sightings with device_id to use username instead
        Returns number of records updated
        """
        async with self.db_pool.acquire() as conn:
            try:
                # Update sightings table
                result = await conn.execute("""
                    UPDATE sightings 
                    SET reporter_id = $1
                    WHERE reporter_id = $2
                """, username, device_id)
                
                # Extract number of updated rows from result
                updated_count = int(result.split()[-1]) if result.startswith('UPDATE') else 0
                
                logger.info(f"Migrated {updated_count} sightings from device_id '{device_id}' to username '{username}'")
                return updated_count
                
            except Exception as e:
                logger.error(f"Failed to migrate device_id '{device_id}' to username '{username}': {e}")
                return 0
    
    async def get_migration_status(self) -> dict:
        """Get status of device ID to username migration"""
        async with self.db_pool.acquire() as conn:
            # Count sightings with device_id format (contains hyphens/underscores)
            device_id_count = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings 
                WHERE reporter_id IS NOT NULL 
                AND (reporter_id LIKE '%-%' OR reporter_id LIKE '%_%')
                AND reporter_id NOT LIKE '%.%.%'
            """)
            
            # Count sightings with username format (dot.separated.numbers)
            username_count = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings 
                WHERE reporter_id IS NOT NULL 
                AND reporter_id LIKE '%.%.%'
            """)
            
            # Count null/empty reporter_ids
            null_count = await conn.fetchval("""
                SELECT COUNT(*) FROM sightings 
                WHERE reporter_id IS NULL OR reporter_id = ''
            """)
            
            total_sightings = await conn.fetchval("SELECT COUNT(*) FROM sightings")
            
            return {
                "total_sightings": total_sightings,
                "device_id_format": device_id_count,
                "username_format": username_count,
                "no_reporter_id": null_count,
                "migration_progress": f"{username_count}/{device_id_count + username_count}" if (device_id_count + username_count) > 0 else "0/0"
            }

# Global service instance
migration_service = None

async def get_migration_service(db_pool):
    """Get or create migration service instance"""
    global migration_service
    if migration_service is None:
        migration_service = UserMigrationService(db_pool)
    return migration_service