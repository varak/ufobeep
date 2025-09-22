# Movement Detection Sprint Plan

## Problem Statement
Device locations become stale when users move, causing proximity alerts to be sent to wrong locations. Users need automatic location updates without manual intervention.

## Current State Analysis

### What Exists Now
- ✅ **DeviceService.updateDeviceLocation()** - Manual location update method
- ✅ **API endpoints** - PATCH /devices/{id}/location (fixed to update geometry)
- ✅ **Location permissions** - App already requests GPS access
- ❌ **No automatic triggers** - Location only updates during beep submission

### What's Missing
- **Background location monitoring** - Detect when user moves significantly
- **Automatic API calls** - Update server when movement detected
- **Battery optimization** - Efficient monitoring without drain
- **Error handling** - Retry logic, network failures

## Implementation Strategy

### Phase 1: Foundation & Research (2 days)

#### 1.1 Technical Requirements Analysis
- [ ] **Battery impact assessment** - How much drain is acceptable?
- [ ] **Movement threshold research** - What distance triggers update? (1km optimal)
- [ ] **Update frequency limits** - Prevent API spam (max 1 update per 10 minutes)
- [ ] **Platform capability check** - Android vs iOS efficient movement detection

#### 1.2 User Experience Planning
- [ ] **Permission flow design** - How to request background location access
- [ ] **User communication** - Clear explanation of tracking necessity
- [ ] **Settings integration** - Where to put movement detection controls
- [ ] **Tracking notification** - Required Android foreground service notification

#### 1.3 Architecture Design
- [ ] **Service structure** - Background service vs foreground monitoring
- [ ] **State management** - How to track last known location
- [ ] **API integration** - Reuse existing updateDeviceLocation() method
- [ ] **Error handling** - Network failures, permission revocation

### Phase 2: Android Implementation (3 days)

#### 2.1 Android Background Service
- [ ] **Create LocationTrackingService** - Foreground service for continuous monitoring
- [ ] **Implement WorkManager integration** - Ensure service stays alive
- [ ] **Add persistent notification** - "UFOBeep is monitoring location for alerts"
- [ ] **Handle service lifecycle** - Start/stop with app install/uninstall

#### 2.2 Android Movement Detection
- [ ] **Configure LocationManager** - High accuracy with balanced power usage
- [ ] **Implement movement threshold** - Calculate distance from last known position
- [ ] **Add debouncing logic** - Prevent rapid-fire updates (max 1 per 10 minutes)
- [ ] **Handle GPS accuracy** - Filter out inaccurate readings

#### 2.3 Android API Integration
- [ ] **Automatic server updates** - Call existing device location endpoint
- [ ] **Queue failed updates** - Store and retry when network available
- [ ] **Authentication handling** - Manage JWT tokens in background service
- [ ] **Error logging** - Track update failures for debugging

### Phase 3: iOS Implementation (3 days)

#### 3.1 iOS Background Location
- [ ] **Configure CLLocationManager** - Background location with significant changes
- [ ] **Implement background app refresh** - Handle location updates when app closed
- [ ] **Add location usage description** - Clear Info.plist descriptions
- [ ] **Handle iOS 14+ location permissions** - Precise vs approximate location

#### 3.2 iOS Movement Detection
- [ ] **Significant location change monitoring** - iOS native efficient detection
- [ ] **Manual distance threshold** - Additional 1km threshold check
- [ ] **Background task management** - Handle iOS background execution limits
- [ ] **Core Location accuracy handling** - Filter poor accuracy readings

#### 3.3 iOS API Integration
- [ ] **Background network calls** - Update server from background
- [ ] **Background processing time** - Work within iOS background limits
- [ ] **Silent push notifications** - Trigger location checks remotely
- [ ] **App state handling** - Different behavior for foreground vs background

### Phase 4: Cross-Platform Integration (2 days)

#### 4.1 Flutter Service Layer
- [ ] **Create unified LocationTrackingService** - Abstract Android/iOS differences
- [ ] **Platform-specific implementations** - MethodChannel integration
- [ ] **State management** - Track monitoring status across app restarts
- [ ] **Settings integration** - Enable/disable tracking with clear consequences

#### 4.2 Error Handling & Resilience
- [ ] **Network failure handling** - Queue updates, retry logic
- [ ] **Permission revocation** - Handle user changing permissions
- [ ] **Service recovery** - Restart monitoring if stopped
- [ ] **Data validation** - Ensure location accuracy before API calls

