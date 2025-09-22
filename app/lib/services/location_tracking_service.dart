import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../config/environment.dart';
import 'auth_repository.dart';
import 'device_service.dart';

/// Background location tracking service using geofence-based movement detection
///
/// Strategy: Create 2km geofence around current location. When user exits geofence,
/// get precise location and check if they moved >1km. If so, update server and
/// create new geofence. This provides 1km movement detection with minimal battery drain.
class LocationTrackingService {
  static const String _isTrackingKey = 'location_tracking_enabled';
  static const String _lastPositionKey = 'last_tracked_position';
  static const String _lastUpdateTimeKey = 'last_location_update_time';

  // Technical requirements
  static const double geofenceRadiusKm = 2.0;
  static const double minMovementKm = 1.0;
  static const Duration minUpdateInterval = Duration(minutes: 10);
  static const double maxAccuracyMeters = 100.0;

  // Singleton instance
  static final LocationTrackingService _instance = LocationTrackingService._internal();
  factory LocationTrackingService() => _instance;
  LocationTrackingService._internal();

  // Internal state
  Position? _lastKnownPosition;
  DateTime? _lastUpdateTime;
  StreamSubscription<Position>? _positionStream;
  bool _isMonitoring = false;

  /// Check if location tracking is enabled
  Future<bool> isTrackingEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isTrackingKey) ?? false;
  }

  /// Enable/disable location tracking
  Future<void> setTrackingEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isTrackingKey, enabled);

    if (enabled) {
      await startBackgroundMonitoring();
    } else {
      await stopBackgroundMonitoring();
    }
  }

  /// Start background location monitoring with geofence strategy
  Future<bool> startBackgroundMonitoring() async {
    if (_isMonitoring) {
      print('LocationTracking: Already monitoring, skipping start');
      return true;
    }

    // Check if tracking is enabled in preferences
    if (!await isTrackingEnabled()) {
      print('LocationTracking: Tracking disabled in preferences');
      return false;
    }

    // Request always location permission for background monitoring
    final permission = await _requestBackgroundLocationPermission();
    if (!permission) {
      print('LocationTracking: Background location permission denied');
      return false;
    }

    // Get initial position to establish geofence
    final initialPosition = await _getCurrentPosition();
    if (initialPosition == null) {
      print('LocationTracking: Could not get initial position');
      return false;
    }

    // Load last known position for comparison
    await _loadLastKnownPosition();

    // Check if we need to update server location first
    if (_shouldUpdateServerLocation(initialPosition)) {
      final updated = await _updateServerLocation(initialPosition);
      if (updated) {
        _lastKnownPosition = initialPosition;
        await _saveLastKnownPosition(initialPosition);
      }
    }

    // Start geofence-based monitoring
    await _startGeofenceMonitoring(initialPosition);

    _isMonitoring = true;
    print('LocationTracking: ✅ Background monitoring started with 2km geofence');
    return true;
  }

  /// Stop background location monitoring
  Future<void> stopBackgroundMonitoring() async {
    await _positionStream?.cancel();
    _positionStream = null;
    _isMonitoring = false;
    print('LocationTracking: Background monitoring stopped');
  }

  /// Request background location permission
  Future<bool> _requestBackgroundLocationPermission() async {
    // Check location services
    final serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      print('LocationTracking: Location services disabled');
      return false;
    }

    // Check current permission
    LocationPermission permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    // For background monitoring, we need 'always' permission
    if (permission == LocationPermission.whileInUse) {
      // Request upgrade to 'always' permission
      // Note: This may show system dialog explaining background location usage
      permission = await Geolocator.requestPermission();
    }

    final granted = permission == LocationPermission.always;

    print('LocationTracking: Permission status: $permission (granted: $granted)');
    return granted;
  }

  /// Get current position with timeout and accuracy filtering
  Future<Position?> _getCurrentPosition() async {
    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium, // Balance accuracy vs battery
        timeLimit: const Duration(seconds: 15),
      );

      // Filter out inaccurate readings
      if (position.accuracy > maxAccuracyMeters) {
        print('LocationTracking: Position accuracy too low: ${position.accuracy}m');
        return null;
      }

      return position;
    } catch (e) {
      print('LocationTracking: Error getting current position: $e');
      return null;
    }
  }

  /// Start geofence monitoring around given position
  Future<void> _startGeofenceMonitoring(Position centerPosition) async {
    // Use Geolocator's position stream with distance filter for geofence-like behavior
    const LocationSettings locationSettings = LocationSettings(
      accuracy: LocationAccuracy.medium,
      distanceFilter: 1000, // Trigger when moved 1km (our geofence radius in meters)
    );

    _positionStream = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(_onLocationChanged);

    print('LocationTracking: Geofence monitoring started around ${centerPosition.latitude}, ${centerPosition.longitude}');
  }

  /// Handle location changes (geofence exits)
  Future<void> _onLocationChanged(Position newPosition) async {
    print('LocationTracking: Location change detected: ${newPosition.latitude}, ${newPosition.longitude}');

    // Filter out inaccurate readings
    if (newPosition.accuracy > maxAccuracyMeters) {
      print('LocationTracking: Ignoring inaccurate position: ${newPosition.accuracy}m');
      return;
    }

    // Check if we should update based on movement and time
    if (!_shouldUpdateServerLocation(newPosition)) {
      return;
    }

    // Update server location
    final updated = await _updateServerLocation(newPosition);
    if (updated) {
      // Update our tracking state
      _lastKnownPosition = newPosition;
      _lastUpdateTime = DateTime.now();

      // Save state for persistence across app restarts
      await _saveLastKnownPosition(newPosition);
      await _saveLastUpdateTime(_lastUpdateTime!);

      print('LocationTracking: ✅ Server location updated and new geofence established');
    }
  }

  /// Check if we should update server location
  bool _shouldUpdateServerLocation(Position newPosition) {
    // Rate limiting: Don't update more than once per 10 minutes
    if (_lastUpdateTime != null) {
      final timeSinceUpdate = DateTime.now().difference(_lastUpdateTime!);
      if (timeSinceUpdate < minUpdateInterval) {
        print('LocationTracking: Rate limited - last update ${timeSinceUpdate.inMinutes} minutes ago');
        return false;
      }
    }

    // Movement threshold: Only update if moved >1km
    if (_lastKnownPosition != null) {
      final distanceKm = _calculateDistanceKm(_lastKnownPosition!, newPosition);
      if (distanceKm < minMovementKm) {
        print('LocationTracking: Movement too small - ${distanceKm.toStringAsFixed(2)}km');
        return false;
      }
      print('LocationTracking: Significant movement detected - ${distanceKm.toStringAsFixed(2)}km');
    }

    return true;
  }

  /// Update server with new location using the same endpoint as LocationUpdateManager
  Future<bool> _updateServerLocation(Position position) async {
    try {
      print('LocationTracking: Updating server location to ${position.latitude}, ${position.longitude}');

      // Use the same API endpoint as LocationUpdateManager for consistency
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();

      if (accessToken == null || accessToken.isEmpty) {
        print('LocationTracking: No access token available');
        return false;
      }

      final response = await http.post(
        Uri.parse('${AppEnvironment.apiBaseUrl}/devices/update-location'),
        headers: {
          'Authorization': 'Bearer $accessToken',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'lat': position.latitude,
          'lon': position.longitude,
        }),
      );

      if (response.statusCode == 204) {
        print('LocationTracking: ✅ Server location updated successfully');
        return true;
      } else {
        print('LocationTracking: ❌ Server location update failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('LocationTracking: Error updating server location: $e');
      return false;
    }
  }

  /// Calculate distance between two positions using Haversine formula
  double _calculateDistanceKm(Position pos1, Position pos2) {
    const double earthRadiusKm = 6371.0;

    final lat1Rad = pos1.latitude * pi / 180;
    final lat2Rad = pos2.latitude * pi / 180;
    final deltaLatRad = (pos2.latitude - pos1.latitude) * pi / 180;
    final deltaLonRad = (pos2.longitude - pos1.longitude) * pi / 180;

    final a = sin(deltaLatRad / 2) * sin(deltaLatRad / 2) +
        cos(lat1Rad) * cos(lat2Rad) *
        sin(deltaLonRad / 2) * sin(deltaLonRad / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));

    return earthRadiusKm * c;
  }

  /// Load last known position from storage
  Future<void> _loadLastKnownPosition() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final positionJson = prefs.getString(_lastPositionKey);

      if (positionJson != null) {
        final parts = positionJson.split(',');
        if (parts.length >= 2) {
          _lastKnownPosition = Position(
            latitude: double.parse(parts[0]),
            longitude: double.parse(parts[1]),
            timestamp: DateTime.now(),
            accuracy: 0.0,
            altitude: 0.0,
            altitudeAccuracy: 0.0,
            heading: 0.0,
            headingAccuracy: 0.0,
            speed: 0.0,
            speedAccuracy: 0.0,
          );
        }
      }

      final lastUpdateMs = prefs.getInt(_lastUpdateTimeKey);
      if (lastUpdateMs != null) {
        _lastUpdateTime = DateTime.fromMillisecondsSinceEpoch(lastUpdateMs);
      }
    } catch (e) {
      print('LocationTracking: Error loading last position: $e');
    }
  }

  /// Save last known position to storage
  Future<void> _saveLastKnownPosition(Position position) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_lastPositionKey, '${position.latitude},${position.longitude}');
  }

  /// Save last update time to storage
  Future<void> _saveLastUpdateTime(DateTime time) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_lastUpdateTimeKey, time.millisecondsSinceEpoch);
  }

  /// Get current tracking status for UI
  Map<String, dynamic> getTrackingStatus() {
    return {
      'isMonitoring': _isMonitoring,
      'lastKnownPosition': _lastKnownPosition != null ? {
        'latitude': _lastKnownPosition!.latitude,
        'longitude': _lastKnownPosition!.longitude,
        'timestamp': _lastKnownPosition!.timestamp.toIso8601String(),
      } : null,
      'lastUpdateTime': _lastUpdateTime?.toIso8601String(),
      'geofenceRadiusKm': geofenceRadiusKm,
      'minMovementKm': minMovementKm,
    };
  }

  /// Initialize tracking service (call from app startup)
  Future<void> initialize() async {
    // Auto-enable for ALL users (authenticated and anonymous) for proximity alerts
    // This replaces LocationUpdateManager with battery-efficient geofencing
    await setTrackingEnabled(true);
    print('LocationTracking: Auto-enabled geofence monitoring for all users (replaces battery-draining LocationUpdateManager)');
  }

  /// Stop monitoring and cleanup
  Future<void> dispose() async {
    await stopBackgroundMonitoring();
  }
}

// Global instance
final locationTrackingService = LocationTrackingService();