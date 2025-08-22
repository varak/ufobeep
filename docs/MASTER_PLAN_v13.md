# MASTER_PLAN_v13 — UFOBeep
**User System Implementation & Premium Features**

## Debugging Summary - Photo Upload Issues (Aug 21, 2025)

### Root Cause Identified
- **Primary Issue**: Missing `firebase_admin` module on production server
- **Impact**: ALL photo uploads were failing with proximity alerts error
- **Resolution**: Installed firebase_admin using `sudo pip install --break-system-packages firebase-admin`

### Issues Fixed
1. **Proximity Alerts**: Now working (tested - no-media beep from tablet successfully alerted 4 nearby devices)
2. **Phone Photo Uploads**: Working after firebase_admin installation
3. **Tablet No-Media Beeps**: Working correctly

### Final Resolution
- **Tablet Photo Uploads**: ✅ **FIXED** - Camera app needed location permissions
- **Root Cause**: Camera app (not UFOBeep app) lacked location permission to embed GPS data in photo EXIF
- **Solution**: Granted location permissions to tablet's camera application

### System Status - ALL WORKING ✅
- API: ✅ Running (ufobeep-api.service active)
- Proximity Alerts: ✅ Working (firebase_admin installed)
- Push Notifications: ✅ Working (some old tokens failing as expected)
- Phone Uploads: ✅ Working
- Tablet Uploads: ✅ Working (camera permissions fixed)

## Deployment & Development

### Deploy Script
- **Location**: `/home/mike/D/ufobeep/deploy.sh`
- **Usage**: `./deploy.sh` (from project root)
- **What it does**:
  - Commits and pushes to GitHub
  - Builds release APK automatically
  - Deploys to all connected devices
  - Updates production API if needed

### Latest Updates (Aug 21, 2025)
- ✅ **SkyFi Integration**: Added alongside BlackSky for premium satellite imagery
- ✅ **Pricing Removed**: BlackSky and SkyFi show "Coming Soon" instead of pricing
- ✅ **Website Updated**: Homepage and download page reflect satellite integrations
- ✅ **API Fixed**: Both BlackSky and SkyFi data now included in enrichment responses

See conversation plan details here.

---

## MASTER PLAN v13 ROADMAP

### PHASE 1: User System Implementation (PRIORITY)

**Current Issue**: Empty `reporterId` fields causing UI bugs
- "I saw it too" showing for alert creators
- Premium satellite access control failing

**Solution**: Replace anonymous device IDs with proper user system

#### Task MP13-1: Username Generation System
**Objective**: Replace device IDs with human-readable usernames
- Generate usernames like `cosmic-whisper-7823` on first app launch
- Store username mapping in backend user table
- Migrate existing anonymous alerts to username system

#### Task MP13-2: User Registration Flow  
**Objective**: Progressive onboarding for new users
- Welcome screen with username generator
- Basic preferences (alert range, units, optional email)
- Seamless transition to main app

#### Task MP13-3: Alert Ownership Fix
**Objective**: Proper alert attribution and access control
- Populate `reporterId` with username instead of device ID
- Fix "I saw it too" visibility logic
- Fix premium satellite imagery access control
- Enable cross-device user experience

### PHASE 2: Enhanced Premium Features

#### Task MP13-4: Premium Satellite Access Refinement
**Objective**: Proper access control for BlackSky/SkyFi
- Creator access: Always visible
- Witness access: Only for confirmed witnesses within 2x visibility distance
- Guest access: Denied (show placeholder with upgrade prompt)

#### Task MP13-5: Witness Confirmation Enhancement  
**Objective**: Improve witness verification system
- Distance-based validation using weather visibility data
- Time window restrictions (configurable, default 60 minutes)
- Anti-spam protection (rate limiting per user)

### PHASE 3: User Experience Improvements

#### Task MP13-6: Profile Management
**Objective**: Basic user settings and preferences
- Username display and regeneration option
- Alert history and statistics
- Privacy settings for alert visibility

#### Task MP13-7: Social Features Foundation
**Objective**: Prepare for viral sharing (MP14)
- User attribution in alerts ("Reported by cosmic-whisper-7823")
- Follow-up witness media uploads
- Basic user reputation system

### Implementation Priority

1. **MP13-1, MP13-2, MP13-3** → Fixes current `reporterId` bugs
2. **MP13-4, MP13-5** → Enhances premium features reliability  
3. **MP13-6, MP13-7** → Improves user engagement

This roadmap directly addresses our current device ID comparison issues while building foundation for advanced features.
