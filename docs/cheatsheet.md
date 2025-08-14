# UFOBeep API Infrastructure Cheatsheet

## Server Architecture
- **Single FastAPI server** serving all endpoints (confirmed correct architecture)
- **Production URL**: https://api.ufobeep.com
- **Local testing**: Production only - no localhost testing

## API Endpoints Structure
```
Single FastAPI app with routers:
- media.router        → /media/presign, /media/complete, etc.
- media_serve.router  → /media/{sighting_id}/{filename} (NEW)
- devices.router      → /devices/* endpoints
- plane_match.router  → no prefix (root level)
- Direct endpoints: /alerts, /sightings, /healthz, /ping

✅ All routers properly included in main.py
✅ New media serving endpoint deployed
✅ Sighting-based media storage implemented
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
- `/alerts/[id]` - Old alert route (uses mock data, to be deprecated)
- `/app` - App download page

## Mobile App Flow
- Camera capture → Beep composition → Send beep → Alert detail page
- Gallery photo selection → EXIF GPS extraction → Send beep → Alert detail page
- Photos saved to both app storage and user's gallery
- GPS data collected from device sensors (camera captures) or EXIF data (gallery photos)
- **Location data workflow**: ✅ FIXED - Both app captures and gallery photos preserve GPS coordinates

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
- **SSH production**: `ssh -p 322 ufobeep@ufobeep.com`
- **Standard deploy**: `git push && ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull origin main && cd web && npm run build && pm2 restart all"`
- **Clean deploy** (when webpack breaks): `ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep/web && rm -rf .next node_modules/.cache && npm run build && pm2 restart all"`
- **API restart**: `ssh -p 322 ufobeep@ufobeep.com "sudo systemctl restart ufobeep-api"`

## Deployment Architecture Notes
- **Production server**: ufobeep.com (SSH port 322) - ALL TESTING HAPPENS HERE
- **Development machine**: /home/mike/D/ufobeep (code development only)
- **PM2 processes**: Run on production server, managed via SSH commands
- **Testing**: ALWAYS test on production server, never locally
- **Production builds**: Always built and deployed on production server via SSH