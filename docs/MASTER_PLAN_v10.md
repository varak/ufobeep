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

## UNIFIED ALERTS ARCHITECTURE 🟢 ✅ IMPLEMENTED

**Clean Break Philosophy:** No backward compatibility - unified `/alerts` endpoints only

### Core API Design
```
POST   /alerts                         → Create new alert (replaces /beep/anonymous)
GET    /alerts                         → List all alerts  
GET    /alerts/{id}                    → Get specific alert
POST   /alerts/{id}/media              → Upload media to alert
DELETE /alerts/{id}/media/{file}       → Remove media
PATCH  /alerts/{id}                    → Update alert details  
POST   /alerts/{id}/witness            → Confirm witness
GET    /alerts/{id}/witness-aggregation → Witness data
```

### Mobile App Workflow
```
1. POST /devices/register               ← Register device
2. PATCH /devices/{device_id}/location  ← Update location
3. POST /alerts                         ← Create alert, get ID  
4. POST /alerts/{id}/media              ← Upload media
5. GET /alerts/{id}                     ← Display result
```

### Future Features Ready
- **User Accounts**: Clean alert ownership model (`user_id` field)
- **2x Visibility Media**: Proximity-based sharing permissions
- **Cross-Device Sync**: User's alerts synced across devices
- **Alert Management**: Edit/delete own alerts
- **Proximity Sharing**: Users within 2x visibility can add media

### Implementation Status
- 🟢 Database: `sightings` table (implementation detail)
- 🟡 API Layer: Needs unification to `/alerts` pattern  
- 🟡 Mobile App: Update to use `/alerts` endpoints
- 🟡 Remove: All `/sightings` endpoint references

---

## PHASE 0 — Emergency Alert Foundation (GET BEEPING NOW)
**Goal:** Make phones beep URGENTLY when something's in the sky

### Core Alert System
1. 🟢 **[mobile] URGENT SOUND SYSTEM** - Multiple alert levels with escalating sounds ✅
   - ✅ Normal beep: single tone
   - ✅ Multiple witnesses: urgent warble  
   - ✅ Mass sighting (10+): emergency siren
   - ✅ Audio focus and vibration support
   - 🔴 Override quiet hours for emergency level (Phase 1.5 - needs user preferences)
   - ✅ Rate limiting protection (max 3 alerts per 15 min)

2. 🟢 **[api] Anonymous Beeping** - No signup required ✅
   - ✅ Device ID based tracking
   - ✅ Optional registration later
   - ✅ Guest beeps fully functional

3. 🟢 **[mobile] One-Tap Beep Button** - HUGE button on app open ✅
   - ✅ No menus, no navigation (QuickBeepScreen)
   - ✅ GPS permission request inline
   - 🔴 Fallback to manual direction if GPS fails (minor enhancement)

4. 🟢 **[api] Proximity Alert System** - Instant fanout ✅
   - ✅ Geohash-based delivery (90-500ms delivery times achieved)
   - ✅ Distance rings: 1km, 5km, 10km, 25km
   - ✅ Haversine distance calculation fallback
   - 🔴 Priority queue for closer witnesses (optimization)
   - ✅ Rate limiting: skip alerts if 3+ sightings in 15 minutes

**→ Breakpoint B0: BEEPING WORKS ✅ ACHIEVED**
```bash
# Test anonymous beep
curl -X POST https://api.ufobeep.com/beep/anonymous \
  -d '{"device_id":"test123","lat":47.61,"lon":-122.33}'
# ✅ WORKING: Push to all devices within 25km in 90-500ms
```

---

## PHASE 1 — Instant Witness Network
**Goal:** Get multiple people looking at the same thing

### Witness Coordination
5. 🟢 **[mobile] "I SEE IT TOO" Button** - One tap to confirm ✅
   - ✅ Adds witness count in real-time
   - ✅ Escalates alert priority (3+ urgent, 10+ emergency)
   - ✅ Shows bearing from witness location with distance calculation
   - ✅ Cross-platform witness count display (mobile action, website display)
   - ✅ Admin dashboard monitoring and management

