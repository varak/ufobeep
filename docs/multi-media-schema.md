# Multi-Media Database Schema Design

## Current State Analysis

✅ **Already Working**:
- `MediaType` enum supports PHOTO, VIDEO, AUDIO
- Multiple media files per sighting (array of MediaFile objects)
- Upload API supports multiple file types
- Media serving with thumbnails

🔴 **Missing Features**:
- Primary media designation (which shows in lists/thumbnails)
- User ownership tracking per media file
- Media upload order/sequence
- Display priority system

## Enhanced Schema Design

### 1. MediaFile Model Extensions

Add these fields to the existing `MediaFile` model:

```python
class MediaFile(BaseModel):
    # ... existing fields ...
    id: str
    type: MediaType
    filename: str
    url: str
    thumbnail_url: Optional[str] = None
    size_bytes: int
    duration_seconds: Optional[float] = None
    width: Optional[int] = None
    height: Optional[int] = None
    created_at: string
    
    # NEW FIELDS:
    is_primary: bool = False           # Mark as primary display image
    uploaded_by_user_id: Optional[str] = None  # Who uploaded this file
    upload_order: int = 0              # Order uploaded (0 = first/original)
    display_priority: int = 0          # Manual priority for display order
    contributed_at: Optional[datetime] = None  # When added to sighting
```

### 2. Database Table Changes

```sql
-- Add new columns to existing media_files table
ALTER TABLE media_files 
ADD COLUMN is_primary BOOLEAN DEFAULT FALSE,
ADD COLUMN uploaded_by_user_id UUID REFERENCES users(id),
ADD COLUMN upload_order INTEGER DEFAULT 0,
ADD COLUMN display_priority INTEGER DEFAULT 0,
ADD COLUMN contributed_at TIMESTAMP WITH TIME ZONE DEFAULT NOW();

-- Ensure only one primary per sighting
CREATE UNIQUE INDEX idx_media_files_primary_per_sighting 
ON media_files(sighting_id) 
WHERE is_primary = TRUE;

-- Index for efficient queries
CREATE INDEX idx_media_files_sighting_priority 
ON media_files(sighting_id, display_priority DESC, upload_order ASC);
```

### 3. Business Logic Rules

**Primary Media Selection**:
1. First uploaded file is automatically marked `is_primary = true`
2. Only one primary per sighting (database constraint)
3. If primary is deleted, next in priority order becomes primary
4. Users can manually set primary (reporter + admins only)

**Upload Order**:
- Original beep media: `upload_order = 0`
- Additional uploads: increment from 1, 2, 3...
- Determines fallback display order

**Display Priority**:
- Default: 0 (uses upload_order for sorting)  
- Manual override: higher numbers = higher priority
- Allows admins/reporters to reorder media display

**User Permissions**:
- Reporter can upload unlimited additional media
- Other users can contribute media if within proximity (future feature)
- Only reporter + admins can set primary or reorder

### 4. API Changes

**Media Upload Response**:
```json
{
  "success": true,
  "data": {
    "id": "media_123",
    "type": "photo",
    "filename": "UFO_2025.jpg",
    "is_primary": false,
    "upload_order": 2,
    "uploaded_by_user_id": "user_456"
  }
}
```

**Sighting Response with Ordered Media**:
```json
{
  "id": "sighting_789",
  "media_files": [
    {
      "id": "media_1",
      "type": "photo", 
      "is_primary": true,
      "upload_order": 0,
      "display_priority": 0
    },
    {
      "id": "media_2", 
      "type": "video",
      "is_primary": false,
      "upload_order": 1,
      "display_priority": 10  // Higher priority, shows second
    }
  ]
}
```

**New Endpoints**:
- `PUT /media/{media_id}/set-primary` - Set as primary image
- `PUT /media/{media_id}/priority` - Change display priority
- `GET /sightings/{id}/media?order=priority` - Get ordered media

### 5. Display Logic

**List View (Alerts/Sightings)**:
- Show primary media only
- Fallback: first by display_priority DESC, upload_order ASC
- Show media count badge: "📷 3" for multiple files

**Detail View**:
- Primary image prominent at top
- Additional media in gallery below  
- Order by: display_priority DESC, upload_order ASC
- Show uploader info: "Added by @username"

**Media Gallery**:
- Thumbnails ordered by priority/upload_order
- Primary has special styling/badge
- Click to expand full view
- Videos show duration overlay

### 6. Migration Strategy

**Phase 1: Schema Updates**
- Add new columns with defaults
- Mark first media file of each sighting as primary
- Set upload_order based on created_at timestamps

**Phase 2: API Updates**  
- Update upload endpoints to set new fields
- Modify sighting responses to include new fields
- Add media management endpoints

**Phase 3: UI Updates**
- Mobile app: primary image display in lists
- Web: media gallery with ordering
- Admin controls for primary/priority management

### 7. Implementation Priority

1. ✅ **Database schema changes** (add columns, constraints, indexes)
2. ✅ **API model updates** (update MediaFile model, responses) 
3. ✅ **Upload logic changes** (set is_primary, upload_order, user_id)
4. ✅ **Sighting display logic** (return ordered media, primary first)
5. ✅ **Mobile app updates** (show primary in lists, full gallery in details)
6. ✅ **Web app updates** (primary thumbnails, media gallery)
7. ✅ **Admin controls** (set primary, reorder media)

### 8. Success Metrics

- **Primary Display**: 100% of sightings have designated primary media
- **User Experience**: Media loads faster with proper primary/thumbnail system
- **Content Management**: Users can effectively organize multiple media per sighting
- **MUFON Integration**: Supports importing sightings with multiple attachments

### 9. Technical Considerations

**Storage**:
- Primary designation doesn't affect storage, just metadata
- Thumbnails generated for all media types (video screenshots)
- Existing media URLs remain unchanged

**Performance**:
- Database indexes support efficient primary lookup
- API responses include media order to minimize client-side sorting
- Thumbnail serving optimized for primary images

**Backwards Compatibility**:
- Existing media files get is_primary=false by default  
- First media file per sighting auto-promoted to primary
- Legacy API responses unchanged, new fields optional

---

**Status**: Ready for implementation  
**Prerequisites**: None - extends existing system  
**Estimated effort**: 2-3 days full implementation