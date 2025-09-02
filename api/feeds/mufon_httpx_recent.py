#!/usr/bin/env python3
"""
Fast httpx scraper: reuse saved cookies, POST directly to captured endpoint.
"""
import json, os
from datetime import datetime, timedelta
from pathlib import Path
import httpx

STATE = Path("mufon_artifacts/storage_state.json")  # created by recorder
OUT   = Path("results_mufon.json")

# paste from the captured request (adjust as needed)
SEARCH_URL = "https://<neon-or-z2-host>/.../search"   # <-- put exact URL here

# these names should match what you saw in captured body (examples shown)
PARAM_TEMPLATE = {
    "startDate": None,   # e.g. "08/30/2025"
    "endDate":   None,   # e.g. "09/01/2025"
    # include any required hidden fields you saw (csrf tokens, choice, etc.)
    # "choice": "Database Search",
    # "csrfToken": "....",
}

def mmddyyyy(dt): return dt.strftime("%m/%d/%Y")

def load_cookies_from_playwright_state():
    st = json.loads(STATE.read_text(encoding="utf-8"))
    jar = httpx.Cookies()
    for c in st.get("cookies", []):
        # httpx cookie requires domain without leading dot sometimes; pass as-is
        jar.set(c["name"], c["value"], domain=c.get("domain"), path=c.get("path"))
    return jar

def main(days_back_start=2, days_back_end=0):
    assert STATE.exists(), f"Missing {STATE}; run recorder once to create login state."
    cookies = load_cookies_from_playwright_state()
    start = datetime.now() - timedelta(days=days_back_start)
    end   = datetime.now() - timedelta(days=days_back_end)

    params = PARAM_TEMPLATE.copy()
    params.update({
        "startDate": mmddyyyy(start),
        "endDate":   mmddyyyy(end),
    })

    headers = {
        "User-Agent": "Mozilla/5.0",
        "Origin": SEARCH_URL.split("/")[0] + "//" + SEARCH_URL.split("/")[2],
        "Referer": SEARCH_URL,
        "Content-Type": "application/x-www-form-urlencoded",
    }

    with httpx.Client(cookies=cookies, follow_redirects=True, timeout=30.0) as client:
        r = client.post(SEARCH_URL, data=params, headers=headers)
        r.raise_for_status()
        # Some Neon endpoints return HTML; others JSON. Save raw and let downstream parse.
        OUT.write_text(r.text, encoding="utf-8")
        print("Saved:", OUT)

if __name__ == "__main__":
    main()