#!/usr/bin/env python3
"""
Import MUFON cases into UFOBeep database with proper media downloading
"""
import json
import requests
import subprocess
from datetime import datetime
from pathlib import Path
import uuid
import mimetypes

def download_media_file(url, filename):
    """Download media file and store it like the alert system does"""
    try:
        # Create media directory if it doesn't exist
        media_dir = Path("/home/mike/D/ufobeep/api/media")
        media_dir.mkdir(exist_ok=True)
        
        # Generate unique filename to avoid conflicts
        file_ext = Path(filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = media_dir / unique_filename
        
        print(f"📥 Downloading {filename} from {url}")
        response = requests.get(url, timeout=30)
        response.raise_for_status()
        
        # Write the file
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        print(f"✅ Saved as {unique_filename}")
        return {
            'original_filename': filename,
            'stored_filename': unique_filename,
            'file_path': str(file_path),
            'file_size': len(response.content),
            'mime_type': mimetypes.guess_type(filename)[0]
        }
        
    except Exception as e:
        print(f"❌ Failed to download {filename}: {e}")
        return None

def insert_sighting_via_api(case_data, media_files):
    """Insert sighting via UFOBeep API like a real alert"""
    try:
        # Prepare sighting data
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
            'media_files': media_files
        }
        
        print(f"📤 Creating sighting via API: {sighting_payload['title'][:50]}...")
        
        # Call local UFOBeep API endpoint
        response = requests.post(
            'http://localhost:8000/sightings/create',
            json=sighting_payload,
            timeout=30
        )
        
        if response.status_code == 201:
            sighting_data = response.json()
            print(f"✅ Created sighting ID: {sighting_data.get('id')}")
            return sighting_data
        else:
            print(f"❌ API error: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"❌ Failed to create sighting via API: {e}")
        return None

def import_mufon_cases():
    """Import MUFON cases with proper media downloading like alert system"""
    
    # Load extracted MUFON data
    data_file = Path("mufon_working_results.json")
    if not data_file.exists():
        print("❌ No MUFON data file found")
        return
    
    with open(data_file) as f:
        mufon_data = json.load(f)
    
    print(f"📊 Processing {mufon_data['total_cases']} MUFON cases...")
    
    imported_count = 0
    total_media_downloaded = 0
    
    for case in mufon_data['cases']:
        try:
            print(f"\n--- Processing Case #{case.get('Case_Number')} ---")
            print(f"Description: {case.get('Short_Description', '')}")
            print(f"Location: {case.get('Location', '')}")
            print(f"Event Date: {case.get('DateTime_Event', '')}")
            
            # Download media files first (like alert system does)
            downloaded_media = []
            media_files = case.get('Attachments_media', [])
            
            for media in media_files:
                downloaded = download_media_file(media['url'], media['filename'])
                if downloaded:
                    downloaded_media.append(downloaded)
                    total_media_downloaded += 1
            
            # Insert sighting with media via API (like alert flow)
            sighting = insert_sighting_via_api(case, downloaded_media)
            
            if sighting:
                imported_count += 1
                if downloaded_media:
                    print(f"   📎 Downloaded and stored {len(downloaded_media)} media files")
            
        except Exception as e:
            print(f"❌ Failed to process case #{case.get('Case_Number', 'unknown')}: {e}")
    
    print(f"\n🎉 Successfully imported {imported_count} MUFON cases!")
    print(f"📥 Downloaded {total_media_downloaded} media files")
    print(f"💾 Media stored in: /home/mike/D/ufobeep/api/media/")

if __name__ == "__main__":
    import_mufon_cases()