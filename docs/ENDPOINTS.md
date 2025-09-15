# API ENDPOINTS (Enhanced with NUFORC Integration)

## 🌐 URL Structure & Routing

UFOBeep now supports both traditional long URLs and smart short URLs with automatic language detection:

### Smart Short URL System with Multi-Language Support
- **Format**: `/{short_id}` or `/{short_id}/{lang}`
- **Intelligent Middleware**:
  - Auto-detects browser language (Accept-Language header)
  - Fetches alert data directly from backend API
  - Generates localized long slugs using actual ARB translation files
  - Single redirect to proper SEO-friendly URL
- **Examples**:
  - `/ehf3` → English browser: `/beep/en/ufo-sighting-las-vegas-nevada-2025-09-11-ehf3`
  - `/ehf3` → Spanish browser: `/beep/es/ovni-avistamiento-las-vegas-nevada-2025-09-11-ehf3`
  - `/ehf3/fr` → Explicit French: `/beep/fr/observation-ovni-las-vegas-nevada-2025-09-11-ehf3`
- **Supported Languages**: All 22 languages from mobile app ARB files
- **Translation Source**: Uses `app/lib/l10n/app_{locale}.arb` as single source of truth

### Traditional URLs
- **Localized Detail Pages**: `/beep/{locale}/{slug}`
- **API Endpoints**: `/api/*` (proxied to backend)
- **Static Pages**: `/app`, `/privacy`, `/terms`, etc.

### Backend API Endpoints

The API uses unified `/api/beep` endpoints for all sighting operations:

#### Beep Endpoints
- `GET /api/beep` - List sightings with advanced filtering
- `POST /api/beep` - Create new sighting
- `GET /api/beep/{id}` - Get specific sighting details
- `GET /api/beep/by-short-url/{short_id}` - Get sighting by short URL (5-char alphanumeric)
- `GET /api/beep/map-points` - Get optimized map data **[NEW - COMPLETED]**
- `POST /api/beep/{id}/media` - Attach media to sighting **[NEW - COMPLETED]**
- `PATCH /api/beep/{id}/media` - Update media files **[NEW - COMPLETED]**
- `POST /api/beep/{id}/witnesses` - Confirm witness sighting
- `GET /api/beep/{id}/comments` - Get sighting comments
- `POST /api/beep/{id}/comments` - Add comment to sighting
- `POST /api/beep/{id}/follow` - Follow sighting for updates

**Note**: All responses use consistent data structures with `data.beeps` containing the sighting list.

## Map Data System - COMPLETED ✅

### New Map Points Endpoint
- **Endpoint**: `GET /api/beep/map-points`
- **Query Parameters**:
  - `minimal=true` - Returns only essential data (id, coordinates, source) for lightweight map rendering
  - `minimal=false` (default) - Returns full alert details for map popups
- **Purpose**: Optimized endpoint for map display with thousands of data points
- **Response Format**:
  ```json
  {
    "success": true,
    "data": [
      {
        "id": "ABC12",
        "public_latitude": 40.7128,
        "public_longitude": -74.0060,
        "source": "UFOBeep",
        "enrichment_data": {...}
      }
    ]
  }
  ```

### Map Integration Features
- **Dynamic Rendering**: Fixed map display issues with proper zoom levels
- **Zoom Optimization**: Level 5 for US overview, Level 8 for user location
- **Performance**: Minimal query mode for initial load, full details on demand
- **Multi-Source**: Supports UFOBeep, MUFON, and NUFORC data points

## Media Upload System - COMPLETED ✅

### New Unified Implementation
- **Endpoint**: `POST /api/beep/{beep_id}/media`
- **PATCH Support**: `PATCH /api/beep/{beep_id}/media` for file updates
- **Mobile Integration**: Flutter app uses `/api/beep/` routing (nginx compatible)
- **Progress Tracking**: Individual file upload progress indicators
- **UX Improvements**:
  - Single-press upload (double-press issue eliminated)
  - File-by-file progress (black → blue → green)
  - Individual file removal with X buttons
  - Always-visible Camera/Gallery buttons
  - No UI flash during submission

### Media Upload Flow
```bash
# Create sighting
POST /api/beep
{
  "title": "UFO Sighting",
  "description": "Bright lights in sky",
  "location": {...}
}

# Upload media files
POST /api/beep/{beep_id}/media
Content-Type: multipart/form-data
- file: (binary data)
- source: "mobile_app"

# Update existing media
PATCH /api/beep/{beep_id}/media/{media_id}
Content-Type: multipart/form-data
- file: (binary data)
```

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
The `/api/beep` endpoints provide comprehensive functionality:

