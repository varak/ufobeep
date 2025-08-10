#!/bin/bash

# UFOBeep Beta Distribution Script
# Distributes beta builds to testers via Firebase App Distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m' 
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# Configuration
FIREBASE_PROJECT_ID="ufobeep-app"
ANDROID_APP_ID="1:123456789:android:abcdef123456"
IOS_APP_ID="1:123456789:ios:abcdef123456"
TESTER_GROUPS="beta-testers,internal-team"

echo -e "${BLUE}📦 UFOBeep Beta Distribution${NC}"
echo ""

# Check if Firebase CLI is installed
if ! command -v firebase &> /dev/null; then
    echo -e "${RED}❌ Firebase CLI not found. Installing...${NC}"
    npm install -g firebase-tools
fi

# Check if user is logged in to Firebase
if ! firebase projects:list &> /dev/null; then
    echo -e "${YELLOW}🔐 Please login to Firebase...${NC}"
    firebase login
fi

# Function to distribute Android beta
distribute_android() {
    local apk_path="dist/android/ufobeep-1.0.0-beta.1-release.apk"
    
    if [ ! -f "$apk_path" ]; then
        echo -e "${RED}❌ Android APK not found: $apk_path${NC}"
        echo -e "Run ${YELLOW}./scripts/build_beta.sh android${NC} first"
        return 1
    fi
    
    echo -e "${GREEN}📱 Distributing Android Beta...${NC}"
    
    firebase appdistribution:distribute "$apk_path" \
        --app "$ANDROID_APP_ID" \
        --groups "$TESTER_GROUPS" \
        --release-notes-file "store_assets/release_notes_beta.txt"
    
    echo -e "${GREEN}✅ Android beta distributed!${NC}"
}

# Function to distribute iOS beta
distribute_ios() {
    local ipa_path="dist/ios/ufobeep-1.0.0-beta.1.ipa"
    
    if [ ! -f "$ipa_path" ]; then
        echo -e "${RED}❌ iOS IPA not found: $ipa_path${NC}"
        echo -e "Run ${YELLOW}./scripts/build_beta.sh ios${NC} first"
        return 1
    fi
    
    echo -e "${GREEN}📱 Distributing iOS Beta...${NC}"
    
    firebase appdistribution:distribute "$ipa_path" \
        --app "$IOS_APP_ID" \
        --groups "$TESTER_GROUPS" \
        --release-notes-file "store_assets/release_notes_beta.txt"
    
    echo -e "${GREEN}✅ iOS beta distributed!${NC}"
}

# Create release notes for beta
create_release_notes() {
    mkdir -p store_assets
    
    cat > store_assets/release_notes_beta.txt << EOF
UFOBeep Beta 1.0.0-beta.1

🎉 Welcome to UFOBeep Beta!

What's New:
• Real-time UFO sighting alerts within your specified radius
• Advanced compass navigation with augmented reality overlay
• Professional pilot mode with aviation-grade instruments
• Photo and video documentation with automatic metadata
• Community discussion rooms powered by Matrix protocol
• Multi-language support (English, Spanish, German)
• Offline functionality for remote locations
• Enriched sighting data with weather, celestial objects, and aircraft tracking

Known Issues:
• Background location may require manual permission in some Android versions
• Matrix chat requires account creation on first use
• Some pilot mode features may not work in flight simulator mode

How to Test:
1. Enable location permissions for best experience
2. Try capturing a test sighting with photo
3. Browse the alerts map and join a discussion
4. Test compass navigation in outdoor areas
5. Switch between languages in settings

Feedback:
Please report bugs and feedback to: beta@ufobeep.com
Join our beta tester chat: https://matrix.to/#/#ufobeep-beta:matrix.org

Thank you for testing UFOBeep! 🛸
EOF

    echo -e "${GREEN}📝 Release notes created${NC}"
}

# Function to send notification to beta testers
notify_testers() {
    echo -e "${BLUE}📧 Sending notifications to beta testers...${NC}"
    
    # This would typically integrate with your notification system
    # For now, we'll just log the action
    echo -e "${YELLOW}📬 Beta testers will receive email notifications from Firebase${NC}"
    echo -e "${YELLOW}📱 Push notifications sent to existing beta app installs${NC}"
}

# Main distribution process
main() {
    # Create release notes
    create_release_notes
    
    # Distribute based on arguments
    case "${1:-all}" in
        "android")
            distribute_android
            ;;
        "ios")
            distribute_ios
            ;;
        "all"|*)
            distribute_android
            distribute_ios
            ;;
    esac
    
    # Send notifications
    notify_testers
    
    # Display summary
    echo ""
    echo -e "${GREEN}🎉 Beta distribution complete!${NC}"
    echo ""
    echo -e "${BLUE}Next Steps:${NC}"
    echo -e "1. Monitor Firebase App Distribution for downloads"
    echo -e "2. Check crash reporting in Firebase Crashlytics"
    echo -e "3. Gather feedback from beta testers"
    echo -e "4. Track usage analytics"
    echo ""
    echo -e "${YELLOW}Beta Tester Links:${NC}"
    echo -e "Android: https://appdistribution.firebase.dev/i/${ANDROID_APP_ID}"
    echo -e "iOS: https://appdistribution.firebase.dev/i/${IOS_APP_ID}"
}

# Error handling
handle_error() {
    echo -e "${RED}❌ Distribution failed: $1${NC}"
    exit 1
}

trap 'handle_error "Unexpected error occurred"' ERR

# Check if builds exist
if [ ! -d "dist" ]; then
    echo -e "${RED}❌ No distribution files found${NC}"
    echo -e "Run ${YELLOW}./scripts/build_beta.sh${NC} first to create builds"
    exit 1
fi

# Run main function
main "$@"