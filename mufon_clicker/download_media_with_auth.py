#!/usr/bin/env python3
"""
Download media files using authenticated Playwright session
"""

import json
from pathlib import Path
from playwright.sync_api import sync_playwright

def download_media_with_auth(media_urls, case_id):
    """Download media files using authenticated session"""
    downloaded = []
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state="mufon_artifacts/storage_state.json")
        page = context.new_page()
        
        for i, media_url in enumerate(media_urls, 1):
            try:
                filename = Path(media_url).name
                print(f"📥 Downloading {filename}...")
                
                # Navigate to the media URL
                response = page.goto(media_url, wait_until="domcontentloaded", timeout=30000)
                
                if response and response.status == 200:
                    # Save the file
                    content = page.content()
                    if content and len(content) > 1000:  # Check if we got actual media content
                        file_path = Path(f"media_{case_id}_{i}_{filename}")
                        with open(file_path, 'wb') as f:
                            # For binary content, we need to get the response body
                            page.goto(media_url)
                            content_bytes = response.body()
                            f.write(content_bytes)
                        
                        downloaded.append({
                            'filename': filename,
                            'local_path': str(file_path),
                            'size': len(content_bytes)
                        })
                        print(f"✅ Downloaded {filename} ({len(content_bytes)} bytes)")
                    else:
                        print(f"❌ {filename}: No content received")
                else:
                    print(f"❌ {filename}: HTTP {response.status if response else 'No response'}")
                    
            except Exception as e:
                print(f"❌ Error downloading {filename}: {e}")
        
        browser.close()
    
    return downloaded

if __name__ == "__main__":
    # Test with one media URL
    test_urls = [
        "https://mufoncms.com/cgi-bin/ffplay.pl?file=140889_submitter_file1__GreenObject1.jpg"
    ]
    
    result = download_media_with_auth(test_urls, "140889")
    print(f"Downloaded {len(result)} files")