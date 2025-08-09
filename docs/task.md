# UFOBeep — 40 Sequential Build Steps (Tagged for Claude)

> Feed these to Claude **one at a time** in order.

01. [ALL] Initialize monorepo skeleton and branches  
02. [DESIGN] Create design tokens & brand (dark-first, neon-green)  
03. [ALL] Add .gitignore, .env.example; confirm local dirs  
04. [MOBILE] Scaffold Flutter routes (go_router) + Riverpod store  
05. [NEXTJS] Scaffold Next.js pages: /, /alerts/[id], /app, /privacy, /terms, /safety  
06. [ALL] Environment config strategy (`API_BASE_URL`, `MATRIX_BASE_URL`, locales)  
07. [MOBILE] Profile/Registration UI (prefs, range, language)  
08. [MOBILE] Splash/Startup init & locale load  
09. [MOBILE] Alerts (Home) list skeleton with filters & Beep button  
10. [MOBILE] Beep (Capture/Upload) screen with preview & submit  
11. [MOBILE] Alert Detail skeleton with enrichment placeholders  
12. [MOBILE] Chat screen skeleton (timeline + composer)  
13. [MOBILE] Compass — Standard mode (heading + arrow + AR overlay stub)  
14. [MOBILE] Compass — Pilot mode (mag/true heading, relative bearing, ETA stub)  
15. [MOBILE] i18n packs EN/ES/DE and live switch  
16. [NEXTJS] Home page content + mini map placeholder + CTA  
17. [NEXTJS] /app page (install + permissions rationale)  
18. [NEXTJS] /alerts/[id] public detail + read-only chat area (placeholder)  
19. [NEXTJS] /privacy, /terms, /safety pages + sitemap/robots placeholders  
20. [FASTAPI] Finalize API contracts & shared models (Dart/TS)  
21. [FASTAPI] Upload presign endpoint → PUT to S3/MinIO (app wiring)  
22. [FASTAPI][MOBILE] Create sighting endpoint + client wiring  
23. [FASTAPI][MOBILE] Alerts feed endpoint + app list rendering  
24. [WORKER][FASTAPI] Progressive enrichment (weather, celestial, satellites, HF)  
25. [FASTAPI][MOBILE] Matrix SSO token & auto-join per-sighting room  
26. [NEXTJS][MATRIX] SSR read-only transcript (last 100 messages)  
27. [FASTAPI][MOBILE] Push token registration & device model  
28. [WORKER] Alert fanout (push) + app deep link handling  
29. [MOBILE] Compass math polish + AR overlay (standard mode)  
30. [MOBILE] Pilot mode vectoring (mag/true, relative bearing, ETA, bank overlay)  
31. [MOBILE] Visibility logic (min(profile, 2×visibility) fallback 30 km) + filters  
32. [T&S] Moderation badges in chat (soft-hidden/redacted)  
33. [T&S] NSFW quarantine handling (hide public, allow reporter/mods)  
34. [ALL] Error handling + retries + offline caches  
35. [ALL] Performance pass (lists, images, code splitting, CWV)  
36. [NEXTJS] i18n for site + localized meta/OG  
37. [NEXTJS] SEO (sitemap, robots, canonical, OG on /alerts/[id])  
38. [CI/CD] Workflows: API Docker → VPS, Flutter builds, Next.js → Vercel  
39. [QA] E2E against AC-1..AC-6 (including Pilot Mode)  
40. [RELEASE] Beta packaging (stores), website /app polish, incident runbook