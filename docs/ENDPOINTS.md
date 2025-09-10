# API ENDPOINTS (Enhanced with NUFORC Integration)

## 🌐 URL Structure & Routing

UFOBeep now supports both traditional long URLs and smart short URLs with automatic language detection:

### Short URL System
- **Format**: `/{short_id}` or `/{short_id}/{lang}`
- **Examples**: 
  - `/ehf3` → Auto-detects language from browser, redirects to `/beep/es/ehf3` 
  - `/ehf3/fr` → Explicit French, redirects to `/beep/fr/ehf3`
- **Supported Languages**: es, de, fr, pt, ru, ja, zh, it, ar, ko, tr, hi, pl, cs, nl, sv, da, no, fi, el, he
- **Middleware**: Handles automatic language detection and URL rewriting

### Traditional URLs
- **Localized Detail Pages**: `/beep/{locale}/{slug}` 
- **API Endpoints**: `/api/*` (proxied to backend)
- **Static Pages**: `/app`, `/privacy`, `/terms`, etc.

### Backend API Endpoints

The API now maintains **dual endpoint compatibility** for different clients:

#### Unified Beep Endpoints (Primary)
- `GET /beep` - List sightings with advanced filtering
- `POST /beep` - Create new sighting  
- `GET /beep/{id}` - Get specific sighting details
- `POST /beep/{id}/media` - Attach media to sighting
- `POST /beep/{id}/witnesses` - Confirm witness sighting

#### Legacy Alert Endpoints (Mobile App Compatibility)
- `GET /alerts` - List alerts (same functionality as `/beep`)
- `POST /alerts` - Create new alert
- `GET /alerts/{id}` - Get specific alert details  
- `POST /alerts/{id}/media` - Attach media to alert
- `POST /alerts/{id}/witnesses` - Confirm witness sighting

**Note**: Both endpoint families return identical data structures. Frontend transforms `data.alerts` to `data.beeps` for consistency.

## Authentication
- `POST /users/auth/firebase` - Firebase authentication
- `GET /users/me` - Get current user profile
- `POST /users/regenerate-username` - Generate new username (FIXED in current release)

## Media Management  
- `POST /media/uploads` - Upload media files
- `GET /media/{id}` - Retrieve media file
- `POST /media/{id}/presign` - Get presigned upload URL

## Sightings & Alerts (Enhanced with NUFORC/MUFON Integration)

### Core Endpoints
Both `/beep` and `/alerts` endpoints support identical functionality:

**Listing Sightings**
- `GET /beep` or `GET /alerts` - List sightings with advanced filtering and geographic search
  - **Basic pagination**: `limit` (default: 20), `offset` (default: 0)
  - **Source filtering**: `source=UFOBeep|MUFON|NUFORC` (multiple sources: `source=MUFON,NUFORC`)
  - **Geographic search**: `near=Phoenix&radius=50` (radius in km, supports city names/coordinates)
  - **Shape filtering**: `shape=disc|triangle|light|sphere` etc.
  - **Tier filtering**: `tier=1|2|3|4` (NUFORC quality rating)
  - **Date filtering**: `date_from=2024-01-01&date_to=2024-12-31`
  - **Full-text search**: `q=bright%20lights` (searches descriptions)
  - Response: `{ success: true, data: { alerts: [...], total: 175000, page: 1, limit: 20, sources: {...}, filters: {...} } }`

**Individual Sightings**
- `GET /beep/{id}` or `GET /alerts/{id}` - Get specific sighting details with smart ID routing
  - **5-char alphanumeric** (ABC12) → UFOBeep sightings
  - **Numeric only** → MUFON cases or NUFORC reports (auto-detected)
  - **Prefixed IDs** → M123456 (MUFON), N987654 (NUFORC) - optional format

**Creating & Updating Sightings**
- `POST /beep` or `POST /alerts` - Create new sighting (supports locationless MUFON alerts)
- `POST /beep/{id}/media` or `POST /alerts/{id}/media` - Attach media to sighting
- `POST /beep/{id}/witnesses` or `POST /alerts/{id}/witnesses` - Confirm witness sighting (FIXED: type safety issues resolved)

### MUFON Integration
MUFON-sourced alerts (`source: "mufon"`) have special handling:
- Location data is optional (allows locationless alerts)
- UI widgets are automatically hidden (witness, map, time modal)
- Comment system disabled by default
- Enriched with UFO classification data

