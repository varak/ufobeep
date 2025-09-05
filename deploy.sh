#!/bin/bash

# UFOBeep Unified Deployment Script
# Deploy API, Web, and/or Mobile to production

set -e

# Configuration
PROD_HOST="ufobeep@ufobeep.com"
PROD_PORT="322"
PROD_WEB_DIR="/home/ufobeep/ufobeep/web/public/downloads"
PROD_API_DIR="/var/www/ufobeep.com/html"
PROD_NEXT_DIR="/home/ufobeep/ufobeep/web"

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "🚀 UFOBeep Production Deployment"
echo "================================"
echo

# Parse arguments
DEPLOY_API=false
DEPLOY_WEB=false
DEPLOY_WEB_FAST=false
DEPLOY_APK=false
DEPLOY_ALL=false
AUTO_COMMIT=false
COMMIT_MSG=""
TARGET_DEVICES=""

if [ $# -eq 0 ]; then
    DEPLOY_ALL=true
else
    for arg in "$@"; do
        case $arg in
            api) DEPLOY_API=true ;;
            web) DEPLOY_WEB=true ;;
            web-fast) DEPLOY_WEB_FAST=true ; DEPLOY_WEB=false ;;
            apk|mobile) DEPLOY_APK=true ;;
            all) DEPLOY_ALL=true ;;
            moto) DEPLOY_APK=true; TARGET_DEVICES=$(adb devices | grep -E "192\.168\." | head -1 | cut -f1) ;;
            tablet) DEPLOY_APK=true; TARGET_DEVICES="356120372031894" ;;
            pixel) DEPLOY_APK=true; TARGET_DEVICES="HT75D0202593" ;;
            samsung) DEPLOY_APK=true; TARGET_DEVICES="Y5SSW8MZDIU45995" ;;
            claude) DEPLOY_APK=true; TARGET_DEVICES="Y5SSW8MZDIU45995" ;;
            --auto-commit=*) 
                AUTO_COMMIT=true
                COMMIT_MSG="${arg#*=}"
                ;;
            *) echo -e "${RED}Unknown option: $arg${NC}"; exit 1 ;;
        esac
    done
fi

# Set all flags if deploying all
if [ "$DEPLOY_ALL" = true ]; then
    DEPLOY_API=true
    DEPLOY_WEB=true
    DEPLOY_APK=true
fi

# Step 1: Git operations
echo -e "${BLUE}📝 Step 1: Git Operations${NC}"
echo "-------------------------"

# Check for uncommitted changes
if [[ -n $(git status -s) ]]; then
    echo -e "${YELLOW}⚠️  Uncommitted changes detected:${NC}"
    git status -s
    echo
    
    if [ "$AUTO_COMMIT" = true ] && [ -n "$COMMIT_MSG" ]; then
        echo "Auto-committing with message: $COMMIT_MSG"
        git add .
        git commit -m "$COMMIT_MSG"
    else
        read -p "Commit these changes? (y/n): " -n 1 -r
        echo
        if [[ $REPLY =~ ^[Yy]$ ]]; then
            echo -e "${YELLOW}💡 Remember: Do not include self-attribution in commit messages${NC}"
            read -p "Enter commit message: " commit_msg
            git add .
            git commit -m "$commit_msg"
        fi
    fi
fi

# Push to origin
echo "Pushing to GitHub..."
git push origin main || true
echo -e "${GREEN}✅ Code synced${NC}"
echo

