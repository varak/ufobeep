# UFOBeep API Contracts & Models

This document defines the complete API contract for the UFOBeep platform, including all endpoints, data models, and client implementations.

## Overview

UFOBeep uses a FastAPI backend with shared data models across Flutter (Dart) and Next.js (TypeScript) clients. All APIs follow REST principles with JSON payloads and standardized response formats.

## Base Configuration

- **Base URL**: `https://api.ufobeep.com` (production) / `http://localhost:8000` (development)
- **API Version**: `v1`
- **Content Type**: `application/json`
- **Authentication**: Bearer token (where required)

## Core Data Models

### Enums

```typescript
enum SightingCategory { UFO = 'ufo', ANOMALY = 'anomaly', UNKNOWN = 'unknown' }
enum SightingStatus { PENDING = 'pending', VERIFIED = 'verified', EXPLAINED = 'explained', REJECTED = 'rejected' }
enum AlertLevel { LOW = 'low', MEDIUM = 'medium', HIGH = 'high', CRITICAL = 'critical' }
enum MediaType { PHOTO = 'photo', VIDEO = 'video', AUDIO = 'audio' }
```

### Location & Sensor Data

```typescript
interface GeoCoordinates {
  latitude: number      // -90.0 to 90.0
  longitude: number     // -180.0 to 180.0
  altitude?: number     // meters above sea level
  accuracy?: number     // GPS accuracy in meters
}

interface SensorData {
  timestamp: string     // ISO 8601 datetime
  location: GeoCoordinates
  azimuth_deg: number   // 0-360 compass heading
  pitch_deg: number     // -90 to 90 device tilt
  roll_deg?: number     // -180 to 180 device rotation
  hfov_deg?: number     // horizontal field of view
  vfov_deg?: number     // vertical field of view
  device_id?: string    // anonymous device identifier
  app_version?: string  // app version for debugging
}
```

### Environmental Context

```typescript
interface WeatherData {
  temperature_c?: number
  humidity_percent?: number     // 0-100
  pressure_hpa?: number
  wind_speed_ms?: number
  wind_direction_deg?: number   // 0-360
  visibility_km?: number
  cloud_cover_percent?: number  // 0-100
  conditions?: string           // "clear", "cloudy", "rainy", etc.
  precipitation_mm?: number
}

interface CelestialData {
  moon_phase?: string
  moon_illumination_percent?: number  // 0-100
  moon_altitude_deg?: number          // -90 to 90
  moon_azimuth_deg?: number           // 0-360
  sun_altitude_deg?: number           // -90 to 90
  sun_azimuth_deg?: number            // 0-360
  visible_planets: string[]
  satellite_passes: Record<string, any>[]
}
```

### Media & Enrichment

```typescript
interface MediaFile {
  id: string
  type: MediaType
  filename: string
  url: string               // public URL
  thumbnail_url?: string    // thumbnail for videos/images
  size_bytes: number
  duration_seconds?: number // for video/audio
  width?: number           // for images/video
  height?: number          // for images/video
  created_at: string       // ISO datetime
  metadata: Record<string, any>
}

interface PlaneMatchResult {
  is_likely_aircraft: boolean
  confidence: number        // 0.0 to 1.0
  matched_aircraft?: Record<string, any>
  reason: string
  checked_at: string       // ISO datetime
}

interface EnrichmentData {
  weather?: WeatherData
  celestial?: CelestialData
  plane_match?: PlaneMatchResult
  nearby_airports: Record<string, any>[]
  military_activity?: Record<string, any>
  processed_at: string     // ISO datetime
}
```

### Core Sighting Models

```typescript
interface SightingSubmission {
  title: string            // 5-200 chars
  description: string      // 10-2000 chars
  category: SightingCategory
  sensor_data: SensorData
  media_files: string[]    // media file IDs
  reporter_id?: string     // user ID (if authenticated)
  duration_seconds?: number
  witness_count: number    // 1-100
  tags: string[]          // max 10 tags
  is_public: boolean
  submitted_at: string    // ISO datetime
}

interface Sighting {
  id: string
  title: string
  description: string
  category: SightingCategory
  sensor_data: SensorData
  media_files: MediaFile[]
  status: SightingStatus
  enrichment?: EnrichmentData
  jittered_location: GeoCoordinates  // privacy-protected coordinates
  alert_level: AlertLevel
  reporter_id?: string
  witness_count: number
  view_count: number
  verification_score: number     // 0.0 to 1.0
  matrix_room_id?: string        // chat room ID
  submitted_at: string
  processed_at?: string
  verified_at?: string
  created_at: string
  updated_at: string
}
```

## API Endpoints

### Health & System

#### `GET /healthz`
Health check endpoint.
```json
Response: { "ok": true }
```

#### `GET /v1/ping`  
API connectivity test.
```json
Response: { "message": "pong" }
```

### Sightings

#### `POST /v1/sightings`
Submit a new sighting.
```json
Request: SightingSubmission
Response: DataResponse<{ sighting_id: string }>
```

#### `GET /v1/sightings/{sighting_id}`
Get sighting details.
```json
Response: DataResponse<Sighting>
```

#### `PUT /v1/sightings/{sighting_id}`
Update sighting (owner only).
```json
Request: UpdateSightingRequest
Response: DataResponse<Sighting>
```

#### `DELETE /v1/sightings/{sighting_id}`
Delete sighting (owner only).
```json
Response: APIResponse
```

### Alerts Feed

#### `GET /v1/alerts`
Get paginated alerts feed with filtering.
```json
Query Parameters:
- center_lat?: number
- center_lng?: number  
- radius_km?: number (max 1000)
- category?: SightingCategory
- status?: SightingStatus
- min_alert_level?: AlertLevel
- verified_only?: boolean
- offset?: number (default: 0)
- limit?: number (default: 20, max: 100)
- since?: ISO datetime
- until?: ISO datetime

Response: DataResponse<AlertsFeed>
```

