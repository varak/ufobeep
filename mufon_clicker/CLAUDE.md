# MUFON VIEW-Click Extension — Read Me First (for Claude)

## Do NOT Re-Auth
- Reuse the existing session: `storage_state="mufon_artifacts/storage_state.json"`
- Start **directly** at the already-working results page (`RESULTS_URL`). Do NOT click “SEARCH DATABASE” or rebuild the login flow.

## What to Do Now
1) Open `extend_mufon_details.py` (in this same folder) and set:
   - `RESULTS_URL` → paste the exact URL that shows the 3 (or 11) rows you already pulled
   - `STORAGE_STATE="mufon_artifacts/storage_state.json"`
   - `JSON_PATH="mufon_working_results.json"` (existing file with cases + media)
2) Run it: `python extend_mufon_details.py`
3) The script will:
   - Load the results page **with** saved auth
   - Lock onto the table iframe deterministically (`page.frame_locator("iframe")` → tighten if needed)
   - Iterate one pass over `table tbody tr`
   - Click **VIEW** via role-based button/link OR last-cell button
   - Handle either popup OR same-frame navigation
   - Extract the **long description** using resilient selectors (`#longDescription`, `.description`, label+following-sibling, or largest paragraph fallback)
   - Merge the text back into `mufon_working_results.json` keyed by MUFON case ID
   - Save `trace.zip` for debugging

## Anti-Loop Rules
- One strict pass with a `visited` set (case_id/row index); no retries on the same row.
- Consider navigation “successful” only if (A) frame URL changes OR (B) a known detail marker appears.
- Never `history.back()`. Prefer a “Back/Results” control; otherwise reload `RESULTS_URL` (idempotent) and continue.
- Hard timeouts everywhere (2–8s). If it doesn’t navigate, **skip** and move on.

## What You May Need to Tweak
- `frame_locator("iframe")` → if there are multiple iframes, target by `src*="search"` / `src*="results"`.
- The detail selectors for long description—swap in the exact ID/class/label observed on the detail page.

## Deliverables
- Updated `mufon_working_results.json` with `long_description` per case
- `trace.zip` for any failure analysis
