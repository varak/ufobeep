import os, time, re, json
from datetime import datetime, timedelta
from pathlib import Path
from dotenv import load_dotenv
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout

load_dotenv()
USER = os.getenv("MUFON_USERNAME") or ""
PASS = os.getenv("MUFON_PASSWORD") or ""
assert USER and PASS, "Set MUFON_USERNAME and MUFON_PASSWORD in .env"

ART = Path("mufon_run"); ART.mkdir(exist_ok=True)

def now(): return time.strftime("%H:%M:%S")
def mmddyyyy(dt): return dt.strftime("%m/%d/%Y")

def log(page, msg):
    print(f"[{now()}] {msg} | URL: {page.url} | Title: {page.title()}")

def snap(page, name):
    (ART/f"{name}.html").write_text(page.content(), encoding="utf-8")
    page.screenshot(path=str(ART/f"{name}.png"), full_page=True)

def first(page, sels, timeout=6000):
    for s in sels:
        try:
            page.wait_for_selector(s, timeout=timeout)
            return page.locator(s).first
        except PWTimeout:
            continue
    return None

def click_any(page, labels, timeout=6000):
    cands=[]
    for t in labels:
        cands += [
            f"text={t}",
            f"role=link[name='{t}']",
            f"role=button[name='{t}']",
            f"//a[normalize-space()='{t}']",
            f"//button[normalize-space()='{t}']",
            f"//*[contains(normalize-space(), '{t}')]",
        ]
    for sel in cands:
        try:
            page.wait_for_selector(sel, timeout=timeout)
            page.locator(sel).first.click()
            return True
        except Exception:
            pass
    return False

def fill_dates(container, date_from, date_to):
    # Try common single inputs
    start_names = ["startDate","fromDate","dateFrom","beginDate","searchStartDate","date_from","StartDate"]
    end_names   = ["endDate","toDate","dateTo","endDate2","searchEndDate","date_to","EndDate"]
    filled=False
    for n in start_names:
        loc = container.locator(f"input[name='{n}']")
        if loc.count(): loc.first.fill(date_from); filled=True; break
    for n in end_names:
        loc = container.locator(f"input[name='{n}']")
        if loc.count(): loc.first.fill(date_to);   filled=True; break

    # If not, try MDY selects (prefix: from/start/begin and to/end)
    def parts(s): m,d,y = s.split("/"); return int(m), int(d), int(y)
    def try_triplet(prefix, m,d,y):
        ok=False
        pairs = [
            (f"{prefix}Month", m), (f"{prefix}M", m), (f"{prefix}_month", m),
            (f"{prefix}Day", d),   (f"{prefix}D", d), (f"{prefix}_day", d),
            (f"{prefix}Year", y),  (f"{prefix}Y", y), (f"{prefix}_year", y),
        ]
        for name, val in pairs:
            sel = container.locator(f"select[name='{name}']")
            if sel.count():
                try:
                    sel.first.select_option(str(val))
                except Exception:
                    try: sel.first.select_option(f"{val:02d}")
                    except Exception: pass
                ok=True
        return ok

    if not filled:
        m,d,y = parts(date_from); filled = try_triplet("from", m,d,y) or try_triplet("start", m,d,y) or try_triplet("begin", m,d,y)
        m,d,y = parts(date_to);   filled = try_triplet("to",   m,d,y) or try_triplet("end",   m,d,y) or filled
    return filled

def find_search_container(page):
    # Prefer iframes that look like Neon/z2
    for fr in page.frames:
        url = (fr.url or "").lower()
        if any(x in url for x in ["z2systems","neon","mufoncms"]):
            return fr
    # else use main page
    return page

def click_search(container):
    return click_any(container, ["Search","Find","Filter","Apply","Go","Submit"], timeout=4000)

def wait_results(container, ms=20000):
    base = container.locator("table tr").count() + container.locator("div.card, div.result, li").count()
    start = time.time()
    while (time.time()-start)*1000 < ms:
        time.sleep(0.3)
        nowc = container.locator("table tr").count() + container.locator("div.card, div.result, li").count()
        if nowc > base:
            return True
    return False

