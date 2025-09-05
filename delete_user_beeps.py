#!/usr/bin/env python3
"""
Delete all beeps from a specific user
"""

import subprocess
import sys

# The reporter_id for dark.idea.8245's test beeps
REPORTER_ID = "460911d5-e738-42f0-9a91-4e28c8886e44"

def delete_beeps():
    # Get all sighting IDs for this reporter
    cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM sightings WHERE reporter_id = '{REPORTER_ID}';" """
    
    try:
        result = subprocess.run(cmd, shell=True, capture_output=True, text=True)
        sighting_ids = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]
        
        if not sighting_ids:
            print("No sightings found for this user")
            return
        
        print(f"Found {len(sighting_ids)} sightings to delete")
        
        # Delete each sighting and associated data
        for sighting_id in sighting_ids:
            print(f"\nDeleting sighting {sighting_id}...")
            
            # Delete from related tables first
            tables = [
                'media_files',
                'comments', 
                'follows',
                'photo_metadata',
                'photo_analysis_results',
                'alert_notifications',
                'alert_deliveries',
                'alert_events'
            ]
            
            for table in tables:
                delete_cmd = f"""sudo -u postgres psql -d ufobeep_db -c "DELETE FROM {table} WHERE sighting_id = '{sighting_id}';" """
                subprocess.run(delete_cmd, shell=True, capture_output=True)
                print(f"  Cleaned {table}")
            
            # Delete the sighting itself
            delete_sighting = f"""sudo -u postgres psql -d ufobeep_db -c "DELETE FROM sightings WHERE id = '{sighting_id}';" """
            subprocess.run(delete_sighting, shell=True, capture_output=True)
            print(f"  Deleted sighting record")
        
        # Final count
        count_cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE reporter_id = '{REPORTER_ID}';" """
        result = subprocess.run(count_cmd, shell=True, capture_output=True, text=True)
        remaining = int(result.stdout.strip())
        
        if remaining == 0:
            print(f"\n✅ Successfully deleted all {len(sighting_ids)} test beeps")
        else:
            print(f"\n⚠️ {remaining} beeps still remain")
            
    except Exception as e:
        print(f"Error: {e}")
        sys.exit(1)

if __name__ == '__main__':
    delete_beeps()