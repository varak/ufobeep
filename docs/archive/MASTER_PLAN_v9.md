# UFOBeep — MASTER PLAN v9 — "LOOK AT IT RIGHT NOW" Edition

**Core Philosophy:** "Hey I see something weird in the sky and I want other people to look at it RIGHT NOW"  
**Priority:** Speed > Features. Alert first, analyze later. Beep now, chat later. Look NOW.

> **v9 Changes from v8:**
> - Reordered phases: Alert sounds/urgency FIRST
> - Anonymous beeping enabled from start
> - Emergency escalation for mass sightings
> - Simplified onboarding (no signup required)
> - Matrix chat integration for decentralized discussion
> - "I'm looking too" real-time witness counter
> - Viral sharing mechanics built-in

## Critical Success Metrics
- **Time to Beep:** ≤3 seconds from app open to alert sent
- **Alert Delivery:** ≤2 seconds to nearby devices
- **Compass Open:** ≤1 second from notification tap
- **Witness Join:** ≤5 seconds to "I see it too"
- **Battery Impact:** ≤10% for 10 min active use on low-end device

Legend: **[api]** FastAPI • **[mobile]** Flutter • **[web]** Site • **[infra]** servers/DNS/Firebase • **[ops]** release/CI • **[data]** DB  
Status markers: `[ ]` not started • `[~]` in progress • `[x]` complete • `[!]` blocked

---

## Environment & Paths (authoritative)

### Dev machine (your workstation)
- Project root: `/home/mike/D/ufobeep`
- Mobile (Flutter): `/home/mike/D/ufobeep/app`
- Web (Next.js): `/home/mike/D/ufobeep/web`
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
- Services: **systemd** → `ufobeep-api`, **PM2** → web

---

## PHASE 0 — Emergency Alert Foundation (GET BEEPING NOW)
**Goal:** Make phones beep URGENTLY when something's in the sky

1. [ ] [mobile] **URGENT SOUND SYSTEM** - Multiple alert levels with escalating sounds
   - Normal beep: single tone
   - Multiple witnesses: urgent warble
   - Mass sighting (10+): emergency siren
   - Override quiet hours for emergency level

2. [ ] [api] **Anonymous Beeping** - No signup required
   - Device ID based tracking
   - Optional registration later
   - Guest beeps fully functional

3. [ ] [mobile] **One-Tap Beep Button** - HUGE button on app open
   - No menus, no navigation
   - GPS permission request inline
   - Fallback to manual direction if GPS fails

4. [ ] [api] **Proximity Alert System** - Instant fanout
   - Geohash-based delivery
   - Distance rings: 1km, 5km, 10km, 25km
   - Priority queue for closer witnesses

**→ Breakpoint B0: BEEPING WORKS**
```bash
# Test anonymous beep
curl -X POST https://api.ufobeep.com/beep/anonymous \
  -d '{"device_id":"test123","lat":47.61,"lon":-122.33}'
# Expect: Push to all devices within 25km in ≤2s
```

---

## PHASE 1 — Instant Witness Network
**Goal:** Get multiple people looking at the same thing

5. [ ] [mobile] **"I SEE IT TOO" Button** - One tap to confirm
   - Adds witness count in real-time
   - Escalates alert priority
   - Shows bearing from witness location

6. [ ] [mobile] **Compass Arrow Overlay** - Points to sighting
   - Opens immediately on notification tap
   - Shows distance and direction
   - Updates in real-time as you move

7. [ ] [api] **Witness Aggregation** - Build consensus
   - Triangulation from multiple bearings
   - Heat map of witness locations
   - Auto-escalate when witnesses exceed threshold

8. [ ] [mobile] **Quick Share After Beep** - Viral mechanics
   - "Share to Twitter/Facebook/WhatsApp" modal
   - Pre-filled: "UFO sighting near [location]! Download UFOBeep to see where"
   - Short link: ufobeep.com/s/[ID]

**→ Breakpoint B1: WITNESS NETWORK ACTIVE**
- 3+ witnesses within 60 seconds escalates to emergency
- Share modal gets 30%+ engagement rate

---

## PHASE 2 — Media & Evidence (But Don't Block Alerts)
**Goal:** Capture evidence without slowing down alerts

9. [ ] [mobile] **Share-to-Beep** - From camera/gallery
   - Share sheet integration
   - Alert sends IMMEDIATELY
   - Media uploads in background

