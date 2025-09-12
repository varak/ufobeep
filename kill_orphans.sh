#!/bin/bash
# Kill Orphans Script - Clean up orphaned data when Claude fucks up deletions
# Usage: ./kill_orphans.sh

echo "🧹 Cleaning up orphaned data..."
echo "This fixes what happens when deletions don't use the proper delete script"

# Clean orphaned database records
echo "🗑️ Cleaning orphaned database records..."

echo "  Cleaning photo_metadata..."
ssh -p 322 ufobeep@ufobeep.com 'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM photo_metadata WHERE sighting_id NOT IN (SELECT id FROM sightings);"'

echo "  Cleaning photo_analysis_results..."  
ssh -p 322 ufobeep@ufobeep.com 'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM photo_analysis_results WHERE sighting_id NOT IN (SELECT id FROM sightings);"'

echo "  Cleaning media_files..."
ssh -p 322 ufobeep@ufobeep.com 'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM media_files WHERE sighting_id NOT IN (SELECT id FROM sightings);"'

echo "  Cleaning comments..."
ssh -p 322 ufobeep@ufobeep.com 'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM comments WHERE sighting_id NOT IN (SELECT id FROM sightings);"'

echo "  Cleaning follows..."
ssh -p 322 ufobeep@ufobeep.com 'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM follows WHERE sighting_id NOT IN (SELECT id FROM sightings);"'

# Clean orphaned media directories
echo "🗑️ Cleaning orphaned media directories..."
ssh -p 322 ufobeep@ufobeep.com 'cd /home/ufobeep/ufobeep && python3 cleanup_orphaned_media.py'

echo "✅ Orphan cleanup complete"
echo "💡 Next time use the delete_user_beeps.py script instead of direct SQL!"
echo "🚨 CLAUDE: NEVER RUN DIRECT SQL DELETES - USE THE DELETE SCRIPT!"