import 'dart:async';
import 'dart:convert';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'auth_repository.dart';

/// LocationUpdateManager handles battery-efficient location updates
/// Uses OS distance filter (1km) + 15-minute throttle to minimize battery impact
/// Sends location updates to server only when significant movement occurs
class LocationUpdateManager {
  final AuthRepository auth;
  final String baseUrl;
  
  StreamSubscription<Position>? _locationSubscription;
  Position? _lastSentPosition;
  DateTime? _lastSentAt;
  bool _isStarted = false;
  
  static const int _minimumDistanceMeters = 1000; // 1km
  static const Duration _minimumTimeInterval = Duration(minutes: 15); // 15min throttle

  LocationUpdateManager({
    required this.auth, 
    required this.baseUrl,
  });

  /// Haversine distance calculation in meters
  static double _distanceInMeters(Position a, Position b) {
    const double earthRadiusM = 6371000.0;
    
    double dLatRad = (b.latitude - a.latitude) * math.pi / 180.0;
    double dLonRad = (b.longitude - a.longitude) * math.pi / 180.0;
    double lat1Rad = a.latitude * math.pi / 180.0;
    double lat2Rad = b.latitude * math.pi / 180.0;
    
    double a_val = math.sin(dLatRad / 2) * math.sin(dLatRad / 2) +
        math.cos(lat1Rad) * math.cos(lat2Rad) *
        math.sin(dLonRad / 2) * math.sin(dLonRad / 2);
    
    double c = 2 * math.asin(math.min(1.0, math.sqrt(a_val)));
    
    return earthRadiusM * c;
  }

  /// Start location monitoring with battery-efficient settings
  Future<void> start() async {
    if (_isStarted) {
      print('📍 LocationUpdateManager: Already started');
      return;
    }

    // Check location services
    if (!await Geolocator.isLocationServiceEnabled()) {
      print('📍 LocationUpdateManager: Location services disabled');
      return;
    }

    // Check/request permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    
    if (permission == LocationPermission.denied || 
        permission == LocationPermission.deniedForever) {
      print('📍 LocationUpdateManager: Location permission denied');
      return;
    }

    print('📍 LocationUpdateManager: Starting with 1km distance filter + 15min throttle');

    // Seed with last known position (no network call yet)
    try {
      final lastKnown = await Geolocator.getLastKnownPosition();
      if (lastKnown != null && _isValidCoordinate(lastKnown)) {
        _lastSentPosition = lastKnown;
        _lastSentAt = DateTime.now();
        print('📍 LocationUpdateManager: Seeded with last known: ${lastKnown.latitude}, ${lastKnown.longitude}');
      }
    } catch (e) {
      print('📍 LocationUpdateManager: Error getting last known position: $e');
    }

    // Configure location settings with OS-level distance filter
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: _minimumDistanceMeters, // 1km OS-level threshold
    );

    // Start listening to position updates
    await _locationSubscription?.cancel();
    _locationSubscription = Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen(_onPositionUpdate, onError: _onLocationError);
    
    _isStarted = true;
    print('📍 LocationUpdateManager: Started location stream');
  }

  /// Handle new position updates with throttling and distance filtering
  Future<void> _onPositionUpdate(Position position) async {
    print('📍 LocationUpdateManager: Position update: ${position.latitude}, ${position.longitude}');
    
    // Validate coordinates
    if (!_isValidCoordinate(position)) {
      print('📍 LocationUpdateManager: Invalid coordinates received, ignoring');
      return;
    }

    // Time throttle: max 1 update per 15 minutes unless significant movement
    if (_lastSentAt != null) {
      final timeSinceLastSent = DateTime.now().difference(_lastSentAt!);
      if (timeSinceLastSent < _minimumTimeInterval) {
        // Check if movement is significant enough to override time throttle
        if (_lastSentPosition != null) {
          final distanceM = _distanceInMeters(_lastSentPosition!, position);
          if (distanceM < _minimumDistanceMeters) {
            print('📍 LocationUpdateManager: Throttled - ${timeSinceLastSent.inMinutes}min < 15min, distance ${distanceM.round()}m < 1km');
            return;
          }
        }
      }
    }

    // Distance filter: must be ≥1km from last sent position
    if (_lastSentPosition != null) {
      final distanceM = _distanceInMeters(_lastSentPosition!, position);
      if (distanceM < _minimumDistanceMeters) {
        print('📍 LocationUpdateManager: Distance filter - ${distanceM.round()}m < ${_minimumDistanceMeters}m');
        return;
      }
    }

    // Send location update to server
    await _sendLocationUpdate(position);
  }

  /// Send location update to API server
  Future<void> _sendLocationUpdate(Position position) async {
    try {
      final accessToken = await auth.getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        print('📍 LocationUpdateManager: No access token available');
        return;
      }

      print('📍 LocationUpdateManager: 🚀 Sending location update: ${position.latitude}, ${position.longitude}');

      final response = await http.post(
        Uri.parse('$baseUrl/devices/update-location'),
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
        // Success!
        _lastSentPosition = position;
        _lastSentAt = DateTime.now();
        print('✅ LocationUpdateManager: Location updated successfully');
      } else {
        print('❌ LocationUpdateManager: Update failed - ${response.statusCode}: ${response.body}');
      }
    } catch (e) {
      print('❌ LocationUpdateManager: Network error: $e');
    }
  }

  /// Handle location stream errors
  void _onLocationError(Object error) {
    print('❌ LocationUpdateManager: Location stream error: $error');
  }

  /// Validate coordinates are not null/zero
  bool _isValidCoordinate(Position position) {
    return position.latitude.abs() > 0.0001 && position.longitude.abs() > 0.0001;
  }

  /// Stop location monitoring
  Future<void> stop() async {
    if (!_isStarted) return;
    
    await _locationSubscription?.cancel();
    _locationSubscription = null;
    _isStarted = false;
    
    print('📍 LocationUpdateManager: Stopped');
  }

  /// Manually trigger location update (for testing)
  Future<void> forceLocationUpdate() async {
    if (!_isStarted) {
      print('📍 LocationUpdateManager: Not started, cannot force update');
      return;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
      
      if (_isValidCoordinate(position)) {
        await _sendLocationUpdate(position);
      }
    } catch (e) {
      print('❌ LocationUpdateManager: Force update failed: $e');
    }
  }

  /// Check if manager is actively monitoring location
  bool get isActive => _isStarted && _locationSubscription != null;
  
  /// Get last sent position information
  Map<String, dynamic>? get lastSentInfo {
    if (_lastSentPosition == null || _lastSentAt == null) return null;
    
    return {
      'latitude': _lastSentPosition!.latitude,
      'longitude': _lastSentPosition!.longitude,
      'timestamp': _lastSentAt!.toIso8601String(),
      'age_minutes': DateTime.now().difference(_lastSentAt!).inMinutes,
    };
  }

  void dispose() {
    stop();
  }
}