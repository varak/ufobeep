# MASTER PLAN v12 - "WITNESS MEDIA & VIRAL SHARING" Edition

## Core Philosophy
"Hey I see something weird in the sky and I want other people to look at it RIGHT NOW"
**Priority:** Speed > Features. Alert first, analyze later. Beep now, share evidence later.

## KEY CHANGES FROM v11
- **Eliminated Matrix chat** → Replaced with simple witness media sharing
- **Added viral social sharing** → Localized for different regions/languages
- **Refined moderation** → Simple 3-flag system, no complex admin queues
- **Extended i18n** → Use existing system, add social sharing messages
- **Enhanced user system** → Human-readable IDs with progressive data collection

---

## APP NAVIGATION FLOW DIAGRAM

```
┌─────────────────────────────────────────────────────────────────┐
│                        APP LAUNCH                               │
└─────────────────────┬───────────────────────────────────────────┘
                      │
                      ▼
         ┌─────────────────────────┐
         │    First Time User?     │
         └─────────┬───────────────┘
                   │
        ┌──────────▼──────────┐         ┌─────────────────┐
        │   YES → REGISTRATION │         │  NO → HOME      │
        │   (Task 19)         │         │  (Existing)     │
        └─────────┬───────────┘         └─────────┬───────┘
                  │                               │
                  ▼                               │
    ┌─────────────────────────┐                  │
    │  Username Generation    │                  │
    │  cosmic-whisper-7823    │                  │
    │  [Regenerate] [Keep]    │                  │
    └─────────┬───────────────┘                  │
              │                                  │
              ▼                                  │
    ┌─────────────────────────┐                  │
    │    Basic Preferences    │                  │
    │  • Alert range (1-50km) │                  │
    │  • Units (metric/imp)   │                  │
    │  • Email (optional)     │                  │
    └─────────┬───────────────┘                  │
              │                                  │
              └──────────────┬───────────────────┘
                             │
                             ▼
              ┌─────────────────────────┐
              │       HOME SCREEN       │
              │   (Bottom Tab Nav)      │
              └─────────┬───────────────┘
                        │
        ┌───────────────┼───────────────┐
        │               │               │
        ▼               ▼               ▼
┌─────────────┐ ┌─────────────┐ ┌─────────────┐
│   ALERTS    │ │    BEEP     │ │  PROFILE    │
│ (Tab 1)     │ │  (Tab 2)    │ │  (Tab 3)    │
│             │ │             │ │             │
│ Alert List  │ │ Quick Beep  │ │ Settings    │
│ ↓           │ │ Camera      │ │ Preferences │
│ Alert       │ │ Gallery     │ │ Username    │
│ Details     │ │ ↓           │ │             │
│ ↓           │ │ Share Modal │ │             │
│ Media View  │ │ (Task 28)   │ │             │
│ Flag Button │ │             │ │             │
│ (Task 26)   │ │             │ │             │
└─────────────┘ └─────────────┘ └─────────────┘
```

### DETAILED SCREEN FLOWS

#### Registration Flow (New Users Only)
```
App Launch
    ↓
┌─────────────────────────┐
│   Welcome Screen        │
│   "Create your UFO ID"  │
│   [Get Started]         │
└─────────┬───────────────┘
          ▼
┌─────────────────────────┐
│  Username Generator     │  ← Task 19
│  cosmic-whisper-7823    │
│  [🎲 Generate New]      │
│  [✓ I Like This]        │
└─────────┬───────────────┘
          ▼
┌─────────────────────────┐
│   Basic Setup           │
│   Alert Range: [25km▼]  │
│   Units: [Imperial▼]    │
│   Email: [optional]     │
│   [Complete Setup]      │
└─────────┬───────────────┘
          ▼
      Home Screen
```

#### Alert Detail Flow (Enhanced)
```
Alert List
    ↓
┌─────────────────────────┐
│    Alert Detail        │  ← Task 23
│  Original: "Bright obj" │
│  cosmic-whisper-7823    │
│  📷 Photo by user       │
│  📹 Video by witness-1  │
│  📷 Photo by witness-2  │
│  ┌─────────────────┐    │
│  │ [I SEE IT TOO]  │    │ ← Task 22
│  │ + Upload Media  │    │
│  └─────────────────┘    │
│  [🚩 Flag Content]      │ ← Task 26
│  [📤 Share Sighting]    │ ← Task 28
└─────────────────────────┘
```

