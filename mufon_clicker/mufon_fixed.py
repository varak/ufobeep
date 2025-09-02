#!/usr/bin/env python3
# MUFON script with proper selectors and automated flow

import json, re, time
from pathlib import Path
from playwright.sync_api import sync_playwright
from datetime import datetime

# === CONFIG ===
BASE_URL = "https://mufon.app.neoncrm.com"
LOGIN_URL = f"{BASE_URL}/np/publicaccess/neonPage.do?pageId=19&"
JSON_PATH = "mufon_working_results.json"
# ==============

def load_cases():
    p = Path(JSON_PATH)
    if not p.exists():
        return {"cases": []}
    with p.open("r", encoding="utf-8") as f:
        return json.load(f)

def save_cases(data):
    with open(JSON_PATH, "w", encoding="utf-8") as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

def case_id_from_row_text(s: str) -> str:
    m = re.search(r"\b(\d{5,7})\b", s)
    return m.group(1) if m else None

def extract_long_description(page) -> str:
    candidates = [
        "#longDescription",
        "#description", 
        ".long-description",
        ".description",
        "textarea[name*='description']",
        "[name='longDescription']",
        "[name='description']"
    ]
    
    for sel in candidates:
        el = page.locator(sel).first
        if el.is_visible(timeout=2000):
            text = el.inner_text().strip()
            if len(text) > 25:
                return text
    
    # Fallback to largest paragraph
    paras = page.locator("p")
    best = ""
    for i in range(min(paras.count(), 20)):
        text = paras.nth(i).inner_text().strip()
        if len(text) > len(best):
            best = text
    return best if len(best) > 25 else "(No description found)"

def main():
    data = load_cases()
    
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False)
        context = browser.new_context()
        context.tracing.start(screenshots=True, snapshots=True, sources=True)
        
        page = context.new_page()
        
        print("Navigating to MUFON...")
        page.goto(LOGIN_URL, wait_until="domcontentloaded", timeout=30000)
        
        # Click terms radio button
        terms_radio = page.locator("input[type='radio']").first
        if terms_radio.is_visible(timeout=5000):
            print("Clicking terms radio button...")
            terms_radio.click()
            time.sleep(1)
        
        # Click SEARCH DATABASE
        search_btn = page.locator("text=/search database/i").first
        if search_btn.is_visible(timeout=5000):
            print("Clicking SEARCH DATABASE...")
            search_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=10000)
        
        # Enter today's date
        today = datetime.now().strftime("%m/%d/%Y")
        date_inputs = page.locator("input[type='date'], input[name*='date']")
        date_count = date_inputs.count()
        if date_count > 0:
            print(f"Entering today's date: {today}")
            for i in range(date_count):
                date_input = date_inputs.nth(i)
                if date_input.is_visible(timeout=2000):
                    date_input.fill(today)
                    time.sleep(0.5)
        
        # Click search/submit
        submit_btn = page.locator("input[type='submit'], button[type='submit']").first
        if submit_btn.is_visible(timeout=5000):
            print("Clicking search...")
            submit_btn.click()
            page.wait_for_load_state("domcontentloaded", timeout=15000)
        
        # Find table rows
        page.wait_for_selector("table", timeout=10000)
        rows = page.locator("table tbody tr, table tr:not(:first-child)")
        row_count = rows.count()
        print(f"Found {row_count} rows in results table")
        
        if row_count == 0:
            print("No rows found!")
            context.tracing.stop(path="trace.zip")
            browser.close()
            return
        
        visited = set()
        
        for i in range(row_count):
            row = rows.nth(i)
            text = row.inner_text(timeout=3000).strip()
            cid = case_id_from_row_text(text) or f"row{i+1}"
            
            if cid in visited:
                print(f"Skip {cid} (already visited)")
                continue
            visited.add(cid)
            
            print(f"Processing case {cid}...")
            
            # Click VIEW button in row
            view_btn = row.locator("text=/view/i, a, button").last
            if view_btn.is_visible(timeout=3000):
                view_btn.click(timeout=5000)
                page.wait_for_load_state("domcontentloaded", timeout=10000)
                
                # Extract description
                long_desc = extract_long_description(page)
                
                # Update JSON
                found = False
                for c in data.get("cases", []):
                    if str(c.get("case_id")) == str(cid) or str(c.get("Case_Number")) == str(cid):
                        c["long_description"] = long_desc
                        found = True
                        break
                if not found:
                    data.setdefault("cases", []).append({
                        "case_id": cid,
                        "long_description": long_desc
                    })
                
                save_cases(data)
                print(f"[OK] {cid}: {len(long_desc)} chars saved")
                
                # Go back
                page.go_back()
                page.wait_for_load_state("domcontentloaded", timeout=5000)
                
                # Refresh row locators
                rows = page.locator("table tbody tr, table tr:not(:first-child)")
            else:
                print(f"[WARN] {cid}: No VIEW button found")
        
        print("Extraction complete!")
        context.tracing.stop(path="trace.zip")
        browser.close()

if __name__ == "__main__":
    main()