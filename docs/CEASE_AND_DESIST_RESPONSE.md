# MUFON & NUFORC Cease and Desist Response

**Date:** November 7, 2025
**Status:** TEMPORARY REMOVAL - Data preserved for restoration
**Commit:** ae810552

## Summary

Temporarily removed all MUFON and NUFORC references and beeps from public display pending legal resolution of cease and desist notice. All data remains in database for restoration when resolved.

## Changes Made

### Backend API Filtering
**Files Modified:**
- `api/app/services/alerts_service.py`
- `api/app/routers/beep.py`

**Changes:**
- Added default WHERE clause: `(source IS NULL OR source NOT IN ('mufon', 'nuforc'))`
- Applied to:
  - `get_recent_alerts()` method
  - `get_total_alerts_count()` method
  - GET `/beep/map-points` endpoint (both minimal and full modes)
- Explicit source filtering still allows `?source=mufon` if needed for admin/legal purposes

### Website Content Removal
**Files Modified:**
- `web/src/app/page.tsx`
- `web/src/app/how-it-works/page.tsx`
- `web/src/app/faq/page.tsx`

**Changes:**
- Homepage: Removed section mentioning "Powered by Professional UFO Research" that referenced MUFON and NUFORC
- Homepage: Changed "Historical Database" card to "Community Reports" focusing on user-submitted data
- How It Works: Removed MUFON/NUFORC from Data Sources section
- How It Works: Changed AI summary reference from "NUFORC/MUFON reports" to generic "sighting reports"
- FAQ: Changed "How is UFOBeep different from MUFON or NUFORC?" to "How is UFOBeep different from traditional UFO reporting?"

### Defensive Client-Side Filtering
**Files Modified:**
- `web/src/components/AlertsMap.tsx`
- `app/lib/providers/alerts_provider.dart`

**Changes:**
- Added client-side filter as backup: `alerts.filter(alert => !alert.source || (alert.source !== 'mufon' && alert.source !== 'nuforc'))`
- Ensures no MUFON/NUFORC beeps display even if backend filtering fails
- Applied to mobile app alerts provider

## Data Preservation

### Database Status
```sql
SELECT source, COUNT(*) FROM sightings WHERE source IN ('mufon', 'nuforc') GROUP BY source;
```

**Results (as of Nov 7, 2025):**
- MUFON: 3,045 beeps
- NUFORC: 232 beeps
- Total: 3,277 beeps preserved

**Important:** Data is NOT deleted, only hidden from public queries.

## Scraper Scripts Status

### Disabled (Not Running)
- `mufon.sh` - MUFON daily import script
- `nuforc.sh` - NUFORC daily import script
- `scripts/mufon-nightly-import.sh` - Nightly cron script
- `scripts/setup-mufon-cron.sh` - Cron setup script

**Production Crontab:** Empty (verified Nov 7, 2025)

**Note:** Scripts remain in codebase but are not being executed.

## Testing Results

### API Endpoints
✅ **GET /beep?limit=10**
- Total alerts returned: 10
- Source breakdown: UFOBeep: 10
- MUFON/NUFORC: 0

✅ **GET /beep/map-points?minimal=true**
- Total map points: 92
- Sources on map: UFOBeep only
- MUFON/NUFORC: 0

### Website
✅ Homepage: No MUFON/NUFORC mentions
✅ How It Works: No MUFON/NUFORC mentions
✅ FAQ: Generic language about traditional reporting
✅ Map: Displays only UFOBeep beeps

### Mobile App
✅ Client-side filtering active in alerts provider
✅ Will not display MUFON/NUFORC beeps even if API returns them

## Direct Access Still Works

Individual MUFON/NUFORC beeps can still be accessed via:
- Direct UUID: `GET /beep/{uuid}`
- Short URL: `GET /beep/{short_url}`
- Admin query: `GET /beep?source=mufon`

This allows:
- Existing shared links to continue working
- Legal/admin review of specific beeps
- Restoration when C&D is resolved

## Restoration Process (When C&D Resolved)

### 1. Backend API
Revert changes in:
- `api/app/services/alerts_service.py` - Remove default exclusion filter
- `api/app/routers/beep.py` - Remove WHERE clause filters

### 2. Website Content
Restore original text in:
- `web/src/app/page.tsx` - Add back MUFON/NUFORC section
- `web/src/app/how-it-works/page.tsx` - Add back to data sources
- `web/src/app/faq/page.tsx` - Restore specific comparison question

### 3. Client-Side Filters
Remove defensive filters from:
- `web/src/components/AlertsMap.tsx` - Remove filteredAlerts
- `app/lib/providers/alerts_provider.dart` - Remove source filtering

### 4. Re-enable Scrapers (Optional)
If continuing MUFON/NUFORC imports:
- Set up production cron: `ssh -p 322 mike@ufobeep.com 'crontab -e'`
- Add: `0 2 * * * /home/ufobeep/ufobeep/scripts/mufon-nightly-import.sh`
- Test: `ssh -p 322 mike@ufobeep.com './mufon.sh yesterday'`

## Impact Assessment

### Before Changes
- Total public beeps: ~3,369 (3,277 MUFON/NUFORC + 92 UFOBeep)
- Map showed global coverage from historical data

### After Changes
- Total public beeps: 92 (UFOBeep only)
- Map shows only community-submitted sightings
- 97% reduction in displayed content

### User Experience
- Website now appears as pure community platform
- Historical data invisible to casual users
- Power users/admins can still access via source parameter
- No functionality broken (filters, search, maps all work)

## Legal Compliance

✅ MUFON/NUFORC content removed from public display
✅ Organization names removed from marketing content
✅ Scraper scripts disabled (not running)
✅ Data preserved for potential restoration
✅ Direct links still work (don't break existing shares)

## Notes

- Changes deployed: November 7, 2025 at 06:12 UTC
- Deployment verified on production
- No errors or service disruption
- Database queries optimized with proper indexes
- Mobile app will receive filtering on next API call (no app update needed)
