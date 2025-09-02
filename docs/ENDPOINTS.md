# API ENDPOINTS (MP16 Implementation Status)

## Authentication
- `POST /users/auth/firebase` - Firebase authentication
- `GET /users/me` - Get current user profile
- `POST /users/regenerate-username` - Generate new username (FIXED in current release)

## Media Management  
- `POST /media/uploads` - Upload media files
- `GET /media/{id}` - Retrieve media file
- `POST /media/{id}/presign` - Get presigned upload URL

## Alerts & Sightings
- `POST /alerts` - Create new sighting alert (supports locationless MUFON alerts)
- `GET /alerts` - List alerts with filtering (includes MUFON source alerts)
- `GET /alerts/{id}` - Get specific alert details
- `POST /alerts/{id}/media` - Attach media to alert
- `POST /alerts/{id}/witnesses` - Confirm witness sighting (FIXED: type safety issues resolved)

### MUFON Integration
MUFON-sourced alerts (`source: "mufon"`) have special handling:
- Location data is optional (allows locationless alerts)
- UI widgets are automatically hidden (witness, map, time modal)
- Comment system disabled by default
- Enriched with UFO classification data

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
