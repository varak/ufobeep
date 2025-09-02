MUFON VIEW-Clicker Pack

Contents:
- CLAUDE.md                -> exact operator instructions (no re-auth; start at RESULTS_URL)
- MUFON_STATUS.md          -> concise status of where we are
- MUFON_TASKS.md           -> ordered checklist
- extend_mufon_details.py  -> Playwright script that reuses saved auth to click VIEW and extract long descriptions

Quick Start:
1) Edit extend_mufon_details.py and set RESULTS_URL to the exact results page that already shows your MUFON rows.
2) Ensure storage_state exists at mufon_artifacts/storage_state.json.
3) Ensure mufon_working_results.json exists (cases + media already imported).
4) Run: python extend_mufon_details.py
5) Check mufon_working_results.json for 'long_description' per case. See trace.zip if anything fails.
