#!/usr/bin/env python3
"""
NUFORC Stealth Scraper with AI Summarization
Headless browser approach with Playwright for maximum anti-bot evasion

Strategy:
- Headless Playwright browser with stealth mode
- Realistic human-like browsing patterns
- Slow, respectful collection (10-15s delays)
- Full report extraction + Gemini AI summaries
- Daily collection of fresh reports only
- Duplicate detection to avoid re-processing

Built for: UFOBeep.com
Author: Stealth scraping beast mode activated 🤖
"""

import sys
import os
import time
import json
import hashlib
from datetime import datetime, timezone, timedelta
from typing import Optional, List, Dict, Any
import random
import traceback
import re
import uuid
from dataclasses import dataclass

# Core imports
from playwright.sync_api import sync_playwright, Page, Browser, BrowserContext
from bs4 import BeautifulSoup
import requests
import google.generativeai as genai
from dotenv import load_dotenv

# Load environment
load_dotenv()
GEMINI_API_KEY = os.getenv('GEMINI_API_KEY')

if GEMINI_API_KEY:
    genai.configure(api_key=GEMINI_API_KEY)
    ai_model = genai.GenerativeModel('gemini-2.0-flash-exp')
    print("🧠 Gemini AI loaded and ready for summarization")
else:
    ai_model = None
    print("⚠️  No GEMINI_API_KEY found - AI summaries disabled")

@dataclass
class NuforcReport:
    """Comprehensive NUFORC report data - capture EVERYTHING for Gemini analysis"""
    report_id: str
    url: str
    title: str = ""

    # Temporal data
    occurred_date: Optional[str] = None
    reported_date: Optional[str] = None
    posted_date: Optional[str] = None

    # Location data
    location: Optional[str] = None
    location_details: Optional[str] = None
    city: Optional[str] = None
    state: Optional[str] = None
    country: Optional[str] = None
    exact_latitude: Optional[float] = None
    exact_longitude: Optional[float] = None

    # Object characteristics
    shape: Optional[str] = None
    color: Optional[str] = None
    estimated_size: Optional[str] = None
    apparent_size: Optional[str] = None
    characteristics: Optional[str] = None

    # Observation details
    duration: Optional[str] = None
    witnesses: Optional[int] = None
    viewed_from: Optional[str] = None
    direction_from_viewer: Optional[str] = None
    direction_faced: Optional[str] = None
    angle_of_elevation: Optional[str] = None
    closest_distance: Optional[str] = None
    estimated_speed: Optional[str] = None
    height: Optional[str] = None
    altitude: Optional[str] = None
    distance: Optional[str] = None

    # Environmental conditions
    weather: Optional[str] = None
    visibility: Optional[str] = None
    temperature: Optional[str] = None
    wind: Optional[str] = None
    clouds: Optional[str] = None
    precipitation: Optional[str] = None

    # Effects and evidence
    electromagnetic_effects: Optional[str] = None
    animal_reactions: Optional[str] = None
    physical_effects: Optional[str] = None
    physiological_effects: Optional[str] = None
    trace_evidence: Optional[str] = None
    radar_contact: Optional[str] = None

    # Content
    description: str = ""
    full_text: str = ""
    media_urls: List[str] = None

    # AI analysis
    ai_summary: Optional[str] = None
    ai_key_points: List[str] = None

    def __post_init__(self):
        if self.media_urls is None:
            self.media_urls = []

def log(message: str, level: str = "INFO"):
    """Enhanced logging with emoji indicators"""
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    emoji = {
        "INFO": "ℹ️",
        "SUCCESS": "✅",
        "WARNING": "⚠️",
        "ERROR": "❌",
        "STEALTH": "🥷",
        "AI": "🤖",
        "BROWSER": "🌐"
    }.get(level, "📝")

    print(f"[{timestamp}] {emoji} {message}")

def human_delay(min_seconds: float = 8.0, max_seconds: float = 15.0):
    """Human-like random delays to avoid detection"""
    delay = random.uniform(min_seconds, max_seconds)
    log(f"Human-like delay: {delay:.1f}s", "STEALTH")
    time.sleep(delay)

