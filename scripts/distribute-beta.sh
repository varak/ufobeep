#!/bin/bash

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

echo -e "${YELLOW}Building UFOBeep Beta APK...${NC}"

# Navigate to app directory
cd "$(dirname "$0")/../app"

# Check if we're in the right directory
if [ ! -f "pubspec.yaml" ]; then
    echo -e "${RED}Error: pubspec.yaml not found. Are we in the Flutter app directory?${NC}"
    exit 1
fi

# Clean and get dependencies
echo -e "${YELLOW}Cleaning and getting dependencies...${NC}"
flutter clean
flutter pub get

# Build release APK
echo -e "${YELLOW}Building release APK...${NC}"
flutter build apk --release

# Check if build succeeded
if [ ! -f "build/app/outputs/flutter-apk/app-release.apk" ]; then
    echo -e "${RED}Build failed! APK not found.${NC}"
    exit 1
fi

# Get version from pubspec.yaml
VERSION=$(grep "version:" pubspec.yaml | cut -d ' ' -f 2 | cut -d '+' -f 1)
BUILD=$(grep "version:" pubspec.yaml | cut -d '+' -f 2)

echo -e "${GREEN}Built version ${VERSION}+${BUILD}${NC}"

# Get APK size
APK_SIZE=$(du -h "build/app/outputs/flutter-apk/app-release.apk" | cut -f1)
echo -e "${GREEN}APK size: ${APK_SIZE}${NC}"

# Get release notes
echo ""
echo "Enter release notes (or press Enter for default):"
read NOTES
if [ -z "$NOTES" ]; then
    NOTES="UFOBeep Beta v${VERSION} build ${BUILD} - $(date +%Y-%m-%d)"
fi

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}Firebase CLI not installed. Run: npm install -g firebase-tools${NC}"
    exit 1
fi

# Check if logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${YELLOW}Please login to Firebase first:${NC}"
    firebase login
fi

# Your Firebase App ID from google-services.json
FIREBASE_APP_ID="1:973986376996:android:0d843f4797938ad08c17b1"

# Upload to Firebase App Distribution
echo -e "${YELLOW}Uploading to Firebase App Distribution...${NC}"

firebase appdistribution:distribute "build/app/outputs/flutter-apk/app-release.apk" \
  --app "$FIREBASE_APP_ID" \
  --groups "beta-testers" \
  --release-notes "$NOTES"

if [ $? -eq 0 ]; then
    echo ""
    echo -e "${GREEN}✓ Successfully distributed to beta testers!${NC}"
    echo -e "${GREEN}✓ Testers will receive an email invitation${NC}"
    echo -e "${GREEN}✓ Version: ${VERSION}+${BUILD}${NC}"
    echo -e "${GREEN}✓ Size: ${APK_SIZE}${NC}"
    echo ""
    echo -e "${YELLOW}View distribution status:${NC}"
    echo "https://console.firebase.google.com/project/ufobeep-d685a/appdistribution"
else
    echo -e "${RED}Distribution failed!${NC}"
    exit 1
fi