def parse_results(container):
    rows=[]
    tables = container.locator("table")
    for t in range(min(tables.count(),5)):
        tbl = tables.nth(t); trs = tbl.locator("tr")
        if trs.count()<2: continue
        headers=[trs.nth(0).locator("th,td").nth(i).inner_text().strip() for i in range(trs.nth(0).locator("th,td").count())]
        for r in range(1, trs.count()):
            tds=trs.nth(r).locator("td"); 
            if tds.count()<2: continue
            row={}
            for c in range(min(len(headers), tds.count())):
                row[(headers[c] or f"col_{c}")]=re.sub(r"\s+"," ",tds.nth(c).inner_text()).strip()
            if row: rows.append(row)
    if rows: return rows
    # fallback: cards
    items = container.locator("div.card, div.result, li, article")
    for i in range(min(items.count(),200)):
        txt = re.sub(r"\s+"," ", items.nth(i).inner_text()).strip()
        if re.search(r"case\s*#?\s*\d", txt, re.I): rows.append({"raw": txt})
    return rows

def main():
    today = datetime.now()
    date_from = mmddyyyy(today - timedelta(days=2))
    date_to   = mmddyyyy(today)

    # Use existing session if available
    state_file = Path("mufon_artifacts/storage_state.json")

    with sync_playwright() as p:
        browser = p.chromium.launch(headless=False, slow_mo=150)
        context = browser.new_context(
            viewport={"width":1400,"height":900},
            storage_state=str(state_file) if state_file.exists() else None
        )
        page = context.new_page()

        # Go to home page - login should be automatic if session exists
        page.goto("https://mufon.com", wait_until="domcontentloaded", timeout=60000)
        log(page, "Home"); snap(page, "00_home")
        
        # Check if already logged in by looking for logout/member elements
        if not any(page.locator(sel).count() > 0 for sel in ["text=Logout", "text=My Account", "text=Member"]):
            # Need to login
            if not click_any(page, ["Login","Sign In","Member Login","Log in"]):
                page.goto("https://mufon.com/login/", wait_until="load")
            page.wait_for_load_state("networkidle")
            log(page, "Login page"); snap(page, "01_login")

            # Fill creds
            u = first(page, ["input[name='username']","input#username","input[name='log']","input[type='text']","input[type='email']"])
            psel = first(page, ["input[name='password']","input#password","input[type='password']"])
            assert u and psel, "Login inputs not found (see 01_login.html)"
            u.fill(USER); psel.fill(PASS)
            if not click_any(page, ["Login","Sign In","Log in","Submit"]):
                psel.press("Enter")
            page.wait_for_load_state("networkidle")
            log(page, "Post-login"); snap(page, "02_post_login")
        else:
            print("Already logged in, proceeding to search")

        # Track UFOs → Database Search
        click_any(page, ["Track UFOs","TRACK UFOS","Track UFO's"])
        time.sleep(0.8)
        click_any(page, ["Database Search","Search Database","Case Search","UFO Database"])
        page.wait_for_load_state("networkidle")
        log(page, "Database Search landing"); snap(page, "03_db_landing")

        # Accept T&C if shown
        # common patterns: radio + continue
        click_any(page, ["I Agree","I Accept","Agree","Accept"])
        click_any(page, ["Continue","Proceed","Next"])

        # Work inside the real container (iframe or page)
        container = find_search_container(page)
        snap(container.page if hasattr(container,"page") else container, "04_container")

        # Try to auto-fill last 2 days, else let the user do it manually
        auto = fill_dates(container, date_from, date_to)
        if auto:
            click_search(container)
            ok = wait_results(container, 20000)
            if not ok:
                print("\n--- Results not detected quickly. You can finish the search manually in the open browser. ---")
                input("When you see results, press ENTER here… ")
        else:
            print("\n--- Could not auto-detect date inputs. Please set dates & click Search manually in the open browser. ---")
            input("When results appear, press ENTER here… ")

        snap(page, "05_results")
        rows = parse_results(container)
        out = ART/"results.json"
        out.write_text(json.dumps({"from":date_from,"to":date_to,"rows":rows}, indent=2), encoding="utf-8")
        print(f"\nSaved results: {out}\nParsed rows: {len(rows)}")

        browser.close()

if __name__ == "__main__":
    main()