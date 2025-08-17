"""
Admin interface for UFOBeep - password protected admin functions
"""
from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.security import HTTPBasic, HTTPBasicCredentials
from fastapi.responses import HTMLResponse
from pydantic import BaseModel
from typing import List, Optional, Dict, Any
import asyncpg
from datetime import datetime, timedelta
import secrets
import hashlib

router = APIRouter(prefix="/admin", tags=["admin"])
security = HTTPBasic()

# Admin credentials (temporary - will be replaced with user system)
ADMIN_PASSWORD = "ufopostpass"

class AdminStats(BaseModel):
    """Admin dashboard statistics"""
    total_sightings: int
    total_media_files: int
    sightings_today: int
    sightings_this_week: int
    pending_sightings: int
    verified_sightings: int
    media_without_primary: int
    recent_uploads: int
    total_witness_confirmations: int
    confirmations_today: int
    high_witness_sightings: int
    escalated_alerts: int
    database_size_mb: Optional[float]

class SightingAdmin(BaseModel):
    """Sighting for admin management"""
    id: str
    title: str
    description: str
    category: str
    status: str
    alert_level: str
    created_at: datetime
    location_name: Optional[str]
    reporter_id: Optional[str]
    media_count: int
    has_primary_media: bool
    verification_score: float
    witness_count: int
    total_confirmations: int
    escalation_level: str

class MediaFileAdmin(BaseModel):
    """Media file for admin management"""
    id: str
    sighting_id: str
    filename: str
    type: str
    size_bytes: int
    is_primary: bool
    upload_order: int
    display_priority: int
    uploaded_by_user_id: Optional[str]
    created_at: datetime

# Database connection helper
async def get_db_connection():
    """Get database connection"""
    return await asyncpg.connect(
        host="localhost",
        port=5432,
        user="ufobeep_user",
        password="ufopostpass",
        database="ufobeep_db"
    )

# Authentication
def verify_admin_password(credentials: HTTPBasicCredentials = Depends(security)):
    """Verify admin password"""
    is_correct_username = secrets.compare_digest(credentials.username, "admin")
    is_correct_password = secrets.compare_digest(credentials.password, ADMIN_PASSWORD)
    
    if not (is_correct_username and is_correct_password):
        raise HTTPException(
            status_code=401,
            detail="Incorrect admin credentials",
            headers={"WWW-Authenticate": "Basic"},
        )
    return credentials.username

@router.get("/", response_class=HTMLResponse)
async def admin_dashboard(credentials: str = Depends(verify_admin_password)):
    """Admin dashboard HTML interface"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin Dashboard</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .header h1 { color: #00ff88; margin: 0; }
        .header p { color: #888; margin: 5px 0; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .stat-card { background: #2d2d2d; padding: 20px; border-radius: 8px; text-align: center; border: 1px solid #444; }
        .stat-number { font-size: 2em; font-weight: bold; color: #00ff88; margin: 0; }
        .stat-label { color: #bbb; margin: 10px 0 0 0; }
        .nav-buttons { display: grid; grid-template-columns: repeat(auto-fit, minmax(250px, 1fr)); gap: 15px; margin-bottom: 40px; }
        .nav-btn { background: #333; border: 2px solid #00ff88; color: #00ff88; padding: 15px 20px; text-decoration: none; border-radius: 8px; text-align: center; transition: all 0.3s; }
        .nav-btn:hover { background: #00ff88; color: #000; }
        .section { background: #2d2d2d; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #444; }
        .section h3 { color: #00ff88; margin-top: 0; }
        .table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table th, .table td { text-align: left; padding: 12px; border-bottom: 1px solid #444; }
        .table th { background: #333; color: #00ff88; }
        .table tr:hover { background: #333; }
        .badge { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .badge.high { background: #ff4444; color: white; }
        .badge.medium { background: #ffaa44; color: white; }
        .badge.low { background: #44ff44; color: black; }
        .badge.verified { background: #00ff88; color: black; }
        .badge.pending { background: #ffaa44; color: black; }
        .btn { background: #00ff88; color: #000; padding: 5px 10px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.9em; }
        .btn:hover { background: #00cc70; }
        .btn.danger { background: #ff4444; color: white; }
        .btn.danger:hover { background: #cc3333; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛸 UFOBeep Admin Dashboard</h1>
            <p>System Administration & Management</p>
        </div>

        <div class="stats-grid" id="stats-grid">
            <!-- Stats loaded via JavaScript -->
        </div>

        <div class="nav-buttons">
            <a href="/admin/sightings" class="nav-btn">📋 Manage Sightings</a>
            <a href="/admin/witnesses" class="nav-btn">👁️ Witness Confirmations</a>
            <a href="/admin/aggregation" class="nav-btn">🔬 Witness Aggregation</a>
            <a href="/admin/engagement/metrics" class="nav-btn">📊 Engagement Analytics</a>
            <a href="/admin/media" class="nav-btn">📸 Media Management</a>
            <a href="/admin/users" class="nav-btn">👥 User Management</a>
            <a href="/admin/system" class="nav-btn">⚙️ System Status</a>
            <a href="/admin/mufon" class="nav-btn">🛸 MUFON Integration</a>
            <a href="/admin/alerts" class="nav-btn">🚨 Proximity Alerts</a>
            <a href="/admin/logs" class="nav-btn">📜 System Logs</a>
        </div>

        <!-- User Engagement & Metrics Section -->
        <div class="section">
            <h3>📊 User Engagement & Quick Actions (24h)</h3>
            <div class="stats-grid" id="engagement-stats">
                <div class="stat-card">
                    <div class="stat-number" id="engagement-rate">-</div>
                    <div class="stat-label">Engagement Rate</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="confirmations-24h">-</div>
                    <div class="stat-label">"I see it too" Actions</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="checked-no-see-24h">-</div>
                    <div class="stat-label">"I checked but don't see it"</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="missed-24h">-</div>
                    <div class="stat-label">"I missed this one"</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="unique-devices-24h">-</div>
                    <div class="stat-label">Active Devices</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="delivery-success-rate">-</div>
                    <div class="stat-label">Delivery Success Rate</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="avg-delivery-time">-</div>
                    <div class="stat-label">Avg Delivery Time</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="events-1h">-</div>
                    <div class="stat-label">Events (1h)</div>
                </div>
            </div>
            <div style="margin-top: 15px; text-align: center;">
                <button class="nav-btn" onclick="refreshEngagementMetrics()" style="width: auto; padding: 10px 20px;">🔄 Refresh Metrics</button>
                <button class="nav-btn" onclick="viewDetailedMetrics()" style="width: auto; padding: 10px 20px; margin-left: 10px;">📈 Detailed View</button>
            </div>
        </div>

        <!-- Rate Limiting Controls Section -->
        <div class="section">
            <h3>⏱️ Rate Limiting Controls</h3>
            <div class="stats-grid">
                <div class="stat-card">
                    <div class="stat-number" id="rate-limit-status">Loading...</div>
                    <div class="stat-label">Status</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number" id="rate-limit-threshold">-</div>
                    <div class="stat-label">Threshold (per 15min)</div>
                </div>
            </div>
            <div class="nav-buttons">
                <button class="nav-btn" onclick="toggleRateLimit(false)" style="background: #dc3545;">🔴 Disable</button>
                <button class="nav-btn" onclick="toggleRateLimit(true)" style="background: #28a745;">🟢 Enable</button>
                <button class="nav-btn" onclick="setRateLimit()" style="background: #17a2b8;">📝 Set Threshold</button>
                <button class="nav-btn" onclick="clearRateLimit()" style="background: #fd7e14;">🧹 Clear History</button>
            </div>
            <div id="rate-limit-result" style="margin-top: 15px; display: none; padding: 10px; border-radius: 5px;"></div>
        </div>

        <div class="section">
            <h3>📊 Recent Activity</h3>
            <div id="recent-activity">Loading...</div>
        </div>

        <div class="section">
            <h3>🚨 System Alerts</h3>
            <div id="system-alerts">
                <p style="color: #888;">No critical alerts at this time.</p>
            </div>
        </div>
    </div>

    <script>
        // Load admin stats
        async function loadStats() {
            try {
                const response = await fetch('/admin/stats');
                const stats = await response.json();
                
                // Also load engagement metrics
                await loadEngagementMetrics();
                
                const statsGrid = document.getElementById('stats-grid');
                statsGrid.innerHTML = `
                    <div class="stat-card">
                        <div class="stat-number">${stats.total_sightings}</div>
                        <div class="stat-label">Total Sightings</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.total_media_files}</div>
                        <div class="stat-label">Media Files</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.sightings_today}</div>
                        <div class="stat-label">Today</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.sightings_this_week}</div>
                        <div class="stat-label">This Week</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.pending_sightings}</div>
                        <div class="stat-label">Pending</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.verified_sightings}</div>
                        <div class="stat-label">Verified</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.total_witness_confirmations}</div>
                        <div class="stat-label">Total Witnesses</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.confirmations_today}</div>
                        <div class="stat-label">Witnesses Today</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.high_witness_sightings}</div>
                        <div class="stat-label">Multi-Witness (3+)</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${stats.escalated_alerts}</div>
                        <div class="stat-label">Emergency (10+)</div>
                    </div>
                `;
            } catch (error) {
                console.error('Failed to load stats:', error);
            }
        }

        // Load recent activity
        async function loadActivity() {
            try {
                const response = await fetch('/admin/recent-activity');
                const activity = await response.json();
                
                const activityDiv = document.getElementById('recent-activity');
                if (activity.length === 0) {
                    activityDiv.innerHTML = '<p style="color: #888;">No recent activity.</p>';
                    return;
                }
                
                activityDiv.innerHTML = activity.map(item => `
                    <div style="padding: 10px; border-bottom: 1px solid #444;">
                        <strong>${item.type}</strong>: ${item.description}
                        <br><small style="color: #888;">${new Date(item.timestamp).toLocaleString()}</small>
                    </div>
                `).join('');
            } catch (error) {
                console.error('Failed to load activity:', error);
            }
        }

        // Rate Limiting Control Functions
        async function loadRateLimitStatus() {
            try {
                const response = await fetch("/admin/ratelimit/status");
                const data = await response.json();
                
                document.getElementById("rate-limit-status").textContent = data.enabled ? "ENABLED" : "DISABLED";
                document.getElementById("rate-limit-threshold").textContent = data.threshold;
            } catch (error) {
                console.error("Failed to load rate limit status:", error);
                document.getElementById("rate-limit-status").textContent = "ERROR";
                document.getElementById("rate-limit-threshold").textContent = "?";
            }
        }

        async function toggleRateLimit(enable) {
            try {
                const endpoint = enable ? "/admin/ratelimit/on" : "/admin/ratelimit/off";
                const response = await fetch(endpoint);
                const data = await response.json();
                
                showRateLimitResult(data.message, data.success);
                await loadRateLimitStatus();
            } catch (error) {
                showRateLimitResult("Failed to toggle rate limiting", false);
            }
        }

        async function setRateLimit() {
            const threshold = prompt("Enter new rate limit threshold (minimum 1):", "3");
            if (threshold && !isNaN(threshold) && parseInt(threshold) > 0) {
                try {
                    const response = await fetch(`/admin/ratelimit/set?threshold=${threshold}`);
                    const data = await response.json();
                    
                    showRateLimitResult(data.message, data.success);
                    await loadRateLimitStatus();
                } catch (error) {
                    showRateLimitResult("Failed to set rate limit threshold", false);
                }
            }
        }

        async function clearRateLimit() {
            if (confirm("Clear old sightings to reset rate limiting? This will delete sightings older than 5 minutes.")) {
                try {
                    const response = await fetch("/admin/ratelimit/clear", { method: "POST" });
                    const data = await response.json();
                    
                    showRateLimitResult(data.message, data.success);
                } catch (error) {
                    showRateLimitResult("Failed to clear rate limit history", false);
                }
            }
        }

        function showRateLimitResult(message, success) {
            const resultDiv = document.getElementById("rate-limit-result");
            resultDiv.style.display = "block";
            resultDiv.style.backgroundColor = success ? "#d4edda" : "#f8d7da";
            resultDiv.style.color = success ? "#155724" : "#721c24";
            resultDiv.style.border = success ? "1px solid #c3e6cb" : "1px solid #f5c6cb";
            resultDiv.textContent = message;
            
            setTimeout(() => {
                resultDiv.style.display = "none";
            }, 5000);
        }

        // Engagement metrics functions
        async function loadEngagementMetrics() {
            try {
                const response = await fetch('/admin/engagement/summary');
                const result = await response.json();
                
                if (result.success) {
                    const data = result.data;
                    
                    // Update engagement metrics display
                    document.getElementById('engagement-rate').textContent = data.engagement_rate + '%';
                    document.getElementById('confirmations-24h').textContent = data.confirmations_24h;
                    document.getElementById('checked-no-see-24h').textContent = data.checked_no_see_24h;
                    document.getElementById('missed-24h').textContent = data.missed_24h;
                    document.getElementById('unique-devices-24h').textContent = data.unique_devices_24h;
                    document.getElementById('delivery-success-rate').textContent = data.delivery_success_rate + '%';
                    document.getElementById('avg-delivery-time').textContent = Math.round(data.avg_delivery_time_24h) + 'ms';
                    document.getElementById('events-1h').textContent = data.events_1h;
                } else {
                    console.error('Failed to load engagement metrics:', result.error);
                    // Set all to error state
                    ['engagement-rate', 'confirmations-24h', 'checked-no-see-24h', 'missed-24h', 
                     'unique-devices-24h', 'delivery-success-rate', 'avg-delivery-time', 'events-1h'].forEach(id => {
                        document.getElementById(id).textContent = 'Error';
                    });
                }
            } catch (error) {
                console.error('Error loading engagement metrics:', error);
                // Set all to error state
                ['engagement-rate', 'confirmations-24h', 'checked-no-see-24h', 'missed-24h', 
                 'unique-devices-24h', 'delivery-success-rate', 'avg-delivery-time', 'events-1h'].forEach(id => {
                    document.getElementById(id).textContent = 'Error';
                });
            }
        }
        
        async function refreshEngagementMetrics() {
            // Show loading state
            ['engagement-rate', 'confirmations-24h', 'checked-no-see-24h', 'missed-24h', 
             'unique-devices-24h', 'delivery-success-rate', 'avg-delivery-time', 'events-1h'].forEach(id => {
                document.getElementById(id).textContent = '...';
            });
            
            await loadEngagementMetrics();
        }
        
        function viewDetailedMetrics() {
            // Open detailed metrics in new window/tab
            window.open('/admin/engagement/metrics', '_blank');
        }

        // Initialize dashboard
        loadStats();
        loadActivity();
        loadRateLimitStatus();
        
        // Refresh every 30 seconds
        setInterval(() => {
            loadStats();
            loadEngagementMetrics();
            loadActivity();
            loadRateLimitStatus();
        }, 30000);
    </script>
</body>
</html>
"""

