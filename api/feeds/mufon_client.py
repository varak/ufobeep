"""
MUFON RSS/Web scraper for last 20 public reports
Fetches from https://mufoncms.com/last_20_public.html
"""
import httpx
from bs4 import BeautifulSoup
from typing import List, Dict, Any
import hashlib
from datetime import datetime
import re

MUFON_URL = "https://mufoncms.com/last_20_public.html"

async def fetch_last20() -> List[Dict[str, Any]]:
    """
    Fetch last 20 MUFON reports from their public page
    Returns list of raw report dictionaries
    """
    try:
        async with httpx.AsyncClient(timeout=30.0) as client:
            response = await client.get(MUFON_URL)
            response.raise_for_status()
            
        soup = BeautifulSoup(response.text, 'html.parser')
        reports = []
        
        # Find the reports table or container
        # MUFON structure: look for report rows/cards
        report_elements = soup.find_all('tr')[1:]  # Skip header row
        
        for element in report_elements[:20]:  # Limit to 20
            try:
                cells = element.find_all('td')
                if len(cells) >= 6:  # Ensure we have enough data
                    report = _parse_mufon_row(cells)
                    if report:
                        reports.append(report)
            except Exception as e:
                print(f"Error parsing MUFON row: {e}")
                continue
                
        return reports
        
    except Exception as e:
        print(f"Error fetching MUFON data: {e}")
        return []

def _parse_mufon_row(cells) -> Dict[str, Any]:
    """Parse a MUFON table row into structured data"""
    try:
        # MUFON table structure (adjust based on actual HTML):
        # Case #, Date, City, State, Country, Shape, Duration, Summary
        case_num = cells[0].get_text(strip=True)
        date_str = cells[1].get_text(strip=True)
        city = cells[2].get_text(strip=True)
        state = cells[3].get_text(strip=True) if len(cells) > 3 else ""
        country = cells[4].get_text(strip=True) if len(cells) > 4 else ""
        shape = cells[5].get_text(strip=True) if len(cells) > 5 else ""
        duration = cells[6].get_text(strip=True) if len(cells) > 6 else ""
        summary = cells[7].get_text(strip=True) if len(cells) > 7 else ""
        
        # Parse date
        occurred_at = _parse_mufon_date(date_str)
        
        return {
            "case_number": case_num,
            "date_str": date_str,
            "city": city,
            "state": state,
            "country": country,
            "shape": shape,
            "duration": duration,
            "summary": summary,
            "occurred_at": occurred_at,
            "url": f"https://mufoncms.com/case/{case_num}" if case_num else None
        }
        
    except Exception as e:
        print(f"Error parsing MUFON row: {e}")
        return None

def _parse_mufon_date(date_str: str) -> datetime:
    """Parse MUFON date string to datetime"""
    try:
        # Common MUFON formats: "MM/DD/YYYY", "YYYY-MM-DD", etc.
        date_str = date_str.strip()
        
        # Try different formats
        formats = [
            "%m/%d/%Y",
            "%Y-%m-%d", 
            "%m-%d-%Y",
            "%d/%m/%Y"
        ]
        
        for fmt in formats:
            try:
                return datetime.strptime(date_str, fmt)
            except ValueError:
                continue
                
        # Fallback to current time if parsing fails
        return datetime.utcnow()
        
    except:
        return datetime.utcnow()

def to_alert_dict(mufon_report: Dict[str, Any]) -> Dict[str, Any]:
    """
    Convert MUFON report to sighting/alert format
    """
    # Create unique hash for deduplication
    content = f"{mufon_report.get('case_number', '')}-{mufon_report.get('summary', '')}-{mufon_report.get('city', '')}"
    ingestion_hash = hashlib.sha256(content.encode()).hexdigest()
    
    # Build location string
    location_parts = [
        mufon_report.get('city', ''),
        mufon_report.get('state', ''),
        mufon_report.get('country', '')
    ]
    location = ', '.join([p for p in location_parts if p])
    
    # Create title
    title = f"UFO Sighting in {mufon_report.get('city', 'Unknown Location')}"
    if mufon_report.get('shape'):
        title += f" - {mufon_report.get('shape')} Shape"
    
    # Create sensor_data with location info (if we can geocode)
    sensor_data = {
        "location": {
            "city": mufon_report.get('city', ''),
            "state": mufon_report.get('state', ''),
            "country": mufon_report.get('country', '')
        }
    }
    
    return {
        "source": "mufon",
        "source_id": mufon_report.get('case_number'),
        "ingestion_hash": ingestion_hash,
        "occurred_at": mufon_report.get('occurred_at'),
        "title": title,
        "summary": mufon_report.get('summary', ''),
        "city": mufon_report.get('city'),
        "state": mufon_report.get('state'),
        "country": mufon_report.get('country'),
        "shape": mufon_report.get('shape'),
        "duration": mufon_report.get('duration'),
        "external_url": mufon_report.get('url'),
        "sensor_data": sensor_data,
        "raw": mufon_report
    }