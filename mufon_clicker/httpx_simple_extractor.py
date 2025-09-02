#!/usr/bin/env python3
"""
Simple MUFON extractor using direct form submission and HTML parsing
No wasted JSON API calls - goes straight to what works
"""
import httpx
import json
import time
import re
from datetime import datetime
from pathlib import Path

def load_authenticated_cookies():
    """Load cookies from storage_state.json"""
    storage_state_path = Path("mufon_artifacts/storage_state.json")
    if not storage_state_path.exists():
        raise Exception("No storage_state.json found - need to authenticate first")
    
    with open(storage_state_path) as f:
        storage_data = json.load(f)
    
    cookies = {}
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']
    
    return cookies

def ensure_authenticated(client, cookies):
    """Make sure we're authenticated, auto-login if needed"""
    # Check if we need to authenticate
    test_url = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19"
    response = client.get(test_url)
    
    if "signIn" in str(response.url) or "login" in response.text.lower():
        print("🔐 Need to login - attempting automatic login...")
        
        # Get login page
        login_response = client.get("https://mufon.app.neoncrm.com/np/signIn.do")
        
        # Submit login form (using correct field names)
        login_data = {
            'loginName': 'varak',
            'loginPassword': 'ufobeep123pass'
        }
        
        login_result = client.post("https://mufon.app.neoncrm.com/np/signIn.do", data=login_data)
        
        if "dashboard" in login_result.text.lower() or "welcome" in login_result.text.lower():
            print("✅ Successfully logged in")
            
            # Save new cookies
            new_cookies = {}
            for cookie in client.cookies.jar:
                new_cookies[cookie.name] = cookie.value
                
            # Update storage_state.json with new cookies
            storage_path = Path("mufon_artifacts/storage_state.json")
            if storage_path.exists():
                with open(storage_path, 'r') as f:
                    storage_data = json.load(f)
                
                # Update cookies in storage
                for i, cookie_data in enumerate(storage_data.get('cookies', [])):
                    if cookie_data['name'] in new_cookies:
                        storage_data['cookies'][i]['value'] = new_cookies[cookie_data['name']]
                
                with open(storage_path, 'w') as f:
                    json.dump(storage_data, f, indent=2)
                    
                print("💾 Updated stored cookies")
            
            return True
        else:
            raise Exception("Login failed - check credentials")
    
    print("✅ Already authenticated")
    return True

def search_mufon(date_str, cookies):
    """Search MUFON using direct form submission with authentication check"""
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
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Referer': 'https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&'
    }
    
    form_data = {
        'event_start_month': str(month - 1),  # 0-based
        'event_start_day': str(day - 1),      # 0-based  
        'event_start_year': year,
        'event_end_month': str(month - 1),
        'event_end_day': str(day - 1),
        'event_end_year': year,
        'submit': 'Submit',
        'pageId': '19'
    }
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=60.0, follow_redirects=True) as client:
        print("🔍 Submitting search form...")
        response = client.post('https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do', data=form_data)
        
        if response.status_code == 200:
            # Check if we got redirected to login again
            if "signIn" in str(response.url):
                raise Exception("Lost authentication during search")
                
            print(f"✅ Got response from {response.url}")
            
            # Save response for debugging
            with open('debug_search_response.html', 'w') as f:
                f.write(response.text)
            print("💾 Saved response for debugging")
            
            cases = parse_html_response(response.text)
            return cases
        else:
            raise Exception(f"Search failed: HTTP {response.status_code}")

def parse_html_response(html_content):
    """Parse MUFON HTML response and extract case data"""
    cases = []
    
    # Find all tables in response
    tables = re.findall(r'<table[^>]*>(.*?)</table>', html_content, re.DOTALL | re.IGNORECASE)
    
    for table in tables:
        rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table, re.DOTALL | re.IGNORECASE)
        if len(rows) < 2:  # Need header + data
            continue
            
        print(f"📋 Processing table with {len(rows)} rows...")
        
        # Skip header row, process data rows
        for row in rows[1:]:
            cells = re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', row, re.DOTALL | re.IGNORECASE)
            if len(cells) < 2:  # Need at least case number + something
                continue
                
            # Clean cell contents
            clean_cells = []
            for cell in cells:
                clean_text = re.sub(r'<[^>]+>', ' ', cell).strip()
                clean_text = re.sub(r'\s+', ' ', clean_text)
                clean_cells.append(clean_text)
            
            # Extract case info
            case_data = extract_case_from_cells(clean_cells)
            if case_data:
                cases.append(case_data)
                print(f"   ✅ Found case #{case_data['case_number']}")
    
    return cases

