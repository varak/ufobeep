#!/bin/bash
# NUFORC Import Pipeline - Production Script
# Usage: ./nuforc.sh 2025-10-21
# Usage: ./nuforc.sh yesterday
# Usage: ./nuforc.sh today
# Usage: ./nuforc.sh 2025-10-20:2025-10-21   # date range (inclusive)

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./nuforc.sh <date or range>"
    echo "Examples:"
    echo "  ./nuforc.sh 2025-10-21"
    echo "  ./nuforc.sh yesterday"
    echo "  ./nuforc.sh today"
    echo "  ./nuforc.sh 2025-10-20:2025-10-21"
    exit 1
fi

DATE_INPUT="$1"

# Create log file with timestamp
LOG_FILE="logs/nuforc_import_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

# Helper: resolve tokens like 'today'/'yesterday' to YYYY-MM-DD
resolve_date_token() {
    local token="$1"
    if [ "$token" = "yesterday" ]; then
        date -d "yesterday" +%Y-%m-%d
    elif [ "$token" = "today" ]; then
        date +%Y-%m-%d
    else
        if ! date -d "$token" +%Y-%m-%d >/dev/null 2>&1; then
            echo ""
            return 1
        fi
        date -d "$token" +%Y-%m-%d
    fi
}

# Compute display header
if [[ "$DATE_INPUT" == *:* ]]; then
    START_TOKEN="${DATE_INPUT%%:*}"
    END_TOKEN="${DATE_INPUT##*:}"
    START_DATE=$(resolve_date_token "$START_TOKEN") || true
    END_DATE=$(resolve_date_token "$END_TOKEN") || true
    if [ -z "$START_DATE" ] || [ -z "$END_DATE" ]; then
        echo "❌ Invalid date range: '$DATE_INPUT'"
        exit 1
    fi
    if [[ "$START_DATE" > "$END_DATE" ]]; then
        echo "❌ Start date ($START_DATE) is after end date ($END_DATE)"
        exit 1
    fi
    echo "🚀 NUFORC Pipeline Starting for range $START_DATE to $END_DATE"
    echo "============================================================"
else
    DATE=$(resolve_date_token "$DATE_INPUT") || true
    if [ -z "$DATE" ]; then
        echo "❌ Invalid date: '$DATE_INPUT'"
        exit 1
    fi
    echo "🚀 NUFORC Pipeline Starting for $DATE"
    echo "===================================="
fi

# Bash function to run the embedded Python for a single date
run_nuforc_for_date() {
    local RUN_DATE="$1"
    echo ""
    echo "==============================================="
    echo "Processing NUFORC data for: $RUN_DATE"
    echo "==============================================="
    echo "🔍 Running NUFORC extraction and import for $RUN_DATE..."
    python3 - "$RUN_DATE" << 'EOF'
#!/usr/bin/env python3
import sys
import os
import time
import json
import requests
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict
import random
import traceback
import re
from bs4 import BeautifulSoup
import uuid

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def random_delay(min_seconds=1, max_seconds=3):
    """Add random delay to be respectful to NUFORC servers"""
    delay = random.uniform(min_seconds, max_seconds)
    time.sleep(delay)

def retry_with_backoff(func, max_retries=3, initial_delay=3):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = initial_delay * (2 ** attempt) + random.uniform(0, 1)
            log(f"⚠️ Attempt {attempt + 1} failed: {str(e)[:100]}")
            log(f"🔄 Retrying in {delay:.1f} seconds...")
            time.sleep(delay)

def geocode_location(city: str, state: str = None) -> Optional[Dict[str, any]]:
    """Geocode location using Nominatim"""
    if not city or len(city.strip()) < 2:
        return None

    # Build search query
    if state:
        search_location = f"{city}, {state}, USA"
    else:
        search_location = f"{city}, USA"

    try:
        time.sleep(0.3)  # Rate limit for Nominatim

        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": search_location,
            "format": "json",
            "limit": 1
        }

        headers = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}

        response = requests.get(url, params=params, headers=headers, timeout=15)
        if response.status_code == 200:
            data = response.json()
            if data:
                result = data[0]
                lat = float(result["lat"])
                lon = float(result["lon"])

                # Validate coordinates
                if -180 <= lon <= 180 and -90 <= lat <= 90:
                    return {
                        "location": search_location,
                        "latitude": lat,
                        "longitude": lon,
                        "display_name": result.get("display_name", search_location)
                    }
    except Exception as e:
        log(f"⚠️ Geocoding failed for '{search_location}': {e}")

    return None