10. [ ] [mobile] **Quick Capture** - Built-in camera
    - Optional: tap to add photo AFTER beeping
    - Video mode for ongoing sightings
    - Auto-stabilization and enhancement

11. [ ] [api] **Media Processing Pipeline** - Async enrichment
    - EXIF extraction for time/location
    - AI object detection (runs AFTER alert)
    - Thumbnail generation for quick preview

**→ Breakpoint B2: MEDIA DOESN'T SLOW ALERTS**
- Beep sends in ≤3s even with 100MB video attached
- Background upload continues after app close

---

## PHASE 3 — Human-Readable IDs & Basic Users
**Goal:** Make sightings shareable and trackable

12. [ ] [api] **Human-Readable IDs** - UFO-2025-001234 format
    - Sequential, memorable
    - Works for URLs: ufobeep.com/UFO-2025-001234
    - QR codes for quick sharing

13. [ ] [api] **Optional User Registration** - Claim your beeps
    - Email or social login
    - Claim anonymous beeps retroactively
    - Username reservation system

14. [ ] [mobile][web] **Sighting History** - Track what you've seen
    - Personal sighting log
    - Favorite/follow sightings
    - Export to MUFON format

---

## PHASE 4 — Matrix Chat Integration (Decentralized Discussion)
**Goal:** Let witnesses discuss without central control

15. [ ] [api] **Matrix Homeserver Setup** - chat.ufobeep.com
    - Auto-create room per sighting: #UFO-2025-001234:ufobeep.com
    - Bridge UFOBeep users to Matrix accounts
    - Federation enabled for cross-server participation

16. [ ] [mobile][web] **"Join Discussion" Button** - On every sighting
    - One-tap to join Matrix room
    - No separate chat app needed
    - Embedded chat widget

17. [ ] [api] **Chat Notifications** - Configurable alerts
    - "Notify me about comments on my sighting" toggle
    - Follow/unfollow discussions
    - @mentions and replies

18. [ ] [mobile] **Chat Quick Actions** - Speed matters
    - "Still visible" / "It's gone" quick buttons
    - Location sharing for triangulation
    - Voice messages for hands-free updates

**→ Breakpoint B3: DECENTRALIZED CHAT LIVE**
- Matrix rooms auto-created for all sightings
- 50%+ of witnesses join discussion

---

## PHASE 5 — Smart Enrichment (After Alert)
**Goal:** Add context without blocking urgent alerts

19. [ ] [api] **Aircraft Checker** - ADS-B integration
    - Runs 30s AFTER alert sent
    - Shows possible aircraft matches
    - Never blocks or delays alert

20. [ ] [api] **Satellite Tracker** - TLE matching
    - Identifies possible satellites
    - ISS pass notifications
    - Starlink train detection

21. [ ] [api] **Weather/Astronomy** - Natural phenomena
    - Moon phase and position
    - Planet visibility
    - Weather balloon tracker

22. [ ] [web] **Enrichment Dashboard** - See all analyses
    - Timeline of analyses
    - Confidence scores
    - Community voting on explanations

---

## PHASE 6 — Viral Growth Features
**Goal:** Make UFOBeep spread like wildfire

23. [ ] [mobile] **Invite Rewards** - Gamification
    - "Invite 3 friends, unlock AR mode"
    - Leaderboard for most witnesses recruited
    - Badges for first responders

24. [ ] [mobile] **Quick Tile / Widget** - One-tap from home screen
    - Android Quick Settings tile
    - iOS widget with big BEEP button
    - Apple Watch / Wear OS apps

25. [ ] [web] **Public Alert Pages** - SEO optimized
    - Rich previews for social sharing
    - Live witness count
    - "Download app to join" CTA

26. [ ] [api] **MUFON Integration** - Credibility bridge
    - Export to MUFON format
    - Import MUFON reports
    - Cross-reference sightings

---

## PHASE 7 — Advanced Features (Don't Build Until Phase 6 Ships)

27. [ ] [mobile] **AR Visualization** - For capable devices
    - Optional AR overlay
    - Bearings in 3D space
    - Witness positions on map

28. [ ] [api] **Machine Learning** - Pattern detection
    - Cluster similar sightings
    - Predict hotspots
    - Classify objects

29. [ ] [mobile] **Pilot Mode** - Advanced navigation
    - Professional compass
    - Aviation charts overlay
    - ADSB integration

30. [ ] [ops] **Moderation System** - Community safety
    - Report inappropriate content
    - Temporary mutes for spam
    - Admin tools for emergency response

