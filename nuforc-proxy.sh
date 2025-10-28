#!/bin/bash
# NUFORC Import Pipeline with Proxy Rotation
# Usage: ./nuforc-proxy.sh 2025-10-21
#        ./nuforc-proxy.sh yesterday
#        ./nuforc-proxy.sh today
#        ./nuforc-proxy.sh 2025-10-20:2025-10-21

set -e

if [ $# -eq 0 ]; then
    echo "Usage: ./nuforc-proxy.sh <date or range>"
    echo "Examples:"
    echo "  ./nuforc-proxy.sh 2025-10-21"
    echo "  ./nuforc-proxy.sh yesterday"
    echo "  ./nuforc-proxy.sh today"
    echo "  ./nuforc-proxy.sh 2025-10-20:2025-10-21"
    exit 1
fi

DATE_INPUT="$1"

# Create log file with timestamp
LOG_FILE="logs/nuforc_import_proxy_$(date +%Y%m%d_%H%M%S).log"
mkdir -p logs
{
    # announce log target early on stdout
    echo "📜 Logging to $LOG_FILE"
} >/dev/null

# Mirror all output to file and console
exec > >(tee -a "$LOG_FILE") 2>&1

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
    echo "🚀 NUFORC Proxy Pipeline: $START_DATE to $END_DATE"
    echo "=================================================="
else
    DATE=$(resolve_date_token "$DATE_INPUT") || true
    if [ -z "$DATE" ]; then
        echo "❌ Invalid date: '$DATE_INPUT'"
        exit 1
    fi
    echo "🚀 NUFORC Proxy Pipeline for $DATE"
    echo "=================================="
fi

# Bash function to run the embedded Python for a single date using rotating proxies
run_nuforc_with_proxy_for_date() {
    local RUN_DATE="$1"
    echo ""
    echo "==============================================="
    echo "Processing NUFORC data (proxy) for: $RUN_DATE"
    echo "==============================================="
    echo "🔍 Running NUFORC extraction and import with proxies for $RUN_DATE..."
    python3 - "$RUN_DATE" << 'EOF'
#!/usr/bin/env python3
import sys
import time
import json
import random
import traceback
import re
from datetime import datetime, timezone
from typing import Optional, List, Dict

import requests
from bs4 import BeautifulSoup
from urllib.parse import urlparse


def log(message: str):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    print(f"[{timestamp}] {message}", flush=True)


class ProxyRotator:
    """Fetches proxies from ProxyNova and rotates them every min for NUFORC requests."""

    LIST_URL = "https://www.proxynova.com/proxy-server-list/"

    def __init__(self, min_switch_interval: int = 60):
        self.min_switch_interval = min_switch_interval
        self.proxies: List[Dict[str, str]] = []
        self.current_index: int = -1
        self.last_switch: float = 0.0
        self.last_refresh: float = 0.0
        self.refresh_interval: int = 600  # refresh list every 10 minutes
        self.session = requests.Session()
        self.browser_headers = {
            "User-Agent": (
                "Mozilla/5.0 (Windows NT 10.0; Win64; x64)"
                " AppleWebKit/537.36 (KHTML, like Gecko)"
                " Chrome/124.0.0.0 Safari/537.36"
            )
        }
        self._refresh_proxies()

    def _refresh_proxies(self):
        now = time.time()
        if self.proxies and (now - self.last_refresh) < self.refresh_interval:
            return
        try:
            candidates = []

            # Fetch from multiple sources
            try:
                usproxy = self._fetch_usproxy_org()
                log(f"🇺🇸 US-Proxy.org candidates: {len(usproxy)}")
                candidates.extend(usproxy)
            except Exception as e:
                log(f"⚠️ US-Proxy.org fetch failed: {e}")

            try:
                nova_us = self._fetch_proxynova_country('us')
                log(f"🇺🇸 ProxyNova US candidates: {len(nova_us)}")
                candidates.extend(nova_us)
            except Exception as e:
                log(f"⚠️ ProxyNova US fetch failed: {e}")

            try:
                pld_us = self._fetch_proxylist_download_us()
                log(f"🇺🇸 proxy-list.download candidates: {len(pld_us)}")
                candidates.extend(pld_us)
            except Exception as e:
                log(f"⚠️ proxy-list.download fetch failed: {e}")

            try:
                pscrape = self._fetch_proxyscrape()
                log(f"🔎 ProxyScrape candidates: {len(pscrape)}")
                candidates.extend(pscrape)
            except Exception as e:
                log(f"⚠️ ProxyScrape fetch failed: {e}")

            try:
                pscan = self._fetch_proxyscan_us()
                log(f"🇺🇸 Proxyscan.io US candidates: {len(pscan)}")
                candidates.extend(pscan)
            except Exception as e:
                log(f"⚠️ Proxyscan.io US fetch failed: {e}")

            try:
                geonode = self._fetch_geonode_us()
                log(f"🇺🇸 Geonode US candidates: {len(geonode)}")
                candidates.extend(geonode)
            except Exception as e:
                log(f"⚠️ Geonode fetch failed: {e}")

            try:
                usproxy = self._fetch_usproxy_org()
                log(f"🇺🇸 US-Proxy.org candidates: {len(usproxy)}")
                candidates.extend(usproxy)
            except Exception as e:
                log(f"⚠️ US-Proxy.org fetch failed: {e}")

            # Load local proxies file first if present
            try:
                local = self._load_local_file()
                if local:
                    log(f"📁 Local proxies.txt candidates: {len(local)}")
                    candidates.extend(local)
            except Exception as e:
                log(f"⚠️ Reading local proxies.txt failed: {e}")

            # Deduplicate while preserving order
            seen = set()
            deduped = []
            for p in candidates:
                key = p["http"]
                if key in seen:
                    continue
                seen.add(key)
                deduped.append(p)

            # Pre-check proxies quickly against NUFORC to avoid long hangs
            self.proxies = self._precheck_proxies(deduped)
            self.current_index = -1
            self.last_refresh = now
            log(f"✅ Loaded {len(self.proxies)} working proxies")
        except Exception as e:
            log(f"⚠️ Failed to refresh proxies: {e}")

    def _normalize_candidate(self, hostport: str) -> Dict[str, str] | None:
        # Accept only IPv4:port and common proxy ports to improve quality
        m = re.match(r"^(\d{1,3}(?:\.\d{1,3}){3}):(\d{2,5})$", hostport)
        if not m:
            return None
        port = int(m.group(2))
        allowed_ports = {80, 81, 82, 83, 84, 85, 443, 3128, 808, 8080, 8088, 8000, 8008, 8880, 8888, 9000, 9090, 8081, 8082, 8083, 8181, 7890, 53281, 65103}
        if port not in allowed_ports:
            return None
        proxy_url = f"http://{hostport}"
        return {"http": proxy_url, "https": proxy_url}

    def _load_local_file(self) -> List[Dict[str, str]]:
        import os
        path = os.path.join(os.getcwd(), "proxies.txt")
        parsed: List[Dict[str, str]] = []
        if not os.path.exists(path):
            return parsed
        with open(path, "r", encoding="utf-8", errors="ignore") as f:
            for line in f:
                s = line.strip()
                if not s or s.startswith("#"):
                    continue
                s = s.replace("http://", "").replace("https://", "")
                p = self._normalize_candidate(s)
                if p:
                    parsed.append(p)
        return parsed

    def _fetch_proxynova_country(self, country_code: str = 'us') -> List[Dict[str, str]]:
        url = f"https://www.proxynova.com/proxy-server-list/country-{country_code}"
        log(f"🌐 Fetching proxies from ProxyNova ({country_code.upper()})...")
        resp = self.session.get(url, headers=self.browser_headers, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")
        rows = soup.select("#tbl_proxy_list tbody tr")
        parsed: List[Dict[str, str]] = []
        for tr in rows:
            tds = tr.find_all("td")
            if len(tds) < 2:
                continue
            ip_cell = tds[0]
            ip_text = ip_cell.get_text(" ", strip=True)
            js_text = " ".join(script.get_text(" ", strip=True) for script in ip_cell.find_all("script"))
            combined = " ".join([ip_text, js_text])
            ip_match = re.search(r"\b(\d{1,3}(?:\.\d{1,3}){3})\b", combined)
            if not ip_match:
                continue
            ip = ip_match.group(1)
            port_text = tds[1].get_text(strip=True)
            if not port_text.isdigit():
                continue
            status_text = " ".join(td.get_text(" ", strip=True).lower() for td in tds)
            if any(bad in status_text for bad in ["down", "dead"]):
                continue
            recent_ok = True
            lc_match = re.search(r"(\d+)\s*min", status_text)
            if lc_match:
                try:
                    mins = int(lc_match.group(1))
                    recent_ok = mins <= 10
                except Exception:
                    recent_ok = True
            if not recent_ok:
                continue
            cand = self._normalize_candidate(f"{ip}:{port_text}")
            if cand:
                parsed.append(cand)
        return parsed

    def _fetch_proxyscrape(self) -> List[Dict[str, str]]:
        # ProxyScrape v2 plain text list
        urls = [
            # Prefer proxies that support HTTPS (CONNECT) and US country when available
            "https://api.proxyscrape.com/v2/?request=displayproxies&protocol=http&timeout=3000&country=US&ssl=yes&anonymity=all",
            "https://api.proxyscrape.com/v2/?request=displayproxies&protocol=http&timeout=3000&country=all&ssl=yes&anonymity=all",
            "https://api.proxyscrape.com/?request=displayproxies&proxytype=http&timeout=3000&country=US&ssl=yes&anonymity=all",
        ]
        parsed: List[Dict[str, str]] = []
        for u in urls:
            try:
                resp = self.session.get(u, headers=self.browser_headers, timeout=15)
                if resp.status_code != 200:
                    continue
                for line in resp.text.splitlines():
                    line = line.strip()
                    if not line or ":" not in line:
                        continue
                    cand = self._normalize_candidate(line)
                    if cand:
                        parsed.append(cand)
            except Exception:
                continue
        return parsed

    def _fetch_proxyscan_us(self) -> List[Dict[str, str]]:
        url = "https://www.proxyscan.io/api/proxy?type=http&format=txt&country=us"
        parsed: List[Dict[str, str]] = []
        resp = self.session.get(url, headers=self.browser_headers, timeout=15)
        if resp.status_code == 200:
            for line in resp.text.splitlines():
                line = line.strip()
                cand = self._normalize_candidate(line)
                if cand:
                    parsed.append(cand)
        return parsed

    def _fetch_usproxy_org(self) -> List[Dict[str, str]]:
        # US-only list powered by free-proxy-list.net
        url = "https://www.us-proxy.org/"
        resp = self.session.get(url, headers=self.browser_headers, timeout=20)
        resp.raise_for_status()
        soup = BeautifulSoup(resp.text, "html.parser")
        table = soup.find("table", id="proxylisttable")
        parsed: List[Dict[str, str]] = []
        if not table:
            return parsed
        rows = table.tbody.find_all("tr") if table.tbody else table.find_all("tr")
        for tr in rows:
            tds = tr.find_all("td")
            if len(tds) < 7:
                continue
            ip = tds[0].get_text(strip=True)
            port = tds[1].get_text(strip=True)
            https_yesno = tds[6].get_text(strip=True).lower()
            if not ip or not port.isdigit():
                continue
            # Prefer only HTTPS-capable proxies for CONNECT
            if https_yesno != "yes":
                continue
            cand = self._normalize_candidate(f"{ip}:{port}")
            if cand:
                parsed.append(cand)
        return parsed

    def _fetch_proxylist_download_us(self) -> List[Dict[str, str]]:
        # API: https://www.proxy-list.download/api/v1/get?type=http&country=US
        urls = [
            "https://www.proxy-list.download/api/v1/get?type=http&country=US",
            "https://www.proxy-list.download/api/v1/get?type=https&country=US",
        ]
        parsed: List[Dict[str, str]] = []
        for u in urls:
            try:
                resp = self.session.get(u, headers=self.browser_headers, timeout=15)
                if resp.status_code != 200:
                    continue
                for line in resp.text.splitlines():
                    line = line.strip()
                    if not line or ":" not in line:
                        continue
                    cand = self._normalize_candidate(line)
                    if cand:
                        parsed.append(cand)
            except Exception:
                continue
        return parsed

    def _fetch_geonode_us(self) -> List[Dict[str, str]]:
        # API: https://proxylist.geonode.com/api/proxy-list?limit=200&page=1&sort_by=lastChecked&sort_type=desc&country=US&protocols=http,https
        url = (
            "https://proxylist.geonode.com/api/proxy-list?limit=200&page=1&"
            "sort_by=lastChecked&sort_type=desc&country=US&protocols=http,https"
        )
        parsed: List[Dict[str, str]] = []
        try:
            resp = self.session.get(url, headers=self.browser_headers, timeout=20)
            if resp.status_code != 200:
                return parsed
            data = resp.json()
            for item in data.get("data", []):
                ip = item.get("ip")
                port = str(item.get("port", "")).strip()
                protocols = [p.lower() for p in item.get("protocols", [])]
                if not ip or not port.isdigit():
                    continue
                # Only proxies that list https support
                if "https" not in protocols:
                    continue
                cand = self._normalize_candidate(f"{ip}:{port}")
                if cand:
                    parsed.append(cand)
        except Exception:
            return parsed
        return parsed

    def _precheck_proxies(self, candidates: list, test_url: str = "https://nuforc.org/robots.txt") -> list:
        # Validate proxies in parallel with a short timeout and a global budget
        import concurrent.futures as cf
        good = []
        if not candidates:
            return good
        target_good = 5
        max_to_check = min(len(candidates), 400)
        timeout_per = 2.5
        workers = 32
        budget_seconds = 25
        log(f"🧪 Concurrently validating up to {max_to_check} proxies (aim {target_good}, {workers} workers, {timeout_per}s each, {budget_seconds}s budget)...")

        start_all = time.perf_counter()

        def try_one(idx_p):
            idx, p = idx_p
            try:
                t0 = time.perf_counter()
                r = self.session.get(test_url, proxies=p, headers=self.browser_headers, timeout=timeout_per)
                dur = int((time.perf_counter() - t0) * 1000)
                if r.status_code in (200, 301, 302):
                    log(f"   ✅ [{idx}/{max_to_check}] {p['http']} ok ({dur} ms)")
                    return p
                else:
                    log(f"   ❌ [{idx}/{max_to_check}] {p['http']} HTTP {r.status_code}")
            except requests.RequestException as e:
                # Keep log terse: only class name
                err = type(e).__name__
                log(f"   ❌ [{idx}/{max_to_check}] {p['http']} fail: {err}")
            return None

        with cf.ThreadPoolExecutor(max_workers=workers) as ex:
            futures = []
            for i, p in enumerate(candidates[:max_to_check], 1):
                futures.append(ex.submit(try_one, (i, p)))
            for fut in cf.as_completed(futures, timeout=budget_seconds):
                if len(good) >= target_good:
                    break
                left = budget_seconds - (time.perf_counter() - start_all)
                if left <= 0:
                    log("⏱️ Proxy validation budget exhausted")
                    break
                res = fut.result(timeout=max(left, 0.1))
                if res:
                    good.append(res)

        if not good:
            log("❌ No working proxies passed validation")
        else:
            log(f"🟢 {len(good)} proxies validated and ready")
        return good

    def _advance(self):
        if not self.proxies:
            return None
        self.current_index = (self.current_index + 1) % len(self.proxies)
        self.last_switch = time.time()
        cur = self.proxies[self.current_index]
        log(f"🔁 Switched proxy -> {cur['http']}")
        return cur

    def current(self):
        # Ensure list is fresh
        self._refresh_proxies()
        if not self.proxies:
            return None
        now = time.time()
        if self.current_index == -1:
            return self._advance()
        if (now - self.last_switch) >= self.min_switch_interval:
            return self._advance()
        return self.proxies[self.current_index]

    def mark_bad_and_rotate(self):
        if not self.proxies:
            return None
        # Optionally push the bad proxy to end
        bad = None
        if 0 <= self.current_index < len(self.proxies):
            bad = self.proxies.pop(self.current_index)
            self.proxies.append(bad)
            # step back so _advance goes to the next newly at current index
            self.current_index = (self.current_index - 1) % len(self.proxies)
        return self._advance()


def random_delay(min_seconds=1, max_seconds=3):
    delay = random.uniform(min_seconds, max_seconds)
    time.sleep(delay)


def retry_with_backoff(func, max_retries=3, initial_delay=3):
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


def is_nuforc_url(url: str) -> bool:
    try:
        host = urlparse(url).hostname or ""
        return host.endswith("nuforc.org")
    except Exception:
        return False


class NuforcClient:
    def __init__(self, proxy_rotator: ProxyRotator | None):
        self.proxy_rotator = proxy_rotator
        self.session = requests.Session()
        self.ua = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}

    def get(self, url: str, use_proxy_if_nuforc: bool = True, **kwargs):
        headers = kwargs.pop("headers", {})
        headers = {**self.ua, **headers}
        kwargs["headers"] = headers
        # default tighter timeout if not provided
        kwargs.setdefault("timeout", 10)

        if use_proxy_if_nuforc and is_nuforc_url(url):
            if not self.proxy_rotator:
                raise RuntimeError("Proxy is required for nuforc.org but none configured")
            # loop with limited quick rotations on proxy errors; never fall back to direct
            last_error = None
            max_attempts = max(5, min(8, (len(self.proxy_rotator.proxies) or 0) + 2))
            for attempt in range(1, max_attempts + 1):
                proxies = self.proxy_rotator.current()
                if not proxies:
                    raise RuntimeError("No proxies available for nuforc.org; refusing direct connection")
                try:
                    start = time.perf_counter()
                    log(f"🌍 GET {url} via {proxies['http']} (attempt {attempt}/{max_attempts})")
                    resp = self.session.get(url, proxies=proxies, **kwargs)
                    dur = (time.perf_counter() - start) * 1000
                    log(f"   ↪ status {resp.status_code} in {int(dur)} ms")
                    return resp
                except (requests.exceptions.ProxyError,
                        requests.exceptions.ConnectTimeout,
                        requests.exceptions.ReadTimeout,
                        requests.exceptions.SSLError,
                        requests.exceptions.ConnectionError) as e:
                    last_error = e
                    log(f"⛔ Proxy failed: {e}. Rotating...")
                    self.proxy_rotator.mark_bad_and_rotate()
                    continue
            if last_error:
                raise last_error
        # default direct for non-NUFORC URLs
        return self.session.get(url, **kwargs)

    def post(self, url: str, json: dict | None = None, files=None, data=None, **kwargs):
        # Do NOT proxy posts to ufobeep.com (not part of scraping)
        headers = kwargs.pop("headers", {})
        headers = {**self.ua, **headers}
        return self.session.post(url, json=json, files=files, data=data, headers=headers, **kwargs)


def geocode_location(city: str, state: str | None = None) -> Optional[Dict[str, any]]:
    if not city or len(city.strip()) < 2:
        return None
    from datetime import timedelta
    time.sleep(0.3)
    url = "https://nominatim.openstreetmap.org/search"
    params = {"q": f"{city}, {state + ', ' if state else ''}USA", "format": "json", "limit": 1}
    headers = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}
    try:
        r = requests.get(url, params=params, headers=headers, timeout=15)
        if r.status_code == 200:
            data = r.json()
            if data:
                lat = float(data[0]["lat"]) ; lon = float(data[0]["lon"])
                if -180 <= lon <= 180 and -90 <= lat <= 90:
                    return {"location": params["q"], "latitude": lat, "longitude": lon, "display_name": data[0].get("display_name", params["q"]) }
    except Exception as e:
        log(f"⚠️ Geocoding failed for '{params['q']}': {e}")
    return None


def parse_nuforc_report(html_content: str, report_id: str, report_url: str) -> Optional[Dict]:
    # Reuse the same parser from nuforc.sh (trimmed for brevity here)
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

        h1 = soup.find('h1')
        if not h1:
            raise Exception("Could not find H1 title tag")

        text_parts = []
        current_field = None
        seen_shape = False
        known_fields = ['occurred', 'reported', 'duration', 'no of observers', 'location',
                        'location details', 'shape', 'characteristics', 'color', 'estimated size',
                        'viewed from', 'direction from viewer', 'angle of elevation',
                        'closest distance', 'estimated speed', 'apparent size', 'direction faced',
                        'height', 'altitude', 'distance', 'latitude', 'longitude']

        for sibling in h1.next_siblings:
            if isinstance(sibling, str):
                text = sibling.strip()
                if text and current_field:
                    key = current_field
                    if key == 'occurred':
                        report_data['occurred'] = text
                    elif key == 'reported':
                        report_data['reported'] = text
                    elif key == 'duration':
                        report_data['duration'] = text
                    elif key == 'no_of_observers':
                        try:
                            report_data['no_of_observers'] = int(text)
                        except Exception:
                            pass
                    elif key == 'location':
                        report_data['location'] = text
                        parts = text.split(',')
                        if len(parts) >= 2:
                            report_data['city'] = parts[0].strip()
                            if len(parts) == 2:
                                report_data['state'] = parts[1].strip()
                            elif len(parts) >= 3:
                                report_data['state'] = parts[1].strip()
                                report_data['country'] = parts[2].strip()
                    elif key == 'location_details':
                        report_data['location_details'] = text
                        lat_match = re.search(r'Latitude:\s*([-\d.]+)', text)
                        lon_match = re.search(r'Longitude:\s*([-\d.]+)', text)
                        if lat_match and lon_match:
                            try:
                                report_data['exact_latitude'] = float(lat_match.group(1))
                                report_data['exact_longitude'] = float(lon_match.group(1))
                            except Exception:
                                pass
                    elif key == 'shape':
                        report_data['shape'] = text
                        seen_shape = True
                    elif key == 'color':
                        report_data['color'] = text
                    elif key == 'estimated_size':
                        report_data['estimated_size'] = text
                    elif key == 'viewed_from':
                        report_data['viewed_from'] = text
                    elif key == 'direction_from_viewer':
                        report_data['direction_from_viewer'] = text
                    elif key == 'angle_of_elevation':
                        try:
                            report_data['angle_of_elevation'] = float(text)
                        except Exception:
                            report_data['angle_of_elevation'] = text
                    elif key == 'closest_distance':
                        report_data['closest_distance'] = text
                    elif key == 'estimated_speed':
                        report_data['estimated_speed'] = text
                    elif key == 'characteristics':
                        report_data['characteristics'] = text
                    current_field = None
                elif seen_shape and text and not current_field:
                    if text.startswith('Posted'):
                        report_data['posted'] = text.replace('Posted', '').strip()
                        break
                    elif text not in ['TERMS OF SERVICE', 'PRIVACY POLICY', 'Copyright', 'National UFO Reporting Center']:
                        text_parts.append(text)
            else:
                if getattr(sibling, 'name', None) == 'b':
                    field = sibling.get_text(strip=True).rstrip(':').lower()
                    norm = field.replace(' ', '_')
                    current_field = norm if field in known_fields else None
                elif getattr(sibling, 'name', None) == 'br' and seen_shape:
                    t = sibling.get_text().strip()
                    if t and len(t) > 50:
                        text_parts.append(t)

        if text_parts:
            report_data['summary'] = text_parts[0]
            report_data['text'] = '\n\n'.join(text_parts)

        # media: images and videos
        images = soup.find_all('img')
        for img in images:
            src = img.get('src', '')
            alt = img.get('alt', '')
            if src and ('wpforms' in src or '/simages/' in src) and 'logo' not in src.lower():
                full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                if not any(m['url'] == full_url for m in report_data['media']):
                    report_data['media'].append({'type': 'image', 'url': full_url, 'alt': alt, 'filename': src.split('/')[-1]})

        videos = soup.find_all('video')
        for video in videos:
            sources = video.find_all('source')
            if sources:
                for source in sources:
                    src = source.get('src', '')
                    if src:
                        full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                        if not any(m['url'] == full_url for m in report_data['media']):
                            report_data['media'].append({'type': 'video', 'url': full_url, 'alt': '', 'filename': src.split('/')[-1]})
            else:
                src = video.get('src', '')
                if src:
                    full_url = src if src.startswith('http') else f"https://nuforc.org{src}"
                    if not any(m['url'] == full_url for m in report_data['media']):
                        report_data['media'].append({'type': 'video', 'url': full_url, 'alt': '', 'filename': src.split('/')[-1]})

        html_str = str(html_content)
        muse_matches = re.findall(r'video:\s*"([^"]+)"', html_str)
        for video_id in muse_matches:
            muse_url = f"https://muse.ai/v/{video_id}"
            if not any(m['url'] == muse_url for m in report_data['media']):
                report_data['media'].append({'type': 'video', 'url': muse_url, 'filename': f"muse_{video_id}.mp4"})

        return report_data
    except Exception as e:
        log(f"❌ Failed to parse report {report_id}: {e}")
        log(f"   Traceback: {traceback.format_exc()}")
        raise


def get_reports_for_date(date_str: str, client: NuforcClient) -> List[Dict]:
    dt = datetime.strptime(date_str, "%Y-%m-%d")
    date_code = dt.strftime("%y%m%d")
    index_url = f"https://nuforc.org/subndx/?id=p{date_code}"
    log(f"🔍 Fetching daily index: {index_url}")

    def fetch_index():
        resp = client.get(index_url, use_proxy_if_nuforc=True, timeout=30)
        resp.raise_for_status()
        return resp.content

    html_content = retry_with_backoff(fetch_index)
    soup = BeautifulSoup(html_content, 'html.parser')
    report_links = []
    for link in soup.find_all('a', href=True):
        href = link.get('href')
        if '/sighting/?id=' in href:
            m = re.search(r'id=(\d+)', href)
            if m:
                report_id = m.group(1)
                full_url = href if href.startswith('http') else f"https://nuforc.org{href}"
                report_links.append({"report_id": report_id, "url": full_url})
    log(f"📊 Found {len(report_links)} reports for {date_str}")
    return report_links


def upload_media_to_beep(beep_id: str, media_files: List[Dict], client: NuforcClient):
    if not media_files:
        return
    log(f"📤 Uploading {len(media_files)} media files for beep {beep_id}...")
    headers_download = {"User-Agent": "UFOBeep-NUFORC/1.0 (+https://ufobeep.com)"}
    for i, media in enumerate(media_files, 1):
        filename = media.get('filename', f"media_{i}.jpg")
        try:
            media_url = media['url']
            if 'muse.ai' in media_url:
                log(f"   ⏭️  Skipping Muse.ai video {i}/{len(media_files)} (embedded player)")
                continue
            log(f"   📥 Downloading {i}/{len(media_files)}: {filename}")
            response = client.get(media_url, use_proxy_if_nuforc=True, headers=headers_download, timeout=30)
            response.raise_for_status()
            files = {'files': (filename, response.content, 'application/octet-stream')}
            data = {'source': 'nuforc_import'}
            upload_response = client.post(f"https://ufobeep.com/api/beep/{beep_id}/media", files=files, data=data, timeout=300)
            if upload_response.status_code in [200, 201]:
                log(f"   ✅ Uploaded {filename}")
            else:
                log(f"   ⚠️ Failed to upload {filename}: {upload_response.status_code}")
        except Exception as e:
            log(f"   ❌ Error uploading media {filename}: {e}")
            continue


def extract_and_import_nuforc(date_str: str) -> bool:
    log(f"🎯 Processing NUFORC reports for {date_str}")
    proxy_rotator = ProxyRotator(min_switch_interval=60)
    client = NuforcClient(proxy_rotator)

    # Strict mode: require proxies for NUFORC
    if not proxy_rotator.proxies:
        log("❌ No active proxies available from ProxyNova; aborting to avoid direct use of origin IP")
        return False

    # Get list of reports for this date
    try:
        report_links = get_reports_for_date(date_str, client)
    except Exception as e:
        log(f"❌ Failed to get reports for {date_str}: {e}")
        return False
    if not report_links:
        log("⚠️ No reports found for this date")
        return True

    imported_count = 0
    skipped_count = 0
    error_count = 0

    for report_info in report_links:
        report_id = report_info['report_id']
        report_url = report_info['url']
        try:
            external_id = f"nuforc_{report_id}"
            log(f"📖 Processing report {report_id}...")

            def fetch_report():
                resp = client.get(report_url, use_proxy_if_nuforc=True, timeout=30)
                resp.raise_for_status()
                return resp.content

            html_content = retry_with_backoff(fetch_report)
            report_data = parse_nuforc_report(html_content, report_id, report_url)
            if not report_data or not report_data.get('text'):
                log(f"⚠️ Could not extract text from report {report_id}")
                error_count += 1
                continue

            # Geocode
            geo_data = None
            if report_data.get('exact_latitude') and report_data.get('exact_longitude'):
                geo_data = {
                    "latitude": report_data['exact_latitude'],
                    "longitude": report_data['exact_longitude'],
                    "location": f"{report_data.get('city', '')}, {report_data.get('state', '')}".strip(', ')
                }
                log(f"📍 Using exact NUFORC coordinates: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")
            elif report_data.get('city'):
                geo_data = geocode_location(report_data['city'], report_data.get('state'))
                if geo_data:
                    log(f"📍 Geocoded: {geo_data['location']} -> {geo_data['latitude']}, {geo_data['longitude']}")

            # Dates
            occurred_iso = None
            posted_iso = None
            reported_iso = None
            if report_data.get('occurred'):
                try:
                    date_part = report_data['occurred'].split()[0]
                    occurred_iso = datetime.strptime(date_part, "%Y-%m-%d").replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse occurred date '{report_data['occurred']}': {e}")
            if report_data.get('posted'):
                try:
                    posted_iso = datetime.strptime(report_data['posted'], "%Y-%m-%d").replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse posted date '{report_data['posted']}': {e}")
            if report_data.get('reported'):
                try:
                    date_part = report_data['reported'].split()[0]
                    reported_iso = datetime.strptime(date_part, "%Y-%m-%d").replace(tzinfo=timezone.utc).isoformat()
                except Exception as e:
                    log(f"⚠️ Could not parse reported date '{report_data['reported']}': {e}")

            import uuid
            shape = report_data.get('shape')
            title = f"NUFORC {shape.title()} Sighting" if shape else "NUFORC Sighting"
            alert_id = str(uuid.uuid4())
            beep_data = {
                "id": alert_id,
                "device_id": f"nuforc_import_{report_id}",
                "username": "NUFORC",
                "source": "nuforc",
                "external_id": external_id,
                "tier": 2,
                "title": title,
                "description": report_data['text'],
                "enrichment_data": {
                    "nuforc": {
                        "report_id": report_id,
                        "url": report_url,
                        "occurred": report_data.get('occurred'),
                        "reported": report_data.get('reported'),
                        "posted": report_data.get('posted'),
                        "duration": report_data.get('duration'),
                        "no_of_observers": report_data.get('no_of_observers'),
                        "location": report_data.get('location'),
                        "location_details": report_data.get('location_details'),
                        "city": report_data.get('city'),
                        "state": report_data.get('state'),
                        "country": report_data.get('country'),
                        "shape": report_data.get('shape'),
                        "color": report_data.get('color'),
                        "estimated_size": report_data.get('estimated_size'),
                        "viewed_from": report_data.get('viewed_from'),
                        "direction_from_viewer": report_data.get('direction_from_viewer'),
                        "angle_of_elevation": report_data.get('angle_of_elevation'),
                        "closest_distance": report_data.get('closest_distance'),
                        "estimated_speed": report_data.get('estimated_speed'),
                        "characteristics": report_data.get('characteristics'),
                        "summary": report_data.get('summary'),
                    },
                    "muse_ai_videos": [m['url'] for m in report_data.get('media', []) if 'muse.ai' in m['url']],
                    "hide_witness_widget": True,
                    "hide_location_widget": True,
                    "hide_environmental_analysis": True,
                    "hide_actions": True,
                    "is_historical_report": True,
                    "source_name": "NUFORC"
                }
            }
            if geo_data:
                beep_data["location"] = {"latitude": geo_data["latitude"], "longitude": geo_data["longitude"], "name": geo_data["location"]}
            elif report_data.get('city'):
                beep_data["location"] = {"name": f"{report_data['city']}, {report_data.get('state', '')}".strip(', ')}

            log(f"📤 Creating beep for NUFORC report {report_id}...")
            response = client.post("https://ufobeep.com/api/beep", json=beep_data, timeout=30)
            if response.status_code in [200, 201]:
                created_id = response.json().get('sighting_id')
                log(f"✅ Created beep: {created_id}")
                if report_data.get('media'):
                    upload_media_to_beep(created_id, report_data['media'], client)
                imported_count += 1
            else:
                log(f"❌ Failed to create beep for {report_id}: {response.status_code}")
                log(f"   Response: {response.text[:200]}")
                error_count += 1

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
    echo "📅 Import range (proxy): $START_DATE to $END_DATE"
    echo "⏱️  2-second delay between each day"
    echo ""
    while [[ "$current_date" < "$last_date" ]] || [[ "$current_date" == "$last_date" ]]; do
        day_count=$((day_count + 1))
        echo "📅 Day $day_count: Processing $current_date"
        if run_nuforc_with_proxy_for_date "$current_date"; then
            echo "✅ Successfully imported data for $current_date"
            success_count=$((success_count + 1))
        else
            echo "❌ Failed to import data for $current_date"
            error_count=$((error_count + 1))
        fi
        current_date=$(date -d "$current_date + 1 day" +%Y-%m-%d)
        if [[ "$current_date" < "$last_date" ]] || [[ "$current_date" == "$last_date" ]]; then
            echo "⏳ Waiting 2 seconds..."
            sleep 2
            echo ""
        fi
    done
    echo ""
    echo "🎉 NUFORC Range Import (proxy) Complete!"
    echo "========================================"
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
    if run_nuforc_with_proxy_for_date "$DATE"; then
        echo "✅ NUFORC import (proxy) completed successfully!"
        exit 0
    else
        echo "❌ NUFORC import (proxy) failed"
        exit 1
    fi
fi