def parse_nuforc_report(html_content: str, report_id: str, report_url: str) -> Optional[Dict]:
    """Parse NUFORC report HTML and extract fields"""
    try:
        soup = BeautifulSoup(html_content, 'html.parser')

        report_data = {
            "report_id": report_id,
            "url": report_url,
            "occurred": None,
            "reported": None,
            "posted": None,
            "duration": None,
            "no_of_observers": None,
            "location": None,
            "location_details": None,
            "exact_latitude": None,
            "exact_longitude": None,
            "city": None,
            "state": None,
            "country": None,
            "shape": None,
            "color": None,
            "estimated_size": None,
            "viewed_from": None,
            "direction_from_viewer": None,
            "angle_of_elevation": None,
            "closest_distance": None,
            "estimated_speed": None,
            "characteristics": None,
            "summary": None,
            "text": None,
            "media": []
        }

        # Find the H1 with the report title
        h1 = soup.find('h1')
        if not h1:
            raise Exception("Could not find H1 title tag")

        # Parse fields from H1 siblings
        text_parts = []
        capture_text = False
        current_field = None
        seen_shape = False  # Track when we've seen the Shape field

        # Known field labels to recognize (all possible NUFORC fields)
        known_fields = ['occurred', 'reported', 'duration', 'no of observers', 'location',
                       'location details', 'shape', 'characteristics', 'color', 'estimated size',
                       'viewed from', 'direction from viewer', 'angle of elevation',
                       'closest distance', 'estimated speed', 'apparent size', 'direction faced',
                       'height', 'altitude', 'distance', 'latitude', 'longitude']

        for sibling in h1.next_siblings:
            # Skip br tags and empty strings
            if isinstance(sibling, str):
                text = sibling.strip()
                if text and current_field:
                    # This is a value for the previous field
                    if current_field == 'occurred':
                        report_data['occurred'] = text
                    elif current_field == 'reported':
                        report_data['reported'] = text
                    elif current_field == 'duration':
                        report_data['duration'] = text
                    elif current_field == 'no_of_observers':
                        try:
                            report_data['no_of_observers'] = int(text)
                        except:
                            pass
                    elif current_field == 'location':
                        report_data['location'] = text
                        # Parse city, state, country
                        parts = text.split(',')
                        if len(parts) >= 2:
                            report_data['city'] = parts[0].strip()
                            if len(parts) == 2:
                                report_data['state'] = parts[1].strip()
                            elif len(parts) >= 3:
                                report_data['state'] = parts[1].strip()
                                report_data['country'] = parts[2].strip()
                    elif current_field == 'location_details':
                        report_data['location_details'] = text
                        # Extract exact coordinates if present
                        # Format: "Latitude: 49.112642 | Longitude: -122.164049"
                        if 'Latitude:' in text and 'Longitude:' in text:
                            try:
                                import re
                                lat_match = re.search(r'Latitude:\s*([-\d.]+)', text)
                                lon_match = re.search(r'Longitude:\s*([-\d.]+)', text)
                                if lat_match and lon_match:
                                    report_data['exact_latitude'] = float(lat_match.group(1))
                                    report_data['exact_longitude'] = float(lon_match.group(1))
                            except:
                                pass
                    elif current_field == 'shape':
                        report_data['shape'] = text
                        seen_shape = True
                    elif current_field == 'color':
                        report_data['color'] = text
                    elif current_field == 'estimated_size':
                        report_data['estimated_size'] = text
                    elif current_field == 'viewed_from':
                        report_data['viewed_from'] = text
                    elif current_field == 'direction_from_viewer':
                        report_data['direction_from_viewer'] = text
                    elif current_field == 'angle_of_elevation':
                        try:
                            report_data['angle_of_elevation'] = float(text)
                        except:
                            report_data['angle_of_elevation'] = text
                    elif current_field == 'closest_distance':
                        report_data['closest_distance'] = text
                    elif current_field == 'estimated_speed':
                        report_data['estimated_speed'] = text
                    elif current_field == 'characteristics':
                        report_data['characteristics'] = text
                        capture_text = True  # Start capturing after characteristics

                    # After shape, start capturing non-field text
                    if seen_shape and current_field not in ['occurred', 'reported', 'duration', 'no_of_observers', 'location', 'location_details', 'shape']:
                        capture_text = True

                    current_field = None

                # Capture report text after we've seen shape field
                elif seen_shape and text and not current_field:
                    # Stop if we hit Posted
                    if text.startswith('Posted'):
                        report_data['posted'] = text.replace('Posted', '').strip()
                        break
                    # Skip footer text
                    elif text not in ['TERMS OF SERVICE', 'PRIVACY POLICY', 'Copyright', 'National UFO Reporting Center']:
                        # Check if this looks like a field value (very short) or actual text (longer)
                        # Field values are typically < 50 chars, report text is longer
                        if len(text) > 15 or '.' in text:  # Likely report text
                            text_parts.append(text)

            # Handle tags
            elif hasattr(sibling, 'name'):
                # Check for field labels in <b> tags
                if sibling.name == 'b':
                    field_text = sibling.get_text().strip().lower().replace(':', '')
                    if field_text in known_fields:
                        current_field = field_text.replace(' ', '_')

                # Check for images in report text
                elif sibling.name == 'img' and seen_shape:
                    # Extract media URL
                    src = sibling.get('src', '')
                    alt = sibling.get('alt', '')
                    # Capture wpforms uploads AND simages (both are report media)
                    if src and ('wpforms' in src or '/simages/' in src):
                        full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                        report_data['media'].append({
                            'type': 'image',
                            'url': full_url,
                            'alt': alt,
                            'filename': src.split('/')[-1]
                        })

                # Check for Posted text (in <i> tag or <p>/<div>)
                elif sibling.name in ['i', 'p', 'div']:
                    text = sibling.get_text().strip()
                    if text.startswith('Posted'):
                        report_data['posted'] = text.replace('Posted', '').strip()
                        break
                    # Capture text from p/div tags after we've seen shape
                    elif seen_shape and text and len(text) > 50:
                        text_parts.append(text)

                # Capture text from <br> tags (NUFORC puts bulk of report in br tags!)
                elif sibling.name == 'br' and seen_shape:
                    text = sibling.get_text().strip()
                    if text and len(text) > 50:  # Skip small breaks
                        text_parts.append(text)

        # Join text parts
        if text_parts:
            report_data['summary'] = text_parts[0] if text_parts else ''
            report_data['text'] = '\n\n'.join(text_parts)

        # Check for images in the content
        images = soup.find_all('img')
        for img in images:
            src = img.get('src', '')
            alt = img.get('alt', '')
            # Capture wpforms uploads AND simages, but skip logos
            if src and ('wpforms' in src or '/simages/' in src) and 'logo' not in src.lower():
                full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                # Avoid duplicates
                if not any(m['url'] == full_url for m in report_data['media']):
                    report_data['media'].append({
                        'type': 'image',
                        'url': full_url,
                        'alt': alt,
                        'filename': src.split('/')[-1]
                    })

        # Check for video elements (HTML5 video tags)
        videos = soup.find_all('video')
        for video in videos:
            # Get source from video tag or child source tags
            sources = video.find_all('source')
            if sources:
                for source in sources:
                    src = source.get('src', '')
                    if src:
                        full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                        if not any(m['url'] == full_url for m in report_data['media']):
                            report_data['media'].append({
                                'type': 'video',
                                'url': full_url,
                                'alt': '',
                                'filename': src.split('/')[-1]
                            })
            else:
                src = video.get('src', '')
                if src:
                    full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                    if not any(m['url'] == full_url for m in report_data['media']):
                        report_data['media'].append({
                            'type': 'video',
                            'url': full_url,
                            'alt': '',
                            'filename': src.split('/')[-1]
                        })

        # Check for links to video/image files
        links = soup.find_all('a', href=True)
        media_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.mp4', '.mov', '.avi', '.webm', '.m4v']
        for link in links:
            href = link.get('href', '')
            if any(ext in href.lower() for ext in media_extensions):
                full_url = href if href.startswith('http') else f"https://nuforc.org{href}"
                file_type = 'video' if any(ext in href.lower() for ext in ['.mp4', '.mov', '.avi', '.webm', '.m4v']) else 'image'
                if not any(m['url'] == full_url for m in report_data['media']):
                    report_data['media'].append({
                        'type': file_type,
                        'url': full_url,
                        'filename': href.split('/')[-1]
                    })

        # Check for Muse.ai embedded videos (used by NUFORC for video hosting)
        html_str = str(html_content)
        import re
        muse_matches = re.findall(r'video:\s*"([^"]+)"', html_str)
        for video_id in muse_matches:
            muse_url = f"https://muse.ai/v/{video_id}"
            if not any(m['url'] == muse_url for m in report_data['media']):
                report_data['media'].append({
                    'type': 'video',
                    'url': muse_url,
                    'filename': f"muse_{video_id}.mp4"
                })

        return report_data
    except Exception as e:
        log(f"❌ Failed to parse report {report_id}: {e}")
        log(f"   Traceback: {traceback.format_exc()}")
        raise