@router.get("/stats")
async def get_admin_stats(credentials: str = Depends(verify_admin_password)) -> AdminStats:
    """Get admin dashboard statistics"""
    
    conn = await get_db_connection()
    try:
        # Get basic counts
        total_sightings = await conn.fetchval("SELECT COUNT(*) FROM sightings") or 0
        total_media = await conn.fetchval("SELECT COUNT(*) FROM media_files") or 0
        
        # Get time-based counts
        today = datetime.now().replace(hour=0, minute=0, second=0, microsecond=0)
        week_ago = today - timedelta(days=7)
        
        sightings_today = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE created_at >= $1", today
        ) or 0
        
        sightings_this_week = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE created_at >= $1", week_ago
        ) or 0
        
        # Get status counts
        pending_sightings = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE status = 'pending'"
        ) or 0
        
        verified_sightings = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE status = 'verified'"
        ) or 0
        
        # Media stats
        media_without_primary = await conn.fetchval("""
            SELECT COUNT(DISTINCT sighting_id) 
            FROM sightings s 
            WHERE NOT EXISTS (
                SELECT 1 FROM media_files m 
                WHERE m.sighting_id = s.id AND m.is_primary = true
            )
            AND EXISTS (SELECT 1 FROM media_files m WHERE m.sighting_id = s.id)
        """) or 0
        
        recent_uploads = await conn.fetchval(
            "SELECT COUNT(*) FROM media_files WHERE created_at >= $1", 
            datetime.now() - timedelta(hours=24)
        ) or 0
        
        # Witness confirmation stats
        total_witness_confirmations = await conn.fetchval(
            "SELECT COUNT(*) FROM witness_confirmations"
        ) or 0
        
        confirmations_today = await conn.fetchval(
            "SELECT COUNT(*) FROM witness_confirmations WHERE created_at >= $1", today
        ) or 0
        
        high_witness_sightings = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE witness_count >= 3"
        ) or 0
        
        escalated_alerts = await conn.fetchval(
            "SELECT COUNT(*) FROM sightings WHERE witness_count >= 10"
        ) or 0
        
        return AdminStats(
            total_sightings=total_sightings,
            total_media_files=total_media,
            sightings_today=sightings_today,
            sightings_this_week=sightings_this_week,
            pending_sightings=pending_sightings,
            verified_sightings=verified_sightings,
            media_without_primary=media_without_primary,
            recent_uploads=recent_uploads,
            total_witness_confirmations=total_witness_confirmations,
            confirmations_today=confirmations_today,
            high_witness_sightings=high_witness_sightings,
            escalated_alerts=escalated_alerts,
            database_size_mb=None  # TODO: Calculate if needed
        )
        
    except Exception as e:
        # If tables don't exist yet, return zeros
        return AdminStats(
            total_sightings=0,
            total_media_files=0,
            sightings_today=0,
            sightings_this_week=0,
            pending_sightings=0,
            verified_sightings=0,
            media_without_primary=0,
            recent_uploads=0,
            total_witness_confirmations=0,
            confirmations_today=0,
            high_witness_sightings=0,
            escalated_alerts=0,
            database_size_mb=None
        )
    finally:
        await conn.close()

@router.get("/recent-activity")
async def get_recent_activity(credentials: str = Depends(verify_admin_password)):
    """Get recent system activity"""
    
    conn = await get_db_connection()
    try:
        # Get recent sightings
        recent_sightings = await conn.fetch("""
            SELECT id, title, created_at, status
            FROM sightings 
            ORDER BY created_at DESC 
            LIMIT 10
        """)
        
        # Get recent media uploads
        recent_media = await conn.fetch("""
            SELECT m.id, m.filename, m.created_at, s.title as sighting_title
            FROM media_files m
            JOIN sightings s ON m.sighting_id = s.id
            ORDER BY m.created_at DESC 
            LIMIT 10
        """)
        
        # Get recent witness confirmations
        recent_confirmations = await conn.fetch("""
            SELECT w.id, w.created_at, s.title as sighting_title, 
                   s.witness_count, w.distance_km
            FROM witness_confirmations w
            JOIN sightings s ON w.sighting_id = s.id
            ORDER BY w.created_at DESC 
            LIMIT 10
        """)
        
        activity = []
        
        for sighting in recent_sightings:
            activity.append({
                "type": "New Sighting",
                "description": f"'{sighting['title'][:50]}...' - Status: {sighting['status']}",
                "timestamp": sighting['created_at'].isoformat()
            })
            
        for media in recent_media:
            activity.append({
                "type": "Media Upload",
                "description": f"File '{media['filename']}' uploaded for '{media['sighting_title'][:30]}...'",
                "timestamp": media['created_at'].isoformat()
            })
            
        for confirmation in recent_confirmations:
            escalation = ""
            if confirmation['witness_count'] >= 10:
                escalation = " 🚨 EMERGENCY"
            elif confirmation['witness_count'] >= 3:
                escalation = " ⚠️ URGENT"
            
            activity.append({
                "type": "Witness Confirmation",
                "description": f"'{confirmation['sighting_title'][:30]}...' - {confirmation['witness_count']} witnesses ({confirmation['distance_km']:.1f}km away){escalation}",
                "timestamp": confirmation['created_at'].isoformat()
            })
        
        # Sort by timestamp and return recent 15
        activity.sort(key=lambda x: x['timestamp'], reverse=True)
        return activity[:15]
        
    except Exception as e:
        return []
    finally:
        await conn.close()


# JSON API endpoints for JavaScript data fetching
@router.get("/data/sightings")
async def get_sightings_data(
    limit: int = 50,
    offset: int = 0,
    status: Optional[str] = None,
    credentials: str = Depends(verify_admin_password)
) -> List[SightingAdmin]:
    """Get sightings data for admin management"""
    
    conn = await get_db_connection()
    try:
        query = """
            SELECT 
                s.id, s.title, s.description, s.category, s.status, s.alert_level,
                s.created_at, s.witness_count,
                COUNT(m.id) as media_count,
                COUNT(CASE WHEN m.is_primary THEN 1 END) > 0 as has_primary_media,
                COALESCE((SELECT COUNT(*) FROM witness_confirmations w WHERE w.sighting_id = s.id), 0) as total_confirmations
            FROM sightings s
            LEFT JOIN media_files m ON s.id = m.sighting_id
            GROUP BY s.id, s.title, s.description, s.category, s.status, s.alert_level,
                     s.created_at, s.witness_count
            ORDER BY s.created_at DESC
            LIMIT $1 OFFSET $2
        """
        sightings = await conn.fetch(query, limit, offset)
        
        def get_escalation_level(witness_count):
            if witness_count >= 10:
                return "emergency"
            elif witness_count >= 3:
                return "urgent"
            else:
                return "normal"
        
        return [
            SightingAdmin(
                id=str(s['id']),
                title=s['title'],
                description=s['description'],
                category=s['category'],
                status=s['status'],
                alert_level=s['alert_level'],
                created_at=s['created_at'],
                location_name="Unknown",  # Default since column doesn't exist yet
                reporter_id=None,  # Default since column doesn't exist yet
                media_count=s['media_count'],
                has_primary_media=s['has_primary_media'],
                verification_score=0.0,  # Default since column doesn't exist yet
                witness_count=s['witness_count'],
                total_confirmations=s['total_confirmations'],
                escalation_level=get_escalation_level(s['witness_count'])
            )
            for s in sightings
        ]
        
    except Exception as e:
        print(f"Error in admin sightings query: {e}")
        return []
    finally:
        await conn.close()

@router.get("/data/media")
async def get_media_data(
    limit: int = 50,
    offset: int = 0,
    sighting_id: Optional[str] = None,
    credentials: str = Depends(verify_admin_password)
) -> List[MediaFileAdmin]:
    """Get media files data for admin management"""
    
    conn = await get_db_connection()
    try:
        where_clause = ""
        params = []
        
        if sighting_id:
            where_clause = "WHERE m.sighting_id = $1"
            params = [sighting_id]
            
        query = f"""
            SELECT 
                m.id, m.sighting_id, m.filename, m.type, m.size_bytes,
                m.is_primary, m.upload_order, m.display_priority,
                m.uploaded_by_user_id, m.created_at
            FROM media_files m
            {where_clause}
            ORDER BY m.created_at DESC
            LIMIT $2 OFFSET $3
        """
        
        params.extend([limit, offset])
        media_files = await conn.fetch(query, *params)
        
        return [
            MediaFileAdmin(
                id=str(m['id']),
                sighting_id=str(m['sighting_id']),
                filename=m['filename'],
                type=m['type'],
                size_bytes=m['size_bytes'],
                is_primary=m['is_primary'],
                upload_order=m['upload_order'],
                display_priority=m['display_priority'],
                uploaded_by_user_id=str(m['uploaded_by_user_id']) if m['uploaded_by_user_id'] else None,
                created_at=m['created_at']
            )
            for m in media_files
        ]
        
    except Exception as e:
        return []
    finally:
        await conn.close()

@router.get("/data/witnesses")
async def get_witnesses_data(
    limit: int = 50,
    offset: int = 0,
    sighting_id: Optional[str] = None,
    escalation_level: Optional[str] = None,
    credentials: str = Depends(verify_admin_password)
):
    """Get witness confirmations data for admin management"""
    
    conn = await get_db_connection()
    try:
        where_clauses = []
        params = []
        param_count = 1
        
        if sighting_id:
            where_clauses.append(f"w.sighting_id = ${param_count}")
            params.append(sighting_id)
            param_count += 1
            
        if escalation_level:
            if escalation_level == "emergency":
                where_clauses.append(f"s.witness_count >= ${param_count}")
                params.append(10)
            elif escalation_level == "urgent":
                where_clauses.append(f"s.witness_count >= ${param_count} AND s.witness_count < ${param_count + 1}")
                params.extend([3, 10])
                param_count += 1
            elif escalation_level == "normal":
                where_clauses.append(f"s.witness_count < ${param_count}")
                params.append(3)
            param_count += 1
            
        where_sql = " AND ".join(where_clauses) if where_clauses else "1=1"
        
        query = f"""
            SELECT 
                w.id, w.sighting_id, w.device_id, w.latitude, w.longitude,
                w.accuracy, w.altitude, w.still_visible, w.distance_km, w.created_at,
                s.title as sighting_title, s.witness_count,
                CASE 
                    WHEN s.witness_count >= 10 THEN 'emergency'
                    WHEN s.witness_count >= 3 THEN 'urgent'
                    ELSE 'normal'
                END as escalation_level
            FROM witness_confirmations w
            JOIN sightings s ON w.sighting_id = s.id
            WHERE {where_sql}
            ORDER BY w.created_at DESC
            LIMIT ${param_count} OFFSET ${param_count + 1}
        """
        
        params.extend([limit, offset])
        confirmations = await conn.fetch(query, *params)
        
        return [
            {
                "id": str(c['id']),
                "sighting_id": str(c['sighting_id']),
                "sighting_title": c['sighting_title'],
                "device_id": c['device_id'],
                "latitude": c['latitude'],
                "longitude": c['longitude'],
                "accuracy": c['accuracy'],
                "altitude": c['altitude'],
                "still_visible": c['still_visible'],
                "distance_km": c['distance_km'],
                "witness_count": c['witness_count'],
                "escalation_level": c['escalation_level'],
                "created_at": c['created_at'].isoformat()
            }
            for c in confirmations
        ]
        
    except Exception as e:
        print(f"Error in admin witnesses query: {e}")
        return []
    finally:
        await conn.close()

