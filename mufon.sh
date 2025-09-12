#!/bin/bash
# MUFON Complete Pipeline - Self-contained script
# Usage: ./mufon.sh 2025-01-27
# Usage: ./mufon.sh yesterday 
# Usage: ./mufon.sh today
# Usage: ./mufon.sh 2025-08-01:2025-08-15   # date range (inclusive)
# Usage: ./mufon.sh yesterday:today         # relative range

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./mufon.sh <date or range> [--retry <log_file>]"
    echo "Examples:"
    echo "  ./mufon.sh 2025-01-27"
    echo "  ./mufon.sh yesterday"
    echo "  ./mufon.sh today"
    echo "  ./mufon.sh 2025-08-01:2025-08-15"
    echo "  ./mufon.sh yesterday:today"
    echo "  ./mufon.sh --retry logs/mufon_import_20250912_143022.log"
    exit 1
fi

# Check for retry mode
if [ "$1" = "--retry" ]; then
    if [ $# -ne 2 ]; then
        echo "Usage: ./mufon.sh --retry <log_file>"
        exit 1
    fi
    
    LOG_PATTERN="$2"
    
    # Expand glob pattern and check files exist
    LOG_FILES=$(ls $LOG_PATTERN 2>/dev/null)
    
    if [ -z "$LOG_FILES" ]; then
        echo "❌ No log files found matching: $LOG_PATTERN"
        exit 1
    fi
    
    echo "🔍 Analyzing failures in: $LOG_PATTERN"
    echo "📁 Found log files:"
    echo "$LOG_FILES"
    echo ""
    
    # Extract failed dates from all matching log files
    FAILED_DATES=$(grep -E "❌|⚠️|failed|Failed|ERROR" $LOG_FILES | \
                   grep -oE "20[0-9]{2}-[0-9]{2}-[0-9]{2}" | \
                   sort | uniq)
    
    if [ -z "$FAILED_DATES" ]; then
        echo "✅ No failed dates found in log file"
        exit 0
    fi
    
    echo "📅 Found failed dates:"
    echo "$FAILED_DATES"
    echo ""
    
    read -p "Retry these dates? (y/N): " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        echo "❌ Aborted by user"
        exit 0
    fi
    
    echo "🔄 Retrying failed dates..."
    success_count=0
    fail_count=0
    
    for date in $FAILED_DATES; do
        echo ""
        echo "🔄 Retrying: $date"
        
        # Recursively call mufon.sh for this date
        if ./mufon.sh "$date"; then
            echo "✅ Retry successful for $date"
            ((success_count++))
        else
            echo "❌ Retry failed for $date"
            ((fail_count++))
        fi
        
        sleep 3
    done
    
    echo ""
    echo "🎉 Retry process complete:"
    echo "  ✅ Successful: $success_count"
    echo "  ❌ Failed: $fail_count"
    exit 0
fi

DATE_INPUT="$1"

# Create log file with timestamp
LOG_FILE="logs/mufon_import_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs

# Function to log to both console and file
log_both() {
    local message="$1"
    echo "$message"
    echo "$message" >> "$LOG_FILE"
}

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

# Compute display header but delay the actual run until after env is loaded
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
    echo "🚀 MUFON Pipeline Starting for range $START_DATE to $END_DATE"
    echo "============================================================"
else
    DATE=$(resolve_date_token "$DATE_INPUT") || true
    if [ -z "$DATE" ]; then
        echo "❌ Invalid date: '$DATE_INPUT'"
        exit 1
    fi
    echo "🚀 MUFON Pipeline Starting for $DATE"
    echo "===================================="
fi

# Change to working directory
# cd /home/ufobeep/ufobeep

# Load environment credentials
echo "✅ Loading MUFON credentials..."
if [ -f /home/ufobeep/.secrets/.env.mufon ]; then
    source /home/ufobeep/.secrets/.env.mufon
elif [ -f .env.mufon ]; then
    source .env.mufon
else
    echo "❌ .env.mufon not found"
fi

if [ -z "$MUFON_USERNAME" ] || [ -z "$MUFON_PASSWORD" ]; then
    echo "❌ MUFON credentials not found in .env.mufon"
    exit 1
fi

# Export credentials for embedded Python script
export MUFON_USERNAME
export MUFON_PASSWORD

# Bash function to run the embedded Python for a single date
run_mufon_for_date() {
    local RUN_DATE="$1"
    echo ""
    echo "==============================================="
    echo "Processing MUFON data for: $RUN_DATE"
    echo "==============================================="
    echo "🔍 Running MUFON extraction and import for $RUN_DATE..."
    log_both "🎯 Starting MUFON import for $RUN_DATE"
    python3 - "$RUN_DATE" << 'EOF'
#!/usr/bin/env python3
import sys
import os
import time
import json
import requests
from datetime import datetime, timezone
from playwright.sync_api import sync_playwright, TimeoutError as PlaywrightTimeout
import httpx
import re
from typing import Optional, List, Dict
import random
import traceback

def log(message):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}")

def random_delay(min_seconds=1, max_seconds=5):
    """Add random delay to avoid bot detection"""
    delay = random.uniform(min_seconds, max_seconds)
    time.sleep(delay)

def retry_with_backoff(func, max_retries=3, initial_delay=5):
    """Retry function with exponential backoff"""
    for attempt in range(max_retries):
        try:
            return func()
        except Exception as e:
            if attempt == max_retries - 1:
                raise
            delay = initial_delay * (2 ** attempt) + random.uniform(0, 2)
            log(f"⚠️ Attempt {attempt + 1} failed: {str(e)[:100]}")
            log(f"🔄 Retrying in {delay:.1f} seconds...")
            time.sleep(delay)

def safe_browser_operation(operation, context_msg="Browser operation"):
    """Safely execute browser operations with error handling"""
    try:
        return operation()
    except PlaywrightTimeout as e:
        log(f"⚠️ {context_msg} timeout: {e}")
        raise
    except Exception as e:
        log(f"❌ {context_msg} error: {e}")
        log(f"📍 Stack trace: {traceback.format_exc()}")
        raise

class UFOClassifier:
    """Classifies UFOs based on description text with extended pattern matching"""
    
    def __init__(self):
        # UFO type patterns based on user's requested classifications
        self.classification_patterns = {
            "triangle": [
                r"triangl\w+", r"three.*light", r"delta.*shape", r"arrow.*shape",
                r"three.*corner", r"v.*shaped?", r"chevron"
            ],
            "disc": [
                r"disc\w*", r"saucer", r"round.*craft", r"circular.*object",
                r"disk\w*", r"plate.*shaped?"
            ],
            "sphere": [
                r"sphere\w*", r"ball.*shaped?", r"orb\w*", r"round.*ball",
                r"spherical", r"globe.*shaped?"
            ],
            "cigar": [
                r"cigar\w*", r"cylinder\w*", r"tube.*shaped?", r"elongated.*object",
                r"capsule.*shaped?", r"oblong.*craft"
            ],
            "light": [
                r"bright.*light", r"single.*light", r"white.*light", r"glowing.*light",
                r"beam.*light", r"flash\w*.*light", r"fireball", r"flash"
            ],
            "boomerang": [
                r"boomerang", r"v.*wing", r"crescent", r"banana.*shaped?"
            ],
            "diamond": [
                r"diamond.*shaped?", r"rhomb\w+", r"kite.*shaped?"
            ],
            "rectangle": [
                r"rectangl\w+", r"square.*craft", r"box.*shaped?", r"cubic",
                r"rectangular.*object", r"square.*rectangle"
            ],
            "oval": [
                r"oval\w*", r"egg.*shaped?", r"elliptical", r"oblong"
            ],
            "cone": [
                r"cone.*shaped?", r"conical", r"funnel.*shaped?"
            ],
            "cross": [
                r"cross.*shaped?", r"cruciform", r"plus.*shaped?"
            ],
            "cylinder": [
                r"cylinder\w*", r"cylindrical", r"barrel.*shaped?"
            ],
            "dumbbell": [
                r"dumbbell", r"dumbell", r"barbell", r"hourglass"
            ],
            "teardrop": [
                r"tear.*drop", r"teardrop", r"droplet.*shaped?"
            ],
            "tic-tac": [
                r"tic.*tac", r"pill.*shaped?", r"capsule"
            ],
            "bullet": [
                r"bullet.*missile", r"bullet.*shaped?", r"missile.*shaped?"
            ],
            "saturn": [
                r"saturn.*like", r"ringed.*object", r"hat.*shaped?"
            ],
            "starlike": [
                r"star.*like", r"stellar", r"point.*light"
            ],
            "blimp": [
                r"blimp", r"airship", r"dirigible"
            ]
        }
    
    def classify(self, description: str, title: str = "") -> Dict[str, any]:
        """Classify UFO based on description and title"""
        if not description and not title:
            return {"type": "unknown", "confidence": 0.0, "keywords": []}
        
        # Combine title and description for analysis
        text = f"{title} {description}".lower()
        
        # Score each classification type
        type_scores = {}
        matched_keywords = {}
        
        for ufo_type, patterns in self.classification_patterns.items():
            score = 0
            keywords = []
            
            for pattern in patterns:
                matches = re.findall(pattern, text, re.IGNORECASE)
                if matches:
                    score += len(matches) * 2
                    keywords.extend(matches)
            
            if score > 0:
                type_scores[ufo_type] = score
                matched_keywords[ufo_type] = keywords
        
        # If no strong classification, try fallback analysis
        if not type_scores:
            return self._fallback_classification(text)
        
        # Find best classification
        best_type = max(type_scores.keys(), key=lambda k: type_scores[k])
        max_score = type_scores[best_type]
        
        # Calculate confidence (0.0 to 1.0)
        confidence = min(max_score / 10.0, 1.0)
        
        return {
            "type": best_type,
            "confidence": confidence,
            "keywords": matched_keywords.get(best_type, []),
            "all_scores": type_scores
        }
    
    def _fallback_classification(self, text: str) -> Dict[str, any]:
        """Fallback classification for unclear descriptions"""
        if any(word in text for word in ["round", "circular", "ball"]):
            return {"type": "sphere", "confidence": 0.3, "keywords": ["round"]}
        
        if any(word in text for word in ["light", "glow", "bright"]):
            return {"type": "light", "confidence": 0.4, "keywords": ["light"]}
        
        return {"type": "unknown", "confidence": 0.0, "keywords": []}


def reverse_geocode(location_text: str) -> Optional[Dict[str, any]]:
    """Extract location from text and get coordinates using Nominatim"""
    if not location_text or len(location_text.strip()) < 3:
        return None
    
    text = location_text.strip()
    
    # Clean up MUFON location format like "Acolita, CA, US" 
    cleaned_location = re.sub(r',?\s*(US|USA)$', '', text, flags=re.IGNORECASE).strip()
    
    # Enhanced regex to handle city names with special characters, numbers, etc.
    # Examples: "Las Vegas, NV", "St. Louis, MO", "New York City, NY", "Acolita, CA"
    if re.match(r'^[A-Za-z0-9\s\.\-\']+,\s*[A-Z]{2}$', cleaned_location):
        search_location = cleaned_location
    else:
        # Extract location patterns from descriptions - enhanced patterns
        location_patterns = [
            r"in\s+([A-Za-z0-9\s\.\-\']+),\s*([A-Z]{2})\b",  # "in City, ST"
            r"near\s+([A-Za-z0-9\s\.\-\']+),\s*([A-Z]{2})\b",  # "near City, ST"
            r"from\s+([A-Za-z0-9\s\.\-\']+),\s*([A-Z]{2})\b",  # "from City, ST"
            r"([A-Za-z0-9\s\.\-\']+),\s*([A-Z]{2})\b",          # "City, ST"
        ]
        
        search_location = None
        for pattern in location_patterns:
            match = re.search(pattern, text, re.IGNORECASE)
            if match:
                city = match.group(1).strip()
                state = match.group(2).strip()
                if len(city) > 2 and len(state) == 2:
                    search_location = f"{city}, {state}"
                    break
        
        # If no structured location found but we have text, try cleaning and using as-is
        if not search_location and len(cleaned_location) > 5:
            # For locations like "Acolita" or other single-word places, try with generic search
            search_location = cleaned_location
            log(f"🔍 Using fallback location search for: '{search_location}'")
    
    try:
        # Use Nominatim for geocoding
        import time
        time.sleep(1.2)  # Rate limit
        
        url = "https://nominatim.openstreetmap.org/search"
        params = {
            "q": search_location,
            "format": "json",
            "limit": 1,
            "countrycodes": "us"
        }
        
        headers = {"User-Agent": "UFOBeep-MUFON/1.0 (+https://ufobeep.com)"}
        
        response = requests.get(url, params=params, headers=headers, timeout=15)
        if response.status_code == 200:
            data = response.json()
            if data:
                result = data[0]
                lat = float(result["lat"])
                lon = float(result["lon"])
                
                # Validate coordinates are in US bounds
                if -180 <= lon <= -60 and 20 <= lat <= 70:
                    return {
                        "location": search_location,
                        "latitude": lat,
                        "longitude": lon,
                        "display_name": result.get("display_name", search_location)
                    }
                else:
                    log(f"⚠️ Invalid coordinates for '{search_location}': {lat}, {lon}")
        else:
            log(f"⚠️ Geocoding API error {response.status_code} for '{search_location}'")
    except Exception as e:
        log(f"⚠️ Geocoding failed for '{search_location}': {e}")
    
    return None

def create_browser_session(playwright_instance):
    """Create a new browser session with anti-detection measures"""
    browser = playwright_instance.chromium.launch(
        headless=True,
        args=[
            '--no-sandbox',
            '--disable-blink-features=AutomationControlled',
            '--disable-web-security',
            '--disable-features=VizDisplayCompositor',
            '--user-agent=Mozilla/5.0 (X11; Linux x86_64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Safari/537.36'
        ]
    )
    
    # Check for existing cookies
    cookies_file = "/tmp/mufon_cookies.json"
    if os.path.exists(cookies_file):
        log("🍪 Loading existing authentication cookies...")
        context = browser.new_context(storage_state=cookies_file)
    else:
        log("🔐 No stored cookies, will authenticate fresh...")
        context = browser.new_context()
    
    page = context.new_page()
    
    # Set extra headers to avoid detection
    page.set_extra_http_headers({
        'Accept-Language': 'en-US,en;q=0.9',
        'Accept-Encoding': 'gzip, deflate, br',
        'Accept': 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8',
        'Connection': 'keep-alive',
        'Upgrade-Insecure-Requests': '1'
    })
    
    return browser, context, page

def extract_and_import_mufon(date_str):
    date_obj = datetime.strptime(date_str, "%Y-%m-%d")
    month, day, year = date_obj.month, date_obj.day, date_obj.year
    
    log(f"🎯 Processing MUFON cases for {date_str}")
    
    # Initialize classifier
    classifier = UFOClassifier()
    
    def run_extraction():
        with sync_playwright() as p:
            browser, context, page = create_browser_session(p)
        
            try:
                # AUTHENTICATE OR TEST EXISTING COOKIES
                log("🔐 Testing MUFON authentication...")
                
                def authenticate():
                    safe_browser_operation(
                        lambda: page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", timeout=30000),
                        "Initial page load"
                    )
                    # OPTIMIZED: Longer initial wait to avoid first-time failure
                    random_delay(4, 6)
                    
                    safe_browser_operation(
                        lambda: page.wait_for_load_state('networkidle', timeout=20000),
                        "Wait for page load"
                    )
                    
                    # Additional settling time for MUFON's slow loading
                    time.sleep(2)
                    
                    # Check if we got redirected to login (cookies expired) or if page looks wrong
                    current_url = page.url
                    page_content = page.content()
                    
                    # More aggressive detection of auth failure
                    auth_failed = (
                        "signIn" in current_url or 
                        "login" in current_url or
                        "signin" in current_url.lower() or
                        "authentication" in page_content.lower() or
                        "please log in" in page_content.lower() or
                        len(page_content) < 5000  # Page too small, likely auth issue
                    )
                    
                    if auth_failed:
                        # Clear bad cookies before attempting fresh login
                        cookies_file = "/tmp/mufon_cookies.json"
                        if os.path.exists(cookies_file):
                            log("🗑️ Clearing expired cookies...")
                            os.remove(cookies_file)
                        log("🔐 Cookies expired, performing fresh login...")
                        
                        mufon_user = os.getenv('MUFON_USERNAME')
                        mufon_pass = os.getenv('MUFON_PASSWORD')
                        
                        if not mufon_user or not mufon_pass:
                            log("❌ MUFON credentials not found")
                            raise Exception("Missing MUFON credentials")
                        
                        log("📝 Filling login form...")
                        safe_browser_operation(
                            lambda: page.fill("input[name='loginName']", mufon_user, timeout=10000),
                            "Fill username"
                        )
                        random_delay(0.5, 1.5)
                        
                        safe_browser_operation(
                            lambda: page.fill("input[name='loginPassword']", mufon_pass, timeout=10000),
                            "Fill password"
                        )
                        random_delay(0.5, 1.5)
                        
                        safe_browser_operation(
                            lambda: page.press("input[name='loginPassword']", "Enter"),
                            "Submit login form"
                        )
                        
                        safe_browser_operation(
                            lambda: page.wait_for_load_state('networkidle', timeout=15000),
                            "Wait after login submit"
                        )
                        random_delay(2, 4)
                        
                        # Verify authentication worked
                        current_url = page.url
                        page_content = page.content()
                        
                        # Check if login failed
                        login_failed = (
                            "signIn" in current_url or 
                            "login" in current_url or
                            "signin" in current_url.lower() or
                            "invalid" in page_content.lower() or
                            "incorrect" in page_content.lower() or
                            len(page_content) < 5000
                        )
                        
                        if login_failed:
                            log("❌ AUTHENTICATION FAILED - clearing bad cookies")
                            cookies_file = "/tmp/mufon_cookies.json"
                            if os.path.exists(cookies_file):
                                os.remove(cookies_file)
                            raise Exception("Authentication failed")
                        
                        # Save cookies for reuse
                        log("💾 Saving authentication cookies...")
                        cookies_file = "/tmp/mufon_cookies.json"
                        context.storage_state(path=cookies_file)
                        
                        # Go to search page after login
                        log("🔍 Navigating to search page after login...")
                        safe_browser_operation(
                            lambda: page.goto("https://mufon.z2systems.com/np/clients/mufon/neonPage.jsp?pageId=19&", timeout=30000),
                            "Navigate to search page"
                        )
                        random_delay(3, 5)
                    
                    log("✅ Authentication successful - ready to search")
                
                # Try authentication with retries (reduced delay since first attempt is now optimized)
                retry_with_backoff(authenticate, max_retries=3, initial_delay=2)
                
                # Get iframe and set date fields
                def setup_search():
                    iframe = page.frame_locator("iframe")
                    
                    log(f"📅 Setting date fields for {month}/{day}/{year}...")
                    
                    # Event Date FROM
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_lo__month']").select_option(str(month), timeout=10000),
                        "Select FROM month"
                    )
                    random_delay(0.3, 0.8)
                    
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_lo__day']").select_option(str(day), timeout=10000),
                        "Select FROM day"
                    )
                    random_delay(0.3, 0.8)
                    
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_lo__year']").select_option(str(year), timeout=10000),
                        "Select FROM year"
                    )
                    random_delay(0.3, 0.8)
                    
                    # Event Date TO (same as FROM for single day)
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_hi__month']").select_option(str(month), timeout=10000),
                        "Select TO month"
                    )
                    random_delay(0.3, 0.8)
                    
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_hi__day']").select_option(str(day), timeout=10000),
                        "Select TO day"
                    )
                    random_delay(0.3, 0.8)
                    
                    safe_browser_operation(
                        lambda: iframe.locator("select[name='event_date_hi__year']").select_option(str(year), timeout=10000),
                        "Select TO year"
                    )
                    random_delay(0.5, 1.0)
                    
                    # Submit search
                    log("🚀 Submitting search...")
                    safe_browser_operation(
                        lambda: iframe.locator("input[type='submit'][value='SUBMIT']").first.click(timeout=10000),
                        "Submit search form"
                    )
                    log("⏳ Waiting for search results...")
                    random_delay(8, 12)
                
                # Try search setup with retries
                retry_with_backoff(setup_search, max_retries=2, initial_delay=3)
                
                # Get results
                def get_results():
                    iframe = page.frame_locator("iframe")
                    return safe_browser_operation(
                        lambda: iframe.locator("table tbody tr").all(),
                        "Get search results"
                    )
                
                rows = retry_with_backoff(get_results, max_retries=2, initial_delay=3)
                log(f"📊 Found {len(rows)} result rows")
                
                # Process each case
                imported_count = 0
                
                for i, row in enumerate(rows, 1):
                    try:
                        cells = safe_browser_operation(
                            lambda: row.locator("td").all(),
                            f"Get cells for row {i}"
                        )
                        if len(cells) >= 4:
                            # Extract cell text safely
                            row_number = safe_browser_operation(
                                lambda: cells[0].inner_text().strip(),
                                f"Get row number for row {i}"
                            )
                            report_date = safe_browser_operation(
                                lambda: cells[1].inner_text().strip(),
                                f"Get report date for row {i}"
                            )
                            sighting_datetime = safe_browser_operation(
                                lambda: cells[2].inner_text().strip(),
                                f"Get sighting datetime for row {i}"
                            )
                            short_description = safe_browser_operation(
                                lambda: cells[3].inner_text().strip(),
                                f"Get short description for row {i}"
                            )
                            location = safe_browser_operation(
                                lambda: cells[4].inner_text().strip() if len(cells) > 4 else "Unknown Location",
                                f"Get location for row {i}"
                            )
                        
                        log(f"🔍 RAW PARSE - Row: '{row_number}', ReportDate: '{report_date}', SightingDT: '{sighting_datetime[:30]}', Desc: '{short_description[:30]}', Loc: '{location[:20]}'")
                        
                        # Skip header rows and invalid cases
                        if not row_number or row_number in ["", "#", "Case"] or not row_number.isdigit():
                            continue
                        
                        log(f"🔍 Processing Row #{row_number}")
                        
                        # DEBUG: Show ALL elements in this row
                        all_elements = row.locator("*").all()
                        log(f"🔍 ROW ELEMENTS DEBUG: Found {len(all_elements)} total elements")
                        
                        inputs = row.locator("input").all()
                        buttons = row.locator("button").all() 
                        links = row.locator("a").all()
                        
                        log(f"🔍 ROW DEBUG: {len(inputs)} inputs, {len(buttons)} buttons, {len(links)} links")
                        
                        for i, inp in enumerate(inputs):
                            value = inp.get_attribute('value') or ''
                            type_attr = inp.get_attribute('type') or ''
                            onclick = inp.get_attribute('onclick') or ''
                            log(f"🔍 INPUT[{i}]: type='{type_attr}', value='{value}', onclick='{onclick}'")
                        
                        for i, btn in enumerate(buttons):
                            text = btn.inner_text().strip()
                            onclick = btn.get_attribute('onclick') or ''
                            log(f"🔍 BUTTON[{i}]: text='{text}', onclick='{onclick}'")
                        
                        for i, link in enumerate(links):
                            href = link.get_attribute('href') or ''
                            text = link.inner_text().strip()
                            log(f"🔍 LINK[{i}]: text='{text}', href='{href}'")
                        
                        # Get real case ID from VIEW button (single source of truth)
                        real_case_id = None
                        
                        # Extract case ID from VIEW button onclick attribute
                        for inp in inputs:
                            onclick = inp.get_attribute('onclick') or ''
                            value = inp.get_attribute('value') or ''
                            if 'VIEW' in value and 'id=' in onclick:
                                match = re.search(r'id=(\d+)', onclick)
                                if match:
                                    real_case_id = match.group(1)
                                    log(f"✅ Extracted real case ID from VIEW link: {real_case_id}")
                                    break
                        
                        # Skip if no case ID found
                        if not real_case_id:
                            log(f"⚠️ No VIEW button with case ID found, skipping row")
                            continue
                        
                        # Extract media files
                        media_files = []
                        if len(cells) > 4:
                            attachments_cell = cells[-1]
                            attachment_links = attachments_cell.locator('a')
                            for j in range(attachment_links.count()):
                                link = attachment_links.nth(j)
                                filename = link.inner_text().strip()
                                href = link.get_attribute('href')
                                
                                if filename and any(ext in filename.lower() for ext in ['.jpg', '.png', '.mp4', '.mov', '.jpeg']):
                                    if href and not href.startswith('http'):
                                        href = f"https://mufoncms.com{href}"
                                    elif href and href.startswith('http://'):
                                        href = href.replace('http://', 'https://')
                                    
                                    file_type = "image" if any(ext in filename.lower() for ext in ['.jpg', '.jpeg', '.png']) else "video"
                                    media_files.append({
                                        "filename": filename,
                                        "url": href,
                                        "type": file_type
                                    })
                        
                            log(f"📎 Found {len(media_files)} media files")
                            
                            # Get long description from VIEW page with error handling
                            long_description = short_description
                            if real_case_id:
                                def get_long_description():
                                    log("📖 Clicking VIEW for long description...")
                                    
                                    # Find the VIEW button we already identified  
                                    view_input = None
                                    for inp in inputs:
                                        value = safe_browser_operation(
                                            lambda: inp.get_attribute('value') or '',
                                            "Get input value"
                                        )
                                        if 'VIEW' in value:
                                            view_input = inp
                                            break
                                    
                                    if not view_input:
                                        log("⚠️ No VIEW button found")
                                        return short_description
                                    
                                    # Try popup approach first
                                    try:
                                        with page.expect_popup(timeout=15000) as popup_info:
                                            safe_browser_operation(
                                                lambda: view_input.click(),
                                                "Click VIEW button"
                                            )
                                        popup = popup_info.value
                                        safe_browser_operation(
                                            lambda: popup.wait_for_load_state("domcontentloaded", timeout=10000),
                                            "Wait for popup load"
                                        )
                                        random_delay(1, 3)
                                        
                                        # Extract text from popup
                                        try:
                                            safe_browser_operation(
                                                lambda: popup.wait_for_selector("pre", timeout=15000),
                                                "Wait for pre element"
                                            )
                                            popup_text = safe_browser_operation(
                                                lambda: popup.locator("pre").inner_text(),
                                                "Get pre text"
                                            )
                                        except:
                                            popup_text = safe_browser_operation(
                                                lambda: popup.locator("body").inner_text(),
                                                "Get body text"
                                            )
                                        
                                        # Clean up the text
                                        if popup_text:
                                            lines = popup_text.strip().split('\n')
                                            filtered_lines = []
                                            for line in lines:
                                                line_clean = line.strip()
                                                if line_clean and not any(header in line_clean for header in ['Long Description', 'Sighting Report', 'MUFON Case']):
                                                    filtered_lines.append(line_clean)
                                            
                                            if filtered_lines:
                                                result = '\n'.join(filtered_lines)
                                                log(f"📝 Found long description from popup: {result[:80]}...")
                                                safe_browser_operation(
                                                    lambda: popup.close(),
                                                    "Close popup"
                                                )
                                                return result
                                        
                                        safe_browser_operation(
                                            lambda: popup.close(),
                                            "Close popup"
                                        )
                                        
                                    except Exception as e:
                                        log(f"⚠️ Popup approach failed: {e}")
                                        # Fallback to same-page navigation
                                        try:
                                            before_url = page.url
                                            safe_browser_operation(
                                                lambda: view_input.click(),
                                                "Click VIEW (fallback)"
                                            )
                                            safe_browser_operation(
                                                lambda: page.wait_for_load_state("domcontentloaded", timeout=10000),
                                                "Wait for page load (fallback)"
                                            )
                                            random_delay(1, 3)
                                            
                                            if page.url != before_url:
                                                try:
                                                    safe_browser_operation(
                                                        lambda: page.wait_for_selector("pre", timeout=15000),
                                                        "Wait for pre (fallback)"
                                                    )
                                                    result = safe_browser_operation(
                                                        lambda: page.locator("pre").inner_text().strip(),
                                                        "Get pre text (fallback)"
                                                    )
                                                except:
                                                    result = safe_browser_operation(
                                                        lambda: page.locator("body").inner_text().strip(),
                                                        "Get body text (fallback)"
                                                    )
                                                
                                                log(f"📝 Found long description from same-page: {result[:80]}...")
                                                return result
                                        except Exception as fallback_e:
                                            log(f"⚠️ Fallback approach also failed: {fallback_e}")
                                    
                                    return short_description  # Return short description if all fails
                                
                                # Try to get long description with retries
                                try:
                                    long_description = retry_with_backoff(get_long_description, max_retries=2, initial_delay=2)
                                except Exception as e:
                                    log(f"⚠️ Failed to get long description after retries: {e}")
                                    long_description = short_description
                        
                        # Classify UFO type
                        classification = classifier.classify(long_description, short_description)
                        log(f"🔍 UFO Classification: {classification['type']} (confidence: {classification['confidence']:.2f})")
                        
                        # Generate alert ID before using it
                        import uuid
                        alert_id = str(uuid.uuid4())
                        
                        # Parse report_date to ISO timestamp for date_posted
                        date_posted_iso = None
                        if report_date:
                            try:
                                # Parse MUFON date format (YYYY-MM-DD) to ISO
                                parsed_date = datetime.strptime(report_date, "%Y-%m-%d")
                                date_posted_iso = parsed_date.replace(tzinfo=timezone.utc).isoformat()
                                log(f"📅 Parsed report_date: {report_date} -> {date_posted_iso}")
                            except Exception as e:
                                log(f"⚠️ Failed to parse report_date '{report_date}': {e}")
                        
                        # Store sighting_datetime - create ISO for API, keep raw for display
                        occurred_at_iso = None
                        mufon_datetime_display = None
                        if sighting_datetime:
                            # Keep raw MUFON format with <br> for display
                            mufon_datetime_display = sighting_datetime.replace('\n', '<br>').strip()
                            # Convert to basic ISO format for API (use date + 00:00:00Z)
                            occurred_at_iso = date_posted_iso or datetime.now(timezone.utc).isoformat()
                            log(f"🕐 MUFON datetime for display: '{mufon_datetime_display}', ISO for API: '{occurred_at_iso}'")
                        
                        # Generate SEO-friendly slug using shared generator
                        alert_data_for_slug = {
                            "id": alert_id,
                            "title": f"MUFON {classification['type'].title()} Report" if classification['confidence'] >= 0.3 else "MUFON Report",
                            "created_at": occurred_at_iso or date_posted_iso or datetime.now(timezone.utc).isoformat(),
                            "location": {"name": location},
                            "source": "mufon",
                            "short_url": None,  # Will be generated
                            "shape": classification['type'] if classification['confidence'] >= 0.3 else None
                        }
                        
                        # Generate SEO slug for multiple languages
                        import subprocess
                        import json
                        
                        slug_data_json = json.dumps(alert_data_for_slug)
                        
                        try:
                            # Generate English slug
                            result = subprocess.run(
                                ["node", "/home/mike/D/ufobeep/shared/generate_slug.js", slug_data_json, "en"],
                                capture_output=True,
                                text=True,
                                timeout=10
                            )
                            if result.returncode == 0:
                                english_slug = result.stdout.strip()
                                log(f"🔗 Generated English slug: {english_slug}")
                            else:
                                log(f"⚠️ Slug generation failed: {result.stderr}")
                                english_slug = None
                        except Exception as e:
                            log(f"⚠️ Slug generation error: {e}")
                            english_slug = None
                        
                        # Extract location and geocode
                        geo_data = None
                        try:
                            # First try the location field directly
                            if location and len(location.strip()) > 3:
                                geo_data = reverse_geocode(location)
                            
                            # If that fails, try extracting from description
                            if not geo_data and long_description:
                                geo_data = reverse_geocode(long_description)
                                
                            if geo_data:
                                log(f"📍 Geocoded: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")
                        except Exception as e:
                            log(f"⚠️ Geocoding error: {e}")
                        
                        # CREATE ALERT in production
                        log(f"📤 Creating alert for MUFON Case #{real_case_id}... (ID: {alert_id})")
                        
                        # Prepare alert data with correct API structure
                        # Title: Add "MUFON Report" for proper attribution
                        if classification['confidence'] >= 0.3:
                            title = f"MUFON {classification['type'].title()} Report"
                        else:
                            title = "MUFON Report"
                        
                        # Use clean description with location but without other duplicate metadata
                        # Frontend will handle displaying enrichment data separately
                        clean_description = long_description if long_description else ""
                        if clean_description:
                            clean_description += f"\n\n📍 Location: {location}"
                        

                        alert_data = {
                            "id": alert_id,  # Pass the pre-generated ID
                            "device_id": f"mufon_import_{real_case_id}",
                            "title": title,
                            "description": clean_description,  # Use clean description without metadata
                            "username": "MUFON",
                            "source": "mufon",
                            "external_id": f"mufon_{real_case_id}",  # Populate external_id field
                            "tier": 2,  # MUFON cases are tier 2 (investigated reports, high quality)
                            "date_posted": date_posted_iso,  # Populate date_posted field
                            "occurred_at": occurred_at_iso,  # Include the parsed occurrence timestamp
                            "report_url": f"https://mufon.com/case/{real_case_id}",  # Direct MUFON case URL
                            "shape": classification['type'] if classification['confidence'] > 0.3 else None,  # UFO shape
                            "duration": None  # Duration not available in MUFON data currently
                        }
                        
                        # Add location - use geocoded data if available, otherwise keep original location text
                        if geo_data:
                            alert_data["location"] = {
                                "latitude": geo_data["latitude"],
                                "longitude": geo_data["longitude"],
                                "name": geo_data["location"]
                            }
                        elif location and location.strip():
                            # Keep the original location text exactly as provided - no coordinates
                            log(f"⚠️ No coordinates for case #{real_case_id}, keeping original location: '{location}'")
                            alert_data["location"] = {
                                "name": location.strip()
                                # No latitude/longitude - proximity alerts will be skipped but data is saved
                            }
                        # If no location at all, don't include location field
                        
                        # Store all enrichment data (classification, geocoding, etc.) 
                        enrichment_data = {
                            "classification": classification,
                            "geocoding": geo_data,
                            # MUFON-specific fields (matching UI expectations)
                            "mufon_case_number": real_case_id,  # UI expects mufon_case_number
                            "reported_when": mufon_datetime_display or sighting_datetime,  # UI expects reported_when for sighting date
                            "database_when": report_date,        # UI expects database_when for report date
                            # Legacy fields (keep for compatibility)
                            "mufon_case_id": real_case_id,
                            "report_date": report_date,
                            "sighting_datetime": sighting_datetime,
                            "occurred_at": occurred_at_iso,  # Proper ISO timestamp for occurred_at
                            "location_raw": location,
                            "short_description": short_description,
                            "long_description": long_description,
                            "external_id": f"mufon_{real_case_id}",
                            "external_url": f"https://mufon.com/case/{real_case_id}",
                            "has_media": len(media_files) > 0,
                            # SEO slug data
                            "seo_slug_en": english_slug,  # Store generated slug for SEO
                            "shape": classification['type'] if classification['confidence'] >= 0.3 else None,
                            # Hide widgets for MUFON alerts
                            "hide_witness_widget": True,
                            "hide_location_widget": True
                        }
                        
                        # Add media files to the alert payload
                        if media_files:
                            alert_data["media_info"] = {"files": media_files}
                        
                        # Use correct parameter name for API
                        alert_data["enrichment_data"] = enrichment_data
                        
                        # Create the alert via API
                        alert_id = None
                        try:
                            response = requests.post(
                                "https://ufobeep.com/api/beep", 
                                json=alert_data,
                                timeout=30
                            )
                            if response.status_code in [200, 201]:
                                alert_response = response.json()
                                # Get alert_id from the sighting_id field
                                alert_id = alert_response.get('sighting_id')
                                log(f"✅ Created alert: {alert_id}")
                                log(f"DEBUG: API Response keys: {list(alert_response.keys())}")
                            else:
                                log(f"❌ Failed to create alert for case #{real_case_id}: {response.status_code}")
                                continue  # Skip media upload if alert creation failed
                        except Exception as e:
                            log(f"❌ Alert creation error: {e}")
                            continue  # Skip media upload if alert creation failed
                        
                        log(f"📤 ALERT DETAILS:")
                        log(f"   ID: {alert_id}")
                        log(f"   Title: {title}")
                        log(f"   Report Date: {report_date}")
                        log(f"   Sighting Date/Time: {sighting_datetime}")
                        log(f"   Location: {location}")
                        log(f"   Short Description: {short_description}")
                        log(f"   Long Description: {long_description}")
                        log(f"   Source ID: mufon_{real_case_id}")
                        log(f"   External URL: https://mufon.com/case/{real_case_id}")
                        log(f"   Media Files: {len(media_files)}")
                        log(f"   UFO Type: {classification['type']} (confidence: {classification['confidence']:.2f})")
                        log(f"   Keywords: {', '.join(classification.get('keywords', []))}")
                        if geo_data:
                            log(f"   Coordinates: {geo_data['latitude']}, {geo_data['longitude']}")
                            log(f"   Geocoded Location: {geo_data['display_name']}")
                        else:
                            log(f"   Geocoding: Failed - no coordinates extracted")
                        
                        imported_count += 1
                        
                        # UPLOAD MEDIA
                        if media_files and alert_id:
                            log(f"📤 Uploading {len(media_files)} media files...")
                            uploaded_count = 0
                            cookies = context.cookies()
                            
                            for media in media_files:
                                try:
                                    cookie_dict = {c['name']: c['value'] for c in cookies}
                                    with httpx.Client(cookies=cookie_dict, timeout=30.0) as client:
                                        media_response = client.get(media['url'])
                                        media_response.raise_for_status()
                                        
                                        files = {'files': (media['filename'], media_response.content, 'application/octet-stream')}
                                        data = {'source': 'mufon_import'}
                                        upload_response = requests.post(f"https://ufobeep.com/api/beep/{alert_id}/media", files=files, data=data, timeout=300)
                                        
                                        if upload_response.status_code == 200:
                                            uploaded_count += 1
                                            log(f"✅ Uploaded: {media['filename']}")
                                        else:
                                            log(f"⚠️ Upload failed for {media['filename']}: {upload_response.status_code}")
                                            
                                except Exception as e:
                                    log(f"⚠️ Media upload failed for {media['filename']}: {e}")
                            
                            log(f"✅ Case #{real_case_id}: {uploaded_count}/{len(media_files)} media uploaded")
                        
                            log(f"🎯 Case #{real_case_id} complete")
                            
                            # Add random delay between cases to avoid overwhelming server
                            if i < len(rows):  # Don't delay after last case
                                random_delay(2, 5)
                        
                    except Exception as e:
                        log(f"⚠️ Error processing row {i}: {e}")
                        random_delay(3, 7)  # Longer delay after errors
                        continue
            
                log(f"🎉 Processing completed: {imported_count} cases imported")
                return imported_count > 0
                
            except Exception as main_error:
                log(f"❌ Main processing error: {main_error}")
                log(f"📍 Stack trace: {traceback.format_exc()}")
                return False
            finally:
                try:
                    log("🧹 Cleaning up browser session...")
                    safe_browser_operation(
                        lambda: browser.close(),
                        "Close browser"
                    )
                except Exception as cleanup_error:
                    log(f"⚠️ Browser cleanup error: {cleanup_error}")
    
    # Run extraction with retry logic
    try:
        log("🚀 Starting MUFON extraction with retry capability...")
        return retry_with_backoff(run_extraction, max_retries=3, initial_delay=10)
    except Exception as final_error:
        log(f"❌ All extraction attempts failed: {final_error}")
        # Clean up cookies if we keep failing
        cookies_file = "/tmp/mufon_cookies.json"
        if os.path.exists(cookies_file):
            log("🗑️ Removing corrupted cookies file...")
            os.remove(cookies_file)
        return False

if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("Usage: python script.py DATE")
        sys.exit(1)
    
    success = extract_and_import_mufon(sys.argv[1])
    sys.exit(0 if success else 1)
EOF
    return $?
}

# Clear any existing cookies once before processing
echo "🗑️ Clearing any existing cookies for fresh authentication..."
rm -f /tmp/mufon_cookies.json

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
        if run_mufon_for_date "$current_date"; then
            echo "✅ Successfully imported data for $current_date"
            success_count=$((success_count + 1))
        else
            echo "❌ Failed to import data for $current_date"
            error_count=$((error_count + 1))
        fi
        # Next day
        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
        if [[ "$current_date" < "$last_date" || "$current_date" == "$last_date" ]]; then
            echo "⏳ Waiting 2 seconds..."
            sleep 2
            echo ""
        fi
    done
    echo ""
    echo "🎉 MUFON Range Import Complete!"
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
    if run_mufon_for_date "$DATE"; then
        echo "✅ MUFON import completed successfully!"
        exit 0
    else
        echo "❌ MUFON import failed"
        exit 1
    fi
fi
