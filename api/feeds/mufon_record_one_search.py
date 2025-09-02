#!/usr/bin/env python3
"""
One-time recorder: log in once, you manually do the search, we capture the real request.
"""
import json, time, os
from pathlib import Path
from playwright.sync_api import sync_playwright

USER = os.getenv("MUFON_USERNAME", "varak")
PASS = os.getenv("MUFON_PASSWORD", "ufobeep123pass")

ART = Path("mufon_artifacts"); ART.mkdir(exist_ok=True)
STATE = ART / "storage_state.json"
CAPTURE = ART / "captured_requests.jsonl"

FILTER_HOSTS = ("z2systems", "neon", "mufoncms")

def keep(resp):
    url = resp.url.lower()
    return any(h in url for h in FILTER_HOSTS)

def main():
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=150)
        context = browser.new_context(storage_state=str(STATE) if STATE.exists() else None,
                                      viewport={"width":1300,"height":900})
        page = context.new_page()

        # capture network
        def on_response(resp):
            if keep(resp) and resp.request.method in ("POST","GET"):
                try:
                    body = resp.request.post_data or ""
                except Exception:
                    body = ""
                rec = {
                    "time": time.time(),
                    "method": resp.request.method,
                    "url": resp.url,
                    "headers": dict(resp.request.headers),
                    "body": body,
                    "status": resp.status,
                }
                with open(CAPTURE, "a", encoding="utf-8") as f:
                    f.write(json.dumps(rec) + "\n")
                print("CAPTURED:", resp.request.method, resp.url)
        context.on("response", on_response)

        # if no state, do a quick login
        if not STATE.exists():
            page.goto("https://mufon.com", wait_until="domcontentloaded")
            for label in ["Login","Sign In","Member Login","Log in"]:
                try:
                    page.get_by_text(label, exact=True).click(timeout=3000); break
                except:
                    continue
            # fallbacks for inputs
            u = None
            for sel in ["input[name='username']","input#username","input[name='log']","input[type='text']","input[type='email']"]:
                loc = page.locator(sel)
                if loc.count(): u = loc.first; break
            psel = page.locator("input[type='password']").first
            assert u is not None, "username field not found"
            u.fill(USER); psel.fill(PASS)
            # submit
            for b in ["Login","Sign In","Log in","Submit"]:
                try:
                    page.get_by_role("button", name=b).click(timeout=2000); break
                except:
                    try:
                        page.get_by_text(b, exact=True).click(timeout=2000); break
                    except: pass
            page.wait_for_load_state("networkidle")
            context.storage_state(path=str(STATE))
            print("Saved storage state:", STATE)

        # guide: you do the clicks; we just record
        page.goto("https://mufon.com", wait_until="domcontentloaded")
        print("\n>>> NOW: Click Track UFOs → Database Search, set past-2-days and click Search.")
        print(">>> This window will capture the real request. Close it when results appear.\n")
        page.bring_to_front()

        # idle until user closes
        try:
            while True:
                time.sleep(1)
        except KeyboardInterrupt:
            pass
        browser.close()

if __name__ == "__main__":
    main()