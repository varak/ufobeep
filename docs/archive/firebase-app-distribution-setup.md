# Firebase App Distribution Setup for UFOBeep

## Step 1: Install Firebase CLI

```bash
# Install Firebase CLI globally
npm install -g firebase-tools

# Login to Firebase (opens browser)
firebase login

# Verify installation
firebase --version
```

## Step 2: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com)
2. Click "Create a project"
3. Name it: `ufobeep` or `ufobeep-app`
4. Disable Google Analytics (optional for now)
5. Click "Create Project"

## Step 3: Add Android App to Firebase

In Firebase Console:
1. Click the Android icon to add an Android app
2. Enter Android package name: `com.ufobeep.app` (check in `app/android/app/build.gradle`)
3. App nickname: "UFOBeep Beta"
4. Download `google-services.json`
5. Place it in `app/android/app/google-services.json`

## Step 4: Configure Flutter App for Firebase

### Add Firebase dependencies to Android

Edit `app/android/build.gradle`:
```gradle
buildscript {
    dependencies {
        // Add this line
        classpath 'com.google.gms:google-services:4.3.15'
    }
}
```

Edit `app/android/app/build.gradle`:
```gradle
// Add at the bottom
apply plugin: 'com.google.gms.google-services'
```

### Add Firebase Flutter packages

```bash
cd app
flutter pub add firebase_core
flutter pub add firebase_app_distribution
```

## Step 5: Initialize Firebase in Your Project

```bash
# In project root
firebase init

# Select:
# - "Hosting" (for later web hosting if needed)
# - Use existing project → select your Firebase project
# - Public directory: web/out (or build)
# - Single-page app: No
# - Automatic builds: No
```

## Step 6: Enable App Distribution

In Firebase Console:
1. Go to "Release & Monitor" → "App Distribution"
2. Click "Get Started"
3. Accept the terms

## Step 7: Install App Distribution Plugin

```bash
# Install the Firebase App Distribution plugin for CLI
cd app
flutter pub global activate flutterfire_cli
```

## Step 8: Build and Distribute Your App

### Option A: Using Firebase CLI (Recommended)

```bash
# Build your APK
cd app
flutter build apk --release

# Upload to Firebase App Distribution
firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "beta-testers" \
  --release-notes "Beta version $(date +%Y%m%d)"
```

### Option B: Using Gradle Plugin

Add to `app/android/app/build.gradle`:
```gradle
// Add plugin
apply plugin: 'com.google.firebase.appdistribution'

android {
    // ... existing config
    
    buildTypes {
        release {
            firebaseAppDistribution {
                artifactType = "APK"
                releaseNotes = "Beta release"
                groups = "beta-testers"
            }
        }
    }
}
```

Then distribute with:
```bash
cd app/android
./gradlew assembleRelease appDistributionUploadRelease
```

## Step 9: Create Tester Groups

In Firebase Console → App Distribution → Testers & Groups:
1. Click "Add group"
2. Name: "beta-testers"
3. Add tester emails (comma-separated)

## Step 10: Create Distribution Script

Create `scripts/distribute-beta.sh`:
```bash
#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building UFOBeep Beta APK...${NC}"

# Navigate to app directory
cd app

# Clean and get dependencies
flutter clean
flutter pub get

# Build release APK
flutter build apk --release

# Check if build succeeded
if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo "Build failed! APK not found."
    exit 1
fi

# Get version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
BUILD=$(grep "version:" pubspec.yaml | cut -d '+' -f 2)

echo -e "${GREEN}Built version ${VERSION}+${BUILD}${NC}"

# Get release notes
echo "Enter release notes (or press Enter for default):"
read NOTES
if [ -z "$NOTES" ]; then
    NOTES="UFOBeep Beta v${VERSION} build ${BUILD} - $(date +%Y-%m-%d)"
fi

# Upload to Firebase App Distribution
echo -e "${YELLOW}Uploading to Firebase App Distribution...${NC}"

firebase appdistribution:distribute build/app/outputs/flutter-apk/app-release.apk \
  --app YOUR_FIREBASE_APP_ID \
  --groups "beta-testers" \
  --release-notes "$NOTES"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✓ Successfully distributed to beta testers!${NC}"
    echo -e "${GREEN}Testers will receive an email invitation.${NC}"
else
    echo "Distribution failed!"
    exit 1
fi
```

Make it executable:
```bash
chmod +x scripts/distribute-beta.sh
```

## Step 11: Find Your Firebase App ID

1. Go to Firebase Console → Project Settings
2. Under "Your apps" → Android app
3. Copy the "App ID" (looks like: `1:123456789:android:abcdef123456`)
4. Replace `YOUR_FIREBASE_APP_ID` in scripts above

## Step 12: Invite Testers

When you run the distribution:
1. Testers get an email invitation
2. They click the link to accept
3. They download the Firebase App Tester app
4. They can install your beta directly

## Alternative: CI/CD Integration

Add to `.github/workflows/beta-release.yml`:
```yaml
name: Beta Release

on:
  push:
    tags:
      - 'beta-*'

jobs:
  build-and-distribute:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      
      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.x'
      
      - name: Build APK
        run: |
          cd app
          flutter build apk --release
      
      - name: Upload to Firebase App Distribution
        uses: wzieba/Firebase-Distribution-Github-Action@v1
        with:
          appId: ${{ secrets.FIREBASE_APP_ID }}
          serviceCredentialsFileContent: ${{ secrets.FIREBASE_SERVICE_ACCOUNT }}
          groups: beta-testers
          file: app/build/app/outputs/flutter-apk/app-release.apk
```

## Tester Experience

1. **First time testers**:
   - Receive email invitation
   - Download Firebase App Tester app
   - Accept invitation
   - Download and install beta

2. **Returning testers**:
   - Get notification in Firebase App Tester
   - One-tap update to new version

## Advantages over Direct APK Distribution

- ✅ Automatic updates notification
- ✅ No manual APK downloads
- ✅ Tester management dashboard
- ✅ Install analytics
- ✅ Crash reporting (if configured)
- ✅ Version history
- ✅ Professional beta testing flow

## Testing Your Setup

1. Build and distribute a test version:
```bash
./scripts/distribute-beta.sh
```

2. Add yourself as a tester in Firebase Console

3. Check your email for the invitation

4. Install and verify the app works

## Troubleshooting

### "App ID not found"
- Check the App ID in Firebase Console → Project Settings
- Ensure google-services.json is in app/android/app/

### "Authentication error"
```bash
firebase logout
firebase login
```

### "Build failed"
- Check Flutter doctor: `flutter doctor -v`
- Clean build: `cd app && flutter clean && flutter pub get`

## Next Steps

Once this is working:
1. Add crash reporting with Firebase Crashlytics
2. Add analytics to track feature usage
3. Set up automated builds on git tags
4. Create different tester groups (alpha, beta, internal)