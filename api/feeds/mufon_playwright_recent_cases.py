import os, json, re, time
from datetime import datetime, timedelta
from pathlib import Path
from contextlib import contextmanager
from dotenv import load_dotenv
from playwright.sync_api import sync_playwright, TimeoutError as PWTimeout
from urllib.parse import urlparse

load_dotenv()

# ---------- config ----------
HEADFUL = os.getenv("HEADFUL", "false").lower() == "true"
USERNAME = os.getenv("MUFON_USERNAME", "varak")
PASSWORD = os.getenv("MUFON_PASSWORD", "ufobeep123pass")
DAYS_BACK_START = int(os.getenv("DAYS_BACK_START", "2"))  # how many days back for start
DAYS_BACK_END = int(os.getenv("DAYS_BACK_END", "0"))      # how many days back for end
OUTPUT_JSON = os.getenv("OUTPUT_JSON", "results_mufon.json")

assert USERNAME and PASSWORD, "Set MUFON_USERNAME and MUFON_PASSWORD in .env"

ART = Path("mufon_artifacts"); ART.mkdir(exist_ok=True)
STATE = ART / "storage_state.json"

# ========== HARDENED HELPERS ==========

def dump_forms(container, tag="forms_inventory"):
    page = container.page if hasattr(container, "page") else container
    html = page.content()
    (ART / f"{tag}.html").write_text(html, encoding="utf-8")
    # Lightweight inventory (names, types, placeholders)
    forms = []
    form_els = container.locator("form")
    for i in range(form_els.count()):
        f = form_els.nth(i)
        inputs = []
        ins = f.locator("input, select, textarea")
        for j in range(ins.count()):
            el = ins.nth(j)
            name = el.get_attribute("name")
            typ  = (el.get_attribute("type") or el.evaluate("e => e.tagName")).lower()
            ph   = el.get_attribute("placeholder")
            idv  = el.get_attribute("id")
            inputs.append({"name": name, "type": typ, "placeholder": ph, "id": idv})
        forms.append({"idx": i, "inputs": inputs})
    (ART / f"{tag}.json").write_text(json.dumps(forms, indent=2), encoding="utf-8")
    print(f"[{now()}] Dumped {len(forms)} forms to {tag}.json")

def locate_search_container(page):
    """
    Returns the page or the correct Frame that actually holds the search form.
    Prefers iframes with z2systems/neon/mufoncms in src.
    """
    frames = page.frames
    # Prefer known vendor frames
    for fr in frames:
        try:
            src = fr.url or ""
            host = urlparse(src).netloc.lower()
            if any(k in src.lower() for k in ["z2systems", "neon", "mufoncms"]):
                return fr
            if any(k in host for k in ["z2systems", "neon", "mufoncms"]):
                return fr
        except Exception:
            continue
    # Fallback: frame that actually has many inputs/buttons
    best = None; best_score = 0
    for fr in frames:
        try:
            score = fr.locator("input, select").count() + fr.locator("button").count()
            if score > best_score:
                best = fr; best_score = score
        except Exception:
            continue
    return best or page

def try_fill_single_date_inputs(container, date_from, date_to):
    """
    Tries common single text/date inputs for from/to.
    Returns True if something was filled.
    """
    candidates_from = [
        "startDate","fromDate","dateFrom","beginDate","searchStartDate","date_from","DateFrom","StartDate"
    ]
    candidates_to = [
        "endDate","toDate","dateTo","endDate2","searchEndDate","date_to","DateTo","EndDate"
    ]
    filled = False
    for name in candidates_from:
        loc = container.locator(f"input[name='{name}']")
        if loc.count() > 0:
            loc.first.fill(date_from); filled = True; break
    for name in candidates_to:
        loc = container.locator(f"input[name='{name}']")
        if loc.count() > 0:
            loc.first.fill(date_to); filled = True; break

    # Fallback: first two date-like inputs by placeholder
    if not filled:
        ins = container.locator("input[type='date'], input[type='text']")
        # heuristics for "from"/"to"
        idxs = []
        for i in range(min(ins.count(), 10)):
            ph = (ins.nth(i).get_attribute("placeholder") or "").lower()
            nm = (ins.nth(i).get_attribute("name") or "").lower()
            if any(k in ph+nm for k in ["from","start","begin","date"]):
                idxs.append(i)
        if len(idxs) >= 1:
            ins.nth(idxs[0]).fill(date_from); filled = True
            if len(idxs) >= 2:
                ins.nth(idxs[1]).fill(date_to)
    return filled