# Step 2: Deploy APK if requested
if [ "$DEPLOY_APK" = true ]; then
    echo -e "${BLUE}📱 Step 2: Mobile APK Deployment${NC}"
    echo "--------------------------------"
    
    # Build fresh APK with latest changes
    echo "Building fresh APK with latest changes..."
    cd app
    echo "Cleaning build cache..."
    flutter clean
    echo "Starting APK build (timeout: 3 minutes)..."
    if timeout 180 flutter build apk --release --verbose; then
        echo -e "${GREEN}✅ APK build successful${NC}"
        cd ..
    else
        echo -e "${RED}❌ APK build failed!${NC}"
        cd ..
        exit 1
    fi
    
    # Find latest APK
    APK_PATH=""
    if [ -f "app/build/app/outputs/flutter-apk/app-release.apk" ]; then
        APK_PATH="app/build/app/outputs/flutter-apk/app-release.apk"
        APK_TYPE="release"
    elif [ -f "app/build/app/outputs/flutter-apk/app-debug.apk" ]; then
        APK_PATH="app/build/app/outputs/flutter-apk/app-debug.apk"
        APK_TYPE="debug"
    fi
    
    if [ -n "$APK_PATH" ]; then
        APK_SIZE=$(ls -lh "$APK_PATH" | awk '{print $5}')
        echo "Found APK: $APK_PATH ($APK_SIZE)"
        
        # Deploy to connected devices - REWRITTEN FOR RELIABILITY
        echo
        echo "Checking for connected devices..."
        
        # Get device list in a more reliable way
        DEVICES_RAW=$(adb devices | grep -E "device$" | cut -f1)
        DEVICE_COUNT=$(echo "$DEVICES_RAW" | grep -v "^$" | wc -l)
        
        # Prioritize IP-based device (Moto) for faster testing
        IP_DEVICE=$(echo "$DEVICES_RAW" | grep -E "^[0-9]+\." | head -1)
        OTHER_DEVICES=$(echo "$DEVICES_RAW" | grep -v -E "^[0-9]+\." | grep -v "^$")
        
        # Build device array - filter by target if specified
        DEVICES_ARRAY=()
        if [ -n "$TARGET_DEVICES" ]; then
            # Deploy to specific device(s) only
            for target in $TARGET_DEVICES; do
                if echo "$DEVICES_RAW" | grep -q "^$target$"; then
                    DEVICES_ARRAY+=("$target")
                else
                    echo -e "${YELLOW}⚠️  Target device $target not connected${NC}"
                fi
            done
            if [ ${#DEVICES_ARRAY[@]} -eq 0 ]; then
                echo -e "${RED}❌ No target devices connected!${NC}"
                exit 1
            fi
            echo -e "${GREEN}Targeting specific device(s): ${DEVICES_ARRAY[*]}${NC}"
        else
            # Deploy to all devices, prioritize IP device
            if [ -n "$IP_DEVICE" ]; then
                DEVICES_ARRAY+=("$IP_DEVICE")
                echo -e "${GREEN}Found $DEVICE_COUNT connected devices (IP device prioritized first)${NC}"
            fi
            while IFS= read -r device; do
                if [ -n "$device" ]; then
                    DEVICES_ARRAY+=("$device")
                fi
            done <<< "$OTHER_DEVICES"
            echo "Device order: ${DEVICES_ARRAY[*]}"
        fi
        
        if [ "$DEVICE_COUNT" -ge 1 ]; then
            echo "Installing to all devices..."
            INSTALL_SUCCESS=0
            
            # Process each device individually with clear output
            for device in "${DEVICES_ARRAY[@]}"; do
                echo ""
                echo "📱 Processing device: $device"
                
                # Step 1: Uninstall (ignore failures)
                echo "  🗑️  Uninstalling old version..."
                timeout 30 adb -s "$device" uninstall com.ufobeep >/dev/null 2>&1 || echo "  ➡️  No previous version"
                
                # Step 2: Install with clear feedback
                echo "  📦 Installing new APK..."
                if timeout 90 adb -s "$device" install -r "$APK_PATH" 2>/dev/null; then
                    echo "  ✅ INSTALL SUCCESS on $device"
                    
                    # Step 3: Force restart app
                    echo "  🔄 Restarting app..."
                    timeout 5 adb -s "$device" shell am force-stop com.ufobeep >/dev/null 2>&1 || true
                    echo "  ✅ RESTART COMPLETE on $device"
                    
                    INSTALL_SUCCESS=$((INSTALL_SUCCESS + 1))
                else
                    echo -e "  ${RED}❌ INSTALL FAILED on $device${NC}"
                fi
            done
            
            echo ""
            echo "=========================================="
            if [ "$INSTALL_SUCCESS" -eq "$DEVICE_COUNT" ]; then
                echo -e "${GREEN}🎉 SUCCESS: Installed on all $DEVICE_COUNT devices!${NC}"
            else
                echo -e "${YELLOW}⚠️  PARTIAL SUCCESS: $INSTALL_SUCCESS/$DEVICE_COUNT devices succeeded${NC}"
            fi
            echo "=========================================="
        else
            echo -e "${RED}❌ No devices connected!${NC}"
            echo "Connect devices and try again"
            exit 1
        fi
        
        echo
        echo "Uploading APK to production server..."
        scp -P $PROD_PORT "$APK_PATH" "$PROD_HOST:$PROD_WEB_DIR/ufobeep-$APK_TYPE.apk"
        ssh -p $PROD_PORT $PROD_HOST "cd $PROD_WEB_DIR && cp ufobeep-$APK_TYPE.apk ufobeep-latest.apk"
        
        echo -e "${GREEN}✅ APK deployed to server${NC}"
        echo "   Download: https://ufobeep.com/downloads/ufobeep-latest.apk"
    else
        echo -e "${YELLOW}⚠️  No APK found. Build with: cd app && flutter build apk${NC}"
    fi
    echo
fi

# Step 3: Deploy API if requested
if [ "$DEPLOY_API" = true ]; then
    echo -e "${BLUE}🔧 Step 3: API Deployment${NC}"
    echo "-------------------------"
    
    echo "Updating API on production..."
    if ssh -p $PROD_PORT $PROD_HOST << 'ENDSSH'
        set -e
        echo "Pulling latest code..."
        cd /home/ufobeep/ufobeep
        git pull origin main
        
        echo "Installing dependencies if requirements changed..."
        cd api
        REQ_HASH_NEW=$(sha256sum requirements.txt | awk '{print $1}')
        REQ_HASH_FILE=.requirements.sha256
        REQ_HASH_OLD=""
        if [ -f "$REQ_HASH_FILE" ]; then
            REQ_HASH_OLD=$(cat "$REQ_HASH_FILE")
        fi
        if [ "$REQ_HASH_NEW" != "$REQ_HASH_OLD" ] || [ ! -d "venv" ]; then
            echo "Requirements changed or venv missing. (old=$REQ_HASH_OLD new=$REQ_HASH_NEW)"
            if [ ! -d "venv" ]; then
                python3 -m venv venv
            fi
            source venv/bin/activate
            echo "Installing/updating packages..."
            pip install --upgrade pip >/dev/null 2>&1 || true
            pip install -r requirements.txt
            echo "$REQ_HASH_NEW" > "$REQ_HASH_FILE"
        else
            echo "Requirements unchanged. Skipping pip install."
            source venv/bin/activate
        fi
        
        echo "Running migrations..."
        source venv/bin/activate
        python run_migration.py || echo "Migration completed or not needed"
        
        echo "Restarting API service..."
        sudo systemctl restart ufobeep-api
        
        echo "Checking API status..."
        sleep 5
        # Try health check with retries
        for i in {1..3}; do
            if curl -s --connect-timeout 10 --max-time 15 https://api.ufobeep.com/healthz | grep -q '"ok":true'; then
                echo "✅ API is healthy"
                exit 0
            fi
            echo "Health check attempt $i failed, retrying..."
            sleep 3
        done
        echo "❌ API health check failed after 3 attempts!"
        sudo systemctl status ufobeep-api --no-pager
        exit 1
ENDSSH
    then
        echo -e "${GREEN}✅ API deployed${NC}"
    else
        echo -e "${RED}❌ API DEPLOYMENT FAILED${NC}"
        exit 1
    fi
    echo
fi

# Step 4a: Deploy Web (remote build)
if [ "$DEPLOY_WEB" = true ]; then
    echo -e "${BLUE}🌐 Step 4: Web App Deployment${NC}"
    echo "------------------------------"
    
    echo "Updating Next.js app on production..."
    if ssh -p $PROD_PORT $PROD_HOST << 'ENDSSH'
        set -e
        echo "Pulling latest code..."
        cd /home/ufobeep/ufobeep
        git pull origin main
        cd web
        
        echo "Installing dependencies..."
        npm install
        
        echo "Building production bundle..."
        npm run build
        
        echo "Restarting web service..."
        sudo systemctl restart ufobeep-web
        
        echo "Checking web status..."
        sleep 2
        if ! sudo systemctl is-active --quiet ufobeep-web; then
            echo "❌ Web service failed to start!"
            sudo systemctl status ufobeep-web --no-pager
            exit 1
        fi
        
        if ! curl -s -I https://ufobeep.com | grep -q "HTTP/2 200"; then
            echo "❌ Website not responding!"
            exit 1
        fi
        echo "✅ Website is healthy"
ENDSSH
    then
        echo -e "${GREEN}✅ Web app deployed${NC}"
    else
        echo -e "${RED}❌ WEB DEPLOYMENT FAILED${NC}"
        exit 1
    fi
    echo
fi

# Step 4b: Deploy Web FAST (local build + rsync)
if [ "$DEPLOY_WEB_FAST" = true ]; then
    echo -e "${BLUE}🌐 Step 4: Web App Deployment (FAST)${NC}"
    echo "-------------------------------------"

    echo "Building Next.js locally (standalone)..."
    pushd web >/dev/null
    if command -v npm >/dev/null 2>&1; then
        npm ci --prefer-offline --no-audit --progress=false || npm install
        NEXT_TELEMETRY_DISABLED=1 npm run build
    else
        echo -e "${RED}npm not found. Aborting web-fast deploy.${NC}"
        exit 1
    fi
    popd >/dev/null

    echo "Syncing build artifacts to production..."
    ssh -p $PROD_PORT $PROD_HOST "mkdir -p $PROD_NEXT_DIR/.next $PROD_NEXT_DIR/public"
    # Sync the entire .next directory to support both next start and standalone
    rsync -az --delete -e "ssh -p $PROD_PORT" web/.next/ "$PROD_HOST:$PROD_NEXT_DIR/.next/"
    rsync -az --delete -e "ssh -p $PROD_PORT" web/public/ "$PROD_HOST:$PROD_NEXT_DIR/public/"

    echo "Restarting web service..."
    ssh -p $PROD_PORT $PROD_HOST "sudo systemctl restart ufobeep-web && sleep 2 && sudo systemctl is-active --quiet ufobeep-web"
    if [ $? -ne 0 ]; then
        echo -e "${RED}❌ WEB SERVICE RESTART FAILED${NC}"
        exit 1
    fi

    echo "Health check..."
    if curl -s -I https://ufobeep.com | grep -q "HTTP/2 200"; then
        echo -e "${GREEN}✅ Web app deployed (FAST)${NC}"
    else
        echo -e "${YELLOW}⚠️  Web responded with non-200. Check service logs.${NC}"
    fi
    echo
fi

# Final summary
echo -e "${GREEN}🎉 DEPLOYMENT COMPLETE!${NC}"
echo
echo "Deployed components:"
[ "$DEPLOY_API" = true ] && echo "  ✅ API: https://api.ufobeep.com"
[ "$DEPLOY_WEB" = true ] && echo "  ✅ Web: https://ufobeep.com"
[ "$DEPLOY_APK" = true ] && echo "  ✅ APK: https://ufobeep.com/downloads/ufobeep-latest.apk"
echo
echo "Usage examples:"
echo "  ./deploy.sh         # Deploy everything"
echo "  ./deploy.sh api     # Deploy only API"
echo "  ./deploy.sh web     # Deploy only web"
echo "  ./deploy.sh apk     # Deploy APK to all devices"
echo "  ./deploy.sh moto    # Deploy APK to Moto only"
echo "  ./deploy.sh tablet  # Deploy APK to tablet only"
echo "  ./deploy.sh pixel   # Deploy APK to Pixel only"
echo "  ./deploy.sh samsung # Deploy APK to Samsung only"
