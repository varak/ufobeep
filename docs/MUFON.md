# MUFON Data Scraper Documentation

## Overview

The MUFON scraper extracts real UFO sighting data from the MUFON (Mutual UFO Network) database and imports it into UFOBeep. MUFON is the world's largest UFO investigation organization with a comprehensive database of reported sightings.

## How to Use the MUFON Scraper

### Single Script: mufon.sh

**ONLY USE `mufon.sh`** - This is the complete, self-contained MUFON import script:

```bash
cd /home/ufobeep/ufobeep
./mufon.sh YYYY-MM-DD
./mufon.sh yesterday
./mufon.sh today
```

The script:
- Handles authentication automatically using `.env.mufon` credentials
- Extracts sighting data from MUFON database
- Validates case numbers (must be 5+ digits)
- Downloads and uploads media files
- Creates complete sightings with descriptions and media
- Validates data insertion into database

**Requirements:**
- `.env.mufon` file with MUFON credentials must exist
- Playwright browser dependencies installed
- UFOBeep API running on localhost:8000

### Script Operation Details

The script performs the following steps:
1. **Authentication** - Logs into MUFON using credentials from `.env.mufon`
2. **Search Setup** - Navigates to search page and sets date filters
3. **Data Extraction** - Parses sighting table data including:
   - Case numbers (validates 5+ digit format)
   - Descriptions (short and long)
   - Location information
   - Media attachments
4. **Media Download** - Downloads photos/videos from MUFON servers
5. **Import** - Creates sightings in UFOBeep database with all media
6. **Validation** - Verifies data was stored correctly

## Credentials Setup

Create `.env.mufon` file in `/home/ufobeep/ufobeep/`:

```bash
export MUFON_USERNAME=your_username
export MUFON_PASSWORD=your_password
```

**SECURITY:** Credentials are NEVER stored in git repository.

## Usage Examples

```bash
# Import yesterday's MUFON cases
./mufon.sh yesterday

# Import specific date
./mufon.sh 2025-09-03

# Import today's cases
./mufon.sh today
```

## Troubleshooting

### Common Issues

1. **Authentication Failed**: Check `.env.mufon` credentials
2. **No Cases Found**: Date may have no MUFON reports
3. **Timeouts**: MUFON site may be slow, script will retry
4. **API Errors**: Ensure UFOBeep API is running on localhost:8000

### Validation

The script validates:
- Case numbers must be 5+ digits
- Descriptions must not be empty
- Media files are properly uploaded
- Database entries are created correctly

## Output

Successful runs show:
- Authentication success
- Case processing with case numbers
- Media upload counts
- Final validation results

## Important Notes

- Script requires active internet connection to MUFON servers
- Large date ranges may take significant time to process  
- Media files are downloaded and uploaded automatically
- All imported sightings have source="mufon" for identification

## Technical Implementation Details

### Data Parsing Methods (September 2025)

The MUFON scraper uses advanced Playwright browser automation with specific parsing techniques:

#### 1. Case ID Extraction (Single Source of Truth)
```python
# Extract real MUFON case ID from VIEW button onclick attribute
for inp in inputs:
    onclick = inp.get_attribute('onclick') or ''
    value = inp.get_attribute('value') or ''
    if 'VIEW' in value and 'id=' in onclick:
        match = re.search(r'id=(\d+)', onclick)
        if match:
            real_case_id = match.group(1)  # e.g., 143976
```

**Key Insight**: VIEW button contains `popup_centered('public_report_handler.pl?req=view_long_desc&id=143976&rnd=')` with real case ID.

#### 2. Table Column Structure
```python
# MUFON table structure: Row#, Date Submitted, Date/Time of Event, Short Description, Location, Long Description, Attachments
row_number = cells[0].inner_text().strip()     # Row number (ignore)
report_date = cells[1].inner_text().strip()   # Date Submitted
sighting_datetime = cells[2].inner_text().strip()  # Date/Time of Event  
short_description = cells[3].inner_text().strip()  # Short Description
location = cells[4].inner_text().strip()      # Location of Event
# cells[6] = Attachments (media files)
```

#### 3. Long Description Extraction (Critical Fix)
```python
# Use expect_popup() context manager for proper popup handling
with page.expect_popup() as popup_info:
    view_input.click()
popup = popup_info.value
popup.wait_for_load_state("domcontentloaded")

# Wait for content selector before extraction
try:
    popup.wait_for_selector("pre", timeout=5000)
    popup_text = popup.locator("pre").inner_text()
except:
    popup_text = popup.locator("body").inner_text()

long_description = popup_text.strip()
popup.close()
```

**Critical Success Factor**: Using `expect_popup()` context manager and `wait_for_load_state()` ensures popup content is fully loaded before extraction.

#### 4. Media URL Handling
```python
# Convert HTTP to HTTPS to avoid 301 redirects
if href and not href.startswith('http'):
    href = f"https://mufoncms.com{href}"
elif href and href.startswith('http://'):
    href = href.replace('http://', 'https://')
```

### Debugging Methods

The script includes comprehensive debugging for troubleshooting:

```python
# Row element analysis
inputs = row.locator("input").all()
buttons = row.locator("button").all() 
links = row.locator("a").all()

for i, inp in enumerate(inputs):
    value = inp.get_attribute('value') or ''
    type_attr = inp.get_attribute('type') or ''
    onclick = inp.get_attribute('onclick') or ''
    log(f"🔍 INPUT[{i}]: type='{type_attr}', value='{value}', onclick='{onclick}'")
```

### Success Metrics (September 2025 Implementation)

✅ **Working Output Example**:
```
✅ Extracted real case ID from VIEW link: 143976
📝 Found long description from popup: Long Description of Sighting Report
I was looking to see what my camera picked up if anything for that night. I noticed what I thought was a plane, drone or helicopter. But then it looked like it stopped and was starting to go backwards when the video stopped recording...
📎 Found 2 media files
🎯 Case #143976 complete
🎉 Processing completed: 4 cases imported
```

## Current Status

The MUFON import functionality is fully operational and tested as of September 2025. All major parsing issues have been resolved:
- ✅ Real case ID extraction working (143976, 143972, 143969, 143965)
- ✅ Full long descriptions extracted from popups
- ✅ Media file detection and processing
- ✅ Proper column mapping and data validation

Use `mufon.sh` for all MUFON data imports.