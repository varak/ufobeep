#!/usr/bin/env python3
"""
Download all MUFON media using httpx with authenticated session
Works with existing JSON files that already have media URLs
"""
import httpx
import json
from pathlib import Path

def load_authenticated_cookies():
    """Extract cookies from storage_state.json for httpx"""
    storage_state_path = Path("mufon_artifacts/storage_state.json")
    if not storage_state_path.exists():
        raise Exception("No storage_state.json found")
    
    with open(storage_state_path) as f:
        storage_data = json.load(f)
    
    cookies = {}
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']
    
    return cookies

def download_all_media_httpx():
    """Download all media files using httpx"""
    
    # Load cookies
    cookies = load_authenticated_cookies()
    print(f"🔑 Loaded {len(cookies)} authentication cookies")
    
    # Find all JSON files
    json_files = list(Path('.').glob('mufon_cases_*.json'))
    if not json_files:
        print("❌ No MUFON case files found")
        return
    
    print(f"📁 Found {len(json_files)} MUFON case files")
    
    # Create media directory
    media_dir = Path("mufon_media_httpx")
    media_dir.mkdir(exist_ok=True)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': '*/*',
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive'
    }
    
    total_downloaded = 0
    total_attempted = 0
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
        
        for json_file in json_files:
            print(f"\n📄 Processing {json_file.name}...")
            
            try:
                with open(json_file) as f:
                    data = json.load(f)
                
                cases = data.get('cases', [])
                print(f"   📊 {len(cases)} cases")
                
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
                        
                        total_attempted += 1
                        local_path = media_dir / f"{case_num}_{filename}"
                        
                        # Skip if already exists
                        if local_path.exists():
                            print(f"      ⏭️ {filename} (exists)")
                            continue
                        
                        try:
                            print(f"      🔽 {filename}...")
                            response = client.get(url)
                            
                            if response.status_code == 200:
                                content = response.content
                                if len(content) > 1000:  # Valid file
                                    with open(local_path, 'wb') as f:
                                        f.write(content)
                                    print(f"      ✅ {len(content)} bytes")
                                    total_downloaded += 1
                                else:
                                    print(f"      ❌ Too small ({len(content)} bytes)")
                            else:
                                print(f"      ❌ HTTP {response.status_code}")
                        
                        except Exception as e:
                            print(f"      ❌ Error: {e}")
            
            except Exception as e:
                print(f"   ❌ Error processing {json_file.name}: {e}")
    
    print(f"\n🎉 Downloaded {total_downloaded}/{total_attempted} media files!")
    print(f"📁 Saved to {media_dir}/")

if __name__ == "__main__":
    download_all_media_httpx()