def try_fill_mdy_selects(container, date_from, date_to):
    """
    Some Neon pages use 3 selects per date (month/day/year).
    We look for select names that share a prefix like fromMonth/fromDay/fromYear.
    """
    def parts(dt):
        m,d,y = dt.split("/")
        return {"m": int(m), "d": int(d), "y": int(y)}
    pf = parts(date_from); pt = parts(date_to)
    filled = False

    # Enumerate select names
    selects = []
    sel = container.locator("select")
    for i in range(sel.count()):
        n = sel.nth(i).get_attribute("name") or ""
        selects.append(n)

    def set_triplet(prefix, P):
        ok = False
        pairs = [
            (f"{prefix}Month", P["m"]),
            (f"{prefix}M",     P["m"]),
            (f"{prefix}_month",P["m"]),
            (f"{prefix}Day",   P["d"]),
            (f"{prefix}D",     P["d"]),
            (f"{prefix}_day",  P["d"]),
            (f"{prefix}Year",  P["y"]),
            (f"{prefix}Y",     P["y"]),
            (f"{prefix}_year", P["y"]),
        ]
        for name, val in pairs:
            if name in selects:
                s = container.locator(f"select[name='{name}']").first
                try:
                    s.select_option(str(val)); ok = True
                except Exception:
                    # maybe option values are zero-padded or month names
                    try: s.select_option(f"{val:02d}"); ok = True
                    except Exception:
                        try:
                            if "Month" in name or name.endswith(("M","_month")):
                                # select by label (Jan, February, etc.)
                                s.select_option(label=str(val))
                        except Exception:
                            pass
        return ok

    # Try common prefixes
    if set_triplet("from", pf): filled = True
    if set_triplet("start", pf): filled = True
    if set_triplet("begin", pf): filled = True

    if set_triplet("to", pt): filled = True
    if set_triplet("end", pt): filled = True

    return filled

def click_search(container):
    labels = ["Search","Find","Filter","Apply","Go","Submit"]
    for lab in labels:
        try:
            container.locator(f"text={lab}").first.click()
            return True
        except Exception:
            pass
        # buttons/inputs
        try:
            container.locator(f"//button[normalize-space()='{lab}']").first.click()
            return True
        except Exception:
            pass
        try:
            container.locator(f"//input[@type='submit' and @value='{lab}']").first.click()
            return True
        except Exception:
            pass
    # last resort: submit the first form
    try:
        container.locator("form").first.evaluate("f => f.submit()")
        return True
    except Exception:
        return False

def wait_for_results_bounded(container, max_ms=20000):
    """
    Waits for either new table rows/cards OR a network response that looks like results.
    Returns True if something changed, else False (we don't hang forever).
    """
    page = container.page if hasattr(container, "page") else container
    start = time.time()
    baseline = (container.locator("table tr").count() if container.locator("table").count() else 0) \
             + container.locator("div.card, div.result, li").count()

    # try to catch any response that contains case-ish data
    seen_response = {"hit": False}
    def on_resp(resp):
        try:
            url = resp.url.lower()
            if any(k in url for k in ["z2systems","neon","mufoncms","search","case"]):
                seen_response["hit"] = True
        except Exception:
            pass
    page.on("response", on_resp)

    while (time.time() - start) * 1000 < max_ms:
        time.sleep(0.3)
        now_count = (container.locator("table tr").count() if container.locator("table").count() else 0) \
                  + container.locator("div.card, div.result, li").count()
        if now_count > baseline or seen_response["hit"]:
            return True
    return False

