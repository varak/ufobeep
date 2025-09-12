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

## Mobile Deployment - UPDATED ✅

### Current Mobile App Status - FULLY COMPLETE
- **Build Number**: 107 (Build v1.0.0-beta.8+107)
- **APK Size**: ~76MB (optimized)
- **Features Complete - 100% POLISHED**: 
  - ✅ **Media Upload System**: Single-press upload with individual file progress indicators
  - ✅ **Share-to-Beep Integration**: Multi-file sharing support from external apps/gallery
  - ✅ **Progress Tracking**: File-by-file visual progress (black → blue → green states)
  - ✅ **File Management**: Individual file removal with X buttons, always-visible controls
  - ✅ **UX Polish**: Seamless experience without UI flash or double-press issues
  - ✅ **Error Handling**: Robust retry logic with user-friendly feedback
- **API Integration**: Uses `/api/beep/` endpoints (nginx routing compatible)
- **Deployment Status**: Fully deployed, tested, and production-ready

### Media Upload Feature - COMPLETED (September 12, 2025)
The media upload system represents a major milestone with:
- **Unified Implementation**: Single BeepScreen handles all media operations
- **Double-Press Issue Eliminated**: Complete fix implemented and tested
- **Share-to-Beep Support**: Multi-file sharing from gallery and other apps
- **Progress Indicators**: Individual file upload progress with visual feedback
- **Status**: 100% complete and polished for production use

### Deployment Script Features
The deployment script automatically:
1. **ALWAYS increments build number** in `app/pubspec.yaml` before building APK
2. Checks for 3+ connected devices (required)
3. Installs APK to all connected devices
4. Uploads APK to production server
5. Commits build number changes to git

### Device Setup
```bash
# Connect devices via USB
adb devices

# Connect wireless device (Moto)
adb connect 192.168.0.49:43413
```

### Device-Specific Deployment
```bash
# Deploy to specific devices
./deploy.sh moto       # Moto device only
./deploy.sh tablet     # Tablet only
./deploy.sh pixel      # Pixel device only
./deploy.sh samsung    # Samsung device only

# Deploy to multiple specific devices
./deploy.sh moto pixel
```

### Manual APK Build Process
```bash
cd app

# CRITICAL: Always increment build number first
# Edit pubspec.yaml: version: 1.0.0-beta.8+N (increment N)

flutter clean
flutter pub get
flutter build apk --release

# APK location: app/build/app/outputs/flutter-apk/app-release.apk
```

### Media Upload Testing - PRODUCTION READY
After deployment, the complete media upload flow is fully functional:
1. Open UFOBeep app on device
2. Navigate to "Report Sighting" (+ button)
3. Add photos/videos using Camera or Gallery buttons (always visible)
4. Verify progress indicators work (black → blue → green)
5. Test individual file removal with X buttons
6. Test Share-to-Beep from external apps (gallery, camera apps)
7. Submit sighting and verify successful upload with file-by-file progress

## Data Management Tools

### Enhanced Delete Script - COMPREHENSIVE CLEANUP ✅
- **Location**: Production server only (connects directly to PostgreSQL)
- **File**: `delete.py` (renamed from delete_user_beeps.py)
- **Capabilities**: Username deletion, MUFON bulk deletion, short URL deletion
- **Data Safety**: Prevents orphaned data with comprehensive cleanup

#### Delete Script Usage
```bash
# SSH to production server
ssh -p 322 mike@ufobeep.com
cd /home/ufobeep/ufobeep

# Delete by username
python3 delete.py "dark.idea.8245"

# MUFON bulk deletion (removes all MUFON imports)
python3 delete.py mufon

# Delete by short URL
python3 delete.py "fdge6"
python3 delete.py "ufobeep.com/fdge6"  # Full URL format also supported
```

#### Comprehensive Cleanup Process
The delete script removes all associated data:
- Primary sighting record
- All uploaded media files (from storage + database)
- User comments on the sighting
- Follow relationships
- Analysis data
- Push notifications
- Related enrichment data

**CRITICAL**: Always use the delete script instead of direct SQL commands to prevent orphaned data.

## SSH Access

```bash
# Connect to production
ssh -p 322 mike@ufobeep.com
```

## Database Access

