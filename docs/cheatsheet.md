# UFOBeep API Infrastructure Cheatsheet

## Server Architecture
- **Single FastAPI server** serving all endpoints (confirmed correct architecture)
- **Production URL**: https://api.ufobeep.com
- **Local testing**: Production only - no localhost testing

## API Endpoints Structure - UNIFIED `/alerts` ARCHITECTURE
```
Single FastAPI app with unified /alerts pattern:
- alerts.router       → /alerts/* (ALL sighting operations)
- media_serve.router  → /media/{alert_id}/{filename} 
- devices.router      → /devices/* endpoints
- plane_match.router  → no prefix (root level)
- Direct endpoints: /healthz, /ping

Core /alerts endpoints:
POST   /alerts                         → Create new alert
GET    /alerts                         → List all alerts  
GET    /alerts/{id}                    → Get specific alert
POST   /alerts/{id}/media              → Upload media to alert
DELETE /alerts/{id}/media/{file}       → Remove media
PATCH  /alerts/{id}                    → Update alert details
POST   /alerts/{id}/witness            → Confirm witness

✅ Unified architecture - no more /sightings confusion
✅ Clean mobile app workflow with single endpoint pattern
✅ Future-ready for user accounts and proximity sharing
```

## Environment Configuration
- **Single .env file location**: `/home/mike/D/ufobeep/.env` (project root)
- **FastAPI settings**: Configured to read `../.env` (parent directory from api folder)
- **No duplicate .env files** - consolidated into single project root file
- **External API keys added**: Astrometry, N2YO satellites, ADS-B Exchange, Google Vision, Roboflow

## Storage (Filesystem)
- **Storage type**: Local filesystem storage (no longer MinIO)
- **Storage root**: `/home/ufobeep/ufobeep/media` (on production server)
- **Structure**: `{sighting_id}/filename.jpg` (organized by sighting ID)
- **Service**: FilesystemStorageService handles all file operations
- **URLs**: Direct serving via `/media/{sighting_id}/{filename}` endpoint

## Media Storage Implementation (COMPLETED)
- **✅ Storage**: Migrated from MinIO to filesystem storage at `/home/ufobeep/ufobeep/media`
- **✅ Structure**: `{sighting_id}/filename.jpg` organization implemented
- **✅ Serving**: Direct endpoint `/media/{sighting_id}/{filename}` with thumbnail support
- **✅ URLs**: `https://api.ufobeep.com/media/{sighting_id}/filename.jpg` (permanent)
- **✅ Features**: EXIF orientation correction, web-optimized thumbnails, caching headers
- **✅ Upload Flow**: Images stored when user clicks "send beep" in mobile app

## File Upload Endpoint
- **Endpoint**: `POST https://api.ufobeep.com/media/presign`
- **Status**: ✅ Working with filesystem storage
- **Process**: Generates upload metadata, files saved directly to filesystem
- **Storage path**: `/home/ufobeep/ufobeep/media/{sighting_id}/{filename}`

## Development Environment
- **Project root**: `/home/mike/D/ufobeep`
- **API path**: `/home/mike/D/ufobeep/api` (FastAPI backend)
- **Web path**: `/home/mike/D/ufobeep/web` (Next.js website)
- **Mobile path**: `/home/mike/D/ufobeep/app` (Flutter mobile app)
- **Virtual env**: `/home/mike/D/ufobeep/api/venv` (in API directory, not project root)
- **Dependencies**: Installed via `venv/bin/pip install -r requirements.txt`
- **IMPORTANT**: Startup script must use `venv/bin/activate` not `../venv/bin/activate`

## Current Web Routes
- `/` - Homepage with email signup
- `/alerts` - List of all recent sightings (24 items max)
- `/alert/[slug]` - SEO-friendly individual alert detail pages  
- `/alerts/[id]` - Individual alert detail pages with interactive maps
- `/app` - App download page

## Interactive Maps (COMPLETED)
- **Individual Alert Pages**: `/alerts/[id]` now include interactive Google Maps
- **Main Sighting**: Prominently highlighted with green marker and detailed info window
- **Nearby Sightings**: Orange markers for sightings within 50km radius (up to 10)
- **Features**: Dark theme, fullscreen modal, distance calculation, clickable markers
- **Responsive**: Works on mobile and desktop with touch/click interactions
- **Integration**: Uses Google Maps API with fallback error handling
- **Navigation**: Click nearby markers to jump to other sighting detail pages

