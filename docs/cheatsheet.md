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

## Storage (MinIO)
- **MinIO endpoint**: http://localhost:9000 (on production server)
- **MinIO console**: http://localhost:9001 (on production server)  
- **Bucket name**: `ufobeep-media` 
- **Credentials**: minioadmin/minioadmin
- **Status**: Bucket exists but URLs have signature issues

## Media Storage Redesign (COMPLETED Phases 1-2)
- **✅ Phase 1**: Changed storage structure from random IDs to sighting-based organization
- **✅ Phase 2**: Added direct serving endpoint `/media/{sighting_id}/{filename}`
- **New structure**: `sightings/{sighting_id}/filename.jpg` in MinIO
- **New URLs**: `https://ufobeep.com/media/{sighting_id}/filename.jpg` (permanent)
- **Status**: API deployed, mobile app updated, testing in progress
- **Issue**: Mobile app getting type error on media upload (in progress)

## Presigned Upload Endpoint
- **Endpoint**: `POST https://api.ufobeep.com/media/presign`
- **Status**: ✅ Working and tested
- **Response includes**: upload_id, upload_url, S3 fields, policy, signature
- **Key structure**: `uploads/YYYY/MM/{upload_id}/{filename}`

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
- Photos saved to both app storage and user's gallery
- GPS data collected and sent with sighting submissions

## Testing Commands
```bash
# Test API health
curl -s https://api.ufobeep.com/media/health

# Test presigned upload
curl -s -X POST https://api.ufobeep.com/media/presign \
  -H "Content-Type: application/json" \
  -d '{"filename": "test.jpg", "content_type": "image/jpeg", "size_bytes": 1024}'
```

## Current Issues
- **Mobile app error**: `String is not a subtype of type 'int' of 'index'` on media upload
- **Root cause**: Likely type casting issue in API response parsing
- **Status**: Debugging with added logging, testing in progress

## Key Learnings
- **Never test localhost** - production is on different machine (ufobeep.com)
- **Single server architecture** - all endpoints served by one FastAPI app
- **Environment files consolidated** - one .env file in project root
- **MinIO bucket was missing** - had to recreate it
- **Media storage redesign complete** - using sighting IDs for permanent URLs
- **SSH production**: `ssh -p 322 ufobeep@ufobeep.com`
- **Deploy command**: `git push && ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && git pull && sudo systemctl restart ufobeep-api"`