def parse_results_relaxed(container):
    rows = []
    # tables first
    tables = container.locator("table")
    for t in range(min(tables.count(), 5)):  # avoid huge scans
        tbl = tables.nth(t)
        trs = tbl.locator("tr")
        if trs.count() < 2: continue
        headers = []
        ths = trs.nth(0).locator("th,td")
        for i in range(ths.count()):
            headers.append(re.sub(r"\s+"," ", ths.nth(i).inner_text()).strip())
        for r in range(1, trs.count()):
            tds = trs.nth(r).locator("td")
            if tds.count() < 2: continue
            row = {}
            for c in range(min(len(headers), tds.count())):
                k = headers[c] or f"col_{c}"
                v = re.sub(r"\s+"," ", tds.nth(c).inner_text()).strip()
                a = tds.nth(c).locator("a")
                if a.count() > 0:
                    href = a.first.get_attribute("href") or ""
                    if href: row[f"{k}_link"] = href
                row[k] = v
            if any(re.search(p, json.dumps(row), re.I) for p in [r"case\s*#?\s*\d", r"\b20\d{2}\b", r"city|state|location|summary|desc"]):
                rows.append(row)
    if rows: return rows
    # fallback: cards/lists
    items = container.locator("div.card, div.result, li, article")
    for i in range(min(items.count(), 200)):
        txt = re.sub(r"\s+"," ", items.nth(i).inner_text()).strip()
        if re.search(r"case\s*#?\s*\d", txt, re.I):
            rows.append({"raw": txt})
    return rows

def do_recent_cases_search(page, date_from, date_to):
    """
    Full guarded flow:
    - find correct container (frame vs page)
    - dump forms
    - try single inputs; if not, try MDY selects
    - submit
    - bounded wait
    - parse
    """
    container = locate_search_container(page)
    target_page = container.page if hasattr(container, "page") else container
    log(target_page, "Located search container (page or frame)")
    dump_forms(container, tag="04c_forms_before_fill")

    filled = try_fill_single_date_inputs(container, date_from, date_to)
    if not filled:
        filled = try_fill_mdy_selects(container, date_from, date_to)

    snap(target_page, "04d_after_fill_dates")

    if not click_search(container):
        snap(target_page, "04e_no_search_button")
        raise RuntimeError("Could not find any Search/Submit control on the search container.")

    # bounded wait (no infinite hang)
    ok = wait_for_results_bounded(container, max_ms=25000)
    snap(target_page, "05_results_after_wait")

    if not ok:
        raise TimeoutError("Results did not appear within 25s; check 04c/04d/04e artifacts.")

    rows = parse_results_relaxed(container)
    return rows

# ========== ORIGINAL HELPERS ==========

def now():
    return time.strftime("%H:%M:%S")

def log(page, msg):
    print(f"[{now()}] {msg}  |  URL: {page.url}  |  Title: {page.title()}")

def snap(page, tag):
    (ART / f"{tag}.html").write_text(page.content(), encoding="utf-8")
    page.screenshot(path=str(ART / f"{tag}.png"), full_page=True)

def mmddyyyy(dt: datetime) -> str:
    return dt.strftime("%m/%d/%Y")

today = datetime.now()
date_from = mmddyyyy(today - timedelta(days=DAYS_BACK_START))
date_to   = mmddyyyy(today - timedelta(days=DAYS_BACK_END))

def normalize(s: str) -> str:
    return re.sub(r"\s+", " ", s or "").strip()

def first_present(page, selectors, timeout=8000):
    """Return locator for the first working selector."""
    for sel in selectors:
        try:
            loc = page.locator(sel)
            page.wait_for_selector(sel, timeout=timeout)
            return loc
        except PWTimeout:
            continue
    return None

def robust_click(page, texts_or_selectors, timeout=10000):
    """Click by exact text or CSS/XPath, trying several strategies."""
    candidates = []
    for t in texts_or_selectors:
        candidates += [
            f"text={t}",
            f"role=link[name='{t}']",
            f"role=button[name='{t}']",
            f"//a[normalize-space()='{t}']",
            f"//button[normalize-space()='{t}']",
            t,  # allow raw selector
        ]
    for sel in candidates:
        try:
            page.wait_for_selector(sel, timeout=timeout)
            page.locator(sel).first.click()
            return True
        except PWTimeout:
            continue
        except Exception:
            continue
    return False

def wait_network_quiet(page, timeout=60000):
    page.wait_for_load_state("domcontentloaded", timeout=timeout)
    page.wait_for_load_state("networkidle", timeout=timeout)

@contextmanager
def tracing(context, name="trace"):
    context.tracing.start(screenshots=True, snapshots=True, sources=True)
    try:
        yield
    finally:
        context.tracing.stop(path=str(ART / f"{name}.zip"))

