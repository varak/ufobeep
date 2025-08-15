# iOS TestFlight Setup Guide

## Overview
This guide helps you distribute UFOBeep iOS app to iPhone users via Apple's TestFlight, using GitHub Actions for building since you don't have a Mac.

## Prerequisites

### 1. Apple Developer Account
- **Cost**: $99/year
- **Sign up**: https://developer.apple.com/programs/
- **Requirements**: Just need an Apple ID

### 2. App Store Connect Setup
After getting developer account:

1. **Go to**: https://appstoreconnect.apple.com/
2. **Create new app**:
   - Platform: iOS
   - Name: UFOBeep
   - Bundle ID: `com.ufobeep.ufobeep`
   - Language: English
   - SKU: `ufobeep-ios`
3. **Enable TestFlight** for the app

## GitHub Actions Setup

### Method 1: Unsigned Build (Easier Start)
Use the `ios-build-only.yml` workflow:

1. **Run workflow** in GitHub Actions tab
2. **Download IPA** from artifacts
3. **Manual signing** needed (requires Mac access or online service)

### Method 2: Full Automated (Advanced)
Use the `ios-testflight.yml` workflow with these GitHub secrets:

#### Required Secrets:
Add these to your GitHub repository settings → Secrets and variables → Actions:

1. **`BUILD_CERTIFICATE_BASE64`**
   - Export your Apple distribution certificate as .p12
   - Convert to base64: `base64 -i certificate.p12 | pbcopy`

2. **`P12_PASSWORD`**
   - Password for the .p12 certificate

3. **`BUILD_PROVISION_PROFILE_BASE64`**
   - Download provisioning profile from developer.apple.com
   - Convert to base64: `base64 -i profile.mobileprovision | pbcopy`

4. **`KEYCHAIN_PASSWORD`**
   - Any secure password for temporary keychain

5. **`DEVELOPMENT_TEAM`**
   - Your Apple Team ID (found in developer account)

6. **`EXPORT_OPTIONS_PLIST`**
   - Base64 encoded export options file (see template below)

7. **`APPSTORE_API_KEY_ID`**
   - App Store Connect API key ID

8. **`APPSTORE_API_ISSUER_ID`**
   - App Store Connect API issuer ID

9. **`APPSTORE_API_PRIVATE_KEY`**
   - Base64 encoded App Store Connect API private key

#### ExportOptions.plist Template:
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>destination</key>
    <string>upload</string>
    <key>method</key>
    <string>app-store</string>
    <key>teamID</key>
    <string>YOUR_TEAM_ID</string>
    <key>uploadBitcode</key>
    <false/>
    <key>uploadSymbols</key>
    <true/>
</dict>
</plist>
```

## App Store Connect API Setup

1. **Go to**: https://appstoreconnect.apple.com/access/api
2. **Generate API Key**:
   - Name: "GitHub Actions UFOBeep"
   - Access: "Developer"
   - Download the .p8 file
3. **Note down**:
   - Key ID
   - Issuer ID
   - Save the .p8 file content

## iOS App Configuration

### Update Bundle Identifier
Edit `app/ios/Runner/Info.plist`:
```xml
<key>CFBundleIdentifier</key>
<string>com.ufobeep.ufobeep</string>
```

### Firebase iOS Setup
1. **Firebase Console**: https://console.firebase.google.com/u/1/project/ufobeep
2. **Add iOS app**:
   - Bundle ID: `com.ufobeep.ufobeep`
   - App nickname: "UFOBeep iOS"
3. **Download GoogleService-Info.plist**
4. **Add to**: `app/ios/Runner/GoogleService-Info.plist`

## Testing Workflow

### Option A: Start Simple (Recommended)
1. **Run "Build iOS App (Manual Upload)"** workflow
2. **Download unsigned IPA** from artifacts
3. **Use online signing service** or find Mac user to sign
4. **Manually upload** to App Store Connect

### Option B: Full Automation
1. **Complete all setup steps above**
2. **Run "Build and Deploy iOS to TestFlight"** workflow
3. **Check TestFlight** in App Store Connect
4. **Add testers** and distribute

## TestFlight Distribution

### Add Testers:
1. **App Store Connect** → Your App → TestFlight
2. **Internal Testing** (up to 100 users)
   - Add by email
   - Instant access
3. **External Testing** (up to 10,000 users)
   - Requires Apple review (1-3 days)
   - Public link available

### Tester Experience:
1. **Install TestFlight** app from App Store
2. **Tap invitation link** or use invitation code
3. **Install UFOBeep** directly from TestFlight
4. **Receive update notifications** automatically

## Troubleshooting

### Common Issues:
- **Certificate errors**: Ensure valid distribution certificate
- **Provisioning profile**: Must match bundle ID and certificate
- **Team ID mismatch**: Verify in Apple Developer account
- **API key permissions**: Ensure "Developer" access level

### GitHub Actions Debugging:
- **Check workflow logs** for specific error messages
- **Verify secrets** are properly base64 encoded
- **Test locally** with similar commands if you get Mac access

## Cost Breakdown
- **Apple Developer Account**: $99/year
- **GitHub Actions**: Free (2000 minutes/month)
- **TestFlight**: Free
- **Total**: $99/year

## Next Steps
1. **Get Apple Developer account**
2. **Choose setup method** (simple vs automated)
3. **Configure iOS app** bundle ID and Firebase
4. **Run GitHub workflow**
5. **Set up TestFlight** and add your iPhone friend as tester!