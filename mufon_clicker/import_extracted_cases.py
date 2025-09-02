#!/usr/bin/env python3
"""
Import extracted MUFON cases with proper media downloads using CGI format
"""
import json
import requests
import sys
from pathlib import Path
import uuid
import mimetypes

def download_media_file(filename):
    """Download media file using working CGI format"""
    try:
        media_dir = Path("/home/mike/D/ufobeep/api/media")
        media_dir.mkdir(exist_ok=True)
        
        # Use working CGI URL format
        media_url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file={filename}"
        
        file_ext = Path(filename).suffix
        unique_filename = f"{uuid.uuid4()}{file_ext}"
        file_path = media_dir / unique_filename
        
        print(f"   📥 Downloading {filename} from CGI...")
        response = requests.get(media_url, timeout=30)
        response.raise_for_status()
        
        with open(file_path, 'wb') as f:
            f.write(response.content)
        
        print(f"   ✅ Saved as {unique_filename} ({len(response.content)} bytes)")
        return {
            'original_filename': filename,
            'stored_filename': unique_filename,
            'file_path': str(file_path),
            'file_size': len(response.content),
            'mime_type': mimetypes.guess_type(filename)[0]
        }
        
    except Exception as e:
        print(f"   ❌ Failed to download {filename}: {e}")
        return None

def create_sighting(case_data, media_files):
    """Create sighting via /sightings/create endpoint"""
    try:
        sighting_payload = {
            'external_id': f"mufon_{case_data.get('case_number', '')}",
            'source': 'mufon',
            'title': f"MUFON Case #{case_data.get('case_number', '')}",
            'description': case_data.get('long_description', ''),
            'location': case_data.get('location', ''),
            'sighted_at': case_data.get('date_time', '').replace('\n', ' '),
            'reported_at': case_data.get('date_time', ''),
            'status': 'verified',
            'visibility': 'public',
            'media_files': media_files
        }
        
        print(f"   📤 Creating sighting: {sighting_payload['title']}")
        
        response = requests.post(
            'http://localhost:8000/sightings/create',
            json=sighting_payload,
            timeout=30
        )
        
        if response.status_code == 201:
            sighting_data = response.json()
            print(f"   ✅ Created sighting ID: {sighting_data.get('id')}")
            return sighting_data
        else:
            print(f"   ❌ API error: {response.status_code} - {response.text}")
            return None
            
    except Exception as e:
        print(f"   ❌ Failed to create sighting: {e}")
        return None

def main():
    if len(sys.argv) != 2:
        print("Usage: python import_extracted_cases.py <json_file>")
        sys.exit(1)
    
    json_file = sys.argv[1]
    
    with open(json_file) as f:
        data = json.load(f)
    
    cases = data.get('cases', [])
    print(f"🚀 Importing {len(cases)} MUFON cases...")
    
    imported_count = 0
    total_media_downloaded = 0
    
    for case in cases:
        case_id = case.get('case_number', 'unknown')
        print(f"\n=== Processing Case #{case_id} ===")
        
        # Download media files
        downloaded_media = []
        for media in case.get('media_files', []):
            filename = media.get('filename')
            if filename:
                downloaded = download_media_file(filename)
                if downloaded:
                    downloaded_media.append(downloaded)
                    total_media_downloaded += 1
        
        # Create sighting
        result = create_sighting(case, downloaded_media)
        if result:
            imported_count += 1
            if downloaded_media:
                print(f"   📎 Included {len(downloaded_media)} media files")
    
    print(f"\n🏁 Import complete!")
    print(f"✅ Successfully imported {imported_count}/{len(cases)} cases")
    print(f"📥 Downloaded {total_media_downloaded} media files")

if __name__ == "__main__":
    main()