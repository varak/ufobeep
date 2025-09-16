"""
Application lifecycle management for UFOBeep API
Handles global database pool and notification queue worker
"""
import os
import asyncio
import logging
import contextlib
import asyncpg
from fastapi import FastAPI
from .services.comment_notifications import comment_notification_service

logger = logging.getLogger(__name__)

async def notification_consumer(app: FastAPI):
    """Background worker that processes notification queue using shared pool and event loop"""
    queue: asyncio.Queue = app.state.notify_queue
    db_pool: asyncpg.Pool = app.state.db_pool
    
    logger.info("🔔 Notification worker started")
    
    while True:
        try:
            # Get comment notification task from queue
            task_data = await queue.get()
            
            try:
                # Extract task parameters
                sighting_id = task_data["sighting_id"]
                commenter_user_id = task_data["commenter_user_id"] 
                commenter_username = task_data["commenter_username"]
                comment_body = task_data["comment_body"]
                
                logger.info(f"🔔 Processing queued notification for sighting {sighting_id}")
                
                # Process notification using shared database pool
                comment_id = task_data.get("comment_id")
                await comment_notification_service.notify_comment_posted(
                    sighting_id=sighting_id,
                    commenter_user_id=commenter_user_id,
                    commenter_username=commenter_username,
                    comment_body=comment_body,
                    comment_id=comment_id,
                    db_pool=db_pool
                )
                
                logger.info(f"🔔 Notification processed for sighting {sighting_id}")
                
            except Exception as e:
                logger.exception(f"Notification worker processing error: {e}")
            finally:
                # Mark task done since we successfully got it from queue
                queue.task_done()
                
        except asyncio.CancelledError:
            logger.info("🔔 Notification worker cancelled during shutdown")
            break

async def on_startup(app: FastAPI):
    """Initialize notification system using existing database pool"""
    logger.info("🚀 Starting notification system...")
    
    # Use existing database service instead of creating new pool
    from app.services.database_service import database_service
    app.state.db_pool = database_service.pool
    logger.info("✅ Using existing database pool for notifications")
    
    # Create notification queue
    app.state.notify_queue = asyncio.Queue(maxsize=1000)  # Prevent unbounded growth
    
    # Start background notification worker
    app.state.notify_task = asyncio.create_task(notification_consumer(app))
    
    logger.info("✅ Notification worker started")

async def on_shutdown(app: FastAPI):
    """Clean shutdown of notification worker"""
    logger.info("🛑 Shutting down notification system...")
    
    # Cancel notification worker
    if hasattr(app.state, 'notify_task'):
        app.state.notify_task.cancel()
        with contextlib.suppress(asyncio.CancelledError):
            await app.state.notify_task
        logger.info("✅ Notification worker stopped")
    
    # Database pool is managed by database_service, not closed here
    
    logger.info("✅ Notification system shutdown complete")