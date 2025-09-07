# MUFON Data Integration Documentation

## Overview

The MUFON integration extracts real UFO sighting data from the MUFON (Mutual UFO Network) database and imports it into UFOBeep. MUFON is the world's largest UFO investigation organization with a comprehensive database of reported sightings.

## Quick Start

### Single Command Script: mufon.sh

**ONLY USE `mufon.sh`** - This is the complete, self-contained MUFON import script:

```bash
# Production usage (from ufobeep server)
cd /home/ufobeep/ufobeep
./mufon.sh YYYY-MM-DD
./mufon.sh yesterday  
./mufon.sh today
./mufon.sh YYYY-MM-DD:YYYY-MM-DD   # date range (inclusive)
./mufon.sh yesterday:today         # relative range

# Local development usage
cd /home/mike/D/ufobeep
./mufon.sh YYYY-MM-DD
./mufon.sh YYYY-MM-DD:YYYY-MM-DD
```

### What It Does
- ✅ **Authentication**: Handles MUFON login automatically
- ✅ **Real Case IDs**: Extracts actual MUFON case numbers (143976, 143972, etc.)
- ✅ **Complete Descriptions**: Gets full witness narratives from popup windows
- ✅ **Media Download**: Downloads and uploads photos/videos from MUFON
- ✅ **Location Processing**: Extracts and geocodes location data
- ✅ **Database Import**: Creates complete UFOBeep alerts with all data

## Requirements

- **Credentials**: `.env.mufon` file with MUFON username/password
- **Dependencies**: Playwright browser automation installed
- **API**: UFOBeep API running on localhost:8000 (production) or 8080 (dev)
- **Network**: Active internet connection to MUFON servers

## How It Works

### Processing Pipeline
1. **Authentication** - Browser automation logs into MUFON CMS
2. **Search & Extract** - Navigates to search page, sets date filters, parses results
3. **Case Processing** - For each case found:
   - Extract real MUFON case ID from VIEW button URLs
   - Click VIEW buttons to get complete descriptions from popups
   - Download any attached media files (photos/videos)
   - Process location data and geocode coordinates
4. **Import** - Creates UFOBeep alerts with all extracted data
5. **Cleanup** - Removes temporary files and validates results

### Data Extracted
- **Case Numbers**: Real MUFON case IDs (e.g., 143976)
- **Descriptions**: Complete witness narratives (not just summaries)
- **Locations**: Geographic data with coordinate geocoding
- **Media Files**: Photos and videos with thumbnail generation
- **Metadata**: Report dates, submission dates, classifications

## Setup

### Credentials File
Create `.env.mufon` in the project root:

```bash
# Production: /home/ufobeep/ufobeep/.env.mufon
# Development: /home/mike/D/ufobeep/.env.mufon
export MUFON_USERNAME=your_mufon_username
export MUFON_PASSWORD=your_mufon_password
```

**SECURITY**: Credentials are never committed to git. File is in .gitignore.

### Dependencies
Playwright and Python dependencies are already installed on production.

## Usage Examples

```bash
# Import yesterday's MUFON cases (most common)
./mufon.sh yesterday

# Import specific date (YYYY-MM-DD format)
./mufon.sh 2025-09-03

# Import today's cases
./mufon.sh today

# Import a specific date range (inclusive)
./mufon.sh 2025-08-01:2025-08-15

# Import a relative range (yesterday through today)
./mufon.sh yesterday:today

# View output while running
./mufon.sh yesterday | tee mufon_import.log
```

Note: Date range support is built directly into `mufon.sh`, replacing the need for `mass_mufon_import.sh`.

### Expected Output
```
🚀 MUFON Pipeline Starting for 2025-09-03
✅ Loading MUFON credentials...
🔐 Testing MUFON authentication...
🎯 Processing MUFON cases for 2025-09-03
✅ Extracted real case ID from VIEW link: 143976
📝 Found long description from popup: Long Description...
📎 Found 2 media files
🎉 Processing completed: 4 cases imported
```

## Troubleshooting

### Common Issues & Solutions

**❌ MUFON credentials not found**
- Check `.env.mufon` file exists in project root
- Verify file has correct export statements
- Ensure no typos in username/password

**❌ No cases found for date**
- Try different date - MUFON may have no reports for that day
- Check MUFON website manually to verify data exists

**❌ API connection failed**
- Verify UFOBeep API is running: `sudo systemctl status ufobeep-api`
- Check correct port (8000 production, 8080 dev)

**❌ Media download failures**
- MUFON servers may be slow or unavailable
- Script will continue without media if downloads fail

**❌ Browser/Playwright issues**
- Restart the script - browser state may be corrupted
- Check disk space for browser cache files

### Validation Checks
The script automatically validates:
- ✅ Real MUFON case IDs extracted (not table row numbers)
- ✅ Complete long descriptions retrieved from popups
- ✅ Media files downloaded and uploaded successfully
- ✅ Database entries created with proper source attribution
- ✅ Location data geocoded when possible

## Web Interface Integration

MUFON alerts appear in UFOBeep with special handling:
- **Source Attribution**: Labeled as "MUFON Sphere Report", "MUFON Light Report", etc.
- **Location Display**: Shows location under title on alerts page
- **UI Customization**: Hides irrelevant features (witness confirmation, location pins)
- **Comments**: Shows actual comment count, not "No comments yet"
- **Media**: Displays photos and videos with proper thumbnails

## Current Status (September 2025)

