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
- `POST /alerts` - Create new sighting alert
- `GET /alerts` - List alerts with filtering
- `GET /alerts/{id}` - Get specific alert details
- `POST /alerts/{id}/media` - Attach media to alert
- `POST /alerts/{id}/witnesses` - Confirm witness sighting (FIXED: type safety issues resolved)

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

## Recent Fixes (Current Release)
- ✅ **Witness Confirmation**: Fixed "string is not subtype of int at index" crash
- ✅ **Username Regeneration**: Added force_regenerate parameter 
- ✅ **Type Safety**: Defensive JSON parsing for all API responses
- ✅ **UI Consistency**: Updated button styling across beep and alert pages
- ✅ **Unified Notifications**: Confirmation notifications now use existing comment system
- ✅ **Auto-refresh Fix**: Fixed route pattern for comments auto-refresh when viewing
- ✅ **Navigation Fix**: Corrected route paths from '/alerts/alert/{id}/comments' to '/alert/{id}/comments'

Notes:
- All POSTs require `Authorization: Bearer <token>`
- `Idempotency-Key` header recommended for media/alerts POSTs
- API responses use consistent JSON structure with defensive type checking
