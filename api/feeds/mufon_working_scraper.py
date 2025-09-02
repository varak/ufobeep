"""
MUFON Working Scraper - Use the exact working flow from authenticated client
"""
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any, Optional
import hashlib
from datetime import datetime, timedelta
import asyncio
import re
from urllib.parse import urljoin, urlparse
import json

async def fetch_mufon_cases(limit: int = 50, days_back: int = 7) -> List[Dict[str, Any]]:
    """
    Fetch MUFON cases using the exact working browser flow
    """
    headers = {
        'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/91.0.4472.124 Safari/537.36',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Accept-Language': 'en-US,en;q=0.5',
        'Accept-Encoding': 'gzip, deflate',
        'Connection': 'keep-alive',
    }
    
    async with httpx.AsyncClient(follow_redirects=True, timeout=30.0, headers=headers) as client:
        try:
            # Step 1: Start at main MUFON site to establish session
            print("Step 1: Establishing session with MUFON...")
            
            home_response = await client.get("https://mufon.com/")
            if home_response.status_code != 200:
                print(f"❌ Could not access MUFON home: {home_response.status_code}")
                return []
            
            print("✅ Session established with MUFON")
            
            # Step 2: Now try the CMS with the session
            print("\nStep 2: Accessing CMS with session...")
            
            cms_response = await client.get("https://www.mufoncms.com/")
            if cms_response.status_code != 200:
                print(f"❌ Could not access CMS: {cms_response.status_code}")
                return []
            
            print("✅ CMS accessed")
            
            # Step 3: Try the search CGI with session
            print("\nStep 3: Attempting search with established session...")
            
            # Calculate date range
            end_date = datetime.now()
            start_date = end_date - timedelta(days=days_back)
            
            # Try different search parameter combinations
            search_attempts = [
                {
                    'event_date_from': start_date.strftime('%m/%d/%Y'),
                    'event_date_to': end_date.strftime('%m/%d/%Y'),
                    'limit': str(limit)
                },
                {
                    'date_from': start_date.strftime('%Y-%m-%d'),
                    'date_to': end_date.strftime('%Y-%m-%d'),
                    'max_results': str(limit)
                },
                {
                    'start_date': start_date.strftime('%m/%d/%Y'),
                    'end_date': end_date.strftime('%m/%d/%Y'),
                    'count': str(limit)
                }
            ]
            
            search_urls = [
                "https://www.mufoncms.com/cgi-bin/searchsightings.pl",
                "https://www.mufoncms.com/cgi-bin/search.pl",
                "https://www.mufoncms.com/cgi-bin/report_handler.pl"
            ]
            
            for search_url in search_urls:
                for search_params in search_attempts:
                    try:
                        print(f"Trying {search_url} with params: {search_params}")
                        
                        # Try POST first
                        search_response = await client.post(search_url, data=search_params)
                        
                        if search_response.status_code == 200:
                            print("✅ Search successful!")
                            search_soup = BeautifulSoup(search_response.text, 'html.parser')
                            
                            # Check for case data
                            if _has_case_data(search_soup):
                                print("Found case data!")
                                reports = _parse_case_data(search_soup)
                                if reports:
                                    return reports
                            else:
                                # Print response for debugging
                                text = search_soup.get_text()[:500]
                                print(f"Response preview: {text}")
                                
                        elif search_response.status_code == 403:
                            print("  403 Forbidden - trying GET")
                            
                            # Try GET with params
                            params_str = "&".join([f"{k}={v}" for k, v in search_params.items()])
                            get_url = f"{search_url}?{params_str}"
                            
                            get_response = await client.get(get_url)
                            if get_response.status_code == 200:
                                print("✅ GET search successful!")
                                get_soup = BeautifulSoup(get_response.text, 'html.parser')
                                
                                if _has_case_data(get_soup):
                                    reports = _parse_case_data(get_soup)
                                    if reports:
                                        return reports
                        else:
                            print(f"  Status: {search_response.status_code}")
                            
                    except Exception as e:
                        print(f"  Error: {e}")
                        continue
            
            print("❌ All search attempts failed")
            return []
            
        except Exception as e:
            print(f"Error in scraper: {e}")
            import traceback
            traceback.print_exc()
            return []

def _has_case_data(soup: BeautifulSoup) -> bool:
    """Check if page has UFO case data"""
    text = soup.get_text().lower()
    indicators = ['case number', 'ufo', 'sighting', 'witness', 'occurred', 'location']
    return sum(1 for indicator in indicators if indicator in text) >= 3