6. 🟢 **[mobile] Compass Arrow Overlay** - Points to sighting ✅
   - ✅ Opens immediately on notification tap
   - ✅ Shows distance and direction to sighting
   - ✅ Updates in real-time as you move
   - ✅ Bearing calculation from device to sighting location
   - ✅ Direct navigation from push notifications

7. 🟢 **[api] Witness Aggregation** - Build consensus ✅
   - ✅ Triangulation from multiple bearings with confidence scoring
   - ✅ Heat map of witness locations for admin analysis
   - ✅ Auto-escalate when witnesses exceed threshold
   - ✅ Admin dashboard for witness aggregation analysis
   - ✅ Consensus quality scoring and uncertainty radius calculation

**→ Breakpoint B1: WITNESS NETWORK ACTIVE**
- 3+ witnesses within 60 seconds escalates to emergency
- Compass navigation guides witnesses to look in right direction

---

## PHASE 1.5 — Alert Preferences & Quiet Mode (NEW)
**Goal:** Give users control over alert frequency without breaking emergency response

### Alert Filtering & Controls
9. 🟢 **[mobile] Alert Preferences Screen** - Fine-grained control ✅
   - ✅ "Ignore anonymous beeps" toggle (only get alerts from registered users)
   - ✅ "Media-only alerts" toggle (only alerts with attached photos/videos)
   - ✅ Quiet hours with emergency override (10+ witnesses bypass)
   - 🔴 Distance filter slider (1km - 100km range) - future enhancement
   - 🔴 Quality threshold (minimum witness count before alert) - future enhancement

10. 🟢 **[mobile] Quiet Mode & Snooze Options** - Temporary muting ✅
    - ✅ "Snooze alerts for 1 hour" quick action in profile
    - ✅ "Snooze alerts for 8 hours" (overnight mode)
    - ✅ "Snooze alerts for 24 hours" (full day off)
    - ✅ Do Not Disturb integration with countdown display
    - ✅ Connected to alert sound system with userPrefs loading
    - ✅ Emergency override: 10+ witnesses bypass all quiet settings

11. 🟢 **[api] Smart Alert Throttling** - Prevent spam without blocking emergency ✅
    - ✅ Global rate limiting system (max 3 alerts per 15 minutes)
    - ✅ Emergency override: mass sightings (10+ witnesses) bypass all filters
    - ✅ Admin controls for rate limiting management (web + mobile)
    - ✅ Rate limiting status monitoring and control endpoints
    - ✅ Configurable thresholds and history clearing capabilities

### User Experience Enhancements
12. 🔴 **[mobile] Alert Preview & Dismiss** - Better notification control
    - Rich notification preview with distance/witness count
    - "Dismiss and snooze similar" option  
    - Quick "I see it too" action from notification
    - Quick "I checked but don't see it"
    - Quick "I missed this one"
 - Expanded notification actions for fast response

**→ Breakpoint B1.5: ALERT FATIGUE SOLVED**
- Users can customize alert frequency without missing emergencies
- Beta testers report manageable notification levels
- Emergency alerts still override all preferences

---

## PHASE 2 — Media & Evidence (But Don't Block Alerts)
**Goal:** Capture evidence without slowing down alerts

### Media Capture
13. 🟢 **[mobile] Share-to-Beep** - From camera/gallery ✅
    - ✅ Share sheet integration with Android intent handling
    - ✅ Alert sends IMMEDIATELY (pre-populates beep screen)
    - ✅ Media uploads in background with file extension detection
    - ✅ Optional description field when media is shared

