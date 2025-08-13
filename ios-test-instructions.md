# UFOBeep iOS Testing Instructions

## For Testers Without a Mac

Unfortunately, iOS apps require special signing to run on physical devices. Here are your options:

### Option 1: Wait for TestFlight (Recommended)
- We're working on getting the app on TestFlight
- This will allow easy installation without technical setup
- Sign up at https://ufobeep.com/app to get notified when it's ready

### Option 2: Use a Testing Service
Services like BrowserStack or Appetize.io can run iOS apps in the cloud:
1. Visit https://appetize.io
2. Upload the .app file (we'll provide this)
3. Test in a virtual iPhone

## For Testers With a Mac

### Requirements
- Mac with Xcode installed (free from App Store)
- iPhone running iOS 14.0 or later
- USB cable to connect iPhone to Mac

### Installation Steps

1. **Download the Flutter SDK** (if not installed)
   ```bash
   # Download Flutter
   git clone https://github.com/flutter/flutter.git -b stable
   export PATH="$PATH:`pwd`/flutter/bin"
   ```

2. **Clone the UFOBeep repository**
   ```bash
   git clone https://github.com/varak/ufobeep.git
   cd ufobeep/app
   ```

3. **Install dependencies**
   ```bash
   flutter pub get
   cd ios
   pod install
   cd ..
   ```

4. **Open in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```

5. **Configure Signing**
   - In Xcode, select "Runner" in the navigator
   - Go to "Signing & Capabilities" tab
   - Select your Apple ID in "Team" dropdown
   - If you don't have a team, click "Add Account" and sign in with your Apple ID

6. **Select your iPhone**
   - Connect your iPhone via USB
   - Trust the computer on your iPhone when prompted
   - In Xcode, select your iPhone from the device dropdown (top toolbar)

7. **Build and Run**
   - Click the "Play" button in Xcode
   - OR run from terminal: `flutter run --release`

8. **Trust the Developer Certificate**
   - On your iPhone: Settings → General → Device Management
   - Tap your developer account
   - Tap "Trust [Your Apple ID]"
   - Confirm by tapping "Trust"

### Alternative: Install Pre-built IPA

If we provide an IPA file:

1. **Using Apple Configurator 2** (Mac App Store - Free)
   - Install Apple Configurator 2
   - Connect iPhone via USB
   - Drag the .ipa file onto your device

2. **Using Xcode**
   - Window → Devices and Simulators
   - Select your iPhone
   - Drag the .ipa file to the "Installed Apps" section

3. **Using ideviceinstaller** (Command Line)
   ```bash
   brew install ideviceinstaller
   ideviceinstaller -i UFOBeep.ipa
   ```

## Simulator Testing (Mac Only)

For testing in the iOS Simulator (no physical device needed):

1. **Start iOS Simulator**
   ```bash
   open -a Simulator
   ```

2. **Run the app**
   ```bash
   cd ufobeep/app
   flutter run
   ```

## Troubleshooting

### "Untrusted Developer" Error
- Go to Settings → General → Device Management
- Trust the developer certificate

### "Unable to Install" Error
- Make sure you have enough storage space
- Restart your iPhone
- Check that your iOS version is 14.0 or later

### Build Errors on Mac
- Run `flutter doctor` to check your setup
- Make sure Xcode is up to date
- Accept Xcode license: `sudo xcodebuild -license accept`

## Features to Test

When testing, please check:
- [ ] Camera capture (photo/video)
- [ ] Location services
- [ ] Push notifications
- [ ] Compass navigation
- [ ] Alert viewing
- [ ] Media upload
- [ ] App performance

## Reporting Issues

Please report any issues with:
- iOS version
- iPhone model
- Screenshot of the error
- Steps to reproduce

Sign up at https://ufobeep.com/app to stay updated on development

## Notes

- The iOS version is currently in alpha
- Some features may not work perfectly
- TestFlight version coming soon for easier testing