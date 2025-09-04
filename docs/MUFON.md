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

## Current Status

The MUFON import functionality is operational and tested. Use mufon.sh for all MUFON data imports.