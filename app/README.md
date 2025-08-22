# UFOBeep Flutter App

Flutter mobile app for instant UFO sighting alerts and media sharing.

## Recent Fixes (Aug 21, 2025)
- ✅ Fixed "future not complete" sensor errors on tablets without magnetometer
- ✅ Fixed permission hanging at 25% initialization with timeout handling  
- ✅ Optimized sensor detection with accelerometer-only mode for limited devices
- ✅ Added timeout protection for all permission requests
- ✅ Release builds now start in 3-5 seconds vs 23 seconds for debug builds

## Building
- **Debug**: `flutter build apk --debug` (development, slower)
- **Release**: `flutter build apk --release` (production, faster)

## Deployment
Release builds are automatically deployed to production via the deploy script.