#### Share Flow (After Beep)
```
Successful Beep
    ↓
┌─────────────────────────┐
│   Beep Sent!            │  ← Task 28
│   "3 nearby alerted"    │
│   ┌─────────────────┐   │
│   │  Share This!    │   │
│   │  ✕ X (Twitter)  │   │
│   │  📘 Facebook    │   │
│   │  💬 WhatsApp    │   │
│   │  📱 Copy Link   │   │
│   └─────────────────┘   │
│   [Maybe Later]         │
└─────────────────────────┘
```

#### Media Upload Flow (Witnesses)
```
"I SEE IT TOO" Tap
    ↓
┌─────────────────────────┐
│   Witness Confirmation  │  ← Task 22
│   ✓ "I see it too!"     │
│   ┌─────────────────┐   │
│   │  Add Evidence   │   │
│   │  📷 Camera      │   │
│   │  🖼️  Gallery     │   │
│   │  ❌ Skip        │   │
│   └─────────────────┘   │
└─────────┬───────────────┘
          ▼
┌─────────────────────────┐
│   Media Capture         │
│   [Photo/Video UI]      │
│   [Upload Progress]     │
│   [✓ Uploaded]          │
└─────────────────────────┘
```

---

## PHASE 3 - User Registration & Identity (PRIORITY)

### Human-Readable User System
**Task 18** **[api]** `[ ]` Human ID Generator Service
- WordNet integration for `cosmic-whisper-7823` format
- Collision detection with database lookups
- API endpoints: `/users/generate-id`, `/users/check-availability/{id}`

**Task 19** **[mobile]** `[ ]` Registration Flow UI (NEW SCREENS)
- **Welcome Screen**: First-time user onboarding
- **Username Generator Screen**: Pick/regenerate human ID
- **Basic Setup Screen**: Preferences, email, units
- Progressive data collection (email/phone optional)

**Task 20** **[data]** `[ ]` User Schema Enhancement
```sql
users (
  id UUID,
  human_id VARCHAR(50) UNIQUE,
  email VARCHAR(255) NULL,
  phone VARCHAR(20) NULL,
  preferences JSONB,
  created_at TIMESTAMP
)
```

---

## PHASE 4 - Witness Media System (CORE FEATURE)

### Evidence Collection Architecture
**Task 21** **[api]** `[ ]` Multi-User Media Upload System
- Extend `/alerts/{id}/media` for witness uploads
- Proximity validation (only nearby witnesses can upload)
- Time-limited uploads (60-minute window)
- Owner attribution tracking

**Task 22** **[mobile]** `[ ]` Witness Media Upload UI (ENHANCED EXISTING)
- **Alert Detail Screen**: Enhanced with multi-user media display
- **"I SEE IT TOO" Action**: Now includes optional media upload
- **Media Capture Flow**: Camera/gallery for witnesses
- **Upload Progress**: Real-time feedback

**Task 23** **[web]** `[ ]` Enhanced Alert Display
- Multiple media from different witnesses
- Media attribution ("Photo by cosmic-whisper-7823")
- Witness media indicators in alert cards

### Content Moderation System
**Task 24** **[api]** `[ ]` Auto-NSFW Detection
- Extend existing HuggingFace text filtering to images/videos
- Google Vision API SafeSearch integration
- Auto-reject flagged content at upload time

**Task 25** **[api]** `[ ]` Community Flagging System
- Simple 3-flag auto-hide mechanism
- User flag rate limiting (5/hour, 20/day)
- Owner self-deletion capabilities
- No admin queue - auto-restoration after 48 hours

**Task 26** **[mobile]** `[ ]` Flag Content UI (NEW SCREEN ELEMENT)
- **Flag Content Modal**: Appears on long-press of media
- Simple flag reasons: NSFW, Spam, Unrelated
- Rate limiting enforcement in UI
- Confirmation dialog

---

## PHASE 5 - Viral Social Sharing (GROWTH)

### Localized Social Platform Integration
**Task 27** **[api]** `[ ]` Social Platform Configuration System
- `/shared/social-platforms.json` with locale-specific platforms
- Template system for share messages
- URL generation with platform-specific formats

**Task 28** **[mobile]** `[ ]` Post-Beep Sharing UI (NEW MODAL)
- **Share Modal**: Appears after successful beep
- **Success Screen Enhancement**: "Share this sighting" section
- Dynamic platform buttons based on user locale
- Pre-filled messages with alert ID and location