def ensure_login(context):
    """Open a page, navigate to login, submit, and persist storage state."""
    page = context.new_page()
    page.on("framenavigated", lambda fr: print(f"→ NAV: {fr.url}"))

    page.goto("https://mufon.com", wait_until="domcontentloaded", timeout=60000)
    wait_network_quiet(page)  # Wait for full page load including dynamic content
    log(page, "Home loaded"); snap(page, "00_home")

    # Try obvious login entry points; adjust if MUFON changes.
    # The Member Login link has target="_blank" so we need to handle new tab behavior
    clicked = False
    try:
        # Look for the specific Member Login link structure
        member_login = page.locator("a[href*='z2systems.com']:has-text('Member Login')")
        if member_login.count() > 0:
            # Get the href directly and navigate to it instead of clicking
            href = member_login.first.get_attribute("href")
            if href:
                print(f"Found Member Login link: {href}")
                page.goto(href, wait_until="load")
                clicked = True
    except Exception as e:
        print(f"Member Login navigation failed: {e}")
    
    if not clicked:
        # Try other variations with same approach (avoid target="_blank" issues)
        login_selectors = [
            "a[href*='z2systems.com']",
            "a:has-text('Login')",
            "a:has-text('Sign In')",  
            "a:has-text('Member Login')",
            "a:has-text('Log in')",
            "a:has-text('MEMBER LOGIN')"
        ]
        for selector in login_selectors:
            try:
                link = page.locator(selector).first
                if link.count() > 0:
                    href = link.get_attribute("href")
                    if href and "z2systems.com" in href:
                        print(f"Found login link via {selector}: {href}")
                        page.goto(href, wait_until="load")
                        clicked = True
                        break
            except Exception:
                continue
    
    if not clicked:
        # fallback known login path - go direct to z2systems
        print("All login link detection failed, using direct z2systems URL")
        page.goto("https://mufon.z2systems.com/np/clients/mufon/login.jsp", wait_until="load")

    wait_network_quiet(page)
    log(page, "Login page"); snap(page, "01_login")

    # Try z2systems specific fields first, then common username/password selectors
    user_sel = first_present(page, ["input[name='loginName']", "input[name='username']", "input#username", "input[name='log']", "input[type='email']", "input[type='text']"])
    pass_sel = first_present(page, ["input[name='loginPassword']", "input[name='password']", "input#password", "input[type='password']"])
    assert user_sel and pass_sel, "Login fields not found. Inspect 01_login.html"

    user_sel.fill(USERNAME)
    pass_sel.fill(PASSWORD)

    # Try submit
    if not robust_click(page, ["Login", "Sign In", "Log in", "Submit", "Sign In →"]):
        # fallback: find submit button in the login form
        login_form = page.locator("form").filter(has=page.locator("input[name='loginName'], input[name='username']"))
        if login_form.count() > 0:
            submit_btn = login_form.locator("input[type='submit'], button[type='submit']")
            if submit_btn.count() > 0:
                submit_btn.first.click()
            else:
                # fallback submit by Enter
                pass_sel.press("Enter")
        else:
            pass_sel.press("Enter")

    wait_network_quiet(page)
    log(page, "Post-login"); snap(page, "02_post_login")

    # Save login state
    context.storage_state(path=str(STATE))
    page.close()

def open_with_state(p):
    browser = p.chromium.launch(headless=not HEADFUL, args=["--disable-blink-features=AutomationControlled"])
    if STATE.exists():
        context = browser.new_context(storage_state=str(STATE), viewport={"width": 1400, "height": 900})
    else:
        context = browser.new_context(viewport={"width": 1400, "height": 900})
    return browser, context