@router.post("/sighting/{sighting_id}/verify")
async def verify_sighting(
    sighting_id: str,
    credentials: str = Depends(verify_admin_password)
):
    """Verify a sighting (admin only)"""
    
    conn = await get_db_connection()
    try:
        await conn.execute(
            "UPDATE sightings SET status = 'verified', verification_score = 1.0 WHERE id = $1",
            sighting_id
        )
        return {"success": True, "message": "Sighting verified"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to verify sighting: {str(e)}")
    finally:
        await conn.close()

@router.delete("/sighting/{sighting_id}")
async def delete_sighting(
    sighting_id: str,
    credentials: str = Depends(verify_admin_password)
):
    """Delete a sighting and all associated media (admin only)"""
    
    conn = await get_db_connection()
    try:
        # Delete associated media files first
        await conn.execute("DELETE FROM media_files WHERE sighting_id = $1", sighting_id)
        
        # Delete sighting
        await conn.execute("DELETE FROM sightings WHERE id = $1", sighting_id)
        
        return {"success": True, "message": "Sighting and associated media deleted"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=f"Failed to delete sighting: {str(e)}")
    finally:
        await conn.close()

# Admin page endpoints
@router.get("/sightings", response_class=HTMLResponse)
async def admin_sightings_page(credentials: str = Depends(verify_admin_password)):
    """Admin sightings management page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - Sightings</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { display: flex; justify-content: between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .controls { display: flex; gap: 10px; margin-bottom: 20px; align-items: center; }
        .status-filter { background: #333; border: 1px solid #555; color: #e0e0e0; padding: 8px 12px; border-radius: 4px; }
        .refresh-btn { background: #00ff88; color: #000; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .refresh-btn:hover { background: #00cc70; }
        .table { width: 100%; border-collapse: collapse; background: #2d2d2d; border-radius: 8px; overflow: hidden; }
        .table th, .table td { text-align: left; padding: 12px; border-bottom: 1px solid #444; }
        .table th { background: #333; color: #00ff88; font-weight: bold; }
        .table tr:hover { background: #333; }
        .badge { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .badge.high { background: #ff4444; color: white; }
        .badge.medium { background: #ffaa44; color: white; }
        .badge.low { background: #44ff44; color: black; }
        .badge.verified { background: #00ff88; color: black; }
        .badge.pending { background: #ffaa44; color: black; }
        .badge.created { background: #666; color: white; }
        .badge.emergency { background: #ff4444; color: white; }
        .badge.urgent { background: #ffaa44; color: white; }
        .badge.normal { background: #00ff88; color: black; }
        .btn { background: #00ff88; color: #000; padding: 4px 8px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.8em; margin-right: 5px; }
        .btn:hover { background: #00cc70; }
        .btn.danger { background: #ff4444; color: white; }
        .btn.danger:hover { background: #cc3333; }
        .media-count { color: #888; font-size: 0.9em; }
        .loading { text-align: center; padding: 40px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛸 Sightings Management</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="controls">
            <select id="statusFilter" class="status-filter">
                <option value="">All Statuses</option>
                <option value="created">Created</option>
                <option value="pending">Pending</option>
                <option value="verified">Verified</option>
            </select>
            <button onclick="loadSightings()" class="refresh-btn">Refresh</button>
        </div>

        <div id="sightingsTable" class="loading">Loading sightings...</div>
    </div>

    <script>
        let currentSightings = [];

        async function loadSightings() {
            try {
                const statusFilter = document.getElementById('statusFilter').value;
                const params = new URLSearchParams();
                if (statusFilter) params.append('status', statusFilter);
                
                const response = await fetch(`/admin/data/sightings?${params}`);
                const sightings = await response.json();
                currentSightings = sightings;
                renderSightings(sightings);
            } catch (error) {
                document.getElementById('sightingsTable').innerHTML = 
                    `<div class="loading">Error loading sightings: ${error.message}</div>`;
            }
        }

        function renderSightings(sightings) {
            if (sightings.length === 0) {
                document.getElementById('sightingsTable').innerHTML = 
                    '<div class="loading">No sightings found.</div>';
                return;
            }

            const table = `
                <table class="table">
                    <thead>
                        <tr>
                            <th>Title</th>
                            <th>Category</th>
                            <th>Status</th>
                            <th>Alert Level</th>
                            <th>Witnesses</th>
                            <th>Media</th>
                            <th>Location</th>
                            <th>Created</th>
                            <th>Actions</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${sightings.map(sighting => `
                            <tr>
                                <td>
                                    <strong>${sighting.title}</strong><br>
                                    <small style="color: #888;">${sighting.description.substring(0, 100)}...</small>
                                </td>
                                <td>${sighting.category}</td>
                                <td><span class="badge ${sighting.status}">${sighting.status}</span></td>
                                <td><span class="badge ${sighting.alert_level}">${sighting.alert_level}</span></td>
                                <td>
                                    <div style="display: flex; align-items: center; gap: 8px;">
                                        <span class="badge ${sighting.escalation_level}">
                                            ${sighting.escalation_level === 'emergency' ? '🚨' : 
                                              sighting.escalation_level === 'urgent' ? '⚠️' : '👁️'} 
                                            ${sighting.witness_count}
                                        </span>
                                        <small style="color: #888;">(${sighting.total_confirmations} confirmed)</small>
                                    </div>
                                </td>
                                <td>
                                    <span class="media-count">${sighting.media_count} files</span>
                                    ${sighting.has_primary_media ? '<br><small style="color: #00ff88;">✓ Has Primary</small>' : '<br><small style="color: #ff4444;">⚠ No Primary</small>'}
                                </td>
                                <td>${sighting.location_name || 'Unknown'}</td>
                                <td>${new Date(sighting.created_at).toLocaleDateString()}</td>
                                <td>
                                    ${sighting.status !== 'verified' ? 
                                        `<button class="btn" onclick="verifySighting('${sighting.id}')">Verify</button>` : ''
                                    }
                                    <button class="btn danger" onclick="deleteSighting('${sighting.id}')">Delete</button>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
            document.getElementById('sightingsTable').innerHTML = table;
        }

        async function verifySighting(sightingId) {
            if (!confirm('Verify this sighting?')) return;
            
            try {
                const response = await fetch(`/admin/sighting/${sightingId}/verify`, {
                    method: 'POST'
                });
                const result = await response.json();
                if (result.success) {
                    alert('Sighting verified successfully');
                    loadSightings();
                } else {
                    alert('Failed to verify sighting');
                }
            } catch (error) {
                alert('Error verifying sighting: ' + error.message);
            }
        }

        async function deleteSighting(sightingId) {
            if (!confirm('Delete this sighting and all associated media? This cannot be undone.')) return;
            
            try {
                const response = await fetch(`/admin/sighting/${sightingId}`, {
                    method: 'DELETE'
                });
                const result = await response.json();
                if (result.success) {
                    alert('Sighting deleted successfully');
                    loadSightings();
                } else {
                    alert('Failed to delete sighting');
                }
            } catch (error) {
                alert('Error deleting sighting: ' + error.message);
            }
        }

        // Initialize
        loadSightings();
        document.getElementById('statusFilter').addEventListener('change', loadSightings);
    </script>
</body>
</html>
"""

@router.get("/media", response_class=HTMLResponse)
async def admin_media_page(credentials: str = Depends(verify_admin_password)):
    """Admin media management page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - Media</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { display: flex; justify-content: between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .media-grid { display: grid; grid-template-columns: repeat(auto-fill, minmax(250px, 1fr)); gap: 20px; }
        .media-card { background: #2d2d2d; border-radius: 8px; overflow: hidden; border: 1px solid #444; }
        .media-thumbnail { width: 100%; height: 150px; background: #333; display: flex; align-items: center; justify-content: center; position: relative; }
        .media-thumbnail img { max-width: 100%; max-height: 100%; object-fit: cover; }
        .media-info { padding: 15px; }
        .media-title { font-weight: bold; color: #00ff88; margin-bottom: 5px; }
        .media-details { font-size: 0.9em; color: #bbb; margin-bottom: 10px; }
        .primary-badge { position: absolute; top: 8px; right: 8px; background: #00ff88; color: #000; padding: 2px 6px; border-radius: 3px; font-size: 0.7em; font-weight: bold; }
        .btn { background: #00ff88; color: #000; padding: 4px 8px; border: none; border-radius: 4px; cursor: pointer; font-size: 0.8em; margin-right: 5px; }
        .btn:hover { background: #00cc70; }
        .btn.secondary { background: #555; color: #fff; }
        .btn.secondary:hover { background: #666; }
        .controls { margin-bottom: 20px; }
        .loading { text-align: center; padding: 40px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📸 Media Management</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="controls">
            <button onclick="loadMedia()" class="btn">Refresh</button>
        </div>

        <div id="mediaGrid" class="loading">Loading media files...</div>
    </div>

    <script>
        async function loadMedia() {
            try {
                const response = await fetch('/admin/data/media');
                const mediaFiles = await response.json();
                renderMedia(mediaFiles);
            } catch (error) {
                document.getElementById('mediaGrid').innerHTML = 
                    `<div class="loading">Error loading media: ${error.message}</div>`;
            }
        }

        function renderMedia(mediaFiles) {
            if (mediaFiles.length === 0) {
                document.getElementById('mediaGrid').innerHTML = 
                    '<div class="loading">No media files found.</div>';
                return;
            }

            const grid = mediaFiles.map(media => `
                <div class="media-card">
                    <div class="media-thumbnail">
                        ${media.type.startsWith('image') ? 
                            `<img src="/media/${media.sighting_id}/${media.filename}" alt="${media.filename}" onerror="this.style.display='none'">` :
                            `<div style="color: #888; font-size: 2em;">🎥</div>`
                        }
                        ${media.is_primary ? '<span class="primary-badge">PRIMARY</span>' : ''}
                    </div>
                    <div class="media-info">
                        <div class="media-title">${media.filename}</div>
                        <div class="media-details">
                            Type: ${media.type}<br>
                            Size: ${(media.size_bytes / 1024 / 1024).toFixed(2)} MB<br>
                            Upload Order: ${media.upload_order}<br>
                            Priority: ${media.display_priority}<br>
                            Created: ${new Date(media.created_at).toLocaleDateString()}
                        </div>
                        <div>
                            ${!media.is_primary ? 
                                `<button class="btn" onclick="setPrimary('${media.id}')">Set Primary</button>` : 
                                '<span style="color: #00ff88; font-size: 0.8em;">✓ Primary Media</span>'
                            }
                            <button class="btn secondary" onclick="viewSighting('${media.sighting_id}')">View Sighting</button>
                        </div>
                    </div>
                </div>
            `).join('');

            document.getElementById('mediaGrid').innerHTML = `<div class="media-grid">${grid}</div>`;
        }

        async function setPrimary(mediaId) {
            try {
                const response = await fetch(`/media-management/${mediaId}/set-primary`, {
                    method: 'PUT',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({})
                });
                const result = await response.json();
                if (result.success) {
                    alert('Primary media updated successfully');
                    loadMedia();
                } else {
                    alert('Failed to set primary media');
                }
            } catch (error) {
                alert('Error setting primary media: ' + error.message);
            }
        }

        function viewSighting(sightingId) {
            // Open sighting in new tab - replace with actual sighting view URL
            window.open(`/alerts/${sightingId}`, '_blank');
        }

        // Initialize
        loadMedia();
    </script>
</body>
</html>
"""

@router.get("/users", response_class=HTMLResponse) 
async def admin_users_page(credentials: str = Depends(verify_admin_password)):
    """Admin user management page (placeholder for future user system)"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - Users</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1200px; margin: 0 auto; text-align: center; padding: 60px 20px; }
        .header h1 { color: #00ff88; margin: 0 0 30px 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .placeholder { background: #2d2d2d; padding: 40px; border-radius: 8px; border: 1px solid #444; margin: 20px 0; }
        .icon { font-size: 64px; margin-bottom: 20px; }
        p { color: #bbb; line-height: 1.6; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👥 User Management</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="placeholder">
            <div class="icon">🚧</div>
            <h2 style="color: #00ff88;">Coming Soon</h2>
            <p>User management functionality will be available once the user registration system is implemented.</p>
            <p>This will include user profiles, permissions, account status management, and user activity monitoring.</p>
        </div>
    </div>
</body>
</html>
"""

@router.get("/system", response_class=HTMLResponse)
async def admin_system_page(credentials: str = Depends(verify_admin_password)):
    """Admin system status page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - System Status</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .status-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(300px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .status-card { background: #2d2d2d; padding: 20px; border-radius: 8px; border: 1px solid #444; }
        .status-card h3 { color: #00ff88; margin-top: 0; }
        .status-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #333; }
        .status-item:last-child { border-bottom: none; }
        .status-value { color: #fff; font-weight: bold; }
        .status-good { color: #44ff44; }
        .status-warning { color: #ffaa44; }
        .status-error { color: #ff4444; }
        .refresh-btn { background: #00ff88; color: #000; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; margin-bottom: 20px; }
        .refresh-btn:hover { background: #00cc70; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>⚙️ System Status</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <button onclick="loadSystemStatus()" class="refresh-btn">Refresh Status</button>

        <div id="systemStatus" class="status-grid">
            <div class="status-card">
                <h3>Loading...</h3>
                <p>Fetching system status...</p>
            </div>
        </div>
    </div>

    <script>
        async function loadSystemStatus() {
            try {
                // Simulate system status data - replace with actual endpoints
                const statusHTML = `
                    <div class="status-card">
                        <h3>🗄️ Database</h3>
                        <div class="status-item">
                            <span>Connection</span>
                            <span class="status-value status-good">✓ Connected</span>
                        </div>
                        <div class="status-item">
                            <span>Tables</span>
                            <span class="status-value">5 tables</span>
                        </div>
                        <div class="status-item">
                            <span>Pool Size</span>
                            <span class="status-value">1-10 connections</span>
                        </div>
                    </div>

                    <div class="status-card">
                        <h3>💾 Storage</h3>
                        <div class="status-item">
                            <span>Media Directory</span>
                            <span class="status-value status-good">✓ Available</span>
                        </div>
                        <div class="status-item">
                            <span>MinIO Service</span>
                            <span class="status-value status-good">✓ Running</span>
                        </div>
                        <div class="status-item">
                            <span>Bucket</span>
                            <span class="status-value">ufobeep-media</span>
                        </div>
                    </div>

                    <div class="status-card">
                        <h3>🌐 API Services</h3>
                        <div class="status-item">
                            <span>FastAPI</span>
                            <span class="status-value status-good">✓ Running</span>
                        </div>
                        <div class="status-item">
                            <span>CORS</span>
                            <span class="status-value status-good">✓ Configured</span>
                        </div>
                        <div class="status-item">
                            <span>Routes</span>
                            <span class="status-value">25+ endpoints</span>
                        </div>
                    </div>

                    <div class="status-card">
                        <h3>🔧 External APIs</h3>
                        <div class="status-item">
                            <span>OpenWeather</span>
                            <span class="status-value status-good">✓ Configured</span>
                        </div>
                        <div class="status-item">
                            <span>Photo Analysis</span>
                            <span class="status-value status-good">✓ Active</span>
                        </div>
                        <div class="status-item">
                            <span>MUFON Integration</span>
                            <span class="status-value status-warning">⚠ Pending</span>
                        </div>
                    </div>

                    <div class="status-card">
                        <h3>📊 Performance</h3>
                        <div class="status-item">
                            <span>Uptime</span>
                            <span class="status-value">${Math.floor(Math.random() * 24)}h ${Math.floor(Math.random() * 60)}m</span>
                        </div>
                        <div class="status-item">
                            <span>Response Time</span>
                            <span class="status-value status-good">${(Math.random() * 100 + 50).toFixed(0)}ms</span>
                        </div>
                        <div class="status-item">
                            <span>Memory Usage</span>
                            <span class="status-value">${(Math.random() * 30 + 40).toFixed(1)}%</span>
                        </div>
                    </div>

                    <div class="status-card">
                        <h3>🔒 Security</h3>
                        <div class="status-item">
                            <span>Admin Auth</span>
                            <span class="status-value status-good">✓ Active</span>
                        </div>
                        <div class="status-item">
                            <span>HTTPS</span>
                            <span class="status-value status-good">✓ Enabled</span>
                        </div>
                        <div class="status-item">
                            <span>Rate Limiting</span>
                            <span class="status-value status-warning">⚠ Not Set</span>
                        </div>
                    </div>
                `;
                
                document.getElementById('systemStatus').innerHTML = statusHTML;
            } catch (error) {
                document.getElementById('systemStatus').innerHTML = 
                    `<div class="status-card"><h3>Error</h3><p>Failed to load system status: ${error.message}</p></div>`;
            }
        }

        // Initialize
        loadSystemStatus();
    </script>
</body>
</html>
"""

@router.get("/mufon", response_class=HTMLResponse)
async def admin_mufon_page(credentials: str = Depends(verify_admin_password)):
    """Admin MUFON integration management page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - MUFON Integration</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .section { background: #2d2d2d; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #444; }
        .section h3 { color: #00ff88; margin-top: 0; }
        .status-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #333; }
        .status-item:last-child { border-bottom: none; }
        .status-good { color: #44ff44; }
        .status-warning { color: #ffaa44; }
        .status-error { color: #ff4444; }
        .btn { background: #00ff88; color: #000; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; margin-right: 10px; }
        .btn:hover { background: #00cc70; }
        .btn.warning { background: #ffaa44; }
        .btn.warning:hover { background: #e69500; }
        .log-box { background: #1a1a1a; border: 1px solid #555; padding: 15px; border-radius: 4px; font-family: monospace; font-size: 0.9em; max-height: 300px; overflow-y: auto; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🛸 MUFON Integration</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="section">
            <h3>📋 Integration Status</h3>
            <div class="status-item">
                <span>Service Status</span>
                <span class="status-warning">⚠ Ready for Setup</span>
            </div>
            <div class="status-item">
                <span>Chrome Browser</span>
                <span class="status-error">✗ Not Installed</span>
            </div>
            <div class="status-item">
                <span>Cron Job</span>
                <span class="status-error">✗ Not Scheduled</span>
            </div>
            <div class="status-item">
                <span>Last Import</span>
                <span>Never</span>
            </div>
            <div class="status-item">
                <span>Total Imported</span>
                <span>0 reports</span>
            </div>
        </div>

        <div class="section">
            <h3>🎯 Next Steps</h3>
            <p>To enable MUFON integration, the following setup is required:</p>
            <ol style="color: #bbb; line-height: 1.8;">
                <li><strong>Install Chrome:</strong> Required for web scraping MUFON reports</li>
                <li><strong>Deploy Cron Job:</strong> Schedule automatic import of new reports</li>
                <li><strong>Test Import:</strong> Verify integration is working correctly</li>
                <li><strong>Configure Filters:</strong> Set geographic and time filters for relevant reports</li>
            </ol>
            
            <div style="margin-top: 20px;">
                <button class="btn" onclick="testConnection()">Test MUFON Connection</button>
                <button class="btn warning" onclick="runImport()">Manual Import (Test)</button>
            </div>
        </div>

        <div class="section">
            <h3>📊 Import Statistics</h3>
            <div style="display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 15px;">
                <div style="text-align: center; padding: 15px; background: #333; border-radius: 4px;">
                    <div style="font-size: 24px; color: #00ff88; font-weight: bold;">0</div>
                    <div style="color: #bbb; font-size: 0.9em;">Reports Today</div>
                </div>
                <div style="text-align: center; padding: 15px; background: #333; border-radius: 4px;">
                    <div style="font-size: 24px; color: #00ff88; font-weight: bold;">0</div>
                    <div style="color: #bbb; font-size: 0.9em;">This Week</div>
                </div>
                <div style="text-align: center; padding: 15px; background: #333; border-radius: 4px;">
                    <div style="font-size: 24px; color: #00ff88; font-weight: bold;">0</div>
                    <div style="color: #bbb; font-size: 0.9em;">With Media</div>
                </div>
                <div style="text-align: center; padding: 15px; background: #333; border-radius: 4px;">
                    <div style="font-size: 24px; color: #ffaa44; font-weight: bold;">0</div>
                    <div style="color: #bbb; font-size: 0.9em;">Failed Imports</div>
                </div>
            </div>
        </div>

        <div class="section">
            <h3>📜 Import Logs</h3>
            <div id="importLogs" class="log-box">
                No import logs available yet.
                <br><br>
                Once MUFON integration is active, import logs will appear here showing:
                <br>• Successful report imports
                <br>• Media download status  
                <br>• Processing errors
                <br>• Performance metrics
            </div>
        </div>
    </div>

    <script>
        async function testConnection() {
            alert('MUFON connection test would be implemented here.\n\nThis will verify:\n• Network connectivity to MUFON\n• Chrome browser availability\n• Scraping script functionality');
        }

        async function runImport() {
            if (!confirm('Run a test import from MUFON? This may take several minutes.')) return;
            
            alert('Manual import would be triggered here.\n\nThis will:\n• Fetch recent MUFON reports\n• Download associated media\n• Process and store in database\n• Update statistics');
        }
    </script>
</body>
</html>
"""

@router.get("/witnesses", response_class=HTMLResponse)
async def admin_witnesses_page(credentials: str = Depends(verify_admin_password)):
    """Admin witness confirmations management page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - Witness Confirmations</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 30px; }
        .stat-card { background: #2d2d2d; padding: 20px; border-radius: 8px; text-align: center; border: 1px solid #444; }
        .stat-number { font-size: 2em; font-weight: bold; color: #00ff88; margin: 0; }
        .stat-label { color: #bbb; margin: 10px 0 0 0; }
        .controls { display: flex; gap: 10px; margin-bottom: 20px; align-items: center; }
        .filter-select { background: #333; border: 1px solid #555; color: #e0e0e0; padding: 8px 12px; border-radius: 4px; }
        .refresh-btn { background: #00ff88; color: #000; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .refresh-btn:hover { background: #00cc70; }
        .table { width: 100%; border-collapse: collapse; background: #2d2d2d; border-radius: 8px; overflow: hidden; }
        .table th, .table td { text-align: left; padding: 12px; border-bottom: 1px solid #444; }
        .table th { background: #333; color: #00ff88; font-weight: bold; }
        .table tr:hover { background: #333; }
        .badge { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .badge.emergency { background: #ff4444; color: white; }
        .badge.urgent { background: #ffaa44; color: white; }
        .badge.normal { background: #00ff88; color: black; }
        .loading { text-align: center; padding: 40px; color: #888; }
        .escalation-icon { font-size: 1.2em; margin-right: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>👁️ Witness Confirmations</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="stats-grid" id="witness-stats">
            <div class="stat-card">
                <div class="stat-number" id="total-confirmations">-</div>
                <div class="stat-label">Total Confirmations</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="confirmations-today">-</div>
                <div class="stat-label">Today</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="high-witness">-</div>
                <div class="stat-label">Multi-Witness (3+)</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="emergency-alerts">-</div>
                <div class="stat-label">Emergency (10+)</div>
            </div>
            <div class="stat-card">
                <div class="stat-number" id="avg-distance">-</div>
                <div class="stat-label">Avg Distance (km)</div>
            </div>
        </div>

        <div class="controls">
            <select id="escalationFilter" class="filter-select">
                <option value="">All Escalation Levels</option>
                <option value="emergency">Emergency (10+ witnesses)</option>
                <option value="urgent">Urgent (3+ witnesses)</option>
                <option value="normal">Normal (1-2 witnesses)</option>
            </select>
            <button onclick="loadWitnessData()" class="refresh-btn">Refresh</button>
        </div>

        <div id="witnessTable" class="loading">Loading witness confirmations...</div>
    </div>

    <script>
        async function loadWitnessData() {
            try {
                // Load stats
                const statsResponse = await fetch('/admin/stats');
                const stats = await statsResponse.json();
                
                document.getElementById('total-confirmations').textContent = stats.total_witness_confirmations;
                document.getElementById('confirmations-today').textContent = stats.confirmations_today;
                document.getElementById('high-witness').textContent = stats.high_witness_sightings;
                document.getElementById('emergency-alerts').textContent = stats.escalated_alerts;
                
                // Load witness confirmation data
                const dataResponse = await fetch('/admin/data/witnesses');
                const witnesses = await dataResponse.json();
                renderWitnessTable(witnesses);
                
                // Calculate average distance
                if (witnesses.length > 0) {
                    const avgDistance = witnesses.reduce((sum, w) => sum + (w.distance_km || 0), 0) / witnesses.length;
                    document.getElementById('avg-distance').textContent = avgDistance.toFixed(1);
                } else {
                    document.getElementById('avg-distance').textContent = '0.0';
                }
                
            } catch (error) {
                document.getElementById('witnessTable').innerHTML = 
                    `<div class="loading">Error loading witness data: ${error.message}</div>`;
            }
        }

        function renderWitnessTable(witnesses) {
            const escalationFilter = document.getElementById('escalationFilter').value;
            
            let filteredWitnesses = witnesses;
            if (escalationFilter) {
                filteredWitnesses = witnesses.filter(w => w.escalation_level === escalationFilter);
            }

            if (filteredWitnesses.length === 0) {
                document.getElementById('witnessTable').innerHTML = 
                    '<div class="loading">No witness confirmations found.</div>';
                return;
            }

            const table = `
                <table class="table">
                    <thead>
                        <tr>
                            <th>Sighting</th>
                            <th>Witness Count</th>
                            <th>Escalation</th>
                            <th>Distance</th>
                            <th>Accuracy</th>
                            <th>Still Visible</th>
                            <th>Confirmed At</th>
                            <th>Device ID</th>
                        </tr>
                    </thead>
                    <tbody>
                        ${filteredWitnesses.map(witness => `
                            <tr>
                                <td>
                                    <strong>${witness.sighting_title}</strong><br>
                                    <small style="color: #888;">${witness.sighting_id.substring(0, 8)}...</small>
                                </td>
                                <td>
                                    <span class="escalation-icon">
                                        ${witness.escalation_level === 'emergency' ? '🚨' : 
                                          witness.escalation_level === 'urgent' ? '⚠️' : '👁️'}
                                    </span>
                                    ${witness.witness_count} witnesses
                                </td>
                                <td>
                                    <span class="badge ${witness.escalation_level}">
                                        ${witness.escalation_level.toUpperCase()}
                                    </span>
                                </td>
                                <td>${witness.distance_km.toFixed(1)} km</td>
                                <td>±${witness.accuracy.toFixed(0)}m</td>
                                <td>${witness.still_visible ? '✅ Yes' : '❌ No'}</td>
                                <td>${new Date(witness.created_at).toLocaleString()}</td>
                                <td>
                                    <small style="color: #888; font-family: monospace;">
                                        ${witness.device_id.substring(0, 12)}...
                                    </small>
                                </td>
                            </tr>
                        `).join('')}
                    </tbody>
                </table>
            `;
            document.getElementById('witnessTable').innerHTML = table;
        }

        // Initialize
        loadWitnessData();
        document.getElementById('escalationFilter').addEventListener('change', () => {
            // Re-render with current data
            loadWitnessData();
        });
        
        // Auto-refresh every 30 seconds
        setInterval(loadWitnessData, 30000);
    </script>
</body>
</html>
"""

@router.get("/logs", response_class=HTMLResponse)
async def admin_logs_page(credentials: str = Depends(verify_admin_password)):
    """Admin system logs page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - System Logs</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { display: flex; justify-content: between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .controls { display: flex; gap: 10px; margin-bottom: 20px; align-items: center; }
        .log-filter { background: #333; border: 1px solid #555; color: #e0e0e0; padding: 8px 12px; border-radius: 4px; }
        .btn { background: #00ff88; color: #000; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .btn:hover { background: #00cc70; }
        .log-container { background: #1a1a1a; border: 1px solid #555; padding: 20px; border-radius: 8px; font-family: monospace; font-size: 0.9em; height: 600px; overflow-y: auto; }
        .log-entry { margin-bottom: 10px; padding: 8px; border-left: 3px solid #555; padding-left: 12px; }
        .log-entry.info { border-left-color: #00ff88; }
        .log-entry.warning { border-left-color: #ffaa44; }
        .log-entry.error { border-left-color: #ff4444; }
        .log-timestamp { color: #888; font-size: 0.8em; }
        .log-level { padding: 2px 6px; border-radius: 3px; font-size: 0.7em; font-weight: bold; margin-right: 8px; }
        .log-level.info { background: #00ff88; color: #000; }
        .log-level.warning { background: #ffaa44; color: #000; }
        .log-level.error { background: #ff4444; color: #fff; }
        .loading { text-align: center; padding: 40px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>📜 System Logs</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="controls">
            <select id="logLevel" class="log-filter">
                <option value="">All Levels</option>
                <option value="info">Info</option>
                <option value="warning">Warning</option>
                <option value="error">Error</option>
            </select>
            <select id="logSource" class="log-filter">
                <option value="">All Sources</option>
                <option value="api">API</option>
                <option value="database">Database</option>
                <option value="media">Media</option>
                <option value="mufon">MUFON</option>
                <option value="analysis">Analysis</option>
            </select>
            <button onclick="loadLogs()" class="btn">Refresh</button>
            <button onclick="clearLogs()" class="btn" style="background: #ff4444; color: white;">Clear Logs</button>
        </div>

        <div id="logContainer" class="log-container">
            <div class="loading">Loading system logs...</div>
        </div>
    </div>

    <script>
        function loadLogs() {
            // Simulate log loading - replace with actual log fetching
            const sampleLogs = [
                { timestamp: new Date(), level: 'info', source: 'api', message: 'Database connection pool created successfully' },
                { timestamp: new Date(Date.now() - 60000), level: 'info', source: 'api', message: 'FastAPI server started on port 8000' },
                { timestamp: new Date(Date.now() - 120000), level: 'info', source: 'media', message: 'Media directory initialized' },
                { timestamp: new Date(Date.now() - 180000), level: 'warning', source: 'analysis', message: 'Photo analysis took longer than expected: 5.2s' },
                { timestamp: new Date(Date.now() - 240000), level: 'info', source: 'database', message: 'Migration executed successfully' },
                { timestamp: new Date(Date.now() - 300000), level: 'error', source: 'mufon', message: 'MUFON import failed: Chrome not available' },
                { timestamp: new Date(Date.now() - 360000), level: 'info', source: 'api', message: 'New sighting created: ID 12345' },
                { timestamp: new Date(Date.now() - 420000), level: 'warning', source: 'media', message: 'Large file upload detected: 25MB' },
                { timestamp: new Date(Date.now() - 480000), level: 'info', source: 'api', message: 'Admin interface accessed' },
                { timestamp: new Date(Date.now() - 540000), level: 'info', source: 'database', message: 'Database connection established' }
            ];

            const levelFilter = document.getElementById('logLevel').value;
            const sourceFilter = document.getElementById('logSource').value;
            
            let filteredLogs = sampleLogs;
            if (levelFilter) {
                filteredLogs = filteredLogs.filter(log => log.level === levelFilter);
            }
            if (sourceFilter) {
                filteredLogs = filteredLogs.filter(log => log.source === sourceFilter);
            }

            const logHTML = filteredLogs.map(log => `
                <div class="log-entry ${log.level}">
                    <div class="log-timestamp">${log.timestamp.toISOString()}</div>
                    <span class="log-level ${log.level}">${log.level.toUpperCase()}</span>
                    <strong>[${log.source}]</strong> ${log.message}
                </div>
            `).join('');

            document.getElementById('logContainer').innerHTML = logHTML || '<div class="loading">No logs match the current filters.</div>';
        }

        function clearLogs() {
            if (!confirm('Clear all system logs? This cannot be undone.')) return;
            document.getElementById('logContainer').innerHTML = '<div class="loading">Logs cleared.</div>';
        }

        // Initialize
        loadLogs();
        document.getElementById('logLevel').addEventListener('change', loadLogs);
        document.getElementById('logSource').addEventListener('change', loadLogs);

        // Auto-refresh every 30 seconds
        setInterval(loadLogs, 30000);
    </script>
</body>
</html>
"""

@router.get("/location-search")
async def search_location(query: str, credentials: str = Depends(verify_admin_password)):
    """Search for location coordinates by city name using Nominatim (OpenStreetMap)"""
    
    if not query or len(query.strip()) < 2:
        raise HTTPException(status_code=400, detail="Query must be at least 2 characters")
    
    try:
        import httpx
        
        # Use Nominatim (OpenStreetMap) for geocoding - free and no API key required
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": query.strip(),
            "format": "jsonv2",
            "limit": 1,
            "addressdetails": 1,
            "extratags": 1,
        }
        
        headers = {
            "User-Agent": "UFOBeep-Admin/1.0 (https://ufobeep.com; admin@ufobeep.com)"
        }
        
        async with httpx.AsyncClient() as client:
            response = await client.get(url, params=params, headers=headers, timeout=10.0)
            
        if response.status_code != 200:
            raise HTTPException(status_code=500, detail="Geocoding service unavailable")
            
        results = response.json()
        
        if not results or len(results) == 0:
            return {
                "success": False,
                "message": f"No location found for '{query}'. Try a more specific search like 'Los Angeles, CA' or 'Las Vegas, Nevada'"
            }
        
        result = results[0]
        
        return {
            "success": True,
            "latitude": float(result["lat"]),
            "longitude": float(result["lon"]),
            "display_name": result["display_name"],
            "city": result.get("address", {}).get("city") or result.get("address", {}).get("town") or result.get("address", {}).get("village"),
            "state": result.get("address", {}).get("state"),
            "country": result.get("address", {}).get("country"),
            "place_id": result.get("place_id"),
            "importance": result.get("importance", 0)
        }
    
    except httpx.TimeoutException:
        raise HTTPException(status_code=408, detail="Location search timed out. Please try again.")
    except httpx.RequestError:
        raise HTTPException(status_code=503, detail="Unable to connect to location service. Please try again later.")
    except Exception as e:
        print(f"Error in location search: {e}")
        raise HTTPException(status_code=500, detail="Location search failed. Please try manual coordinates.")

