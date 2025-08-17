"""
Comprehensive metrics and engagement tracking service for UFOBeep

This service provides centralized logging and metrics collection for:
- Alert delivery tracking (every push notification sent)
- User engagement metrics (how users respond to alerts)  
- System performance metrics (response times, success rates)
- Rollout and adoption metrics (user growth, feature usage)
- Geographic distribution and hotspot analysis
"""

import asyncio
import asyncpg
import json
import time
from datetime import datetime, timedelta
from typing import Dict, List, Optional, Any
from enum import Enum
from dataclasses import dataclass
from uuid import UUID, uuid4

class MetricType(str, Enum):
    ALERT_DELIVERY = "alert_delivery"
    USER_ENGAGEMENT = "user_engagement"
    SYSTEM_PERFORMANCE = "system_performance"
    USER_BEHAVIOR = "user_behavior"
    ROLLOUT_TRACKING = "rollout_tracking"
    ERROR_TRACKING = "error_tracking"

class EngagementType(str, Enum):
    ALERT_SENT = "alert_sent"
    ALERT_DELIVERED = "alert_delivered"
    ALERT_OPENED = "alert_opened"
    QUICK_ACTION_SEE_IT_TOO = "quick_action_see_it_too"
    QUICK_ACTION_DONT_SEE = "quick_action_dont_see"
    QUICK_ACTION_MISSED = "quick_action_missed"
    QUICK_ACTION_DISMISS = "quick_action_dismiss"
    BEEP_SUBMITTED = "beep_submitted"
    COMPASS_OPENED = "compass_opened"
    CAMERA_USED = "camera_used"
    SHARE_TO_BEEP = "share_to_beep"
    APP_OPENED = "app_opened"
    SETTINGS_CHANGED = "settings_changed"

class AlertDeliveryStatus(str, Enum):
    SENT = "sent"
    DELIVERED = "delivered"  
    FAILED = "failed"
    RATE_LIMITED = "rate_limited"
    USER_OPTED_OUT = "user_opted_out"

@dataclass
class MetricEvent:
    """Base metric event structure"""
    event_id: str
    metric_type: MetricType
    event_type: str
    timestamp: datetime
    device_id: Optional[str] = None
    user_id: Optional[UUID] = None
    sighting_id: Optional[UUID] = None
    session_id: Optional[str] = None
    data: Optional[Dict[str, Any]] = None
    
