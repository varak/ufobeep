"""
MUFON Case Processor - Individual case processing with media support
"""
import httpx
import asyncpg
from bs4 import BeautifulSoup
from typing import Dict, Any, Optional, List
import uuid
from datetime import datetime
import re

async def get_case_list() -> List[Dict[str, Any]]:
    """Get list of recent MUFON cases without processing details"""
    async with httpx.AsyncClient(timeout=10.0) as client:
        response = await client.get("https://mufoncms.com/last_20_public.html")
        soup = BeautifulSoup(response.text, 'html.parser')
        
        cases = []
        table = soup.find('table')
        if table:
            rows = table.find_all('tr')[1:]  # Skip header
            for row in rows[:20]:  # Limit to 20 cases
                cells = row.find_all('td')
                if len(cells) >= 4:
                    # Extract case URL and ID
                    link = cells[0].find('a')
                    if link and link.get('href'):
                        case_url = link.get('href')
                        case_id = extract_case_id_from_url(case_url)
                        
                        cases.append({
                            "case_id": case_id,
                            "url": f"https://mufoncms.com{case_url}",
                            "title": cells[0].get_text().strip(),
                            "location": cells[1].get_text().strip(),
                            "date": cells[2].get_text().strip(),
                            "shape": cells[3].get_text().strip()
                        })
        
        print(f"Found {len(cases)} MUFON cases")
        return cases

def extract_case_id_from_url(url: str) -> str:
    """Extract case ID from MUFON URL"""
    match = re.search(r'/case/(\d+)', url)
    return match.group(1) if match else url.split('/')[-1]

async def get_case_details(case_url: str) -> Optional[Dict[str, Any]]:
    """Get full details for a single MUFON case including media"""
    async with httpx.AsyncClient(timeout=30.0) as client:
        try:
            print(f"Fetching case details from: {case_url}")
            response = await client.get(case_url)
            soup = BeautifulSoup(response.text, 'html.parser')
            
            # Extract case data
            case_data = {
                "url": case_url,
                "case_id": extract_case_id_from_url(case_url),
                "title": "",
                "description": "",
                "location": "",
                "occurred_at": "",  # When sighting occurred
                "reported_at": "",  # When reported to MUFON
                "shape": "",
                "media_urls": []
            }
            
            # Extract title
            title_elem = soup.find('h1') or soup.find('h2') or soup.find('title')
            if title_elem:
                case_data["title"] = title_elem.get_text().strip()
            
            # Extract dates from various locations
            date_patterns = [
                r'occurred.*?:?\s*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})',
                r'date.*?:?\s*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})', 
                r'reported.*?:?\s*([0-9]{1,2}[/-][0-9]{1,2}[/-][0-9]{2,4})'
            ]
            
            page_text = soup.get_text().lower()
            for pattern in date_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                if matches:
                    if 'occurred' in pattern or 'date' in pattern:
                        case_data["occurred_at"] = matches[0]
                    if 'reported' in pattern:
                        case_data["reported_at"] = matches[0]
            
            # Extract location from various selectors
            location_selectors = ['td', 'span', 'div']
            for selector in location_selectors:
                for elem in soup.find_all(selector):
                    text = elem.get_text().strip()
                    if len(text) > 5 and len(text) < 100 and (',' in text or any(state in text.upper() for state in ['CA', 'TX', 'NY', 'FL', 'IL'])):
                        if not case_data["location"]:
                            case_data["location"] = text
                            break
            
            # Extract shape from page
            shape_patterns = [
                r'shape.*?:?\s*(\w+)',
                r'object.*?:?\s*(circle|disk|triangle|sphere|cylinder|oval|rectangle|diamond|other)',
            ]
            for pattern in shape_patterns:
                matches = re.findall(pattern, page_text, re.IGNORECASE)
                if matches and not case_data["shape"]:
                    case_data["shape"] = matches[0]
                    break
            
            # Extract description from various possible locations  
            description_parts = []
            
            # Look for description in divs, p tags
            for elem in soup.find_all(['div', 'p'], string=re.compile(r'.{50,}', re.DOTALL)):
                text = elem.get_text().strip()
                if len(text) > 50 and 'MUFON' not in text.upper():
                    description_parts.append(text)
            
            case_data["description"] = "\n\n".join(description_parts[:3])  # First 3 paragraphs
            
            # Extract media URLs
            for img in soup.find_all('img'):
                src = img.get('src')
                if src and ('upload' in src.lower() or 'photo' in src.lower() or 'image' in src.lower()):
                    if src.startswith('/'):
                        src = f"https://mufoncms.com{src}"
                    case_data["media_urls"].append(src)
            
            print(f"Case {case_data['case_id']}: Found {len(case_data['media_urls'])} media files")
            return case_data
            
        except Exception as e:
            print(f"Error fetching case details from {case_url}: {e}")
            return None

