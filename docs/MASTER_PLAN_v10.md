# UFOBeep — MASTER PLAN v10 — "LOOK AT IT RIGHT NOW" Edition

**Core Philosophy:** "Hey I see something weird in the sky and I want other people to look at it RIGHT NOW"  
**Priority:** Speed > Features. Alert first, analyze later. Beep now, chat later. Look NOW.

> **v10 Changes from v9:**
> - Added alert preferences and quiet mode features (Phase 1.5)
> - Visual task completion indicators (🔴🟡🟢⚪)
> - Better organization of user preference features
> - Anti-spam protection for beta testing
> - Snooze and filter options for alert management
> - Emergency override system for mass sightings

## Critical Success Metrics
- **Time to Beep:** ≤3 seconds from app open to alert sent
- **Alert Delivery:** ≤2 seconds to nearby devices
- **Compass Open:** ≤1 second from notification tap
- **Witness Join:** ≤5 seconds to "I see it too"
- **Battery Impact:** ≤10% for 10 min active use on low-end device
- **Alert Spam Prevention:** No more than 3 alerts per user per 15 minutes

## Task Status Legend
- 🔴 **Not Started** - Task not yet begun
- 🟡 **In Progress** - Currently being worked on
- 🟢 **Complete** - Task finished and deployed
- ⚪ **Blocked** - Waiting on dependencies or external factors

Legend: **[api]** FastAPI • **[mobile]** Flutter • **[web]** Site • **[infra]** servers/DNS/Firebase • **[ops]** release/CI • **[data]** DB  

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

### Core Alert System
1. 🟡 **[mobile] URGENT SOUND SYSTEM** - Multiple alert levels with escalating sounds
   - Normal beep: single tone
   - Multiple witnesses: urgent warble
   - Mass sighting (10+): emergency siren
   - Override quiet hours for emergency level
   - Rate limiting protection (max 3 alerts per 15 min)

2. 🟢 **[api] Anonymous Beeping** - No signup required
   - Device ID based tracking
   - Optional registration later
   - Guest beeps fully functional

3. 🟡 **[mobile] One-Tap Beep Button** - HUGE button on app open
   - No menus, no navigation
   - GPS permission request inline
   - Fallback to manual direction if GPS fails

4. 🟡 **[api] Proximity Alert System** - Instant fanout
   - Geohash-based delivery
   - Distance rings: 1km, 5km, 10km, 25km
   - Priority queue for closer witnesses
   - Rate limiting: skip alerts if 3+ sightings in 15 minutes

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

### Witness Coordination
5. 🔴 **[mobile] "I SEE IT TOO" Button** - One tap to confirm
   - Adds witness count in real-time
   - Escalates alert priority
   - Shows bearing from witness location

6. 🔴 **[mobile] Compass Arrow Overlay** - Points to sighting
   - Opens immediately on notification tap
   - Shows distance and direction
   - Updates in real-time as you move

7. 🔴 **[api] Witness Aggregation** - Build consensus
   - Triangulation from multiple bearings
   - Heat map of witness locations
   - Auto-escalate when witnesses exceed threshold

### Viral Mechanics
8. 🔴 **[mobile] Quick Share After Beep** - Viral mechanics
   - "Share to Twitter/Facebook/WhatsApp" modal
   - Pre-filled: "UFO sighting near [location]! Download UFOBeep to see where"
   - Short link: ufobeep.com/s/[ID]

**→ Breakpoint B1: WITNESS NETWORK ACTIVE**
- 3+ witnesses within 60 seconds escalates to emergency
- Share modal gets 30%+ engagement rate

---

## PHASE 1.5 — Alert Preferences & Quiet Mode (NEW)
**Goal:** Give users control over alert frequency without breaking emergency response

### Alert Filtering & Controls
9. 🔴 **[mobile] Alert Preferences Screen** - Fine-grained control
   - "Ignore anonymous beeps" toggle (only get alerts with photos/detailed reports)
   - "Media-only alerts" toggle (only alerts with attached photos/videos)
   - Distance filter slider (1km - 100km range)
   - Quality threshold (minimum witness count before alert)

10. 🔴 **[mobile] Quiet Mode & Snooze Options** - Temporary muting
    - "Snooze alerts for 1 hour" quick action
    - "Snooze alerts for 8 hours" (overnight mode)
    - "Snooze alerts for 24 hours" (full day off)
    - "Emergency only mode" (3+ witnesses required)
    - Do Not Disturb integration (respect system quiet hours)

11. 🔴 **[api] Smart Alert Throttling** - Prevent spam without blocking emergency
    - Per-user rate limiting (configurable in preferences)
    - Emergency override: mass sightings (10+ witnesses) bypass all filters
    - Quality scoring: prioritize alerts with media, multiple witnesses
    - Geographic clustering: group nearby similar alerts

