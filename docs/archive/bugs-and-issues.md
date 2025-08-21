# UFOBeep - Bug Tracking & Issues

## Critical Issues (Blocking Core Functionality)

### 🚨 BUG-001: Beep Submission Not Working
**Status:** ACTIVE  
**Priority:** P0 - Critical  
**Description:** Users can take photos and fill out form, but beep submission fails
**Symptoms:**
- User takes photo successfully
- Form displays and can be filled out
- "Send Beep!" button activates but submission doesn't work
- User reports "it still doesn't work" after multiple fix attempts

**Potential Root Causes:**
1. **Backend servers not running** - Most likely cause
2. API endpoint misconfiguration
3. Network connectivity issues on device
4. Authentication/authorization problems
5. Image upload pipeline broken

**Investigation Needed:**
- [ ] Check if backend API is running and accessible
- [ ] Test API endpoints manually (curl/postman)
- [ ] Check app logs for network errors
- [ ] Verify API client configuration

---

### 🚨 BUG-002: Backend Infrastructure Status Unknown
**Status:** ACTIVE  
**Priority:** P0 - Critical  
**Description:** Backend servers may not be deployed/running
**Impact:** All beep submissions would fail regardless of mobile app quality
**Evidence:**
- Multiple UI fixes haven't resolved submission issues
- User still cannot complete beep flow
- Production setup scripts exist but deployment status unclear

**Action Required:**
- [ ] Verify backend deployment status
- [ ] Check API health endpoints
- [ ] Ensure database connectivity
- [ ] Validate production environment setup

---

## UI/UX Issues

### 🐛 BUG-003: Oversized Message Obscuring Opening Screen Buttons
**Status:** ACTIVE  
**Priority:** P1 - High  
**Description:** Opening screen has oversized message that blocks/obscures action buttons
**Impact:** Users can't access main app functionality
**User Report:** "oversize message obscuring the buttons"
**Action Required:**
- [ ] Identify oversized message component on opening screen
- [ ] Resize or reposition message to not block buttons
- [ ] Test on various screen sizes

---

### 🐛 BUG-004: Registration Legal Agreement UX Problems  
**Status:** ACTIVE  
**Priority:** P1 - High  
**Description:** Legal agreement on registration page has poor UX
**Issues:**
1. Legal agreement text is "easy to miss"
2. No clear indication that checkboxes are required
3. Users don't understand they must click both boxes to proceed

**User Report:** "nothing says you have to click those two boxes, but you have too"
**Action Required:**
- [ ] Make legal agreement more prominent/visible
- [ ] Add clear labels indicating required fields
- [ ] Add validation messaging for unchecked boxes
- [ ] Consider visual emphasis (asterisks, colors, etc.)

---

### 🐛 BUG-005: Flutter Default App Icon  
**Status:** ACTIVE  
**Priority:** P2 - Moderate  
**Description:** App still uses default Flutter icon instead of UFO-themed icon
**User Report:** "I really hate the flutter icon on the install, can we add a ufo to that icon instead"
**Action Required:**
- [ ] Design or find UFO-themed app icon
- [ ] Replace default Flutter icon in Android/iOS app configurations
- [ ] Test icon appears correctly on device

---

### 🐛 BUG-006: New Beep Screen Not Loading  
**Status:** ACTIVE  
**Priority:** P0 - Critical  
**Description:** New single-page beep composition screen not showing, old modal still appears
**User Report:** "none of these changes are showing up" - still seeing old photo modal
**Evidence:** Despite redesign, users still see old photo approval modal instead of new composition page
**Action Required:**
- [ ] Verify new BeepCompositionScreen route is properly configured
- [ ] Check navigation after photo capture goes to correct screen
- [ ] Remove all old modal code completely
- [ ] Add debugging to verify which screen loads

---

### 🐛 BUG-007: Backend Connectivity Required for Core Functionality  
**Status:** ACTIVE  
**Priority:** P0 - Critical  
**Description:** App cannot function without backend, needs fallback handling
**User Report:** "Address that the back end isn't working because this can't work if that doesnt. This must be a fall back if the back end is broken"
**Impact:** App appears broken to users when backend is down
**Action Required:**
- [ ] Add offline mode/fallback when backend unavailable
- [ ] Store beeps locally when server unreachable
- [ ] Show clear messaging about connectivity issues
- [ ] Implement retry mechanism when connection restored

---

## Design Questions (May Affect User Experience)

### 🤔 DESIGN-001: Beep Flow Complexity
**Status:** UNDER REVIEW  
**Priority:** P2 - Moderate  
**Description:** Current beep flow may be too complex for "quick alerts"
**Current Flow:** Photo → Title + Description + Category → Submit
**Concern:** This contradicts "quick beep" concept

**Core App Purpose Reminder:**
> "This app is about helping other people see UFOs and seeing one yourself"  
> "It's time to beep, not document!"

**Potential Solutions:**
1. **Ultra-simple beep:** Photo + location only, auto-submit
2. **Two-tier system:** Quick beep vs. detailed report  
3. **Progressive disclosure:** Send beep first, add details later

---

### 🤔 DESIGN-002: Category Selection Necessity
**Status:** UNDER REVIEW  
**Priority:** P3 - Low  
**Description:** Sighting category dropdown may add unnecessary friction
**Question:** Do users need to categorize during urgent sighting moments?
**Options:**
- Remove category selection entirely
- Auto-default to "UFO sighting"  
- Make it optional/post-submission

---

## Fixed Issues (For Reference)

### ✅ FIXED-001: IconData Type Casting Error
**Status:** RESOLVED  
**Description:** "String is not a subtype of type IconData" error in category selection
**Solution:** Updated category selection to handle String emoji icons properly
**Fixed in:** Commit b0d69c3

### ✅ FIXED-002: Modal Navigation Issues  
**Status:** RESOLVED  
**Description:** Complex modal approval flow was confusing users
**Solution:** Redesigned to single-page composition screen
**Fixed in:** Latest redesign

### ✅ FIXED-003: Flutter Compilation Errors
**Status:** RESOLVED  
**Description:** Multiple compilation errors preventing Android builds
**Solution:** Fixed AsyncValue handling, nullable types, missing icons
**Fixed in:** Commit b0d69c3

---

## Investigation Tasks

### 🔍 INVESTIGATION-001: Backend Health Check
**Assigned:** Next priority  
**Tasks:**
- [ ] Check production server status at ufobeep.com/api.ufobeep.com
- [ ] Test API endpoints: GET /health, POST /sightings
- [ ] Verify database connectivity
- [ ] Check Docker containers status
- [ ] Review server logs for errors

### 🔍 INVESTIGATION-002: Mobile App Network Debugging
**Priority:** After backend verification  
**Tasks:**
- [ ] Add network logging to mobile app
- [ ] Test on different networks (WiFi vs mobile)
- [ ] Verify API endpoint URLs in app configuration
- [ ] Check SSL certificate issues

---

## Next Steps Recommendation

**Priority Order:**
1. **Backend Infrastructure** - Verify/fix server deployment first
2. **API Testing** - Ensure endpoints work independently  
3. **Mobile App Network** - Debug client-side issues
4. **UX Simplification** - Consider ultra-simple beep flow

**Rationale:** No amount of UI fixes will help if the backend isn't running. Let's solve the infrastructure first, then return to UX improvements.

---
*Last updated: 2025-08-10*  
*Next review: After backend verification*