# UFOBeep Sprint Task List - Pre-Play Store Release

**Created**: September 1, 2025  
**Status**: Planning Phase  
**Goal**: Address all critical issues before Play Store submission

## 🔴 **CRITICAL BUGS TO FIX**

### 1. **Multi-Media Initial Upload Bug** [Flutter + API]
- **Issue**: First alert creation fails if user selects >1 media file from gallery
- **Current**: Gallery allows multi-select but beep creation "shits itself"
- **Fix**: Implement proper multi-media handling on initial beep creation
- **Files**: `beep_screen.dart`, API `/alerts` endpoint
- **Acceptance**: User can select 3+ photos, all upload successfully on initial beep

### 2. **Share to Beep Feature** [Flutter]
- **Issue**: Share functionality not tested/working
- **Fix**: Test and fix share intent handling for creating beeps from external apps
- **Files**: `main.dart`, Android manifest for intent filters
- **Acceptance**: Share photo from gallery app → UFOBeep opens → creates beep

### 2b. **Long-Press Quick Camera Capture** [Flutter] ⭐ NEW
- **Feature**: Long-press app icon → quick camera capture → instant beep
- **Use Case**: "I need to capture this NOW and beep it" without navigation
- **Implementation**:
  - Android app shortcut for quick camera access
  - Direct camera screen launch bypassing main navigation
  - One-tap capture and submit workflow
  - Background location capture while camera is active
- **Files**: `main.dart`, Android manifest shortcuts, camera screen
- **Acceptance**: Long-press app icon → "Quick Beep" shortcut → camera opens → capture → auto-beeps with location

## 🟠 **PROFILE & SETTINGS ISSUES**

### 3. **DND/Quiet Hours Implementation** [Flutter + API]
- **Current**: UI exists but functionality incomplete
- **Fix**: Implement proper quiet hours time picker with start/end times
- **Add**: Backend support for respecting quiet hours in push notifications
- **Files**: `profile_screen.dart`, `push_notification_service.dart`
- **Acceptance**: Set quiet hours 10pm-7am → no push notifications during that time

### 4. **Units Setting (Metric/Imperial)** [Flutter]
- **Current**: Toggle exists but not applied throughout app
- **Fix**: Apply units conversion to all distance displays
- **Files**: `unit_conversion.dart`, all screens showing distances
- **Acceptance**: Toggle imperial → all distances show in miles/feet

### 5. **Language Setting** [Flutter]
- **Current**: Selector shows but doesn't change app language
- **Fix**: Implement proper i18n/localization support
- **Files**: Add localization files, update `main.dart`
- **Languages**: EN, ES, RU, ZH, JA, FR, DE, PT
- **Acceptance**: Change to Spanish → entire UI in Spanish

## 🟡 **UI CONSISTENCY & THEMING**

### 6. **Consistent Theming** [Flutter]
- **Issue**: Inconsistent colors/styles across screens
- **Fix**: Audit all screens for theme consistency
- **Standardize**: Button styles, text styles, colors
- **Acceptance**: Every button/text follows AppTheme standards

### 7. **Map Page Improvements** [Flutter]
- **Current**: Basic map functionality
- **Add**: Clustering for multiple alerts in same area
- **Fix**: Performance issues with many markers
- **Files**: `map_screen.dart`
- **Acceptance**: 100+ alerts on map → smooth performance with clustering

## 🟢 **SPRINT C ITEMS (Share Features)**

### 8. **Share Cards Implementation** [Web + API]
- **Add**: Open Graph tags for alert sharing
- **Create**: `/og/alerts/{id}.png` image generation endpoint
- **Files**: Web meta tags, new API endpoint
- **Acceptance**: Share link → shows preview card with image/title/description