---

## Release Breakpoints

| Breakpoint | Goal | Success Criteria |
|---|---|---|
| **B0** | Phones beep urgently | Anonymous beep works, ≤2s delivery |
| **B1** | Witness network active | 3+ witnesses escalates, viral sharing |
| **B2** | Media doesn't block | Beep in ≤3s with media |
| **B3** | Chat discussions live | 50% join rate on Matrix rooms |
| **B4** | Enrichment adds value | 80% accuracy on aircraft |
| **B5** | Viral growth proven | 10% weekly user growth |
| **B6** | Store ready | <1% crash rate, 4.5+ rating |

---

## Critical Path Commands

### Deploy to Production (NO STAGING, PROD ONLY)
```bash
# Deploy API
ssh -p 322 ufobeep@ufobeep.com
cd /var/www/ufobeep.com/html
git pull origin main
sudo systemctl restart ufobeep-api

# Deploy Web
cd /home/ufobeep/ufobeep/web
git pull origin main
npm run build
pm2 restart ufobeep-web

# Deploy Mobile
cd /home/mike/D/ufobeep/app
flutter build apk --release
# Upload to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app 1:346511467728:android:02dcacf7017bae375caad5 \
  --groups "beta-testers"
```

### Test Alert System
```bash
# Send test beep
curl -X POST https://api.ufobeep.com/beep/test \
  -H "Content-Type: application/json" \
  -d '{"lat":47.61,"lon":-122.33,"message":"Test UFO sighting"}'

# Check delivery metrics
curl https://api.ufobeep.com/metrics/delivery-time

# Monitor real-time
ssh -p 322 ufobeep@ufobeep.com "journalctl -u ufobeep-api -f | grep ALERT"
```

### Emergency Response
```bash
# Mass sighting alert (override all preferences)
curl -X POST https://api.ufobeep.com/emergency/alert \
  -H "Authorization: Bearer $ADMIN_TOKEN" \
  -d '{"lat":47.61,"lon":-122.33,"radius_km":50,"message":"Multiple witnesses reporting large craft"}'

# Freeze chat (if needed)
curl -X POST https://api.ufobeep.com/admin/chat/freeze/UFO-2025-001234 \
  -H "Authorization: Bearer $ADMIN_TOKEN"
```

---

## Success Metrics

### User Acquisition
- **Day 1:** 100 downloads
- **Week 1:** 1,000 downloads  
- **Month 1:** 10,000 active devices
- **Month 3:** 100,000 active devices

### Engagement
- **Time to First Beep:** <30 seconds from install
- **Witness Join Rate:** >30% of alerted users
- **Chat Participation:** >50% read, >10% post
- **Daily Active:** >20% of installs

### Technical
- **Alert Latency p99:** <2 seconds
- **Crash-Free Rate:** >99.5%
- **Battery Drain:** <10% per 10 min active
- **API Uptime:** >99.9%

---

## What's Different in v9?

1. **BEEP FIRST** - Everything else is secondary
2. **NO BARRIERS** - Anonymous usage, no signup required
3. **URGENT SOUNDS** - Multiple levels, override quiet hours for emergencies
4. **VIRAL BUILT-IN** - Share mechanics from day one
5. **MATRIX CHAT** - Decentralized, federated, unstoppable
6. **ENRICHMENT AFTER** - Analyses never block alerts
7. **SPEED METRICS** - Every phase measured in seconds

This plan is optimized for one thing: **Getting people to look at something weird in the sky RIGHT NOW**. Everything else is gravy.

---

## Missing from Previous Plans (Now Added)

### Onboarding Flow
1. App opens to BIG BEEP BUTTON (no signup)
2. First beep asks for location permission inline
3. After beep: "Want to claim this sighting?" (optional signup)
4. Tutorial only if user wants it (not forced)

### Emergency Escalation
- 3 witnesses = urgent tone
- 10 witnesses = emergency siren
- 50 witnesses = regional alert
- 100+ witnesses = media notification system

### Fallback Systems
- GPS fails? Manual direction input
- No internet? Queue and send when connected
- Server down? P2P backup via nearby devices
- Chat offline? SMS fallback for urgent updates

### Growth Hacks
- "First to report" badge
- Witness streaks (report 5 days in a row)
- Location leaderboards
- Referral rewards
- Media exclusive partnerships

Remember: **If it doesn't help people look at something RIGHT NOW, it can wait.**