def get_reports_for_date(date_str: str) -> List[Dict]:
    """Get NUFORC reports posted on a specific date"""
    # Convert YYYY-MM-DD to YYMMDD format
    # Example: 2025-10-21 -> 251021
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    date_code = dt.strftime("%y%m%d")

    # NUFORC daily index URL pattern: /subndx/?id=pYYMMDD
    index_url = f"https://nuforc.org/subndx/?id=p{date_code}"

    log(f"🔍 Fetching daily index: {index_url}")

    headers = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}

    def fetch_index():
        resp = requests.get(index_url, headers=headers, timeout=30)
        resp.raise_for_status()
        return resp.content

    html_content = retry_with_backoff(fetch_index)
    soup = BeautifulSoup(html_content, 'html.parser')

    # Find all report links: /sighting/?id=XXXXXX
    report_links = []
    for link in soup.find_all('a', href=True):
        href = link.get('href')
        if '/sighting/?id=' in href:
            # Extract report ID from URL
            match = re.search(r'id=(\d+)', href)
            if match:
                report_id = match.group(1)
                full_url = href if href.startswith('http') else f"https://nuforc.org{href}"
                report_links.append({
                    "report_id": report_id,
                    "url": full_url
                })

    log(f"📊 Found {len(report_links)} reports for {date_str}")
    return report_links

