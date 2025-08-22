# MP13 Testing Guide - User Registration & Alert Ownership

## ✅ Completed Features (MP13-1, MP13-2, MP13-3)

### 1. Username Generation System (MP13-1)
- Cosmic-themed usernames like `astral.specter.0002`
- Multiple alternatives provided for user choice

### 2. Progressive Registration Flow (MP13-2)
- Splash screen → Registration screen → Main app
- No skip option - registration is required for best experience
- Integrated with app initialization

### 3. Alert Ownership Fix (MP13-3)
- `reporter_id` field now populated in alerts
- "I saw it too" button hidden for alert creators
- Automatic migration from device_ids to usernames

## 🧪 Testing Instructions

### Test 1: New User Registration Flow
**What to test:** Complete onboarding experience

1. **Uninstall the app** (to simulate new user)
2. **Install fresh APK** from https://ufobeep.com/downloads/ufobeep-latest.apk
3. **Launch app**
4. **Expected behavior:**
   - Splash screen appears with initialization
   - Automatically routes to registration screen
   - Username is pre-generated (e.g., `cosmic.whisper.7823`)
   - Can select from alternatives or generate new options
   - NO "Skip for now" button (registration is required)
5. **Fill registration:**
   - Accept generated username or choose alternative
   - Optional: Add email (for future persistence features)
   - Set alert range (default 50km)
   - Choose metric/imperial units
6. **Tap "Register"**
7. **Expected result:**
   - Success message shows username
   - Navigates to main alerts screen
   - User is now registered

### Test 2: Returning User Experience
**What to test:** App remembers registered users

1. **Close app completely**
2. **Reopen app**
3. **Expected behavior:**
   - Splash screen appears
   - Automatically routes to alerts screen (skips registration)
   - User remains logged in with same username

### Test 3: "I Saw It Too" Button Visibility
**What to test:** Button only shows for non-creators

1. **Create a new alert** (tap beep button)
2. **Navigate to your own alert**
3. **Expected:** NO "I saw it too" button (you created it)
4. **Find someone else's alert**
5. **Expected:** "I saw it too" button IS visible
6. **Tap the button**
7. **Expected:** Witness count increases

### Test 4: Alert Attribution
**What to test:** Alerts show reporter information

1. **View any alert in the list**
2. **Check alert details**
3. **Expected:** `reporter_id` field contains either:
   - Device ID format: `android_V1UFN35H.193-20_1755848514426` (old alerts)
   - Username format: `cosmic.whisper.7823` (new alerts after registration)

## 📊 API Testing Commands

### Test Username Generation
```bash
curl -X POST https://api.ufobeep.com/users/generate-username
```
Expected: Returns username with alternatives

### Test User Registration
```bash
curl -X POST https://api.ufobeep.com/users/register \
  -H "Content-Type: application/json" \
  -d '{
    "device_id": "your-device-id",
    "platform": "android",
    "email": "optional@email.com"
  }'
```
Expected: Returns username and user_id

### Check Migration Status
```bash
curl https://api.ufobeep.com/users/migration-status
```
Expected: Shows progress of device_id → username migration

### Verify Alert Reporter IDs
```bash
curl https://api.ufobeep.com/alerts | jq '.data.alerts[0].reporter_id'
```
Expected: Returns the reporter_id (device_id or username)

## 🔍 What to Look For

### ✅ Working Correctly:
- Username generation provides cosmic-themed names
- Registration is required (no skip option)
- "I saw it too" button hidden for your own alerts
- Alerts contain reporter_id field
- Device IDs automatically migrate to usernames

### ⚠️ Known Limitations:
- **No persistence across reinstalls** (username lost if app deleted)
- **No email verification** yet (email field exists but not used)
- **No cross-device sync** (each device gets new username)
- **Mixed reporter formats** (some device_ids, some usernames)

## 📈 Current Statistics
- **Total alerts:** 234
- **With device_id format:** 175 
- **With username format:** 58 (growing as users register)
- **Migration progress:** 25% complete

## 🚀 Deployment Status
- **Mobile App:** Deployed to 3/4 devices
- **Latest APK:** https://ufobeep.com/downloads/ufobeep-latest.apk
- **API:** ✅ Running with all MP13 features
- **Database:** ✅ reporter_id column added and populated

## 🔮 Future Enhancements (Not Yet Implemented)
- Email verification for username persistence
- Cross-device username sync
- Password-based login
- Social login integration
- Username change feature
- Account deletion/GDPR compliance

## 🐛 Bug Reports
If you encounter issues, check:
1. App version matches latest deployment
2. Clear app cache/data if seeing old behavior
3. Check network connectivity for API calls
4. Reporter_id comparison uses exact string match

## Success Criteria
MP13 is complete when:
- ✅ All new users get usernames
- ✅ "I saw it too" works correctly  
- ✅ Alerts have proper attribution
- ✅ No skip registration option
- ✅ Progressive device_id → username migration