async def process_case_media(pool: asyncpg.Pool, sighting_id: str, media_urls: List[str]) -> Dict[str, Any]:
    """Download and process media using existing UFOBeep media system"""
    if not media_urls:
        return {}
    
    try:
        # Import existing media service
        from app.services.media_service import get_media_service
        media_service = get_media_service(pool)
        
        media_info = {"files": []}
        
        async with httpx.AsyncClient(timeout=30.0) as client:
            for i, url in enumerate(media_urls[:5]):  # Limit to 5 media files per case
                try:
                    print(f"Downloading media {i+1}/{len(media_urls[:5])}: {url}")
                    
                    # Download media
                    response = await client.get(url)
                    if response.status_code == 200:
                        # Generate filename
                        file_ext = url.split('.')[-1].lower() if '.' in url else 'jpg'
                        filename = f"mufon_{uuid.uuid4().hex[:8]}.{file_ext}"
                        
                        # Save through media service
                        media_result = await media_service.save_media(
                            sighting_id=sighting_id,
                            filename=filename,
                            content=response.content,
                            content_type=response.headers.get('content-type', 'image/jpeg')
                        )
                        
                        if media_result:
                            media_info["files"].append({
                                "filename": filename,
                                "type": "image",
                                "source_url": url,
                                "processed": True
                            })
                            print(f"✅ Saved media: {filename}")
                        
                except Exception as e:
                    print(f"Failed to process media {url}: {e}")
                    continue
        
        print(f"Successfully processed {len(media_info['files'])} media files")
        return media_info
        
    except Exception as e:
        print(f"Error processing media: {e}")
        return {}

async def insert_case_with_media(pool: asyncpg.Pool, case_data: Dict[str, Any]) -> bool:
    """Insert MUFON case with media into sightings table"""
    try:
        sighting_id = str(uuid.uuid4())
        
        # Process media first
        media_info = await process_case_media(pool, sighting_id, case_data.get("media_urls", []))
        
        # Parse occurred_at date
        occurred_at = datetime.now()
        if case_data.get("occurred_at"):
            try:
                date_str = case_data["occurred_at"]
                for fmt in ['%m/%d/%Y', '%m-%d-%Y', '%m/%d/%y', '%m-%d-%y']:
                    try:
                        occurred_at = datetime.strptime(date_str, fmt)
                        break
                    except ValueError:
                        continue
            except:
                pass
        
        # Create enhanced title with case ID
        title = case_data.get("title", "")
        if case_data.get("case_id"):
            title = f"MUFON Case #{case_data['case_id']}: {title}"
        
        # Create sighting record with both dates stored
        async with pool.acquire() as conn:
            await conn.execute("""
                INSERT INTO sightings (
                    id, title, description, category, witness_count, is_public,
                    tags, media_info, sensor_data, alert_level, status,
                    lat, lon, occurred_at, source, source_id, external_url,
                    shape, duration, raw, enrichment_data, reporter_id, firebase_uid,
                    ingestion_hash
                ) VALUES (
                    $1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13, $14, $15, $16, $17, $18, $19, $20, $21, $22, $23, $24
                ) ON CONFLICT (source, source_id) DO NOTHING
            """, 
                sighting_id,
                title[:200] or None,
                f"[MUFON Case #{case_data.get('case_id', 'N/A')}] {case_data.get('description', '')}",
                "ufo",
                1,
                True,
                ["mufon", "verified", "individual_processing"],
                media_info,
                {
                    "location": {"name": case_data.get("location", "")},
                    "source": "mufon_individual",
                    "mufon_case_id": case_data.get("case_id"),
                    "dates": {
                        "occurred": case_data.get("occurred_at", ""),
                        "reported": case_data.get("reported_at", "")
                    }
                },
                "low",
                "verified",
                39.8283,  # Default US center coords
                -98.5795,
                occurred_at,
                "mufon_auth",
                case_data.get("case_id"),
                case_data.get("url"),
                case_data.get("shape"),
                None,
                case_data,
                {"mufon_case_id": case_data.get("case_id")},
                None,
                None,
                f"mufon_{case_data.get('case_id')}_{hash(str(case_data))}"
            )
            
        print(f"✅ Inserted case {case_data.get('case_id')} with {len(media_info.get('files', []))} media files")
        return True
        
    except Exception as e:
        print(f"Failed to insert case: {e}")
        return False