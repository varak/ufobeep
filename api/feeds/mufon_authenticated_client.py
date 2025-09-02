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

async def fetch_authenticated_reports(limit: int = 30, days_back: int = 2, list_only: bool = False) -> List[Dict[str, Any]]:
    """
    Fetch detailed MUFON reports following user navigation flow:
    1. Go to mufon.com/research/
    2. Login via login link  
    3. Navigate to Track UFOs
    4. Find Search Database
    5. Submit search with date range
    """
    # Credentials from secrets
    username = "varak"
    password = "ufobeep123pass"
    
    # Set up client with browser-like headers
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
    }
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0, headers=headers) as client:
        try:
            # Step 1: Go to research page like a real user
            print("Step 1: Navigating to MUFON research page...")
            
            research_response = await client.get("https://mufon.com/research/")
            if research_response.status_code != 200:
                print(f"❌ Could not access research page: {research_response.status_code}")
                return []
            
            research_soup = BeautifulSoup(research_response.text, 'html.parser')
            print(f"✅ Research page loaded: {research_soup.title.get_text() if research_soup.title else 'No title'}")
            
            # Step 2: Find and follow the login link
            print("\nStep 2: Looking for login link...")
            
            login_links = []
            for link in research_soup.find_all('a', href=True):
                text = link.get_text().lower().strip()
                href = link.get('href')
                
                if any(keyword in text for keyword in ['login', 'log in', 'sign in', 'signin']):
                    login_links.append({
                        'text': link.get_text().strip(),
                        'href': href,
                        'full_url': urljoin('https://mufon.com/', href)
                    })
            
            print(f"Found {len(login_links)} login links:")
            for link in login_links:
                print(f"  - '{link['text']}' → {link['href']}")
            
            if not login_links:
                print("❌ No login links found on research page")
                return []
            
            # Use the first login link
            login_url = login_links[0]['full_url']
            print(f"Following login link: {login_url}")
            
            login_page = await client.get(login_url)
            if login_page.status_code != 200:
                print(f"❌ Could not access login page: {login_page.status_code}")
                return []
            
            login_soup = BeautifulSoup(login_page.text, 'html.parser')
            print(f"✅ Login page loaded: {login_soup.title.get_text() if login_soup.title else 'No title'}")
            
            # Step 3: Find and submit login form
            print("\nStep 3: Authenticating...")
            
            login_form = None
            for form in login_soup.find_all('form'):
                action = form.get('action', '')
                if any(keyword in action.lower() for keyword in ['signin', 'login', 'auth']):
                    login_form = form
                    break
            
            if not login_form:
                print("❌ Login form not found")
                return []
            
            # Extract ALL form data for login (including hidden fields and tokens)
            form_data = {}
            for inp in login_form.find_all('input'):
                name = inp.get('name', '')
                value = inp.get('value', '')
                input_type = inp.get('type', 'text')
                
                if name:
                    if any(keyword in name.lower() for keyword in ['username', 'login', 'user', 'email']) and 'password' not in name.lower():
                        form_data[name] = username
                        print(f"  Setting username field '{name}' = '{username}'")
                    elif any(keyword in name.lower() for keyword in ['password', 'pass']):
                        form_data[name] = password
                        print(f"  Setting password field '{name}' = '[REDACTED]'")
                    else:
                        # Preserve ALL other fields (hidden, tokens, etc.)
                        form_data[name] = value
                        if input_type == 'hidden' and value:
                            print(f"  Preserving hidden field '{name}' = '{value}'")
                        elif value:
                            print(f"  Preserving field '{name}' = '{value}' (type: {input_type})")
            
            # Also check for select and textarea elements
            for element in login_form.find_all(['select', 'textarea']):
                name = element.get('name', '')
                if name:
                    if element.name == 'select':
                        selected = element.find('option', selected=True)
                        value = selected.get('value', '') if selected else ''
                    else:
                        value = element.get_text()
                    form_data[name] = value
                    print(f"  Preserving {element.name} field '{name}' = '{value}'")
            
            # Submit login form
            form_action = login_form.get('action', '')
            if not form_action.startswith('http'):
                form_action = urljoin(str(login_page.url), form_action)
            
            print(f"Submitting login to: {form_action}")
            print(f"Form data keys: {list(form_data.keys())}")
            
            # Use proper headers for form submission
            login_headers = headers.copy()
            login_headers.update({
                'Content-Type': 'application/x-www-form-urlencoded',
                'Origin': f"{login_page.url.scheme}://{login_page.url.host}",
                'Referer': str(login_page.url),
            })
            
            login_response = await client.post(form_action, data=form_data, headers=login_headers)
            
            # Check if login was successful by looking for authenticated content
            authenticated_soup = BeautifulSoup(login_response.text, 'html.parser')
            page_title = authenticated_soup.title.get_text() if authenticated_soup.title else 'No title'
            
            # Look for signs of successful authentication
            is_authenticated = any(keyword in page_title.lower() for keyword in ['account', 'dashboard', 'home', 'welcome']) or \
                              any(keyword in login_response.text.lower() for keyword in ['logout', 'sign out', 'dashboard'])
            
            if not is_authenticated:
                print(f"❌ Authentication may have failed. Page title: {page_title}")
                print(f"Response URL: {login_response.url}")
                return []
            
            print(f"✅ Successfully authenticated! Page: {page_title}")
            
            # Step 4: Now look for Track UFOs in the authenticated interface
            print(f"\nStep 4: Looking for Track UFOs in authenticated interface...")
            
            # Calculate date range for search
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days_back)
            print(f"Will search from {start_date.strftime('%m/%d/%Y')} to {end_date.strftime('%m/%d/%Y')}")
            
            # Look for Track UFOs or database search links
            track_ufo_links = []
            for link in authenticated_soup.find_all('a', href=True):
                text = link.get_text().lower().strip()
                href = link.get('href')
                
                if any(keyword in text for keyword in ['track ufo', 'search database', 'database', 'search case', 'case search']):
                    # Skip javascript links
                    if not href.startswith('javascript:') and not href.startswith('#'):
                        track_ufo_links.append({
                            'text': link.get_text().strip(),
                            'href': href,
                            'full_url': urljoin(str(login_response.url), href)
                        })
            
            print(f"Found {len(track_ufo_links)} Track UFOs/database links:")
            for link in track_ufo_links:
                print(f"  - '{link['text']}' → {link['href']}")
            
            if not track_ufo_links:
                print("❌ No Track UFOs or database search links found in authenticated interface")
                return []
            
            # Find the actual SEARCH DATABASE link (not research/underwriting pages)
            search_db_link = None
            for link in track_ufo_links:
                if 'search database' in link['text'].lower() and 'z2systems.com' in link['full_url']:
                    search_db_link = link
                    break
            
            if not search_db_link:
                # Fallback to first link
                search_db_link = track_ufo_links[0]
            
            track_url = search_db_link['full_url']
            print(f"Following SEARCH DATABASE link: {track_url}")
            
            # Follow all redirects like a real browser
            current_url = track_url
            redirect_count = 0
            max_redirects = 10
            
            while redirect_count < max_redirects:
                print(f"Navigating to: {current_url}")
                response = await client.get(current_url)
                
                if response.status_code != 200:
                    print(f"❌ Could not access page: {response.status_code}")
                    return []
                
                soup = BeautifulSoup(response.text, 'html.parser')
                title = soup.title.get_text() if soup.title else 'No title'
                print(f"✅ Page loaded: {title}")
                
                # Debug: Print some of the page content to see what's actually there
                if 'z2systems.com' in current_url:
                    page_preview = soup.get_text()[:1000]
                    print(f"DEBUG - Page content preview:\n{page_preview}\n")
                    
                    # Look for any forms on this page
                    all_forms = soup.find_all('form')
                    print(f"DEBUG - Found {len(all_forms)} forms on z2systems page:")
                    for i, form in enumerate(all_forms):
                        action = form.get('action', 'No action')
                        inputs = form.find_all(['input', 'select', 'textarea'])
                        print(f"  Form {i+1}: action='{action}', {len(inputs)} inputs")
                        for inp in inputs[:3]:  # Show first 3 inputs
                            name = inp.get('name', 'unnamed')
                            inp_type = inp.get('type', inp.name)
                            print(f"    - {inp_type}: {name}")
                
                # Check if this page has the search form we need
                search_forms = []
                for form in soup.find_all('form'):
                    action = form.get('action', '').lower()
                    inputs = form.find_all(['input', 'select', 'textarea'])
                    
                    # Special handling for z2systems forms - the link.do form with choice field is the search
                    if 'z2systems.com' in current_url and '/np/constituent/link.do' in action:
                        # Check if it has a choice select field - this is the search form
                        has_choice_field = any(inp.get('name') == 'choice' for inp in inputs)
                        if has_choice_field:
                            search_forms.append(form)
                            print(f"Found z2systems search form with choice field!")
                    else:
                        # Regular form detection for other pages
                        has_date_fields = any('date' in inp.get('name', '').lower() for inp in inputs)
                        has_search_fields = any(any(term in inp.get('name', '').lower() for term in ['search', 'case', 'sighting', 'report', 'query']) for inp in inputs)
                        
                        # Skip obvious non-search forms
                        skip_actions = ['signin', 'contact', 'newsletter', 'underwriting']
                        if not any(skip_term in action for skip_term in skip_actions):
                            if has_date_fields or has_search_fields or len(inputs) >= 5:
                                search_forms.append(form)
                
                if search_forms:
                    print(f"Found {len(search_forms)} potential search forms on this page!")
                    print("✅ Found the actual database search form - using this page")
                    # We found the search page, break out of redirect loop
                    track_response = response
                    track_soup = soup
                    # Save the found forms for later use
                    found_search_forms = search_forms
                    break
                
                # Look for SPECIFIC database search redirects, not general site links
                redirect_links = []
                
                # First, check if we're on a page that should have the actual search form
                page_text = soup.get_text().lower()
                if any(indicator in page_text for indicator in ['case search', 'database search', 'sighting search', 'search cases']):
                    # This might already be the search page, don't redirect
                    print("This page mentions case/database search - might be the right page")
                else:
                    # Look for specific database/search links that go to different domains or have search in URL
                    for link in soup.find_all('a', href=True):
                        text = link.get_text().lower().strip()
                        href = link.get('href').lower()
                        
                        # Look for links that specifically mention database/search and go somewhere different
                        if ('database' in text or 'search' in text) and ('search' in href or 'database' in href or 'cms' in href):
                            # Skip the same link we just followed
                            full_url = urljoin(str(response.url), link.get('href'))
                            if full_url != current_url:
                                redirect_links.append({
                                    'text': text,
                                    'href': link.get('href'),
                                    'full_url': full_url
                                })
                
                # Also check for meta refresh or javascript redirects
                meta_refresh = soup.find('meta', attrs={'http-equiv': 'refresh'})
                if meta_refresh:
                    content = meta_refresh.get('content', '')
                    if 'url=' in content.lower():
                        redirect_url = content.split('url=', 1)[1]
                        redirect_links.append({
                            'text': 'Meta Refresh',
                            'href': redirect_url,
                            'full_url': urljoin(str(response.url), redirect_url)
                        })
                
                if redirect_links:
                    print(f"Found {len(redirect_links)} potential redirects:")
                    for link in redirect_links:
                        print(f"  - '{link['text']}' → {link['href']}")
                    
                    # Follow the first redirect
                    current_url = redirect_links[0]['full_url']
                    redirect_count += 1
                else:
                    # No more redirects found, use this page
                    track_response = response
                    track_soup = soup
                    break
            
            if redirect_count >= max_redirects:
                print(f"❌ Too many redirects ({max_redirects}), stopping")
                return []
            
            # Use the forms found during the redirect loop
            if 'found_search_forms' in locals() and found_search_forms:
                print(f"✅ Using search form found during navigation with {len(found_search_forms[0].find_all(['input', 'select', 'textarea']))} inputs")
                search_form = found_search_forms[0]
                current_page_soup = track_soup
            else:
                print("❌ No search forms found during navigation")
                return []
            
            # Step 6: Submit the search form with date range
            print(f"\nStep 6: Submitting search form with date range...")
            
            form_data = {}
            inputs = search_form.find_all(['input', 'select', 'textarea'])
            
            print(f"Form has {len(inputs)} inputs:")
            for inp in inputs[:10]:  # Show first 10 inputs
                name = inp.get('name', 'unnamed')
                input_type = inp.get('type', inp.name)
                value = inp.get('value', '')
                print(f"  - {input_type}: {name} = '{value}'")
                
                # If this is the choice select field, show all options
                if name == 'choice' and inp.name == 'select':
                    print(f"    🎯 CHOICE FIELD OPTIONS:")
                    options = inp.find_all('option')
                    for i, option in enumerate(options):
                        opt_value = option.get('value', '')
                        opt_text = option.get_text().strip()
                        selected = 'selected' if option.get('selected') else ''
                        print(f"      {i+1}. value='{opt_value}' text='{opt_text}' {selected}")
                    
                    # Select the "Last 20 Reports" option for actual case data
                    search_option = None
                    for option in options:
                        opt_text = option.get_text().strip()
                        opt_value = option.get('value', '')
                        if 'last 20 reports' in opt_text.lower() or 'mufoncms.com/last_20' in opt_value.lower():
                            search_option = opt_value
                            print(f"    ✅ Found Last 20 Reports option: '{search_option}' = '{opt_text}'")
                            break
            
            # Build form data
            for inp in inputs:
                name = inp.get('name')
                if not name:
                    continue
                    
                input_type = inp.get('type', inp.name)
                value = inp.get('value', '')
                
                if 'date' in name.lower():
                    if any(keyword in name.lower() for keyword in ['from', 'start', 'begin']):
                        form_data[name] = start_date.strftime('%m/%d/%Y')
                        print(f"Set {name} = {start_date.strftime('%m/%d/%Y')}")
                    elif any(keyword in name.lower() for keyword in ['to', 'end', 'until']):
                        form_data[name] = end_date.strftime('%m/%d/%Y')
                        print(f"Set {name} = {end_date.strftime('%m/%d/%Y')}")
                    else:
                        form_data[name] = value
                elif input_type == 'hidden':
                    form_data[name] = value
                elif 'limit' in name.lower() or 'count' in name.lower():
                    form_data[name] = str(limit)
                elif input_type in ['checkbox', 'radio'] and value:
                    # Use default values for checkboxes/radios
                    form_data[name] = value
                elif not value and input_type in ['text', 'email', 'number']:
                    # Leave text fields empty unless we have a specific value
                    form_data[name] = ''
            
            # Submit the search form
            form_action = search_form.get('action', '')
            if not form_action.startswith('http'):
                base_url = str(search_response.url) if 'search_response' in locals() else str(track_response.url)
                form_action = urljoin(base_url, form_action)
            
            print(f"Submitting search to: {form_action}")
            print(f"Form data: {dict(list(form_data.items())[:5])}...")  # Show first 5 items
            
            results_response = await client.post(form_action, data=form_data)
            if results_response.status_code != 200:
                print(f"❌ Search form submission failed: {results_response.status_code}")
                return []
            
            results_soup = BeautifulSoup(results_response.text, 'html.parser')
            print(f"✅ Search results page loaded: {results_soup.title.get_text() if results_soup.title else 'No title'}")
            
            # Parse the search results
            reports = await _parse_detailed_reports(results_soup, limit, client, list_only)
            print(f"Found {len(reports)} reports from user navigation flow")
            
            return reports
            
        except Exception as e:
            print(f"Error in user navigation flow: {e}")
            return []


