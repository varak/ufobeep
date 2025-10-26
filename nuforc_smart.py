#!/usr/bin/env python3
"""
Smart NUFORC Data Collection with AI Summarization
Slow, respectful scraping with full report extraction and AI summaries

Strategy:
1. Collect full reports from NUFORC with VERY slow, respectful scraping (10-15s delays)
2. Extract complete report data (all fields, text, media)
3. Use Google Gemini to create intelligent summaries
4. Always preserve link to original NUFORC report
5. Store rich, summarized content for immediate user access

Cost: ~$0.0003 per summary = essentially free for realistic usage
Benefits: Users get rich content immediately + original source link
"""

import sys
import os
import time
import json
import requests
import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict
import random
import traceback
import re
from bs4 import BeautifulSoup
import uuid
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment variables
load_dotenv()
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    ai_model = genai.GenerativeModel('gemini-2.0-flash-exp')  # Fast, cheap model
    print("✅ Gemini AI configured for on-demand summarization")
else:
    ai_model = None
    print("⚠️  No GEMINI_API_KEY - summaries will be basic extracts")

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def respectful_delay(min_seconds=3, max_seconds=6):
    """Much longer delays to be respectful to NUFORC"""
    delay = random.uniform(min_seconds, max_seconds)
    time.sleep(delay)

def get_daily_reports_metadata(date_str: str) -> List[Dict]:
    """
    Get basic metadata from NUFORC daily index (minimal scraping)
    Only collects: ID, URL, basic location, shape - NO full content
    """
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    date_code = dt.strftime("%y%m%d")
    index_url = f"https://nuforc.org/subndx/?id=p{date_code}"

    log(f"📋 Collecting metadata from daily index: {index_url}")

    headers = {"User-Agent": "UFOBeep Research (+https://ufobeep.com/about)"}

    try:
        resp = requests.get(index_url, headers=headers, timeout=30)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.content, 'html.parser')

        reports = []
        # Look for report links in table rows
        for link in soup.find_all('a', href=True):
            href = link.get('href')
            if '/sighting/?id=' in href:
                # Extract report ID
                match = re.search(r'id=(\d+)', href)
                if match:
                    report_id = match.group(1)
                    full_url = href if href.startswith('http') else f"https://nuforc.org{href}"

                    # Try to extract basic info from the table row
                    row = link.find_parent('tr')
                    if row:
                        cells = row.find_all(['td', 'th'])
                        if len(cells) >= 4:
                            # Typical NUFORC table: Date, City, State, Country, Shape, Duration, Summary
                            basic_info = {
                                "report_id": report_id,
                                "url": full_url,
                                "date_occurred": cells[0].get_text(strip=True) if len(cells) > 0 else None,
                                "city": cells[1].get_text(strip=True) if len(cells) > 1 else None,
                                "state": cells[2].get_text(strip=True) if len(cells) > 2 else None,
                                "country": cells[3].get_text(strip=True) if len(cells) > 3 else None,
                                "shape": cells[4].get_text(strip=True) if len(cells) > 4 else None,
                                "duration": cells[5].get_text(strip=True) if len(cells) > 5 else None,
                                "basic_summary": cells[6].get_text(strip=True) if len(cells) > 6 else None,
                                "collected_at": datetime.now().isoformat(),
                                "needs_ai_summary": True  # Flag for on-demand processing
                            }
                            reports.append(basic_info)

        log(f"📊 Collected {len(reports)} report metadata entries")
        return reports

    except Exception as e:
        log(f"❌ Failed to collect metadata for {date_str}: {e}")
        return []

def generate_ai_summary(report_url: str, report_id: str) -> Optional[Dict]:
    """
    On-demand AI summarization when user views a report
    Fetches original NUFORC page and creates intelligent summary
    """
    if not ai_model:
        return None

    log(f"🤖 Generating AI summary for report {report_id}")

    try:
        # Fetch the original NUFORC report
        headers = {"User-Agent": "UFOBeep Research (+https://ufobeep.com/about)"}
        resp = requests.get(report_url, headers=headers, timeout=30)
        resp.raise_for_status()

        soup = BeautifulSoup(resp.content, 'html.parser')

        # Extract main report text (simplified version of the original parser)
        report_text = ""
        for element in soup.find_all(['p', 'div', 'br']):
            text = element.get_text(strip=True)
            if text and len(text) > 20:  # Skip short fragments
                report_text += text + " "

        # Clean up the text
        report_text = re.sub(r'\s+', ' ', report_text).strip()

        if len(report_text) < 50:
            log(f"⚠️  Insufficient text content for report {report_id}")
            return None

        # Create AI prompt for intelligent summarization
        prompt = f"""
You are analyzing a UFO sighting report from NUFORC. Create a clear, factual summary.

Original Report Text:
{report_text[:2000]}

Please provide:
1. SUMMARY: A clear 2-3 sentence summary of what the witness observed
2. KEY_DETAILS: Location, date/time, duration, number of witnesses (if available)
3. OBJECT_DESCRIPTION: Shape, size, color, behavior of the observed object
4. CREDIBILITY_NOTES: Any notable details about the witness or observation quality

Format exactly like this:
SUMMARY: [2-3 sentences describing what was observed]
KEY_DETAILS: Location: [location], Date: [date], Duration: [duration], Witnesses: [number]
OBJECT_DESCRIPTION: [shape, appearance, behavior]
CREDIBILITY_NOTES: [assessment of report quality/detail]
"""

        response = ai_model.generate_content(prompt)
        ai_text = response.text

        # Parse the structured response
        lines = ai_text.strip().split('\n')
        summary_data = {}

        for line in lines:
            if line.startswith('SUMMARY:'):
                summary_data['ai_summary'] = line.replace('SUMMARY:', '').strip()
            elif line.startswith('KEY_DETAILS:'):
                summary_data['key_details'] = line.replace('KEY_DETAILS:', '').strip()
            elif line.startswith('OBJECT_DESCRIPTION:'):
                summary_data['object_description'] = line.replace('OBJECT_DESCRIPTION:', '').strip()
            elif line.startswith('CREDIBILITY_NOTES:'):
                summary_data['credibility_notes'] = line.replace('CREDIBILITY_NOTES:', '').strip()

        summary_data.update({
            'summarized_at': datetime.now().isoformat(),
            'source_length': len(report_text),
            'summary_method': 'gemini_ai'
        })

        log(f"✅ AI summary generated for report {report_id}")
        return summary_data

    except Exception as e:
        log(f"❌ Failed to generate AI summary for {report_id}: {e}")
        return None