## Mobile App Flow - UNIFIED `/alerts` ARCHITECTURE
Clean 5-step workflow using `/alerts` endpoints only:
```
1. POST /devices/register               ← Register device
2. PATCH /devices/{device_id}/location  ← Update location  
3. POST /alerts                         ← Create alert, get ID
4. POST /alerts/{alert_id}/media        ← Upload media
5. GET /alerts/{alert_id}              ← Display result
```
- **Camera capture** → POST /alerts with media → Alert detail page
- **Gallery selection** → POST /alerts with media → Alert detail page  
- **EXIF GPS data**: ✅ Automatically embedded to prevent "Unknown Location"
- **Clean URLs**: All mobile app requests use `/alerts` pattern
- **Future ready**: User accounts, proximity sharing, cross-device sync

## Firebase Configuration (Push Notifications & Beta Testing)

### Firebase Projects
- **Main Project**: `ufobeep` (Project Number: 346511467728) 
- **Package Name**: `com.ufobeep` (updated from com.ufobeep.ufobeep)
- **Service Account**: `/home/ufobeep/ufobeep/firebase-service-account.json`
- **VAPID Keys**: Deployed for web push notifications
- **Console URL**: https://console.firebase.google.com/u/1/project/ufobeep

### Push Notification Setup (COMPLETED)
- **Status**: ✅ WORKING - Firebase FCM notifications functional
- **Mobile Apps**: Updated with new package name on 4 devices
- **FCM Library**: firebase-admin v7.1.0 (latest)
- **Test**: Media and non-media beeps both trigger FCM notifications

### To distribute new APK:
```bash
cd /home/mike/D/ufobeep
./scripts/distribute-beta.sh
```

The script will:
1. Clean build release APK
2. Prompt for release notes
3. Upload to Firebase App Distribution
4. Send email invitations to beta testers
5. Show distribution status

**Requirements**: Firebase CLI (`npm install -g firebase-tools`) and `firebase login`

## iOS TestFlight Distribution (iPhone Testing)
- **Platform**: Apple TestFlight (requires Apple Developer Account $99/year)
- **Build Method**: GitHub Actions (macOS runners)
- **Setup Guide**: `docs/ios-testflight-setup.md`
- **Workflows**: 
  - `.github/workflows/ios-build-only.yml` (unsigned build)
  - `.github/workflows/ios-testflight.yml` (full automation)
- **Bundle ID**: `com.ufobeep.ufobeep`
- **TestFlight Console**: https://appstoreconnect.apple.com/apps/testflight

### To build iOS version:
1. **Get Apple Developer Account** ($99/year)
2. **Configure GitHub secrets** (certificates, provisioning profiles, API keys)
3. **Run GitHub Actions workflow** 
4. **Distribute via TestFlight** to iPhone users

**Note**: iOS builds require macOS, so we use GitHub Actions with macOS runners since no Mac available locally.

## Testing Commands
```bash
# Test API health
curl -s https://api.ufobeep.com/media/health

# Test presigned upload
curl -s -X POST https://api.ufobeep.com/media/presign \
  -H "Content-Type: application/json" \
  -d '{"filename": "test.jpg", "content_type": "image/jpeg", "size_bytes": 1024}'
```

## Common Issues & Solutions

### Next.js Webpack Chunk Corruption
**Problem**: Website shows white page with "Cannot find module './948.js'" error
**Root cause**: Webpack build artifacts get corrupted during deployment or interrupted builds
**Solution**: Clean rebuild with cache clearing
```bash
ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep/web && rm -rf .next node_modules/.cache && npm run build && pm2 restart all"
```
**Prevention**: Always do full clean rebuilds after major changes

### PM2 Process Stopped (Website Shows Old Content)
**Problem**: Website serves old/cached content despite successful git pulls and builds
**Root cause**: PM2 process was stopped during troubleshooting and `pm2 restart all` only restarts running processes
**Diagnosis**: Check PM2 status with `ssh -p 322 ufobeep@ufobeep.com "pm2 list"` - look for "stopped" status
**Solution**: Start the stopped process
```bash
ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep/web && pm2 start npm --name 'ufobeep-web' -- start"
```
**Alternative**: Delete stopped process and use standard restart
```bash
ssh -p 322 ufobeep@ufobeep.com "pm2 delete ufobeep-web && cd /home/ufobeep/ufobeep/web && pm2 start npm --name 'ufobeep-web' -- start"
```
**Prevention**: Use `pm2 list` to verify process status before and after deployment