def navigate_to_database_search(page):
    """Clicks: Track UFOs → Database Search, handling menus, new tabs, and redirects."""
    log(page, "Navigate to Database Search start")

    # Go to a known landing page after login
    page.goto("https://mufon.com", wait_until="domcontentloaded")
    wait_network_quiet(page)
    snap(page, "03_home_after_login")

    # Some sites open menu items in new tabs; capture popup if it happens.
    # Use shorter timeout since popup may not occur
    clicked = False
    try:
        with page.expect_popup(timeout=5000) as maybe_popup:
            clicked = robust_click(page, ["Track UFOs", "TRACK UFOS", "Track UFO's", "Track UFO's", "TRACK UFO's"])
        if clicked:
            try:
                popup = maybe_popup.value
                # If a popup opened, prefer it; otherwise continue on same page.
                page = popup
                wait_network_quiet(page)
                log(page, "Switched to popup window")
                snap(page, "03a_track_ufos_popup")
            except Exception:
                # No popup, continue on same page
                pass
    except Exception as e:
        # Popup didn't happen, try clicking without popup expectation
        print(f"No popup detected: {e}")
        clicked = robust_click(page, ["Track UFOs", "TRACK UFOS", "Track UFO's", "Track UFO's", "TRACK UFO's"])

    # If there is a submenu, click Database Search
    # Try same page first
    wait_network_quiet(page)
    snap(page, "03b_after_track_ufos")
    
    found = robust_click(page, ["Database Search", "Search Database", "SEARCH DATABASE", "Case Search", "UFO Database"])
    if not found:
        # Sometimes "Track UFOs" link goes to a landing page with tiles
        wait_network_quiet(page)
        found = robust_click(page, ["Database Search", "Search Database", "SEARCH DATABASE", "Case Search", "UFO Database"])

    wait_network_quiet(page)
    log(page, "After clicking Database Search"); snap(page, "04_database_search_landing")

    # Handle Terms and Conditions if we're on that page
    if "terms-and-conditions" in page.url.lower() or "terms" in page.title().lower():
        log(page, "On Terms and Conditions page, looking for agreement form")
        
        # Try to find and select the "Yes, I Agree" radio button
        agreement_handled = False
        
        # Try specific MUFON radio button selectors first
        radio_selectors = [
            "input[type='radio'][value*='agree']",  # Specific MUFON "Yes, I Agree" radio
            "input[type='radio'][id*='agree']",
            "input[type='radio'][id*='field_d0befae-0']",  # Exact field from HTML
            "input[type='radio']:first-child"  # First radio button (likely "agree")
        ]
        
        for selector in radio_selectors:
            try:
                radio = page.locator(selector).first
                if radio.count() > 0:
                    if not radio.is_checked():
                        radio.check()
                        print(f"  ✅ Checked agreement radio button: {selector}")
                    agreement_handled = True
                    break
            except Exception as e:
                print(f"  Debug: Radio selector {selector} failed: {e}")
                continue
        
        # Fallback: try checkbox selectors in case structure differs
        if not agreement_handled:
            checkbox_selectors = [
                "input[type='checkbox'][name*='agree']",
                "input[type='checkbox'][name*='accept']", 
                "input[type='checkbox'][name*='terms']",
                "input[type='checkbox'][name*='consent']",
                "input[type='checkbox']"
            ]
            
            for selector in checkbox_selectors:
                try:
                    checkbox = page.locator(selector).first
                    if checkbox.count() > 0:
                        if not checkbox.is_checked():
                            checkbox.check()
                            print(f"  ✅ Checked agreement checkbox: {selector}")
                        agreement_handled = True
                        break
                except Exception:
                    continue
        
        # Try to find and click the submit button for the agreement form
        if agreement_handled:
            print("  ⏳ Agreement selection made, looking for submit button...")
            
            # Try form-specific submit button first
            form_submit_clicked = False
            try:
                agreement_form = page.locator("form[name='agreeement_form'], form[id='myForm']").first
                if agreement_form.count() > 0:
                    submit_btn = agreement_form.locator("button[type='submit'], input[type='submit']").first
                    if submit_btn.count() > 0:
                        submit_btn.click()
                        form_submit_clicked = True
                        print(f"  ✅ Clicked agreement form submit button")
            except Exception as e:
                print(f"  Debug: Form submit failed: {e}")
            
            # Fallback to generic submit button search
            if not form_submit_clicked:
                agree_clicked = robust_click(page, [
                    "Submit", "I Agree", "Agree", "Accept", "Continue", "Proceed", 
                    "Search Database", "Enter Database", "Access Database"
                ])
                if agree_clicked:
                    print(f"  ✅ Clicked agreement button via robust_click")
            
            wait_network_quiet(page)
            log(page, "Terms accepted, waiting for database search form")
            snap(page, "04b_after_terms_accepted")
        else:
            print("  ⚠️ Could not find terms and conditions agreement form")

    # If the site embeds the search in an iframe, switch into it.
    frames = [f for f in page.frames if f != page.main_frame]
    for fr in frames:
        try:
            # Look for date fields in the frame
            if fr.locator("input[type='text'], input[type='date']").count() > 0:
                log(page, "Found search form in iframe")
                return fr
        except Exception:
            continue
    return page  # default to main page/frame

