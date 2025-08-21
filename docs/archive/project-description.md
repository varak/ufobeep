# UFOBeep — Project Description (Claude-Ready)

## Purpose
UFOBeep alerts nearby users to new sightings (UFOs, pets, missing people, unclassified). Users Beep, backend enriches (weather, celestial/satellite, HF models), pushes alerts to nearby users, chat via Matrix, and navigate with Compass/AR (including Pilot Mode).

## Architecture
- **Mobile (Flutter):** Riverpod + go_router, camera/upload, alerts feed, alert detail, chat (Matrix), compass/AR (standard + pilot), profile/i18n.
- **Web (Next.js):** Public pages (/), app info (/app), legal (/privacy,/terms,/safety), shareable alert detail with SSR read-only transcript.
- **Backend (FastAPI):** REST + enrichment worker (Redis). Media S3/MinIO. PostgreSQL. Matrix Dendrite for chat. Push via FCM/APNs.
- **CI/CD:** GitHub Actions (API Docker→VPS, Flutter build matrix, Next.js→Vercel).

## Key Flows
1) **Beep:** Camera or upload existing image → presigned upload → create sighting → move to Alert Detail.  
2) **Enrichment:** Weather (OpenWeather), celestial (Skyfield), satellites (TLE/Starlink), HF NSFW + classifier, reverse geocode, Matrix room ensure, push fanout.  
3) **Chat:** App SSO to Matrix; auto-join per-sighting room; web shows read-only transcript.  
4) **Compass:** Standard mode (bearing/distance/AR), Pilot Mode (mag/true heading, relative bearing, ETA, bank-aware overlay).


## Plane Matching (Free ADS‑B) — New
When a user captures a sky photo, the mobile client also sends UTC, GPS, compass azimuth, pitch/roll, and camera FOV.
The backend matches “is it a plane?” and, if so, the most likely flight:

- **Data source (free, non‑commercial):** OpenSky Network `/api/states/all` with OAuth2 client‑credentials; 5‑second time resolution and up to 1‑hour history for authenticated clients. Keep bbox tight to conserve credits.
- **Algorithm:** Compute device **line‑of‑sight** (bearing/elevation) from pose; fetch nearby aircraft for that time; pick the minimal angular error within a tolerance (≈2–3°); return `{is_plane, matched_flight?, confidence, why}`. No tail-number OCR required.
- **Fallback (optional):** Airplanes.live REST API (1 req/sec) if OpenSky has gaps; use only if we obtain access.
- **UX:** If a plane match is found, show a subtle “Likely plane: <callsign/type>” badge and allow the user to reclassify as “plane” instead of UFO.


## API (Sketch)
- `POST /v1/plane-match` → inputs: {utc, lat, lon, azimuth_deg, pitch_deg, roll_deg?, hfov_deg?}; output: `{is_plane, matched_flight?, confidence, why}`.
- `POST /v1/auth/register` → user/device + prefs (alerts, range, language, mode).  
- `POST /v1/upload/request` → presign PUT (content-type validated).  
- `POST /v1/sightings` → create sighting; jitter public coords; enqueue enrichment; return stub.  
- `GET /v1/alerts?lat&lng&range_km&cats` → nearby alerts w/ distance/bearing.  
- `GET /v1/alerts/{id}` → full detail + enrichment + Matrix room id (+ optional pilot fields).  

## Acceptance Criteria
- AC‑1: Sighting creates media+record + Matrix room automatically.  
- AC‑2: Nearby user gets push ≤5 s median from enrichment completion.  
- AC‑3: Chat perceived latency <200 ms (optimistic).  
- AC‑4: Flagged message hidden for non‑mods ≤2 s.  
- AC‑5: Web alert page shareable, indexed, and shows last 100 messages (consent-aware).  
- AC‑6: Pilot Mode provides vectoring (mag/true/relative bearing/ETA) and bank-aware overlay.

## Directory Layout (Monorepo)
```
app/      # Flutter (create project here with `flutter create .`)
web/      # Next.js
api/      # FastAPI (ASGI) + enrichment workers
infra/    # Nginx configs, systemd units, deploy scripts
docs/     # task.md + this file
.github/  # CI/CD workflows
```

## Notes
- **Env:** `OPENSKY_CLIENT_ID`, `OPENSKY_CLIENT_SECRET` on API server for OAuth2; small bbox (≤80 km) to stay within free quota.
- **Licensing:** OpenSky free tier is research/non‑commercial; revisit if we monetize.

- Use true coords privately; public coords jittered 100–300 m.  
- Enrichment async; progressive UI updates.  
- Cache weather & TLE; refresh periodically.  
- Keep secrets in CI or server `.env` only.  
- Prioritize accessibility (low-light contrast, text scaling).