# MUFON Data Scraper Documentation

## Overview

The MUFON scraper extracts real UFO sighting data from the MUFON (Mutual UFO Network) database and imports it into UFOBeep. MUFON is the world's largest UFO investigation organization with a comprehensive database of reported sightings.

## How the MUFON Scraper Works

### 1. Authentication Process (`production_mufon_login.py`)

**ALWAYS run authentication first** before any extraction:

```bash
python3 production_mufon_login.py
```

This script:
- Uses Playwright to open MUFON login page
- Fills login credentials from environment variables
- Saves authentication cookies to `storage_state.json`
- Verifies access to search functionality

### 2. Data Extraction (`mufon_proper_extraction.py`)

```bash
python3 mufon_proper_extraction.py YYYY-MM-DD
```

This script performs intelligent HTML parsing:

#### HTML Table Parsing
- **Does not assume fixed column positions** 
- Reads table headers to identify field locations dynamically
- Maps headers to expected fields:
  - Case number (contains "case" or "#")
  - Date/time (contains "date" and "time") 
  - Short description (contains "description" and "short")
  - Location (contains "location")
  - Attachments (contains "attach", "media", or "file")

#### Form Interaction
- Uses precise form field selectors discovered through debugging:
  - `select[name='event_date_lo__month']` - Start month
  - `select[name='event_date_lo__day']` - Start day  
  - `select[name='event_date_lo__year']` - Start year
  - `select[name='event_date_hi__month']` - End month (same as start for single day)
  - `select[name='event_date_hi__day']` - End day
  - `select[name='event_date_hi__year']` - End year

#### Media File Extraction
- Locates attachment links in the proper column
- Downloads media files (images and videos)
- Stores metadata with original MUFON URLs

#### Long Description Extraction
- Clicks VIEW buttons to open case details
- Handles popup windows or inline navigation
- Extracts full sighting narratives
- Finds substantial content using intelligent text analysis

### 3. Data Import (`import_mufon_fixed.py`)

```bash
python3 import_mufon_fixed.py filename.json
```

This script:
- Processes extracted JSON data
- Applies UFO classification using `ufo_classifier.py`
- Handles locationless alerts (MUFON often has vague locations)
- Creates UFOBeep alerts via API with proper metadata
- Uploads media files to UFOBeep storage

## Key Technical Details

### Field Mapping Issues

**CRITICAL:** MUFON's "Location" field often contains **sighting descriptions**, not geographic locations:

❌ Bad location data:
- "A silver disk like object rimmed with circular lights"
- "Two flickering stars positioned N & S of each other"
- "Observed possible drone began recording"

✅ Good location data:
- "Las Alamos, NM"
- "Newport, Oregon" 
- "Charlotte, North Carolina"

### Frontend Integration

MUFON alerts are displayed differently:
- **No location requirements** - alerts can exist without coordinates
- **UI widget hiding** - witness counts, maps, and time modals disabled
- **Special source identification** - `reporter_username: "MUFON_Database"`

Frontend filter allows MUFON alerts with (0,0) coordinates:
```javascript
// Allow MUFON alerts even without location data
const validAlerts = data.data.alerts.filter((alert) => 
  alert.location.latitude !== 0 || 
  alert.location.longitude !== 0 || 
  alert.reporter_username === 'MUFON_Database'
)
```

### UFO Classification

The system automatically classifies MUFON reports:
- **Triangle** - Triangular craft descriptions
- **Sphere** - Orb or spherical objects  
- **Formation** - Multiple objects in formation
- **Light** - Bright lights or illumination
- **Boomerang** - V-shaped or boomerang craft
- **Cigar** - Cylindrical objects
- **Unknown** - Unclassifiable reports

Each classification includes confidence scores (0.0 to 1.0).

## File Structure

```
/home/ufobeep/ufobeep/
├── production_mufon_login.py      # Authentication script
├── mufon_proper_extraction.py     # HTML parsing extraction
├── import_mufon_fixed.py          # Data import to UFOBeep
├── ufo_classifier.py             # UFO type classification
├── storage_state.json            # Authentication cookies
└── mufon_proper_YYYY_MM_DD.json  # Extracted data files
```

## Workflow Process

### Daily Extraction Workflow

1. **Authenticate** (must run first):
   ```bash
   python3 production_mufon_login.py
   ```

2. **Extract data** for specific date:
   ```bash
   python3 mufon_proper_extraction.py 2025-01-26
   ```

3. **Import to UFOBeep**:
   ```bash
   python3 import_mufon_fixed.py mufon_proper_2025_01_26.json
   ```

4. **Verify import**:
   ```bash
   curl -s 'https://api.ufobeep.com/alerts?limit=5' | jq '.data.alerts[] | select(.source=="mufon") | .title'
   ```

### Production Deployment

All scripts run directly on production server:
```bash
ssh -p 322 ufobeep@ufobeep.com
cd /home/ufobeep/ufobeep
# Run workflow above
```

## Common Issues

### Authentication Expiry
- MUFON sessions expire regularly
- Always run `production_mufon_login.py` first
- Check for "authentication working" confirmation

### Field Mapping Errors  
- MUFON table structure can change
- Script uses dynamic header detection
- Check field mapping output: `🗺️ Field mapping: {...}`

### Missing Location Data
- Many MUFON cases lack precise geographic coordinates
- This is normal - UFOBeep handles locationless MUFON alerts
- Frontend displays them without map integration

### Media Download Failures
- MUFON media links can be temporary or broken
- Script continues processing even if some media fails
- Check logs for `❌ Media error:` messages

## Data Quality

### Expected Results
- **10-50 cases per day** depending on UFO activity
- **20-70% have media files** (photos/videos)
- **30-60% have usable location data**
- **100% get UFO classification** with confidence scores

### Data Validation
- Case numbers must be unique
- Dates should match extraction target
- Long descriptions should be substantial (>100 characters)
- Media URLs should be accessible MUFON links

## Monitoring

### Success Indicators
- ✅ Authentication: "authentication working" message
- ✅ Extraction: "Successfully extracted data" with case count
- ✅ Import: "Import completed: X/Y cases imported"
- ✅ Frontend: MUFON alerts visible at ufobeep.com/alerts

### Failure Indicators  
- ❌ Login timeout errors
- ❌ Empty extraction results
- ❌ API import failures
- ❌ Missing alerts on website

## Future Enhancements

1. **Automated Daily Pipeline** - Cron job for daily extraction
2. **Better Location Parsing** - Improved geographic extraction from narratives  
3. **Media Validation** - Check file accessibility before import
4. **Duplicate Detection** - Cross-reference with existing UFOBeep data
5. **Real-time Monitoring** - Alert system for extraction failures