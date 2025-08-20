# UFOBeep — MASTER PLAN v11 — "ENHANCED ENRICHMENT" Edition

**Core Philosophy:** "Hey I see something weird in the sky and I want other people to look at it RIGHT NOW"  
**Priority:** Speed > Features. Alert first, analyze later. Beep now, chat later. Look NOW.

> **v11 Changes from v10:**
> - Enhanced enrichment widgets architecture defined
> - OpenSky aircraft tracking integration (API key configured)
> - BlackSky satellite imagery as premium feature
> - Precise ISS tracking with NASA TLE data
> - Light pollution/Bortle scale integration
> - Celestial events calendar (meteor showers, planetary alignments)
> - Unit conversion system deployed (imperial defaults for US)
> - Photo filter feature on alerts page
> - SSL/nginx issues resolved

## Critical Success Metrics
- **Time to Beep:** ≤3 seconds from app open to alert sent
- **Alert Delivery:** ≤2 seconds to nearby devices
- **Compass Open:** ≤1 second from notification tap
- **Witness Join:** ≤5 seconds to "I see it too"
- **Battery Impact:** ≤10% for 10 min active use on low-end device
- **Alert Spam Prevention:** No more than 3 alerts per user per 15 minutes
- **Enrichment Data:** Available within 30 seconds of alert submission

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
- 🟢 API Layer: Unified to `/alerts` pattern  
- 🟢 Mobile App: Using `/alerts` endpoints
- 🟢 Removed: All `/sightings` endpoint references

---

## PHASE 0 — Emergency Alert Foundation ✅ COMPLETE

All core alert system tasks completed including:
- 🟢 Urgent sound system with escalating levels
- 🟢 Proximity detection and rate limiting
- 🟢 Quiet hours with emergency override
- 🟢 Multi-media support (photos & videos)
- 🟢 Share-to-beep functionality

---

## PHASE 1 — Witness Network ✅ COMPLETE

- 🟢 "I SEE IT TOO" button system
- 🟢 Witness counter with dynamic escalation
- 🟢 Triangulation indicators
- 🟢 Emergency override for mass sightings

---

## PHASE 1.5 — Alert Preferences ✅ COMPLETE

- 🟢 DND/Quiet mode implementation
- 🟢 User preference storage
- 🟢 Rate limiting with emergency override
- 🟢 Alert filtering system

---

## PHASE 2 — Media Capture ✅ COMPLETE

- 🟢 Share-to-beep from gallery
- 🟢 Quick capture camera UI
- 🟢 Video recording (30s max)
- 🟢 EXIF GPS embedding
- 🟢 Media upload pipeline

---

## PHASE 3 — User Registration 🟡 IN PROGRESS

### Human-Readable IDs
18. 🔴 **[api] Human ID Generator** - WordNet magic names
    - `cosmic-whisper-7823` format
    - Collision-free generation
    - Memorable for sharing

19. 🟡 **[mobile] Registration Flow** - Preferences during signup
    - Name selection/regeneration
    - Alert range setting
    - Notification preferences
    - Unit preferences (metric/imperial)

---

## PHASE 4 — Community Chat 🔴 NOT STARTED

20. 🔴 **[api] Matrix Integration** - Per-alert chat rooms
21. 🔴 **[mobile] Chat UI** - Simple messaging interface
22. 🔴 **[api] Chat Notifications** - Push for new messages

---

## PHASE 5 — Smart Enrichment 🟡 IN PROGRESS

**Goal:** Add context without blocking urgent alerts

### Current Enrichment (Working)
- 🟢 **Weather Data** - Temperature, wind, visibility, humidity
- 🟢 **Basic Satellites** - ISS and Starlink passes
- 🟢 **Content Analysis** - Spam/toxicity filtering
- 🟢 **Unit Conversion** - Imperial/metric display preferences

### Enhanced Enrichment Widgets (NEW IN v11)

25. 🟡 **[api] Aircraft Tracking Widget** - OpenSky Network integration
    - Real-time aircraft positions at sighting time
    - Flight path correlation
    - Airport proximity detection
    - Commercial vs military identification
    - API credentials configured: `OPENSKY_CLIENT_ID` and `OPENSKY_CLIENT_SECRET`

26. 🔴 **[api] Precise ISS/Satellite Widget** - NASA TLE data
    - Exact ISS position using Two-Line Elements
    - Magnitude/brightness calculations
    - Pass duration and max elevation
    - Other trackable satellites (Hubble, Tiangong)

27. 🔴 **[api] Celestial Events Widget** - Astronomical calendar
    - Active meteor showers
    - Planetary visibility/conjunctions
    - Moon phase and illumination
    - Notable astronomical events

28. 🔴 **[api] Enhanced Weather Widget** - Light pollution data
    - Bortle scale rating for location
    - Light pollution map integration
    - Sky quality meter equivalent
    - Optimal viewing conditions indicator