def setup_stealth_browser(proxy: Optional[str] = None) -> tuple[Browser, BrowserContext, Page]:
    """
    Create stealth browser with realistic fingerprint
    Maximum anti-bot evasion settings + optional proxy support
    """
    log("Launching stealth browser...", "BROWSER")

    if proxy:
        log(f"🔄 Using proxy: {proxy}", "STEALTH")

    playwright = sync_playwright().start()

    # Launch Chrome with maximum stealth
    launch_args = [
        '--no-sandbox',
        '--disable-blink-features=AutomationControlled',
        '--disable-web-security',
        '--disable-features=VizDisplayCompositor',
        '--disable-dev-shm-usage',
        '--no-first-run',
        '--disable-background-timer-throttling',
        '--disable-backgrounding-occluded-windows',
        '--disable-renderer-backgrounding'
    ]

    # Add proxy if specified
    if proxy:
        launch_args.append(f'--proxy-server={proxy}')

    browser = playwright.chromium.launch(
        headless=True,  # Set to False for debugging
        args=launch_args
    )

    # Create realistic browser context
    context = browser.new_context(
        user_agent='Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36',
        viewport={'width': 1920, 'height': 1080},
        locale='en-US',
        timezone_id='America/New_York',
        permissions=['geolocation'],
        extra_http_headers={
            'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,image/apng,*/*;q=0.8',
            'Accept-Language': 'en-US,en;q=0.9',
            'Accept-Encoding': 'gzip, deflate, br',
            'DNT': '1',
            'Connection': 'keep-alive',
            'Upgrade-Insecure-Requests': '1',
        }
    )

    # Add stealth scripts to hide automation
    context.add_init_script("""
        // Remove webdriver property
        Object.defineProperty(navigator, 'webdriver', {
            get: () => undefined,
        });

        // Mock chrome runtime
        window.chrome = {
            runtime: {},
        };

        // Mock permissions
        const originalQuery = window.navigator.permissions.query;
        window.navigator.permissions.query = (parameters) => (
            parameters.name === 'notifications' ?
                Promise.resolve({ state: Notification.permission }) :
                originalQuery(parameters)
        );
    """)

    page = context.new_page()

    log("Stealth browser ready - maximum evasion mode activated", "STEALTH")
    return browser, context, page

def simulate_human_browsing(page: Page, url: str) -> str:
    """
    Navigate to page with human-like behavior
    """
    log(f"🌐 Navigating to: {url}", "BROWSER")

    try:
        # Navigate with realistic timeout
        response = page.goto(url, wait_until='domcontentloaded', timeout=30000)

        # Check response status
        if response:
            log(f"📊 Response status: {response.status}", "BROWSER")
            if response.status >= 400:
                log(f"❌ HTTP Error {response.status} - possible blocking", "ERROR")

        # Check for blocking indicators
        title = page.title()
        log(f"📄 Page title: {title}", "BROWSER")

        # Look for common blocking messages
        content_preview = page.content()[:500].lower()
        if any(block_word in content_preview for block_word in ['blocked', 'captcha', 'access denied', 'forbidden']):
            log("🚫 Possible blocking detected in page content", "WARNING")

        # Simulate human reading time
        reading_time = random.uniform(3.0, 7.0)
        log(f"👀 Simulating reading time: {reading_time:.1f}s", "STEALTH")
        time.sleep(reading_time)

        # Random scroll to simulate human behavior
        if random.choice([True, False]):
            log("📜 Simulating scroll behavior", "STEALTH")
            page.evaluate("""
                window.scrollTo({
                    top: Math.random() * 500,
                    behavior: 'smooth'
                });
            """)
            time.sleep(random.uniform(0.5, 1.5))

        # Get page content
        content = page.content()
        log(f"📥 Content extracted: {len(content)} characters", "BROWSER")

        # Additional debugging for empty content
        if len(content) < 1000:
            log("⚠️  Very small content size - possible blocking", "WARNING")
            log(f"Content preview: {content[:200]}...", "WARNING")

        return content

    except Exception as e:
        log(f"❌ Navigation failed: {str(e)}", "ERROR")
        return ""