**Listing Sightings**
- `GET /api/beep` - List sightings with advanced filtering and geographic search
  - **Basic pagination**: `limit` (default: 20), `offset` (default: 0)
  - **Source filtering**: `source=UFOBeep|MUFON|NUFORC` (multiple sources: `source=MUFON,NUFORC`)
  - **Geographic search**: `near=Phoenix&radius=50` (radius in km, supports city names/coordinates)
  - **Shape filtering**: `shape=disc|triangle|light|sphere` etc.
  - **Tier filtering**: `tier=1|2|3|4` (NUFORC quality rating)
  - **Date filtering**: `date_from=2024-01-01&date_to=2024-12-31`
  - **Full-text search**: `q=bright%20lights` (searches descriptions)
  - Response: `{ success: true, data: { alerts: [...], total: 175000, page: 1, limit: 20, sources: {...}, filters: {...} } }`

**Individual Sightings**
- `GET /api/beep/{id}` - Get specific sighting details with smart ID routing
  - **5-char alphanumeric** (ABC12) → UFOBeep sightings
  - **Numeric only** → MUFON cases or NUFORC reports (auto-detected)
  - **Prefixed IDs** → M123456 (MUFON), N987654 (NUFORC) - optional format

**Creating & Updating Sightings**
- `POST /api/beep` - Create new sighting (supports locationless MUFON alerts)
- `POST /api/beep/{id}/media` - Attach media to sighting **[FULLY WORKING]**
- `POST /api/beep/{id}/witnesses` - Confirm witness sighting (FIXED: type safety issues resolved)

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
# UFOs near Phoenix within 50km
GET /api/beep?near=Phoenix&radius=50

# NUFORC disc sightings from 2024
GET /api/beep?source=NUFORC&shape=disc&date_from=2024-01-01

# Tier 1 (high quality) NUFORC reports
GET /api/beep?source=NUFORC&tier=1

# Search descriptions for "bright lights"
GET /api/beep?q=bright%20lights

# Multiple sources, recent sightings
GET /api/beep?source=MUFON,NUFORC&date_from=2024-09-01

# Geographic coordinates search
GET /api/beep?near=40.7128,-74.0060&radius=100

