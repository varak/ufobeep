# extend_mufon_details.py
# Minimal, focused VIEW-clicker that reuses saved auth and never redoes the login flow.

import json, re, time
from pathlib import Path
from typing import Optional, Tuple
from playwright.sync_api import sync_playwright

# === CONFIG ===
RESULTS_URL = "https://mufon.app.neoncrm.com/np/clients/mufon/neonPage.jsp?pageId=19&"
STORAGE_STATE = "mufon_artifacts/storage_state.json"
JSON_PATH = "mufon_current_results.json"
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

def extract_long_description(container) -> Optional[str]:
    # Try common IDs/classes then a label-following XPath, then largest paragraph as fallback.
    candidates = [
        "#longDescription",
        "#description",
        ".long-description",
        ".description",
        "xpath=//*[contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'description of event')]/following::*[1]",
        "xpath=//*[contains(translate(., 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz'),'long description')]/following::*[1]",
    ]
    for sel in candidates:
        try:
            el = container.locator(sel).first
            el.wait_for(timeout=1500)
            txt = el.inner_text().strip()
            if len(txt) > 25:
                return txt
        except Exception:
            pass
    try:
        paras = container.locator("p")
        n = paras.count()
        best = ""
        for i in range(min(n, 60)):
            t = paras.nth(i).inner_text().strip()
            if len(t) > len(best):
                best = t
        return best if len(best) > 25 else None
    except Exception:
        return None

def click_view_in_row(frame, row):
    # Try several strategies to find a VIEW control inside this row.
    labels = [r"view", r"details"]
    cands = []
    for lbl in labels:
        cands.append(row.get_by_role("button", name=re.compile(lbl, re.I)).first)
        cands.append(row.get_by_role("link", name=re.compile(lbl, re.I)).first)
        cands.append(row.locator(f"text=/{lbl}/i").first)
    cands.append(row.locator("td:last-child >> role=button").first)
    cands.append(row.locator("td:last-child a").first)

    for cand in cands:
        try:
            with frame.page.context.expect_page(timeout=2500) as pop_ev:
                cand.click(timeout=2000, force=True)
            new_page = pop_ev.value
            new_page.wait_for_load_state("domcontentloaded", timeout=10000)
            return ("popup", new_page)
        except Exception:
            # No popup; try same-frame nav
            try:
                before_url = frame.frame.url
            except Exception:
                before_url = None
            try:
                cand.click(timeout=2000, force=True)
            except Exception:
                continue
            changed = False
            try:
                frame.frame.wait_for_url(lambda url: url != before_url, timeout=5000)
                changed = True
            except Exception:
                pass
            if not changed:
                for sel in ["#longDescription", ".long-description", "text=Description"]:
                    try:
                        frame.locator(sel).first.wait_for(timeout=2000)
                        changed = True
                        break
                    except Exception:
                        pass
            if changed:
                return ("inframe", frame)
    raise RuntimeError("VIEW control not found/clickable in this row.")

def main():
    data = load_cases()
    with sync_playwright() as p:
        browser = p.chromium.launch(headless=True)
        context = browser.new_context(storage_state=STORAGE_STATE)
        context.tracing.start(screenshots=True, snapshots=True, sources=True)

        page = context.new_page()
        page.goto(RESULTS_URL, wait_until="domcontentloaded", timeout=45000)

        # Lock onto the results iframe; tighten selector if needed:
        results_frame = page.frame_locator("iframe").first
        results_frame.locator("table tbody tr, [role='row']").first.wait_for(timeout=8000)

        rows = results_frame.locator("table tbody tr")
        count = rows.count()
        print(f"Found {count} rows.")

        visited = set()

        for i in range(count):
            row = rows.nth(i)
            text = ""
            try:
                text = row.inner_text(timeout=3000).strip()
            except Exception:
                pass
            cid = case_id_from_row_text(text) or f"row{i+1}"
            if cid in visited:
                print("Skip", cid, "(visited)")
                continue
            visited.add(cid)

            try:
                mode, container = click_view_in_row(results_frame, row)
            except Exception as e:
                print(f"[WARN] {cid}: cannot click VIEW: {e}")
                continue

            src = container if mode == "popup" else results_frame
            try:
                long_desc = extract_long_description(src) or "(No long description found)"
            except Exception:
                long_desc = "(No long description found)"

            # Merge into JSON by case_id
            found = False
            for c in data.get("cases", []):
                if str(c.get("case_id")) == str(cid):
                    c["long_description"] = long_desc
                    found = True
                    break
            if not found:
                data.setdefault("cases", []).append({"case_id": cid, "long_description": long_desc})
            save_cases(data)
            print(f"[OK] {cid}: {len(long_desc)} chars")

            # Go back to results without history.back()
            if mode == "popup":
                try:
                    container.close()
                except Exception:
                    pass
            else:
                # Prefer explicit Back/Results control if it exists, else reload results URL
                try:
                    results_frame.get_by_role("link", name=re.compile(r"back|return|results", re.I)).first.click(timeout=1500)
                    results_frame.locator("table tbody tr, [role='row']").first.wait_for(timeout=8000)
                except Exception:
                    page.goto(RESULTS_URL, wait_until="domcontentloaded", timeout=45000)
                    results_frame = page.frame_locator("iframe").first
                    results_frame.locator("table tbody tr, [role='row']").first.wait_for(timeout=8000)
                    rows = results_frame.locator("table tbody tr")
                    count = rows.count()

        context.tracing.stop(path="trace.zip")
        browser.close()

if __name__ == "__main__":
    main()
