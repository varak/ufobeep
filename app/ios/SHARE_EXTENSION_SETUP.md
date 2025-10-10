# iOS Share Extension Setup

This guide will add UFOBeep to the iOS share sheet so users can share photos/videos directly from other apps.

## Steps to Add Share Extension in Xcode

### 1. Create Share Extension Target

1. Open `ios/Runner.xcworkspace` in Xcode
2. File → New → Target
3. Select "Share Extension" template
4. Name it: `UFOBeepShareExtension`
5. Bundle ID: `com.ufobeep.app.ShareExtension`
6. Language: Swift
7. Click Finish
8. When prompted "Activate scheme?", click **Cancel** (keep Runner as active scheme)

### 2. Configure App Groups (for data sharing)

**In Runner target:**
1. Select Runner target → Signing & Capabilities
2. Click "+ Capability" → Add "App Groups"
3. Check or add: `group.com.ufobeep.app`

**In UFOBeepShareExtension target:**
1. Select UFOBeepShareExtension target → Signing & Capabilities
2. Click "+ Capability" → Add "App Groups"
3. Check: `group.com.ufobeep.app` (same group)

### 3. Replace ShareViewController.swift

Replace `UFOBeepShareExtension/ShareViewController.swift` with the file at:
`ios/UFOBeepShareExtension/ShareViewController.swift`

### 4. Update Info.plist

Replace `UFOBeepShareExtension/Info.plist` with the file at:
`ios/UFOBeepShareExtension/Info.plist`

### 5. Build & Run

1. Select Runner scheme (not ShareExtension)
2. Build for your device
3. Test by going to Photos app → Select photo → Share → UFOBeep should appear!

## How It Works

1. User taps Share in Photos/Safari/etc
2. UFOBeep appears in share sheet
3. User taps UFOBeep icon
4. Extension saves photo to shared container
5. Extension opens main app with deep link
6. Main app loads photo and opens beep screen

## Troubleshooting

**Share extension doesn't appear:**
- Make sure both targets have the same App Group enabled
- Reinstall the app completely (delete first)
- Check Info.plist activation rules (should accept images/videos)

**App doesn't open from extension:**
- Verify URL scheme `ufobeep://` is configured in Runner
- Check deep link handling in `AppDelegate.swift`