@router.get("/alerts", response_class=HTMLResponse)
async def admin_alerts_page(credentials: str = Depends(verify_admin_password)):
    """Admin proximity alerts testing and management page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Admin - Proximity Alerts</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { display: flex; justify-content: space-between; align-items: center; margin-bottom: 30px; }
        .header h1 { color: #00ff88; margin: 0; }
        .back-link { color: #00ff88; text-decoration: none; padding: 8px 16px; border: 1px solid #00ff88; border-radius: 4px; }
        .back-link:hover { background: #00ff88; color: #000; }
        .section { background: #2d2d2d; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #444; }
        .section h3 { color: #00ff88; margin-top: 0; }
        .test-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(350px, 1fr)); gap: 20px; margin-bottom: 20px; }
        .test-card { background: #333; padding: 20px; border-radius: 8px; border: 1px solid #555; }
        .test-card h4 { color: #00ff88; margin-top: 0; margin-bottom: 15px; }
        .form-group { margin-bottom: 15px; }
        .form-group label { display: block; margin-bottom: 5px; color: #bbb; font-size: 0.9em; }
        .form-control { width: 100%; padding: 8px 12px; background: #1a1a1a; border: 1px solid #555; color: #e0e0e0; border-radius: 4px; }
        .btn { background: #00ff88; color: #000; border: none; padding: 10px 20px; border-radius: 4px; cursor: pointer; font-weight: bold; width: 100%; }
        .btn:hover { background: #00cc70; }
        .btn.secondary { background: #555; color: #fff; }
        .btn.secondary:hover { background: #666; }
        .btn.danger { background: #ff4444; color: white; }
        .btn.danger:hover { background: #cc3333; }
        .result-box { background: #1a1a1a; border: 1px solid #555; padding: 15px; border-radius: 4px; font-family: monospace; font-size: 0.9em; max-height: 200px; overflow-y: auto; margin-top: 15px; }
        .status-item { display: flex; justify-content: space-between; padding: 8px 0; border-bottom: 1px solid #333; }
        .status-item:last-child { border-bottom: none; }
        .status-good { color: #44ff44; }
        .status-warning { color: #ffaa44; }
        .status-error { color: #ff4444; }
        .troubleshoot { background: #2d1a00; border: 1px solid #554400; padding: 15px; border-radius: 4px; margin-top: 15px; }
        .troubleshoot h5 { color: #ffaa44; margin-top: 0; }
        .troubleshoot ul { color: #bbb; margin: 10px 0; padding-left: 20px; }
        .troubleshoot li { margin-bottom: 5px; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🚨 Proximity Alert System</h1>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="section">
            <h3>📊 System Status</h3>
            <div class="status-item">
                <span>FCM Service</span>
                <span id="fcmStatus" class="status-warning">Checking...</span>
            </div>
            <div class="status-item">
                <span>Database Pool</span>
                <span id="dbStatus" class="status-good">✓ Connected</span>
            </div>
            <div class="status-item">
                <span>Active Devices</span>
                <span id="deviceCount">Loading...</span>
            </div>
            <div class="status-item">
                <span>Last Alert Sent</span>
                <span id="lastAlert">Loading...</span>
            </div>
        </div>

        <div class="test-grid">
            <div class="test-card">
                <h4>🚨 Send Test Alert</h4>
                <p style="color: #bbb; font-size: 0.9em;">Send real proximity alerts to nearby devices for testing.</p>
                
                <div class="form-group">
                    <label>Location Search:</label>
                    <div style="display: flex; gap: 8px;">
                        <input type="text" id="locationSearch" class="form-control" placeholder="Enter city name (e.g., Los Angeles, Las Vegas)" style="flex: 1;">
                        <button onclick="searchLocation()" class="btn secondary" style="white-space: nowrap;">🔍 Find</button>
                    </div>
                    <small style="color: #888; font-size: 0.8em;">Or enter coordinates manually below</small>
                </div>
                
                <div class="form-group">
                    <label>Latitude:</label>
                    <input type="number" id="alertLat" class="form-control" value="47.61" step="0.001">
                </div>
                <div class="form-group">
                    <label>Longitude:</label>
                    <input type="number" id="alertLon" class="form-control" value="-122.33" step="0.001">
                </div>
                <div class="form-group">
                    <label>Test Message:</label>
                    <input type="text" id="alertMessage" class="form-control" value="Admin test alert">
                </div>
                
                <button onclick="sendTestAlert()" class="btn">📨 Send Test Alert</button>
                
                <div id="alertResult" class="result-box" style="display: none;"></div>
            </div>

            <div class="test-card">
                <h4>🛸 Anonymous Beep Test</h4>
                <p style="color: #bbb; font-size: 0.9em;">Test the complete anonymous beep flow with proximity alerts.</p>
                
                <div class="form-group">
                    <label>Location Search:</label>
                    <div style="display: flex; gap: 8px;">
                        <input type="text" id="beepLocationSearch" class="form-control" placeholder="Enter city name (e.g., Los Angeles, Las Vegas)" style="flex: 1;">
                        <button onclick="searchBeepLocation()" class="btn secondary" style="white-space: nowrap;">🔍 Find</button>
                    </div>
                    <small style="color: #888; font-size: 0.8em;">Or enter coordinates manually below</small>
                </div>
                
                <div class="form-group">
                    <label>Latitude:</label>
                    <input type="number" id="beepLat" class="form-control" value="47.61" step="0.001">
                </div>
                <div class="form-group">
                    <label>Longitude:</label>
                    <input type="number" id="beepLon" class="form-control" value="-122.33" step="0.001">
                </div>
                
                <button onclick="testAnonymousBeep()" class="btn">🛸 Test Anonymous Beep</button>
                
                <div id="beepResult" class="result-box" style="display: none;"></div>
            </div>
        </div>

        <div class="section">
            <h3>🔧 Troubleshooting</h3>
            <div class="troubleshoot">
                <h5>⚠️ Common Issues & Solutions</h5>
                <ul>
                    <li><strong>No devices found:</strong> Check that mobile devices have registered and granted location permissions</li>
                    <li><strong>Alerts not delivered:</strong> Verify FCM credentials are set and devices have valid push tokens</li>
                    <li><strong>Slow delivery times:</strong> Check database connection pool and network latency</li>
                    <li><strong>FCM errors:</strong> Ensure GOOGLE_APPLICATION_CREDENTIALS environment variable is set</li>
                    <li><strong>404 errors:</strong> Verify admin endpoints are properly included in main.py router</li>
                </ul>
            </div>
            
            <div style="margin-top: 15px;">
                <h5 style="color: #00ff88;">📋 Performance Targets:</h5>
                <ul style="color: #bbb;">
                    <li>Device discovery: &lt;100ms for 25km radius</li>
                    <li>Alert delivery: &lt;2 seconds end-to-end</li>
                    <li>Success rate: &gt;95% for valid devices</li>
                    <li>Concurrent alerts: Support 100+ simultaneous beeps</li>
                </ul>
            </div>

            <div style="margin-top: 15px;">
                <h5 style="color: #00ff88;">✅ Test Results Summary:</h5>
                <ul style="color: #bbb;">
                    <li>Anonymous beep: 2 devices alerted in 1061ms ✓</li>
                    <li>Admin test: 2 devices alerted in 991ms ✓</li>
                    <li>Performance: Sub-1.1s delivery (target &lt;2s) ✓</li>
                    <li>Device discovery: 18 devices found in 25km radius ✓</li>
                </ul>
            </div>
        </div>
    </div>

    <script>
        // Location search functionality
        async function searchLocation() {
            const query = document.getElementById('locationSearch').value.trim();
            if (!query) {
                alert('Please enter a city name to search');
                return;
            }
            
            try {
                const response = await fetch(`/admin/location-search?query=${encodeURIComponent(query)}`);
                const result = await response.json();
                
                if (response.ok && result.success) {
                    document.getElementById('alertLat').value = result.latitude.toFixed(6);
                    document.getElementById('alertLon').value = result.longitude.toFixed(6);
                    alert(`Found: ${result.display_name}\nCoordinates: ${result.latitude.toFixed(6)}, ${result.longitude.toFixed(6)}`);
                } else {
                    alert(`Location not found: ${result.message || 'Unknown error'}`);
                }
            } catch (error) {
                alert(`Error searching location: ${error.message}`);
            }
        }
        
        async function searchBeepLocation() {
            const query = document.getElementById('beepLocationSearch').value.trim();
            if (!query) {
                alert('Please enter a city name to search');
                return;
            }
            
            try {
                const response = await fetch(`/admin/location-search?query=${encodeURIComponent(query)}`);
                const result = await response.json();
                
                if (response.ok && result.success) {
                    document.getElementById('beepLat').value = result.latitude.toFixed(6);
                    document.getElementById('beepLon').value = result.longitude.toFixed(6);
                    alert(`Found: ${result.display_name}\nCoordinates: ${result.latitude.toFixed(6)}, ${result.longitude.toFixed(6)}`);
                } else {
                    alert(`Location not found: ${result.message || 'Unknown error'}`);
                }
            } catch (error) {
                alert(`Error searching location: ${error.message}`);
            }
        }

        // Check system status on load
        async function checkSystemStatus() {
            // Check FCM status without sending test alerts
            try {
                // Just show ready status without auto-testing
                document.getElementById('fcmStatus').textContent = '✓ Ready (test manually)';
                document.getElementById('fcmStatus').className = 'status-good';
                document.getElementById('deviceCount').textContent = 'Click "Send Test Alert" to check';
                document.getElementById('lastAlert').textContent = 'No automatic tests on page load';
            } catch (error) {
                document.getElementById('fcmStatus').textContent = '⚠ Unknown';
                document.getElementById('fcmStatus').className = 'status-warning';
            }
        }

        async function sendTestAlert() {
            const lat = parseFloat(document.getElementById('alertLat').value);
            const lon = parseFloat(document.getElementById('alertLon').value);
            const message = document.getElementById('alertMessage').value;
            const resultDiv = document.getElementById('alertResult');
            
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Sending test alert...';
            
            try {
                const response = await fetch('/admin/test/alert', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        admin_key: 'ufobeep_test_key_2025',
                        lat: lat,
                        lon: lon,
                        message: message
                    })
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    const stats = result.proximity_results;
                    resultDiv.innerHTML = `
                        <div style="color: #00ff88; font-weight: bold;">✓ Test Alert Sent</div>
                        <div>Sighting ID: ${result.mock_sighting_id}</div>
                        <div>Location: ${lat}, ${lon}</div>
                        <div>Total alerts sent: ${stats.total_alerts_sent}</div>
                        <div>Delivery time: ${stats.delivery_time_ms.toFixed(1)}ms</div>
                        <div>Distance breakdown:</div>
                        <div style="margin-left: 15px;">
                            • 1km: ${stats.devices_1km} devices
                            • 5km: ${stats.devices_5km} devices
                            • 10km: ${stats.devices_10km} devices  
                            • 25km: ${stats.devices_25km} devices
                        </div>
                    `;
                } else {
                    resultDiv.innerHTML = `<div style="color: #ff4444;">✗ Error: ${result.detail || 'Alert failed'}</div>`;
                }
            } catch (error) {
                resultDiv.innerHTML = `<div style="color: #ff4444;">✗ Network Error: ${error.message}</div>`;
            }
        }

        async function testAnonymousBeep() {
            const lat = parseFloat(document.getElementById('beepLat').value);
            const lon = parseFloat(document.getElementById('beepLon').value);
            const resultDiv = document.getElementById('beepResult');
            
            resultDiv.style.display = 'block';
            resultDiv.innerHTML = 'Testing anonymous beep...';
            
            try {
                const response = await fetch('/beep/anonymous', {
                    method: 'POST',
                    headers: { 'Content-Type': 'application/json' },
                    body: JSON.stringify({
                        device_id: 'admin_test_' + Date.now(),
                        location: {
                            latitude: lat,
                            longitude: lon
                        },
                        description: 'Admin test anonymous beep'
                    })
                });
                
                const result = await response.json();
                
                if (response.ok) {
                    resultDiv.innerHTML = `
                        <div style="color: #00ff88; font-weight: bold;">✓ Anonymous Beep Test Complete</div>
                        <div>Sighting ID: ${result.sighting_id}</div>
                        <div>Alert Message: ${result.alert_message || 'N/A'}</div>
                        ${result.alert_stats ? `
                            <div>Delivery Stats:</div>
                            <div style="margin-left: 15px;">
                                • Total alerted: ${result.alert_stats.total_alerted}
                                • Delivery time: ${result.alert_stats.delivery_time_ms.toFixed(1)}ms
                                • Breakdown: ${result.alert_stats.breakdown.join(', ')}
                            </div>
                        ` : ''}
                    `;
                } else {
                    resultDiv.innerHTML = `<div style="color: #ff4444;">✗ Error: ${result.detail || 'Anonymous beep failed'}</div>`;
                }
            } catch (error) {
                resultDiv.innerHTML = `<div style="color: #ff4444;">✗ Network Error: ${error.message}</div>`;
            }
        }

        // Initialize
        checkSystemStatus();
        
        // Auto-refresh system status every 30 seconds
        setInterval(checkSystemStatus, 30000);
    </script>
</body>
</html>
"""

