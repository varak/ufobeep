# UFOBeep App - Beep Flow Design Notes

## Core App Purpose
**UFOBeep is about helping people see UFOs and alerting others when you see one.**

This is a **real-time alert system**, not a detailed documentation platform. The "beep" should be:
- **Fast** - Quick to send when you see something
- **Simple** - Minimal friction to alert others  
- **Location-based** - Help others in the area see what you're seeing

## Current Beep Flow Design (v2 - Single Page)

### Design Change Log
**Previous Flow (v1 - Modal System):**
```
Take Photo → Photo Approval → Modal with Form → Submit
```
- ❌ Confusing navigation
- ❌ Modal approval system was broken
- ❌ Users got stuck between screens

**Current Flow (v2 - Single Page):**
```
Take Photo → Single Composition Page → Send Beep!
```
- ✅ Clean single-page design
- ✅ Photo + form fields together  
- ✅ No confusing modals

### Current Composition Page Elements
- **Photo display** (proper aspect ratio, no distortion)
- **Title input** (required, min 5 chars)
- **Description input** (required, min 10 chars) 
- **Category selection** (UFO, aircraft, unknown, etc.)
- **Location privacy options**
- **"This photo will be sent with your beep" message**
- **Send Beep! button**

## Design Questions & Considerations

### Question 1: Is Category Selection Necessary?
**Current:** Dropdown with UFO, Aircraft, Meteorological, etc.
**Consideration:** For a quick "beep" alert, maybe this is overcomplicating?
- **Pro:** Helps classify sightings
- **Con:** Adds friction to quick alerts
- **Alternative:** Auto-default to "UFO" or "Unknown"?

### Question 2: Title & Description Requirements
**Current:** Both required with character minimums
**Consideration:** For real-time alerts, maybe too much?
- **Pro:** Provides context to other users
- **Con:** Slows down alert time when something is happening NOW
- **Alternative:** Optional title, very short description, or pre-filled defaults?

### Question 3: Quick Beep vs Detailed Report
**Core tension:** 
- **Quick Beep:** "Something is happening HERE NOW!" (photo + location)
- **Detailed Report:** Full documentation for later analysis

**Maybe we need both?**
- **Beep:** Minimal - just photo, location, timestamp
- **Report:** Detailed - full form, analysis, duration, etc.

## Technical Implementation Notes

### Key Files Changed
- `/app/lib/screens/beep/beep_composition_screen.dart` - New single-page design
- `/app/lib/widgets/simple_photo_display.dart` - Clean photo display
- `/app/lib/routing/app_router.dart` - New route for composition
- `/app/lib/screens/beep/beep_screen.dart` - Simplified, removed modal flow

### Navigation Flow
```dart
// After photo capture:
context.go('/beep/compose', extra: {
  'imageFile': submission.imageFile,
  'sensorData': sensorData,
  'planeMatch': planeMatch,
});
```

### Photo Handling
- Uses `BoxFit.contain` to prevent distortion
- Maintains aspect ratios for all orientations
- Clean container styling with proper borders

## Known Issues & Next Steps

See `bugs-and-issues.md` for detailed bug tracking.

**Major Concern:** Backend servers may not be running, causing submission failures regardless of UI quality.

## Future Design Iterations

### Potential v3 - Ultra-Simple Beep
```
Take Photo → Auto-send with location → Done
```
- Minimal UI, maximum speed
- Optional follow-up details later
- Focus on real-time alerting

### Potential Dual System
- **Quick Beep:** Photo + location (1 tap)
- **Detailed Report:** Full documentation (separate flow)

---
*Last updated: 2025-08-10*