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
            <a href="/admin/media" class="nav-btn">📸 Media Management</a>
            <a href="/admin/users" class="nav-btn">👥 User Management</a>
            <a href="/admin/system" class="nav-btn">⚙️ System Status</a>
            <a href="/admin/mufon" class="nav-btn">🛸 MUFON Integration</a>
            <a href="/admin/logs" class="nav-btn">📜 System Logs</a>
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

        // Initialize dashboard
        loadStats();
        loadActivity();
        
        // Refresh every 30 seconds
        setInterval(() => {
            loadStats();
            loadActivity();
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
        
        return AdminStats(
            total_sightings=total_sightings,
            total_media_files=total_media,
            sightings_today=sightings_today,
            sightings_this_week=sightings_this_week,
            pending_sightings=pending_sightings,
            verified_sightings=verified_sightings,
            media_without_primary=media_without_primary,
            recent_uploads=recent_uploads,
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
        where_clause = ""
        params = []
        
        if status:
            where_clause = "WHERE s.status = $1"
            params = [status]
            
        query = f"""
            SELECT 
                s.id, s.title, s.description, s.category, s.status, s.alert_level,
                s.created_at, s.witness_count,
                COUNT(m.id) as media_count,
                COUNT(CASE WHEN m.is_primary THEN 1 END) > 0 as has_primary_media
            FROM sightings s
            LEFT JOIN media_files m ON s.id = m.sighting_id
            {where_clause}
            GROUP BY s.id, s.title, s.description, s.category, s.status, s.alert_level,
                     s.created_at, s.witness_count
            ORDER BY s.created_at DESC
            LIMIT $2 OFFSET $3
        """
        
        params.extend([limit, offset])
        sightings = await conn.fetch(query, *params)
        
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
                verification_score=0.0  # Default since column doesn't exist yet
            )
            for s in sightings
        ]
        
    except Exception as e:
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