### User Experience Enhancements
12. 🔴 **[mobile] Alert Preview & Dismiss** - Better notification control
    - Rich notification preview with distance/witness count
    - "Dismiss and snooze similar" option
    - "Mark as not interesting" to improve future filtering
    - Quick "I see it too" action from notification

**→ Breakpoint B1.5: ALERT FATIGUE SOLVED**
- Users can customize alert frequency without missing emergencies
- Beta testers report manageable notification levels
- Emergency alerts still override all preferences

---

## PHASE 2 — Media & Evidence (But Don't Block Alerts)
**Goal:** Capture evidence without slowing down alerts

### Media Capture
13. 🔴 **[mobile] Share-to-Beep** - From camera/gallery
    - Share sheet integration
    - Alert sends IMMEDIATELY
    - Media uploads in background

14. 🔴 **[mobile] Quick Capture** - Built-in camera
    - Optional: tap to add photo AFTER beeping
    - Video mode for ongoing sightings
    - Auto-stabilization and enhancement

### Processing Pipeline
15. 🔴 **[api] Media Processing Pipeline** - Async enrichment
    - EXIF extraction for time/location
    - AI object detection (runs AFTER alert)
    - Thumbnail generation for quick preview

**→ Breakpoint B2: MEDIA DOESN'T SLOW ALERTS**
- Beep sends in ≤3s even with 100MB video attached
- Background upload continues after app close

---

## PHASE 3 — Human-Readable IDs & Enhanced Users
**Goal:** Make sightings shareable and trackable with personalized preferences

### Identity & Tracking
16. 🔴 **[api] Human-Readable IDs** - UFO-2025-001234 format
    - Sequential, memorable
    - Works for URLs: ufobeep.com/UFO-2025-001234
    - QR codes for quick sharing

17. 🔴 **[api] Enhanced User Registration** - Claim your beeps with preferences
    - Email or social login
    - Claim anonymous beeps retroactively
    - Username reservation system
    - Import alert preferences from device settings

### Personal History & Advanced Preferences
18. 🔴 **[mobile][web] Sighting History** - Track what you've seen
    - Personal sighting log
    - Favorite/follow sightings
    - Export to MUFON format
    - Alert history and statistics

19. 🔴 **[mobile] Advanced Alert Preferences** - Power user controls
    - Custom notification sounds per alert type
    - Time-based preferences (work hours vs evenings)
    - Location-based rules (home, work, travel zones)
    - Integration with calendar (mute during meetings)
    - Friend/follower alerts (higher priority for trusted users)

**→ Breakpoint B3: PERSONALIZED EXPERIENCE**
- Users can fine-tune preferences for optimal experience
- Registered users have better alert targeting
- History tracking improves future recommendations

---

## PHASE 4 — Matrix Chat Integration (Decentralized Discussion)
**Goal:** Let witnesses discuss without central control

### Chat Infrastructure
20. 🔴 **[api] Matrix Homeserver Setup** - chat.ufobeep.com
    - Auto-create room per sighting: #UFO-2025-001234:ufobeep.com
    - Bridge UFOBeep users to Matrix accounts
    - Federation enabled for cross-server participation

21. 🔴 **[mobile][web] "Join Discussion" Button** - On every sighting
    - One-tap to join Matrix room
    - No separate chat app needed
    - Embedded chat widget

### Chat Features
22. 🔴 **[api] Chat Notifications** - Configurable alerts
    - "Notify me about comments on my sighting" toggle
    - Follow/unfollow discussions
    - @mentions and replies
    - Integration with main alert preferences

23. 🔴 **[mobile] Chat Quick Actions** - Speed matters
    - "Still visible" / "It's gone" quick buttons
    - Location sharing for triangulation
    - Voice messages for hands-free updates

**→ Breakpoint B4: DECENTRALIZED CHAT LIVE**
- Matrix rooms auto-created for all sightings
- 50%+ of witnesses join discussion
- Chat notifications respect user preferences

---

## PHASE 5 — Smart Enrichment (After Alert)
**Goal:** Add context without blocking urgent alerts

### Analysis Pipeline
24. 🔴 **[api] Aircraft Checker** - ADS-B integration
    - Runs 30s AFTER alert sent
    - Shows possible aircraft matches
    - Never blocks or delays alert

25. 🔴 **[api] Satellite Tracker** - TLE matching
    - Identifies possible satellites
    - ISS pass notifications
    - Starlink train detection

26. 🔴 **[api] Weather/Astronomy** - Natural phenomena
    - Moon phase and position
    - Planet visibility
    - Weather balloon tracker

### Enrichment Display
27. 🔴 **[web] Enrichment Dashboard** - See all analyses
    - Timeline of analyses
    - Confidence scores
    - Community voting on explanations

**→ Breakpoint B5: ENRICHMENT ADDS VALUE**
- 80% accuracy on aircraft identification
- Analyses help explain conventional phenomena

---