- ✅ **Fully Operational**: All major parsing issues resolved
- ✅ **Real Case IDs**: Extracting actual MUFON case numbers (143976, 143972, etc.)
- ✅ **Complete Descriptions**: Getting full witness narratives from popups
- ✅ **Media Processing**: Downloading and uploading photos/videos successfully
- ✅ **Location Standardization**: Using standard alert.location field consistently
- ✅ **Web Integration**: Clean display with location under titles

## Technical Implementation Details

### Key Technical Components

#### 1. Authentication & Session Management
- Playwright browser automation for MUFON CMS login
- Session persistence using browser storage state
- Cookie management for media download requests

#### 2. Case ID Extraction (Critical Fix)
```python
# WRONG: Using table row numbers (gives 1, 2, 3...)
numeric_case = raw_case.replace("#", "").strip()

# RIGHT: Extract from VIEW button onclick attribute (gives 143976, 143972...)
for inp in inputs:
    onclick = inp.get_attribute('onclick') or ''
    if 'VIEW' in value and 'id=' in onclick:
        match = re.search(r'id=(\d+)', onclick)
        real_case_id = match.group(1)  # Actual MUFON case ID
```

#### 3. Table Column Mapping
```python
# MUFON search results table structure (7 columns)
row_number = cells[0].inner_text().strip()        # Row # (ignore)
report_date = cells[1].inner_text().strip()       # Date Submitted
sighting_datetime = cells[2].inner_text().strip() # Date/Time of Event  
short_description = cells[3].inner_text().strip() # Short Description
location = cells[4].inner_text().strip()          # Location of Event
# cells[5] = Long Description (VIEW button)
# cells[6] = Attachments (media files)
```

#### 4. Long Description Extraction (Critical)
```python
# WRONG: Manual popup detection (unreliable)
if len(page.context.pages) > 1:
    popup = page.context.pages[-1]
    popup_text = popup.locator("body").inner_text()  # May be incomplete

# RIGHT: Proper popup handling with waiting
with page.expect_popup() as popup_info:
    view_input.click()
popup = popup_info.value
popup.wait_for_load_state("domcontentloaded")
popup.wait_for_selector("pre", timeout=5000)
long_description = popup.locator("pre").inner_text()
popup.close()
```

**Success Factor**: `expect_popup()` context manager ensures complete popup loading.

#### 5. Media Processing
```python
# Fix MUFON media URLs for reliable downloads
if href and not href.startswith('http'):
    href = f"https://mufoncms.com{href}"  # Add domain
elif href and href.startswith('http://'):
    href = href.replace('http://', 'https://')  # Force HTTPS

# Download with authenticated session
response = await client.get(href, cookies=mufon_cookies)
```

#### 6. Location Processing & Geocoding
```python
# Extract location from narrative text using patterns
location_patterns = [
    r'in ([^,]+, [A-Z]{2})',  # "in Denver, CO"
    r'near ([^,]+)',          # "near downtown"
    r'from ([^,]+)',          # "from my backyard"
]

# Geocode with OpenStreetMap Nominatim
if location_text:
    geo_data = await geocode_location(location_text)
    if geo_data:
        alert_data["location"] = {
            "latitude": geo_data["latitude"], 
            "longitude": geo_data["longitude"],
            "name": geo_data["location"]
        }
```

### Success Metrics & Output

**Typical Working Session**:
```
🚀 MUFON Pipeline Starting for 2025-09-03
✅ Loading MUFON credentials...
🔐 Testing MUFON authentication...
🎯 Processing MUFON cases for 2025-09-03

--- Processing Case 1/4 ---
✅ Extracted real case ID from VIEW link: 143976
📝 Found long description from popup: I was looking to see what my camera...
📎 Found 2 media files
✅ Downloaded IMG_1234.jpg (145.2 KB)
✅ Downloaded VID_5678.mp4 (2.3 MB)
🌍 Geocoded location: Denver, CO (39.7392, -104.9903)
✅ Created UFOBeep alert: 31289f72-8f7b-4dc5-a548-b8121946ab51

🎉 Processing completed: 4/4 cases imported successfully
📊 Total: 4 alerts, 8 media files, 3 locations geocoded
```

## Data Quality & Performance

### Import Success Rates
- **Case Extraction**: ~95% success rate for finding valid cases
- **Description Retrieval**: ~90% success rate for popup extraction  
- **Media Downloads**: ~85% success rate (depends on MUFON server availability)
- **Location Geocoding**: ~70% success rate for coordinate extraction

### Performance Metrics
- **Speed**: ~10-30 seconds per case (including media downloads)
- **Typical Daily Import**: 5-20 cases, 2-10 minutes total
- **Resource Usage**: ~200-500MB memory during browser automation

## Database Integration

MUFON alerts are stored in the standard UFOBeep database with:
- `source = 'mufon'` - Identifies MUFON-imported alerts
- `reporter_username = 'MUFON'` - Attribution for UI display
- `enrichment_data` - Contains classification and metadata
- `location` - Standardized coordinates and location name
- Media files uploaded to standard UFOBeep media system

## Automated Scheduling

For daily automated imports, add to crontab:
```bash
# Daily MUFON import at 2 AM
0 2 * * * cd /home/ufobeep/ufobeep && ./mufon.sh yesterday
```

---

**Last Updated**: September 5, 2025  
**Status**: Fully operational and production-ready  
**Primary Script**: `mufon.sh` (single source of truth)