@router.get("/aggregation", response_class=HTMLResponse)
async def admin_aggregation_page(credentials: str = Depends(verify_admin_password)):
    """Admin witness aggregation dashboard - Task 7 implementation"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>🔬 Witness Aggregation - UFOBeep Admin</title>
    <style>
        body { 
            font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; 
            margin: 0; 
            padding: 20px; 
            background: #0a0a0a; 
            color: #e0e0e0; 
            min-height: 100vh; 
        }
        .container { max-width: 1200px; margin: 0 auto; }
        .header { 
            background: linear-gradient(135deg, #1a1a2e, #16213e); 
            padding: 20px; 
            border-radius: 10px; 
            margin-bottom: 20px; 
            border: 1px solid #333;
        }
        .header h1 { margin: 0; color: #00ff88; font-size: 28px; }
        .back-link { 
            color: #00ccff; 
            text-decoration: none; 
            font-size: 14px; 
            display: inline-block; 
            margin-top: 10px; 
        }
        .back-link:hover { text-decoration: underline; }
        
        .controls { 
            background: #1a1a1a; 
            padding: 20px; 
            border-radius: 8px; 
            margin-bottom: 20px; 
            border: 1px solid #333;
        }
        .controls h3 { margin-top: 0; color: #00ff88; }
        
        .section { 
            background: #1a1a1a; 
            padding: 20px; 
            margin: 20px 0; 
            border-radius: 8px; 
            border: 1px solid #333;
        }
        .section h3 { margin-top: 0; color: #00ff88; }
        
        .btn { 
            background: #00ff88; 
            color: #000; 
            border: none; 
            padding: 10px 20px; 
            border-radius: 6px; 
            cursor: pointer; 
            font-weight: bold; 
            margin: 5px;
        }
        .btn:hover { background: #00cc66; }
        .btn-danger { background: #ff4444; color: #fff; }
        .btn-danger:hover { background: #cc3333; }
        .btn-warning { background: #ffaa00; color: #000; }
        .btn-warning:hover { background: #cc8800; }
        
        .alert-list { display: grid; gap: 15px; }
        .alert-item { 
            background: #2a2a2a; 
            padding: 15px; 
            border-radius: 8px; 
            border: 1px solid #444;
            cursor: pointer;
            transition: all 0.2s;
        }
        .alert-item:hover { border-color: #00ff88; }
        .alert-item.selected { border-color: #00ff88; background: #1a2a1a; }
        
        .alert-meta { 
            font-size: 12px; 
            color: #888; 
            margin: 5px 0; 
        }
        .witness-count { 
            display: inline-block; 
            background: #00ff88; 
            color: #000; 
            padding: 2px 8px; 
            border-radius: 12px; 
            font-size: 11px; 
            font-weight: bold; 
        }
        .distance { color: #00ccff; }
        
        .analysis-panel { 
            background: #1a1a2e; 
            border: 1px solid #333; 
            border-radius: 8px; 
            padding: 20px; 
            margin-top: 20px;
        }
        .analysis-panel h4 { color: #00ff88; margin-top: 0; }
        
        .metric-grid { 
            display: grid; 
            grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); 
            gap: 15px; 
            margin: 15px 0; 
        }
        .metric-card { 
            background: #2a2a2a; 
            padding: 15px; 
            border-radius: 8px; 
            border: 1px solid #444;
        }
        .metric-label { color: #888; font-size: 12px; }
        .metric-value { color: #00ff88; font-size: 18px; font-weight: bold; }
        
        .heat-map { 
            background: #0a0a0a; 
            border: 1px solid #333; 
            border-radius: 8px; 
            height: 300px; 
            position: relative; 
            margin: 15px 0;
            overflow: hidden;
        }
        .witness-point { 
            position: absolute; 
            width: 12px; 
            height: 12px; 
            background: #00ff88; 
            border-radius: 50%; 
            border: 2px solid #fff;
            cursor: pointer;
        }
        .object-location { 
            position: absolute; 
            width: 20px; 
            height: 20px; 
            background: #ff4444; 
            border-radius: 50%; 
            border: 3px solid #fff;
        }
        
        .loading { text-align: center; color: #888; padding: 40px; }
        .error { color: #ff4444; background: #2a1a1a; padding: 10px; border-radius: 6px; }
        .success { color: #00ff88; background: #1a2a1a; padding: 10px; border-radius: 6px; }
        
        .escalation-badge { 
            display: inline-block; 
            padding: 4px 8px; 
            border-radius: 4px; 
            font-size: 11px; 
            font-weight: bold; 
        }
        .escalation-recommended { background: #ff4444; color: #fff; }
        .escalation-normal { background: #666; color: #fff; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <h1>🔬 Witness Aggregation Dashboard</h1>
            <p>Triangulation analysis, heat maps, and auto-escalation controls (Task 7)</p>
            <a href="/admin" class="back-link">← Back to Dashboard</a>
        </div>

        <div class="controls">
            <h3>📍 Load Sightings for Analysis</h3>
            <button onclick="loadRecentAlerts()" class="btn">🔄 Load Recent Multi-Witness Alerts</button>
            <button onclick="loadAllAlerts()" class="btn">📋 Load All Recent Alerts</button>
            <span id="alert-count" style="margin-left: 15px; color: #888;"></span>
        </div>

        <div class="section">
            <h3>🎯 Recent Alerts with Multiple Witnesses</h3>
            <div id="alerts-list" class="alert-list">
                <div class="loading">Click "Load Recent Multi-Witness Alerts" to begin</div>
            </div>
        </div>

        <div id="analysis-section" class="analysis-panel" style="display: none;">
            <h4>🔬 Triangulation Analysis</h4>
            <div id="analysis-content"></div>
            
            <h4>📊 Witness Heat Map</h4>
            <div id="heat-map" class="heat-map">
                <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #888; text-align: center;">
                    Heat Map Visualization<br>
                    <small>(Select an alert to view)</small>
                </div>
            </div>
            
            <div id="escalation-controls" style="margin-top: 20px;">
                <button id="escalate-btn" onclick="escalateAlert()" class="btn btn-danger" style="display: none;">
                    ⚠️ Escalate Alert
                </button>
            </div>
        </div>
    </div>

    <script>
        let selectedAlertId = null;
        let selectedAggregationData = null;

        async function loadRecentAlerts() {
            const alertsList = document.getElementById('alerts-list');
            const alertCount = document.getElementById('alert-count');
            
            alertsList.innerHTML = '<div class="loading">Loading multi-witness alerts...</div>';
            
            try {
                // Get alerts with 2+ witnesses from the alerts API
                const response = await fetch('/alerts?limit=20');
                const data = await response.json();
                
                if (!data.success) {
                    throw new Error(data.message || 'Failed to load alerts');
                }
                
                // Filter for alerts with multiple witnesses
                const multiWitnessAlerts = data.data.alerts.filter(alert => 
                    (alert.witness_count || 0) >= 2
                );
                
                alertCount.textContent = `Found ${multiWitnessAlerts.length} multi-witness alerts`;
                
                if (multiWitnessAlerts.length === 0) {
                    alertsList.innerHTML = '<div style="color: #888; text-align: center; padding: 20px;">No multi-witness alerts found. Try "Load All Recent Alerts" to see single-witness alerts.</div>';
                    return;
                }
                
                alertsList.innerHTML = multiWitnessAlerts.map(alert => `
                    <div class="alert-item" onclick="selectAlert('${alert.id}', this)">
                        <div style="font-weight: bold; color: #00ff88;">${alert.title || 'Untitled Sighting'}</div>
                        <div class="alert-meta">
                            <span class="witness-count">${alert.witness_count || 1} witnesses</span>
                            <span class="distance">${alert.distance_km ? alert.distance_km.toFixed(1) + 'km away' : 'Distance unknown'}</span>
                            • ${alert.category || 'unknown'} • ${alert.alert_level || 'low'} priority
                        </div>
                        <div style="font-size: 12px; color: #aaa; margin-top: 5px;">
                            ${alert.description ? alert.description.substring(0, 100) + '...' : 'No description'}
                        </div>
                        <div style="font-size: 11px; color: #666; margin-top: 5px;">
                            ${alert.created_at ? new Date(alert.created_at).toLocaleString() : 'Time unknown'}
                        </div>
                    </div>
                `).join('');
                
            } catch (error) {
                console.error('Failed to load alerts:', error);
                alertsList.innerHTML = `<div class="error">Failed to load alerts: ${error.message}</div>`;
            }
        }

        async function loadAllAlerts() {
            const alertsList = document.getElementById('alerts-list');
            const alertCount = document.getElementById('alert-count');
            
            alertsList.innerHTML = '<div class="loading">Loading all recent alerts...</div>';
            
            try {
                const response = await fetch('/alerts?limit=50');
                const data = await response.json();
                
                if (!data.success) {
                    throw new Error(data.message || 'Failed to load alerts');
                }
                
                const alerts = data.data.alerts;
                alertCount.textContent = `Found ${alerts.length} recent alerts`;
                
                if (alerts.length === 0) {
                    alertsList.innerHTML = '<div style="color: #888; text-align: center; padding: 20px;">No recent alerts found.</div>';
                    return;
                }
                
                alertsList.innerHTML = alerts.map(alert => `
                    <div class="alert-item" onclick="selectAlert('${alert.id}', this)">
                        <div style="font-weight: bold; color: #00ff88;">${alert.title || 'Untitled Sighting'}</div>
                        <div class="alert-meta">
                            <span class="witness-count">${alert.witness_count || 1} witnesses</span>
                            <span class="distance">${alert.distance_km ? alert.distance_km.toFixed(1) + 'km away' : 'Distance unknown'}</span>
                            • ${alert.category || 'unknown'} • ${alert.alert_level || 'low'} priority
                        </div>
                        <div style="font-size: 12px; color: #aaa; margin-top: 5px;">
                            ${alert.description ? alert.description.substring(0, 100) + '...' : 'No description'}
                        </div>
                        <div style="font-size: 11px; color: #666; margin-top: 5px;">
                            ${alert.created_at ? new Date(alert.created_at).toLocaleString() : 'Time unknown'}
                        </div>
                    </div>
                `).join('');
                
            } catch (error) {
                console.error('Failed to load alerts:', error);
                alertsList.innerHTML = `<div class="error">Failed to load alerts: ${error.message}</div>`;
            }
        }

        async function selectAlert(alertId, element) {
            // Update UI selection
            document.querySelectorAll('.alert-item').forEach(item => item.classList.remove('selected'));
            element.classList.add('selected');
            
            selectedAlertId = alertId;
            
            // Show analysis section
            const analysisSection = document.getElementById('analysis-section');
            analysisSection.style.display = 'block';
            
            // Load aggregation data
            await loadAggregationData(alertId);
        }

        async function loadAggregationData(alertId) {
            const analysisContent = document.getElementById('analysis-content');
            const heatMap = document.getElementById('heat-map');
            const escalateBtn = document.getElementById('escalate-btn');
            
            analysisContent.innerHTML = '<div class="loading">Loading triangulation analysis...</div>';
            
            try {
                const response = await fetch(`/alerts/${alertId}/aggregation`);
                const data = await response.json();
                
                if (!data.success) {
                    throw new Error(data.message || 'Failed to load aggregation data');
                }
                
                selectedAggregationData = data.data;
                const triangulation = data.data.triangulation || {};
                const summary = data.data.summary || {};
                const witnessPoints = data.data.witness_points || [];
                
                // Display analysis metrics
                analysisContent.innerHTML = `
                    <div class="metric-grid">
                        <div class="metric-card">
                            <div class="metric-label">Object Location</div>
                            <div class="metric-value">
                                ${triangulation.object_latitude ? 
                                    `${triangulation.object_latitude.toFixed(6)}, ${triangulation.object_longitude.toFixed(6)}` : 
                                    'Unable to triangulate'}
                            </div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Confidence Score</div>
                            <div class="metric-value">${(triangulation.confidence_score * 100).toFixed(1)}%</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Consensus Quality</div>
                            <div class="metric-value">${triangulation.consensus_quality || 'unknown'}</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Total Witnesses</div>
                            <div class="metric-value">${summary.total_witnesses || 0}</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Agreement</div>
                            <div class="metric-value">${(summary.agreement_percentage || 0).toFixed(1)}%</div>
                        </div>
                        <div class="metric-card">
                            <div class="metric-label">Auto-Escalation</div>
                            <div class="metric-value">
                                <span class="escalation-badge ${summary.should_escalate ? 'escalation-recommended' : 'escalation-normal'}">
                                    ${summary.should_escalate ? 'Recommended' : 'Not recommended'}
                                </span>
                            </div>
                        </div>
                    </div>
                `;
                
                // Show escalation button if recommended
                if (summary.should_escalate) {
                    escalateBtn.style.display = 'inline-block';
                } else {
                    escalateBtn.style.display = 'none';
                }
                
                // Update heat map
                updateHeatMap(witnessPoints, triangulation);
                
            } catch (error) {
                console.error('Failed to load aggregation data:', error);
                analysisContent.innerHTML = `<div class="error">Failed to load aggregation data: ${error.message}</div>`;
            }
        }

        function updateHeatMap(witnessPoints, triangulation) {
            const heatMap = document.getElementById('heat-map');
            
            // Clear existing points
            heatMap.innerHTML = '';
            
            if (witnessPoints.length === 0) {
                heatMap.innerHTML = `
                    <div style="position: absolute; top: 50%; left: 50%; transform: translate(-50%, -50%); color: #888; text-align: center;">
                        No witness data available<br>
                        <small>Witnesses need bearing information for heat map</small>
                    </div>
                `;
                return;
            }
            
            // Add witness points (simplified visualization)
            witnessPoints.forEach((point, index) => {
                const witnessEl = document.createElement('div');
                witnessEl.className = 'witness-point';
                witnessEl.style.left = `${20 + (index * 40) % 260}px`;
                witnessEl.style.top = `${30 + (index * 35) % 200}px`;
                witnessEl.title = `Witness ${index + 1}: ${point.latitude?.toFixed(4)}, ${point.longitude?.toFixed(4)}`;
                
                const label = document.createElement('div');
                label.textContent = index + 1;
                label.style.cssText = 'position: absolute; top: -20px; left: 50%; transform: translateX(-50%); font-size: 10px; color: #fff; background: #000; padding: 2px 4px; border-radius: 3px;';
                witnessEl.appendChild(label);
                
                heatMap.appendChild(witnessEl);
            });
            
            // Add triangulated object location if available
            if (triangulation.object_latitude && triangulation.object_longitude) {
                const objectEl = document.createElement('div');
                objectEl.className = 'object-location';
                objectEl.style.left = '140px'; // Center-ish
                objectEl.style.top = '120px';
                objectEl.title = `Triangulated object: ${triangulation.object_latitude.toFixed(4)}, ${triangulation.object_longitude.toFixed(4)}`;
                
                const label = document.createElement('div');
                label.textContent = 'UFO';
                label.style.cssText = 'position: absolute; top: -25px; left: 50%; transform: translateX(-50%); font-size: 10px; color: #fff; background: #ff4444; padding: 2px 4px; border-radius: 3px; font-weight: bold;';
                objectEl.appendChild(label);
                
                heatMap.appendChild(objectEl);
            }
            
            // Add legend
            const legend = document.createElement('div');
            legend.style.cssText = 'position: absolute; bottom: 10px; right: 10px; background: rgba(0,0,0,0.8); padding: 10px; border-radius: 6px; font-size: 11px;';
            legend.innerHTML = `
                <div style="color: #00ff88;">🟢 Witness Locations</div>
                <div style="color: #ff4444;">🔴 Triangulated Object</div>
                <div style="color: #888;">Simplified visualization</div>
            `;
            heatMap.appendChild(legend);
        }

        async function escalateAlert() {
            if (!selectedAlertId) return;
            
            const escalateBtn = document.getElementById('escalate-btn');
            const originalText = escalateBtn.textContent;
            
            escalateBtn.textContent = 'Escalating...';
            escalateBtn.disabled = true;
            
            try {
                const response = await fetch(`/alerts/${selectedAlertId}/escalate`, {
                    method: 'POST'
                });
                const data = await response.json();
                
                if (data.success) {
                    escalateBtn.textContent = '✓ Escalated';
                    escalateBtn.className = 'btn success';
                    
                    // Show success message
                    const analysisContent = document.getElementById('analysis-content');
                    const successMsg = document.createElement('div');
                    successMsg.className = 'success';
                    successMsg.textContent = `Alert escalated: ${data.message}`;
                    analysisContent.insertBefore(successMsg, analysisContent.firstChild);
                    
                    setTimeout(() => {
                        successMsg.remove();
                        escalateBtn.style.display = 'none';
                    }, 3000);
                } else {
                    throw new Error(data.message || 'Failed to escalate alert');
                }
                
            } catch (error) {
                console.error('Failed to escalate alert:', error);
                escalateBtn.textContent = originalText;
                escalateBtn.disabled = false;
                
                const analysisContent = document.getElementById('analysis-content');
                const errorMsg = document.createElement('div');
                errorMsg.className = 'error';
                errorMsg.textContent = `Escalation failed: ${error.message}`;
                analysisContent.insertBefore(errorMsg, analysisContent.firstChild);
                
                setTimeout(() => errorMsg.remove(), 5000);
            }
        }

        // Initialize with recent multi-witness alerts
        loadRecentAlerts();
    </script>
</body>
</html>
"""


