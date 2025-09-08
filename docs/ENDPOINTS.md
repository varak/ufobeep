# API ENDPOINTS (Enhanced with NUFORC Integration)

## Authentication
- `POST /users/auth/firebase` - Firebase authentication
- `GET /users/me` - Get current user profile
- `POST /users/regenerate-username` - Generate new username (FIXED in current release)

## Media Management  
- `POST /media/uploads` - Upload media files
- `GET /media/{id}` - Retrieve media file
- `POST /media/{id}/presign` - Get presigned upload URL

## Alerts & Sightings (Enhanced)
- `POST /alerts` - Create new sighting alert (supports locationless MUFON alerts)
- `GET /alerts` - List alerts with advanced filtering and geographic search
  - **Basic pagination**: `limit` (default: 20), `offset` (default: 0)
  - **Source filtering**: `source=UFOBeep|MUFON|NUFORC` (multiple sources: `source=MUFON,NUFORC`)
  - **Geographic search**: `near=Phoenix&radius=50` (radius in km, supports city names/coordinates)
  - **Shape filtering**: `shape=disc|triangle|light|sphere` etc.
  - **Tier filtering**: `tier=1|2|3|4` (NUFORC quality rating)
  - **Date filtering**: `date_from=2024-01-01&date_to=2024-12-31`
  - **Full-text search**: `q=bright%20lights` (searches descriptions)
  - Response: `{ success: true, data: { alerts: [...], total: 175000, page: 1, limit: 20, sources: {...}, filters: {...} } }`
- `GET /alerts/{id}` - Get specific alert details with smart ID routing
  - **5-char alphanumeric** (ABC12) → UFOBeep alerts
  - **Numeric only** → MUFON cases or NUFORC reports (auto-detected)
  - **Prefixed IDs** → M123456 (MUFON), N987654 (NUFORC) - optional format
- `POST /alerts/{id}/media` - Attach media to alert
- `POST /alerts/{id}/witnesses` - Confirm witness sighting (FIXED: type safety issues resolved)

### MUFON Integration
MUFON-sourced alerts (`source: "mufon"`) have special handling:
- Location data is optional (allows locationless alerts)
- UI widgets are automatically hidden (witness, map, time modal)
- Comment system disabled by default
- Enriched with UFO classification data

### NUFORC Integration (New)
NUFORC-sourced alerts (`source: "nuforc"`) provide comprehensive historical data:
- **170,000+ reports** with sequential IDs (1, 2, 3...)
- **Quality tiers** (1=highest quality, 4=lowest quality)
- **Shape classifications** (disc, triangle, light, sphere, etc.)
- **Duration data** extracted from witness reports
- **Original report URLs** linking back to nuforc.org
- **Historical coverage** dating back decades

## Geographic Search & Filtering (New)
- `GET /cities` - Get aggregated city data with sighting counts
  - Response: `{ success: true, data: [{ city: "Phoenix", state: "AZ", country: "US", count: 1247 },...] }`
- `GET /shapes` - Get shape classifications with counts  
  - Response: `{ success: true, data: [{ shape: "disc", count: 15432 }, { shape: "triangle", count: 8765 },...] }`
- `GET /recent` - Recent activity across all sources
  - Query params: `limit=50`, `hours=24` (recent within X hours)
  - Response: Latest sightings with source attribution and geographic data

## Advanced Search Examples
```bash
# UFOs near Phoenix within 50km
GET /alerts?near=Phoenix&radius=50

# NUFORC disc sightings from 2024
GET /alerts?source=NUFORC&shape=disc&date_from=2024-01-01

# Tier 1 (high quality) NUFORC reports
GET /alerts?source=NUFORC&tier=1

# Search descriptions for "bright lights"
GET /alerts?q=bright%20lights

# Multiple sources, recent sightings
GET /alerts?source=MUFON,NUFORC&date_from=2024-09-01

# Geographic coordinates search
GET /alerts?near=40.7128,-74.0060&radius=100

# Combined filters
GET /alerts?source=NUFORC&shape=triangle&tier=1,2&near=Las%20Vegas&radius=200&limit=100
```

## Comments System
- `GET /alerts/{id}/comments` - Get alert comments
- `POST /alerts/{id}/comments` - Add comment to alert

## Social Features
- `POST /alerts/{id}/follow` - Follow alert for updates
- `POST /devices/register` - Register device for push notifications

## User Preferences
- `GET /users/preferences` - Get user settings
- `POST /users/preferences` - Update user preferences
- Profile settings: quiet hours, DND, units, language, alert range

## Push Notifications
- FCM integration for real-time alerts
- Witness confirmation notifications
- Comment notifications

## Recent Fixes (September 2025)
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

Notes:
- All POSTs require `Authorization: Bearer <token>`
- `Idempotency-Key` header recommended for media/alerts POSTs
- API responses use consistent JSON structure with defensive type checking