async def _parse_detailed_reports(soup: BeautifulSoup, limit: int, client: httpx.AsyncClient, list_only: bool = False) -> List[Dict[str, Any]]:
    """Parse detailed reports from search results page"""
    reports = []
    
    print("Parsing search results...")
    
    # Look for different result structures
    result_patterns = [
        # Table rows - most common format
        soup.find_all('tr'),
        # Div containers with case info
        soup.find_all('div', class_=re.compile(r'(case|result|report|sighting)', re.I)),
        # List items
        soup.find_all('li'),
        # Paragraph blocks containing case data
        soup.find_all('p')
    ]
    
    for pattern_name, elements in zip(['table rows', 'divs', 'list items', 'paragraphs'], result_patterns):
        if reports:  # Skip if we already found data
            break
            
        print(f"Checking {len(elements)} {pattern_name} for case data...")
        
        for element in elements:
            try:
                text = element.get_text().strip()
                
                # Skip empty or very short text
                if len(text) < 20:
                    continue
                
                # Look for case number patterns
                case_patterns = [
                    r'case[#\s]*(\d{4,6})',  # Case #123456 or Case 123456
                    r'#(\d{4,6})',           # #123456
                    r'\b(\d{4,6})\b',        # Standalone 4-6 digit number
                ]
                
                case_number = None
                for pattern in case_patterns:
                    match = re.search(pattern, text, re.I)
                    if match:
                        case_number = match.group(1)
                        break
                
                if case_number:
                    print(f"Found case: {case_number}")
                    
                    case_data = {
                        'case_number': case_number,
                        'raw_text': text,
                        'source': 'MUFON_CMS',
                        'scraped_at': datetime.now().isoformat()
                    }
                    
                    # Extract date patterns
                    date_patterns = [
                        r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',  # MM/DD/YYYY or MM-DD-YYYY
                        r'(\d{4}[/-]\d{1,2}[/-]\d{1,2})',    # YYYY/MM/DD or YYYY-MM-DD
                        r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{1,2},? \d{4}', # January 1, 2023
                    ]
                    
                    for pattern in date_patterns:
                        date_match = re.search(pattern, text, re.I)
                        if date_match:
                            case_data['date'] = date_match.group(1)
                            break
                    
                    # Extract location (City, State pattern)
                    location_patterns = [
                        r'([A-Za-z\s]+),\s*([A-Z]{2})\b',     # City, ST
                        r'([A-Za-z\s]+),\s*([A-Za-z\s]+)',   # City, State/Country
                    ]
                    
                    for pattern in location_patterns:
                        location_match = re.search(pattern, text)
                        if location_match:
                            case_data['city'] = location_match.group(1).strip()
                            case_data['state_country'] = location_match.group(2).strip()
                            break
                    
                    # Look for description - usually in cells or child elements
                    description_candidates = []
                    
                    # Check table cells
                    if element.name == 'tr':
                        cells = element.find_all(['td', 'th'])
                        for cell in cells:
                            cell_text = cell.get_text().strip()
                            if len(cell_text) > 30 and not re.match(r'^\d+$', cell_text):  # Not just a number
                                description_candidates.append(cell_text)
                    
                    # Use longest text as description
                    if description_candidates:
                        case_data['description'] = max(description_candidates, key=len)
                    else:
                        case_data['description'] = text[:500]  # First 500 chars
                    
                    # Generate unique hash for deduplication
                    hash_content = f"{case_data.get('case_number', '')}{case_data.get('date', '')}{case_data.get('description', '')[:100]}"
                    case_data['hash'] = hashlib.md5(hash_content.encode()).hexdigest()
                    
                    reports.append(case_data)
                    
                    if len(reports) >= limit:
                        break
                        
            except Exception as e:
                print(f"Error parsing element: {e}")
                continue
        
        if reports:
            print(f"Found {len(reports)} cases in {pattern_name}")
    
    # If no structured data found, try to parse the entire page text
    if not reports:
        print("No structured data found, parsing page text...")
        page_text = soup.get_text()
        
        # Look for case numbers in the entire text
        case_matches = re.finditer(r'case[#\s]*(\d{4,6})', page_text, re.I)
        for match in case_matches:
            case_number = match.group(1)
            
            # Extract surrounding context (±200 chars)
            start = max(0, match.start() - 200)
            end = min(len(page_text), match.end() + 200)
            context = page_text[start:end].strip()
            
            case_data = {
                'case_number': case_number,
                'description': context,
                'source': 'MUFON_CMS_TEXT',
                'scraped_at': datetime.now().isoformat()
            }
            
            hash_content = f"{case_number}{context[:100]}"
            case_data['hash'] = hashlib.md5(hash_content.encode()).hexdigest()
            
            reports.append(case_data)
            
            if len(reports) >= limit:
                break
    
    print(f"Total cases parsed: {len(reports)}")
    
    # Store to database
    if reports:
        await _store_to_database(reports)
    
    return reports


