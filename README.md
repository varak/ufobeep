# UFOBeep

Mobile app and API for real-time UFO sighting alerts ("beeps").

## 🚀 Current Status (September 2025)
- ✅ **Comments System Overhaul**: Auto-refresh, auto-follow, and smart navigation fully working
- ✅ **Multi-Device Testing**: Robust testing with moto/pixel/Claude's phone setup
- ✅ **Critical Bug Fixes**: Witness confirmation system stable and reliable
- ✅ **Production Deployment**: Live at ufobeep.com with real-time push notifications
- 📱 **Mobile Apps**: Android APK available for download

## 🎯 Key Features Working
- Real-time UFO sighting alerts with proximity detection
- Multi-media uploads (photos/videos) 
- Witness confirmation system ("I see it too" button)
- Comments and auto-follow on alerts
- Firebase push notifications
- Environmental context (weather, aircraft tracking)

## 📚 Documentation
- `docs/MASTER_PLAN_v16.md` - Current implementation roadmap
- `docs/ENDPOINTS.md` - API documentation with recent fixes
- `docs/DEPLOYMENT.md` - Production deployment guide

## 🔧 Recent Critical Fixes (September 2025)
- **Comments Auto-Refresh**: Frame-safe UI updates when viewing comments and someone else posts
- **Auto-Follow Reliability**: Retry logic ensures users viewing comments get followed for notifications
- **Smart Navigation**: "I see it too" now properly navigates to comments when conversation exists
- **Notification Delivery**: Direct database insertion for confirmation comments with proper notifications
- **Type Safety**: Set-based listener management prevents duplicate callback registrations
