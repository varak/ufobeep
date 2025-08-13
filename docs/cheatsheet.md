# UFOBeep API Infrastructure Cheatsheet

## Server Architecture
- **Single FastAPI server** serving all endpoints (confirmed correct architecture)
- **Production URL**: https://api.ufobeep.com
- **Local testing**: Production only - no localhost testing

## API Endpoints Structure
```
Single FastAPI app with routers:
- media.router     → /media/* endpoints  
- devices.router   → /devices/* endpoints
- plane_match.router → no prefix (root level)
- Direct endpoints: /alerts, /sightings, /healthz, /ping

⚠️  CRITICAL: sightings.router is NOT included in main.py
- Only the old /sightings endpoint in main.py is active
- The proper sightings router exists but isn't registered
- All mobile submissions go to the old endpoint
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

## Media Storage Issues (NEEDS REDESIGN)
- **Current problem**: Random upload IDs, complex signed URLs failing with 403 errors
- **Proposed solution**: Organize by sighting ID - `/sightings/{sighting_id}/filename.jpg`
- **See**: `/home/mike/D/ufobeep/mediastoragetodo.md` for redesign plan
- **Goal**: Simple permanent URLs like `https://ufobeep.com/media/{sighting_id}/photo1.jpg`

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
- **Virtual env**: `/home/mike/D/ufobeep/api/venv`
- **Dependencies**: Installed via `venv/bin/pip install -r requirements.txt`

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

## Key Learnings
- **Never test localhost** - production is on different machine (ufobeep.com)
- **Single server architecture** - all endpoints served by one FastAPI app
- **Environment files consolidated** - one .env file in project root
- **MinIO bucket was missing** - had to recreate it