# Combined filters
GET /api/beep?source=NUFORC&shape=triangle&tier=1,2&near=Las%20Vegas&radius=200&limit=100
```

## Comments System
- `GET /api/beep/{id}/comments` - Get sighting comments
- `POST /api/beep/{id}/comments` - Add comment to sighting
- `DELETE /api/beep/{sighting_id}/comments/{comment_id}` - Delete comment (status_code=200)

## Social Features
- `POST /api/beep/{id}/follow` - Follow sighting for updates
- `DELETE /api/beep/{sighting_id}/follow` - Unfollow sighting (status_code=200)
- `GET /users/{user_id}/subscriptions` - Get user's active subscriptions/follows
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
- Response format: `data.beeps`

### Mobile Application
The Flutter mobile app uses:
- Direct calls to: `/api/beep` endpoints **[UPDATED FOR ROUTING]**
- Response format: `data.beeps`
- Media uploads: Uses nginx-compatible `/api/beep/{id}/media` routing

## MUFON Script Optimization - COMPLETED ✅

### Performance Improvements
- **Login Optimization**: Reduced retry delay from 5+ seconds to 2.2 seconds
- **Annual Time Savings**: ~18 minutes saved on login retries
- **Endpoint Consistency**: Uses same `/api/beep/` endpoints as mobile app
- **Reliability**: Maintains robust retry logic with optimized timings

### Script Configuration
```bash
# Optimized retry settings
retry_with_backoff(authenticate, max_retries=3, initial_delay=2)  # Was 5+ seconds
retry_with_backoff(setup_search, max_retries=2, initial_delay=3)
retry_with_backoff(get_results, max_retries=2, initial_delay=3)
```

## Middleware Architecture

### Short URL Processing Pipeline
UFOBeep uses advanced Next.js middleware for intelligent URL handling:

1. **Request Interception**: `/arnm6` → Middleware captures short URL pattern
2. **Language Detection**: Analyzes `Accept-Language` header for user preference
3. **Data Fetching**: Direct API call to `/api/beep/by-short-url/arnm6` backend
4. **Translation Loading**: Reads `app/lib/l10n/app_{locale}.arb` files for localized terms
5. **Slug Generation**: Creates SEO-friendly slug: `ovni-avistamiento-las-vegas-nevada-2025-09-11-arnm6`
6. **Single Redirect**: `301` redirect to `/beep/es/ovni-avistamiento-las-vegas-nevada-2025-09-11-arnm6`

### Benefits
- **Performance**: Single server-side redirect (no client-side loading states)
- **SEO**: Proper localized URLs with translated keywords
- **Accuracy**: Uses actual mobile app translations as single source of truth
- **Scalability**: Supports all 22 languages automatically

## Recent Fixes (September 2025)
- ✅ **Map System Implementation**: Added `/api/beep/map-points` endpoint for optimized map data loading
- ✅ **Map Display Fixed**: Corrected zoom levels (5 for US view, 8 for user location) and dynamic rendering
- ✅ **Media Badge Logic**: Fixed three-state system (Image Only/Video Only/Media Only) with proper display logic
- ✅ **Video Permission Fix**: Added microphone permission request for video recording functionality
- ✅ **Translation System**: Fixed beepOnly vs reportOnly translation keys across all languages
- ✅ **Media Upload Feature Complete**: Unified BeepScreen with seamless upload experience
- ✅ **Double-Press Issue Eliminated**: Single-tap media submission working perfectly
- ✅ **Progress Indicators Added**: Individual file progress tracking (black → blue → green)
- ✅ **File Management UX**: X buttons for individual file removal, always-visible controls
- ✅ **API Endpoint Standardization**: All clients use `/api/beep/` for consistency
- ✅ **MUFON Script Optimization**: 2.2s login delay (down from 5+s), saving ~18min annually
- ✅ **Mobile Build 109**: Current production version with complete map and media features
- ✅ **Smart Middleware System**: Intelligent short URL processing with language detection
- ✅ **ARB Translation Integration**: Uses mobile app translation files as single source
- ✅ **Simplified Flow**: Reduced from 5 steps to 2 steps for better performance
- ✅ **Multi-Language Slugs**: Generates proper localized URLs (UFO Sighting → OVNI Avistamiento)
- ✅ **Beeps API Pagination**: Added total count to beeps endpoint for "Showing X-Y of Z" frontend display
- ✅ **Location Null Handling**: Fixed 500 errors when alerts have no location data (MUFON imports)
- ✅ **Comments Auto-Refresh**: Fixed with frame-safe CommentsRefreshNotifier using postFrameCallback
- ✅ **Auto-Follow Reliability**: Added retry logic with exponential backoff for following sightings
- ✅ **Smart Navigation**: "I see it too" now navigates to comments when description exists
- ✅ **Notification Delivery**: Fixed confirmation comments to use direct DB insertion with proper notifications
- ✅ **Type Safety**: Using Set<VoidCallback> to prevent duplicate listeners
- ✅ **Witness Confirmation**: Fixed "string is not subtype of int at index" crash
- ✅ **Username Regeneration**: Added force_regenerate parameter
- ✅ **UI Consistency**: Updated button styling across beep and alert pages
- ✅ **Following Alerts Navigation**: Fixed context.go routing for mobile app
- ✅ **Following Alerts Location Display**: Fixed COALESCE for UFOBeep and MUFON location data
- ✅ **Comment Deletion Documentation**: Added DELETE endpoints to documentation

## Current Status
- **API Endpoints**: All `/api/beep/` endpoints fully functional ✅
- **Map System**: Complete implementation with optimized data loading ✅
- **Media Upload**: Complete implementation with progress tracking ✅
- **Mobile App**: Build 109 (v1.0.0-beta.8+109) deployed ✅
- **MUFON Integration**: Optimized and working with new endpoints ✅
- **Backend**: Stable with dual endpoint support ✅

## Notes
- All POSTs require `Authorization: Bearer <token>`
- `Idempotency-Key` header recommended for media/sighting POSTs
- API responses use consistent JSON structure with defensive type checking
- All clients use unified `/api/beep` endpoint family
- Frontend transformation ensures consistent `beeps` naming in web application
- Short URLs automatically redirect to localized canonical URLs
- Media uploads now support both POST (create) and PATCH (update) operations
- Map endpoints support both minimal and full data modes for performance optimization