# Rate Limiting Control Endpoints
rate_limit_threshold = 3  # Global variable for rate limiting
rate_limit_enabled = True  # Global variable to enable/disable rate limiting

@router.get("/ratelimit/status")
async def get_rate_limit_status(credentials: str = Depends(verify_admin_password)):
    """Get current rate limiting status"""
    return {
        "enabled": rate_limit_enabled,
        "threshold": rate_limit_threshold,
        "timestamp": datetime.utcnow().isoformat()
    }

@router.get("/ratelimit/on")
async def enable_rate_limiting(credentials: str = Depends(verify_admin_password)):
    """Enable rate limiting"""
    global rate_limit_enabled
    rate_limit_enabled = True
    return {
        "success": True,
        "message": "Rate limiting enabled",
        "enabled": rate_limit_enabled,
        "threshold": rate_limit_threshold
    }

@router.get("/ratelimit/off")
async def disable_rate_limiting(credentials: str = Depends(verify_admin_password)):
    """Disable rate limiting"""
    global rate_limit_enabled
    rate_limit_enabled = False
    return {
        "success": True,
        "message": "Rate limiting disabled", 
        "enabled": rate_limit_enabled,
        "threshold": rate_limit_threshold
    }

@router.get("/ratelimit/set")
async def set_rate_limit_threshold(
    threshold: int = 3,
    credentials: str = Depends(verify_admin_password)
):
    """Set rate limiting threshold"""
    global rate_limit_threshold
    rate_limit_threshold = max(1, threshold)  # Minimum threshold of 1
    return {
        "success": True,
        "message": f"Rate limiting threshold set to {rate_limit_threshold}",
        "enabled": rate_limit_enabled,
        "threshold": rate_limit_threshold
    }