## PHASE 6 — Viral Growth Features
**Goal:** Make UFOBeep spread like wildfire

### Gamification
28. 🔴 **[mobile] Invite Rewards** - Gamification
    - "Invite 3 friends, unlock AR mode"
    - Leaderboard for most witnesses recruited
    - Badges for first responders

29. 🔴 **[mobile] Quick Tile / Widget** - One-tap from home screen
    - Android Quick Settings tile
    - iOS widget with big BEEP button
    - Apple Watch / Wear OS apps

### Public Engagement
30. 🔴 **[web] Public Alert Pages** - SEO optimized
    - Rich previews for social sharing
    - Live witness count
    - "Download app to join" CTA

31. 🔴 **[api] MUFON Integration** - Credibility bridge
    - Export to MUFON format
    - Import MUFON reports
    - Cross-reference sightings

**→ Breakpoint B6: VIRAL GROWTH PROVEN**
- 10% weekly user growth
- Social sharing drives 30%+ of new installs

---

## PHASE 7 — Advanced Features (Don't Build Until Phase 6 Ships)

### Advanced Visualization
32. 🔴 **[mobile] AR Visualization** - For capable devices
    - Optional AR overlay
    - Bearings in 3D space
    - Witness positions on map

33. 🔴 **[api] Machine Learning** - Pattern detection
    - Cluster similar sightings
    - Predict hotspots
    - Classify objects

### Professional Features
34. 🔴 **[mobile] Pilot Mode** - Advanced navigation
    - Professional compass
    - Aviation charts overlay
    - ADSB integration

35. 🔴 **[ops] Moderation System** - Community safety
    - Report inappropriate content
    - Temporary mutes for spam
    - Admin tools for emergency response

**→ Breakpoint B7: STORE READY**
- <1% crash rate, 4.5+ rating
- Professional features for aviation community

---

## Release Breakpoints

| Breakpoint | Goal | Success Criteria |
|---|---|---|
| **B0** | Phones beep urgently | Anonymous beep works, ≤2s delivery |
| **B1** | Witness network active | 3+ witnesses escalates, viral sharing |
| **B1.5** | Alert fatigue solved | Users control frequency, emergency override works |
| **B2** | Media doesn't block | Beep in ≤3s with media |
| **B3** | Personalized experience | Advanced preferences, history tracking |
| **B4** | Chat discussions live | 50% join rate on Matrix rooms |
| **B5** | Enrichment adds value | 80% accuracy on aircraft |
| **B6** | Viral growth proven | 10% weekly user growth |
| **B7** | Store ready | <1% crash rate, 4.5+ rating |

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
- **Alert Satisfaction:** <5% users enable "emergency only" mode

### Technical
- **Alert Latency p99:** <2 seconds
- **Crash-Free Rate:** >99.5%
- **Battery Drain:** <10% per 10 min active
- **API Uptime:** >99.9%
- **Spam Prevention:** <3 alerts per user per 15 min average

---

## What's New in v10?

1. **ALERT PREFERENCES** - Phase 1.5 adds comprehensive filtering without breaking emergencies
2. **VISUAL TRACKING** - 🔴🟡🟢⚪ indicators show completion status
3. **ANTI-SPAM PROTECTION** - Prevents the 24-alerts-in-minutes issue
4. **QUIET MODE** - Users can snooze alerts temporarily or set emergency-only mode
5. **QUALITY FILTERING** - Option to only receive alerts with media or multiple witnesses
6. **EMERGENCY OVERRIDE** - Mass sightings bypass all user preferences
7. **BETTER ORGANIZATION** - Alert preferences logically placed in Phase 1.5

### Phase 1.5 Rationale
Alert preferences fit perfectly between initial witness network (Phase 1) and media capture (Phase 2) because:
- Users need witness network features to understand alert quality
- Preferences help manage alert volume before media features add complexity
- Emergency escalation from Phase 1 informs preference design
- User registration (Phase 3) can import and enhance these preferences

This plan maintains the core philosophy: **Getting people to look at something weird in the sky RIGHT NOW** while preventing alert fatigue that could drive users away.

---

## Current Status Assessment (as of v10 creation)

### Completed Features (🟢)
- Anonymous beeping system working
- Basic proximity alerts with rate limiting
- Admin dashboard (without auto-testing)
- Production deployment pipeline

### In Progress Features (🟡)
- Urgent sound system (partial - basic beep implemented)
- One-tap beep button (UI exists, needs polish)
- Proximity alert system (working but needs distance ring improvements)

### Critical Next Steps
1. Complete Phase 0 foundation (sound system, beep button polish)
2. Implement Phase 1.5 alert preferences to prevent user fatigue
3. Build witness network features (Phase 1)
4. Add media capture without blocking alerts (Phase 2)

Remember: **If it doesn't help people look at something RIGHT NOW, it can wait. But if it prevents people from wanting to look, fix it immediately.**