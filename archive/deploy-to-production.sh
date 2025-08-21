#!/bin/bash

# UFOBeep Production Deployment Script
# Pushes code changes and SCPs APK to production

echo "🚀 UFOBEEP PRODUCTION DEPLOYMENT"
echo "=================================="
echo

# Configuration
PROD_HOST="ufobeep@ufobeep.com"
PROD_PORT="322"
PROD_WEB_DIR="/home/ufobeep/ufobeep/web/public/downloads"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

# Step 1: Commit and push code changes
echo "📝 Step 1: Git Operations"
echo "-------------------------"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected${NC}"
    git status -s
    echo
    read -p "Commit these changes? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        read -p "Enter commit message: " commit_msg
        git add .
        git commit -m "$commit_msg"
    fi
fi

# Push to origin
echo "Pushing to origin..."
git push origin main

echo -e "${GREEN}✅ Code pushed to GitHub${NC}"
echo

# Step 2: Deploy APK if exists
echo "📱 Step 2: APK Deployment"
echo "-------------------------"

# Find latest APK
if [ -f "app/build/app/outputs/flutter-apk/app-release.apk" ]; then
    APK_PATH="app/build/app/outputs/flutter-apk/app-release.apk"
    APK_TYPE="release"
elif [ -f "app/build/app/outputs/flutter-apk/app-debug.apk" ]; then
    APK_PATH="app/build/app/outputs/flutter-apk/app-debug.apk"
    APK_TYPE="debug"
else
    echo -e "${YELLOW}⚠️  No APK found to deploy${NC}"
    APK_PATH=""
fi

if [ -n "$APK_PATH" ]; then
    APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
    echo "Found APK: $APK_PATH ($APK_SIZE)"
    echo
    
    read -p "Deploy this APK to production? (y/n): " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Yy]$ ]]; then
        echo "Uploading APK to production..."
        
        # Copy with both versioned and latest names
        scp -P $PROD_PORT "$APK_PATH" "$PROD_HOST:$PROD_WEB_DIR/ufobeep-$APK_TYPE.apk"
        ssh -p $PROD_PORT $PROD_HOST "cd $PROD_WEB_DIR && cp ufobeep-$APK_TYPE.apk ufobeep-latest.apk"
        
        echo -e "${GREEN}✅ APK deployed to production${NC}"
        echo "   Download URL: https://ufobeep.com/downloads/ufobeep-latest.apk"
    fi
fi

echo

# Step 3: Pull changes on production server
echo "🔄 Step 3: Update Production Server"
echo "------------------------------------"

echo "Connecting to production server..."

ssh -p $PROD_PORT $PROD_HOST << 'ENDSSH'
    echo "Updating API code..."
    cd /var/www/ufobeep.com/html
    git pull origin main
    
    echo "Updating web app..."
    cd /home/ufobeep/ufobeep/web
    git pull origin main
    npm install
    npm run build
    pm2 restart ufobeep-web
    
    echo "Restarting API service..."
    sudo systemctl restart ufobeep-api
    
    echo "✅ Production server updated"
ENDSSH

echo
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
echo
echo "Next steps:"
echo "1. Test the website: https://ufobeep.com"
echo "2. Test the API: https://api.ufobeep.com/healthz"
echo "3. Test APK download: https://ufobeep.com/downloads/ufobeep-latest.apk"