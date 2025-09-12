# Media Upload Analysis & Fix

## Problem Summary
4-day-old bug: Flutter app media uploads hang indefinitely after tapping "Beep" button with media files.

## Root Cause
When the API endpoints changed from `/alerts` to `/beep`, the media upload endpoint changed from:
- **Working**: `/alerts/{id}/media` ✅
- **Broken**: `/beep/{id}/media` ❌

## Key Differences

### Working MUFON Upload (mufon.sh:1018)
```python
upload_response = requests.post(
    f"https://ufobeep.com/api/alerts/{alert_id}/media", 
    files=files, 
    data=data, 
    timeout=120
)
```

### Broken Flutter Upload  
```dart
final uploadUri = baseUri.resolve('/beep/$sightingId/media');
```

## Technical Analysis

### `/alerts/{id}/media` Endpoint (WORKING)
- **File**: `api/app/routers/alerts.py:580`
- **Implementation**: Full MediaProcessingService integration
- **File handling**: Uses `shutil.copyfileobj(file.file, buffer)`
- **Response**: Returns processed URLs immediately
- **Status**: Proven stable for 4+ months

### `/beep/{id}/media` Endpoint (BROKEN)
- **File**: `api/app/routers/beep.py:326` 
- **Implementation**: NEW code that mirrors alerts endpoint
- **Issue**: Different flow and error handling
- **Status**: Potential bugs or missing pieces

## Solution Options

### Option 1: Fix `/beep/{id}/media` endpoint
- Debug the new beep media upload implementation
- Ensure it matches alerts endpoint behavior exactly
- Risk: May introduce new bugs

### Option 2: Use `/alerts/{id}/media` for now (RECOMMENDED)
- Change Flutter app to use proven working endpoint
- Immediate fix with zero risk
- Can migrate to beep endpoint later when stable

### Option 3: Use MediaService (api/app/services/media_service.py)
- Both MUFON and beep could use the same MediaService
- Centralized media handling
- Requires more refactoring

## Recommended Fix
**Immediate**: Change Flutter app to use `/alerts/{sighting_id}/media`
**Later**: Fix `/beep/{id}/media` to match alerts implementation exactly

## Enrichment Data Documentation

### Structure (for International Compatibility)
```json
{
  "classification": {
    "type": "triangle|disc|sphere|light|etc",
    "confidence": 0.0-1.0,
    "keywords": ["triangular", "three lights"]
  },
  "geocoding": {
    "latitude": 40.7128,
    "longitude": -74.0060,
    "location": "New York, NY",
    "display_name": "New York, New York, United States"
  },
  "mufon_case_number": "123456",
  "reported_when": "2025-01-15<br>8:30 PM EST", 
  "database_when": "2025-01-16",
  "seo_slug_en": "triangle-ufo-sighting-new-york-jan-15",
  "hide_witness_widget": true,
  "hide_location_widget": true
}
```

### International Standards
- **Coordinates**: WGS84 decimal degrees
- **Timestamps**: ISO 8601 with timezone
- **Classifications**: Shape-based (language-agnostic)
- **SEO Slugs**: Generate per language (`seo_slug_en`, `seo_slug_de`, etc)