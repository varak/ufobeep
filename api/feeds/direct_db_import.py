#!/usr/bin/env python3
"""
Direct database import of MUFON cases using existing database structure
"""
import json
import subprocess
from pathlib import Path
from datetime import datetime

def import_mufon_cases():
    """Import MUFON cases directly into database"""
    
    # Load extracted MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    print(f"📊 Processing {mufon_data['total_cases']} MUFON cases...")
    
    imported_count = 0
    
    for case in mufon_data['cases']:
        try:
            print(f"\n--- Processing Case #{case.get('Case_Number')} ---")
            
            # Parse location
            location = case.get('Location', '')
            location_name = location.split(',')[0] if ',' in location else location
            
            # Parse event datetime
            event_datetime = case.get('DateTime_Event', '').replace('\n', ' ')
            
            # SQL to insert sighting
            sql = f"""
            INSERT INTO sightings 
            (id, title, description, category, latitude, longitude, location_name, 
             alert_level, witness_count, created_at, source, occurred_at, external_id)
            VALUES 
            (gen_random_uuid(), 
             '{case.get('Short_Description', '').replace("'", "''")}',
             '{case.get('Short_Description', '').replace("'", "''")}',
             'ufo_sighting',
             40.7128, -74.0060, 
             '{location_name.replace("'", "''")}',
             'medium', 1, NOW(),
             'mufon',
             '{event_datetime}',
             'mufon_{case.get('Case_Number', '')}');
            """
            
            # Execute SQL
            result = subprocess.run([
                "psql", "-h", "localhost", "-U", "ufobeep_user", "-d", "ufobeep_db", 
                "-c", sql
            ], capture_output=True, text=True, env={"PGPASSWORD": "ufopostpass"})
            
            if result.returncode == 0:
                print(f"✅ Imported case: {case.get('Short_Description', '')[:50]}")
                imported_count += 1
                
                # Note media files for manual download later
                media_files = case.get('Attachments_media', [])
                if media_files:
                    print(f"   📎 Has {len(media_files)} media files to download")
                    for media in media_files:
                        print(f"      - {media['filename']}: {media['url']}")
                
            else:
                print(f"❌ SQL error: {result.stderr}")
                
        except Exception as e:
            print(f"❌ Failed to process case #{case.get('Case_Number', 'unknown')}: {e}")
    
    print(f"\n🎉 Successfully imported {imported_count} MUFON cases!")

if __name__ == "__main__":
    import_mufon_cases()