def get_daily_report_links(page: Page, date_str: str) -> List[Dict[str, str]]:
    """
    Get report links from NUFORC daily index with stealth browser
    """
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    date_code = dt.strftime("%y%m%d")
    index_url = f"https://nuforc.org/subndx/?id=p{date_code}"

    log(f"🔍 Collecting report links for {date_str} (code: {date_code})", "STEALTH")

    # Get page content with human simulation
    content = simulate_human_browsing(page, index_url)

    if not content:
        log("❌ No content received - possible blocking", "ERROR")
        return []

    soup = BeautifulSoup(content, 'html.parser')

    # Debug: Check what we actually got
    log(f"🔍 Parsing HTML content...", "BROWSER")
    all_links = soup.find_all('a', href=True)
    log(f"🔗 Found {len(all_links)} total links on page", "BROWSER")

    # Look for sighting links
    sighting_links = [link for link in all_links if '/sighting/?id=' in link.get('href', '')]
    log(f"👁️ Found {len(sighting_links)} sighting links", "BROWSER")

    # Debug: Show first few links if any
    if len(all_links) > 0:
        log(f"📝 Sample links found:", "BROWSER")
        for i, link in enumerate(all_links[:5]):
            href = link.get('href', 'No href')
            text = link.get_text(strip=True)[:50]
            log(f"  {i+1}. {href} -> '{text}'", "BROWSER")

    reports = []
    for link in sighting_links:
        href = link.get('href')
        match = re.search(r'id=(\d+)', href)
        if match:
            report_id = match.group(1)
            full_url = href if href.startswith('http') else f"https://nuforc.org{href}"

            reports.append({
                "report_id": report_id,
                "url": full_url,
                "link_text": link.get_text(strip=True)
            })
            log(f"✅ Found report: {report_id}", "SUCCESS")

    log(f"📊 Found {len(reports)} reports for {date_str}", "SUCCESS")
    return reports

