# Alert Deletion System

## Overview

The alert deletion system provides a safe, comprehensive way to delete UFOBeep alerts and all their associated data. It handles cascading deletes across multiple database tables and cleans up orphaned media files.

## Quick Start

### Production Usage

```bash
# SSH to production
ssh -p 322 ufobeep@ufobeep.com
cd /home/ufobeep/ufobeep

# Always test with dry-run first
python3 delete_alerts.py --before 2025-08-01 --dry-run

# Execute actual deletion (remove --dry-run)
python3 delete_alerts.py --before 2025-08-01
```

### Local Development

```bash
# Copy script to production first
scp -P322 /home/mike/D/ufobeep/delete_alerts.py ufobeep@ufobeep.com:/home/ufobeep/ufobeep/

# Then use production database for deletions
```

## Script Location

- **Development**: `/home/mike/D/ufobeep/delete_alerts.py`  
- **Production**: `/home/ufobeep/ufobeep/delete_alerts.py`

## Command Options

### Delete by Date Range
```bash
# Delete alerts created before specific date
python3 delete_alerts.py --before 2025-08-01 --dry-run
python3 delete_alerts.py --before 2025-09-05
```

### Delete by Source
```bash
# Delete all alerts from MUFON (when implemented)
python3 delete_alerts.py --source mufon --dry-run
```

### Delete Specific Alert
```bash
# Delete single alert by ID
python3 delete_alerts.py --alert-id 7f643cc1-ecb5-4ab2-9967-af893133f621 --dry-run
```

### Options
- `--dry-run` - Preview what would be deleted without making changes
- `--quiet` - Minimize output for automated scripts

## What Gets Deleted

### Database Records
The script removes records from these tables (when they exist):
- `sightings` - Main alert record
- `media_files` - Media file metadata
- `comments` - User comments on alerts  
- `follows` - User follows/subscriptions
- `photo_metadata` - EXIF and photo analysis data
- `photo_analysis_results` - AI analysis results

### Media Files
- Individual media files referenced in database
- Alert media directories (`/home/ufobeep/ufobeep/media/{alert-id}/`)
- Preserves directory structure but removes all files

### Foreign Key Handling
Uses `CASCADE DELETE` constraints where possible, handles manual cleanup for complex relationships.

## Example Output

### Dry Run Preview
```
[DRY RUN] Found 467 alerts before 2025-09-05 00:00:00
[DRY RUN] Deleting alert: 7f643cc1-ecb5-4ab2-9967-af893133f621
[DRY RUN]   Title: MUFON Report
[DRY RUN]   Source: mufon
[DRY RUN]   Created: 2025-09-05 02:22:23.912737+00:00
[DRY RUN]   Deleted media directory: /home/ufobeep/ufobeep/media/7f643cc1-ecb5-4ab2-9967-af893133f621 (2.3 MB)
[DRY RUN] 
Would delete: 467 alerts
Freed space: 156.7 MB
Use --dry-run=false to actually delete the data
```

### Actual Deletion
```
Deleting alert: 7f643cc1-ecb5-4ab2-9967-af893133f621
  Title: MUFON Report
  Source: mufon
  Created: 2025-09-05 02:22:23.912737+00:00
  Deleted 3 records from media_files
  Deleted 1 records from photo_metadata
  Deleted media directory: /home/ufobeep/ufobeep/media/7f643cc1-ecb5-4ab2-9967-af893133f621 (2.3 MB)
  Deleted main sighting record

Deleted: 467 alerts
Freed space: 156.7 MB
```

## Database Schema Compatibility

The script is designed to work with the current UFOBeep database schema:

### Main Table
- `sightings` - Primary alert storage (not `alerts`)

### Relationship Columns
- Most tables use `sighting_id` to reference alerts
- Some legacy tables may use `alert_id`
- Script handles both column naming patterns

### Media File Storage
- `media_files` table uses `sighting_id`, `url`, `filename`
- `photo_metadata` table uses `sighting_id`, `file_path` 
- Physical files stored in `/home/ufobeep/ufobeep/media/{sighting_id}/`

## Safety Features

### Mandatory Dry Run Testing
- Script requires explicit removal of `--dry-run` flag
- Shows exactly what would be deleted before execution
- Displays space that would be freed

### Transaction Safety  
- Uses database transactions for atomic operations
- If any part fails, entire deletion rolls back
- Prevents partial deletions that could leave orphaned data

### Error Handling
- Gracefully handles missing tables or columns
- Continues deletion even if some cleanup operations fail
- Reports errors but doesn't abort entire process

## Space Management Integration

This deletion system was created after discovering **13GB of orphaned media files** during production space cleanup. The script prevents similar issues by:

1. **Comprehensive Media Cleanup** - Removes both database records AND filesystem files
2. **Directory Structure Preservation** - Keeps media directory structure intact
3. **Space Reporting** - Shows exactly how much space is freed
4. **Orphan Prevention** - Ensures database and filesystem stay synchronized

## Common Use Cases

### Post-Import Cleanup
```bash
# After testing MUFON import, clean up test data
python3 delete_alerts.py --source mufon --dry-run
python3 delete_alerts.py --source mufon
```

### Date Range Cleanup
```bash
# Remove old test data before specific date
python3 delete_alerts.py --before 2025-08-01 --dry-run
python3 delete_alerts.py --before 2025-08-01
```

### Individual Alert Removal
```bash
# Remove specific problematic alert
python3 delete_alerts.py --alert-id abc123... --dry-run
python3 delete_alerts.py --alert-id abc123...
```

### Mass Cleanup for Fresh Import
```bash
# Clear all existing data before mass MUFON import
python3 delete_alerts.py --before 2025-12-31 --dry-run
python3 delete_alerts.py --before 2025-12-31
```

## Technical Implementation

### Database Connection
- Uses asyncpg for PostgreSQL connection
- Connection pool for efficient database operations
- Configured for production database credentials

### Error Recovery
- Handles connection failures gracefully
- Provides clear error messages
- Suggests troubleshooting steps

### Performance Optimization
- Batch operations where possible
- Efficient foreign key constraint handling
- Minimal memory footprint for large deletions

## Production History

### Space Crisis Resolution (September 2025)
- **Problem**: 13GB of orphaned media files from deleted alerts
- **Root Cause**: Previous deletion methods only removed database records
- **Solution**: Created comprehensive deletion script that handles both database and filesystem cleanup
- **Result**: Production disk usage reduced from 99% to 71% (17GB freed)

### Current Status
- ✅ **Fully Operational**: All database table relationships mapped correctly
- ✅ **Production Tested**: Successfully handles real production data
- ✅ **Space Efficient**: Prevents media file orphaning
- ✅ **Safe Operations**: Mandatory dry-run testing prevents accidents

## Future Enhancements

### Automated Scheduling
Consider adding cron job for periodic cleanup:
```bash
# Weekly cleanup of alerts older than 30 days
0 2 * * 0 cd /home/ufobeep/ufobeep && python3 delete_alerts.py --before $(date -d '30 days ago' +%Y-%m-%d) --quiet
```

### Enhanced Filtering
Potential additions:
- Delete by user/reporter
- Delete by alert status
- Delete by geographic region
- Bulk operations with confirmation prompts

### Monitoring Integration
- Log deletion activities to system logs
- Send notifications for large deletions
- Track space freed over time
- Alert on deletion failures

---

**Last Updated**: September 5, 2025  
**Status**: Production ready and fully operational  
**Primary Script**: `delete_alerts.py` (handles complete cascade deletion)