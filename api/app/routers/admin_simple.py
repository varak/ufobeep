from fastapi import APIRouter, HTTPException, Depends, Request
from fastapi.responses import HTMLResponse
from fastapi.security import HTTPBasic, HTTPBasicCredentials
import asyncpg
import secrets
from typing import Dict, Any
import json

router = APIRouter(prefix="/admin", tags=["admin"])
security = HTTPBasic()

# Simple database connection - same pattern as alerts.router
async def get_db():
    return await asyncpg.create_pool(
        host="localhost", port=5432, user="ufobeep_user", 
        password="ufopostpass", database="ufobeep_db",
        min_size=1, max_size=10
    )

def verify_admin(credentials: HTTPBasicCredentials = Depends(security)):
    is_correct_username = secrets.compare_digest(credentials.username, "admin")
    is_correct_password = secrets.compare_digest(credentials.password, "ufopostpass")
    if not (is_correct_username and is_correct_password):
        raise HTTPException(status_code=401, detail="Invalid credentials")
    return credentials.username

@router.get("/", response_class=HTMLResponse)
async def admin_dashboard(username: str = Depends(verify_admin)):
    """Simple admin dashboard - rebuilt from scratch"""
    try:
        db_pool = await get_db()
        async with db_pool.acquire() as conn:
            # Get basic stats
            total_sightings = await conn.fetchval("SELECT COUNT(*) FROM sightings")
            sightings_today = await conn.fetchval(
                "SELECT COUNT(*) FROM sightings WHERE created_at >= CURRENT_DATE"
            )
            total_devices = await conn.fetchval("SELECT COUNT(*) FROM devices WHERE push_token IS NOT NULL")
            
            # Get recent sightings
            recent_sightings = await conn.fetch("""
                SELECT id, description, created_at, 
                       COALESCE(media_info::text, '{}') as media_info
                FROM sightings 
                ORDER BY created_at DESC 
                LIMIT 5
            """)
            
        html = f"""
        <!DOCTYPE html>
        <html>
        <head>
            <title>UFOBeep Admin</title>
            <style>
                body {{ font-family: Arial, sans-serif; margin: 20px; }}
                .stats {{ display: flex; gap: 20px; margin: 20px 0; }}
                .stat-card {{ background: #f5f5f5; padding: 15px; border-radius: 5px; }}
                .sightings {{ margin-top: 30px; }}
                .sighting {{ background: #fff; border: 1px solid #ddd; padding: 10px; margin: 10px 0; border-radius: 5px; }}
                .controls {{ margin: 20px 0; }}
                .controls a {{ margin-right: 10px; padding: 5px 10px; background: #007cba; color: white; text-decoration: none; border-radius: 3px; }}
            </style>
        </head>
        <body>
            <h1>🛸 UFOBeep Admin Dashboard</h1>
            
            <div class="stats">
                <div class="stat-card">
                    <h3>Total Sightings</h3>
                    <p><strong>{total_sightings}</strong></p>
                </div>
                <div class="stat-card">
                    <h3>Today's Sightings</h3>
                    <p><strong>{sightings_today}</strong></p>
                </div>
                <div class="stat-card">
                    <h3>Active Devices</h3>
                    <p><strong>{total_devices}</strong></p>
                </div>
            </div>
            
            <div class="controls">
                <a href="/admin/sightings">Manage Sightings</a>
                <a href="/admin/devices">Device Management</a>
                <a href="/admin/ratelimit/status">Rate Limiting</a>
                <a href="/alerts">View Alerts</a>
            </div>
            
            <div class="sightings">
                <h2>Recent Sightings</h2>
        """
        
        for sighting in recent_sightings:
            media_count = 0
            try:
                media_info = json.loads(sighting['media_info'])
                if isinstance(media_info, dict) and 'files' in media_info:
                    media_count = len(media_info['files'])
            except:
                pass
                
            html += f"""
                <div class="sighting">
                    <strong>ID:</strong> {sighting['id']}<br>
                    <strong>Description:</strong> {sighting['description']}<br>
                    <strong>Created:</strong> {sighting['created_at']}<br>
                    <strong>Media Files:</strong> {media_count}<br>
                    <a href="/alerts/{sighting['id']}" target="_blank">View Details</a>
                </div>
            """
        
        html += """
            </div>
        </body>
        </html>
        """
        
        return html
        
    except Exception as e:
        return f"<html><body><h1>Error</h1><p>{str(e)}</p></body></html>"

@router.get("/ratelimit/status")
async def ratelimit_status(username: str = Depends(verify_admin)):
    """Rate limiting status - simple implementation"""
    # Import rate limiting variables from the existing admin module
    try:
        from app.routers.admin import rate_limit_enabled, rate_limit_threshold
        return {
            "enabled": rate_limit_enabled,
            "threshold": rate_limit_threshold,
            "status": "active" if rate_limit_enabled else "disabled"
        }
    except ImportError:
        return {"error": "Rate limiting not available"}

@router.get("/ratelimit/on")
async def enable_ratelimit(username: str = Depends(verify_admin)):
    """Enable rate limiting"""
    try:
        import app.routers.admin as admin_module
        admin_module.rate_limit_enabled = True
        return {"message": "Rate limiting enabled", "enabled": True}
    except Exception as e:
        return {"error": str(e)}

@router.get("/ratelimit/off") 
async def disable_ratelimit(username: str = Depends(verify_admin)):
    """Disable rate limiting"""
    try:
        import app.routers.admin as admin_module
        admin_module.rate_limit_enabled = False
        return {"message": "Rate limiting disabled", "enabled": False}
    except Exception as e:
        return {"error": str(e)}