def fill_dates_and_search(ctx, container, date_from, date_to):
    """Fill date range and hit Search. 'container' is a Page or Frame."""
    page = container.page if hasattr(container, "page") else container
    log(page, f"Filling dates: {date_from} to {date_to}")
    
    # MUFON/Neon are notorious for different field names — try a bunch:
    start_fields = ["startDate", "fromDate", "dateFrom", "beginDate", "searchStartDate", "event_date_from", "date_from"]
    end_fields   = ["endDate", "toDate", "dateTo", "endDate2", "searchEndDate", "event_date_to", "date_to"]  
    search_buttons = ["Search", "Find", "Submit", "Go", "Filter", "Apply"]

    # Take screenshot before filling
    snap(page, "04a_before_fill_dates")

    start_ok = False
    for name in start_fields:
        loc = container.locator(f"input[name='{name}']")
        if loc.count() > 0:
            loc.first.fill(date_from); start_ok = True
            print(f"  ✅ Filled start date field: {name} = {date_from}")
            break
    if not start_ok:
        # fallback: first date-like input
        all_inputs = container.locator("input[type='date'], input[type='text']")
        for i in range(min(all_inputs.count(), 10)):
            ph = (all_inputs.nth(i).get_attribute("placeholder") or "").lower()
            name = all_inputs.nth(i).get_attribute("name") or f"input_{i}"
            if any(k in ph for k in ["from", "start", "begin", "date"]) or any(k in name.lower() for k in ["from", "start", "begin", "date"]):
                all_inputs.nth(i).fill(date_from); start_ok = True
                print(f"  ✅ Filled start date fallback: {name} = {date_from}")
                break

    end_ok = False
    for name in end_fields:
        loc = container.locator(f"input[name='{name}']")
        if loc.count() > 0:
            loc.first.fill(date_to); end_ok = True
            print(f"  ✅ Filled end date field: {name} = {date_to}")
            break
    if not end_ok:
        # fallback: next date-like input
        all_inputs = container.locator("input[type='date'], input[type='text']")
        for i in range(min(all_inputs.count(), 10)):
            ph = (all_inputs.nth(i).get_attribute("placeholder") or "").lower()
            name = all_inputs.nth(i).get_attribute("name") or f"input_{i}"
            if any(k in ph for k in ["to", "end", "until"]) or any(k in name.lower() for k in ["to", "end", "until"]):
                all_inputs.nth(i).fill(date_to); end_ok = True
                print(f"  ✅ Filled end date fallback: {name} = {date_to}")
                break

    if not start_ok:
        print(f"  ⚠️ Could not find start date field")
    if not end_ok:
        print(f"  ⚠️ Could not find end date field")

    # Take screenshot after filling
    snap(page, "04b_after_fill_dates")

    # Click Search
    clicked = robust_click(container, search_buttons)
    if not clicked:
        # try submit in form
        print("  ⚠️ No search button found, trying form submit")
        try:
            forms = container.locator("form")
            if forms.count() > 0:
                forms.first.evaluate("f => f.submit()")
        except Exception as e:
            print(f"  ❌ Form submit failed: {e}")

    # Wait for results
    wait_network_quiet(page)
    log(page, "Search submitted, waiting for results")
    snap(page, "05_results")

