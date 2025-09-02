"""
MUFON Direct Public Scraper - Use browser emulation to access search database
Emulates the browser flow from the working authenticated client but targets public access
"""
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any, Optional
import hashlib
from datetime import datetime, timedelta
import asyncio
import re
from geopy.geocoders import Nominatim
import os
from urllib.parse import urljoin, urlparse
import json

async def fetch_public_reports(limit: int = 50, days_back: int = 7) -> List[Dict[str, Any]]:
    """
    Fetch MUFON reports using browser emulation approach from authenticated client
    But try to find public access points to the search database
    """
    # Browser-like headers
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
    }
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0, headers=headers) as client:
        try:
            # Use the working CMS interface directly
            cms_url = "https://www.mufoncms.com/"
            print(f"Accessing MUFON CMS: {cms_url}")
            
            response = await client.get(cms_url)
            if response.status_code != 200:
                print(f"❌ Could not access CMS: {response.status_code}")
                return []
            
            soup = BeautifulSoup(response.text, 'html.parser')
            title = soup.title.get_text() if soup.title else 'No title'
            print(f"✅ CMS loaded: {title}")
            
            # Try to submit directly to the searchsightings CGI with public parameters
            search_url = "https://www.mufoncms.com/cgi-bin/searchsightings.pl"
            print(f"Attempting direct search submission to: {search_url}")
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days_back)
            
            # Build search parameters for public data
            search_data = {
                'event_date_from': start_date.strftime('%m/%d/%Y'),
                'event_date_to': end_date.strftime('%m/%d/%Y'),
                'limit': str(limit),
                'public_only': '1',
                'format': 'html',
                'search': 'Search'
            }
            
            print(f"Submitting search data: {search_data}")
            
            # Try POST request to search
            search_response = await client.post(search_url, data=search_data)
            
            if search_response.status_code == 200:
                print("✅ Search successful!")
                search_soup = BeautifulSoup(search_response.text, 'html.parser')
                
                if _has_case_data(search_soup):
                    print("Found case data in results")
                    reports = await _parse_search_results(search_soup, client)
                    if reports:
                        return reports
                else:
                    print("No case data found, trying alternative parsing...")
                    # Print first 500 chars to debug
                    text_preview = search_soup.get_text()[:500]
                    print(f"Page preview: {text_preview}")
            else:
                print(f"Search failed with status: {search_response.status_code}")
                
                # Try with GET parameters
                print("Trying GET request with parameters...")
                params = "&".join([f"{k}={v}" for k, v in search_data.items()])
                get_url = f"{search_url}?{params}"
                
                get_response = await client.get(get_url)
                if get_response.status_code == 200:
                    print("✅ GET search successful!")
                    get_soup = BeautifulSoup(get_response.text, 'html.parser')
                    
                    if _has_case_data(get_soup):
                        reports = await _parse_search_results(get_soup, client)
                        if reports:
                            return reports
                else:
                    print(f"GET search also failed: {get_response.status_code}")
            
            print("❌ No working database links found")
            return []
            
        except Exception as e:
            print(f"Error in MUFON scraper flow: {e}")
            import traceback
            traceback.print_exc()
            return []


def _has_case_data(soup: BeautifulSoup) -> bool:
    """Check if the page contains UFO case data"""
    text = soup.get_text().lower()
    case_indicators = ['case number', 'ufo', 'sighting', 'report', 'date occurred', 'witness']
    return sum(1 for indicator in case_indicators if indicator in text) >= 3


def _find_search_forms(soup: BeautifulSoup) -> List[Any]:
    """Find forms that look like search forms"""
    search_forms = []
    for form in soup.find_all('form'):
        inputs = form.find_all(['input', 'select', 'textarea'])
        
        # Look for date fields, search fields, or multiple inputs
        has_date_field = any('date' in inp.get('name', '').lower() for inp in inputs)
        has_search_field = any('search' in inp.get('name', '').lower() for inp in inputs)
        has_multiple_inputs = len(inputs) >= 3
        
        if has_date_field or has_search_field or has_multiple_inputs:
            search_forms.append(form)
    
    return search_forms


async def _try_search_forms(forms: List[Any], client: httpx.AsyncClient, base_url: str, limit: int, days_back: int) -> List[Dict[str, Any]]:
    """Try to submit search forms and get results"""
    end_date = datetime.now()
    start_date = end_date - timedelta(days=days_back)
    
    for form in forms:
        try:
            print(f"Trying search form...")
            
            # Build form data
            form_data = {}
            inputs = form.find_all(['input', 'select', 'textarea'])
            
            for inp in inputs:
                name = inp.get('name')
                if not name:
                    continue
                    
                input_type = inp.get('type', inp.name)
                value = inp.get('value', '')
                
                if 'date' in name.lower():
                    if any(keyword in name.lower() for keyword in ['from', 'start', 'begin']):
                        form_data[name] = start_date.strftime('%m/%d/%Y')
                    elif any(keyword in name.lower() for keyword in ['to', 'end', 'until']):
                        form_data[name] = end_date.strftime('%m/%d/%Y')
                    else:
                        form_data[name] = value
                elif input_type == 'hidden':
                    form_data[name] = value
                elif 'limit' in name.lower() or 'count' in name.lower():
                    form_data[name] = str(limit)
                elif input_type in ['checkbox', 'radio'] and value:
                    form_data[name] = value
                else:
                    form_data[name] = value if value else ''
            
            # Submit form
            form_action = form.get('action', '')
            if not form_action.startswith('http'):
                form_action = urljoin(str(base_url), form_action)
            
            print(f"Submitting to: {form_action}")
            response = await client.post(form_action, data=form_data)
            
            if response.status_code == 200:
                results_soup = BeautifulSoup(response.text, 'html.parser')
                if _has_case_data(results_soup):
                    reports = await _parse_search_results(results_soup, client)
                    if reports:
                        return reports
                        
        except Exception as e:
            print(f"Form submission failed: {e}")
            continue
    
    return []


