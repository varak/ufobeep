# Media Storage System Redesign

## Current Problems
- Images stored with random upload IDs: `upload_1755087754042_8b202a171729/UFOBeep_1755087744706.jpg`
- Complex signed URLs with query parameters that expire and fail
- No logical connection between sighting ID and media storage path
- 403 Forbidden errors due to signature mismatches
- Thumbnails not displaying on alerts page
- Media URLs are messy and unmaintainable

## New Design Goals
- **Logical storage**: `/media/{sighting_id}/{filename}`
- **Permanent URLs**: `https://ufobeep.com/media/{sighting_id}/image1.jpg`
- **Simple querying**: List all media for a sighting by directory
- **Clean database**: Store sighting ID, generate media URLs on demand
- **No expiring signatures**: Direct file serving

## Implementation Tasks

### Phase 1: Update Storage Structure
- [ ] Modify media upload to use sighting ID as directory structure
- [ ] Update `storage_service.py` to organize by sighting ID
- [ ] Change upload path from `uploads/YYYY/MM/{upload_id}/` to `sightings/{sighting_id}/`

### Phase 2: Update API Endpoints
- [ ] Modify `/media/presign` endpoint to accept sighting_id parameter
- [ ] Update `/media/complete` endpoint to store files under sighting ID
- [ ] Create simple `/media/{sighting_id}` endpoint to list sighting media
- [ ] Add `/media/{sighting_id}/{filename}` endpoint for direct file serving

### Phase 3: Update Mobile App
- [ ] Modify mobile app to pass sighting_id to media upload
- [ ] Update `api_client.dart` to use new sighting-based upload flow
- [ ] Change media_info structure to use simple filenames instead of full URLs

### Phase 4: Update Database Schema
- [ ] Simplify media_files storage - store just filename, not full URL
- [ ] Update `/alerts` endpoint to generate media URLs from sighting_id + filename
- [ ] Remove complex URL generation from database storage

### Phase 5: Update Web Frontend
- [ ] Update alerts page to use new media URL format
- [ ] Update alert detail page to use sighting-based media URLs
- [ ] Remove URL signing and use direct file serving

### Phase 6: Migration & Cleanup
- [ ] Create migration script for existing media files
- [ ] Update MinIO bucket structure
- [ ] Remove old upload-based storage code
- [ ] Clean up expired/orphaned upload directories

## New URL Structure
```
Storage:     /sightings/{sighting_id}/image1.jpg
Public URL:  https://ufobeep.com/media/{sighting_id}/image1.jpg
Directory:   /sightings/876955a1-6b9d-40be-b26d-4ef08f788d73/
Files:       - photo1.jpg
             - photo2.jpg
             - video1.mp4
```

## Database Changes
```json
// OLD complex structure:
"media_files": [{
  "id": "c4d78d9b-24bb-4f50-8794-a48ee71dcfea",
  "url": "http://ufobeep.com:9000/ufobeep-media/uploads/2025/08/upload_1755087754042_8b202a171729/UFOBeep_1755087744706.jpg?X-Amz-Algorithm=...",
  "thumbnail_url": "..."
}]

// NEW simple structure:
"media_files": [
  "photo1.jpg",
  "photo2.jpg"
]
// URLs generated on demand: https://ufobeep.com/media/{sighting_id}/photo1.jpg
```

## Benefits
- ✅ Clean, logical storage organization
- ✅ Permanent URLs that don't expire
- ✅ Easy to query media for any sighting
- ✅ Simple database storage
- ✅ No signature issues or 403 errors
- ✅ Maintainable and scalable