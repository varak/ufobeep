#!/usr/bin/env python3
"""
Comprehensive delete script for UFOBeep

IMPORTANT: This script MUST be run on the production server where PostgreSQL is installed.
It will NOT work on local development machines without PostgreSQL access.

Production Usage:
  ssh -p 322 ufobeep@ufobeep.com
  cd /home/ufobeep/ufobeep
  python3 delete.py <target>

Or remotely:
  ssh -p 322 ufobeep@ufobeep.com "cd /home/ufobeep/ufobeep && python3 delete.py '<target>'"

Examples:
  python3 delete.py "dark.idea.8245"           # Delete by username
  python3 delete.py "mufon"                    # Delete all MUFON records
  python3 delete.py "fdge6"                    # Delete by short URL
  python3 delete.py "ufobeep.com/fdge6"       # Delete by full URL

Main test users to clean up:
  python3 delete.py "dark.idea.8245"           # Test user 1
  python3 delete.py "enigmatic.entity.2741"    # Test user 2
  python3 delete.py "instant.storm.2516"       # Test user 3

This script safely deletes in proper cascade order to prevent orphaned data:
1. All comments made by the user (anywhere on platform)
2. Media files and metadata for each sighting
3. Related data (alerts, follows, analysis)
4. Sighting records themselves

Database Authentication:
- Uses environment PGPASSWORD or .pgpass file
- Follows security guidelines from docs/SECRETS.md
- No hardcoded credentials in script
"""

import subprocess
import sys
import os

def delete_beeps(target):
    # Extract short URL from full URL if provided
    if 'ufobeep.com/' in target:
        target = target.split('/')[-1]

    if target.lower() == 'mufon':
        print("Deleting ALL MUFON beeps...")
        # Get all MUFON sighting IDs
        sighting_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT id FROM sightings WHERE source = 'mufon';" """
        device_id = None
    elif len(target) == 5 and target.isalnum():
        # Looks like a short URL (5 chars, alphanumeric)
        print(f"Deleting beep by short URL: {target}")
        sighting_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT id FROM sightings WHERE short_url = '{target}';" """
        device_id = None
    else:
        # Username - get user ID and sighting IDs
        print(f"Looking up records for username: {target}")

        # First get user ID
        user_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT id FROM users WHERE username = '{target}';" """
        result = subprocess.run(user_cmd, shell=True, capture_output=True, text=True)
        device_id = result.stdout.strip() if result.stdout.strip() else None

        if device_id:
            print(f"Found user ID: {device_id}")
            sighting_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT id FROM sightings WHERE reporter_id = '{device_id}';" """
        else:
            print("No user found in users table, trying reporter_name...")
            sighting_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT id FROM sightings WHERE reporter_name = '{target}';" """

    # Get sighting IDs
    result = subprocess.run(sighting_cmd, shell=True, capture_output=True, text=True)
    sighting_ids = [line.strip() for line in result.stdout.strip().split('\n') if line.strip()]

    if not sighting_ids:
        print("No sightings found for this target")
        return

    print(f"Found {len(sighting_ids)} sightings to delete")

    try:
        # STEP 1: Delete ALL comments made by this user (anywhere on platform)
        if device_id:
            print(f"\nSTEP 1: Deleting all comments made by user {device_id}...")
            comment_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -c "DELETE FROM comments WHERE user_id = '{device_id}';" """
            subprocess.run(comment_cmd, shell=True, capture_output=True)
            print("  ✅ Deleted all user comments")
        else:
            print("\nSTEP 1: No user ID found, skipping user comment deletion")

        # STEP 2: Delete media and related data for each sighting
        print(f"\nSTEP 2: Deleting media and related data...")
        for sighting_id in sighting_ids:
            print(f"  Processing sighting {sighting_id}...")

            # Delete media-related tables first
            media_tables = [
                'photo_analysis_results',
                'photo_metadata',
                'media_files'
            ]

            for table in media_tables:
                delete_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -c "DELETE FROM {table} WHERE sighting_id = '{sighting_id}';" """
                subprocess.run(delete_cmd, shell=True, capture_output=True)
                print(f"    Cleaned {table}")

        # STEP 3: Delete remaining related data and sightings
        print(f"\nSTEP 3: Deleting remaining data and sightings...")
        for sighting_id in sighting_ids:
            print(f"  Processing sighting {sighting_id}...")

            # Delete remaining related tables
            other_tables = [
                'alert_deliveries',
                'alert_notifications',
                'alert_events',
                'comments',  # Comments ON this sighting (user's own comments already deleted)
                'follows'
            ]

            for table in other_tables:
                delete_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -c "DELETE FROM {table} WHERE sighting_id = '{sighting_id}';" """
                subprocess.run(delete_cmd, shell=True, capture_output=True)
                print(f"    Cleaned {table}")

            # Finally delete the sighting itself
            delete_sighting = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -c "DELETE FROM sightings WHERE id = '{sighting_id}';" """
            subprocess.run(delete_sighting, shell=True, capture_output=True)
            print(f"    ✅ Deleted sighting record")

        # Final verification
        if target.lower() == 'mufon':
            count_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE source = 'mufon';" """
        elif device_id:
            count_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE reporter_id = '{device_id}';" """
        else:
            count_cmd = f"""psql -h localhost -U ufobeep_user -d ufobeep_db -t -c "SELECT COUNT(*) FROM sightings WHERE reporter_name = '{target}';" """

        result = subprocess.run(count_cmd, shell=True, capture_output=True, text=True)
        remaining = int(result.stdout.strip()) if result.stdout.strip() else 0

        if remaining == 0:
            print(f"\n✅ Successfully deleted all {len(sighting_ids)} records for {target}")
        else:
            print(f"\n⚠️ {remaining} records still remain for {target}")

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