async def _store_to_database(reports: List[Dict[str, Any]]):
    """Store reports to UFOBeep database"""
    try:
        import asyncpg
        
        conn = await asyncpg.connect(
            host='localhost',
            database='ufobeep_db',
            user='ufobeep_user',
            password='ufopostpass'
        )
        
        # Create table if not exists
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS mufon_cases (
                id SERIAL PRIMARY KEY,
                case_number VARCHAR(50),
                date VARCHAR(50),
                city VARCHAR(100),
                state_country VARCHAR(100),
                description TEXT,
                raw_text TEXT,
                source VARCHAR(50),
                hash VARCHAR(32) UNIQUE,
                scraped_at TIMESTAMP,
                created_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        
        # Insert reports
        inserted_count = 0
        for report in reports:
            try:
                await conn.execute('''
                    INSERT INTO mufon_cases (case_number, date, city, state_country, description, raw_text, source, hash, scraped_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9)
                    ON CONFLICT (hash) DO NOTHING
                ''', 
                report.get('case_number'),
                report.get('date'),
                report.get('city'),
                report.get('state_country'),
                report.get('description'),
                report.get('raw_text'),
                report.get('source'),
                report.get('hash'),
                datetime.fromisoformat(report.get('scraped_at'))
                )
                inserted_count += 1
            except Exception as e:
                print(f"Error inserting report {report.get('case_number', 'unknown')}: {e}")
        
        await conn.close()
        print(f"Successfully stored {inserted_count} new reports to database")
        
    except Exception as e:
        print(f"Database error: {e}")

if __name__ == "__main__":
    # Test the authenticated client
    reports = asyncio.run(fetch_authenticated_reports(limit=5, days_back=1))
    for report in reports:
        print(f"Report: {report.get('title', 'No title')}")