### Media Upload

#### `POST /v1/media/presign`
Get presigned upload URL.
```json
Request: PresignedUploadRequest
Response: DataResponse<PresignedUploadData>
```

#### `POST /v1/media/complete`
Mark upload as complete.
```json
Request: MediaUploadCompleteRequest  
Response: DataResponse<MediaFile>
```

### User Profiles

#### `GET /v1/users/{user_id}/profile`
Get user profile.
```json
Response: DataResponse<UserProfile>
```

#### `PUT /v1/users/{user_id}/profile`
Update user profile.
```json
Request: Partial<UserProfile>
Response: DataResponse<UserProfile>
```

### Matrix Integration

#### `POST /v1/matrix/token`
Get Matrix access token for sighting chat.
```json
Request: MatrixTokenRequest
Response: DataResponse<MatrixTokenData>
```

### Plane Matching (Existing)

#### `POST /v1/plane-match`
Check if sighting matches known aircraft.
```json
Request: PlaneMatchRequest
Response: DataResponse<PlaneMatchResponse>
```

## Response Formats

All API responses follow these standard formats:

### Success Response
```json
{
  "success": true,
  "message": "Optional success message",
  "timestamp": "2024-01-15T10:30:00Z",
  "data": { /* response data */ }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "timestamp": "2024-01-15T10:30:00Z",
  "error_code": "VALIDATION_ERROR",
  "details": { /* additional error info */ }
}
```

### Paginated Response
```json
{
  "success": true,
  "timestamp": "2024-01-15T10:30:00Z",
  "data": [ /* array of items */ ],
  "total_count": 150,
  "offset": 0,
  "limit": 20,
  "has_more": true
}
```

## HTTP Status Codes

- `200 OK` - Successful request
- `201 Created` - Resource created successfully
- `400 Bad Request` - Invalid request data
- `401 Unauthorized` - Authentication required
- `403 Forbidden` - Access denied
- `404 Not Found` - Resource not found
- `409 Conflict` - Resource already exists
- `422 Unprocessable Entity` - Validation failed
- `429 Too Many Requests` - Rate limit exceeded
- `500 Internal Server Error` - Server error

## Authentication

Most endpoints require authentication via Bearer token:
```
Authorization: Bearer <access_token>
```

Public endpoints (no authentication required):
- `GET /healthz`
- `GET /v1/ping`
- `GET /v1/alerts` (public sightings only)
- `GET /v1/sightings/{id}` (public sightings only)

## Rate Limiting

- **Anonymous**: 100 requests/hour
- **Authenticated**: 1000 requests/hour  
- **Uploads**: 10 uploads/hour
- **Plane matching**: 100 requests/hour

## Client Implementation

### TypeScript/Next.js
- Models: `/web/src/types/api.ts`
- Client: `/web/src/config/api.ts`

### Dart/Flutter  
- Models: `/app/lib/models/api_models.dart`
- Client: `/app/lib/services/api_client.dart`

### Python/FastAPI
- Models: `/shared/api-contracts/core_models.py`
- Schemas: `/api/app/schemas/`

## Validation Rules

### Coordinates
- Latitude: -90.0 to 90.0
- Longitude: -180.0 to 180.0
- Altitude: Any reasonable value in meters

### Text Fields
- Title: 5-200 characters
- Description: 10-2000 characters
- Tags: 1-50 characters each, max 10 tags

### Numeric Fields
- Witness count: 1-100
- Alert range: 1-1000 km
- Confidence scores: 0.0-1.0
- Percentages: 0.0-100.0
- Angles: 0.0-360.0 (azimuth), -90.0-90.0 (elevation)

### File Uploads
- Max size: 50MB per file
- Supported types: JPEG, PNG, MP4, MOV, MP3, WAV
- Max files per sighting: 5

## Privacy & Security

### Location Privacy
- Exact coordinates are jittered by 100-300m before public sharing
- Original coordinates stored encrypted for distance calculations
- User can disable location sharing entirely

### Data Retention
- Sightings: Retained indefinitely (with user consent)
- Media files: Auto-deleted after 1 year if unused
- User data: Deleted within 30 days of account deletion

### Encryption
- All API communication via HTTPS
- Database fields encrypted at rest
- Matrix chat rooms use end-to-end encryption

## Error Handling

### Common Error Codes
- `VALIDATION_ERROR` - Input validation failed
- `AUTH_REQUIRED` - Authentication required
- `ACCESS_DENIED` - Insufficient permissions  
- `RESOURCE_NOT_FOUND` - Requested resource doesn't exist
- `RATE_LIMITED` - Too many requests
- `QUOTA_EXCEEDED` - Storage/usage quota exceeded
- `EXTERNAL_SERVICE_ERROR` - Third-party service unavailable

### Client Error Handling
Clients should implement:
- Automatic retry with exponential backoff
- Graceful degradation when services unavailable
- Clear error messages for users
- Offline mode for core functionality

## Versioning

API versioning follows semantic versioning:
- **Major**: Breaking changes (v1 -> v2)
- **Minor**: New features, backward compatible  
- **Patch**: Bug fixes, no breaking changes

Current version: `v1.0.0`

## Development & Testing

### Mock Data
Sample data available in:
- `/api/app/tests/fixtures/`
- `/app/test/fixtures/`
- `/web/src/__tests__/fixtures/`

### Environment URLs
- **Development**: `http://localhost:8000`
- **Staging**: `https://api-staging.ufobeep.com`
- **Production**: `https://api.ufobeep.com`