def extract_case_from_cells(cells):
    """Extract case information from table cells"""
    case = {
        'case_number': None,
        'date_time': None,
        'location': None,
        'description': None,
        'long_description': None,
        'media_files': [],
        'detail_links': []
    }
    
    for cell in cells:
        if not cell or len(cell.strip()) < 2:
            continue
            
        cell = cell.strip()
        
        # Case number: 6-digit number (MUFON cases)
        if re.match(r'^\d{5,6}$', cell):
            case['case_number'] = cell
            
        # Date: various formats
        elif re.search(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}|\d{1,2}[-/]\d{1,2}[-/]\d{4}', cell):
            if not case['date_time']:  # Take first date found
                case['date_time'] = cell
                
        # Location: contains location indicators
        elif any(indicator in cell.lower() for indicator in [
            ', ', ' county', ' city', ' state', ' st ', ' ave', ' road', ' drive',
            ' alaska', ' arizona', ' california', ' texas', ' florida', ' missouri'
        ]):
            if not case['location'] and len(cell) > 5:
                case['location'] = cell
                
        # Description: longer text
        elif len(cell) > 15 and not case['description']:
            case['description'] = cell
    
    # Only return cases with valid case numbers
    return case if case['case_number'] else None

def get_case_details(case_number, cookies):
    """Try to get detailed description for a case"""
    # This would require finding the case detail page
    # For now, return None - we'll use what we have from the table
    return None

def discover_media_files(case_number, cookies):
    """Find media files for a case"""
    media_files = []
    media_dir = Path("mufon_media")
    media_dir.mkdir(exist_ok=True)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
    }
    
    extensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi']
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0) as client:
        for i in range(1, 4):  # Try up to 3 files per case
            for ext in extensions:
                # Try common filename patterns
                filenames = [
                    f"IMG{i:04d}.{ext}",
                    f"file{i}.{ext}",
                    f"image{i}.{ext}",
                    f"video{i}.{ext}"
                ]
                
                for filename in filenames:
                    url = f"https://mufoncms.com/cgi-bin/ffplay.pl?file={case_number}_submitter_file{i}__{filename}"
                    
                    try:
                        response = client.get(url, timeout=10)
                        if response.status_code == 200 and len(response.content) > 1000:
                            # Valid media file
                            local_path = media_dir / f"{case_number}_{i}_{filename}"
                            with open(local_path, 'wb') as f:
                                f.write(response.content)
                            
                            media_files.append({
                                "filename": filename,
                                "url": url,
                                "type": "image" if ext in ['jpg', 'jpeg', 'png', 'gif'] else "video",
                                "local_path": str(local_path)
                            })
                            
                            print(f"   📎 Downloaded {filename} ({len(response.content)} bytes)")
                            break
                            
                    except Exception:
                        continue
                        
            time.sleep(0.2)
    
    return media_files

def extract_mufon_simple(date_str):
    """Main extraction function - simple and direct"""
    try:
        # Load cookies
        cookies = load_authenticated_cookies()
        print(f"🔑 Loaded {len(cookies)} authentication cookies")
        
        # Search for cases
        cases = search_mufon(date_str, cookies)
        
        if not cases:
            print("⚠️  No cases found")
            return None
        
        print(f"📊 Found {len(cases)} cases")
        
        # Get media files for each case
        for case in cases:
            if case.get('case_number'):
                print(f"🎬 Finding media for case {case['case_number']}")
                media_files = discover_media_files(case['case_number'], cookies)
                case['media_files'] = media_files
        
        # Save results
        filename = f"mufon_simple_{date_str.replace('-', '_')}.json"
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "extraction_method": "httpx_simple_html",
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"🎉 Extracted {len(cases)} cases!")
        print(f"💾 Saved to {filename}")
        
        # Show sample
        if cases:
            print(f"\n📋 Sample case:")
            sample = cases[0]
            for key, value in sample.items():
                if key != 'media_files':
                    display_value = str(value)[:100] + "..." if len(str(value)) > 100 else str(value)
                    print(f"  {key}: {display_value}")
                else:
                    print(f"  {key}: {len(value)} files")
        
        return filename
        
    except Exception as e:
        print(f"❌ Error: {e}")
        import traceback
        traceback.print_exc()
        return None

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python httpx_simple_extractor.py YYYY-MM-DD")
        print("Example: python httpx_simple_extractor.py 2024-09-06")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    extract_mufon_simple(date_arg)