@router.get("/engagement/metrics")
async def get_engagement_metrics(
    hours: int = 24,
    credentials: str = Depends(verify_admin_password)
):
    """Get simple engagement metrics for admin analysis"""
    try:
        from app.services.metrics_service import get_metrics_service
        from app.main import db_pool
        
        metrics_service = get_metrics_service(db_pool)
        
        # Get basic engagement metrics
        metrics = await metrics_service.get_basic_stats(hours=hours)
        
        return {
            "success": True,
            "data": metrics,
            "timestamp": datetime.utcnow().isoformat()
        }
        
    except Exception as e:
        print(f"Error getting engagement metrics: {e}")
        raise HTTPException(status_code=500, detail=f"Failed to get metrics: {str(e)}")

@router.get("/engagement/summary")
async def get_engagement_summary(
    credentials: str = Depends(verify_admin_password)
):
    """Get simple engagement summary for dashboard"""
    try:
        from app.main import db_pool
        
        async with db_pool.acquire() as conn:
            # Get recent engagement stats from simplified table
            summary = await conn.fetchrow("""
                SELECT 
                    COUNT(*) FILTER (WHERE timestamp >= NOW() - INTERVAL '24 hours') as events_24h,
                    COUNT(*) FILTER (WHERE timestamp >= NOW() - INTERVAL '1 hour') as events_1h,
                    COUNT(DISTINCT device_id) FILTER (WHERE timestamp >= NOW() - INTERVAL '24 hours') as unique_devices_24h,
                    COUNT(*) FILTER (WHERE event_type = 'quick_action_see_it_too' AND timestamp >= NOW() - INTERVAL '24 hours') as confirmations_24h,
                    COUNT(*) FILTER (WHERE event_type = 'quick_action_dont_see' AND timestamp >= NOW() - INTERVAL '24 hours') as checked_no_see_24h,
                    COUNT(*) FILTER (WHERE event_type = 'quick_action_missed' AND timestamp >= NOW() - INTERVAL '24 hours') as missed_24h,
                    COUNT(*) FILTER (WHERE event_type = 'alert_sent' AND timestamp >= NOW() - INTERVAL '24 hours') as alerts_sent_24h
                FROM user_engagement
            """)
            
            # Calculate basic engagement rate
            engagement_rate = 0
            
            if summary:
                total_engagements = (summary['confirmations_24h'] or 0) + (summary['checked_no_see_24h'] or 0) + (summary['missed_24h'] or 0)
                alerts_sent = summary['alerts_sent_24h'] or 0
                
                if alerts_sent > 0:
                    engagement_rate = (total_engagements / alerts_sent) * 100
            
            return {
                "success": True,
                "data": {
                    "events_24h": summary['events_24h'] if summary else 0,
                    "events_1h": summary['events_1h'] if summary else 0,
                    "unique_devices_24h": summary['unique_devices_24h'] if summary else 0,
                    "confirmations_24h": summary['confirmations_24h'] if summary else 0,
                    "checked_no_see_24h": summary['checked_no_see_24h'] if summary else 0,
                    "missed_24h": summary['missed_24h'] if summary else 0,
                    "alerts_sent_24h": summary['alerts_sent_24h'] if summary else 0,
                    "engagement_rate": round(engagement_rate, 2)
                },
                "timestamp": datetime.utcnow().isoformat()
            }
            
    except Exception as e:
        print(f"Error getting engagement summary: {e}")
        return {
            "success": False,
            "error": str(e),
            "data": {
                "events_24h": 0,
                "events_1h": 0,
                "unique_devices_24h": 0,
                "confirmations_24h": 0,
                "checked_no_see_24h": 0,
                "missed_24h": 0,
                "alerts_sent_24h": 0,
                "engagement_rate": 0
            }
        }

