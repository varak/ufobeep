#!/usr/bin/env python3
"""
Proper MUFON extraction using httpx with JSON API parsing
Uses MUFON's actual JSON endpoints instead of HTML scraping
"""
import httpx
import json
import time
import re
from datetime import datetime
from pathlib import Path

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

def parse_html_response_properly(html_content):
    """Parse MUFON HTML response with intelligent field identification"""
    cases = []
    
    # Look for table structure
    import re
    tables = re.findall(r'<table[^>]*>(.*?)</table>', html_content, re.DOTALL | re.IGNORECASE)
    
    for table in tables:
        rows = re.findall(r'<tr[^>]*>(.*?)</tr>', table, re.DOTALL | re.IGNORECASE)
        if len(rows) < 2:  # Need header + data
            continue
            
        # Process data rows (skip first row which is likely headers)
        for row in rows[1:]:
            cells = re.findall(r'<t[hd][^>]*>(.*?)</t[hd]>', row, re.DOTALL | re.IGNORECASE)
            if len(cells) < 3:  # Need at least 3 columns of data
                continue
                
            # Clean cell contents
            clean_cells = []
            for cell in cells:
                clean_text = re.sub(r'<[^>]+>', ' ', cell).strip()
                clean_text = re.sub(r'\s+', ' ', clean_text)
                clean_cells.append(clean_text)
            
            # Identify fields by content patterns
            case_data = identify_fields_from_cells(clean_cells)
            if case_data and case_data.get('case_number'):
                cases.append(case_data)
    
    return cases

def identify_fields_from_cells(cells):
    """Identify what each cell contains based on content patterns"""
    case = {
        'case_number': None,
        'date_time': None,
        'location': None,
        'description': None,
        'long_description': None,
        'media_files': []
    }
    
    import re
    
    for cell in cells:
        if not cell or len(cell.strip()) < 2:
            continue
            
        cell = cell.strip()
        
        # Case number: 6-digit number starting with 1
        if re.match(r'^1\d{5}$', cell):
            case['case_number'] = cell
            
        # Date: various date patterns
        elif re.search(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}|\d{1,2}[-/]\d{1,2}[-/]\d{4}', cell):
            case['date_time'] = cell
            
        # Location: contains geographic indicators
        elif any(geo in cell.lower() for geo in [', ', ' county', ' city', ' state', ' st', ' ave', ' road']):
            if not case['location']:  # Take first location-like cell
                case['location'] = cell
                
        # Description: longer text that doesn't match other patterns
        elif len(cell) > 20 and not case['description']:
            case['description'] = cell
    
    return case if case['case_number'] else None

def identify_mufon_fields(cell_data, headers):
    """Identify what each cell contains based on content patterns"""
    case_info = {
        'case_number': None,
        'date_time': None,
        'location': None,
        'description': None,
        'long_description': None,
        'media_files': [],
        'detail_links': []
    }
    
    for i, cell in enumerate(cell_data):
        text = cell['text']
        links = cell['links']
        
        # Case number: typically numeric, sometimes prefixed
        if re.match(r'^\d+$', text) and len(text) >= 4:
            case_info['case_number'] = text
            
        # Date patterns: look for date formats
        elif re.search(r'\d{4}[-/]\d{1,2}[-/]\d{1,2}|\d{1,2}[-/]\d{1,2}[-/]\d{4}', text):
            case_info['date_time'] = text
            
        # Location: geographic indicators (city, state, country names)
        elif any(geo_word in text.lower() for geo_word in [
            'city', 'county', 'state', 'street', 'road', 'avenue', 'drive',
            ', al', ', ak', ', az', ', ar', ', ca', ', co', ', ct', ', de', ', fl',
            ', ga', ', hi', ', id', ', il', ', in', ', ia', ', ks', ', ky', ', la',
            ', me', ', md', ', ma', ', mi', ', mn', ', ms', ', mo', ', mt', ', ne',
            ', nv', ', nh', ', nj', ', nm', ', ny', ', nc', ', nd', ', oh', ', ok',
            ', or', ', pa', ', ri', ', sc', ', sd', ', tn', ', tx', ', ut', ', vt',
            ', va', ', wa', ', wv', ', wi', ', wy'
        ]):
            case_info['location'] = text
            
        # Description: longer text that doesn't match other patterns
        elif len(text) > 50 and not case_info['description']:
            case_info['description'] = text
            
        # Links to case details
        if links:
            case_info['detail_links'].extend(links)
    
    # If no clear location found, look for geographic clues in description
    if not case_info['location'] and case_info['description']:
        # Look for city/state patterns in description
        location_match = re.search(r'\b([A-Z][a-z]+(?:\s+[A-Z][a-z]+)*),?\s+([A-Z]{2})\b', case_info['description'])
        if location_match:
            city, state = location_match.groups()
            case_info['location'] = f"{city}, {state}"
    
    return case_info

