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
    """Get list of recent MUFON cases using simple direct search"""
    try:
        from feeds.mufon_simple_search import simple_mufon_search
        
        print("Fetching MUFON cases using simple search...")
        reports = await simple_mufon_search(limit=20, days_back=2)
        
        if not reports:
            print("⚠️ No reports returned from MUFON simple search")
            return []
        
        cases = []
        for report in reports[:10]:  # Limit to 10 for faster processing
            case_id = report.get("case_id") or "unknown"
            cases.append({
                "case_id": str(case_id),
                "title": report.get("summary", "")[:100],
                "location": report.get("location", ""),
                "date": report.get("date", ""),
                "shape": "",  # Simple search might not have shape
                "report_data": report  # Keep full report for processing
            })
        
        print(f"✅ Found {len(cases)} MUFON cases from simple search")
        return cases
    
    except Exception as e:
        print(f"❌ MUFON simple search failed: {e}")
        return []

def extract_case_id_from_url(url: str) -> str:
    """Extract case ID from MUFON URL"""
    match = re.search(r'/case/(\d+)', url)
    return match.group(1) if match else url.split('/')[-1]

async def get_case_details(case_data: Dict[str, Any]) -> Optional[Dict[str, Any]]:
    """Get full details for a single MUFON case from authenticated CMS data"""
    try:
        report = case_data.get("report_data", {})
        case_id = case_data.get("case_id")
        
        print(f"Processing MUFON case {case_id}")
        
        # Build enhanced case data from authenticated CMS
        enhanced_case = {
            "case_id": case_id,
            "title": report.get("summary", "")[:200] or f"MUFON Case {case_id}",
            "description": report.get("summary", "") or "",
            "location": f"{report.get('city', '')}, {report.get('state', '')}".strip(", "),
            "occurred_at": report.get("occurred_date_time", ""),
            "reported_at": report.get("date_submitted", ""),
            "shape": report.get("shape", ""),
            "duration": report.get("duration", ""),
            "media_urls": [],
            "raw_report": report
        }
        
        # Try to get media from CMS if available
        media_fields = ['media_url', 'image_url', 'photo_url', 'attachment_url']
        for field in media_fields:
            if report.get(field):
                enhanced_case["media_urls"].append(report[field])
        
        # Check for media in nested objects or arrays
        if isinstance(report.get('media'), list):
            for media in report['media']:
                if isinstance(media, dict) and media.get('url'):
                    enhanced_case["media_urls"].append(media['url'])
                elif isinstance(media, str):
                    enhanced_case["media_urls"].append(media)
        
        print(f"Case {case_id}: Found {len(enhanced_case['media_urls'])} media files from CMS data")
        return enhanced_case
        
    except Exception as e:
        print(f"Error processing case data: {e}")
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