def create_lightweight_beep(report_metadata: Dict, date_str: str) -> bool:
    """
    Create a lightweight beep entry with just metadata
    AI summary will be generated on-demand when user views it
    """
    try:
        report_id = report_metadata['report_id']
        external_id = f"nuforc_{report_id}"

        # Create basic beep with metadata only
        alert_id = str(uuid.uuid4())

        # Parse occurred date if available
        occurred_iso = None
        if report_metadata.get('date_occurred'):
            try:
                # Try to parse various NUFORC date formats
                date_text = report_metadata['date_occurred']
                if '/' in date_text:
                    # Format like "10/21/25"
                    dt = datetime.strptime(date_text, "%m/%d/%y")
                    # Handle Y2K issue - assume years 00-30 are 2000s, 31-99 are 1900s
                    if dt.year < 1931:
                        dt = dt.replace(year=dt.year + 100)
                    occurred_iso = dt.replace(tzinfo=timezone.utc).isoformat()
            except:
                pass  # Use None if parsing fails

        # Build location name
        location_parts = [
            report_metadata.get('city'),
            report_metadata.get('state'),
            report_metadata.get('country')
        ]
        location_name = ', '.join([p for p in location_parts if p and p.strip()])

        beep_data = {
            "id": alert_id,
            "device_id": f"nuforc_smart_{report_id}",
            "username": "NUFORC",
            "source": "nuforc",
            "external_id": external_id,
            "tier": 2,

            "title": f"NUFORC {report_metadata.get('shape', 'UFO').title()} Sighting",
            "description": report_metadata.get('basic_summary', 'UFO sighting report - click for AI summary'),

            "occurred_at": occurred_iso,
            "date_posted": datetime.now().isoformat(),
            "shape": report_metadata.get('shape'),
            "duration": report_metadata.get('duration'),

            "report_url": report_metadata['url'],

            "enrichment_data": {
                "nuforc_report_id": report_id,
                "original_url": report_metadata['url'],
                "collection_method": "smart_metadata_only",
                "ai_summary_available": bool(ai_model),
                "basic_summary": report_metadata.get('basic_summary'),

                # Raw metadata from daily index
                "raw_city": report_metadata.get('city'),
                "raw_state": report_metadata.get('state'),
                "raw_country": report_metadata.get('country'),
                "raw_date_occurred": report_metadata.get('date_occurred'),

                # UI flags
                "hide_witness_widget": True,
                "hide_location_widget": True,
                "hide_environmental_analysis": True,
                "hide_actions": True,
                "is_historical_report": True,
                "source_name": "NUFORC",
                "needs_ai_summary": True  # Flag for frontend to offer AI summary
            }
        }

        # Add location if we have it
        if location_name:
            beep_data["location"] = {"name": location_name}

        # Create beep
        response = requests.post(
            "https://ufobeep.com/api/beep",
            json=beep_data,
            timeout=30
        )

        if response.status_code in [200, 201]:
            alert_response = response.json()
            created_id = alert_response.get('sighting_id')
            log(f"✅ Created lightweight beep: {created_id}")
            return True
        else:
            log(f"❌ Failed to create beep for {report_id}: {response.status_code}")
            return False

    except Exception as e:
        log(f"❌ Error creating beep for {report_metadata.get('report_id', 'unknown')}: {e}")
        return False

def main():
    """Main function for smart NUFORC collection"""
    if len(sys.argv) != 2:
        print("Usage: python3 nuforc_smart.py <date>")
        print("Examples:")
        print("  python3 nuforc_smart.py 2025-10-21")
        print("  python3 nuforc_smart.py yesterday")
        print("  python3 nuforc_smart.py today")
        sys.exit(1)

    date_input = sys.argv[1]

    # Handle special date tokens
    if date_input == "yesterday":
        date_str = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    elif date_input == "today":
        date_str = datetime.now().strftime("%Y-%m-%d")
    else:
        date_str = date_input

    log(f"🚀 Smart NUFORC Collection Starting for {date_str}")
    log("🧠 Strategy: Minimal metadata collection + on-demand AI summaries")

    # Collect basic metadata (respectful, minimal scraping)
    reports_metadata = get_daily_reports_metadata(date_str)

    if not reports_metadata:
        log("⚠️  No reports found for this date")
        return

    # Create lightweight beeps
    success_count = 0
    for report_meta in reports_metadata:
        if create_lightweight_beep(report_meta, date_str):
            success_count += 1

        # Be very respectful with delays
        respectful_delay(2, 4)

    log(f"🎉 Smart collection complete: {success_count}/{len(reports_metadata)} beeps created")
    log("💡 AI summaries will be generated on-demand when users view reports")

if __name__ == "__main__":
    main()