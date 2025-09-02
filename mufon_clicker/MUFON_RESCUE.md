# MUFON Rescue Pack — From Login → Search → VIEW Click

## Why this exists
Your working code got lost and the flow drifted. This pack restores a **two‑phase** flow:

- **Phase A — `login_and_search.py`:** 
  - Login (with `.env` creds), accept Terms & Conditions, navigate to **Database Search**, perform a default search.
  - Auto-detect the **results iframe** that displays the case rows.
  - Save artifacts to `mufon_artifacts/`:
    - `storage_state.json` (fresh session)
    - `results_url.txt` (the iframe `src` URL on `https://mufoncms.com/...`)
    - `results_frame.html` (HTML snapshot of the results frame)
    - `trace_login.zip` (trace for debugging)

- **Phase B — `extend_mufon_details.py`:**
  - Reuse `storage_state.json` + `results_url.txt`
  - Load results URL, iterate each row, click **VIEW**, extract **long description**.
  - Merge into `mufon_working_results.json` keyed by MUFON case ID.
  - Save `trace_click.zip`
