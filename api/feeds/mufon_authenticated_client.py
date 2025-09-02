"""
MUFON Authenticated CRM Client - Get detailed reports with full descriptions
Uses authenticated session to access richer data from MUFON CRM
"""
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any, Optional, Tuple
import hashlib
from datetime import datetime, timedelta
import asyncio
import re
from geopy.geocoders import Nominatim
import os
from urllib.parse import urljoin, urlparse

async def fetch_authenticated_reports(limit: int = 30, days_back: int = 2) -> List[Dict[str, Any]]:
    """
    Fetch detailed MUFON reports using authenticated CRM access
    Returns reports with full descriptions and enhanced data
    """
    # Credentials from secrets
    username = "varak"
    password = "ufobeep123pass"
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0) as client:
        # Step 1: Login to CRM
        print("Authenticating to MUFON CRM...")
        
        login_page = await client.get("https://mufon.app.neoncrm.com/np/clients/mufon/login.jsp")
        soup = BeautifulSoup(login_page.text, 'html.parser')
        
        # Find login form
        login_form = None
        for form in soup.find_all('form'):
            if form.get('action') and 'signIn.do' in form.get('action'):
                login_form = form
                break
        
        if not login_form:
            print("❌ Login form not found")
            return []
        
        # Extract form data for login
        form_data = {}
        for inp in login_form.find_all('input'):
            name = inp.get('name')
            value = inp.get('value', '')
            if name:
                if name == 'loginName':
                    form_data[name] = username
                elif name == 'loginPassword':
                    form_data[name] = password
                else:
                    form_data[name] = value
        
        # Perform login
        login_response = await client.post("https://mufon.app.neoncrm.com/np/security/signIn.do", data=form_data)
        
        if "accountHome.do" not in str(login_response.url):
            print("❌ Authentication failed")
            return []
        
        print("✅ Successfully authenticated to MUFON CRM")
        
        # Step 2: Perform a search within the CRM for last 30 days
        print(f"\nStep 2: Searching CRM for last {days_back} days of reports...")
        
        # Calculate date range for nightly runs
        end_date = datetime.now()
        start_date = end_date - timedelta(days=days_back)
        
        print(f"Searching from {start_date.strftime('%m/%d/%Y')} to {end_date.strftime('%m/%d/%Y')}")
        
        try:
            # Use direct search database URL with parameters instead of form parsing
            search_db_url = "https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp"
            
            # Build search parameters directly
            search_params = {
                'pageId': '19',
                'choice': 'search',  # Try search option first
                'from_date': start_date.strftime('%m/%d/%Y'),
                'to_date': end_date.strftime('%m/%d/%Y'),
                'limit': limit
            }
            
            print(f"Making direct search request to: {search_db_url}")
            print(f"Search parameters: {search_params}")
            
            # Try direct GET request with parameters
            search_response = await client.get(search_db_url, params=search_params)
            print(f"Direct search response status: {search_response.status_code}")
            
            if search_response.status_code == 200:
                search_soup = BeautifulSoup(search_response.text, 'html.parser')
                print(f"Search results page title: {search_soup.title.get_text() if search_soup.title else 'No title'}")
                
                # Parse results directly
                reports = await _parse_detailed_reports(search_soup, limit, client)
                print(f"Found {len(reports)} reports from direct search")
                
                if reports:
                    return reports
            
            # If direct search didn't work, try POST with form data
            print("Direct search failed, trying POST with form data...")
            search_response = await client.post(search_db_url, data=search_params)
            print(f"POST search response status: {search_response.status_code}")
            
            search_response = None
            search_url = None
            
            for url in search_urls_to_try:
                try:
                    print(f"Trying search URL: {url}")
                    test_response = await client.get(url)
                    if test_response.status_code == 200:
                        print(f"✅ Found working search URL: {url}")
                        search_response = test_response
                        search_url = url
                        break
                    else:
                        print(f"  Status: {test_response.status_code}")
                except Exception as e:
                    print(f"  Error: {e}")
                    continue
            
            if not search_response:
                print("❌ No working search URLs found - authentication likely failed")
                print("Available session cookies:", list(client.cookies.keys()))
                return []
            
            # Parse the search page to find forms or data
            search_soup = BeautifulSoup(search_response.text, 'html.parser')
            
            print(f"Search page title: {search_soup.title.get_text() if search_soup.title else 'No title'}")
            
            # Look for search forms to submit date range
            forms = search_soup.find_all('form')
            print(f"Found {len(forms)} forms on search page")
            
            search_form = None
            for i, form in enumerate(forms):
                action = form.get('action', 'No action')
                method = form.get('method', 'GET')
                inputs = form.find_all(['input', 'select', 'textarea'])
                
                print(f"\nForm {i+1}: {action} ({method}) with {len(inputs)} fields")
                
                # Look for MUFON choice select field or date-related inputs
                has_choice_field = False
                has_date_fields = False
                
                for inp in inputs:
                    inp_type = inp.get('type', inp.name) 
                    inp_name = inp.get('name', 'unnamed')
                    inp_value = inp.get('value', '')
                    
                    print(f"  - {inp_type}: {inp_name} = '{inp_value}'")
                    
                    # Check for MUFON choice select field
                    if inp_name == 'choice' and inp.name == 'select':
                        has_choice_field = True
                        options = inp.find_all('option')
                        print(f"    Choice options: {[opt.get('value') or opt.get_text().strip() for opt in options]}")
                    
                    # Check for date fields
                    if any(keyword in inp_name.lower() for keyword in ['date', 'from', 'to', 'start', 'end']):
                        has_date_fields = True
                
                # Use form with choice field (preferred) or date fields
                if has_choice_field:
                    print(f"  -> Using MUFON choice field form for database search")
                    search_form = form
                    break
                
                if has_date_fields:
                    print(f"  -> Using form with date fields")
                    search_form = form
                    break
            
            # If we found a search form with date fields, submit it
            if search_form:
                print(f"\n✅ Found search form, submitting date range query...")
                
                # Build form data for inputs and selects
                form_data = {}
                
                # Handle input fields
                for inp in search_form.find_all('input'):
                    name = inp.get('name')
                    value = inp.get('value', '')
                    inp_type = inp.get('type', 'text')
                    
                    if name:
                        if inp_type == 'submit':
                            continue
                        elif 'start' in name.lower() or 'from' in name.lower():
                            form_data[name] = start_date.strftime('%m/%d/%Y')
                        elif 'end' in name.lower() or 'to' in name.lower():
                            form_data[name] = end_date.strftime('%m/%d/%Y')  
                        else:
                            form_data[name] = value
                
                # Handle select fields (like choice)
                for select in search_form.find_all('select'):
                    name = select.get('name')
                    if name == 'choice':
                        # For MUFON choice field, we need to find the right option
                        # Try to find a search or database option
                        options = select.find_all('option')
                        search_value = None
                        
                        for option in options:
                            option_text = option.get_text().strip().lower()
                            option_value = option.get('value', '').strip()
                            
                            # Look for CMS database options (z2systems URLs) instead of public reports
                            if 'z2systems.com/neonPage.jsp' in option_value:
                                search_value = option_value
                                print(f"  -> Using CMS database option: '{option.get_text().strip()}' (value: '{search_value}')")
                                break
                        
                        # If no specific search option found, use the first non-empty option
                        if not search_value and options:
                            for option in options:
                                if option.get('value') or option.get_text().strip():
                                    search_value = option.get('value') or option.get_text().strip()
                                    print(f"  -> Using fallback choice option: '{option.get_text().strip()}' (value: '{search_value}')")
                                    break
                        
                        if search_value:
                            form_data[name] = search_value
                
                # Submit search
                form_action = search_form.get('action')
                if form_action and not form_action.startswith('http'):
                    if form_action.startswith('/'):
                        form_action = f"https://mufon.app.neoncrm.com{form_action}"
                    else:
                        form_action = f"https://mufon.app.neoncrm.com/np/clients/mufon/{form_action}"
                
                search_method = search_form.get('method', 'POST').upper()
                
                print(f"Submitting to: {form_action} ({search_method})")
                print(f"Form data: {form_data}")
                
                results_response = await client.request(search_method, form_action, data=form_data)
                results_soup = BeautifulSoup(results_response.text, 'html.parser')
                
                print(f"Search results status: {results_response.status_code}")
                
            else:
                # No search form found, try to parse current page for data
                print("No search form found, parsing current page for data...")
                results_soup = search_soup
            
            # Parse the results
            reports = await _parse_detailed_reports(results_soup, limit, client)
            
            print(f"Successfully parsed {len(reports)} detailed reports from CRM search")
            return reports
            
        except Exception as e:
            print(f"Error performing CRM search: {e}")
            
            # Final fallback to public data
            print("Final fallback to public endpoint...")
            fallback_response = await client.get("https://mufoncms.com/last_20_public.html")
            fallback_soup = BeautifulSoup(fallback_response.text, 'html.parser')
            return await _parse_detailed_reports(fallback_soup, limit, client)