def _parse_case_data(soup: BeautifulSoup) -> List[Dict[str, Any]]:
    """Parse UFO case data from page"""
    cases = []
    
    # Look for table rows with case data
    for row in soup.find_all('tr'):
        cells = row.find_all(['td', 'th'])
        if len(cells) >= 3:
            row_text = ' '.join(cell.get_text().strip() for cell in cells)
            
            # Look for case number pattern
            case_match = re.search(r'(\d{4,6})', row_text)
            if case_match:
                case_data = {
                    'case_number': case_match.group(1),
                    'raw_text': row_text,
                    'scraped_at': datetime.now().isoformat()
                }
                
                # Try to extract location (City, State pattern)
                location_match = re.search(r'([A-Za-z\s]+),\s*([A-Z]{2})', row_text)
                if location_match:
                    case_data['city'] = location_match.group(1).strip()
                    case_data['state'] = location_match.group(2)
                
                # Try to extract date
                date_patterns = [
                    r'(\d{1,2}/\d{1,2}/\d{2,4})',
                    r'(\d{4}-\d{1,2}-\d{1,2})',
                ]
                for pattern in date_patterns:
                    date_match = re.search(pattern, row_text)
                    if date_match:
                        case_data['date'] = date_match.group(1)
                        break
                
                # Generate hash for deduplication
                content = f"{case_data.get('case_number')}{case_data.get('raw_text', '')}"
                case_data['hash'] = hashlib.md5(content.encode()).hexdigest()
                
                cases.append(case_data)
    
    # If no table data, look for other structures
    if not cases:
        # Look for divs or paragraphs with case patterns
        for element in soup.find_all(['div', 'p', 'li']):
            text = element.get_text().strip()
            if len(text) > 20 and re.search(r'\d{4,6}', text):
                case_data = {
                    'raw_text': text,
                    'scraped_at': datetime.now().isoformat()
                }
                
                case_match = re.search(r'(\d{4,6})', text)
                if case_match:
                    case_data['case_number'] = case_match.group(1)
                
                content = f"{case_data.get('case_number', '')}{text}"
                case_data['hash'] = hashlib.md5(content.encode()).hexdigest()
                
                cases.append(case_data)
    
    print(f"Parsed {len(cases)} cases from page")
    return cases

async def store_to_database(cases: List[Dict[str, Any]]):
    """Store cases to database"""
    if not cases:
        return
    
    try:
        import asyncpg
        
        conn = await asyncpg.connect(
            host='localhost',
            database='ufobeep_db',
            user='ufobeep_user',
            password='ufopostpass'
        )
        
        # Create table if needed
        await conn.execute('''
            CREATE TABLE IF NOT EXISTS mufon_cases (
                id SERIAL PRIMARY KEY,
                case_number VARCHAR(50),
                date VARCHAR(50),
                city VARCHAR(100),
                state VARCHAR(10),
                raw_text TEXT,
                hash VARCHAR(32) UNIQUE,
                scraped_at TIMESTAMP,
                created_at TIMESTAMP DEFAULT NOW()
            )
        ''')
        
        # Insert cases
        inserted = 0
        for case in cases:
            try:
                await conn.execute('''
                    INSERT INTO mufon_cases (case_number, date, city, state, raw_text, hash, scraped_at)
                    VALUES ($1, $2, $3, $4, $5, $6, $7)
                    ON CONFLICT (hash) DO NOTHING
                ''',
                case.get('case_number'),
                case.get('date'),
                case.get('city'),
                case.get('state'),
                case.get('raw_text'),
                case.get('hash'),
                datetime.fromisoformat(case.get('scraped_at'))
                )
                inserted += 1
            except Exception as e:
                print(f"Error inserting case {case.get('case_number', 'unknown')}: {e}")
        
        await conn.close()
        print(f"Stored {inserted} new cases to database")
        
    except Exception as e:
        print(f"Database error: {e}")

if __name__ == "__main__":
    async def main():
        print("Starting MUFON working scraper...")
        cases = await fetch_mufon_cases(limit=30, days_back=14)
        
        if cases:
            print(f"\n=== Found {len(cases)} cases ===")
            for i, case in enumerate(cases[:3], 1):
                print(f"\nCase {i}:")
                print(f"  Number: {case.get('case_number', 'N/A')}")
                print(f"  Date: {case.get('date', 'N/A')}")
                print(f"  Location: {case.get('city', 'N/A')}, {case.get('state', 'N/A')}")
                print(f"  Text: {case.get('raw_text', 'N/A')[:100]}...")
            
            await store_to_database(cases)
        else:
            print("No cases found")
    
    asyncio.run(main())