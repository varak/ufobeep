"""
Shared push target selection for all notification types.
Ensures consistent token selection logic across proximity alerts and comment notifications.
"""

from typing import Iterable, List
import asyncpg

LATEST_TOKEN_SQL_FOR_USERS = """
WITH ranked AS (
  SELECT
    d.user_id,
    d.push_token,
    d.updated_at,
    ROW_NUMBER() OVER (
      PARTITION BY d.user_id, d.push_token
      ORDER BY COALESCE(d.updated_at, NOW()) DESC
    ) AS rn
  FROM devices d
  WHERE d.user_id = ANY($1)
    AND d.is_active = TRUE
    AND d.push_enabled = TRUE
    AND d.push_token IS NOT NULL
    AND d.token_status = 'valid'
)
SELECT DISTINCT push_token
FROM ranked
WHERE rn = 1
"""

async def tokens_for_users(pool: asyncpg.Pool, user_ids: Iterable[str]) -> List[str]:
    """
    Get valid FCM tokens for a list of user IDs.
    Returns only the most recent token per user to avoid duplicates.
    """
    ids = list(user_ids)
    if not ids:
        return []
    
    async with pool.acquire() as conn:
        rows = await conn.fetch(LATEST_TOKEN_SQL_FOR_USERS, ids)
    
    return [r["push_token"] for r in rows]