# UFOBeep Deployment Guide

## Quick Deploy

```bash
# Deploy everything (API, Web, Mobile)
./deploy.sh

# Deploy specific components
./deploy.sh api        # API only
./deploy.sh web        # Web only  
./deploy.sh apk        # Mobile only
./deploy.sh api web    # API and Web
```

## Production Services

Both API and Web are managed by systemd on production:

## 🚨 Critical Issues & Solutions

### Database Connection Pool Exhaustion (September 8, 2025)

**Issue**: API returned 500 errors after only 5-10 requests due to PostgreSQL connection limit exceeded.

**Root Cause**: Multiple API routers were creating independent database connection pools:
- Main API: 1 pool (min=2, max=20)
- alerts.py: Created own pool (min=1, max=10) 
- admin_simple.py: Created own pool (min=1, max=10)
- mufon.py: Created 2 own pools (min=1, max=5 each)

Total: 4+ pools competing for PostgreSQL's 100 connection limit.

**Fix Applied**: Updated all routers to use shared database service:
```python
# Before (WRONG):
async def get_db():
    return await asyncpg.create_pool(
        host="localhost", port=5432, user="ufobeep_user", 
        password="ufopostpass", database="ufobeep_db",
        min_size=1, max_size=10
    )

# After (CORRECT):
async def get_db():
    from app.services.database_service import get_database_pool
    return await get_database_pool()
```

**Files Fixed**: 
- `api/app/routers/alerts.py`
- `api/app/routers/admin_simple.py` 
- `api/app/routers/mufon.py` (2 instances)

**Prevention Rules**:
1. **Never create new database pools in routers**
2. **Always use `app.services.database_service.get_database_pool()`**
3. **Never call `pool.close()` on shared pools**
4. **Code review must check for `asyncpg.create_pool()` usage**

**Monitoring**: Watch for these error patterns:
```
asyncpg.exceptions.TooManyConnectionsError: remaining connection slots are reserved for roles with the SUPERUSER attribute
```

### API Service
- **Service**: `ufobeep-api.service`
- **Port**: 8000
- **URL**: https://ufobeep.com/api

```bash
# Check status
sudo systemctl status ufobeep-api

# Restart
sudo systemctl restart ufobeep-api

# View logs
sudo journalctl -u ufobeep-api -f
```

### Web Service (Next.js)
- **Service**: `ufobeep-web.service`
- **Port**: 3000
- **URL**: https://ufobeep.com

```bash
# Check status
sudo systemctl status ufobeep-web

# Restart
sudo systemctl restart ufobeep-web

# View logs
sudo journalctl -u ufobeep-web -f
tail -f /var/log/ufobeep-web.log
```

## Mobile Deployment

The deployment script automatically:
1. Checks for 3+ connected devices (required)
2. Installs APK to all connected devices
3. Uploads APK to production server

### Device Setup
```bash
# Connect devices via USB
adb devices

# Connect wireless device (Moto)
adb connect 192.168.0.49:43413
```

### Manual APK Build
```bash
cd app
flutter build apk --release
```

## SSH Access

```bash
# Connect to production
ssh -p 322 ufobeep@ufobeep.com
```

## Database Access

### Query Production Database
```bash
# SSH and query database
ssh -p 322 ufobeep@ufobeep.com "PGPASSWORD=\$DB_PASS psql -h localhost -U ufobeep_user -d ufobeep_db -c \"SELECT * FROM users LIMIT 5;\""

# Interactive database session
ssh -p 322 ufobeep@ufobeep.com
PGPASSWORD=\$DB_PASS psql -h localhost -U ufobeep_user -d ufobeep_db

# Common queries
# Find user by email
SELECT id, username, email, firebase_uid FROM users WHERE email='user@example.com';

# Check recent alerts
SELECT id, title, reporter_username, created_at FROM sightings ORDER BY created_at DESC LIMIT 10;

# User device mappings
SELECT u.username, ud.device_id, ud.platform FROM users u JOIN user_devices ud ON u.id = ud.user_id;
```

### Database Connection Details
- **Host**: localhost 
- **Port**: 5432 (default)
- **Database**: ufobeep_db
- **User**: ufobeep_user
- **Password**: See SECRETS.md

## Service Configuration Files

### API Service (`/etc/systemd/system/ufobeep-api.service`)
```ini
[Unit]
Description=UFOBeep FastAPI Application
After=network.target

[Service]
Type=simple
User=ufobeep
WorkingDirectory=/var/www/ufobeep.com/html/api
ExecStart=/var/www/ufobeep.com/html/api/venv/bin/uvicorn app.main:app --host 0.0.0.0 --port 8000
Restart=on-failure

[Install]
WantedBy=multi-user.target
```

### Web Service (`/etc/systemd/system/ufobeep-web.service`)
```ini
[Unit]
Description=UFOBeep Next.js Web Application
After=network.target

[Service]
Type=simple
User=ufobeep
WorkingDirectory=/home/ufobeep/ufobeep/web
ExecStart=/usr/bin/npm run start
Restart=on-failure
Environment=NODE_ENV=production
Environment=PORT=3000
StandardOutput=append:/var/log/ufobeep-web.log
StandardError=append:/var/log/ufobeep-web.error.log

[Install]
WantedBy=multi-user.target
```

## Troubleshooting

### Service won't start
```bash
# Check service logs
sudo journalctl -u ufobeep-api -n 50
sudo journalctl -u ufobeep-web -n 50

# Check permissions
ls -la /var/www/ufobeep.com/html/api
ls -la /home/ufobeep/ufobeep/web
```

### Port conflicts
```bash
# Check what's using ports
sudo lsof -i :8000
sudo lsof -i :3000
```

### Reload systemd after config changes
```bash
sudo systemctl daemon-reload
sudo systemctl restart ufobeep-api
sudo systemctl restart ufobeep-web
```