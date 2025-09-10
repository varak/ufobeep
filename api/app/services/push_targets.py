"""
Shared push target selection for all notification types.
Ensures consistent token selection logic across proximity alerts and comment notifications.
"""

from typing import Iterable, List
import asyncpg

ALL_TOKENS_SQL_FOR_USERS = """
SELECT DISTINCT d.push_token
FROM devices d
WHERE d.user_id = ANY($1::uuid[])
  AND d.is_active = TRUE
  AND d.push_enabled = TRUE
  AND d.push_token IS NOT NULL
  AND d.token_status = 'valid'
"""

async def tokens_for_users(pool: asyncpg.Pool, user_ids: Iterable[str]) -> List[str]:
    """
    Get valid FCM tokens for a list of user IDs.
    Returns ALL tokens for all devices belonging to these users.
    """
    ids = list(user_ids)
    if not ids:
        return []
    
    async with pool.acquire() as conn:
        rows = await conn.fetch(ALL_TOKENS_SQL_FOR_USERS, ids)
    
    return [r["push_token"] for r in rows]


TOKENS_FOR_USERS_EXCLUDE_DEVICE_SQL = """
SELECT DISTINCT d.push_token
FROM devices d
WHERE d.user_id = ANY($1::uuid[])
  AND d.is_active = TRUE
  AND d.push_enabled = TRUE
  AND d.push_token IS NOT NULL
  AND d.token_status = 'valid'
  AND ($2::text IS NULL OR d.device_id != $2::text)
"""


async def tokens_for_users_excluding_device(pool: asyncpg.Pool, user_ids: Iterable[str], exclude_device_id: str) -> List[str]:
    """
    Get valid FCM tokens for a list of user IDs, excluding a specific device.
    Returns ALL tokens for all devices belonging to these users, except the excluded device.
    """
    ids = list(user_ids)
    if not ids:
        return []
    
    async with pool.acquire() as conn:
        rows = await conn.fetch(TOKENS_FOR_USERS_EXCLUDE_DEVICE_SQL, ids, exclude_device_id)
    
    return [r["push_token"] for r in rows]