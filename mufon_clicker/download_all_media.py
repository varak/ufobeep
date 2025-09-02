#!/usr/bin/env python3
"""
Simple script to download all media files from extracted MUFON cases
Uses authenticated session to download all CGI URLs
"""
import json
import requests
import os
from pathlib import Path
from playwright.sync_api import sync_playwright

def download_all_media():
    """Download all media files from existing MUFON JSON files"""
    
    # Get all JSON files with MUFON cases
    json_files = list(Path('.').glob('mufon_cases_*.json'))
    if not json_files:
        print("❌ No MUFON case files found")
        return
    
    print(f"📁 Found {len(json_files)} MUFON case files")
    
    # Create media directory
    media_dir = Path("mufon_media")
    media_dir.mkdir(exist_ok=True)
    
    # Load authenticated session from storage state
    storage_state_path = Path("mufon_artifacts/storage_state.json")
    if not storage_state_path.exists():
        print("❌ No authenticated session found")
        return
    
    # Use playwright to get authenticated requests session
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=str(storage_state_path))
        page = context.new_page()
        
        total_downloaded = 0
        
        # Process each JSON file
        for json_file in json_files:
            print(f"\n📄 Processing {json_file.name}...")
            
            try:
                with open(json_file) as f:
                    data = json.load(f)
                
                cases = data.get('cases', [])
                print(f"   📊 Found {len(cases)} cases")
                
                # Download media for each case
                for case in cases:
                    case_num = case.get('case_number', 'unknown')
                    media_files = case.get('media_files', [])
                    
                    if not media_files:
                        continue
                    
                    print(f"   📦 Case {case_num}: {len(media_files)} media files")
                    
                    for media in media_files:
                        filename = media.get('filename', '')
                        url = media.get('url', '')
                        
                        if not filename or not url:
                            continue
                        
                        # Skip if already downloaded
                        local_path = media_dir / f"{case_num}_{filename}"
                        if local_path.exists():
                            print(f"      ⏭️ {filename} (already exists)")
                            continue
                        
                        try:
                            print(f"      🔽 Downloading {filename}...")
                            
                            # Use authenticated page context for download
                            response = page.request.get(url, timeout=30000)  # 30 second timeout
                            
                            if response.status == 200:
                                content = response.body()
                                if len(content) > 1000:  # Valid file size
                                    with open(local_path, 'wb') as f:
                                        f.write(content)
                                    print(f"      ✅ Downloaded {filename} ({len(content)} bytes)")
                                    total_downloaded += 1
                                else:
                                    print(f"      ❌ File too small: {len(content)} bytes")
                            else:
                                print(f"      ❌ HTTP {response.status}")
                                
                        except Exception as e:
                            print(f"      ❌ Download error: {e}")
            
            except Exception as e:
                print(f"   ❌ Error processing {json_file.name}: {e}")
        
        browser.close()
        
    print(f"\n🎉 Downloaded {total_downloaded} media files total!")

if __name__ == "__main__":
    download_all_media()