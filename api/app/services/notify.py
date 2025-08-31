"""
Unified notification service for all notification types.
Handles token selection, FCM sending, and automatic cleanup of invalid tokens.
"""

from typing import Dict, Iterable
import asyncio
import asyncpg

from .push_targets import tokens_for_users
from . import fcm_sender

INVALIDATE_SQL = """
UPDATE devices
   SET token_status = 'invalid',
       invalidated_at = NOW(),
       push_enabled = FALSE
 WHERE push_token = ANY($1::text[])
"""

PURGE_SQL = "DELETE FROM devices WHERE token_status = 'invalid'"

async def notify_users(pool: asyncpg.Pool,
                       user_ids: Iterable[str],
                       title: str,
                       body: str,
                       data: Dict[str, str]) -> int:
    """
    Send push notifications to a list of users.
    
    This is the SINGLE notification function used by all systems:
    - Comment notifications
    - Proximity alerts 
    - Any other push notifications
    
    Returns:
        Number of successful sends
    """
    tokens = await tokens_for_users(pool, user_ids)
    if not tokens:
        return 0

    # Offload the blocking network I/O to a thread
    success_count, to_invalidate = await asyncio.to_thread(
        fcm_sender.send_to_tokens, tokens, title, body, data
    )

    # Immediately clean up any invalid tokens
    if to_invalidate:
        async with pool.acquire() as conn:
            async with conn.transaction():
                await conn.execute(INVALIDATE_SQL, to_invalidate)
                # Hard purge right away so they are never seen again
                await conn.execute(PURGE_SQL)

    return success_count