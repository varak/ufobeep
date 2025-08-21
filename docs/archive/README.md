# UFOBeep Documentation

## Building the Beta APK

### Prerequisites
- Flutter SDK installed and configured
- Android SDK with build tools
- Valid keystore for signing (optional for debug builds)

### Build Commands

#### Debug APK (for testing)
```bash
cd app
flutter clean
flutter pub get
flutter build apk --debug
```

The debug APK will be generated at:
`app/build/app/outputs/flutter-apk/app-debug.apk`

#### Release APK (for beta distribution)
```bash
cd app
flutter clean
flutter pub get
flutter build apk --release
```

The release APK will be generated at:
`app/build/app/outputs/flutter-apk/app-release.apk`

### APK Size Optimization

To reduce APK size for beta releases:

1. **Build split APKs by ABI** (recommended):
```bash
flutter build apk --split-per-abi --release
```

This creates separate APKs for each architecture:
- `app-armeabi-v7a-release.apk` (~70MB)
- `app-arm64-v8a-release.apk` (~70MB)
- `app-x86_64-release.apk` (~70MB)

2. **Build app bundle** (for Play Store):
```bash
flutter build appbundle --release
```

### Deploying Beta APK

1. Build the APK using the commands above
2. Copy to the web server:
```bash
scp -P 322 app/build/app/outputs/flutter-apk/app-release.apk ufobeep@ufobeep.com:/home/ufobeep/ufobeep/web/public/downloads/ufobeep-beta.apk
```

3. The APK will be available at:
`https://ufobeep.com/downloads/ufobeep-beta.apk`

### Version Naming Convention

Beta releases follow this pattern:
- `v1.0.0-beta.X` where X is the beta build number
- Example: `v1.0.0-beta.5 "the Nikolai Build"`

Update version in `app/pubspec.yaml`:
```yaml
version: 1.0.0+5  # 5 is the build number
```

### Important Notes

- APK files are excluded from git (see `web/public/downloads/.gitignore`)
- Debug APKs are larger (~200MB) due to debug symbols
- Release APKs are smaller (~100MB) and optimized
- Split APKs by ABI reduces download size to ~70MB per architecture
- Always test release APKs before distribution

### Testing the APK

1. **Install via ADB**:
```bash
adb install app/build/app/outputs/flutter-apk/app-release.apk
```

2. **Direct download**: Share the download link from the website

3. **QR Code**: Generate a QR code for the download URL for easy mobile access