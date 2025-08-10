#!/bin/bash

# UFOBeep Beta Build Script
# Builds and prepares the app for beta distribution

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
FLUTTER_VERSION="stable"
BUILD_TYPE="beta"
BETA_VERSION="1.0.0-beta.1"

echo -e "${BLUE}🚀 UFOBeep Beta Build Script${NC}"
echo -e "Flutter Version: ${FLUTTER_VERSION}"
echo -e "Build Type: ${BUILD_TYPE}"
echo -e "Version: ${BETA_VERSION}"
echo ""

# Check Flutter installation
if ! command -v flutter &> /dev/null; then
    echo -e "${RED}❌ Flutter not found. Please install Flutter first.${NC}"
    exit 1
fi

echo -e "${YELLOW}📋 Checking Flutter environment...${NC}"
flutter doctor

# Clean previous builds
echo -e "${YELLOW}🧹 Cleaning previous builds...${NC}"
flutter clean
flutter pub get

# Run code generation
echo -e "${YELLOW}⚙️ Running code generation...${NC}"
dart run build_runner build --delete-conflicting-outputs

# Generate localization files
echo -e "${YELLOW}🌍 Generating localization files...${NC}"
flutter gen-l10n

# Run tests
echo -e "${YELLOW}🧪 Running tests...${NC}"
flutter test

# Build Android Beta
build_android_beta() {
    echo -e "${GREEN}📱 Building Android Beta APK...${NC}"
    
    # Create upload keystore if it doesn't exist (for demo purposes)
    if [ ! -f "android/ufobeep-keystore.jks" ]; then
        echo -e "${YELLOW}🔐 Creating demo keystore (replace with real one for production)...${NC}"
        keytool -genkey -v -keystore android/ufobeep-keystore.jks \
            -keyalg RSA -keysize 2048 -validity 10000 \
            -alias ufobeep-key \
            -dname "CN=UFOBeep Demo, OU=Development, O=UFOBeep, L=City, ST=State, C=US" \
            -storepass demo123 -keypass demo123
        
        # Update key.properties with demo values
        cat > android/key.properties << EOF
storePassword=demo123
keyPassword=demo123
keyAlias=ufobeep-key
storeFile=../ufobeep-keystore.jks
EOF
    fi
    
    # Build signed APK
    flutter build apk --release --build-name=$BETA_VERSION --build-number=1
    
    # Build App Bundle for Play Store
    flutter build appbundle --release --build-name=$BETA_VERSION --build-number=1
    
    # Copy outputs to distribution folder
    mkdir -p dist/android
    cp build/app/outputs/flutter-apk/app-release.apk "dist/android/ufobeep-${BETA_VERSION}-release.apk"
    cp build/app/outputs/bundle/release/app-release.aab "dist/android/ufobeep-${BETA_VERSION}-release.aab"
    
    echo -e "${GREEN}✅ Android build complete!${NC}"
    echo -e "APK: dist/android/ufobeep-${BETA_VERSION}-release.apk"
    echo -e "AAB: dist/android/ufobeep-${BETA_VERSION}-release.aab"
}

# Build iOS Beta
build_ios_beta() {
    if [[ "$OSTYPE" == "darwin"* ]]; then
        echo -e "${GREEN}📱 Building iOS Beta...${NC}"
        
        # Clean iOS build
        rm -rf ios/build
        
        # Build iOS archive
        flutter build ipa --release --build-name=$BETA_VERSION --build-number=1
        
        # Copy to distribution folder
        mkdir -p dist/ios
        cp build/ios/ipa/*.ipa "dist/ios/ufobeep-${BETA_VERSION}.ipa"
        
        echo -e "${GREEN}✅ iOS build complete!${NC}"
        echo -e "IPA: dist/ios/ufobeep-${BETA_VERSION}.ipa"
    else
        echo -e "${YELLOW}⚠️ Skipping iOS build (macOS required)${NC}"
    fi
}

# Create build info
create_build_info() {
    mkdir -p dist
    
    cat > dist/build_info.json << EOF
{
  "version": "$BETA_VERSION",
  "build_type": "$BUILD_TYPE",
  "build_date": "$(date -u +%Y-%m-%dT%H:%M:%S.%3NZ)",
  "flutter_version": "$(flutter --version | head -n 1)",
  "commit_hash": "$(git rev-parse HEAD 2>/dev/null || echo 'unknown')",
  "branch": "$(git branch --show-current 2>/dev/null || echo 'unknown')",
  "artifacts": {
    "android_apk": "android/ufobeep-${BETA_VERSION}-release.apk",
    "android_aab": "android/ufobeep-${BETA_VERSION}-release.aab",
    "ios_ipa": "ios/ufobeep-${BETA_VERSION}.ipa"
  }
}
EOF

    echo -e "${GREEN}📝 Build info created: dist/build_info.json${NC}"
}

# Main build process
main() {
    # Create distribution directory
    mkdir -p dist
    
    # Build for specified platforms
    case "${1:-all}" in
        "android")
            build_android_beta
            ;;
        "ios")
            build_ios_beta
            ;;
        "all"|*)
            build_android_beta
            build_ios_beta
            ;;
    esac
    
    # Create build information
    create_build_info
    
    # Calculate file sizes
    echo -e "${BLUE}📊 Build Summary:${NC}"
    if [ -d "dist/android" ]; then
        echo -e "Android APK: $(du -h dist/android/*.apk 2>/dev/null | cut -f1 || echo 'N/A')"
        echo -e "Android AAB: $(du -h dist/android/*.aab 2>/dev/null | cut -f1 || echo 'N/A')"
    fi
    if [ -d "dist/ios" ]; then
        echo -e "iOS IPA: $(du -h dist/ios/*.ipa 2>/dev/null | cut -f1 || echo 'N/A')"
    fi
    
    echo ""
    echo -e "${GREEN}🎉 Beta build complete!${NC}"
    echo -e "Distribution files are in the ${BLUE}dist/${NC} folder"
    echo ""
    echo -e "${YELLOW}Next steps:${NC}"
    echo -e "1. Test the APK/IPA on physical devices"
    echo -e "2. Upload to Google Play Console (Internal Testing)"
    echo -e "3. Upload to App Store Connect (TestFlight)"
    echo -e "4. Distribute to beta testers"
}

# Error handling
handle_error() {
    echo -e "${RED}❌ Build failed: $1${NC}"
    exit 1
}

trap 'handle_error "Unexpected error occurred"' ERR

# Run main function
main "$@"