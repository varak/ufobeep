#!/usr/bin/env python3
"""
Delete all beeps from a specific user by username
Usage: python3 delete_user_beeps.py <username>

Examples:
  python3 delete_user_beeps.py "dark.idea.8245"
  python3 delete_user_beeps.py "enigmatic.entity.2741" 
  python3 delete_user_beeps.py "instant.storm.2516"

This script safely deletes:
- Sighting records
- Media files and metadata
- Comments
- Follows
- Photo analysis results
- Alert notifications and deliveries
- Alert events
"""

import subprocess
import sys

def delete_beeps(username):
    if username.lower() == 'mufon':
        print("Deleting ALL MUFON beeps...")
        # Get all MUFON sighting IDs
        cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM sightings WHERE source = 'mufon';" """
    else:
        print(f"Looking up device ID for username: {username}")
        
        # First, find the user ID for this username from users table
        lookup_cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM users WHERE username = '{username}';" """
        
        try:
            lookup_result = subprocess.run(lookup_cmd, shell=True, capture_output=True, text=True)
            device_ids = [line.strip() for line in lookup_result.stdout.strip().split('\n') if line.strip()]
            
            if not device_ids:
                print(f"No device ID found for username: {username}")
                return
                
            device_id = device_ids[0]  # Use first match
            print(f"Found device ID: {device_id}")
            
        except Exception as e:
            print(f"Error looking up device ID: {e}")
            return
        
        # Get all sighting IDs for this device_id
        cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM sightings WHERE reporter_id = '{device_id}';" """
    
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
            
            # Delete from related tables first (order matters for foreign keys)
            tables = [
                'alert_deliveries',    # Delete delivery records first
                'alert_notifications', # Delete notification records  
                'alert_events',        # Delete event records
                'photo_analysis_results', # Delete photo analysis
                'photo_metadata',      # Delete photo metadata
                'media_files',         # Delete media file records
                'comments',            # Delete comments
                'follows'              # Delete follows last
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
        if username.lower() == 'mufon':
            count_cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE source = 'mufon';" """
        else:
            count_cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE reporter_id = '{device_id}';" """
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
    if len(sys.argv) != 2:
        print("Usage: python3 delete_user_beeps.py <username>")
        sys.exit(1)
    
    username = sys.argv[1]
    print(f"Deleting all beeps for username: {username}")
    delete_beeps(username)