def extract_full_report(page: Page, report_url: str, report_id: str) -> NuforcReport:
    """
    Extract complete report data from individual NUFORC page
    Enhanced parser using the stealth browser
    """
    log(f"Extracting full report: {report_id}", "BROWSER")

    # Get page content with human behavior
    content = simulate_human_browsing(page, report_url)
    soup = BeautifulSoup(content, 'html.parser')

    # Create report object
    report = NuforcReport(
        report_id=report_id,
        url=report_url
    )

    try:
        # Find the main content area
        h1 = soup.find('h1')
        if h1:
            report.title = h1.get_text(strip=True)

        # Parse ALL possible NUFORC fields - be comprehensive for Gemini analysis
        text_parts = []
        current_field = None
        seen_shape = False

        # EXPANDED field list - capture EVERYTHING NUFORC provides
        known_fields = ['occurred', 'reported', 'posted', 'duration', 'no of observers', 'location',
                       'location details', 'shape', 'characteristics', 'color', 'estimated size',
                       'viewed from', 'direction from viewer', 'angle of elevation',
                       'closest distance', 'estimated speed', 'apparent size', 'direction faced',
                       'height', 'altitude', 'distance', 'latitude', 'longitude', 'weather',
                       'visibility', 'temperature', 'wind', 'clouds', 'precipitation',
                       'electromagnetic effects', 'animal reactions', 'physical effects',
                       'physiological effects', 'trace evidence', 'radar contact']

        if h1:
            for sibling in h1.next_siblings:
                if isinstance(sibling, str):
                    text = sibling.strip()
                    if text and current_field:
                        # Process ALL field values - comprehensive capture
                        if current_field == 'occurred':
                            report.occurred_date = text
                        elif current_field == 'reported':
                            report.reported_date = text
                        elif current_field == 'posted':
                            report.posted_date = text
                        elif current_field == 'duration':
                            report.duration = text
                        elif current_field == 'no_of_observers':
                            try:
                                report.witnesses = int(text)
                            except:
                                pass
                        elif current_field == 'location':
                            report.location = text
                            # Parse city, state, country
                            parts = text.split(',')
                            if len(parts) >= 1:
                                report.city = parts[0].strip()
                            if len(parts) >= 2:
                                report.state = parts[1].strip()
                            if len(parts) >= 3:
                                report.country = parts[2].strip()
                        elif current_field == 'location_details':
                            report.location_details = text
                            # Extract exact coordinates if present
                            if 'Latitude:' in text and 'Longitude:' in text:
                                try:
                                    lat_match = re.search(r'Latitude:\s*([-\d.]+)', text)
                                    lon_match = re.search(r'Longitude:\s*([-\d.]+)', text)
                                    if lat_match and lon_match:
                                        report.exact_latitude = float(lat_match.group(1))
                                        report.exact_longitude = float(lon_match.group(1))
                                except:
                                    pass
                        elif current_field == 'shape':
                            report.shape = text
                            seen_shape = True
                        elif current_field == 'color':
                            report.color = text
                        elif current_field == 'estimated_size':
                            report.estimated_size = text
                        elif current_field == 'apparent_size':
                            report.apparent_size = text
                        elif current_field == 'characteristics':
                            report.characteristics = text
                        elif current_field == 'viewed_from':
                            report.viewed_from = text
                        elif current_field == 'direction_from_viewer':
                            report.direction_from_viewer = text
                        elif current_field == 'direction_faced':
                            report.direction_faced = text
                        elif current_field == 'angle_of_elevation':
                            report.angle_of_elevation = text
                        elif current_field == 'closest_distance':
                            report.closest_distance = text
                        elif current_field == 'estimated_speed':
                            report.estimated_speed = text
                        elif current_field == 'height':
                            report.height = text
                        elif current_field == 'altitude':
                            report.altitude = text
                        elif current_field == 'distance':
                            report.distance = text
                        elif current_field == 'latitude':
                            try:
                                report.exact_latitude = float(text)
                            except:
                                pass
                        elif current_field == 'longitude':
                            try:
                                report.exact_longitude = float(text)
                            except:
                                pass
                        elif current_field == 'weather':
                            report.weather = text
                        elif current_field == 'visibility':
                            report.visibility = text
                        elif current_field == 'temperature':
                            report.temperature = text
                        elif current_field == 'wind':
                            report.wind = text
                        elif current_field == 'clouds':
                            report.clouds = text
                        elif current_field == 'precipitation':
                            report.precipitation = text
                        elif current_field == 'electromagnetic_effects':
                            report.electromagnetic_effects = text
                        elif current_field == 'animal_reactions':
                            report.animal_reactions = text
                        elif current_field == 'physical_effects':
                            report.physical_effects = text
                        elif current_field == 'physiological_effects':
                            report.physiological_effects = text
                        elif current_field == 'trace_evidence':
                            report.trace_evidence = text
                        elif current_field == 'radar_contact':
                            report.radar_contact = text

                        current_field = None

                    # Collect report text after shape field
                    elif seen_shape and text and len(text) > 15:
                        if text.startswith('Posted'):
                            report.posted_date = text.replace('Posted', '').strip()
                            break
                        elif text not in ['TERMS OF SERVICE', 'PRIVACY POLICY', 'Copyright']:
                            text_parts.append(text)

                elif hasattr(sibling, 'name'):
                    if sibling.name == 'b':
                        field_text = sibling.get_text().strip().lower().replace(':', '')
                        if field_text in known_fields:
                            current_field = field_text.replace(' ', '_')

                    # Extract media
                    elif sibling.name == 'img' and seen_shape:
                        src = sibling.get('src', '')
                        if src and ('wpforms' in src or '/simages/' in src):
                            full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                            report.media_urls.append(full_url)

        # Join collected text
        if text_parts:
            report.description = text_parts[0] if text_parts else ""
            report.full_text = "\n\n".join(text_parts)

        # Enhanced media detection - look for ALL types of media
        # Images
        for img in soup.find_all('img'):
            src = img.get('src', '')
            if src and ('wpforms' in src or '/simages/' in src or '/uploads/' in src or '/media/' in src) and 'logo' not in src.lower():
                full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                if full_url not in report.media_urls:
                    report.media_urls.append(full_url)
                    log(f"📸 Found image: {src.split('/')[-1]}", "SUCCESS")

        # Videos
        for video in soup.find_all('video'):
            sources = video.find_all('source')
            if sources:
                for source in sources:
                    src = source.get('src', '')
                    if src:
                        full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                        if full_url not in report.media_urls:
                            report.media_urls.append(full_url)
                            log(f"🎥 Found video: {src.split('/')[-1]}", "SUCCESS")
            else:
                src = video.get('src', '')
                if src:
                    full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                    if full_url not in report.media_urls:
                        report.media_urls.append(full_url)
                        log(f"🎥 Found video: {src.split('/')[-1]}", "SUCCESS")

        # Links to media files
        media_extensions = ['.jpg', '.jpeg', '.png', '.gif', '.bmp', '.webp', '.tiff',
                           '.mp4', '.mov', '.avi', '.webm', '.m4v', '.mkv', '.wmv',
                           '.mp3', '.wav', '.m4a', '.pdf', '.doc', '.docx']
        for link in soup.find_all('a', href=True):
            href = link.get('href', '')
            if any(ext in href.lower() for ext in media_extensions):
                full_url = href if href.startswith('http') else f"https://nuforc.org{href}"
                if full_url not in report.media_urls:
                    report.media_urls.append(full_url)
                    log(f"📎 Found media file: {href.split('/')[-1]}", "SUCCESS")

        # Muse.ai embedded videos (common on NUFORC)
        html_str = str(content)
        muse_matches = re.findall(r'video:\s*"([^"]+)"', html_str)
        for video_id in muse_matches:
            muse_url = f"https://muse.ai/v/{video_id}"
            if muse_url not in report.media_urls:
                report.media_urls.append(muse_url)
                log(f"🎬 Found Muse.ai video: {video_id}", "SUCCESS")

        log(f"Report extracted: {len(report.full_text)} chars, {len(report.media_urls)} media", "SUCCESS")
        return report

    except Exception as e:
        log(f"Error extracting report {report_id}: {e}", "ERROR")
        return report

