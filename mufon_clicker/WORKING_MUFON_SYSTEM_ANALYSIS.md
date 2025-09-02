# WORKING MUFON SYSTEM ANALYSIS

## What We Discovered About The Working System

After reading through all the existing scripts in `/home/mike/D/ufobeep/api/feeds/`, I found the actual working MUFON import pipeline that was successfully "grabbing and adding them all" with media.

## The Working Pipeline Components

### 1. EXTRACTION SCRIPTS
- **`mufon_complete_scraper.py`** - The working extraction script
- **`working_mufon_search.py`** - Another working extraction approach
- Used **authenticated CMS** at `https://mufon.z2systems.com/` (not public site)
- Saved session state in `mufon_artifacts/storage_state.json`

### 2. IMPORT SCRIPT
- **`import_mufon_cases.py`** - The working import script
- **CRITICAL**: Used `/sightings/create` endpoint (NOT `/alerts`)
- Downloaded media to `/home/mike/D/ufobeep/api/media/` directory
- Used UUID filenames to avoid conflicts

### 3. MEDIA HANDLING - THE KEY DISCOVERY
- **Working media URLs used CGI format**: 
  ```python
  media_url = f"http://mufoncms.com/cgi-bin/ffplay.pl?file={filename}"
  ```
- **NOT the case_files URLs we were trying**:
  ```python
  # This was FAILING:
  media_url = f"https://mufoncms.com/case_files/{filename}" 
  ```

### 4. WORKING API ENDPOINT
- **Used**: `http://localhost:8000/sightings/create`
- **NOT**: `https://api.ufobeep.com/alerts` 
- Payload format from `import_mufon_cases.py`:
  ```python
  sighting_payload = {
      'external_id': f"mufon_{case_data.get('Case_Number', '')}",
      'source': 'mufon',
      'title': case_data.get('Short_Description', '')[:100],
      'description': case_data.get('Short_Description', ''),
      'location': case_data.get('Location', ''),
      'sighted_at': case_data.get('DateTime_Event', '').replace('\n', ' '),
      'reported_at': case_data.get('Date_Submitted', ''),
      'status': 'verified',
      'visibility': 'public',
      'media_files': media_files  # Downloaded media info
  }
  ```

## Why Media Was Working Before

1. **Correct URL format**: CGI script URLs instead of case_files
2. **Correct endpoint**: `/sightings/create` instead of `/alerts`
3. **Correct media handling**: Downloaded to local storage first, then included in payload
4. **No complex enrichment**: Simple classification, not the heavy enrichment we added

## The Complete Working Process

1. **Authentication**: Load `storage_state.json` for CMS access
2. **Extraction**: Use authenticated CMS search with coordinate-based form filling
3. **For each case**:
   - Extract basic info from table
   - Click VIEW to get long description + real case ID
   - Extract media filenames from attachments column
   - **Download media using CGI URLs**
   - **Import immediately via `/sightings/create`**
   - Move to next case

## What We Were Doing Wrong

1. **Wrong media URLs**: Using `case_files` instead of CGI script
2. **Wrong endpoint**: Using `/alerts` instead of `/sightings/create`  
3. **Wrong approach**: File-based batch processing instead of one-at-a-time
4. **Over-complicated**: Added heavy enrichment when working system was simple

## Current Status

- **`recreate_working_pipeline.py`** - Created to combine all working components
- Uses authenticated CMS + CGI media URLs + `/sightings/create` endpoint
- Processes one case at a time completely (extract → download media → import)

## Files That Show The Working System

- `/home/mike/D/ufobeep/api/feeds/mufon_complete_scraper.py` - Line 239 shows CGI URL format
- `/home/mike/D/ufobeep/api/feeds/import_mufon_cases.py` - Shows `/sightings/create` endpoint usage
- `/home/mike/D/ufobeep/api/feeds/upload_mufon_media.py` - Shows separate media upload process

## Next Steps

1. Test `recreate_working_pipeline.py` with a recent date
2. Verify media downloads work with CGI URLs
3. Verify `/sightings/create` endpoint accepts the payload
4. If successful, this recreates the working "grabbed and added them all" system

## Key Quote From User

"it grabbed and added them all" - referring to media files being successfully attached to cases, which was working with the CGI URL format and `/sightings/create` endpoint, NOT the `/alerts` endpoint we've been trying.

## Authentication Note

The working system uses the authenticated CMS at `mufon.z2systems.com` (member portal), not the public `mufon.com` site which is "garbage" as user noted.