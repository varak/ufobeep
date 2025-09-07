#!/usr/bin/env python3
"""
Fix missing media for already uploaded MUFON cases
"""

import json
import requests
from pathlib import Path

# Alert IDs that need media
cases_needing_media = [
    ("0656695e-a7c6-4553-8111-a0998a4bcbc3", "140889", ["GreenObject1.jpg", "GreenObject2.jpg", "GreenObject3.jpg"]),
    ("a189ad6a-844d-4ccb-b3dc-ad4a3eacedd4", "140887", ["IMG0936.mov"]),
    ("e415b5cd-f213-49c9-96ff-fa354a56d149", "140886", ["IMG8493.mov"]),
    ("ac1942e7-dbd8-4c49-ac5b-b34c23eb383e", "140882", ["IMG01181.MOV"])
]

# Load auth cookies
storage_state_path = Path('mufon_artifacts/storage_state.json')
cookies = {}
with open(storage_state_path) as f:
    storage_data = json.load(f)
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']

for alert_id, case_id, media_files in cases_needing_media:
    print(f"\n📤 Processing alert {alert_id} (Case #{case_id})")
    
    for i, filename in enumerate(media_files, 1):
        try:
            # Download with auth
            cgi_url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file={case_id}_submitter_file{i}__{filename}"
            print(f"   📥 Downloading {filename}...")
            
            response = requests.get(cgi_url, cookies=cookies, timeout=30)
            if response.status_code != 200:
                print(f"   ❌ Download failed: HTTP {response.status_code}")
                continue
            
            if len(response.content) < 1000:
                print(f"   ❌ Content too small: {len(response.content)} bytes")
                continue
            
            # Upload to alert
            files = {'files': (filename, response.content)}
            data = {'source': 'mufon_import'}
            
            upload_response = requests.post(
                f'https://ufobeep.com/api/alerts/{alert_id}/media',
                files=files,
                data=data,
                timeout=30
            )
            
            if upload_response.status_code == 200:
                print(f"   ✅ Uploaded {filename} ({len(response.content)} bytes)")
            else:
                print(f"   ❌ Upload failed: HTTP {upload_response.status_code} - {upload_response.text[:100]}")
                
        except Exception as e:
            print(f"   ❌ Error with {filename}: {e}")

print(f"\n🏁 Media fix complete!")