def generate_ai_summary(report: NuforcReport) -> bool:
    """
    Generate intelligent AI summary using Gemini
    """
    if not ai_model or not report.full_text:
        return False

    log(f"Generating AI summary for report {report.report_id}", "AI")

    try:
        # Build comprehensive data for Gemini analysis
        comprehensive_data = f"""
TEMPORAL DATA:
- Occurred: {report.occurred_date or 'Unknown'}
- Reported: {report.reported_date or 'Unknown'}
- Posted: {report.posted_date or 'Unknown'}

LOCATION & ENVIRONMENT:
- Location: {report.location or 'Unknown'}
- Location Details: {report.location_details or 'N/A'}
- Weather: {report.weather or 'Unknown'}
- Visibility: {report.visibility or 'Unknown'}
- Temperature: {report.temperature or 'Unknown'}
- Wind: {report.wind or 'Unknown'}
- Clouds: {report.clouds or 'Unknown'}
- Precipitation: {report.precipitation or 'Unknown'}

OBJECT CHARACTERISTICS:
- Shape: {report.shape or 'Unknown'}
- Color: {report.color or 'Unknown'}
- Estimated Size: {report.estimated_size or 'Unknown'}
- Apparent Size: {report.apparent_size or 'Unknown'}
- Characteristics: {report.characteristics or 'Unknown'}

OBSERVATION DETAILS:
- Duration: {report.duration or 'Unknown'}
- Witnesses: {report.witnesses or 'Unknown'}
- Viewed From: {report.viewed_from or 'Unknown'}
- Direction from Viewer: {report.direction_from_viewer or 'Unknown'}
- Direction Faced: {report.direction_faced or 'Unknown'}
- Angle of Elevation: {report.angle_of_elevation or 'Unknown'}
- Closest Distance: {report.closest_distance or 'Unknown'}
- Estimated Speed: {report.estimated_speed or 'Unknown'}
- Height/Altitude: {report.height or report.altitude or 'Unknown'}
- Distance: {report.distance or 'Unknown'}

EFFECTS & EVIDENCE:
- Electromagnetic Effects: {report.electromagnetic_effects or 'None reported'}
- Animal Reactions: {report.animal_reactions or 'None reported'}
- Physical Effects: {report.physical_effects or 'None reported'}
- Physiological Effects: {report.physiological_effects or 'None reported'}
- Trace Evidence: {report.trace_evidence or 'None reported'}
- Radar Contact: {report.radar_contact or 'None reported'}

MEDIA ATTACHED: {len(report.media_urls)} files

FULL WITNESS DESCRIPTION:
{report.full_text}
"""

        prompt = f"""
You are analyzing a comprehensive UFO sighting report from NUFORC. You have access to ALL available data fields.

{comprehensive_data}

Create an intelligent, engaging summary that incorporates ALL relevant details:

1. SUMMARY: 2-3 compelling sentences describing what the witness observed, incorporating key details like environment, object characteristics, and any unusual effects
2. KEY_POINTS: 4-6 most important details from ALL the data above (each on new line with • bullet)
3. CREDIBILITY: Assessment based on detail level, consistency, and specificity of the report

Format exactly like this:
SUMMARY: [2-3 compelling sentences using comprehensive data]
KEY_POINTS:
• [Point 1]
• [Point 2]
• [Point 3]
• [Point 4]
CREDIBILITY: [Assessment based on all available data]
"""

        response = ai_model.generate_content(prompt)
        ai_text = response.text

        # Parse structured response
        lines = ai_text.strip().split('\n')
        collecting_points = False
        key_points = []

        for line in lines:
            line = line.strip()
            if line.startswith('SUMMARY:'):
                report.ai_summary = line.replace('SUMMARY:', '').strip()
            elif line.startswith('KEY_POINTS:'):
                collecting_points = True
            elif line.startswith('CREDIBILITY:'):
                collecting_points = False
                # Could store credibility if needed
            elif collecting_points and line.startswith('•'):
                key_points.append(line[1:].strip())

        report.ai_key_points = key_points

        log(f"AI summary generated: {len(report.ai_summary or '')} chars", "SUCCESS")
        return True

    except Exception as e:
        log(f"AI summary failed for {report.report_id}: {e}", "ERROR")
        return False

