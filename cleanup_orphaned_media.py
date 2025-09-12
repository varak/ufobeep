#!/usr/bin/env python3
"""
Clean up orphaned media directories and database records
"""

import os
import subprocess
import sys

def cleanup_orphaned_media():
    """Remove media directories that no longer have corresponding sightings"""
    media_dir = "/home/ufobeep/ufobeep/media"
    removed_count = 0
    
    try:
        for item in os.listdir(media_dir):
            item_path = os.path.join(media_dir, item)
            if os.path.isdir(item_path):
                # Check if sighting exists
                check_cmd = f'sudo -u postgres psql -d ufobeep_db -t -c "SELECT 1 FROM sightings WHERE id = \'{item}\';"'
                result = subprocess.run(check_cmd, shell=True, capture_output=True, text=True)
                
                if '1' not in result.stdout:
                    print(f"Removing orphaned media directory: {item}")
                    subprocess.run(f"rm -rf {item_path}", shell=True)
                    removed_count += 1
                    
        print(f"✅ Removed {removed_count} orphaned media directories")
        
    except Exception as e:
        print(f"Error cleaning media: {e}")

def cleanup_orphaned_db_records():
    """Clean up orphaned database records"""
    tables = [
        'photo_metadata',
        'photo_analysis_results', 
        'media_files',
        'comments',
        'follows'
    ]
    
    for table in tables:
        try:
            cmd = f'sudo -u postgres psql -d ufobeep_db -c "DELETE FROM {table} WHERE sighting_id NOT IN (SELECT id FROM sightings);"'
            result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
            print(f"Cleaned {table}: {result.stdout.strip()}")
        except Exception as e:
            print(f"Error cleaning {table}: {e}")

if __name__ == '__main__':
    print("🧹 Cleaning up orphaned media and database records...")
    cleanup_orphaned_media()
    cleanup_orphaned_db_records()
    print("✅ Cleanup complete")