def parse_results(container):
    """Return a list of dict rows from the results table/cards."""
    rows = []
    page = container.page if hasattr(container, "page") else container
    
    print(f"  📊 Parsing results from {page.url}")

    # Try tables first
    tables = container.locator("table")
    print(f"  Found {tables.count()} tables")
    
    for t in range(tables.count()):
        tbl = tables.nth(t)
        trs = tbl.locator("tr")
        if trs.count() < 2:
            continue
        print(f"    Table {t}: {trs.count()} rows")
        
        # headers
        headers = []
        ths = trs.nth(0).locator("th,td")
        for i in range(ths.count()):
            headers.append(normalize(ths.nth(i).inner_text()))
        if not headers:
            continue

        print(f"      Headers: {headers}")

        # body
        for r in range(1, min(trs.count(), 50)):  # Limit to first 50 rows
            tds = trs.nth(r).locator("td")
            if tds.count() < 2:
                continue
            row = {}
            for c in range(min(len(headers), tds.count())):
                key = headers[c] or f"col_{c}"
                val = normalize(tds.nth(c).inner_text())
                # try pulling a link to case detail
                a = tds.nth(c).locator("a")
                if a.count() > 0:
                    href = a.first.get_attribute("href") or ""
                    if href:
                        row[f"{key}_link"] = href
                row[key] = val
            if any(k for k in row if re.search(r"case|date|city|state|location|summary|desc", k, re.I)):
                rows.append(row)
                print(f"      Row {r}: {row}")

    # Fallback: card/list items with case patterns
    if not rows:
        print("  No table data found, trying cards/list items")
        items = container.locator("li, article, div.card, div.result, div.search-result, div[class*='case'], tr")
        print(f"  Found {items.count()} potential items")
        
        for i in range(min(items.count(), 300)):
            txt = normalize(items.nth(i).inner_text())
            if len(txt) > 20 and re.search(r"case\s*#?\s*\d|report\s*#?\s*\d|\d{4,6}", txt, re.I):
                # Extract case number if possible
                case_match = re.search(r"case\s*#?\s*(\d+)|report\s*#?\s*(\d+)|(\d{4,6})", txt, re.I)
                case_num = None
                if case_match:
                    case_num = case_match.group(1) or case_match.group(2) or case_match.group(3)
                
                row = {"raw": txt}
                if case_num:
                    row["case_number"] = case_num
                
                # Try to extract date
                date_match = re.search(r"(\d{1,2}[/-]\d{1,2}[/-]\d{2,4})", txt)
                if date_match:
                    row["date"] = date_match.group(1)
                
                # Try to extract location
                location_match = re.search(r"([A-Za-z\s]+),\s*([A-Z]{2})", txt)
                if location_match:
                    row["location"] = f"{location_match.group(1)}, {location_match.group(2)}"
                
                rows.append(row)
                print(f"      Item {i}: case={case_num}, text={txt[:100]}...")

    # Filter out obvious "famous cases" if they sneak in
    bad_words = ["Roswell 1947", "Aurora 1897", "Kecksburg 1965", "Mantell 1948", "Washington DC 1952"]
    original_count = len(rows)
    rows = [r for r in rows if not any(b in json.dumps(r) for b in bad_words)]
    filtered_count = original_count - len(rows)
    if filtered_count > 0:
        print(f"  🚫 Filtered out {filtered_count} famous/historical cases")
    
    return rows

def main():
    print(f"🛸 MUFON Recent Cases Scraper")
    print(f"📅 Date range: {date_from} to {date_to}")
    print(f"👤 Username: {USERNAME}")
    print(f"🎭 Headful: {HEADFUL}")
    
    with sync_playwright() as p:
        browser, context = open_with_state(p)
        with tracing(context, "mufon_trace"):
            # ensure we have a logged-in state
            if not STATE.exists():
                print("🔐 No saved login state, logging in...")
                ensure_login(context)
                print("✅ Login completed and saved")

            page = context.new_page()
            page.on("framenavigated", lambda fr: print(f"→ NAV: {fr.url}"))

            # go straight with stored session
            page.goto("https://mufon.com", wait_until="domcontentloaded", timeout=60000)
            wait_network_quiet(page)
            log(page, "Session restored"); snap(page, "03b_home_with_state")

            container = navigate_to_database_search(page)
            log(page if container == page else container.page, "On/inside Database Search page")

            # fill last-2-days and search
            fill_dates_and_search(context, container, date_from, date_to)

            # parse
            rows = parse_results(container)
            print(f"[{now()}] 📊 Parsed {len(rows)} rows")
            
            result_data = {
                "timestamp": datetime.now().isoformat(),
                "date_range": {"from": date_from, "to": date_to}, 
                "total_rows": len(rows),
                "rows": rows
            }
            
            Path(OUTPUT_JSON).write_text(json.dumps(result_data, indent=2), encoding="utf-8")
            print(f"💾 Saved: {OUTPUT_JSON}")
            
            # Print summary
            if rows:
                print(f"\n📋 SUMMARY:")
                print(f"  • Total cases found: {len(rows)}")
                for i, row in enumerate(rows[:5]):  # Show first 5
                    case_num = row.get('case_number', 'N/A')
                    date = row.get('date', 'N/A') 
                    location = row.get('location', 'N/A')
                    raw = row.get('raw', '')[:50] if row.get('raw') else 'N/A'
                    print(f"  {i+1}. Case {case_num} | {date} | {location} | {raw}...")
            else:
                print("⚠️ No cases found - check artifacts for debugging")
                
        browser.close()

if __name__ == "__main__":
    main()