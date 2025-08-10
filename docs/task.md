# UFOBeep — 40 Sequential Build Steps (Tagged for Claude)

> Feed these to Claude **one at a time** in order.

01. [DONE] [ALL] Initialize monorepo skeleton and branches  
02. [DONE] [DESIGN] Create design tokens & brand (dark-first, neon-green)  
03. [DONE] [ALL] Add .gitignore, .env.example; confirm local dirs  
04. [PARTIAL] [MOBILE] Scaffold Flutter routes (go_router) + Riverpod store  
05. [PARTIAL] [NEXTJS] Scaffold Next.js pages: /, /alerts/[id], /app, /privacy, /terms, /safety  
06. [DONE] [ALL] Environment config strategy (`API_BASE_URL`, `MATRIX_BASE_URL`, locales)  
07. [TODO] [MOBILE] Profile/Registration UI (prefs, range, language)  
08. [DONE] Splash/Startup init & locale load
08A. [DONE] [MOBILE] Capture + send sensor payload with photo (UTC, GPS, azimuth, pitch/roll, hfov).  
08B. [DONE] [FASTAPI] Implement `/v1/plane-match` (OpenSky OAuth2 client‑credentials, bbox query, LOS math, tolerance).  
08C. [PARTIAL] [MOBILE] If capture flagged as sky object, call plane‑match; render “Likely plane …” badge and allow reclassify.  
08D. [PARTIAL] [FASTAPI] Quota/rate handling: bbox ≤80 km, 5‑sec time quantization, caching for 10s; config radius/tolerance via env.  
08E. [TODO] [DOCS] Add OPENSKY setup steps and `.env` keys; note non‑commercial licensing.  
08F. [TODO] [QA] Synthetic fixtures for 3 locations; verify plane vs unknown behavior and graceful fallbacks.  
08Z. [PARTIAL] [ALL] **Backfill 1–8**: audit and complete any incomplete items; commit with tag `task-01..08-backfill`.  
09. [PARTIAL] [MOBILE] Alerts (Home) list skeleton with filters & Beep button  
10. [TODO] [MOBILE] Beep (Capture/Upload) screen with preview & submit  
11. [PARTIAL] [MOBILE] Alert Detail skeleton with enrichment placeholders  
12. [DONE] [MOBILE] Chat screen skeleton (timeline + composer)  
13. [DONE] [MOBILE] Compass — Standard mode (heading + arrow + AR overlay stub)  
14. [PARTIAL] [MOBILE] Compass — Pilot mode (mag/true heading, relative bearing, ETA stub)  
15. [DONE] [MOBILE] i18n packs EN/ES/DE and live switch  
16. [DONE] [NEXTJS] Home page content + mini map placeholder + CTA  
17. [TODO] [NEXTJS] /app page (install + permissions rationale)  
18. [PARTIAL] [NEXTJS] /alerts/[id] public detail + read-only chat area (placeholder)  
19. [TODO] [NEXTJS] /privacy, /terms, /safety pages + sitemap/robots placeholders  
20. [DONE] [FASTAPI] Finalize API contracts & shared models (Dart/TS)  
21. [TODO] [FASTAPI] Upload presign endpoint → PUT to S3/MinIO (app wiring)  
22. [PARTIAL] [FASTAPI][MOBILE] Create sighting endpoint + client wiring  
23. [PARTIAL] [FASTAPI][MOBILE] Alerts feed endpoint + app list rendering  
24. [PARTIAL] [WORKER][FASTAPI] Progressive enrichment (weather, celestial, satellites, HF)  
25. [PARTIAL] [FASTAPI][MOBILE] Matrix SSO token & auto-join per-sighting room  
26. [DONE] [NEXTJS][MATRIX] SSR read-only transcript (last 100 messages)  
27. [TODO] [FASTAPI][MOBILE] Push token registration & device model  
28. [TODO] [WORKER] Alert fanout (push) + app deep link handling  
29. [PARTIAL] [MOBILE] Compass math polish + AR overlay (standard mode)  
30. [PARTIAL] [MOBILE] Pilot mode vectoring (mag/true, relative bearing, ETA, bank overlay)  
31. [TODO] [MOBILE] Visibility logic (min(profile, 2×visibility) fallback 30 km) + filters  
32. [DONE] [T&S] Moderation badges in chat (soft-hidden/redacted)  
33. [DONE] [T&S] NSFW quarantine handling (hide public, allow reporter/mods)  
34. [TODO] [ALL] Error handling + retries + offline caches  
35. [PARTIAL] [ALL] Performance pass (lists, images, code splitting, CWV)  
36. [TODO] [NEXTJS] i18n for site + localized meta/OG  
37. [TODO] [NEXTJS] SEO (sitemap, robots, canonical, OG on /alerts/[id])  
38. [TODO] [CI/CD] Workflows: API Docker → VPS, Flutter builds, Next.js → Vercel  
39. [TODO] [QA] E2E against AC-1..AC-6 (including Pilot Mode)  
40. [TODO] [RELEASE] Beta packaging (stores), website /app polish, incident runbook