class MetricsService:
    """Centralized metrics collection and analysis service"""
    
    def __init__(self, db_pool: asyncpg.Pool):
        self.db_pool = db_pool
        self._buffer = []
        self._buffer_lock = asyncio.Lock()
        self._flush_task = None
        
    async def initialize(self):
        """Initialize metrics tables and start background flushing"""
        await self._create_metrics_tables()
        self._flush_task = asyncio.create_task(self._periodic_flush())
        
    async def _create_metrics_tables(self):
        """Create comprehensive metrics tracking tables"""
        async with self.db_pool.acquire() as conn:
            # Core metrics events table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS metrics_events (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    event_id VARCHAR(255) UNIQUE NOT NULL,
                    metric_type VARCHAR(50) NOT NULL,
                    event_type VARCHAR(100) NOT NULL,
                    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
                    device_id VARCHAR(255),
                    user_id UUID,
                    sighting_id UUID,
                    session_id VARCHAR(255),
                    data JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # Alert delivery tracking table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS alert_deliveries (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    alert_batch_id VARCHAR(255) NOT NULL,
                    sighting_id UUID NOT NULL,
                    device_id VARCHAR(255) NOT NULL,
                    push_token_hash VARCHAR(64),
                    delivery_status VARCHAR(50) NOT NULL,
                    delivery_attempt_time TIMESTAMP WITH TIME ZONE NOT NULL,
                    delivery_confirmed_time TIMESTAMP WITH TIME ZONE,
                    delivery_time_ms INTEGER,
                    error_message TEXT,
                    witness_count INTEGER DEFAULT 1,
                    distance_km DECIMAL(8,3),
                    escalation_level VARCHAR(20),
                    user_preferences JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # User engagement sessions table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS engagement_sessions (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    session_id VARCHAR(255) UNIQUE NOT NULL,
                    device_id VARCHAR(255) NOT NULL,
                    user_id UUID,
                    session_start TIMESTAMP WITH TIME ZONE NOT NULL,
                    session_end TIMESTAMP WITH TIME ZONE,
                    session_duration_seconds INTEGER,
                    events_count INTEGER DEFAULT 0,
                    alerts_received INTEGER DEFAULT 0,
                    alerts_engaged INTEGER DEFAULT 0,
                    beeps_submitted INTEGER DEFAULT 0,
                    app_version VARCHAR(50),
                    platform VARCHAR(20),
                    location_lat DECIMAL(10,7),
                    location_lng DECIMAL(10,7),
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # Performance metrics table
            await conn.execute("""
                CREATE TABLE IF NOT EXISTS performance_metrics (
                    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
                    metric_name VARCHAR(100) NOT NULL,
                    metric_value DECIMAL(15,6) NOT NULL,
                    metric_unit VARCHAR(20),
                    timestamp TIMESTAMP WITH TIME ZONE NOT NULL,
                    context JSONB,
                    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
                )
            """)
            
            # Create indexes for efficient querying
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_metrics_events_timestamp ON metrics_events(timestamp)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_metrics_events_device ON metrics_events(device_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_metrics_events_type ON metrics_events(metric_type, event_type)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_metrics_events_sighting ON metrics_events(sighting_id)")
            
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_alert_deliveries_batch ON alert_deliveries(alert_batch_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_alert_deliveries_device ON alert_deliveries(device_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_alert_deliveries_sighting ON alert_deliveries(sighting_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_alert_deliveries_time ON alert_deliveries(delivery_attempt_time)")
            
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_sessions_device ON engagement_sessions(device_id)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_engagement_sessions_start ON engagement_sessions(session_start)")
            
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_performance_metrics_name ON performance_metrics(metric_name)")
            await conn.execute("CREATE INDEX IF NOT EXISTS idx_performance_metrics_timestamp ON performance_metrics(timestamp)")
            
        print("✅ Metrics tables and indexes created successfully")
    
    async def log_alert_delivery(self, 
                                alert_batch_id: str,
                                sighting_id: UUID,
                                device_id: str,
                                status: AlertDeliveryStatus,
                                delivery_time_ms: Optional[int] = None,
                                witness_count: int = 1,
                                distance_km: Optional[float] = None,
                                escalation_level: str = "normal",
                                error_message: Optional[str] = None,
                                push_token: Optional[str] = None):
        """Log alert delivery attempt with comprehensive tracking"""
        
        # Hash push token for privacy
        import hashlib
        push_token_hash = None
        if push_token:
            push_token_hash = hashlib.sha256(push_token.encode()).hexdigest()[:16]
        
        event = MetricEvent(
            event_id=f"alert_delivery_{alert_batch_id}_{device_id}_{int(time.time())}",
            metric_type=MetricType.ALERT_DELIVERY,
            event_type=status.value,
            timestamp=datetime.utcnow(),
            device_id=device_id,
            sighting_id=sighting_id,
            data={
                "alert_batch_id": alert_batch_id,
                "delivery_time_ms": delivery_time_ms,
                "witness_count": witness_count,
                "distance_km": distance_km,
                "escalation_level": escalation_level,
                "error_message": error_message,
                "push_token_hash": push_token_hash
            }
        )
        
        await self._queue_event(event)
        
        # Also insert directly into alert_deliveries table for detailed tracking
        await self._insert_alert_delivery_record(
            alert_batch_id, sighting_id, device_id, status, 
            delivery_time_ms, witness_count, distance_km, 
            escalation_level, error_message, push_token_hash
        )
    
    async def log_user_engagement(self,
                                 engagement_type: EngagementType,
                                 device_id: str,
                                 sighting_id: Optional[UUID] = None,
                                 user_id: Optional[UUID] = None,
                                 session_id: Optional[str] = None,
                                 additional_data: Optional[Dict[str, Any]] = None):
        """Log user engagement event (button presses, actions, etc.)"""
        
        event = MetricEvent(
            event_id=f"engagement_{engagement_type.value}_{device_id}_{int(time.time())}",
            metric_type=MetricType.USER_ENGAGEMENT,
            event_type=engagement_type.value,
            timestamp=datetime.utcnow(),
            device_id=device_id,
            user_id=user_id,
            sighting_id=sighting_id,
            session_id=session_id,
            data=additional_data or {}
        )
        
        await self._queue_event(event)
    
    async def log_performance_metric(self,
                                   metric_name: str,
                                   metric_value: float,
                                   metric_unit: str = "ms",
                                   context: Optional[Dict[str, Any]] = None):
        """Log system performance metric"""
        
        event = MetricEvent(
            event_id=f"perf_{metric_name}_{int(time.time())}",
            metric_type=MetricType.SYSTEM_PERFORMANCE,
            event_type=metric_name,
            timestamp=datetime.utcnow(),
            data={
                "metric_value": metric_value,
                "metric_unit": metric_unit,
                "context": context or {}
            }
        )
        
        await self._queue_event(event)
    
    async def start_engagement_session(self,
                                     device_id: str,
                                     user_id: Optional[UUID] = None,
                                     app_version: Optional[str] = None,
                                     platform: Optional[str] = None,
                                     location_lat: Optional[float] = None,
                                     location_lng: Optional[float] = None) -> str:
        """Start a new user engagement session and return session_id"""
        
        session_id = f"session_{device_id}_{int(time.time())}"
        
        async with self.db_pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO engagement_sessions 
                (session_id, device_id, user_id, session_start, app_version, platform, location_lat, location_lng)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8)
            """, session_id, device_id, user_id, datetime.utcnow(), 
                app_version, platform, location_lat, location_lng)
        
        return session_id
    
    async def end_engagement_session(self, session_id: str):
        """End an engagement session and calculate duration"""
        
        async with self.db_pool.acquire() as conn:
            result = await conn.fetchrow("""
                UPDATE engagement_sessions 
                SET session_end = $1,
                    session_duration_seconds = EXTRACT(EPOCH FROM ($1 - session_start))
                WHERE session_id = $2
                RETURNING session_duration_seconds
            """, datetime.utcnow(), session_id)
            
            if result:
                duration = result['session_duration_seconds']
                await self.log_performance_metric(
                    "session_duration",
                    duration,
                    "seconds",
                    {"session_id": session_id}
                )
    
    async def get_engagement_metrics(self, 
                                   time_range_hours: int = 24,
                                   sighting_id: Optional[UUID] = None) -> Dict[str, Any]:
        """Get comprehensive engagement metrics for analysis"""
        
        since = datetime.utcnow() - timedelta(hours=time_range_hours)
        
        async with self.db_pool.acquire() as conn:
            # Overall engagement stats
            if sighting_id:
                engagement_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(*) as total_events,
                        COUNT(DISTINCT device_id) as unique_devices,
                        COUNT(DISTINCT sighting_id) as unique_sightings,
                        AVG(CASE WHEN data->>'delivery_time_ms' IS NOT NULL 
                            THEN (data->>'delivery_time_ms')::float END) as avg_delivery_time_ms
                    FROM metrics_events 
                    WHERE timestamp >= $1
                    AND sighting_id = $2
                """, since, sighting_id)
            else:
                engagement_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(*) as total_events,
                        COUNT(DISTINCT device_id) as unique_devices,
                        COUNT(DISTINCT sighting_id) as unique_sightings,
                        AVG(CASE WHEN data->>'delivery_time_ms' IS NOT NULL 
                            THEN (data->>'delivery_time_ms')::float END) as avg_delivery_time_ms
                    FROM metrics_events 
                    WHERE timestamp >= $1
                """, since)
            
            # Engagement by type
            if sighting_id:
                engagement_by_type = await conn.fetch("""
                    SELECT 
                        event_type,
                        COUNT(*) as count,
                        COUNT(DISTINCT device_id) as unique_devices
                    FROM metrics_events 
                    WHERE timestamp >= $1 
                    AND metric_type = $2
                    AND sighting_id = $3
                    GROUP BY event_type
                    ORDER BY count DESC
                """, since, MetricType.USER_ENGAGEMENT.value, sighting_id)
            else:
                engagement_by_type = await conn.fetch("""
                    SELECT 
                        event_type,
                        COUNT(*) as count,
                        COUNT(DISTINCT device_id) as unique_devices
                    FROM metrics_events 
                    WHERE timestamp >= $1 
                    AND metric_type = $2
                    GROUP BY event_type
                    ORDER BY count DESC
                """, since, MetricType.USER_ENGAGEMENT.value)
            
            # Alert delivery success rates
            if sighting_id:
                delivery_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(*) as total_deliveries,
                        COUNT(CASE WHEN delivery_status = 'delivered' THEN 1 END) as successful_deliveries,
                        COUNT(CASE WHEN delivery_status = 'failed' THEN 1 END) as failed_deliveries,
                        COUNT(CASE WHEN delivery_status = 'rate_limited' THEN 1 END) as rate_limited,
                        AVG(delivery_time_ms) as avg_delivery_time_ms,
                        MAX(delivery_time_ms) as max_delivery_time_ms
                    FROM alert_deliveries 
                    WHERE delivery_attempt_time >= $1
                    AND sighting_id = $2
                """, since, sighting_id)
            else:
                delivery_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(*) as total_deliveries,
                        COUNT(CASE WHEN delivery_status = 'delivered' THEN 1 END) as successful_deliveries,
                        COUNT(CASE WHEN delivery_status = 'failed' THEN 1 END) as failed_deliveries,
                        COUNT(CASE WHEN delivery_status = 'rate_limited' THEN 1 END) as rate_limited,
                        AVG(delivery_time_ms) as avg_delivery_time_ms,
                        MAX(delivery_time_ms) as max_delivery_time_ms
                    FROM alert_deliveries 
                    WHERE delivery_attempt_time >= $1
                """, since)
            
            # Engagement funnel (how many people go from alert → action)
            if sighting_id:
                funnel_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(DISTINCT CASE WHEN event_type = 'alert_sent' THEN device_id END) as alerts_sent,
                        COUNT(DISTINCT CASE WHEN event_type = 'alert_opened' THEN device_id END) as alerts_opened,
                        COUNT(DISTINCT CASE WHEN event_type LIKE 'quick_action_%' THEN device_id END) as quick_actions,
                        COUNT(DISTINCT CASE WHEN event_type = 'beep_submitted' THEN device_id END) as beeps_submitted
                    FROM metrics_events 
                    WHERE timestamp >= $1
                    AND metric_type = $2
                    AND sighting_id = $3
                """, since, MetricType.USER_ENGAGEMENT.value, sighting_id)
            else:
                funnel_stats = await conn.fetchrow("""
                    SELECT 
                        COUNT(DISTINCT CASE WHEN event_type = 'alert_sent' THEN device_id END) as alerts_sent,
                        COUNT(DISTINCT CASE WHEN event_type = 'alert_opened' THEN device_id END) as alerts_opened,
                        COUNT(DISTINCT CASE WHEN event_type LIKE 'quick_action_%' THEN device_id END) as quick_actions,
                        COUNT(DISTINCT CASE WHEN event_type = 'beep_submitted' THEN device_id END) as beeps_submitted
                    FROM metrics_events 
                    WHERE timestamp >= $1
                    AND metric_type = $2
                """, since, MetricType.USER_ENGAGEMENT.value)
        
        return {
            "time_range_hours": time_range_hours,
            "sighting_id": str(sighting_id) if sighting_id else None,
            "overall": dict(engagement_stats) if engagement_stats else {},
            "by_type": [dict(row) for row in engagement_by_type],
            "delivery": dict(delivery_stats) if delivery_stats else {},
            "funnel": dict(funnel_stats) if funnel_stats else {},
            "calculated_metrics": {
                "engagement_rate": (funnel_stats['quick_actions'] / max(funnel_stats['alerts_sent'], 1)) * 100 if funnel_stats else 0,
                "open_rate": (funnel_stats['alerts_opened'] / max(funnel_stats['alerts_sent'], 1)) * 100 if funnel_stats else 0,
                "delivery_success_rate": (delivery_stats['successful_deliveries'] / max(delivery_stats['total_deliveries'], 1)) * 100 if delivery_stats else 0
            }
        }
    
    async def _queue_event(self, event: MetricEvent):
        """Queue event for batch processing"""
        async with self._buffer_lock:
            self._buffer.append(event)
            
            # Flush immediately if buffer is getting large
            if len(self._buffer) >= 100:
                await self._flush_buffer()
    
    async def _flush_buffer(self):
        """Flush buffered events to database"""
        if not self._buffer:
            return
            
        async with self._buffer_lock:
            events_to_flush = self._buffer.copy()
            self._buffer.clear()
        
        if not events_to_flush:
            return
            
        async with self.db_pool.acquire() as conn:
            # Batch insert all events
            records = [
                (
                    event.event_id,
                    event.metric_type.value,
                    event.event_type,
                    event.timestamp,
                    event.device_id,
                    event.user_id,
                    event.sighting_id,
                    event.session_id,
                    json.dumps(event.data) if event.data else None
                )
                for event in events_to_flush
            ]
            
            await conn.executemany("""
                INSERT INTO metrics_events 
                (event_id, metric_type, event_type, timestamp, device_id, user_id, sighting_id, session_id, data)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                ON CONFLICT (event_id) DO NOTHING
            """, records)
            
        print(f"📊 Flushed {len(events_to_flush)} metric events to database")
    
    async def _insert_alert_delivery_record(self, 
                                          alert_batch_id: str,
                                          sighting_id: UUID,
                                          device_id: str,
                                          status: AlertDeliveryStatus,
                                          delivery_time_ms: Optional[int],
                                          witness_count: int,
                                          distance_km: Optional[float],
                                          escalation_level: str,
                                          error_message: Optional[str],
                                          push_token_hash: Optional[str]):
        """Insert detailed alert delivery record"""
        
        async with self.db_pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO alert_deliveries 
                (alert_batch_id, sighting_id, device_id, delivery_status, delivery_attempt_time,
                 delivery_time_ms, witness_count, distance_km, escalation_level, error_message, push_token_hash)
                VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11)
                ON CONFLICT DO NOTHING
            """, alert_batch_id, sighting_id, device_id, status.value, datetime.utcnow(),
                delivery_time_ms, witness_count, distance_km, escalation_level, error_message, push_token_hash)
    
    async def _periodic_flush(self):
        """Periodically flush buffered events"""
        while True:
            try:
                await asyncio.sleep(30)  # Flush every 30 seconds
                await self._flush_buffer()
            except asyncio.CancelledError:
                break
            except Exception as e:
                print(f"Error in periodic flush: {e}")
    
    async def shutdown(self):
        """Shutdown metrics service and flush remaining events"""
        if self._flush_task:
            self._flush_task.cancel()
            try:
                await self._flush_task
            except asyncio.CancelledError:
                pass
        
        await self._flush_buffer()
        print("📊 Metrics service shutdown complete")

# Global metrics service instance
_metrics_service: Optional[MetricsService] = None

def get_metrics_service(db_pool: asyncpg.Pool) -> MetricsService:
    """Get or create the global metrics service instance"""
    global _metrics_service
    if _metrics_service is None:
        _metrics_service = MetricsService(db_pool)
    return _metrics_service

async def initialize_metrics_service(db_pool: asyncpg.Pool):
    """Initialize the global metrics service"""
    metrics_service = get_metrics_service(db_pool)
    await metrics_service.initialize()
    return metrics_service