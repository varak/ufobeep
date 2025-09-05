# MUFON Data Pipeline Documentation

## Overview

The MUFON Data Pipeline extracts UFO sighting reports from the MUFON Case Management System (CMS) and imports them into UFOBeep as enriched alerts with media files.

## Pipeline Components

### 1. Authentication (`mufon_clicker/production_mufon_login.py`)
- **Purpose**: Authenticate with MUFON CMS and save session cookies
- **Input**: MUFON credentials from environment variables (.env.mufon)
- **Output**: `mufon_artifacts/storage_state.json` (browser session state)
- **Technology**: Playwright headless browser automation

```bash
python3 mufon_clicker/production_mufon_login.py
```

### 2. Data Extraction (`mufon_clicker/mufon_simple_extraction.py`)
- **Purpose**: Extract MUFON cases for a specific date with media files  
- **Input**: Date (YYYY-MM-DD format), environment variables from .env.mufon
- **Output**: JSON file with cases and downloaded media files
- **Technology**: Playwright + httpx for media downloads
- **Status**: ✅ **CURRENTLY WORKING** (Last updated 00:10)

```bash
# Must source environment first
cd /home/ufobeep/ufobeep
source .env.mufon
python3 mufon_clicker/mufon_simple_extraction.py 2025-01-27
```

**Output Format**: `mufon_simple_YYYY_MM_DD.json`

**Success Example**:
```
🎯 MUFON Simple Extraction for 2025-09-02
📊 Found 7 results
💾 Results saved to mufon_simple_2025_09_02.json
```
```json
{
  "search_date": "2025-01-27",
  "timestamp": "2025-09-02T06:57:22.567507",
  "total_cases": 18,
  "cases": [
    {
      "case_number": "143964",
      "date_time": "2025-09-02", 
      "short_description": "2025-09-01\\n6:31PM",
      "long_description": "round orb Metalic blackish...",
      "location": "round orb traveling south to north...",
      "media_files": [
        {
          "filename": "IMG1234.mov",
          "url": "http://mufoncms.com/cgi-bin/ffplay.pl?file=...",
          "type": "video",
          "local_path": "mufon_media/1_IMG1234.mov"
        }
      ],
      "row_index": 4
    }
  ]
}
```

### 3. UFO Classification (`ufo_classifier.py`)
- **Purpose**: Analyze case descriptions to classify UFO types
- **Input**: Long description text, short description 
- **Output**: UFO type classification with confidence score
- **Types**: Triangle, Sphere, Light, Cigar, Disc, Formation, Unknown

### 4. Data Import (`api/feeds/import_mufon_fixed.py`)
- **Purpose**: Import MUFON cases into UFOBeep database
- **Input**: JSON file from extraction step
- **Output**: UFOBeep alerts in PostgreSQL database
- **Features**:
  - Location extraction from narrative text
  - Geocoding with OpenStreetMap/Nominatim
  - UFO classification and enrichment
  - Media file upload to UFOBeep
  - UI widget customization for MUFON alerts

```bash
python3 api/feeds/import_mufon_fixed.py mufon_simple_2025_01_27.json
```

## Complete Pipeline Process

### Manual Execution (CURRENT WORKING PROCESS)
```bash
# Step 1: Go to working directory and load environment
cd /home/ufobeep/ufobeep
source .env.mufon

# Step 2: Fresh login to get cookies (optional - cookies last several hours)
python3 mufon_clicker/production_mufon_login.py

# Step 3: Extract live data for specific date  
python3 mufon_clicker/mufon_simple_extraction.py 2025-01-27

# Step 4: Import extracted data to database with media
python3 api/feeds/import_mufon_fixed.py mufon_clicker/mufon_simple_2025_01_27.json

# Step 5: Cleanup local files
rm -f mufon_clicker/mufon_simple_2025_01_27.json
rm -rf mufon_clicker/mufon_media/
```

### Automated Execution (CURRENT WORKING PIPELINE)
The complete pipeline can be run as a single command:
```bash
cd /home/ufobeep/ufobeep && \
source .env.mufon && \
python3 mufon_clicker/production_mufon_login.py && \
python3 mufon_clicker/mufon_simple_extraction.py 2025-01-27 && \
python3 api/feeds/import_mufon_fixed.py mufon_clicker/mufon_simple_2025_01_27.json && \
rm -f mufon_clicker/mufon_simple_2025_01_27.json && rm -rf mufon_clicker/mufon_media/
```