**Task 29** **[web]** `[ ]` Social Share Integration
- Share buttons on individual alert pages
- Open Graph meta tags for rich previews
- Clean shareable URLs: `ufobeep.com/alerts/cosmic-whisper-7823`

### Internationalization Extensions
**Task 30** **[mobile]** `[ ]` i18n Social Messages
- Extend existing `/app/lib/l10n/app_{locale}.arb` files
- Add `shareMessage` with placeholders for alertId, location, url
- Support for Russian (VK, Telegram), Chinese (WeChat, Weibo)

**Task 31** **[web]** `[ ]` i18n Social Messages
- Extend existing `/web/public/locales/{locale}/common.json`
- Add social sharing messages with template variables
- Platform-specific message templates

---

## PHASE 6 - Enhanced Enrichment (v11 PRIORITY)

### Advanced Analysis Widgets
**Task 32** **[api]** `[ ]` Aircraft Tracking Widget
- OpenSky Network API integration (credentials configured)
- Real-time aircraft correlation with sighting time/location
- Commercial vs military aircraft identification

**Task 33** **[api]** `[ ]` Enhanced Weather Widget
- Add Bortle scale light pollution data
- Sky quality indicators for optimal viewing
- Integration with existing weather enrichment

**Task 34** **[api]** `[ ]` Precise ISS/Satellite Widget
- NASA TLE data for exact satellite positions
- Magnitude/brightness calculations
- BlackSky satellite imagery purchase integration

**Task 35** **[api]** `[ ]` Celestial Events Widget
- Active meteor shower calendar
- Planetary visibility and conjunctions
- Moon phase and illumination data

---

## ADDITIONAL CONSIDERATIONS

### Database Performance
**Task 36** **[data]** `[ ]` Media Storage Optimization
- Implement automatic cleanup of expired uploads (>60 min old)
- Media compression for bandwidth optimization
- CDN consideration for global media serving

### Security & Abuse Prevention
**Task 37** **[api]** `[ ]` Upload Rate Limiting
- Per-user media upload limits (10/hour, 50/day)
- IP-based rate limiting for anonymous users
- Geographic validation for witness uploads

### Analytics & Monitoring
**Task 38** **[api]** `[ ]` Viral Sharing Tracking
- Track share button clicks by platform/locale
- Measure conversion rates from shared links
- Monitor user acquisition from social sharing

### Future Revenue Integration
**Task 39** **[api]** `[ ]` Premium Feature Foundation
- BlackSky imagery purchase flow preparation
- User purchase history tracking
- Payment integration preparation (Stripe/PayPal)

---

## NAVIGATION IMPACT SUMMARY

### NEW SCREENS ADDED:
1. **Welcome Screen** (Task 19) - First-time users only
2. **Username Generator Screen** (Task 19) - First-time users only  
3. **Basic Setup Screen** (Task 19) - First-time users only
4. **Share Modal** (Task 28) - After successful beep
5. **Flag Content Modal** (Task 26) - Long-press on media

### ENHANCED EXISTING SCREENS:
1. **Alert Detail Screen** (Task 22/23) - Multi-user media display
2. **"I SEE IT TOO" Action** (Task 22) - Now includes media upload option
3. **Profile Screen** - Shows username, preferences

### NO NEW BOTTOM TABS - maintains existing 3-tab structure
- **Alerts Tab**: Enhanced with multi-media display
- **Beep Tab**: Enhanced with share modal
- **Profile Tab**: Enhanced with username display

---

## SUCCESS CRITERIA
- **Phase 3**: Human IDs generating, user registration working
- **Phase 4**: Multiple witnesses can upload media to same alert
- **Phase 5**: Social sharing working for 3+ languages/regions
- **Phase 6**: Aircraft tracking 80% accurate, enrichment data complete

## TECHNICAL DEPENDENCIES
- Existing i18n system (✅ already implemented)
- HuggingFace API (✅ configured for text)
- Google Vision API (✅ configured)
- OpenSky API (✅ credentials configured)
- Social platform APIs (varies by region)

This plan preserves the "look NOW" urgency while adding evidence sharing and viral growth without complex chat systems or heavy moderation overhead.

---

_Last Updated: 2025-08-20_
_Version: 12.0_
_Status: Active Development_