async def _parse_detailed_reports(soup: BeautifulSoup, limit: int, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
    """Parse detailed MUFON reports from HTML with full descriptions"""
    reports = []
    
    # Look for report containers - could be table rows, divs, or other structures
    # Try multiple selectors to find the report data
    
    # Try table-based structure first
    table = soup.find('table')
    if table:
        rows = table.find_all('tr')[1:]  # Skip header
        print(f"Found table with {len(rows)} data rows")
        
        for i, row in enumerate(rows[:limit]):
            try:
                cells = row.find_all('td')
                if len(cells) >= 6:
                    report = await _parse_enhanced_row(cells, i, client)
                    if report:
                        reports.append(report)
                        # Rate limiting for geocoding and media processing
                        await asyncio.sleep(0.5)
            except Exception as e:
                print(f"Error parsing row {i}: {e}")
                continue
    
    # Also try div-based structure for detailed reports
    report_divs = soup.find_all('div', class_=re.compile(r'report|case|sighting', re.I))
    if report_divs and len(report_divs) > len(reports):
        print(f"Found {len(report_divs)} report divs, parsing...")
        
        for i, div in enumerate(report_divs[:limit]):
            try:
                report = await _parse_enhanced_div(div, i, client)
                if report:
                    # Check for duplicates
                    duplicate = False
                    for existing in reports:
                        if report.get('case_number') and report['case_number'] == existing.get('case_number'):
                            duplicate = True
                            break
                    
                    if not duplicate:
                        reports.append(report)
                        await asyncio.sleep(0.5)
            except Exception as e:
                print(f"Error parsing div {i}: {e}")
                continue
    
    return reports

async def _parse_enhanced_row(cells, row_index: int, client: httpx.AsyncClient) -> Optional[Dict[str, Any]]:
    """Parse enhanced table row with full descriptions"""
    try:
        # Enhanced MUFON structure - extract all available data
        case_num = _extract_case_id_from_cells(cells) or cells[0].get_text(strip=True) if len(cells) > 0 else f"row_{row_index}"
        date_str = cells[1].get_text(strip=True) if len(cells) > 1 else ""
        city = cells[2].get_text(strip=True) if len(cells) > 2 else ""
        state = cells[3].get_text(strip=True) if len(cells) > 3 else ""
        country = cells[4].get_text(strip=True) if len(cells) > 4 else ""
        shape = cells[5].get_text(strip=True) if len(cells) > 5 else ""
        duration = cells[6].get_text(strip=True) if len(cells) > 6 else ""
        
        # Look for description fields - these might be in additional columns
        summary = cells[7].get_text(strip=True) if len(cells) > 7 else ""
        long_description = cells[8].get_text(strip=True) if len(cells) > 8 else ""
        
        # If no separate long description, try to extract from summary or look for more data
        if not long_description and len(cells) > 8:
            # Check if there are additional cells with description data
            for cell in cells[8:]:
                cell_text = cell.get_text(strip=True)
                if len(cell_text) > len(summary):
                    long_description = cell_text
                    break
        
        # Parse date
        occurred_at = _parse_mufon_date(date_str)
        
        # Geocode location for coordinates
        lat, lon = await _geocode_location(city, state, country)
        
        # Extract and download media attachments
        media_files = await _extract_and_download_media(cells, case_num, client)
        
        return {
            "case_number": case_num,
            "date_str": date_str,
            "city": city,
            "state": state,
            "country": country,
            "shape": shape,
            "duration": duration,
            "summary": summary,
            "long_description": long_description,  # Enhanced field
            "occurred_at": occurred_at,
            "lat": lat,
            "lon": lon,
            "url": f"https://mufoncms.com/case/{case_num}" if case_num else None,
            "source_type": "authenticated_crm",
            "media_files": media_files  # Include extracted media files
        }
        
    except Exception as e:
        print(f"Error parsing enhanced row: {e}")
        return None

async def _parse_enhanced_div(div, div_index: int, client: httpx.AsyncClient) -> Optional[Dict[str, Any]]:
    """Parse enhanced div-based report structure"""
    try:
        # Extract data from div structure
        case_num = ""
        summary = ""
        long_description = ""
        
        # Look for case number from links or extract from URLs
        case_num = _extract_case_id_from_div(div)
        if not case_num:
            case_links = div.find_all('a', href=re.compile(r'case|report', re.I))
            if case_links:
                case_num = case_links[0].get_text(strip=True)
        
        # Extract all text content and try to identify descriptions
        text_content = div.get_text(separator=' | ', strip=True)
        
        # Split content to find short and long descriptions
        sentences = text_content.split('|')
        if len(sentences) >= 2:
            summary = sentences[0].strip()
            long_description = ' '.join(sentences[1:]).strip()
        else:
            summary = text_content[:200] + "..." if len(text_content) > 200 else text_content
            long_description = text_content
        
        # Try to extract other fields
        city, state, country = _extract_location_from_text(text_content)
        shape, duration = _extract_details_from_text(text_content)
        
        occurred_at = datetime.utcnow()  # Fallback date
        
        # Geocode location
        lat, lon = await _geocode_location(city, state, country)
        
        # Extract media files from div content
        media_files = []
        for link in div.find_all('a', href=True):
            href = link.get('href')
            if href and any(ext in href.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi']):
                try:
                    if not href.startswith('http'):
                        if href.startswith('/'):
                            href = f"https://mufoncms.com{href}"
                        else:
                            href = f"https://mufoncms.com/{href}"
                    
                    media_info = {
                        "url": href,
                        "type": "image" if any(ext in href.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video",
                        "source": "mufon_authenticated",
                        "case_number": case_num or f"div_{div_index}"
                    }
                    media_files.append(media_info)
                except Exception as e:
                    print(f"Error processing media from {href}: {e}")
                    continue
        
        return {
            "case_number": case_num or f"div_{div_index}",
            "date_str": "",
            "city": city,
            "state": state,
            "country": country,
            "shape": shape,
            "duration": duration,
            "summary": summary,
            "long_description": long_description,  # Enhanced field
            "occurred_at": occurred_at,
            "lat": lat,
            "lon": lon,
            "url": f"https://mufoncms.com/case/{case_num}" if case_num else None,
            "source_type": "authenticated_crm",
            "media_files": media_files
        }
        
    except Exception as e:
        print(f"Error parsing enhanced div: {e}")
        return None

async def _geocode_location(city: str, state: str, country: str) -> Tuple[Optional[float], Optional[float]]:
    """Geocode location to get coordinates"""
    if not city:
        # Fallback to Las Vegas coordinates if no location
        return 36.1672719, -115.1483538
    
    try:
        geocoder = Nominatim(user_agent="ufobeep_feeds/1.0")
        
        # Build search query
        location_parts = [p for p in [city, state, country] if p]
        query = ", ".join(location_parts)
        
        location = geocoder.geocode(query, timeout=10)
        
        if location:
            return float(location.latitude), float(location.longitude)
    
    except Exception as e:
        print(f"Geocoding error for {city}, {state}, {country}: {e}")
    
    # Fallback coordinates (Las Vegas)
    return 36.1672719, -115.1483538

def _parse_mufon_date(date_str: str) -> datetime:
    """Parse MUFON date string to datetime"""
    try:
        date_str = date_str.strip()
        
        formats = ["%m/%d/%Y", "%Y-%m-%d", "%m-%d-%Y", "%d/%m/%Y"]
        
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt)
            except ValueError:
                continue
                
        return datetime.utcnow()
    except:
        return datetime.utcnow()

def _extract_location_from_text(text: str) -> Tuple[str, str, str]:
    """Extract city, state, country from text content"""
    # Simple extraction - could be enhanced based on actual format
    city = state = country = ""
    
    # Look for patterns like "City, State" or "City, State, Country"
    location_match = re.search(r'([A-Za-z\s]+),\s*([A-Z]{2})\s*,?\s*([A-Za-z\s]*)', text)
    if location_match:
        city = location_match.group(1).strip()
        state = location_match.group(2).strip()
        country = location_match.group(3).strip() or "US"
    
    return city, state, country

def _extract_details_from_text(text: str) -> Tuple[str, str]:
    """Extract shape and duration from text content"""
    shape = duration = ""
    
    # Look for shape keywords
    shapes = ["circle", "triangle", "disc", "sphere", "cylinder", "oval", "diamond", "rectangle", "cigar", "light"]
    for s in shapes:
        if s.lower() in text.lower():
            shape = s.capitalize()
            break
    
    # Look for duration patterns
    duration_match = re.search(r'(\d+\s*(?:second|minute|hour|sec|min|hr)s?)', text, re.I)
    if duration_match:
        duration = duration_match.group(1)
    
    return shape, duration

async def _extract_and_download_media(cells, case_num: str, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
    """Extract and download media attachments from MUFON report"""
    media_files = []
    
    # Look for image/video links in table cells
    for cell in cells:
        # Find all links that might be media
        for link in cell.find_all('a', href=True):
            href = link.get('href')
            if not href:
                continue
                
            # Check if link points to media file
            if any(ext in href.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi']):
                try:
                    # Make URL absolute if needed
                    if not href.startswith('http'):
                        if href.startswith('/'):
                            href = f"https://mufoncms.com{href}"
                        else:
                            href = f"https://mufoncms.com/{href}"
                    
                    # Basic media info - would need full UFOBeep media processing
                    media_info = {
                        "url": href,
                        "type": "image" if any(ext in href.lower() for ext in ['.jpg', '.jpeg', '.png', '.gif']) else "video",
                        "source": "mufon_authenticated",
                        "case_number": case_num
                    }
                    media_files.append(media_info)
                    
                except Exception as e:
                    print(f"Error processing media from {href}: {e}")
                    continue
    
    return media_files

def _extract_case_id_from_cells(cells) -> Optional[str]:
    """Extract MUFON case ID from table cells"""
    for cell in cells:
        # Look for links with id= parameter
        for link in cell.find_all('a', href=True):
            href = link.get('href')
            if href:
                match = re.search(r'id=(\d+)', href)
                if match:
                    return match.group(1)
        
        # Look for case ID in text content
        text = cell.get_text()
        if text and text.isdigit():
            return text
    
    return None

def _extract_case_id_from_div(div) -> Optional[str]:
    """Extract MUFON case ID from div content"""
    # Look for links with id= parameter
    for link in div.find_all('a', href=True):
        href = link.get('href')
        if href:
            match = re.search(r'id=(\d+)', href)
            if match:
                return match.group(1)
    
    # Look in text content for case patterns
    text = div.get_text()
    match = re.search(r'(?:case|id)[\s#:]*(\d{5,})', text, re.I)
    if match:
        return match.group(1)
    
    return None

def _clean_mufon_location(city: str, state: str, country: str) -> tuple[str, str, str]:
    """Clean messy MUFON location data"""
    # Handle leading zeros and empty cities
    if city and (city.strip() == '0' or city.strip().startswith('0,')):
        city = ""
    
    # Clean up state
    if state and state.strip() == '0':
        state = ""
    
    # Default country if missing
    if not country or country.strip() in ['', '0']:
        country = "US"
    
    # If no city but we have state, try state name
    if not city and state:
        city = state
    
    return city.strip() if city else "", state.strip() if state else "", country.strip()

def to_alert_dict(mufon_report: Dict[str, Any]) -> Dict[str, Any]:
    """Convert enhanced MUFON report to sighting/alert format"""
    # Create unique hash
    content = f"{mufon_report.get('case_number', '')}-{mufon_report.get('summary', '')}-{mufon_report.get('city', '')}"
    ingestion_hash = hashlib.sha256(content.encode()).hexdigest()
    
    # Build location string
    location_parts = [mufon_report.get('city', ''), mufon_report.get('state', ''), mufon_report.get('country', '')]
    location = ', '.join([p for p in location_parts if p])
    
    # Create enhanced title
    title = f"UFO Sighting in {mufon_report.get('city', 'Unknown Location')}"
    if mufon_report.get('shape'):
        title += f" - {mufon_report.get('shape')} Shape"
    
    # Use long description if available, otherwise fall back to summary
    description = mufon_report.get('long_description') or mufon_report.get('summary', '')
    
    return {
        "source": "mufon_authenticated",
        "source_id": mufon_report.get('case_number'),
        "ingestion_hash": ingestion_hash,
        "occurred_at": mufon_report.get('occurred_at'),
        "title": title,
        "summary": mufon_report.get('summary', ''),
        "description": description,  # Enhanced field with full description
        "city": mufon_report.get('city'),
        "state": mufon_report.get('state'),
        "country": mufon_report.get('country'),
        "shape": mufon_report.get('shape'),
        "duration": mufon_report.get('duration'),
        "lat": mufon_report.get('lat'),
        "lon": mufon_report.get('lon'),
        "external_url": mufon_report.get('url'),
        "raw": mufon_report
    }