### Current Status (September 2025)
- ✅ **Authentication**: Fixed .env.mufon exports - working
- ✅ **Extraction**: mufon.sh unified script confirmed working
- ✅ **Import**: Processed 4/4 cases with full long descriptions successfully  
- ✅ **Parsing**: All major data extraction issues resolved
- ✅ **Popup Handling**: Long descriptions now extracted correctly using expect_popup()
- ⚠️  **Note**: Use mufon.sh as the single source of truth - other scripts deprecated

## Technical Details

### Authentication Method
- Uses Playwright to simulate browser login
- Saves complete browser session state including cookies
- Session state reused for subsequent extractions
- Authentication expires periodically, requiring fresh login

### Data Extraction Process (Updated September 2025)
1. **Authentication**: Handle session cookies automatically with persistent storage
2. **Navigate to Search**: Go to MUFON CMS search interface in iframe
3. **Set Date Range**: Use precise date selectors for target date
4. **Submit Search**: Execute search and wait for results table
5. **Parse Table Structure**: Extract data using correct column mapping:
   - cells[0] = Row number (ignore)  
   - cells[1] = Date Submitted
   - cells[2] = Date/Time of Event
   - cells[3] = Short Description  
   - cells[4] = Location
   - cells[6] = Attachments
6. **Extract Case IDs**: Parse real MUFON case ID from VIEW button onclick attribute
7. **Extract Long Descriptions**: Use expect_popup() context manager with proper waiting
8. **Download Media**: Convert HTTP to HTTPS URLs for media files
9. **Import to Database**: Create alerts directly in UFOBeep database

### Critical Technical Fixes (September 2025)

#### Case ID Extraction - Single Source of Truth
```python
# BEFORE: Using table row numbers (wrong)
numeric_case = raw_case.replace("#", "").strip()  # Results in 1, 2, 3...

# AFTER: Using VIEW button onclick (correct)  
onclick = inp.get_attribute('onclick')
match = re.search(r'id=(\d+)', onclick)  # Results in 143976, 143972...
real_case_id = match.group(1)
```

#### Popup Handling - Proper Async Context
```python
# BEFORE: Manual page counting (unreliable)
if len(page.context.pages) > 1:
    popup = page.context.pages[-1]
    popup_text = popup.locator("body").inner_text()  # Missing await!

# AFTER: Context manager with proper waiting (reliable)
with page.expect_popup() as popup_info:
    view_input.click()
popup = popup_info.value
popup.wait_for_load_state("domcontentloaded")
popup.wait_for_selector("pre", timeout=5000)
popup_text = popup.locator("pre").inner_text()
```

#### Media URL Handling - HTTPS Conversion
```python
# Convert HTTP to HTTPS to avoid 301 redirects
if href.startswith('http://'):
    href = href.replace('http://', 'https://')
```

### Location Processing
- **Primary**: Extract location from long description narrative text
- **Patterns**: "in [City], [State]", "near [Location]", "from [City]" etc.
- **Geocoding**: Use OpenStreetMap Nominatim for coordinates
- **Fallback**: Allow alerts without location data (MUFON-specific)

### UI Customization
MUFON alerts are customized to hide irrelevant UFOBeep features:
- Hide witness confirmation widgets
- Hide location pin widgets  
- Hide time modal and pin features
- Hide map widgets and sections
- Disable comments by default
- Force comment count display to actual count

### Media Handling
- Download media files during extraction phase
- Upload to UFOBeep media system during import
- Support for images (.jpg, .png) and videos (.mp4, .mov)
- Generate thumbnails and web-optimized versions
- Clean up local files after import

## Database Schema

MUFON alerts are stored in the standard UFOBeep `sightings` table with:
- `source = 'mufon'` - Identifies MUFON-imported alerts
- `enrichment_data` - Contains UFO classification and MUFON metadata
- `external_url` - Link back to original MUFON case (if available)
- `media_info` - JSON with uploaded media file details

