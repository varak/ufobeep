#!/usr/bin/env python3
"""
Simple httpx media downloader - just download the URLs we already have
"""
import httpx
import json
from pathlib import Path

# Load cookies from storage_state.json
with open("mufon_artifacts/storage_state.json") as f:
    storage_data = json.load(f)

cookies = {}
for cookie in storage_data.get('cookies', []):
    cookies[cookie['name']] = cookie['value']

print(f"🔑 {len(cookies)} cookies loaded")

# Headers
headers = {
    'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
}

# Create media dir
Path("httpx_media").mkdir(exist_ok=True)

# Load September 4th data (has media URLs)
with open("mufon_cases_2024_09_04.json") as f:
    data = json.load(f)

with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
    for case in data['cases']:
        case_num = case.get('case_number')
        for media in case.get('media_files', []):
            url = media.get('url')
            filename = media.get('filename')
            
            if url and filename:
                print(f"Downloading {filename}...")
                try:
                    response = client.get(url)
                    if response.status_code == 200:
                        with open(f"httpx_media/{case_num}_{filename}", 'wb') as f:
                            f.write(response.content)
                        print(f"✅ {len(response.content)} bytes")
                    else:
                        print(f"❌ HTTP {response.status_code}")
                except Exception as e:
                    print(f"❌ {e}")

print("Done!")