### NUFORC Integration
NUFORC-sourced alerts (`source: "nuforc"`) provide comprehensive historical data:
- **170,000+ reports** with sequential IDs (1, 2, 3...)
- **Quality tiers** (1=highest quality, 4=lowest quality)
- **Shape classifications** (disc, triangle, light, sphere, etc.)
- **Duration data** extracted from witness reports
- **Original report URLs** linking back to nuforc.org
- **Historical coverage** dating back decades

## Geographic Search & Filtering
- `GET /cities` - Get aggregated city data with sighting counts
  - Response: `{ success: true, data: [{ city: "Phoenix", state: "AZ", country: "US", count: 1247 },...] }`
- `GET /shapes` - Get shape classifications with counts  
  - Response: `{ success: true, data: [{ shape: "disc", count: 15432 }, { shape: "triangle", count: 8765 },...] }`
- `GET /recent` - Recent activity across all sources
  - Query params: `limit=50`, `hours=24` (recent within X hours)
  - Response: Latest sightings with source attribution and geographic data

## Advanced Search Examples
```bash
# UFOs near Phoenix within 50km (using either endpoint family)
GET /beep?near=Phoenix&radius=50
GET /alerts?near=Phoenix&radius=50

# NUFORC disc sightings from 2024
GET /beep?source=NUFORC&shape=disc&date_from=2024-01-01

# Tier 1 (high quality) NUFORC reports
GET /beep?source=NUFORC&tier=1

# Search descriptions for "bright lights"
GET /beep?q=bright%20lights

# Multiple sources, recent sightings
GET /beep?source=MUFON,NUFORC&date_from=2024-09-01

# Geographic coordinates search
GET /beep?near=40.7128,-74.0060&radius=100

# Combined filters
GET /beep?source=NUFORC&shape=triangle&tier=1,2&near=Las%20Vegas&radius=200&limit=100
```

## Comments System
- `GET /beep/{id}/comments` or `GET /alerts/{id}/comments` - Get sighting comments
- `POST /beep/{id}/comments` or `POST /alerts/{id}/comments` - Add comment to sighting

## Social Features
- `POST /beep/{id}/follow` or `POST /alerts/{id}/follow` - Follow sighting for updates
- `POST /devices/register` - Register device for push notifications

## User Preferences
- `GET /users/preferences` - Get user settings
- `POST /users/preferences` - Update user preferences
- Profile settings: quiet hours, DND, units, language, alert range

## Push Notifications
- FCM integration for real-time alerts
- Witness confirmation notifications
- Comment notifications

## Frontend API Compatibility

### Web Application
The Next.js web app uses a compatibility layer:
- Frontend calls: `/api/beep`
- Backend maps to: `/beep` endpoints
- Response transformation: `data.alerts` → `data.beeps`

### Mobile Application  
The Flutter mobile app uses:
- Direct calls to: `/alerts` endpoints
- Native response format: `data.alerts`

## Recent Fixes (September 2025)
- ✅ **URL Structure Overhaul**: New short URL system with language detection
- ✅ **Dual Endpoint Support**: Both `/beep` and `/alerts` endpoints for client compatibility
- ✅ **Language-Aware Routing**: Automatic browser language detection and URL rewriting
- ✅ **Middleware Implementation**: Smart URL routing with canonical redirects
- ✅ **Alerts API Pagination**: Added total count to alerts endpoint for "Showing X-Y of Z" frontend display
- ✅ **Location Null Handling**: Fixed 500 errors when alerts have no location data (MUFON imports)
- ✅ **Comments Auto-Refresh**: Fixed with frame-safe CommentsRefreshNotifier using postFrameCallback
- ✅ **Auto-Follow Reliability**: Added retry logic with exponential backoff for following sightings
- ✅ **Smart Navigation**: "I see it too" now navigates to comments when description exists
- ✅ **Notification Delivery**: Fixed confirmation comments to use direct DB insertion with proper notifications
- ✅ **Type Safety**: Using Set<VoidCallback> to prevent duplicate listeners
- ✅ **Witness Confirmation**: Fixed "string is not subtype of int at index" crash
- ✅ **Username Regeneration**: Added force_regenerate parameter 
- ✅ **UI Consistency**: Updated button styling across beep and alert pages

## Notes
- All POSTs require `Authorization: Bearer <token>`
- `Idempotency-Key` header recommended for media/sighting POSTs
- API responses use consistent JSON structure with defensive type checking
- Both `/beep` and `/alerts` endpoint families are functionally identical
- Frontend transformation ensures consistent `beeps` naming in web application
- Short URLs automatically redirect to localized canonical URLs