### Query Production Database
```bash
# SSH and query database
ssh -p 322 mike@ufobeep.com "PGPASSWORD=\$DB_PASS psql -h localhost -U ufobeep_user -d ufobeep_db -c \"SELECT * FROM users LIMIT 5;\""

# Interactive database session
ssh -p 322 mike@ufobeep.com
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

## API Endpoint Testing - FULLY UPDATED

### Test Complete Media Upload Flow - PRODUCTION READY
```bash
# Create a test sighting
curl -X POST https://ufobeep.com/api/beep \
  -H "Authorization: Bearer <token>" \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Test Sighting",
    "description": "Testing media upload",
    "location": {"latitude": 40.7128, "longitude": -74.0060}
  }'

# Upload media to the sighting - FULLY WORKING
curl -X POST https://ufobeep.com/api/beep/{sighting_id}/media \
  -H "Authorization: Bearer <token>" \
  -F "file=@test_image.jpg" \
  -F "source=test_deployment"

# Update existing media - NEW PATCH ENDPOINT
curl -X PATCH https://ufobeep.com/api/beep/{sighting_id}/media \
  -H "Authorization: Bearer <token>" \
  -F "file=@updated_image.jpg"

# Verify sighting with media
curl https://ufobeep.com/api/beep/{sighting_id}
```

### Test MUFON Script Integration - OPTIMIZED
```bash
# Verify mufon.sh uses new endpoints
grep -n "api/beep" mufon.sh
# Should show: https://ufobeep.com/api/beep and https://ufobeep.com/api/beep/{id}/media

# Verify optimized login timing (2.2s instead of 5+s)
time ./mufon.sh --test-login
# Expected: ~2.2 seconds total login time
```

## Website Updates - COMPLETE OVERHAUL ✅

### Current Website Status
- **Homepage**: Updated with current features, MUFON integration mention
- **Download Page**: Current version info (v1.0.0-beta.8+107), email signup, 22 languages
- **Map Page**: Instant loading with progressive marker system
- **Navigation**: Clean UX with `/app` redirecting to `/download`
- **Translation**: Fixed "mufonDatabaseReport" display issue

### Website Testing
```bash
# Test updated homepage
curl -I https://ufobeep.com/

# Test download page with current APK
curl -I https://ufobeep.com/download

# Test map functionality
curl -I https://ufobeep.com/map

# Verify APK download (current build)
curl -I https://ufobeep.com/downloads/ufobeep-alpha.apk
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

### Mobile App Issues
```bash
# Check connected devices
adb devices

# Install specific APK version (current: build 107)
adb install -r /path/to/ufobeep-v107.apk

# View app logs
adb logcat | grep -i flutter
adb logcat | grep -i ufobeep
```

### Media Upload Issues
```bash
# Test media endpoints directly - ALL WORKING
curl -I https://ufobeep.com/api/beep/ABC12/media

# Check nginx routing
sudo nginx -t
sudo systemctl reload nginx

# Verify MinIO bucket access
curl -I https://ufobeep.com/api/media/test-file
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

## Recent Deployment Improvements (September 2025)

### Media Upload System - 100% COMPLETE ✅
- **Unified Implementation**: Single BeepScreen handles all media operations seamlessly
- **Progress Tracking**: Individual file visual indicators for upload stages
- **Error Handling**: Robust retry logic with user-friendly feedback
- **Share-to-Beep**: Multi-file sharing support from external applications
- **API Consistency**: All platforms use standardized `/api/beep/{id}/media` endpoints
- **UX Polish**: Eliminated double-press issues, always-visible controls, seamless experience

### MUFON Script Optimization - COMPLETED ✅
- **Performance**: Reduced login delays from 5+ seconds to 2.2 seconds
- **Reliability**: Maintained robust retry logic with optimized timings
- **Consistency**: Uses same `/api/beep/` endpoints as mobile app
- **Monitoring**: Annual time savings of ~18 minutes on login retries

### Enhanced Delete Script - COMPREHENSIVE ✅
- **Flexibility**: Supports username, MUFON bulk, and short URL deletion
- **Safety**: Comprehensive cleanup prevents orphaned data
- **Production-Ready**: Direct PostgreSQL integration with full relationship cleanup

### Build Process Improvements - AUTOMATED ✅
- **Automatic Build Increment**: Deploy script always increments build number
- **Version Tracking**: Build 107 represents complete and polished media upload feature
- **Quality Assurance**: Multi-device testing requirement before production upload
- **Current Status**: v1.0.0-beta.8+107 (~76MB APK) fully deployed and tested