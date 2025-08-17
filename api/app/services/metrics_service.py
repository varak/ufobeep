"""
Simple engagement tracking for UFOBeep

Tracks basic user interactions:
- Alert delivery (sent/delivered/failed)
- Quick action responses (see it too, checked, missed)
- Basic engagement metrics
"""

import asyncio
import asyncpg
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from enum import Enum
from uuid import UUID, uuid4

class EngagementType(str, Enum):
    ALERT_SENT = "alert_sent"
    ALERT_DELIVERED = "alert_delivered"
    QUICK_ACTION_SEE_IT_TOO = "quick_action_see_it_too"
    QUICK_ACTION_DONT_SEE = "quick_action_dont_see"
    QUICK_ACTION_MISSED = "quick_action_missed"
    BEEP_SUBMITTED = "beep_submitted"

@dataclass
class EngagementEvent:
    """Simple engagement event"""
    device_id: str
    event_type: EngagementType
    sighting_id: Optional[UUID] = None
    timestamp: Optional[datetime] = None
    
class MetricsService:
    """Simple engagement tracking service"""
    
    def __init__(self, db_pool: asyncpg.Pool):
        self.db_pool = db_pool
        
    async def initialize(self):
        """Initialize single engagement table"""
        await self._create_engagement_table()
        
    async def _create_engagement_table(self):
        """Create simple engagement tracking table"""
        async with self.db_pool.acquire() as conn:
            # Single engagement table with user_id for future user system
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS user_engagement (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    device_id VARCHAR(255) NOT NULL,
                    user_id UUID,
                    event_type VARCHAR(50) NOT NULL,
                    sighting_id UUID,
                    timestamp TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # Basic indexes including user_id for future queries
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_timestamp ON user_engagement(timestamp)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_device ON user_engagement(device_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_user ON user_engagement(user_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_sighting ON user_engagement(sighting_id)")
            
        print("✅ Simple engagement table created with user_id support")
    
    async def log_engagement(self, device_id: str, event_type: EngagementType, sighting_id: Optional[UUID] = None, user_id: Optional[UUID] = None):
        """Log simple engagement event"""
        async with self.db_pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO user_engagement (device_id, user_id, event_type, sighting_id)
                VALUES ($1, $2, $3, $4)
            """, device_id, user_id, event_type.value, sighting_id)
        
        print(f"📊 Logged engagement: {event_type.value} from {device_id}")
    
    async def get_basic_stats(self, hours: int = 24) -> Dict[str, Any]:
        """Get basic engagement statistics"""
        since = datetime.utcnow() - timedelta(hours=hours)
        
        async with self.db_pool.acquire() as conn:
            # Basic counts
            total_events = await conn.fetchval("""
                SELECT COUNT(*) FROM user_engagement WHERE timestamp >= $1
            """, since)
            
            unique_devices = await conn.fetchval("""
                SELECT COUNT(DISTINCT device_id) FROM user_engagement WHERE timestamp >= $1
            """, since)
            
            # Event breakdown
            event_counts = await conn.fetch("""
                SELECT event_type, COUNT(*) as count
                FROM user_engagement 
                WHERE timestamp >= $1
                GROUP BY event_type
                ORDER BY count DESC
            """, since)
            
            return {
                "hours": hours,
                "total_events": total_events,
                "unique_devices": unique_devices,
                "events": [{"type": row["event_type"], "count": row["count"]} for row in event_counts]
            }
    

# Global metrics service instance
_metrics_service: Optional[MetricsService] = None

def get_metrics_service(db_pool: asyncpg.Pool) -> MetricsService:
    """Get or create the global metrics service instance"""
    global _metrics_service
    if _metrics_service is None:
        _metrics_service = MetricsService(db_pool)
    return _metrics_service

async def initialize_metrics_service(db_pool: asyncpg.Pool):
    """Initialize the simple metrics service"""
    metrics_service = get_metrics_service(db_pool)
    await metrics_service.initialize()
    return metrics_service