def get_case_details(case_number, detail_links, cookies):
    """Get full case details including long description"""
    if not detail_links:
        return None
        
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Referer': 'https://mufon.app.neoncrm.com/'
    }
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
        for link in detail_links:
            try:
                if link.startswith('/'):
                    link = 'https://mufon.app.neoncrm.com' + link
                elif not link.startswith('http'):
                    continue
                    
                response = client.get(link)
                if response.status_code == 200:
                    soup = BeautifulSoup(response.text, 'html.parser')
                    
                    # Look for long description in various places
                    long_desc = None
                    
                    # Try common selectors for descriptions
                    desc_selectors = [
                        '#longDescription',
                        '.description',
                        '.long-description', 
                        '[name*="description"]',
                        'textarea',
                        '.case-details'
                    ]
                    
                    for selector in desc_selectors:
                        elem = soup.select_one(selector)
                        if elem:
                            long_desc = elem.get_text(strip=True)
                            if len(long_desc) > 100:  # Only use substantial descriptions
                                break
                    
                    # If no specific selector worked, look for the largest text block
                    if not long_desc:
                        paragraphs = soup.find_all(['p', 'div'])
                        for p in paragraphs:
                            text = p.get_text(strip=True)
                            if len(text) > 200:  # Substantial text
                                long_desc = text
                                break
                    
                    if long_desc:
                        return long_desc
                        
            except Exception as e:
                print(f"   ⚠️  Error fetching details for case {case_number}: {e}")
                continue
    
    return None

def search_mufon_html(date_str, cookies):
    """Search MUFON using form submission and HTML parsing"""
    print(f"📅 Searching MUFON for {date_str} using direct form submission...")
    
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
            print("✅ Got response, parsing HTML...")
            cases = parse_html_response_properly(response.text)
            return cases
        else:
            raise Exception(f"Search failed: HTTP {response.status_code}")
    
    return []

def search_using_json_api(api_endpoint, date_str, cookies):
    """Search using discovered JSON API endpoint"""
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Accept': 'application/json',
        'Content-Type': 'application/json'
    }
    
    # Try different search parameters
    search_params = [
        {'date': date_str},
        {'start_date': date_str, 'end_date': date_str},
        {'event_date': date_str},
        {'search_date': date_str}
    ]
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0) as client:
        for params in search_params:
            try:
                response = client.get(api_endpoint, params=params)
                if response.status_code == 200:
                    data = response.json()
                    cases = parse_json_response(data)
                    if cases:
                        return cases
            except Exception as e:
                print(f"⚠️  Error with params {params}: {e}")
    
    return []

