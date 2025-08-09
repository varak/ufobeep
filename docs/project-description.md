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

## API (Sketch)
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
- Use true coords privately; public coords jittered 100–300 m.  
- Enrichment async; progressive UI updates.  
- Cache weather & TLE; refresh periodically.  
- Keep secrets in CI or server `.env` only.  
- Prioritize accessibility (low-light contrast, text scaling).