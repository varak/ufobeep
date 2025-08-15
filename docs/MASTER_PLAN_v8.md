# UFOBeep — MASTER PLAN (Tagged + Breakpoints + Runbooks) — v6

> **Battery & Low-End Device Policy (v8 update)**  
> All features must consider battery impact and run acceptably on low-end devices without ARCore/ARKit.  
> - 10 min active use ≤10% battery drain on low-end device.  
> - Fallback UI for devices without required sensors/hardware.  
> - Adaptive update rates for sensors (compass, GPS).  
> - Camera preview auto-disables after inactivity.  
> - High-priority push only for Beep alerts; other pushes batched.  
> - "Low-Power Mode" toggle in settings: reduces polling, suspends AR, limits chat refresh.  

**Scope:** Beep‑first, Share‑to‑Beep, real push, compass overlay, live chat.  
**Audience:** You + Claude + any contributor. This is the _live_ plan; keep status boxes updated.

Legend: **[api]** FastAPI • **[mobile]** Flutter • **[web]** Site • **[infra]** servers/DNS/Firebase • **[ops]** release/CI • **[data]** DB  
Status markers: `[ ]` not started • `[~]` in progress • `[x]` complete • `[!]` blocked

---

## Environment & Paths (authoritative)

### Dev machine (your workstation)
- Project root: `/home/mike/D/ufobeep`
- Mobile (Flutter): `/home/mike/D/ufobeep/app`
- Web (Next.js/PWA companion): `/home/mike/D/ufobeep/web` (historical PWA lives under `/home/mike/D/ufobeep/www` if needed)
- API (dev clone): `/home/mike/D/ufobeep/api`
- Single dotenv: `/home/mike/D/ufobeep/.env`
- Downloads (assets/APKs): `/home/mike/Downloads`

### Production server
- SSH: `ssh -p 322 ufobeep@ufobeep.com`
- API base: `https://api.ufobeep.com`
- API code (prod): `/var/www/ufobeep.com/html`
- Media storage: `/home/ufobeep/ufobeep/media`
- Web app (PM2-managed): `/home/ufobeep/ufobeep/web`
- Nginx: hosts `ufobeep.com` + `api.ufobeep.com`
- Services: **systemd** → `ufobeep-api` (and optional blue/green units), **PM2** → web

> These are baked into all commands below. Do not drift.

---

## Release Breakpoints (push‑beta gates)