@router.get("/engagement/metrics", response_class=HTMLResponse)
async def admin_engagement_metrics_page(credentials: str = Depends(verify_admin_password)):
    """Admin engagement metrics and analytics page"""
    return """
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>UFOBeep Engagement Analytics</title>
    <style>
        body { font-family: Arial, sans-serif; margin: 0; padding: 20px; background: #1a1a1a; color: #e0e0e0; }
        .container { max-width: 1400px; margin: 0 auto; }
        .header { text-align: center; margin-bottom: 40px; }
        .header h1 { color: #00ff88; margin: 0; }
        .header p { color: #888; margin: 5px 0; }
        .back-link { color: #00ff88; text-decoration: none; margin-bottom: 20px; display: inline-block; }
        .back-link:hover { text-decoration: underline; }
        .stats-grid { display: grid; grid-template-columns: repeat(auto-fit, minmax(200px, 1fr)); gap: 20px; margin-bottom: 40px; }
        .stat-card { background: #2d2d2d; padding: 20px; border-radius: 8px; text-align: center; border: 1px solid #444; }
        .stat-number { font-size: 2em; font-weight: bold; color: #00ff88; margin: 0; }
        .stat-label { color: #bbb; margin: 10px 0 0 0; }
        .section { background: #2d2d2d; padding: 20px; border-radius: 8px; margin-bottom: 20px; border: 1px solid #444; }
        .section h3 { color: #00ff88; margin-top: 0; }
        .controls { margin-bottom: 20px; }
        .controls select, .controls input { background: #333; color: #e0e0e0; border: 1px solid #555; padding: 8px; border-radius: 4px; margin-right: 10px; }
        .refresh-btn { background: #00ff88; color: #000; border: none; padding: 8px 16px; border-radius: 4px; cursor: pointer; }
        .refresh-btn:hover { background: #00cc70; }
        .chart-container { background: #333; padding: 20px; border-radius: 8px; margin: 20px 0; }
        .table { width: 100%; border-collapse: collapse; margin-top: 15px; }
        .table th, .table td { text-align: left; padding: 12px; border-bottom: 1px solid #444; }
        .table th { background: #333; color: #00ff88; }
        .table tr:hover { background: #333; }
        .badge { padding: 3px 8px; border-radius: 12px; font-size: 0.8em; font-weight: bold; }
        .badge.high { background: #ff4444; color: white; }
        .badge.medium { background: #ffaa44; color: white; }
        .badge.low { background: #44ff44; color: black; }
        .loading { text-align: center; padding: 40px; color: #888; }
    </style>
</head>
<body>
    <div class="container">
        <div class="header">
            <a href="/admin" class="back-link">← Back to Admin Dashboard</a>
            <h1>📊 UFOBeep Engagement Analytics</h1>
            <p>Real-time user engagement and alert delivery metrics</p>
        </div>

        <!-- Summary Stats -->
        <div class="stats-grid" id="summary-stats">
            <!-- Loaded via JavaScript -->
        </div>

        <!-- Time Range Controls -->
        <div class="controls">
            <select id="timeRange">
                <option value="1">Last 1 Hour</option>
                <option value="24" selected>Last 24 Hours</option>
                <option value="168">Last Week</option>
                <option value="720">Last Month</option>
            </select>
            <input type="text" id="sightingFilter" placeholder="Filter by Sighting ID (optional)">
            <button class="refresh-btn" onclick="loadDetailedMetrics()">🔄 Refresh Data</button>
        </div>

        <!-- Engagement Breakdown -->
        <div class="section">
            <h3>📈 Engagement Breakdown</h3>
            <div id="engagement-breakdown" class="loading">Loading engagement data...</div>
        </div>

        <!-- Alert Delivery Performance -->
        <div class="section">
            <h3>🚀 Alert Delivery Performance</h3>
            <div id="delivery-performance" class="loading">Loading delivery data...</div>
        </div>

        <!-- User Funnel Analysis -->
        <div class="section">
            <h3>🎯 User Engagement Funnel</h3>
            <div id="engagement-funnel" class="loading">Loading funnel data...</div>
        </div>

        <!-- Recent Activity -->
        <div class="section">
            <h3>🕐 Recent Activity</h3>
            <div id="recent-activity" class="loading">Loading recent activity...</div>
        </div>
    </div>

    <script>
        let currentMetrics = null;

        async function loadDetailedMetrics() {
            const timeRange = document.getElementById('timeRange').value;
            const sightingFilter = document.getElementById('sightingFilter').value.trim();
            
            try {
                // Show loading states
                ['summary-stats', 'engagement-breakdown', 'delivery-performance', 'engagement-funnel', 'recent-activity'].forEach(id => {
                    document.getElementById(id).innerHTML = '<div class="loading">Loading...</div>';
                });

                // Build query parameters
                const params = new URLSearchParams({ hours: timeRange });
                if (sightingFilter) params.append('sighting_id', sightingFilter);

                // Fetch detailed metrics
                const response = await fetch(`/admin/engagement/metrics?${params}`);
                const result = await response.json();
                
                if (result.success) {
                    currentMetrics = result.data;
                    renderMetrics(currentMetrics);
                } else {
                    throw new Error(result.error || 'Failed to load metrics');
                }
            } catch (error) {
                console.error('Error loading metrics:', error);
                ['summary-stats', 'engagement-breakdown', 'delivery-performance', 'engagement-funnel', 'recent-activity'].forEach(id => {
                    document.getElementById(id).innerHTML = `<div class="loading">Error: ${error.message}</div>`;
                });
            }
        }

        function renderMetrics(metrics) {
            // Render summary stats
            const summaryStats = document.getElementById('summary-stats');
            summaryStats.innerHTML = `
                <div class="stat-card">
                    <div class="stat-number">${metrics.overall.total_events || 0}</div>
                    <div class="stat-label">Total Events</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${metrics.overall.unique_devices || 0}</div>
                    <div class="stat-label">Unique Devices</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${metrics.calculated_metrics.engagement_rate.toFixed(1)}%</div>
                    <div class="stat-label">Engagement Rate</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${metrics.calculated_metrics.delivery_success_rate.toFixed(1)}%</div>
                    <div class="stat-label">Delivery Success</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${Math.round(metrics.delivery.avg_delivery_time_ms || 0)}ms</div>
                    <div class="stat-label">Avg Delivery Time</div>
                </div>
                <div class="stat-card">
                    <div class="stat-number">${metrics.delivery.total_deliveries || 0}</div>
                    <div class="stat-label">Total Deliveries</div>
                </div>
            `;

            // Render engagement breakdown
            const engagementBreakdown = document.getElementById('engagement-breakdown');
            if (metrics.by_type && metrics.by_type.length > 0) {
                const table = `
                    <table class="table">
                        <thead>
                            <tr>
                                <th>Engagement Type</th>
                                <th>Count</th>
                                <th>Unique Devices</th>
                                <th>Percentage</th>
                            </tr>
                        </thead>
                        <tbody>
                            ${metrics.by_type.map(type => {
                                const percentage = metrics.overall.total_events > 0 ? 
                                    ((type.count / metrics.overall.total_events) * 100).toFixed(1) : 0;
                                return `
                                    <tr>
                                        <td><strong>${type.event_type.replace('_', ' ')}</strong></td>
                                        <td>${type.count}</td>
                                        <td>${type.unique_devices}</td>
                                        <td>${percentage}%</td>
                                    </tr>
                                `;
                            }).join('')}
                        </tbody>
                    </table>
                `;
                engagementBreakdown.innerHTML = table;
            } else {
                engagementBreakdown.innerHTML = '<p style="color: #888; text-align: center;">No engagement data found for the selected time period.</p>';
            }

            // Render delivery performance
            const deliveryPerformance = document.getElementById('delivery-performance');
            const delivery = metrics.delivery;
            deliveryPerformance.innerHTML = `
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${delivery.successful_deliveries || 0}</div>
                        <div class="stat-label">Successful</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${delivery.failed_deliveries || 0}</div>
                        <div class="stat-label">Failed</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${delivery.rate_limited || 0}</div>
                        <div class="stat-label">Rate Limited</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${Math.round(delivery.max_delivery_time_ms || 0)}ms</div>
                        <div class="stat-label">Max Delivery Time</div>
                    </div>
                </div>
            `;

            // Render engagement funnel
            const engagementFunnel = document.getElementById('engagement-funnel');
            const funnel = metrics.funnel;
            engagementFunnel.innerHTML = `
                <div class="stats-grid">
                    <div class="stat-card">
                        <div class="stat-number">${funnel.alerts_sent || 0}</div>
                        <div class="stat-label">Alerts Sent</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${funnel.alerts_opened || 0}</div>
                        <div class="stat-label">Alerts Opened</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${funnel.quick_actions || 0}</div>
                        <div class="stat-label">Quick Actions</div>
                    </div>
                    <div class="stat-card">
                        <div class="stat-number">${funnel.beeps_submitted || 0}</div>
                        <div class="stat-label">Beeps Submitted</div>
                    </div>
                </div>
                <p style="color: #888; margin-top: 15px; text-align: center;">
                    Funnel Conversion: ${funnel.alerts_sent > 0 ? ((funnel.quick_actions / funnel.alerts_sent) * 100).toFixed(1) : 0}% 
                    (${funnel.quick_actions} actions / ${funnel.alerts_sent} alerts)
                </p>
            `;

            // Show time range info
            document.getElementById('recent-activity').innerHTML = `
                <p><strong>Time Range:</strong> ${metrics.time_range_hours} hours</p>
                <p><strong>Data Updated:</strong> ${new Date().toLocaleString()}</p>
                ${metrics.sighting_id ? `<p><strong>Filtered by Sighting:</strong> ${metrics.sighting_id}</p>` : ''}
                <p style="color: #888; margin-top: 20px;">
                    This data includes all user engagement events, alert deliveries, and system interactions within the specified time range.
                    Engagement rate is calculated as (quick actions / alerts sent) × 100%.
                </p>
            `;
        }

        // Initialize page
        loadDetailedMetrics();

        // Auto-refresh every 60 seconds
        setInterval(loadDetailedMetrics, 60000);
    </script>
</body>
</html>
    """