14. 🟢 **[mobile] Quick Capture** - Built-in camera ✅
    - ✅ Direct camera integration with fast workflow (≤3s beep time)
    - ✅ Dual shutter sound (system + app) with haptic feedback
    - ✅ Maximum resolution capture with GPS EXIF embedding
    - ✅ Immediate navigation to composition screen (no approval step)
    - ✅ Auto-save to phone gallery in UFOBeep album
    - ✅ Video mode for ongoing sightings (30s max, toggle in camera UI)
    - ✅ Video playback working on mobile and website

### Processing Pipeline
15. 🟡 **[api] Media Processing Pipeline** - Async enrichment
    - ✅ EXIF extraction for time/location (photos working)
    - ✅ Media type detection and proper API response formatting
    - ✅ Mobile app video player integration (VideoPlayerWidget working)
    - ✅ Website video player implementation (HTML5 video with controls)
    - 🔴 Video thumbnail generation (using placeholder URLs with ?thumbnail=true)
    - 🔴 AI object detection (runs AFTER alert)

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

### Viral Mechanics (moved from Phase 1)
18. 🔴 **[mobile] Quick Share After Beep** - Viral mechanics
    - "Share to Twitter/Facebook/WhatsApp" modal
    - Pre-filled: "UFO sighting UFO-2025-001234 near [location]! Download UFOBeep to see where"
    - Clean shareable link: ufobeep.com/UFO-2025-001234
    - Track who recruited witnesses
    - Gamification: "You recruited 5 witnesses!"

### Personal History & Advanced Preferences
19. 🔴 **[mobile][web] Sighting History** - Track what you've seen
    - Personal sighting log
    - Favorite/follow sightings
    - Export to MUFON format
    - Alert history and statistics

20. 🔴 **[mobile] Advanced Alert Preferences** - Power user controls
    - Custom notification sounds per alert type
    - Time-based preferences (work hours vs evenings)
    - Location-based rules (home, work, travel zones)
    - Integration with calendar (mute during meetings)
    - Friend/follower alerts (higher priority for trusted users)

**→ Breakpoint B3: PERSONALIZED EXPERIENCE**
- Clean, memorable IDs enable viral sharing
- Share modal gets 30%+ engagement rate
- Users can track their recruiting success
- History tracking improves future recommendations

---

## PHASE 4 — Matrix Chat Integration (Decentralized Discussion)
**Goal:** Let witnesses discuss without central control

### Chat Infrastructure
21. 🔴 **[api] Matrix Homeserver Setup** - chat.ufobeep.com
    - Auto-create room per sighting: #UFO-2025-001234:ufobeep.com
    - Bridge UFOBeep users to Matrix accounts
    - Federation enabled for cross-server participation

22. 🔴 **[mobile][web] "Join Discussion" Button** - On every sighting
    - One-tap to join Matrix room
    - No separate chat app needed
    - Embedded chat widget

### Chat Features
23. 🔴 **[api] Chat Notifications** - Configurable alerts
    - "Notify me about comments on my sighting" toggle
    - Follow/unfollow discussions
    - @mentions and replies
    - Integration with main alert preferences

24. 🔴 **[mobile] Chat Quick Actions** - Speed matters
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
25. 🔴 **[api] Aircraft Checker** - ADS-B integration
    - Runs 30s AFTER alert sent
    - Shows possible aircraft matches
    - Never blocks or delays alert

26. 🔴 **[api] Satellite Tracker** - TLE matching
    - Identifies possible satellites
    - ISS pass notifications
    - Starlink train detection

27. 🔴 **[api] Weather/Astronomy** - Natural phenomena
    - Moon phase and position
    - Planet visibility
    - Weather balloon tracker

### Enrichment Display
28. 🔴 **[web] Enrichment Dashboard** - See all analyses
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
29. 🔴 **[mobile] Invite Rewards** - Gamification
    - "Invite 3 friends, unlock AR mode"
    - Leaderboard for most witnesses recruited
    - Badges for first responders

30. 🔴 **[mobile] Quick Tile / Widget** - One-tap from home screen
    - Android Quick Settings tile
    - iOS widget with big BEEP button
    - Apple Watch / Wear OS apps