## Error Handling

### Authentication Failures
- Login script fails if MUFON credentials invalid
- Session expires require fresh authentication
- Network issues cause extraction to fail

### Extraction Issues
- Missing data handled gracefully (empty fields)
- Media download failures logged but don't stop extraction
- Browser automation robust against page layout changes

### Import Problems
- Database connection failures halt import
- Invalid location data creates locationless alerts
- Media upload failures logged but don't fail case import
- Duplicate case detection prevents re-imports

## Monitoring and Logging

### Extraction Logging
```
🎯 MUFON WORKING Pipeline Starting...
📅 Date: 2025-01-27
🔑 Loaded 7 httpx cookies for media downloads
✅ Found 18 result rows for 2025-01-27
📎 Found attachments: IMG1234.mov
✅ Downloaded IMG1234.mov (9069439 bytes)
```

### Import Logging  
```
📊 Processing 18 MUFON cases from 2025-01-27
--- Processing MUFON Case #143964 ---
🔍 UFO Classification: Sphere (confidence: 0.20)
✅ Created alert: 31289f72-8f7b-4dc5-a548-b8121946ab51
📎 Uploading 3 media files...
✅ Successfully uploaded 3 media files
🎉 Import completed: 18/18 cases imported
```

## Production Deployment

### File Locations
- **Scripts**: `/home/ufobeep/ufobeep/`
- **Session Data**: `/home/ufobeep/ufobeep/mufon_artifacts/`
- **Media Files**: `/home/ufobeep/ufobeep/mufon_media/` (temporary)
- **Final Media**: `/home/ufobeep/ufobeep/media/{alert_id}/`

### Prerequisites
- Python 3.8+ with required packages
- Playwright browser automation
- httpx for HTTP requests
- PostgreSQL database access
- UFOBeep API running on localhost:8000

### Cron Automation
For nightly automated imports:
```bash
# Daily MUFON import at 2 AM
0 2 * * * cd /home/ufobeep/ufobeep && ./mufon_nightly_pipeline.py --date yesterday --cleanup
```

## Data Quality

### Classification Accuracy
UFO type classification uses keyword matching with confidence scores:
- **High Confidence (>0.4)**: Strong keyword matches
- **Medium Confidence (0.2-0.4)**: Moderate matches  
- **Low Confidence (<0.2)**: Weak/no matches, defaults to "Unknown"

### Location Accuracy
Location extraction success varies by case quality:
- **~70% Success**: Clear geographic references in descriptions
- **~20% Geocoded**: Valid coordinates found via Nominatim
- **~10% Locationless**: No geographic data, allowed for MUFON

### Media Completeness
Media download success depends on MUFON server availability:
- **~95% Success**: Standard images and videos
- **~5% Failures**: Large files, server timeouts, broken links

## Troubleshooting

### Common Issues

**Authentication Errors**:
```bash
# Re-run login script
python3 production_mufon_login.py
```

**No Results Found**:
- Date may have no MUFON submissions
- MUFON site may be down
- Search parameters may need adjustment

**Media Download Failures**:
- MUFON CDN may be unavailable  
- Large files may timeout
- Authentication cookies may be stale

**Import Database Errors**:
- Check UFOBeep API is running: `sudo systemctl status ufobeep-api`
- Verify database connectivity
- Check disk space for media uploads

### Debug Mode
Add verbose logging to scripts:
```bash
export MUFON_DEBUG=1
python3 mufon_working_pipeline.py 2025-01-27
```

## Performance Metrics

### Extraction Speed
- **~2-3 seconds per case** without media
- **~10-30 seconds per case** with media downloads
- **~5-15 minutes** for typical daily batch (10-20 cases)

### Import Speed  
- **~1-2 seconds per case** for database insertion
- **~5-10 seconds per media file** for upload and processing
- **~2-5 minutes** for typical daily batch

### Resource Usage
- **Memory**: ~200-500MB during extraction (browser overhead)
- **Disk**: ~50-500MB temporary media storage per batch
- **Network**: Variable based on media file sizes

---

*Last Updated: September 3, 2025 - Added comprehensive data parsing methods and technical fixes*