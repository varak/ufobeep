#!/usr/bin/env python3
"""
Complete MUFON extraction using httpx authenticated session
Gets search results, long descriptions, and media files
"""
import httpx
import json
import re
from pathlib import Path
from datetime import datetime
from urllib.parse import urljoin, urlparse, parse_qs

def load_cookies():
    """Load cookies from storage_state.json"""
    with open("mufon_artifacts/storage_state.json") as f:
        storage_data = json.load(f)
    
    cookies = {}
    for cookie in storage_data.get('cookies', []):
        cookies[cookie['name']] = cookie['value']
    return cookies

def extract_mufon_date_httpx(date_str):
    """Extract MUFON cases for specific date using httpx"""
    print(f"📅 Extracting MUFON cases for {date_str}")
    
    # Parse date
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    year = str(date_obj.year)
    month = date_obj.month - 1  # 0-based
    day = date_obj.day - 1      # 0-based
    
    cookies = load_cookies()
    print(f"🔑 Loaded {len(cookies)} cookies")
    
    headers = {
        'User-Agent': 'Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate, br',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    }
    
    cases = []
    
    with httpx.Client(cookies=cookies, headers=headers, timeout=60.0, follow_redirects=True) as client:
        
        # Step 1: Go to search page
        print("🔍 Going to search page...")
        search_page = "https://mufon.app.neoncrm.com/np/publicaccess/neonPage.do?pageId=19&"
        response = client.get(search_page)
        print(f"Search page: {response.status_code}")
        
        # Step 2: Submit search form
        print(f"📝 Submitting search for {date_str}...")
        form_data = {
            'event_start_month': str(month),
            'event_start_day': str(day),
            'event_start_year': year,
            'event_end_month': str(month),
            'event_end_day': str(day),
            'event_end_year': year,
            'submit': 'Submit'
        }
        
        # Submit to same URL
        response = client.post(search_page, data=form_data)
        print(f"Search submitted: {response.status_code}")
        
        # Step 3: Parse results HTML
        html = response.text
        
        # Look for iframe with results
        iframe_match = re.search(r'<iframe[^>]*src="([^"]*)"', html)
        if iframe_match:
            iframe_url = iframe_match.group(1)
            if not iframe_url.startswith('http'):
                iframe_url = urljoin(response.url, iframe_url)
            
            print(f"📊 Getting results from iframe: {iframe_url}")
            iframe_response = client.get(iframe_url)
            html = iframe_response.text
        
        # Step 4: Extract table rows
        # Look for table rows with case data
        table_pattern = r'<tr[^>]*>(.*?)</tr>'
        rows = re.findall(table_pattern, html, re.DOTALL)
        
        print(f"Found {len(rows)} table rows")
        
        processed_cases = set()
        
        for row_html in rows:
            # Extract cells
            cell_pattern = r'<td[^>]*>(.*?)</td>'
            cells = re.findall(cell_pattern, row_html, re.DOTALL)
            
            if len(cells) >= 4:
                # Clean HTML from cells
                clean_cells = []
                for cell in cells:
                    clean_text = re.sub(r'<[^>]+>', ' ', cell)
                    clean_text = re.sub(r'\s+', ' ', clean_text).strip()
                    clean_cells.append(clean_text)
                
                # Check if this looks like a case row
                if clean_cells[0] and any(char.isdigit() for char in clean_cells[0]):
                    case_number = clean_cells[0].strip()
                    
                    # Skip duplicates
                    if case_number in processed_cases:
                        continue
                    processed_cases.add(case_number)
                    
                    date_time = clean_cells[1] if len(clean_cells) > 1 else ""
                    short_desc = clean_cells[2] if len(clean_cells) > 2 else ""
                    location = clean_cells[3] if len(clean_cells) > 3 else ""
                    
                    print(f"\n📋 Case {case_number}: {short_desc[:50]}...")
                    
                    # Step 5: Get long description via VIEW button
                    long_description = ""
                    view_match = re.search(r'<input[^>]*value[^>]*VIEW[^>]*onclick="([^"]*)"', row_html)
                    if view_match:
                        onclick_content = view_match.group(1)
                        # Extract URL from onclick - usually like "location.href='url'"
                        url_match = re.search(r"location\.href='([^']*)'", onclick_content)
                        if url_match:
                            view_url = url_match.group(1)
                            if not view_url.startswith('http'):
                                view_url = urljoin(response.url, view_url)
                            
                            print(f"   🔍 Getting long description from: {view_url}")
                            try:
                                view_response = client.get(view_url)
                                view_html = view_response.text
                                
                                # Extract long description from detail page
                                # Look for substantial text content
                                text_content = re.sub(r'<[^>]+>', ' ', view_html)
                                lines = [line.strip() for line in text_content.split('\n')]
                                
                                # Find the longest substantial line as description
                                for line in lines:
                                    if (len(line) > 100 and 
                                        'mufon' not in line.lower() and
                                        'description' not in line.lower()[:20]):
                                        long_description = line[:1000]  # Limit length
                                        break
                                
                                if long_description:
                                    print(f"   ✅ Got {len(long_description)} char description")
                                else:
                                    print(f"   ⚠️ No long description found")
                                    
                            except Exception as e:
                                print(f"   ❌ Error getting description: {e}")
                    
                    # Step 6: Get media files
                    media_files = []
                    # Look for attachment links in the row
                    attachment_pattern = r'<a[^>]*href="([^"]*)"[^>]*>([^<]*\.(jpg|jpeg|png|gif|mp4|mov|avi))</a>'
                    attachments = re.findall(attachment_pattern, row_html, re.IGNORECASE)
                    
                    for href, filename, ext in attachments:
                        if not href.startswith('http'):
                            href = urljoin(response.url, href)
                        
                        file_type = "image" if ext.lower() in ['jpg', 'jpeg', 'png', 'gif'] else "video"
                        
                        print(f"   📎 Found media: {filename}")
                        
                        # Download media file
                        try:
                            media_response = client.get(href)
                            if media_response.status_code == 200 and len(media_response.content) > 1000:
                                # Save to local file
                                media_dir = Path("httpx_media")
                                media_dir.mkdir(exist_ok=True)
                                local_path = media_dir / f"{case_number}_{filename}"
                                
                                with open(local_path, 'wb') as f:
                                    f.write(media_response.content)
                                
                                print(f"   ✅ Downloaded {filename} ({len(media_response.content)} bytes)")
                                
                                media_files.append({
                                    "filename": filename,
                                    "url": href,
                                    "type": file_type,
                                    "local_path": str(local_path)
                                })
                            else:
                                print(f"   ❌ Download failed for {filename}")
                                
                        except Exception as e:
                            print(f"   ❌ Error downloading {filename}: {e}")
                    
                    # Store case data
                    case_data = {
                        "case_number": case_number,
                        "date_time": date_time,
                        "short_description": short_desc,
                        "long_description": long_description,
                        "location": location,
                        "media_files": media_files
                    }
                    
                    cases.append(case_data)
    
    # Save results
    filename = f"mufon_httpx_complete_{date_str.replace('-', '_')}.json"
    output = {
        "search_date": date_str,
        "timestamp": datetime.now().isoformat(),
        "method": "httpx_complete",
        "total_cases": len(cases),
        "cases": cases
    }
    
    with open(filename, "w") as f:
        json.dump(output, f, indent=2)
    
    print(f"\n🎉 Extracted {len(cases)} cases with long descriptions and media!")
    print(f"💾 Saved to {filename}")
    
    return filename

if __name__ == "__main__":
    import sys
    if len(sys.argv) != 2:
        print("Usage: python httpx_full_extractor.py YYYY-MM-DD")
        sys.exit(1)
    
    extract_mufon_date_httpx(sys.argv[1])