def check_report_exists(external_id: str) -> bool:
    """
    Check if report already exists in UFOBeep database
    """
    try:
        response = requests.get(
            f"https://ufobeep.com/api/beep/external/{external_id}",
            timeout=10
        )
        return response.status_code == 200
    except:
        return False

def geocode_location(location_text: str) -> Optional[Dict[str, float]]:
    """
    Simple geocoding using Nominatim (OpenStreetMap)
    """
    if not location_text:
        return None

    try:
        import urllib.parse
        encoded_location = urllib.parse.quote(location_text)
        url = f"https://nominatim.openstreetmap.org/search?q={encoded_location}&format=json&limit=1"

        headers = {"User-Agent": "UFOBeep Research (+https://ufobeep.com/about)"}
        response = requests.get(url, headers=headers, timeout=10)

        if response.status_code == 200:
            data = response.json()
            if data:
                result = data[0]
                lat = float(result["lat"])
                lon = float(result["lon"])

                if -180 <= lon <= 180 and -90 <= lat <= 90:
                    log(f"📍 Geocoded '{location_text}' -> {lat}, {lon}", "SUCCESS")
                    return {"latitude": lat, "longitude": lon}

        log(f"⚠️ Could not geocode '{location_text}'", "WARNING")
        return None

    except Exception as e:
        log(f"❌ Geocoding error: {e}", "ERROR")
        return None

def upload_media_to_ufobeep(beep_id: str, media_urls: List[str]):
    """
    Download media from NUFORC and upload to UFOBeep
    """
    if not media_urls:
        return

    log(f"📤 Uploading {len(media_urls)} media files to beep {beep_id}", "SUCCESS")

    headers = {"User-Agent": "UFOBeep Research (+https://ufobeep.com/about)"}

    for i, media_url in enumerate(media_urls, 1):
        try:
            # Skip Muse.ai videos (they're embedded players)
            if 'muse.ai' in media_url:
                log(f"⏭️  Skipping Muse.ai video {i}/{len(media_urls)} (embedded player)", "INFO")
                continue

            filename = media_url.split('/')[-1] or f"media_{i}"
            log(f"📥 Downloading {i}/{len(media_urls)}: {filename}", "INFO")

            # Download from NUFORC
            response = requests.get(media_url, headers=headers, timeout=30)
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
                log(f"✅ Uploaded {filename}", "SUCCESS")
            else:
                log(f"⚠️ Failed to upload {filename}: {upload_response.status_code}", "WARNING")

        except Exception as e:
            log(f"❌ Error uploading media {filename}: {e}", "ERROR")
            continue