def upload_media_to_beep(beep_id: str, media_files: List[Dict]):
    """Download media from NUFORC and upload to UFOBeep"""
    if not media_files:
        return

    log(f"📤 Uploading {len(media_files)} media files for beep {beep_id}...")

    headers_download = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}

    for i, media in enumerate(media_files, 1):
        try:
            media_url = media['url']
            filename = media.get('filename', f"media_{i}.jpg")

            log(f"   📥 Downloading {i}/{len(media_files)}: {filename}")

            # Download from NUFORC
            response = requests.get(media_url, headers=headers_download, timeout=30)
            response.raise_for_status()

            # Upload to UFOBeep
            files = {'files': (filename, response.content, 'application/octet-stream')}
            data = {'source': 'nuforc_import'}

            upload_response = requests.post(
                f"https://ufobeep.com/api/beep/{beep_id}/media",
                files=files,
                data=data,
                timeout=300
            )

            if upload_response.status_code in [200, 201]:
                log(f"   ✅ Uploaded {filename}")
            else:
                log(f"   ⚠️ Failed to upload {filename}: {upload_response.status_code}")

        except Exception as e:
            log(f"   ❌ Error uploading media {filename}: {e}")
            continue

def extract_and_import_nuforc(date_str: str):
    """Main extraction and import function"""
    log(f"🎯 Processing NUFORC reports for {date_str}")

    # Get list of reports for this date
    try:
        report_links = get_reports_for_date(date_str)
    except Exception as e:
        log(f"❌ Failed to get reports for {date_str}: {e}")
        return False

    if not report_links:
        log("⚠️ No reports found for this date")
        return True  # Not an error, just no reports

    imported_count = 0
    skipped_count = 0
    error_count = 0

    for report_info in report_links:
        report_id = report_info['report_id']
        report_url = report_info['url']

        try:
            # Check if already imported
            external_id = f"nuforc_{report_id}"

            log(f"📖 Processing report {report_id}...")

            # Fetch report HTML
            headers = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}

            def fetch_report():
                resp = requests.get(report_url, headers=headers, timeout=30)
                resp.raise_for_status()
                return resp.content

            html_content = retry_with_backoff(fetch_report)

            # Parse report
            report_data = parse_nuforc_report(html_content, report_id, report_url)
            if not report_data or not report_data.get('text'):
                log(f"⚠️ Could not extract text from report {report_id}")
                error_count += 1
                continue

            # Use exact coordinates from NUFORC if available, otherwise geocode
            geo_data = None
            if report_data.get('exact_latitude') and report_data.get('exact_longitude'):
                # NUFORC provided exact coordinates - use them!
                geo_data = {
                    "latitude": report_data['exact_latitude'],
                    "longitude": report_data['exact_longitude'],
                    "location": f"{report_data.get('city', '')}, {report_data.get('state', '')}".strip(', ')
                }
                log(f"📍 Using exact NUFORC coordinates: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")
            elif report_data.get('city'):
                # Geocode the city/state
                geo_data = geocode_location(
                    report_data['city'],
                    report_data.get('state')
                )
                if geo_data:
                    log(f"📍 Geocoded: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")

            # Parse dates
            occurred_iso = None
            posted_iso = None
            reported_iso = None

            if report_data.get('occurred'):
                try:
                    # Handle various NUFORC date formats
                    # Common format: "2023-03-05 20:47 Local"
                    date_part = report_data['occurred'].split()[0]
                    occurred_dt = datetime.strptime(date_part, "%Y-%m-%d")
                    occurred_iso = occurred_dt.replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse occurred date '{report_data['occurred']}': {e}")

            if report_data.get('posted'):
                try:
                    # Format: "2023-03-06"
                    posted_dt = datetime.strptime(report_data['posted'], "%Y-%m-%d")
                    posted_iso = posted_dt.replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse posted date '{report_data['posted']}': {e}")

            if report_data.get('reported'):
                try:
                    # Format: "2023-03-05 19:21 Pacific"
                    date_part = report_data['reported'].split()[0]
                    reported_dt = datetime.strptime(date_part, "%Y-%m-%d")
                    reported_iso = reported_dt.replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse reported date '{report_data['reported']}': {e}")

            # Build beep payload
            alert_id = str(uuid.uuid4())

            # Build title
            shape = report_data.get('shape')
            if shape:
                title = f"NUFORC {shape.title()} Sighting"
            else:
                title = "NUFORC Sighting"

            beep_data = {
                "id": alert_id,
                "device_id": f"nuforc_import_{report_id}",
                "username": "NUFORC",
                "source": "nuforc",  # CRITICAL: Prevents alerts!
                "external_id": external_id,
                "tier": 2,  # Same as MUFON

                "title": title,
                "description": report_data['text'],  # Full report text

                "occurred_at": occurred_iso or posted_iso,
                "date_posted": posted_iso,
                "shape": shape,
                "duration": report_data.get('duration'),

                "report_url": report_url,  # Link back to NUFORC

                "enrichment_data": {
                    "nuforc_report_id": report_id,
                    "summary": report_data.get('summary'),
                    "full_text": report_data['text'],
                    "posted_date": posted_iso,
                    "reported_date": reported_iso,

                    # Visual characteristics
                    "shape": shape,
                    "color": report_data.get('color'),
                    "estimated_size": report_data.get('estimated_size'),
                    "characteristics": report_data.get('characteristics', ''),

                    # Observation details
                    "viewed_from": report_data.get('viewed_from'),
                    "direction_from_viewer": report_data.get('direction_from_viewer'),
                    "angle_of_elevation": report_data.get('angle_of_elevation'),
                    "closest_distance": report_data.get('closest_distance'),
                    "estimated_speed": report_data.get('estimated_speed'),
                    "no_of_observers": report_data.get('no_of_observers'),
                    "duration": report_data.get('duration'),

                    # Location data
                    "location_raw": f"{report_data.get('city', '')}, {report_data.get('state', '')}".strip(', '),
                    "location_details": report_data.get('location_details'),
                    "exact_latitude": report_data.get('exact_latitude'),
                    "exact_longitude": report_data.get('exact_longitude'),

                    # Links and metadata
                    "external_url": report_url,

                    # UI flags for mobile app
                    "hide_witness_widget": True,
                    "hide_location_widget": True,
                    "hide_environmental_analysis": True,  # Don't show weather/aircraft/satellites
                    "hide_actions": True,  # Don't show "Report to MUFON" etc
                    "is_historical_report": True,  # This is historical NUFORC data
                    "source_name": "NUFORC"  # Display "NUFORC Report" instead of "UFOBeep Alert"
                }
            }

            # Add location if geocoded
            if geo_data:
                beep_data["location"] = {
                    "latitude": geo_data["latitude"],
                    "longitude": geo_data["longitude"],
                    "name": geo_data["location"]
                }
            elif report_data.get('city'):
                # No coordinates but have location text
                beep_data["location"] = {
                    "name": f"{report_data['city']}, {report_data.get('state', '')}".strip(', ')
                }

            # Create beep
            log(f"📤 Creating beep for NUFORC report {report_id}...")
            response = requests.post(
                "https://ufobeep.com/api/beep",
                json=beep_data,
                timeout=30
            )

            if response.status_code in [200, 201]:
                alert_response = response.json()
                created_id = alert_response.get('sighting_id')
                log(f"✅ Created beep: {created_id}")

                # Upload media if present
                if report_data.get('media'):
                    upload_media_to_beep(created_id, report_data['media'])

                imported_count += 1

            else:
                log(f"❌ Failed to create beep for {report_id}: {response.status_code}")
                log(f"   Response: {response.text[:200]}")
                error_count += 1

            # Rate limiting
            random_delay(2, 3)

        except Exception as e:
            log(f"❌ Error processing report {report_id}: {e}")
            log(f"   Traceback: {traceback.format_exc()}")
            error_count += 1
            random_delay(1, 2)
            continue

    log(f"🎉 Processing complete:")
    log(f"   ✅ Imported: {imported_count}")
    log(f"   ⏭️  Skipped: {skipped_count}")
    log(f"   ❌ Errors: {error_count}")

    return error_count == 0

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py DATE")
        sys.exit(1)

    success = extract_and_import_nuforc(sys.argv[1])
    sys.exit(0 if success else 1)