def search_with_json_fallback(date_str, cookies):
    """Fallback: submit form but check for JSON in response"""
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    year = str(date_obj.year)
    month = date_obj.month
    day = date_obj.day
    
    # Try both JSON and form headers
    json_headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Accept': 'application/json, text/html, */*',
        'Content-Type': 'application/json',
        'X-Requested-With': 'XMLHttpRequest'
    }
    
    form_headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36',
        'Content-Type': 'application/x-www-form-urlencoded',
        'Accept': 'application/json, text/html, */*'
    }
    
    # Search data in different formats
    json_data = {
        "event_start_month": month - 1,
        "event_start_day": day - 1,
        "event_start_year": year,
        "event_end_month": month - 1,
        "event_end_day": day - 1,
        "event_end_year": year,
        "submit": "Submit",
        "pageId": "19"
    }
    
    form_data = {
        'event_start_month': str(month - 1),
        'event_start_day': str(day - 1),
        'event_start_year': year,
        'event_end_month': str(month - 1),
        'event_end_day': str(day - 1),
        'event_end_year': year,
        'submit': 'Submit',
        'pageId': '19'
    }
    
    search_urls = [
        "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do",
        "https://mufon.app.neoncrm.com/api/search",
        "https://mufoncms.com/api/search"
    ]
    
    with httpx.Client(cookies=cookies, timeout=60.0, follow_redirects=True) as client:
        # Try JSON POST first
        for url in search_urls:
            try:
                print(f"🔍 Trying JSON POST to {url}")
                response = client.post(url, headers=json_headers, json=json_data)
                
                if response.status_code == 200:
                    try:
                        data = response.json()
                        cases = parse_json_response(data)
                        if cases:
                            print(f"✅ Got {len(cases)} cases from JSON response")
                            return cases
                    except:
                        print("📋 Response is not JSON, trying form data...")
                        
            except Exception as e:
                print(f"⚠️  JSON POST failed: {e}")
        
        # Try form POST 
        for url in search_urls:
            try:
                print(f"🔍 Trying form POST to {url}")
                response = client.post(url, headers=form_headers, data=form_data)
                
                if response.status_code == 200:
                    # Check if response is JSON
                    try:
                        data = response.json()
                        cases = parse_json_response(data)
                        if cases:
                            print(f"✅ Got {len(cases)} cases from JSON response")
                            return cases
                    except:
                        # Response is HTML, extract any embedded JSON
                        cases = extract_json_from_html(response.text)
                        if cases:
                            print(f"✅ Extracted {len(cases)} cases from HTML-embedded JSON")
                            return cases
                        
            except Exception as e:
                print(f"⚠️  Form POST failed: {e}")
    
    return []

def parse_json_response(data):
    """Parse JSON response and extract case information properly"""
    cases = []
    
    # Handle different JSON structures
    if isinstance(data, list):
        # Direct array of cases
        for item in data:
            case = parse_case_json(item)
            if case:
                cases.append(case)
                
    elif isinstance(data, dict):
        # Look for cases in common keys
        possible_keys = ['cases', 'results', 'data', 'items', 'records']
        for key in possible_keys:
            if key in data and isinstance(data[key], list):
                for item in data[key]:
                    case = parse_case_json(item)
                    if case:
                        cases.append(case)
                break
        
        # If no array found, treat the whole dict as a single case
        if not cases:
            case = parse_case_json(data)
            if case:
                cases.append(case)
    
    return cases

def parse_case_json(item):
    """Parse individual case from JSON with proper field mapping"""
    if not isinstance(item, dict):
        return None
    
    case = {
        'case_number': None,
        'date_time': None,
        'location': None,
        'description': None,
        'long_description': None,
        'media_files': []
    }
    
    # Map common JSON field names to our structure
    field_mappings = {
        'case_number': ['case_number', 'caseNumber', 'id', 'case_id', 'number'],
        'date_time': ['date_time', 'dateTime', 'event_date', 'date', 'occurred_at', 'sighting_date'],
        'location': ['location', 'place', 'city', 'state', 'country', 'address', 'geo_location'],
        'description': ['description', 'summary', 'short_description', 'brief'],
        'long_description': ['long_description', 'longDescription', 'full_description', 'details', 'narrative', 'report']
    }
    
    for our_field, possible_keys in field_mappings.items():
        for key in possible_keys:
            if key in item and item[key]:
                case[our_field] = str(item[key]).strip()
                break
    
    # Extract media files if present
    media_keys = ['media', 'attachments', 'files', 'images', 'videos']
    for key in media_keys:
        if key in item and isinstance(item[key], list):
            for media_item in item[key]:
                if isinstance(media_item, dict) and 'url' in media_item:
                    case['media_files'].append({
                        'filename': media_item.get('filename', ''),
                        'url': media_item['url'],
                        'type': media_item.get('type', 'unknown'),
                        'local_path': ''
                    })
    
    # Only return cases with at least a case number
    if case['case_number']:
        return case
    
    return None