### API Service Virtual Environment Issues  
**Problem**: ufobeep-api.service fails with pydantic_settings import errors
**Root cause**: Startup script using wrong virtual environment path
**Solution**: Fix startup script to use `venv/bin/activate` not `../venv/bin/activate`
**Prevention**: Virtual environment is in `/home/ufobeep/ufobeep/api/venv/`, not project root

## Key Learnings
- **Never test localhost** - production is on different machine (ufobeep.com)
- **Single server architecture** - all endpoints served by one FastAPI app
- **Environment files consolidated** - one .env file in project root
- **Storage migrated to filesystem** - no longer using MinIO, direct filesystem storage
- **Media storage complete** - using sighting IDs for permanent URLs with thumbnail support
- **Location data fixed** - Gallery photos now preserve GPS EXIF data using photo_manager library
- **Mobile permissions** - Added Android 13+ photo permissions and media location access
- **Photo metadata working** - Both camera captures and gallery selections extract GPS coordinates
- **GPS EXIF embedding implemented** - Photos now have GPS coordinates embedded in EXIF when sensor data available, preventing "Unknown Location" failures
- **Firebase App Distribution configured** - Beta testing via ./scripts/distribute-beta.sh for wireless APK distribution
- **SSH production**: `ssh -p 322 ufobeep@ufobeep.com`
- **Standard deploy**: `git push && ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull origin main && cd web && npm run build && pm2 restart all && pm2 list"`
- **Clean deploy** (when webpack breaks): `ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep/web && rm -rf .next node_modules/.cache && npm run build && pm2 restart all && pm2 list"`
- **PM2 troubleshoot**: `ssh -p 322 ufobeep@ufobeep.com "pm2 list"` (check for stopped processes)
- **API restart**: `ssh -p 322 ufobeep@ufobeep.com "sudo systemctl restart ufobeep-api"`

## Server Architecture & Nginx Configuration
- **Production server**: ufobeep.com (SSH port 322) - ALL TESTING HAPPENS HERE
- **Development machine**: /home/mike/D/ufobeep (code development only)
- **PM2 processes**: Run on production server, managed via SSH commands
- **Testing**: ALWAYS test on production server, never locally
- **Production builds**: Always built and deployed on production server via SSH