### Phase 5: User Experience & Compliance (2 days)

#### 5.1 Permission Flow & Communication
- [ ] **Design permission request flow** - Clear necessity explanation
- [ ] **Create tracking indicator** - Show when location is being monitored
- [ ] **Add privacy settings** - User control with functionality warnings
- [ ] **Implement tracking notification** - Required for Android foreground service

#### 5.2 Language Support & Legal
- [ ] **Add location tracking translations** - All text in user's language
- [ ] **Update privacy policy** - Accurate description of location tracking
- [ ] **Create user communication** - How tracking works, why it's necessary
- [ ] **Add legal disclaimers** - Required for location tracking apps

### Phase 6: Testing & Optimization (3 days)

#### 6.1 Real-World Testing
- [ ] **Battery drain testing** - Measure actual impact over 24+ hours
- [ ] **Movement accuracy testing** - Test with actual travel (driving, walking)
- [ ] **Background operation testing** - Verify works when app completely closed
- [ ] **Network condition testing** - Poor signal, airplane mode scenarios

#### 6.2 Performance Validation
- [ ] **API call frequency testing** - Ensure not spamming server
- [ ] **Spatial query integration** - Verify updated locations work with proximity
- [ ] **Cross-device testing** - Multiple devices updating simultaneously
- [ ] **Edge case testing** - Rapid movement, poor GPS, permission changes

#### 6.3 User Acceptance Testing
- [ ] **Permission flow testing** - Users understand and accept tracking
- [ ] **Settings functionality** - Enable/disable controls work properly
- [ ] **Language testing** - All tracking text properly translated
- [ ] **Privacy compliance** - All disclosures accurate and complete

## Technical Implementation Details

### LocationTrackingService Architecture
```dart
class LocationTrackingService {
  static const double movementThresholdKm = 1.0;
  static const Duration minUpdateInterval = Duration(minutes: 10);
  static const Duration maxLocationAge = Duration(minutes: 5);

  // Platform-specific background monitoring
  Future<void> startBackgroundMonitoring();
  Future<void> stopBackgroundMonitoring();

  // Movement detection
  Future<void> onLocationChanged(Position position);
  bool shouldUpdateLocation(Position current, Position? last);

  // Server integration
  Future<void> updateServerLocation(Position position);
  Future<void> retryFailedUpdates();
}
```

### Platform-Specific Requirements

#### Android Requirements
- **Foreground service** - Required for background location access
- **Persistent notification** - "UFOBeep is monitoring location for proximity alerts"
- **WorkManager scheduling** - Ensure service restarts if killed
- **Battery optimization whitelist** - Request exemption for reliable operation

#### iOS Requirements
- **Background app refresh** - Required capability in Info.plist
- **Location always permission** - Required for background monitoring
- **Background location usage** - Clear description in permission prompt
- **Significant location changes** - Most battery-efficient approach

## Success Metrics

### Functional Requirements
- **Movement detection accuracy** - 95% of >1km movements trigger updates
- **Update latency** - Location updates within 5 minutes of significant movement
- **Battery efficiency** - <5% additional battery drain in normal usage
- **Network resilience** - 99% update success rate with retry logic

### User Experience Requirements
- **Permission acceptance rate** - >80% of users accept background location
- **Clear communication** - Users understand why tracking is necessary
- **Language support** - All tracking features work in user's language
- **Settings control** - Users can manage tracking preferences easily

## Risk Assessment

### High Risk Areas
- **App store approval** - Background location apps face scrutiny
- **Battery drain complaints** - Poor implementation can cause user abandonment
- **Permission rejection** - Users may reject background location access
- **Platform policy changes** - OS updates may break background location

### Medium Risk Areas
- **Implementation complexity** - Cross-platform background services are complex
- **Testing challenges** - Hard to test all movement scenarios
- **Network reliability** - API failures in background need robust handling
- **User trust** - Location tracking can reduce user confidence

## Timeline Estimate
- **Total effort**: 2.5 weeks (15 days)
- **Cross-platform complexity** - Requires native Android/iOS knowledge
- **Testing requirements** - Extensive real-world validation needed
- **User experience work** - Proper permission flows and communication

## Dependencies
- **Native platform development** - Android/iOS background service expertise
- **App store compliance** - May require approval process updates
- **Testing infrastructure** - Real devices for battery/movement testing
- **Legal compliance** - Privacy policy updates for location tracking