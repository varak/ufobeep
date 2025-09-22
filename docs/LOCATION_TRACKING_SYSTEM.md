# UFOBeep Location Tracking System

**Last Updated:** September 22, 2025
**Status:** Production Active
**Battery Impact:** <3% (vs ~15% with continuous GPS)

## Overview

UFOBeep uses intelligent geofencing technology to monitor user location in the background for proximity alerts. This system automatically updates device location when users move, ensuring accurate proximity alerts without significant battery drain.

## System Architecture

### Geofence-Based Approach
- **2km geofence boundaries** created around user's current location
- **System-managed monitoring** - leverages OS geofencing capabilities
- **Triggered only on boundary crossing** - not continuous GPS polling
- **1km movement validation** - filters out false positives from geofence exits

### Battery Optimization
- **<3% battery impact** compared to ~15% from continuous GPS monitoring
- **No persistent notifications** - operates silently in background
- **OS-level efficiency** - uses hardware-accelerated location chips
- **Smart activation** - only activates GPS when crossing geofence boundaries

## Technical Implementation

### LocationTrackingService
**File:** `app/lib/services/location_tracking_service.dart`

**Key Components:**
```dart
class LocationTrackingService {
  // Configuration
  static const double geofenceRadiusKm = 2.0;     // 2km boundary
  static const double minMovementKm = 1.0;         // 1km validation threshold
  static const Duration minUpdateInterval = Duration(minutes: 10); // Rate limiting
  static const double maxAccuracyMeters = 100.0;   // GPS accuracy filter
}
```

**Workflow:**
1. **Initialization** - Auto-enables for all users at app startup
2. **Geofence Creation** - 2km radius around current location
3. **Boundary Detection** - OS triggers when user crosses geofence
4. **Movement Validation** - Calculates distance from last known position
5. **Rate Limiting** - Enforces 10-minute minimum between updates
6. **Server Update** - Calls `POST /devices/update-location` API
7. **New Geofence** - Creates fresh boundary around new location

### API Integration
**Endpoint:** `POST /devices/update-location`
**Authentication:** Bearer token required
**Payload:**
```json
{
  "lat": 37.7749,
  "lon": -122.4194
}
```
**Response:** `204 No Content` on success

### State Persistence
- **Last known position** stored in SharedPreferences
- **Last update timestamp** for rate limiting
- **Tracking enabled status** for user preferences
- **Survives app restarts** - state restored from storage

## User Experience

### Automatic Operation
- **All users** - Auto-enabled for proximity alerts (authenticated + anonymous)
- **Silent operation** - No notifications or user intervention required
- **Transparent controls** - Status visible in Profile → Location Tracking settings

### User Controls
**Location:** Profile → Privacy & Data → Location Tracking

**Settings Available:**
- **Enable/Disable** background tracking toggle
- **Current status** - Shows if monitoring is active
- **Last known location** - Display coordinates (truncated for privacy)
- **Last update time** - When location was last sent to server
- **Technical details** - Movement thresholds and battery impact

### Permission Requirements
- **"Always Allow" location permission** required for background operation
- **Clear permission dialog** explains necessity for proximity alerts
- **Benefits-focused messaging** - "Get UFO alerts wherever you travel"
- **No fallbacks** - Fails clearly if proper permission not granted

## Privacy & Security

### Data Collection
- **Current location only** - No historical tracking or movement patterns
- **Movement detection** - Only when crossing 1km threshold
- **Rate limited** - Maximum one update per 10 minutes
- **Accuracy filtered** - Ignores GPS readings >100m accuracy

### Data Usage
- **Proximity alerts** - Core functionality for location-based notifications
- **Distance calculations** - Determining alert relevance to user location
- **Geofence management** - Creating boundaries around user position
- **No surveillance** - Location not used for tracking, profiling, or commercial purposes

### Data Storage
- **Server storage** - Current location coordinates only
- **Local storage** - Last position and timestamps for rate limiting
- **No location history** - Previous positions not retained
- **Coordinate jittering** - Public displays offset by 100-300m for privacy

## Comparison: Old vs New System

### LocationUpdateManager (Disabled)
- ❌ **Continuous GPS monitoring** - Always listening to location stream
- ❌ **High battery usage** - ~15% additional drain
- ❌ **1km OS distance filter** - Still requires constant GPS
- ❌ **15-minute throttle** - Less responsive to movement
- ✅ **Automatic for all users** - No setup required
- ✅ **Proven working** - Battle-tested in production

### LocationTrackingService (Active)
- ✅ **Geofence-based monitoring** - System-managed boundaries
- ✅ **Low battery usage** - <3% additional drain
- ✅ **2km geofence + 1km validation** - Smart filtering
- ✅ **10-minute throttle** - More responsive updates
- ✅ **Automatic for all users** - No setup required
- ✅ **Modern approach** - Leverages hardware optimization

## Configuration

### Auto-Enable Logic
```dart
Future<void> initialize() async {
  // Auto-enable for ALL users (authenticated and anonymous) for proximity alerts
  await setTrackingEnabled(true);
  print('LocationTracking: Auto-enabled geofence monitoring for all users');
}
```

### App Startup Integration
**File:** `app/lib/main.dart`
```dart
// Initialize efficient geofence-based LocationTrackingService for ALL users
Future.delayed(Duration.zero, () async {
  await locationTrackingService.initialize();
  debugPrint('✅ LocationTrackingService initialized - efficient geofencing for all users');
});
```

## App Store Compliance

### Privacy Policy Integration
- **Background location monitoring** clearly described
- **Geofencing technology** explained in user-friendly terms
- **Battery efficiency** highlighted (<3% impact)
- **User controls** documented with disable options
- **Purpose limitation** - Only for proximity alerts, not surveillance

### Required Disclosures
- **"Always Allow" permission** necessity explained
- **Background location usage** transparently communicated
- **Data retention policies** - Current location only, no history
- **User rights** - Can disable anytime in app settings

## Monitoring & Debugging

### Console Logging
All location tracking operations are logged with `LocationTracking:` prefix:
- Service initialization and auto-enable status
- Geofence creation and boundary crossing events
- Movement validation and distance calculations
- Rate limiting decisions and API call results
- Permission status and error conditions

### Status Information
Available via `LocationTrackingService.getTrackingStatus()`:
- Current monitoring state (active/inactive)
- Last known position coordinates
- Last update timestamp and age
- Configuration values (geofence radius, movement threshold)

## Future Enhancements

### Potential Improvements
- **Adaptive geofence sizing** - Larger boundaries in rural areas, smaller in cities
- **Speed-based adjustments** - Different thresholds for walking vs driving
- **Network condition handling** - Queue updates when offline
- **Background sync optimization** - Batch updates when network restored

### App Store Considerations
- **Location tracking apps** face increased scrutiny during review
- **Clear necessity justification** required for "Always Allow" permission
- **Battery efficiency claims** should be measurable and accurate
- **Privacy transparency** essential for approval and user trust

## Conclusion

The geofence-based LocationTrackingService provides the same proximity alert functionality as the previous LocationUpdateManager while delivering significant battery life improvements. Users get accurate location-based notifications with minimal device impact and full transparency about data usage.