### Nginx Reverse Proxy Setup
- **Main domain**: ufobeep.com → Next.js app on localhost:3000
- **API domain**: api.ufobeep.com → FastAPI on localhost:8000
- **Media serving**: ufobeep.com/media/* → FastAPI on localhost:8000
- **Admin redirect**: ufobeep.com/admin → api.ufobeep.com/admin (301 redirect)

### Key Nginx Configuration Points
- **Location order matters**: More specific paths (e.g., `/admin`, `/media/`) must come before general paths (e.g., `/`)
- **Admin access**: Both https://api.ufobeep.com/admin and https://ufobeep.com/admin work
- **Configuration file**: `/etc/nginx/sites-enabled/zzz-ufobeep.conf`
- **Reload nginx**: `sudo nginx -s reload` after config changes
- **Test config**: `sudo nginx -t` before reloading

### Application-Level vs Server-Level Redirects
- **Next.js redirects**: Don't work reliably for cross-domain redirects
- **Nginx redirects**: Server-level 301 redirects are more reliable and efficient
- **Lesson**: Use nginx for infrastructure-level routing, Next.js for application routing

## Admin Interface (COMPLETED)
- **Primary URL**: https://api.ufobeep.com/admin
- **Redirect URL**: https://ufobeep.com/admin (nginx 301 redirect)
- **Authentication**: HTTP Basic Auth (username: admin, password: ufopostpass)
- **Features**: Dashboard, sightings management, media management, system status, MUFON integration, system logs
- **Implementation**: Complete FastAPI router with HTML interfaces and server-side rendered data
- **Database Integration**: Direct PostgreSQL queries for admin statistics and management
- **Security**: Password-protected endpoints with secrets.compare_digest for timing attack protection
- **Dashboard**: Server-side rendered statistics (no AJAX/credentials exposure)
- **Sightings Page**: Uses /alerts endpoint with media thumbnails (40x40px with video indicators)
- **Media Display**: Proper video/image detection with fallback icons and primary media indicators

### Rate Limiting Controls
- **Disable Rate Limiting**: `https://admin:ufopostpass@api.ufobeep.com/admin/ratelimit/off`
- **Enable Rate Limiting**: `https://admin:ufopostpass@api.ufobeep.com/admin/ratelimit/on`
- **Set Threshold**: `https://admin:ufopostpass@api.ufobeep.com/admin/ratelimit/set?N` (where N = number)
- **Clear History**: `https://admin:ufopostpass@api.ufobeep.com/admin/ratelimit/clear`
- **Check Status**: `https://admin:ufopostpass@api.ufobeep.com/admin/ratelimit/status`
- **Access**: Available in both web admin dashboard and mobile app admin section

## Proximity Alert System (COMPLETED)

### Phase 0 Emergency Alert Foundation ✅ COMPLETE
- **Status**: ✅ FULLY OPERATIONAL - All Phase 0 tasks complete as of 2025-08-16
- **Proximity Detection**: Haversine distance calculation (PostGIS not required)
- **Distance Rings**: 1km (emergency), 5km (urgent), 10km (normal), 25km (normal)
- **Rate Limiting**: Max 3 alerts per 15 minutes (emergency override at 10+ witnesses)
- **Quiet Hours**: User-configurable with emergency override
- **Device Registration**: Devices must have location data to receive alerts
- **Push Delivery**: Firebase Cloud Messaging (FCM) with correct project configuration
- **Audio & Vibration**: Audio focus for foreground alerts, haptic feedback for emergencies
- **Response Time**: 90-500ms alert delivery to nearby devices
- **Sound Behavior**: Custom sounds when app closed, system notification sound when app open

### Testing Proximity Alerts
```bash
# Send test alert from dev machine
curl -X POST https://api.ufobeep.com/beep/anonymous \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "test_device",
    "location": {"latitude": 36.24, "longitude": -115.24},
    "description": "Test proximity alert"
  }'

# Check registered devices with location
ssh -p 322 ufobeep@ufobeep.com "PGPASSWORD=ufopostpass psql -h localhost -U ufobeep_user -d ufobeep_db -c 'SELECT device_id, lat, lon FROM devices WHERE lat IS NOT NULL;'"
```

### Known Working Device
- **Device ID**: `android_V1UFN35H.193-20_1755327935654` (Las Vegas test device)
- **Location**: 36.2457131, -115.2411522
- **Status**: Successfully receiving proximity alerts

## Multi-Media System (COMPLETED)
- **Database Schema**: Added primary media designation, upload order, display priority fields
- **Migration**: `/api/migrations/001_add_media_primary_fields.sql` deployed to production
- **API Models**: Updated across all platforms (Python, TypeScript, Dart) for consistency
- **Mobile App**: Primary thumbnail display, "Add Photos & Videos" button, smart navigation
- **Web App**: Primary media thumbnails with visual indicators
- **Admin Management**: Set primary media, view metadata, manage media files

## Video Playback System (COMPLETED) 
- **API Media Type Detection**: `/api/app/main.py` - Fixed hardcoded 'image' defaults with `guess_media_type_from_filename()`
- **Mobile Video Player**: `/app/lib/screens/alerts/alert_detail_screen.dart` - `VideoPlayerWidget` with URL-based fallback detection
- **Website Video Player**: `/web/src/app/alerts/[id]/page.tsx` - HTML5 video with controls and poster thumbnails
- **AlertCard Component**: `/web/src/components/AlertCard.tsx` - Unified video detection for alerts page and homepage
- **Video Thumbnail URLs**: API generates `?thumbnail=true` URLs for video files
- **Video Detection**: `isVideoMedia()` helper with .mp4/.mov/.avi URL detection fallback
- **Camera Video Mode**: Mobile app camera toggle (photo/video) with 30s max recording
- **Share-to-Beep Videos**: Both photo and video sharing from gallery working
- **Complete Workflow**: Record video → upload → display correctly on mobile and web

### Video Components Fixed:
- **Individual Alert Pages**: `/web/src/app/alerts/[id]/page.tsx` - Conditional video/image rendering
- **Alerts List Page**: `/web/src/app/alerts/page.tsx` - Uses improved AlertCard component
- **Homepage Map Section**: `/web/src/components/RecentAlertsSidebar.tsx` - Uses AlertCard with video thumbnails
- **Mobile Alert Details**: `/app/lib/screens/alerts/alert_detail_screen.dart` - VideoPlayerWidget integration