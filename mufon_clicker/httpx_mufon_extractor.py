#!/usr/bin/env python3
"""
MUFON extraction using httpx with authenticated session
Fast, reliable, no browser overhead
"""
import httpx
import json
import time
from datetime import datetime
from pathlib import Path
import re

def load_authenticated_cookies():
    """Extract cookies from storage_state.json for httpx"""
    storage_state_path = Path("mufon_artifacts/storage_state.json")
    if not storage_state_path.exists():
        raise Exception("No storage_state.json found - need to authenticate first")
    
    with open(storage_state_path) as f:
        storage_data = json.load(f)
    
    cookies = {}
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']
    
    return cookies

def search_mufon_date(date_str, cookies):
    """Search MUFON for specific date using httpx"""
    print(f"📅 Searching MUFON for {date_str}...")
    
    # Parse date
    try:
        date_obj = datetime.strptime(date_str, "%Y-%m-%d")
        year = str(date_obj.year)
        month = date_obj.month
        day = date_obj.day
    except ValueError:
        raise Exception("Invalid date format. Use YYYY-MM-DD")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': 'https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&'
    }
    
    # Search form data
    form_data = {
        'event_start_month': str(month - 1),  # 0-based
        'event_start_day': str(day - 1),      # 0-based  
        'event_start_year': year,
        'event_end_month': str(month - 1),    # Same date for single day
        'event_end_day': str(day - 1),
        'event_end_year': year,
        'submit': 'Submit',
        'pageId': '19'
    }
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
        # Submit search
        search_url = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do"
        print(f"🔍 Submitting search...")
        
        response = client.post(search_url, data=form_data)
        if response.status_code != 200:
            raise Exception(f"Search failed: HTTP {response.status_code}")
        
        print(f"✅ Search submitted, parsing results...")
        
        # Extract case data from HTML table
        cases = []
        html_content = response.text
        
        # Simple regex to extract table rows (crude but works)
        # Look for patterns like case numbers, dates, descriptions
        case_pattern = r'<tr[^>]*>.*?</tr>'
        matches = re.findall(case_pattern, html_content, re.DOTALL)
        
        for i, match in enumerate(matches):
            if 'case' in match.lower() or any(char.isdigit() for char in match):
                # Extract basic info from table cells
                cell_pattern = r'<td[^>]*>(.*?)</td>'
                cells = re.findall(cell_pattern, match, re.DOTALL)
                
                if len(cells) >= 4:
                    # Clean HTML tags from cells
                    clean_cells = []
                    for cell in cells:
                        clean_text = re.sub(r'<[^>]+>', '', cell).strip()
                        clean_cells.append(clean_text)
                    
                    if clean_cells[0] and any(char.isdigit() for char in clean_cells[0]):
                        case_data = {
                            "case_number": clean_cells[0],
                            "date_time": clean_cells[1] if len(clean_cells) > 1 else "",
                            "short_description": clean_cells[2] if len(clean_cells) > 2 else "",
                            "location": clean_cells[3] if len(clean_cells) > 3 else "",
                            "media_files": [],
                            "long_description": ""  # Will get separately
                        }
                        cases.append(case_data)
        
        print(f"📊 Found {len(cases)} cases")
        return cases

def download_media_files(cases, cookies):
    """Download media files for all cases"""
    media_dir = Path("mufon_media")
    media_dir.mkdir(exist_ok=True)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
    }
    
    downloaded_count = 0
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0) as client:
        for case in cases:
            case_num = case['case_number']
            
            # Try common media file patterns
            media_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi']
            
            for ext in media_extensions:
                for i in range(1, 6):  # Try up to 5 attachments per case
                    filename = f"file{i}{ext}"
                    url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file={case_num}_submitter_file{i}__{filename}"
                    
                    try:
                        response = client.get(url)
                        if response.status_code == 200 and len(response.content) > 1000:
                            local_path = media_dir / f"{case_num}_{filename}"
                            with open(local_path, 'wb') as f:
                                f.write(response.content)
                            
                            print(f"   ✅ Downloaded {filename} ({len(response.content)} bytes)")
                            
                            case['media_files'].append({
                                "filename": filename,
                                "url": url,
                                "type": "image" if ext in ['.jpg', '.jpeg', '.png', '.gif'] else "video",
                                "local_path": str(local_path)
                            })
                            downloaded_count += 1
                            
                    except Exception as e:
                        continue  # Try next file
            
            time.sleep(0.5)  # Be respectful
    
    print(f"📎 Downloaded {downloaded_count} media files")
    return cases

def extract_mufon_httpx(date_str):
    """Main extraction function using httpx"""
    try:
        # Load authenticated cookies
        cookies = load_authenticated_cookies()
        print(f"🔑 Loaded {len(cookies)} authentication cookies")
        
        # Search for cases
        cases = search_mufon_date(date_str, cookies)
        
        # Download media files
        cases = download_media_files(cases, cookies)
        
        # Save results
        filename = f"mufon_httpx_{date_str.replace('-', '_')}.json"
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "extraction_method": "httpx",
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"🎉 Extracted {len(cases)} cases with httpx!")
        print(f"💾 Saved to {filename}")
        
        return filename
        
    except Exception as e:
        print(f"❌ Error: {e}")
        return None

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python httpx_mufon_extractor.py YYYY-MM-DD")
        print("Example: python httpx_mufon_extractor.py 2024-09-05")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    extract_mufon_httpx(date_arg)