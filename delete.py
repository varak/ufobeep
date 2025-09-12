#!/usr/bin/env python3
"""
Comprehensive delete script for UFOBeep
Usage: python3 delete.py <target>

Examples:
  python3 delete.py "dark.idea.8245"           # Delete by username
  python3 delete.py "mufon"                    # Delete all MUFON records
  python3 delete.py "fdge6"                    # Delete by short URL
  python3 delete.py "ufobeep.com/fdge6"       # Delete by full URL

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

def delete_beeps(target):
    # Extract short URL from full URL if provided
    if 'ufobeep.com/' in target:
        target = target.split('/')[-1]
    
    if target.lower() == 'mufon':
        print("Deleting ALL MUFON beeps...")
        # Get all MUFON sighting IDs
        cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM sightings WHERE source = 'mufon';" """
    elif len(target) == 5 and target.isalnum():
        # Looks like a short URL (5 chars, alphanumeric)
        print(f"Deleting beep by short URL: {target}")
        cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM sightings WHERE short_url = '{target}';" """
    else:
        # Assume it's a username
        print(f"Looking up device ID for username: {target}")
        
        # First, find the user ID for this username from users table
        lookup_cmd = f"""sudo -u postgres psql -d ufobeep_db -t -c "SELECT id FROM users WHERE username = '{target}';" """
        
        try:
            lookup_result = subprocess.run(lookup_cmd, shell=True, capture_output=True, text=True)
            device_ids = [line.strip() for line in lookup_result.stdout.strip().split('\n') if line.strip()]
            
            if not device_ids:
                print(f"No device ID found for username: {target}")
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
        print("Usage: python3 delete.py <target>")
        print("Target can be: username, 'mufon', short URL, or full ufobeep.com URL")
        sys.exit(1)
    
    target = sys.argv[1]
    print(f"Deleting beeps for target: {target}")
    delete_beeps(target)