Each **Breakpoint (B#)** is a Go/No‑Go gate for tagging, distributing a beta, and/or touching production. Never skip a breakpoint.

| Breakpoint | What we ship | Must‑pass checks | Tracks |
|---|---|---|---|
| **B0 — Foundation** | CI, env layout, migrations skeleton | `staging` remote up; rollback tested | tag `v6.0.0-foundation` |
| **B1 — Beep MVP** | Beep → push → open alert shell | 2 Android test devices receive push ≤4s LTE; crash‑free >99% | internal sideload |
| **B2 — Share‑to‑Beep** | Share sheet → compose → Beep now; media streams in | Share from Photos works; background upload continues | Firebase App Dist / Play Internal |
| **B3 — Compass + Chat Hook** | Compass overlay + “Join Chat” | Bearing updates <1s; deep‑link chat resolve OK | internal |
| **B4 — Profile Parity** | Full prefs sync (radius, quiet hours, sound) | Mobile↔API round‑trip ≤15s; device Test Push OK | beta |
| **B5 — Moderation + Analyzers** | NSFW media strip only; aircraft/sat/planet checks visible | Rules toggle works; admin restore/removal works | beta |
| **B6 — Store Prep** | Store assets, privacy pages, signed builds | Lints pass; CI signs AAB/APK | RC |

Task cross‑refs: see brackets like **(AT#14‑16,33‑36)** to map into *ufobeep_actionTasks.com.pdf*.

---

## Phase 0 — Repo, Branching, Secrets, Environments
1. [ops] Git model: `main`=prod, `develop`=staging, `feature/*`=work. Protect `main` and `develop`.  
2. [ops] Secrets: add `.env.example` and document secrets in `/home/mike/D/ufobeep/.env`; mirror to CI. **Never commit secrets**.  
3. [infra] Remotes: staging & prod for API/web; health endpoints live.  
4. [ops] CI stubs: build APK (debug/release), run `flutter test`, build FastAPI image/wheel, run unit tests.

**→ Breakpoint B0**  
**Tag:** `v6.0.0-foundation`  
```bash
cd /home/mike/D/ufobeep && git checkout -b feature/ops-foundation
# add CI files, .env.example, docs
git commit -am "ops: CI + env scaffolding + docs"
git checkout develop && git merge --no-ff feature/ops-foundation
git tag v6.0.0-foundation && git push && git push --tags
```

---

## Phase 1 — Data & IDs  (AT#31–36, 32)
5. [api][data] Sighting IDs: `UFO-YYYY-NNNNNN`; schema for users, sightings, devices, prefs.  
6. [api] Alembic migration scaffolding + backup/rollback scripts.

**Server Mgmt — Staging DB migrate**  
```bash
# on prod host but targeting STAGING DB (or run on staging host)
pg_dump -Fc -f /var/backups/ufobeep_staging_$(date +%F).dump "$STAGING_DB_URL"
alembic upgrade head
# verify; rollback example:
# alembic downgrade -1
```

---

## Phase 2 — Devices & Push  (AT#21–27, 32–33)
7. [api][mobile] FCM device token endpoints + persist device metadata (OS/model/app build).  
8. [mobile] Android notification channels, custom sound/vibration, background handlers.

**Internal sideload smoke**  
```bash
cd /home/mike/D/ufobeep/app
flutter clean && flutter pub get
flutter build apk --debug
adb install -r build/app/outputs/flutter-apk/app-debug.apk
```

---

## Phase 3 — Beep MVP (E2E)  (AT#14–16, 33–36)
9. [mobile] Beep now (one‑tap) with instant coarse location; media optional later.  
10. [api] Proximity fanout → FCM payloads + deep links; retries/logging.  
11. [mobile] Compass overlay on alert; arrow updates by heading.  
12. [api][mobile] Alert history, mute/test, quiet hours (client + server).

**→ Breakpoint B1** — E2E Beep on staging  
```bash
# test fanout
curl -X POST https://staging.api.ufobeep.com/beeps/test \
  -H "Authorization: Bearer STAGING_ADMIN" \
  -H "Content-Type: application/json" \
  -d '{"lat":47.61,"lon":-122.33,"radius_km":20}'
# Expect push in ≤2–4s; deep link opens compass
```

---

## Phase 4 — Share‑to‑Beep (Speed First)  (AT#18–19, 35–36)
13. [mobile] Android Share Sheet receiver: `ACTION_SEND` / `ACTION_SEND_MULTIPLE` (`image/*`,`video/*`), persistable URI perms; route to `ufobeep://beep/compose?fromShare=true`.  
14. [mobile] **Streaming attach**: Beep sends instantly; uploads continue in background; progress chips per media.  
15. [api] `POST /media/preupload` → temp IDs/presigned URLs; `POST /beeps/create` returns `public_id`; `POST /sightings/{id}/media/add` attaches as they finish.

**→ Breakpoint B2** — Distribute beta  
```bash
cd /home/mike/D/ufobeep/app
flutter build apk --release
# Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app <FIREBASE_ANDROID_APP_ID> \
  --groups "internal" \
  --release-notes "$(git describe --tags --always) share-to-beep"
# or: build AAB and upload to Play Internal Testing
flutter build appbundle --release
```

---

## Phase 5 — Speed & Reliability Boosters
16. [mobile] Quick actions: Android QS tile + long‑press “Beep now”.  
17. [mobile] Background prewarm (reuse for 10–15s after close).  
18. [api][infra] Geo‑topic fanout (geohash subscriptions).  
19. [ops] Telemetry: delivery/open latency; per‑sighting stats.

**Server Mgmt — API blue/green rollout (prod)**  
```bash
# as ufobeep@ufobeep.com (port 322)
ssh -p 322 ufobeep@ufobeep.com
sudo systemctl start ufobeep-api@green
curl -fsS https://api.ufobeep.com/health || exit 1
# flip symlink if healthy
sudo ln -sfn /etc/systemd/system/ufobeep-api@green.service /etc/systemd/system/ufobeep-api.service
sudo systemctl daemon-reload && sudo systemctl restart ufobeep-api
sudo nginx -t && sudo systemctl reload nginx
# rollback: point symlink back to @blue, restart, reload
```

---

## Phase 6 — Profile Parity & Device Controls  (AT#20–21, 25–29, 31–32, 34)
20. [api][data] Profile schema: alert/chat prefs, radius presets, quiet hours, **sound profiles**.  
21. [api] Profile read/update + per‑device overrides.  
22. [mobile][web] Full profile UI; device list with **Test notification**.  
23. [web][mobile] Import/Export settings JSON.

**→ Breakpoint B4** — Settings parity beta  
```bash
git tag v6.2.0-profiles-beta && git push --tags
# Distribute via App Dist / Play Internal
```

---

## Phase 7 — Chat & Co‑Witness (Practical)
24. [api][web][mobile] Follow chat (All/Mentions/Joins); push for mentions.  
25. [api] `@mention` resolver; minimal search by `public_id`.  
26. [mobile][web] **Co‑witness “I see it too”**; bearings aggregation (circular mean) indicator.

**Field Beta (5–20 users)**  
Scripted outdoor test with 3 beeps; verify bearings ring convergence <1s.

---

## Phase 8 — Moderation & Safety (Beep‑First)
27. [mod][api] Moderation schema (flags, reasons, appeals, banlists).  
28. [mod] Rules: **only** hard‑block extreme explicit media; the alert itself always stands.  
29. [web] Admin drawer: remove/restore media, temp/perma bans, freeze chat.  
30. [ops] Appeals workflow + audit trail.

**→ Breakpoint B5** — Moderation toggles live  
Feature flags in `.env`:
```
MOD_ENABLE_NSFW=1
MOD_HARD_BLOCK_THRESHOLD=0.98
```

---

## Phase 9 — Pluggable Analyzers (Free‑first)
31. [analyzers][api] Framework → `sighting_analyses` table (provider, status, result JSON).  
32. [analyzers] Aircraft: ADS‑B Exchange WS (free) with OpenSky fallback.  
33. [analyzers] Satellites: local TLE match; optional N2YO key.  
34. [analyzers] Moon/planets: local ephemeris; moon phase, alt/az.  
35. [web] Analyses panel (provider toggles in Admin).

**→ Breakpoint B5 (continued)** — Analyzers ON (staging 48h) then prod green/blue.

---


## Phase 9B — External Sharing & MUFON Integration

- **[mobile][api][web]** After Beep submit, show **Share this sighting** modal:
  - Pre-generated share text with short link to the alert on ufobeep.com (SEO-friendly).
  - Buttons for **X (Twitter)**, **Facebook**, **Telegram**, **Reddit**, **Copy Link**.
- **[mobile]** MUFON Report prompt:
  - Open MUFON mobile site with description/media preloaded if possible.
  - "Later" option queues a reminder in-app until dismissed or sent.
- **[api][web]** Public alert pages: add Open Graph & Twitter Card tags, event schema.
- **[ops][seo]** Ensure all public alert detail pages are crawlable/indexable with canonical URLs.

**→ Breakpoint B7 — External Share Ready**
- Share modal appears after Beep send.
- Links open external platforms with correct pre-filled message/media previe
## Phase 9C — Optional AR Visualization & Bearings Aggregation

- **[mobile]** Lightweight AR overlay (compass + camera) as default:  
  - Compass update ~5–10 Hz unless actively aiming.  
  - Camera preview auto-off after 30s inactivity.  
- **[mobile]** Full AR tracking (ARCore/ARKit) available as opt-in in settings.  
- **[api]** Bearings aggregation (circular mean) shown in AR mode if enabled.  
- **[ops]** Battery benchmark part of Breakpoint acceptance.

**→ Breakpoint B8 — AR Mode Ready**
- Works on ARCore/ARKit and has fallback for non-supported devices.  
- Battery drain on low-end device: ≤10% for 10 min AR Lite; ≤15% for full AR.  
- Bearings and witness markers display accurately in AR.

---
w.
- MUFON prompt appears; later/reminder flow works.
- Public page passes Facebook Debugger & Twitter Card Validator.

**SEO Checklist:**
1. Web (Next.js) — Add `<meta property="og:image">` for first sighting image.
2. Add `<meta name="twitter:card" content="summary_large_image">`.
3. Add JSON-LD structured data for `"@type": "Event"` with location, date, description.
4. Use short, keyword-rich titles: `UFO Sighting — {City}, {Date} | UFOBeep`.
5. Auto-generate short public link: `ufobeep.com/a/{alert_id}`.
6. Link MUFON from public alert pages.

---
## Phase 10 — E2E Hardening & Store Prep  (AT#37–40)
36. [ops] Scripted E2E runbooks: Beep → push → open → compass → chat → upload (repeatable).  
37. [ops] Privacy Policy, screenshots, feature graphic, custom sounds under `/home/mike/Downloads`.  
38. [ops] Play Console tracks: Internal → Closed → Open testing wired to CI.  
39. [ops] Crash/ANR: Firebase Crashlytics; minimal custom telemetry.

**→ Breakpoint B6 — Release Candidate**  
```bash
cd /home/mike/D/ufobeep/app
flutter build appbundle --release
# Upload AAB to Play Console Internal Testing
git tag v6.4.0-rc1 && git push --tags
```

---

## Ops Runbooks

### API (prod) — systemd
```bash
# health
curl -fsS https://api.ufobeep.com/health || exit 1

# logs
journalctl -u ufobeep-api -n 200 -f

# restart
sudo systemctl restart ufobeep-api
sudo systemctl status ufobeep-api --no-pager
```

### Web (prod) — PM2
```bash
# list
pm2 ls

# restart web (name your process 'ufobeep-web')
pm2 restart ufobeep-web

# logs
pm2 logs ufobeep-web --lines 200
```

### Nginx (prod)
```bash
sudo nginx -t && sudo systemctl reload nginx
sudo tail -n 200 /var/log/nginx/access.log
sudo tail -n 200 /var/log/nginx/error.log
```

### Backups & Rollback
```bash
# DB backup
pg_dump -Fc -f /var/backups/ufobeep_prod_$(date +%F).dump "$PROD_DB_URL"

# App rollback by tag
cd /var/www/ufobeep.com/html
git fetch --tags
git checkout tags/v6.3.0-analyzers-beta
sudo systemctl restart ufobeep-api
```

---

## Acceptance Gates (must‑pass)

- **B1 (E2E Beep):** push ≤2–4s; deep link opens compass & chat; retries logged.
- **B2 (Share‑to‑Beep):** share 20–60s video → Beep sends instantly; media attaches while chat is live.
- **B4 (Settings):** profile sync mobile↔web ≤15s; device “Test notification” works.
- **Field beta:** ≥3 witnesses tap *I see it too*; bearings ring converges <1s.
- **B5 (Moderation/Analyzers):** aircraft/sat/planet checks ≤2–5s; provider fallback OK.
- **B6 (RC):** Crash‑free users ≥99.5% over 24–72h; no P0/P1 open.

---

## Cross‑Reference: Action Tasks (AT)
- **AT#14–16,33–36** → Beep MVP & alert flow (Phases 3–4)
- **AT#18–19** → Camera/gallery & uploads (Phase 4)
- **AT#20–21,25–29,31–32,34** → Styling, Firebase, messaging, geolocator, compass, device reg (Phases 2,6)
- **AT#37–40** → Builds, store assets, submissions (Phase 10)

---

## Notes & Policy
- Web/PWA is companion only; real‑time network effect is **native app**.  
- Always halt at a Breakpoint if any must‑pass check fails; fix or roll back.  
- Keep this file as the **single source of truth**; update statuses inline.
