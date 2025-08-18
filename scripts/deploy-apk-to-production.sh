#!/bin/bash

# UFOBeep APK Deployment Script
# Deploys latest APK to production and updates website

echo "🚀 UFOBEEP APK DEPLOYMENT TO PRODUCTION"
echo "======================================="
echo

# Configuration
PROD_HOST="ufobeep@ufobeep.com"
PROD_PORT="322"
PROD_WEB_DIR="/home/ufobeep/ufobeep/web/public/downloads"
LOCAL_APK_PATH=""
APK_VERSION="latest"
APK_DATE=$(date +%Y%m%d)

# Color codes
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Find the latest APK
echo "🔍 Searching for latest APK..."

# Check common locations for APK
if [ -f "app/build/app/outputs/flutter-apk/app-release.apk" ]; then
    LOCAL_APK_PATH="app/build/app/outputs/flutter-apk/app-release.apk"
    APK_VERSION="release"
elif [ -f "app/build/app/outputs/flutter-apk/app-debug.apk" ]; then
    LOCAL_APK_PATH="app/build/app/outputs/flutter-apk/app-debug.apk"
    APK_VERSION="debug"
elif [ -f "app/build/outputs/apk/debug/app-debug.apk" ]; then
    LOCAL_APK_PATH="app/build/outputs/apk/debug/app-debug.apk"
    APK_VERSION="debug"
elif [ -f "app-debug.apk" ]; then
    LOCAL_APK_PATH="app-debug.apk"
    APK_VERSION="debug"
else
    echo -e "${RED}❌ No APK found! Please build the app first.${NC}"
    echo "Run: cd app && flutter build apk"
    exit 1
fi

echo -e "${GREEN}✅ Found APK: $LOCAL_APK_PATH${NC}"
echo

# Get APK size
APK_SIZE=$(ls -lh "$LOCAL_APK_PATH" | awk '{print $5}')
echo "📦 APK Size: $APK_SIZE"
echo

# Rename APK for production
PROD_APK_NAME="ufobeep-${APK_VERSION}-${APK_DATE}.apk"
PROD_APK_LATEST="ufobeep-latest.apk"

echo "📤 Deploying APK to production..."
echo "   Server: $PROD_HOST"
echo "   Port: $PROD_PORT"
echo "   Destination: $PROD_WEB_DIR"
echo

# Copy APK to production with both timestamped and latest versions
echo "Uploading $PROD_APK_NAME..."
scp -P $PROD_PORT "$LOCAL_APK_PATH" "$PROD_HOST:$PROD_WEB_DIR/$PROD_APK_NAME"

if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ APK uploaded successfully!${NC}"
    
    # Create symlink to latest version
    echo "Creating latest symlink..."
    ssh -p $PROD_PORT $PROD_HOST "cd $PROD_WEB_DIR && ln -sf $PROD_APK_NAME $PROD_APK_LATEST"
    
    echo -e "${GREEN}✅ Symlink created!${NC}"
else
    echo -e "${RED}❌ Failed to upload APK${NC}"
    exit 1
fi

echo
echo "🌐 DOWNLOAD URLS:"
echo "   Latest: https://ufobeep.com/downloads/$PROD_APK_LATEST"
echo "   Versioned: https://ufobeep.com/downloads/$PROD_APK_NAME"
echo

echo -e "${GREEN}🎉 APK DEPLOYMENT COMPLETE!${NC}"
echo
echo "Next steps:"
echo "1. Update the website download page with installation instructions"
echo "2. Test the download link"
echo "3. Announce the new version to users"