### Public Engagement
31. 🔴 **[web] Public Alert Pages** - SEO optimized
    - Rich previews for social sharing
    - Live witness count
    - "Download app to join" CTA

32. 🔴 **[api] MUFON Integration** - Credibility bridge
    - Export to MUFON format
    - Import MUFON reports
    - Cross-reference sightings

**→ Breakpoint B6: VIRAL GROWTH PROVEN**
- 10% weekly user growth
- Social sharing drives 30%+ of new installs

---

## PHASE 7 — Advanced Features (Don't Build Until Phase 6 Ships)

### Advanced Visualization
33. 🔴 **[mobile] AR Visualization** - For capable devices
    - Optional AR overlay
    - Bearings in 3D space
    - Witness positions on map

34. 🔴 **[api] Machine Learning** - Pattern detection
    - Cluster similar sightings
    - Predict hotspots
    - Classify objects

### Professional Features
35. 🔴 **[mobile] Pilot Mode** - Advanced navigation
    - Professional compass
    - Aviation charts overlay
    - ADSB integration

36. 🔴 **[ops] Moderation System** - Community safety
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
- ✅ Anonymous beeping system working
- ✅ Proximity alerts with rate limiting (90-500ms delivery)
- ✅ Emergency alert escalation system (normal/urgent/emergency sounds)
- ✅ Audio focus and vibration support
- ✅ Firebase push notifications working
- ✅ Admin dashboard functional with rate limiting controls
- ✅ Production deployment pipeline
- ✅ Rate limiting system with admin management (web + mobile)
- ✅ **PHASE 0 COMPLETE** - Breakpoint B0 achieved
- ✅ **PHASE 1 COMPLETE** - Breakpoint B1 achieved  
- ✅ **PHASE 1.5 MOSTLY COMPLETE** - Alert fatigue solved with DND/quiet mode
- ✅ **PHASE 2 MOSTLY COMPLETE** - Media capture doesn't slow alerts

### Phase 1 Complete! (🟢)  
- **PHASE 1** - Instant Witness Network (3/3 complete) ✅ ACHIEVED
  1. ✅ "I SEE IT TOO" button for witness confirmation
  2. ✅ Compass arrow overlay pointing to sighting
  3. ✅ Witness aggregation and consensus building

### Phase 1.5 Complete! (🟢)  
- **PHASE 1.5** - Alert Preferences & Quiet Mode (3/4 complete) ✅ MOSTLY ACHIEVED
  1. ✅ Alert preferences screen with basic controls
  2. ✅ Quiet mode & snooze options (DND fully functional)
  3. ✅ Smart alert throttling (rate limiting implemented)
  4. 🔴 Alert preview & dismiss features (notification enhancements)

### Next Phase Priority (🔴)  
- **PHASE 2** - Media & Evidence (2/3 complete) 
  1. ✅ Share-to-Beep implementation complete
  2. ✅ Quick capture built-in camera (fast workflow achieved)
  3. 🔴 Media processing pipeline (async enrichment)

### Critical Next Steps
1. ✅ **Phase 0 foundation complete** - Emergency alert system working
2. ✅ **Phase 1 complete** - Witness network fully operational (Tasks 5, 6, 7 ✅ complete)
3. ✅ **Phase 1.5 mostly complete** - DND, quiet mode, and rate limiting operational
4. ✅ **Phase 2 mostly complete** - Share-to-beep and quick capture camera functional
5. **Next Priority: Task 15** - Media processing pipeline (async EXIF/AI/enrichment)
6. **Then: Task 12** - Alert preview & dismiss (rich notifications, quick actions)
7. **Then: Phase 3** - Human-readable IDs and enhanced user registration

Remember: **If it doesn't help people look at something RIGHT NOW, it can wait. But if it prevents people from wanting to look, fix it immediately.**
