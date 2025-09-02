# login_and_search.py
import os, re, sys, time
from pathlib import Path
from urllib.parse import urlparse
from playwright.sync_api import sync_playwright

ART_DIR = Path("mufon_artifacts")
ART_DIR.mkdir(exist_ok=True)
STORAGE_STATE = ART_DIR / "storage_state.json"
RESULTS_URL_TXT = ART_DIR / "results_url.txt"
RESULTS_FRAME_HTML = ART_DIR / "results_frame.html"
TRACE_PATH = ART_DIR / "trace_login.zip"

HOST = "https://mufoncms.com"
ENTRY_URLS = [f"{HOST}/"]
SEARCH_LINK_TEXT = re.compile(r"(database\s*search|track\s*ufo|search\s*ufo)", re.I)
SEARCH_BUTTON_TEXT = re.compile(r"\b(search|submit|go)\b", re.I)
ROW_HINTS = ["VIEW", "Case", "ID", "Shape", "Date", "Location"]

def env(k):
    v = os.environ.get(k)
    if v: return v
    p = Path(".env")
    if p.exists():
        for line in p.read_text(encoding="utf-8").splitlines():
            line=line.strip()
            if not line or line.startswith("#") or "=" not in line: continue
            key,val=line.split("=",1)
            if key.strip()==k: return val.strip()
    return None

def blocked(msg): print(f"BLOCKED: {msg}"); sys.exit(2)

def ensure_logged_in(page):
    user, pw = env("MUFON_USER"), env("MUFON_PASS")
    if not user or not pw: blocked("Set MUFON_USER and MUFON_PASS in .env or env")
    try:
        page.get_by_label(re.compile(r"email|username|user", re.I)).fill(user, timeout=2000)
        page.get_by_label(re.compile(r"password", re.I)).fill(pw, timeout=2000)
        page.get_by_role("button", name=re.compile(r"(sign\s*in|log\s*in|submit)", re.I)).first.click(timeout=3000)
        page.wait_for_load_state("domcontentloaded", timeout=10000); print("Logged in via labels."); return
    except Exception: pass
    try:
        page.locator("input[type='email'], input[name*='user'], input[name*='email']").first.fill(user, timeout=2000)
        page.locator("input[type='password']").first.fill(pw, timeout=2000)
        page.get_by_role("button", name=re.compile(r"(sign\s*in|log\s*in|submit)", re.I)).first.click(timeout=3000)
        page.wait_for_load_state("domcontentloaded", timeout=10000); print("Logged in via generic."); return
    except Exception: pass

def accept_terms_if_present(page):
    try:
        page.get_by_label(re.compile(r"(i\s*agree|accept)", re.I)).check(timeout=2000)
        page.get_by_role("button", name=re.compile(r"(continue|agree|accept|submit|next)", re.I)).first.click(timeout=2000)
        page.wait_for_load_state("domcontentloaded", timeout=7000); print("Accepted T&C."); return
    except Exception: pass
    try:
        page.get_by_role("button", name=re.compile(r"(agree|accept)", re.I)).first.click(timeout=2000)
        page.wait_for_load_state("domcontentloaded", timeout=7000); print("Accepted T&C (btn)."); return
    except Exception: pass

def find_and_click_database_search(page):
    try:
        page.get_by_role("link", name=re.compile(r"track\s*ufo", re.I)).first.click(timeout=2500)
        time.sleep(0.5)
    except Exception: pass
    try:
        page.get_by_role("link", name=SEARCH_LINK_TEXT).first.click(timeout=4000)
        page.wait_for_load_state("domcontentloaded", timeout=10000); print("Opened Database Search."); return
    except Exception:
        try:
            page.get_by_text(re.compile(r"database\s*search|search", re.I)).first.click(timeout=4000)
            page.wait_for_load_state("domcontentloaded", timeout=10000); print("Opened Database Search (fallback)."); return
        except Exception as e:
            blocked(f"Cannot reach Database Search: {e}")

def perform_basic_search(page):
    def find_results_frame():
        for fr in page.frames:
            try:
                for h in ROW_HINTS: fr.get_by_text(h, exact=False).first.wait_for(timeout=600)
                return fr
            except Exception: continue
        return None
    try:
        page.get_by_role("button", name=SEARCH_BUTTON_TEXT).first.click(timeout=2000)
        page.wait_for_load_state("domcontentloaded", timeout=8000)
    except Exception: pass
    fr = find_results_frame()
    if fr is None:
        for f in page.frames:
            try:
                f.get_by_role("button", name=SEARCH_BUTTON_TEXT).first.click(timeout=1500)
                time.sleep(0.5)
                fr = find_results_frame()
                if fr: break
            except Exception: continue
    if fr is None:
        for f in page.frames:
            try:
                f.locator("table tbody tr, [role='row']").first.wait_for(timeout=1500); fr = f; break
            except Exception: continue
    if fr is None:
        print("FRAME DUMP:"); 
        for f in page.frames: print(" -", f.url or "<no-url>")
        blocked("NO RESULTS FRAME FOUND")
    try:
        RESULTS_FRAME_HTML.write_text(fr.content(), encoding="utf-8")
    except Exception: pass
    host = urlparse(fr.url or "").hostname or ""
    if "mufoncms.com" in host:
        RESULTS_URL_TXT.write_text(fr.url, encoding="utf-8"); print("Saved results iframe URL:", fr.url)
    else:
        RESULTS_URL_TXT.write_text("", encoding="utf-8"); print("Results frame URL empty; Phase B will re-pick.")

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context()
        context.tracing.start(screenshots=True, snapshots=True, sources=True)
        page = context.new_page()
        page.goto(ENTRY_URLS[0], wait_until="domcontentloaded", timeout=45000)
        try: ensure_logged_in(page)
        except Exception: pass
        accept_terms_if_present(page)
        find_and_click_database_search(page)
        perform_basic_search(page)
        try: context.storage_state(path=str(STORAGE_STATE))
        except Exception: pass
        context.tracing.stop(path=str(TRACE_PATH))
        browser.close()

if __name__ == "__main__":
    main()
