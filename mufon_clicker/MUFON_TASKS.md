# MUFON — Immediate Task List (Short, Ordered)

## Prereqs (5 minutes)
- [ ] Paste your exact results page URL into `RESULTS_URL` in `extend_mufon_details.py`.
- [ ] Confirm the saved auth exists at `mufon_artifacts/storage_state.json`.
- [ ] Ensure `mufon_working_results.json` is present (the file with the cases + media already imported).

## Click + Scrape (15 minutes)
- [ ] Launch Playwright with `storage_state` (no login).
- [ ] Lock iframe: start with `page.frame_locator("iframe").first` (tighten to `src*="search"` if needed).
- [ ] Iterate `table tbody tr` once; maintain `visited` set.
- [ ] Click **VIEW** (button/link; last-cell fallback).
- [ ] If popup: scrape there; else same-frame: require URL change or detail marker (e.g., `#longDescription`, “Description” text).
- [ ] Extract long description; merge into `mufon_working_results.json` by MUFON case ID.
- [ ] Return to results via explicit “Back/Results” control or reload `RESULTS_URL` (no `history.back()`).
- [ ] Save `trace.zip` for any failing rows.

## If Selectors Don’t Match (10 minutes)
- [ ] Run once; open `trace.zip` in Playwright trace viewer to inspect the DOM.
- [ ] Replace the iframe locator to a more specific selector (e.g., `iframe[src*='SearchResults']`).
- [ ] Replace description selectors with the actual ID/class/label seen in the detail page.

## Fallback Plan (No UI Clicks)
- [ ] Use Playwright to intercept network while clicking one **VIEW** manually; copy the detail endpoint URL pattern (caseId param).
- [ ] Call that endpoint with **httpx** using existing cookies/headers to fetch long descriptions directly (no UI).