### 9. **Language-Specific Share Platforms** [Flutter] ⭐ NEW
- **Modular Share System**: Different platforms per language/region
  
  **English (EN)**:
  - Twitter/X
  - Facebook
  - Reddit (r/UFOs, r/HighStrangeness)
  - WhatsApp
  - Telegram
  
  **Spanish (ES)**:
  - WhatsApp (primary in LATAM)
  - Facebook
  - Twitter/X
  - Telegram groups
  - Regional platforms (varies by country)
  
  **Russian (RU)**:
  - VKontakte (VK)
  - Telegram (primary)
  - Odnoklassniki (OK)
  - WhatsApp
  
  **Chinese (ZH)**:
  - WeChat
  - Weibo
  - QQ
  - Douyin/TikTok
  
  **Japanese (JA)**:
  - LINE (primary)
  - Twitter/X (very popular)
  - Instagram
  
  **Portuguese (PT)**:
  - WhatsApp (primary in Brazil)
  - Facebook
  - Instagram
  - Twitter/X
  
  **Implementation**:
  - Create `share_platforms.dart` with language mappings
  - Dynamic share menu based on user language
  - Include platform-specific formatting/hashtags
  - Regional UFO community hashtags per language

### 10. **Share→Compose Reliability** [Flutter]
- **Fix**: singleTask launch mode
- **Add**: onNewIntent handling
- **Implement**: Persisted pending share state
- **Files**: Android manifest, `main.dart`
- **Acceptance**: Share from any app → UFOBeep handles correctly

## 🔵 **SPRINT D ITEMS (Operations)**

### 11. **Map Clustering** [Flutter]
- **Add**: Cluster nearby alerts on map
- **Improve**: Map performance with many points
- **Files**: `map_screen.dart`, clustering library
- **Acceptance**: Zoom out → see cluster numbers, zoom in → clusters expand

### 12. **Field Diagnostic Screen** [Flutter]
- **Create**: Debug screen for field testing
- **Show**: Device info, sensor status, API connectivity
- **Add**: Log viewer for troubleshooting
- **Acceptance**: One screen shows all diagnostic info

### 13. **Sentry Integration** [Flutter + API + Web]
- **Add**: Error tracking and monitoring
- **Configure**: For all platforms
- **Setup**: Alerts for critical errors
- **Acceptance**: Error in production → team gets notified

## 📋 **ADDITIONAL IMPROVEMENTS**

### 14. **CI/CD Pipeline** [DevOps]
- **Setup**: GitHub Actions for automated testing
- **Add**: Automated APK builds on push
- **Configure**: Deployment automation
- **Acceptance**: Push to main → APK auto-builds

### 15. **NSFW Content Detection** [API + Flutter] ⭐ NEW
- **Feature**: Automatic detection and filtering of inappropriate uploaded content
- **Implementation**:
  - Server-side image analysis using ML model (TensorFlow/PyTorch)
  - Flag NSFW images before they reach other users
  - Quarantine system for flagged content
  - Admin review interface for false positives
  - User reporting system for missed content
- **Files**: API content moderation endpoints, upload pipeline
- **Acceptance**: Upload inappropriate image → gets flagged → doesn't appear in public alerts

### 16. **Play Store Preparation** [Flutter]
- **Fix**: All critical bugs above
- **Update**: App metadata and descriptions
- **Generate**: Release signing keys
- **Create**: Store listing in multiple languages
- **Screenshots**: For each supported language
- **Test**: On multiple devices and Android versions

## 📊 **Priority Order**

**Week 1 - Critical Fixes**:
1. Fix multi-media upload bug (CRITICAL)
2. Fix share to beep feature (CRITICAL)

**Week 2 - User Settings**:
3. DND/quiet hours implementation
4. Units setting functionality
5. Language setting with i18n

**Week 3 - Polish & Sharing**:
6. UI consistency audit
7. Language-specific share platforms
8. Share cards with OG tags

**Week 4 - Operations**:
9. Map improvements & clustering
10. Field diagnostic screen
11. Sentry integration

**Week 5 - Release Prep**:
12. CI/CD pipeline
13. Play Store preparation
14. Multi-language store listings

## 🎯 **Success Metrics**

- [ ] Zero crash rate for 48 hours
- [ ] All settings actually work
- [ ] Share feature works in all languages
- [ ] Map handles 500+ alerts smoothly
- [ ] Successful test on 10+ different devices
- [ ] Store listing ready in 5+ languages

## 📝 **Notes**

- Each task indicates [Flutter], [API], [Web], or [DevOps] to show where changes are needed
- Language-specific sharing is crucial for viral growth in different regions
- Consider regional UFO communities and their preferred platforms
- Some platforms (WeChat, VK) may need special SDK integrations