EOF
    return $?
}

# In range mode, loop days; otherwise run single date
if [[ "$DATE_INPUT" == *:* ]]; then
    current_date="$START_DATE"
    last_date="$END_DATE"
    day_count=0
    success_count=0
    error_count=0
    echo "📅 Import range: $START_DATE to $END_DATE"
    echo "⏱️  2-second delay between each day"
    echo ""
    while [[ "$current_date" < "$last_date" ]] || [[ "$current_date" == "$last_date" ]]; do
        day_count=$((day_count + 1))
        echo "📅 Day $day_count: Processing $current_date"
        if run_nuforc_for_date "$current_date"; then
            echo "✅ Successfully imported data for $current_date"
            success_count=$((success_count + 1))
        else
            echo "❌ Failed to import data for $current_date"
            error_count=$((error_count + 1))
        fi
        # Next day
        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
        if [[ "$current_date" < "$last_date" ]] || [[ "$current_date" == "$last_date" ]]; then
            echo "⏳ Waiting 2 seconds..."
            sleep 2
            echo ""
        fi
    done
    echo ""
    echo "🎉 NUFORC Range Import Complete!"
    echo "================================"
    echo "📊 Total days processed: $day_count"
    echo "✅ Successful imports: $success_count"
    echo "❌ Failed imports: $error_count"
    echo "📅 Date range: $START_DATE to $END_DATE"
    if [ $error_count -eq 0 ]; then
        echo "🎯 All imports completed successfully!"
        exit 0
    else
        echo "⚠️  Some imports failed. Check logs above for details."
        exit 1
    fi
else
    if run_nuforc_for_date "$DATE"; then
        echo "✅ NUFORC import completed successfully!"
        exit 0
    else
        echo "❌ NUFORC import failed"
        exit 1
    fi
fi
