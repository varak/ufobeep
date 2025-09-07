#!/usr/bin/env python3
"""
Upload large video file with compression
"""

import json
import requests
import tempfile
import subprocess
from pathlib import Path

# Load auth cookies
storage_state_path = Path('mufon_artifacts/storage_state.json')
cookies = {}
with open(storage_state_path) as f:
    storage_data = json.load(f)
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']

# Download the large file
alert_id = "ac1942e7-dbd8-4c49-ac5b-b34c23eb383e"
case_id = "140882"
filename = "IMG01181.MOV"

cgi_url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file={case_id}_submitter_file1__{filename}"
print(f"📥 Downloading {filename} ({85.8} MB)...")

response = requests.get(cgi_url, cookies=cookies, timeout=60)
if response.status_code != 200:
    print(f"❌ Download failed: {response.status_code}")
    exit(1)

print(f"✅ Downloaded {len(response.content)} bytes")

# Save to temp file and compress with ffmpeg
with tempfile.NamedTemporaryFile(suffix='.mov', delete=False) as temp_input:
    temp_input.write(response.content)
    temp_input_path = temp_input.name

with tempfile.NamedTemporaryFile(suffix='.mp4', delete=False) as temp_output:
    temp_output_path = temp_output.name

try:
    print("🗜️ Compressing video...")
    # Compress video to reduce size
    cmd = [
        'ffmpeg', '-i', temp_input_path,
        '-vcodec', 'libx264', '-crf', '28',
        '-preset', 'fast', '-y',
        temp_output_path
    ]
    
    result = subprocess.run(cmd, capture_output=True, text=True, timeout=120)
    
    if result.returncode == 0:
        # Check compressed file size
        compressed_size = Path(temp_output_path).stat().st_size
        print(f"✅ Compressed to {compressed_size} bytes ({compressed_size/1024/1024:.1f} MB)")
        
        # Upload compressed version
        with open(temp_output_path, 'rb') as f:
            files = {'files': (filename.replace('.MOV', '.mp4'), f.read())}
            data = {'source': 'mufon_import'}
            
            upload_response = requests.post(
                f'https://ufobeep.com/api/alerts/{alert_id}/media',
                files=files,
                data=data,
                timeout=60
            )
            
            if upload_response.status_code == 200:
                print(f"✅ Uploaded compressed {filename}")
            else:
                print(f"❌ Upload failed: {upload_response.status_code} - {upload_response.text[:200]}")
    else:
        print(f"❌ Compression failed: {result.stderr}")
        
        # Try uploading original file anyway
        print("🔄 Trying original file upload...")
        files = {'files': (filename, response.content)}
        data = {'source': 'mufon_import'}
        
        upload_response = requests.post(
            f'https://ufobeep.com/api/alerts/{alert_id}/media',
            files=files,
            data=data,
            timeout=60
        )
        
        if upload_response.status_code == 200:
            print(f"✅ Uploaded original {filename}")
        else:
            print(f"❌ Upload failed: {upload_response.status_code} - {upload_response.text[:200]}")

finally:
    # Clean up temp files
    try:
        Path(temp_input_path).unlink()
        Path(temp_output_path).unlink()
    except:
        pass