def create_ufobeep_entry(report: NuforcReport) -> bool:
    """
    Create enhanced UFOBeep entry with AI summary
    """
    external_id = f"nuforc_{report.report_id}"

    # Skip if already exists
    if check_report_exists(external_id):
        log(f"Report {report.report_id} already exists - skipping", "WARNING")
        return True

    log(f"Creating UFOBeep entry for {report.report_id}", "SUCCESS")

    try:
        # Parse occurred date
        occurred_iso = None
        if report.occurred_date:
            try:
                # Handle various NUFORC date formats
                date_part = report.occurred_date.split()[0]
                occurred_dt = datetime.strptime(date_part, "%Y-%m-%d")
                occurred_iso = occurred_dt.replace(tzinfo=timezone.utc).isoformat()
            except:
                pass

        # Build enhanced title with report ID for reference
        shape_text = f" {report.shape.title()}" if report.shape else ""
        location_text = f" in {report.city}" if report.city else ""
        title = f"NUFORC{shape_text} Sighting{location_text} (#{report.report_id})"

        # Use AI summary or fallback to description (clean, no URL clutter)
        description = report.ai_summary or report.description or "UFO sighting report with AI analysis available"

        alert_id = str(uuid.uuid4())

        beep_data = {
            "id": alert_id,
            "device_id": f"nuforc_stealth_{report.report_id}",
            "username": "NUFORC",
            "source": "nuforc",
            "external_id": external_id,
            "tier": 2,

            "title": title,
            "description": description,

            "occurred_at": occurred_iso or datetime.now().isoformat(),
            "date_posted": datetime.now().isoformat(),
            "shape": report.shape,
            "duration": report.duration,

            # CRITICAL: Add report_url for "View original report" link
            "external_url": report.url,
            "report_url": report.url,  # Try both field names

            "enrichment_data": {
                "nuforc_report_id": report.report_id,
                "external_url": report.url,  # CRITICAL: This makes the link clickable in app!
                "full_text": f"""{report.full_text}

Original NUFORC report: {report.url}""",

                # CRITICAL: location_raw is what UFOBeep uses for NUFORC location names!
                "location_raw": report.location,

                # UI settings (these ARE preserved by UFOBeep)
                "hide_witness_widget": False,
                "hide_location_widget": False,
                "hide_environmental_analysis": True,
                "hide_actions": True,
                "is_historical_report": True,
                "source_name": "NUFORC"
            }
        }

        # Add location with geocoding
        if report.location:
            # Try to geocode for lat/lng first
            coords = geocode_location(report.location)
            if coords:
                beep_data["location"] = {
                    "latitude": coords["latitude"],
                    "longitude": coords["longitude"],
                    "name": report.location,
                    "address": report.location,  # Try different field names
                    "location_name": report.location,
                    "display_name": report.location
                }
            else:
                # Fallback: try just city if we have it
                if report.city:
                    city_coords = geocode_location(f"{report.city}, {report.state or 'USA'}")
                    if city_coords:
                        location_name = f"{report.city}, {report.state}" if report.state else report.city
                        beep_data["location"] = {
                            "latitude": city_coords["latitude"],
                            "longitude": city_coords["longitude"],
                            "name": location_name,
                            "address": location_name,
                            "location_name": location_name,
                            "display_name": location_name
                        }
        elif report.city:
            # Fallback to city, state
            location_name = f"{report.city}, {report.state}" if report.state else report.city
            beep_data["location"] = {"name": location_name}

        # Debug: Log what we're sending
        log(f"🔍 Sending external_url: {beep_data.get('external_url')}", "INFO")
        log(f"🔍 Full location object being sent: {beep_data.get('location')}", "INFO")

        # Log the complete payload structure for debugging
        if beep_data.get('location'):
            location_obj = beep_data['location']
            log(f"🔍 Location fields: name={location_obj.get('name')}, lat={location_obj.get('latitude')}, lng={location_obj.get('longitude')}", "INFO")

        # Debug: Log the full payload being sent
        log(f"🔍 FULL PAYLOAD TO UFOBEEP:", "INFO")
        import json
        log(f"🔍 {json.dumps(beep_data, indent=2)[:1000]}...", "INFO")

        # Create beep
        response = requests.post(
            "https://ufobeep.com/api/beep",
            json=beep_data,
            timeout=30
        )

        if response.status_code in [200, 201]:
            alert_response = response.json()
            created_id = alert_response.get('sighting_id')
            log(f"UFOBeep entry created: {created_id}", "SUCCESS")

            # Upload media if present
            if report.media_urls:
                upload_media_to_ufobeep(created_id, report.media_urls)

            return True
        else:
            log(f"Failed to create beep: {response.status_code} - {response.text[:200]}", "ERROR")
            return False

    except Exception as e:
        log(f"Error creating UFOBeep entry: {e}", "ERROR")
        return False