async def _parse_search_results(soup: BeautifulSoup, client: httpx.AsyncClient) -> List[Dict[str, Any]]:
    """
    Parse MUFON search results page to extract case data
    """
    reports = []
    
    # Look for different possible result structures
    result_patterns = [
        # Table rows
        soup.find_all('tr'),
        # Div containers with case data
        soup.find_all('div', class_=re.compile(r'case|result|report', re.I)),
        # List items
        soup.find_all('li'),
        # Paragraph blocks
        soup.find_all('p')
    ]
    
    for pattern_results in result_patterns:
        for element in pattern_results:
            text = element.get_text().strip()
            
            # Look for case number patterns
            case_match = re.search(r'case[#\s]*(\d+)', text, re.I)
            if case_match:
                case_data = await _extract_case_data(element, text)
                if case_data:
                    reports.append(case_data)
        
        if reports:  # If we found results with one pattern, use those
            break
    
    return reports


async def _extract_case_data(element, text: str) -> Optional[Dict[str, Any]]:
    """
    Extract case data from a result element
    """
    try:
        case_data = {}
        
        # Extract case number
        case_match = re.search(r'case[#\s]*(\d+)', text, re.I)
        if case_match:
            case_data['case_number'] = case_match.group(1)
        
        # Extract dates
        date_patterns = [
            r'(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})',
            r'(\d{4}-\d{1,2}-\d{1,2})',
            r'(jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)[a-z]* \d{1,2},? \d{4}',
        ]
        
        for pattern in date_patterns:
            date_match = re.search(pattern, text, re.I)
            if date_match:
                case_data['date'] = date_match.group(1)
                break
        
        # Extract location (city, state pattern)
        location_match = re.search(r'([A-Za-z\s]+),\s*([A-Z]{2})', text)
        if location_match:
            case_data['city'] = location_match.group(1).strip()
            case_data['state'] = location_match.group(2).strip()
        
        # Extract description (usually the longest text block)
        description_candidates = []
        for descendant in element.descendants:
            if hasattr(descendant, 'get_text'):
                desc_text = descendant.get_text().strip()
                if len(desc_text) > 50 and desc_text != text:
                    description_candidates.append(desc_text)
        
        if description_candidates:
            case_data['description'] = max(description_candidates, key=len)
        else:
            # Use the full text as description if nothing else found
            case_data['description'] = text
        
        # Generate unique hash for the case
        case_content = f"{case_data.get('case_number', '')}{case_data.get('date', '')}{case_data.get('description', '')}"
        case_data['hash'] = hashlib.md5(case_content.encode()).hexdigest()
        
        # Add timestamp
        case_data['scraped_at'] = datetime.now().isoformat()
        
        return case_data if case_data.get('case_number') else None
        
    except Exception as e:
        print(f"Error extracting case data: {e}")
        return None


async def store_reports_to_database(reports: List[Dict[str, Any]]):
    """
    Store the scraped reports to the UFOBeep database
    """
    if not reports:
        print("No reports to store")
        return
    
    try:
        import asyncpg
        
        # Database connection
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
                state VARCHAR(10),
                description TEXT,
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
                    INSERT INTO mufon_cases (case_number, date, city, state, description, hash, scraped_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7)
                    ON CONFLICT (hash) DO NOTHING
                ''', 
                report.get('case_number'),
                report.get('date'),
                report.get('city'),
                report.get('state'), 
                report.get('description'),
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
    # Test the scraper
    async def main():
        print("Starting MUFON direct scraper...")
        reports = await fetch_public_reports(limit=20, days_back=7)
        
        if reports:
            print(f"\n=== Found {len(reports)} reports ===")
            for i, report in enumerate(reports[:3], 1):
                print(f"\nReport {i}:")
                print(f"  Case: {report.get('case_number', 'N/A')}")
                print(f"  Date: {report.get('date', 'N/A')}")
                print(f"  Location: {report.get('city', 'N/A')}, {report.get('state', 'N/A')}")
                print(f"  Description: {report.get('description', 'N/A')[:100]}...")
            
            # Store to database
            await store_reports_to_database(reports)
        else:
            print("No reports found")
    
    asyncio.run(main())