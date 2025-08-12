# UFOBeep — Phased Task Plan (Claude-Ready)

## Phase 1: Core User Flows (IMMEDIATE)

✅ **Step 1:** Task 10 – Beep (Capture/Upload) screen  
- **COMPLETED:** Fixed beep composition UI, navigation to alert detail, “Add More Photos” feature, moved location privacy to profile  

✅ **Step 2:** Task 07 – Profile/Registration UI  
- **COMPLETED:** Profile/registration screens with location privacy settings, units selector, comprehensive user preferences  

🔄 **Step 3:** Task 21 – Upload presign endpoint  
- **NEXT:** [FASTAPI] Upload presign endpoint → PUT to S3/MinIO (app wiring)  

📋 **Step 4:** Task 27 – Push token registration  
- **TODO:** [FASTAPI][MOBILE] Push token registration & device model  

📋 **Step 5:** Task 28 – Alert fanout system  
- **TODO:** [WORKER] Alert fanout (push) + app deep link handling  

---

## Phase 2: Enhanced User Experience

📋 **Step 6:** Task 31 – Visibility logic  
- **TODO:** [MOBILE] Visibility logic (min(profile, 2×visibility) fallback 30 km) + filters  

📋 **Step 7:** Task 17 – Next.js /app page  
- **TODO:** [NEXTJS] /app page (install + permissions rationale)  

📋 **Step 8:** Task 19 – Legal pages  
- **TODO:** [NEXTJS] /privacy, /terms, /safety pages + sitemap/robots placeholders  

---

## Phase 3: Advanced Features

📋 **Step 9:** Task P1 – Pet classification in `/sightings`  
- **TODO:** [FASTAPI] Extend `POST /sightings` to accept `classification` enum (ufo, pet, other) and pet metadata fields (`pet_type`, `color_markings`, `collar_tag_info`, `status`, `cross_streets`)  

📋 **Step 10:** Task P2 – Pet SharePack trigger  
- **TODO:** [FASTAPI] Add worker job trigger: if `classification=pet`, enqueue `generate_sharepack` task  

📋 **Step 11:** Task P3 – Reverse-geocoding  
- **TODO:** [FASTAPI][WORKER] Implement reverse-geocoding (city, ZIP, cross streets) from sighting lat/lng  

📋 **Step 12:** Task P4 – SharePack generation  
- **TODO:** [FASTAPI][WORKER] Generate `SharePack` (shortlink, public URL, OG image, prefilled post text, Craigslist base URL, shelter links)  

📋 **Step 13:** Task P5 – Store & serve SharePack  
- **TODO:** [FASTAPI] Persist `SharePack` JSON with sighting; add `GET /sightings/{id}/sharepack`  

📋 **Step 14:** Task P6 – Public pet alert page  
- **TODO:** [NEXTJS] Create `/p/[slug]` public pet alert page with OG tags, map, photo, description, and share buttons  

📋 **Step 15:** Task P7 – Pet index page  
- **TODO:** [NEXTJS] Create `/pets` index (list/map of pet alerts, filters, SEO/OG)  

📋 **Step 16:** Task P8 – Pet resources page  
- **TODO:** [NEXTJS] Create `/resources/pets` page listing local shelter links by city/ZIP  

📋 **Step 17:** Task P9 – Mobile pet-share flow trigger  
- **TODO:** [MOBILE] On post-submit, if `classification=pet`, navigate to `FoundPetSharePage`  

📋 **Step 18:** Task P10 – FoundPetSharePage UI  
- **TODO:** [MOBILE] Buttons for Facebook, Nextdoor, Craigslist, PawBoost, Petco Love Lost + native share sheet  

📋 **Step 19:** Task P11 – Integrate SharePack fetch  
- **TODO:** [MOBILE] Fetch prefilled text, shortlink, image URL, and shelter links from `GET /sightings/{id}/sharepack`  

📋 **Step 20:** Task P12 – Share button behavior  
- **TODO:** [MOBILE] Copy text to clipboard, save image locally, open deep-link/browser for platform  

📋 **Step 21:** Task P13 – Shelter button link  
- **TODO:** [MOBILE] Direct link to city shelter page from SharePack  

📋 **Step 22:** Task P14 – Pet share analytics  
- **TODO:** [ALL] Track share button taps (platform, timestamp) → analytics table  

📋 **Step 23:** Task P15 – Pet flow QA  
- **TODO:** [QA] Full pet flow: create → SharePack generation → public page → app/web share → OG card verification  

📋 **Step 24:** Task 08E – OpenSky documentation  
- **TODO:** [DOCS] Add OPENSKY setup steps and `.env` keys  

📋 **Step 25:** Task 08F – Plane matching QA  
- **TODO:** [QA] Synthetic fixtures for 3 locations; verify plane vs unknown behavior  

📋 **Step 26:** Task 34 – Error handling  
- **TODO:** [ALL] Error handling + retries + offline caches  

---

## Phase 4: Production Readiness

📋 **Step 27:** Task 36 – Next.js i18n  
- **TODO:** [NEXTJS] i18n for site + localized meta/OG  

📋 **Step 28:** Task 37 – SEO optimization  
- **TODO:** [NEXTJS] SEO (sitemap, robots, canonical, OG on /alerts/[id])  

📋 **Step 29:** Task 38 – CI/CD workflows  
- **TODO:** [CI/CD] Workflows: API Docker → VPS, Flutter builds, Next.js → Vercel  

📋 **Step 30:** Task 39 – E2E testing  
- **TODO:** [QA] E2E against AC-1..AC-6 (including Pilot Mode)  

📋 **Step 31:** Task 40 – Release preparation  
- **TODO:** [RELEASE] Beta packaging (stores), website /app polish, incident runbook