29. 🔴 **[api] BlackSky Satellite Integration** - Premium imagery
    - Display as "satellite" in existing widget
    - Click to purchase archived imagery ($25)
    - Option for priority tasking ($100+)
    - "See what satellites saw" value prop
    - Simple popup/modal for purchase flow

### Enrichment Architecture
```
Alert Submission
    ↓ (immediate)
Alert Sent to Nearby Devices
    ↓ (async, 30s later)
Enrichment Pipeline Starts
    ├── Weather + Light Pollution (combined widget)
    ├── Aircraft Tracking (OpenSky)
    ├── ISS/Satellites (NASA TLE)
    ├── Celestial Events
    └── BlackSky Option (in satellite list)
```

### Implementation Priority
1. **Aircraft Tracking** - Most important for debunking
2. **Enhanced Weather** - Add light pollution to existing
3. **Precise ISS** - Upgrade existing satellite widget
4. **Celestial Events** - New widget for context
5. **BlackSky** - Premium revenue opportunity

---

## PHASE 6 — Compass Navigation 🔴 NOT STARTED

30. 🔴 **[mobile] AR Compass Mode** - Point to find object
31. 🔴 **[mobile] Standard Compass** - Traditional navigation
32. 🔴 **[mobile] Pilot Mode** - Aviation-style display

---

## PHASE 7 — Advanced Features 🔴 FUTURE

- Web admin dashboard
- MUFON integration
- Researcher tools
- Advanced analytics
- API marketplace

---

## COMPLETED INFRASTRUCTURE UPDATES (v11)

### Unit Conversion System 🟢
- Mobile app respects user preferences (metric/imperial)
- Website defaults to imperial units (US audience)
- Temperature, wind speed, visibility, distance conversions
- Deployed to production

### Website Enhancements 🟢
- Photo filter on alerts page (clickable stat card)
- Visual feedback for active filters
- Pagination improvements
- SSL/nginx configuration fixed (removed duplicates)

### API Configuration 🟢
- OpenSky Network credentials added to .env
- N2YO satellite API configured
- OpenWeather API active
- HuggingFace content filtering operational

---

## Current Development Focus

**PRIORITY ORDER:**
1. Complete Phase 3 (User Registration) - Human-readable IDs
2. Implement Phase 5 Enhanced Enrichment:
   - Aircraft tracking with OpenSky
   - Light pollution integration
   - Precise ISS tracking
   - Celestial events calendar
   - BlackSky imagery option
3. Then Phase 4 (Community Chat)
4. Then Phase 6 (Compass Navigation)

---

## Key Metrics to Track

### User Engagement
- Daily active users
- Alerts per user per day
- Witness confirmation rate
- Media attachment rate
- Chat participation rate

### System Performance
- Alert delivery latency
- Enrichment processing time
- API response times
- Media upload success rate
- Push notification delivery rate

### Data Quality
- Aircraft identification accuracy
- False positive rate
- Witness triangulation accuracy
- Enrichment data completeness

---

## Revenue Opportunities

### Premium Features (Phase 5+)
- **BlackSky Imagery**: $25-100 per image
- **Priority Enrichment**: Faster processing
- **Extended History**: Access older alerts
- **Advanced Analytics**: Detailed patterns
- **API Access**: Researcher/developer tier

### Partnerships
- BlackSky satellite imagery resale
- MUFON data exchange
- Academic research access
- Media organization feeds

---

## Next Sprint (Immediate Tasks)

1. 🟡 **Implement Aircraft Tracking Widget**
   - Use OpenSky API for real-time aircraft data
   - Create AircraftTrackingCard component
   - Add to enrichment pipeline

2. 🟡 **Enhance Weather Widget**
   - Add light pollution API integration
   - Display Bortle scale rating
   - Update WeatherCard component

3. 🔴 **Upgrade Satellite Widget**
   - Integrate NASA TLE data for ISS
   - Add BlackSky as clickable option
   - Implement purchase flow modal

4. 🔴 **Create Celestial Events Widget**
   - Meteor shower calendar API
   - Planetary position calculations
   - New CelestialEventsCard component

---

## Success Criteria

### Phase 5 Enhanced Enrichment Complete When:
- ✅ Aircraft within 50km radius identified
- ✅ Light pollution data displayed
- ✅ ISS position accurate to <1km
- ✅ Celestial events for next 48h shown
- ✅ BlackSky purchase flow working

### User Experience Goals:
- Enrichment doesn't slow alerts
- Data helps identify objects
- Premium features discoverable
- Clean, understandable UI
- Mobile-first design

---

## Notes & Decisions

- Imperial units default for US audience
- BlackSky as simple satellite option, not complex widget
- Aircraft tracking highest priority for credibility
- All enrichment async - never blocks alerts
- Premium features enhance, don't gate core functionality

---

_Last Updated: 2025-08-20_
_Version: 11.0_
_Status: Active Development_