def main():
    """
    Main stealth scraping pipeline
    """
    if len(sys.argv) != 2:
        print("Usage: python3 nuforc_stealth.py <date>")
        print("Examples:")
        print("  python3 nuforc_stealth.py 2025-10-25")
        print("  python3 nuforc_stealth.py yesterday")
        print("  python3 nuforc_stealth.py today")
        sys.exit(1)

    date_input = sys.argv[1]

    # Handle date tokens
    if date_input == "yesterday":
        date_str = (datetime.now() - timedelta(days=1)).strftime("%Y-%m-%d")
    elif date_input == "today":
        date_str = datetime.now().strftime("%Y-%m-%d")
    else:
        date_str = date_input

    log("🥷 NUFORC STEALTH SCRAPER ACTIVATED", "STEALTH")
    log("=" * 60, "INFO")
    log(f"Target date: {date_str}", "INFO")
    log(f"AI Enhancement: {'Enabled' if ai_model else 'Disabled'}", "AI")
    log("=" * 60, "INFO")

    browser = None

    try:
        # Setup stealth browser
        browser, context, page = setup_stealth_browser()

        # Get daily report links
        report_links = get_daily_report_links(page, date_str)

        if not report_links:
            log(f"No reports found for {date_str}", "WARNING")
            return

        log(f"Processing {len(report_links)} reports with maximum stealth...", "STEALTH")

        success_count = 0
        error_count = 0

        for i, link_data in enumerate(report_links, 1):
            report_id = link_data['report_id']
            report_url = link_data['url']

            log(f"[{i}/{len(report_links)}] Processing report {report_id}", "INFO")

            try:
                # Extract full report
                report = extract_full_report(page, report_url, report_id)

                if not report.full_text:
                    log(f"No content extracted for {report_id} - skipping", "WARNING")
                    continue

                # Generate AI summary if available
                if ai_model:
                    generate_ai_summary(report)

                # Create UFOBeep entry
                if create_ufobeep_entry(report):
                    success_count += 1
                else:
                    error_count += 1

                # Human-like delay between reports (CRITICAL for stealth)
                if i < len(report_links):  # Don't delay after last report
                    human_delay(10.0, 18.0)

            except Exception as e:
                log(f"Error processing {report_id}: {e}", "ERROR")
                error_count += 1
                human_delay(5.0, 10.0)  # Shorter delay on errors
                continue

        log("=" * 60, "INFO")
        log("🎉 STEALTH MISSION COMPLETE", "SUCCESS")
        log(f"✅ Successful: {success_count}", "SUCCESS")
        log(f"❌ Errors: {error_count}", "ERROR")
        log(f"📊 Success rate: {success_count/(success_count+error_count)*100:.1f}%" if (success_count+error_count) > 0 else "N/A", "INFO")
        log("=" * 60, "INFO")

    except Exception as e:
        log(f"Fatal error: {e}", "ERROR")
        log(f"Traceback: {traceback.format_exc()}", "ERROR")

    finally:
        if browser:
            browser.close()
            log("Stealth browser closed", "BROWSER")

if __name__ == "__main__":
    main()