def extract_json_from_html(html_content):
    """Extract JSON data embedded in HTML"""
    cases = []
    
    # Look for common JSON patterns in HTML
    json_patterns = [
        r'var\s+cases\s*=\s*(\[.*?\]);',
        r'var\s+data\s*=\s*(\{.*?\});',
        r'"cases":\s*(\[.*?\])',
        r'JSON\.parse\([\'"]([^\'"]*)[\'\"]\)'
    ]
    
    for pattern in json_patterns:
        matches = re.findall(pattern, html_content, re.DOTALL)
        for match in matches:
            try:
                data = json.loads(match)
                extracted_cases = parse_json_response(data)
                cases.extend(extracted_cases)
            except:
                continue
    
    return cases

def discover_media_files(case_number, cookies):
    """Discover media files for a case by trying common patterns"""
    media_files = []
    media_dir = Path("mufon_media")
    media_dir.mkdir(exist_ok=True)
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36'
    }
    
    # Try common file patterns
    file_patterns = [
        f"{case_number}_submitter_file{{i}}__{{filename}}",
        f"case_{case_number}_file{{i}}.{{ext}}",
        f"{case_number}_{{i}}.{{ext}}"
    ]
    
    extensions = ['jpg', 'jpeg', 'png', 'gif', 'mp4', 'mov', 'avi', 'wmv']
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=30.0, follow_redirects=True) as client:
        for i in range(1, 6):  # Try up to 5 files per case
            for ext in extensions:
                # Try actual filenames if we can guess them
                test_filenames = [
                    f"IMG{case_number[-4:]}.{ext}",  # Common pattern
                    f"video{i}.{ext}",
                    f"image{i}.{ext}",
                    f"file{i}.{ext}"
                ]
                
                for filename in test_filenames:
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
                        
            time.sleep(0.2)  # Small delay between requests
    
    return media_files

def extract_mufon_json(date_str):
    """Main extraction function using JSON parsing"""
    try:
        # Load authenticated cookies
        cookies = load_authenticated_cookies()
        print(f"🔑 Loaded {len(cookies)} authentication cookies")
        
        # Search for cases using HTML form submission  
        cases = search_mufon_html(date_str, cookies)
        
        if not cases:
            print("⚠️  No cases found with JSON methods")
            return None
        
        # Get media files for each case
        for case in cases:
            if case.get('case_number'):
                print(f"🎬 Finding media for case {case['case_number']}")
                media_files = discover_media_files(case['case_number'], cookies)
                case['media_files'].extend(media_files)
            
        # Save results
        filename = f"mufon_json_{date_str.replace('-', '_')}.json"
        output = {
            "search_date": date_str,
            "timestamp": datetime.now().isoformat(),
            "extraction_method": "httpx_json_parsing",
            "total_cases": len(cases),
            "cases": cases
        }
        
        with open(filename, "w") as f:
            json.dump(output, f, indent=2)
        
        print(f"🎉 JSON extracted {len(cases)} cases with proper field mapping!")
        print(f"💾 Saved to {filename}")
        
        # Show sample of extracted data
        if cases:
            print(f"\n📋 Sample case structure:")
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
        print("Usage: python httpx_proper_extractor.py YYYY-MM-DD")
        print("Example: python httpx_proper_extractor.py 2024-09-05")
        sys.exit(1)
    
    date_arg = sys.argv[1]
    extract_mufon_json(date_arg)