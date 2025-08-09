import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/compass_data.dart';

class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  StreamController<CompassData>? _compassController;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<Position>? _locationSubscription;
  
  CompassData? _lastCompassData;
  LocationData? _currentLocation;
  double _declination = 0.0; // Magnetic declination for true north calculation
  
  Stream<CompassData> get compassStream {
    _compassController ??= StreamController<CompassData>.broadcast();
    return _compassController!.stream;
  }

  bool get isActive => _magnetometerSubscription != null;

  Future<void> startListening() async {
    if (isActive) return;

    try {
      // Start location updates
      await _startLocationUpdates();
      
      // Start magnetometer updates
      await _startMagnetometerUpdates();
      
      debugPrint('Compass service started');
    } catch (e) {
      debugPrint('Error starting compass service: $e');
      rethrow;
    }
  }

  Future<void> stopListening() async {
    await _magnetometerSubscription?.cancel();
    await _locationSubscription?.cancel();
    _magnetometerSubscription = null;
    _locationSubscription = null;
    
    debugPrint('Compass service stopped');
  }

  Future<void> _startLocationUpdates() async {
    // Check permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception('Location permissions are permanently denied');
    }

    // Start location stream
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 1, // Update every meter
    );

    _locationSubscription = Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen((position) {
      _currentLocation = LocationData(
        latitude: position.latitude,
        longitude: position.longitude,
        altitude: position.altitude,
        accuracy: position.accuracy,
        timestamp: DateTime.now(),
      );
      
      // Update magnetic declination based on location
      _updateMagneticDeclination(position.latitude, position.longitude);
      
      // Recalculate compass data with new location
      _updateCompassData();
    });
  }

  Future<void> _startMagnetometerUpdates() async {
    _magnetometerSubscription = magnetometerEvents.listen(
      (MagnetometerEvent event) {
        _processMagnetometerData(event.x, event.y, event.z);
      },
      onError: (error) {
        debugPrint('Magnetometer error: $error');
      },
    );
  }

  void _processMagnetometerData(double x, double y, double z) {
    // Calculate magnetic heading from magnetometer data
    double magneticHeading = math.atan2(y, x) * 180 / math.pi;
    
    // Normalize to 0-360 range
    if (magneticHeading < 0) {
      magneticHeading += 360;
    }
    
    // Calculate true heading using magnetic declination
    double trueHeading = magneticHeading + _declination;
    if (trueHeading >= 360) trueHeading -= 360;
    if (trueHeading < 0) trueHeading += 360;
    
    // Calculate accuracy based on magnetometer strength
    final strength = math.sqrt(x * x + y * y + z * z);
    final accuracy = _calculateAccuracy(strength);
    final calibration = _assessCalibrationLevel(strength);
    
    _lastCompassData = CompassData(
      magneticHeading: magneticHeading,
      trueHeading: trueHeading,
      accuracy: accuracy,
      timestamp: DateTime.now(),
      calibration: calibration,
      location: _currentLocation,
    );
    
    _compassController?.add(_lastCompassData!);
  }

  void _updateCompassData() {
    if (_lastCompassData != null) {
      final updatedData = _lastCompassData!.copyWith(
        location: _currentLocation,
      );
      _compassController?.add(updatedData);
    }
  }

  void _updateMagneticDeclination(double latitude, double longitude) {
    // Simplified magnetic declination calculation
    // In a real app, you'd use a more accurate model like WMM (World Magnetic Model)
    // This is a very rough approximation for demonstration
    
    // Basic approximation: varies roughly with longitude
    _declination = longitude * 0.1; // Very rough estimate
    
    // Clamp to reasonable range
    if (_declination > 30) _declination = 30;
    if (_declination < -30) _declination = -30;
  }

  double _calculateAccuracy(double magneticStrength) {
    // Normal Earth's magnetic field strength is around 25-65 μT
    // Magnetometer usually returns values in μT
    const normalStrength = 50.0;
    const minStrength = 20.0;
    const maxStrength = 80.0;
    
    if (magneticStrength < minStrength || magneticStrength > maxStrength) {
      return 45.0; // Poor accuracy
    } else if (magneticStrength > normalStrength * 0.8 && 
               magneticStrength < normalStrength * 1.2) {
      return 5.0; // Excellent accuracy
    } else {
      return 15.0; // Good accuracy
    }
  }

  CompassCalibrationLevel _assessCalibrationLevel(double magneticStrength) {
    const normalStrength = 50.0;
    
    if (magneticStrength < 20.0 || magneticStrength > 80.0) {
      return CompassCalibrationLevel.low;
    } else if (magneticStrength > normalStrength * 0.9 && 
               magneticStrength < normalStrength * 1.1) {
      return CompassCalibrationLevel.high;
    } else {
      return CompassCalibrationLevel.medium;
    }
  }

  // Create a target from an alert location
  CompassTarget createTargetFromAlert(String alertId, String title, double latitude, double longitude) {
    final targetLocation = LocationData(
      latitude: latitude,
      longitude: longitude,
      accuracy: 10.0,
      timestamp: DateTime.now(),
    );

    double? distance;
    if (_currentLocation != null) {
      distance = _currentLocation!.distanceTo(targetLocation);
    }

    return CompassTarget(
      id: alertId,
      name: title,
      description: 'UFO Alert Location',
      location: targetLocation,
      type: TargetType.alert,
      distance: distance,
      status: CompassTargetStatus.active,
    );
  }

  // Get mock compass data for testing
  CompassData getMockCompassData() {
    final now = DateTime.now();
    return CompassData(
      magneticHeading: 45.0,
      trueHeading: 47.0,
      accuracy: 8.0,
      timestamp: now,
      calibration: CompassCalibrationLevel.high,
      location: LocationData(
        latitude: 40.7128,
        longitude: -74.0060,
        altitude: 10.0,
        accuracy: 5.0,
        timestamp: now,
      ),
    );
  }

  // Get mock target for testing
  CompassTarget getMockTarget() {
    return CompassTarget(
      id: 'test-alert-1',
      name: 'UFO Sighting',
      description: 'Bright object reported moving erratically',
      location: LocationData(
        latitude: 40.7589,
        longitude: -73.9851,
        accuracy: 10.0,
        timestamp: DateTime.now(),
      ),
      type: TargetType.alert,
      distance: 5420.0,
      status: CompassTargetStatus.active,
      estimatedArrival: DateTime.now().add(const Duration(minutes: 8)),
    );
  }

  void dispose() {
    stopListening();
    _compassController?.close();
    _compassController = null;
  }
}

// Provider for Riverpod integration
final compassServiceProvider = Provider<CompassService>((ref) {
  final service = CompassService();
  ref.onDispose(() => service.dispose());
  return service;
});

final compassDataProvider = StreamProvider<CompassData>((ref) {
  final service = ref.watch(compassServiceProvider);
  return service.compassStream;
});