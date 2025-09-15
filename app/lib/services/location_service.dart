import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  static LocationService get I => _instance;

  /// Get reliable GPS coordinates using multiple fallback strategies
  /// Returns Map with 'lat' and 'lon' keys, or null if no valid coordinates available
  Future<Map<String, double>?> getReliableCoordinates({
    double? preferredLat,
    double? preferredLon,
    bool usePositionStream = true,
    Duration timeout = const Duration(seconds: 8),
  }) async {
    // Helper to validate coordinates
    bool isValidCoordinate(double? lat, double? lon) {
      if (lat == null || lon == null) return false;
      return lat.abs() > 0.001 && lon.abs() > 0.001 && lat.abs() < 90.0 && lon.abs() < 180.0;
    }

    // Strategy 1: Try preferred coordinates first
    if (isValidCoordinate(preferredLat, preferredLon)) {
      print('✅ GPS Strategy 1: Using preferred coordinates: $preferredLat, $preferredLon');
      return {'lat': preferredLat!, 'lon': preferredLon!};
    }

    // Strategy 2: High accuracy current position
    print('🔄 GPS Strategy 2: High accuracy current position...');
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 5),
      );
      
      if (isValidCoordinate(position.latitude, position.longitude)) {
        print('✅ GPS Strategy 2: Current position: ${position.latitude}, ${position.longitude}');
        return {'lat': position.latitude, 'lon': position.longitude};
      }
    } catch (e) {
      print('❌ GPS Strategy 2: Current position failed: $e');
    }

    // Strategy 3: Position stream (Flutter equivalent of watchPosition)
    if (usePositionStream) {
      print('🔄 GPS Strategy 3: Position stream...');
      try {
        await for (final Position position in Geolocator.getPositionStream(
          locationSettings: const LocationSettings(
            accuracy: LocationAccuracy.medium,
            distanceFilter: 0,
          ),
        ).timeout(timeout)) {
          if (isValidCoordinate(position.latitude, position.longitude)) {
            print('✅ GPS Strategy 3: Stream position: ${position.latitude}, ${position.longitude}');
            return {'lat': position.latitude, 'lon': position.longitude};
          }
        }
      } catch (e) {
        print('❌ GPS Strategy 3: Position stream failed: $e');
      }
    }

    // Strategy 4: Medium accuracy fallback
    print('🔄 GPS Strategy 4: Medium accuracy fallback...');
    try {
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
        timeLimit: const Duration(seconds: 3),
      );
      
      if (isValidCoordinate(position.latitude, position.longitude)) {
        print('✅ GPS Strategy 4: Medium accuracy: ${position.latitude}, ${position.longitude}');
        return {'lat': position.latitude, 'lon': position.longitude};
      }
    } catch (e) {
      print('❌ GPS Strategy 4: Medium accuracy failed: $e');
    }

    // Strategy 5: Last known position
    print('🔄 GPS Strategy 5: Last known position...');
    try {
      final Position? lastPosition = await Geolocator.getLastKnownPosition();
      if (lastPosition != null && isValidCoordinate(lastPosition.latitude, lastPosition.longitude)) {
        print('✅ GPS Strategy 5: Last known position: ${lastPosition.latitude}, ${lastPosition.longitude}');
        return {'lat': lastPosition.latitude, 'lon': lastPosition.longitude};
      }
    } catch (e) {
      print('❌ GPS Strategy 5: Last known position failed: $e');
    }

    print('❌ All GPS strategies failed - no valid coordinates available');
    return null;
  }

  /// Quick coordinate validation helper
  static bool isValidCoordinate(double? lat, double? lon) {
    if (lat == null || lon == null) return false;
    return lat.abs() > 0.001 && lon.abs() > 0.001 && lat.abs() < 90.0 && lon.abs() < 180.0;
  }

  /// Get current position with single strategy (for simple cases)
  Future<Position?> getCurrentPosition({
    LocationAccuracy accuracy = LocationAccuracy.high,
    Duration? timeLimit,
  }) async {
    try {
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: accuracy,
        timeLimit: timeLimit ?? const Duration(seconds: 10),
      );
    } catch (e) {
      print('getCurrentPosition failed: $e');
      return null;
    }
  }

  /// Check if location services are enabled and permissions granted
  Future<bool> isLocationAvailable() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        print('Location services disabled');
        return false;
      }

      final permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        print('Location permission denied: $permission');
        return false;
      }

      return true;
    } catch (e) {
      print('Location availability check failed: $e');
      return false;
    }
  }
}