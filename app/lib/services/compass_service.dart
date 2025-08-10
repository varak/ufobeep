import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:sensors_plus/sensors_plus.dart';

import '../models/compass_data.dart';
import '../models/pilot_data.dart';
import 'compass_math.dart';

class CompassService {
  static final CompassService _instance = CompassService._internal();
  factory CompassService() => _instance;
  CompassService._internal();

  StreamController<CompassData>? _compassController;
  StreamSubscription<MagnetometerEvent>? _magnetometerSubscription;
  StreamSubscription<AccelerometerEvent>? _accelerometerSubscription;
  StreamSubscription<Position>? _locationSubscription;
  
  CompassData? _lastCompassData;
  LocationData? _currentLocation;
  double _declination = 0.0; // Magnetic declination for true north calculation
  
  // Sensor data for tilt compensation
  double _accelerometerX = 0.0;
  double _accelerometerY = 0.0;
  double _accelerometerZ = 0.0;
  
  // Heading stability tracking
  final List<double> _recentHeadings = [];
  final int _maxHeadingHistory = 10;
  
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
      
      // Start sensor updates
      await _startMagnetometerUpdates();
      await _startAccelerometerUpdates();
      
      debugPrint('Compass service started');
    } catch (e) {
      debugPrint('Error starting compass service: $e');
      rethrow;
    }
  }

  Future<void> stopListening() async {
    await _magnetometerSubscription?.cancel();
    await _accelerometerSubscription?.cancel();
    await _locationSubscription?.cancel();
    _magnetometerSubscription = null;
    _accelerometerSubscription = null;
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
      
      // Update magnetic declination using improved model
      _declination = CompassMath.calculateMagneticDeclination(
        position.latitude, 
        position.longitude
      );
      
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

  Future<void> _startAccelerometerUpdates() async {
    _accelerometerSubscription = accelerometerEvents.listen(
      (AccelerometerEvent event) {
        _accelerometerX = event.x;
        _accelerometerY = event.y;
        _accelerometerZ = event.z;
      },
      onError: (error) {
        debugPrint('Accelerometer error: $error');
      },
    );
  }

  void _processMagnetometerData(double x, double y, double z) {
    // Calculate magnetic heading with tilt compensation
    double magneticHeading = CompassMath.calculateHeadingFromMagnetometer(
      x, y, z,
      accelerometerX: _accelerometerX,
      accelerometerY: _accelerometerY,
      accelerometerZ: _accelerometerZ,
    );
    
    // Normalize to 0-360 range
    magneticHeading = CompassMath.normalizeHeading(magneticHeading);
    
    // Calculate true heading using magnetic declination
    double trueHeading = CompassMath.normalizeHeading(magneticHeading + _declination);
    
    // Track heading history for stability analysis
    _recentHeadings.add(trueHeading);
    if (_recentHeadings.length > _maxHeadingHistory) {
      _recentHeadings.removeAt(0);
    }
    
    // Calculate accuracy based on field strength and stability
    final strength = math.sqrt(x * x + y * y + z * z);
    final accuracy = CompassMath.calculateCompassAccuracy(
      strength,
      _recentHeadings,
    );
    final calibration = _assessCalibrationLevel(strength, accuracy);
    
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

  CompassCalibrationLevel _assessCalibrationLevel(double magneticStrength, double accuracy) {
    // Assess calibration based on both field strength and calculated accuracy
    const normalStrength = 50.0;
    
    if (magneticStrength < 20.0 || magneticStrength > 80.0 || accuracy > 30.0) {
      return CompassCalibrationLevel.low;
    } else if (magneticStrength > normalStrength * 0.85 && 
               magneticStrength < normalStrength * 1.15 && 
               accuracy < 10.0) {
      return CompassCalibrationLevel.high;
    } else if (accuracy < 20.0) {
      return CompassCalibrationLevel.medium;
    } else {
      return CompassCalibrationLevel.low;
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

  // Create navigation solution for pilot mode
  NavigationSolution? createNavigationSolution(CompassTarget target) {
    if (_currentLocation == null || _lastCompassData == null) return null;
    
    final distance = _currentLocation!.distanceTo(target.location);
    final bearing = _lastCompassData!.bearingToTarget(target.location);
    final magneticBearing = bearing - _declination;
    final relativeBearing = _lastCompassData!.relativeBearing(target.location);
    
    // Calculate ETE based on mock ground speed
    const groundSpeedMS = 25.0; // 50 knots = ~25 m/s
    final eteSeconds = distance / groundSpeedMS;
    final estimatedTimeEnroute = Duration(seconds: eteSeconds.round());
    
    return NavigationSolution(
      target: target,
      distance: distance,
      bearing: bearing,
      magneticBearing: magneticBearing,
      relativeBearing: relativeBearing,
      estimatedTimeEnroute: estimatedTimeEnroute,
      desiredTrack: bearing,
      trackError: 0.0, // On track for direct navigation
      requiredHeading: bearing, // No wind correction in mock
    );
  }

  // Get mock pilot navigation data
  PilotNavigationData getMockPilotData() {
    final compassData = getMockCompassData();
    final target = getMockTarget();
    final solution = createNavigationSolution(target);
    
    return PilotNavigationData(
      compass: compassData,
      groundSpeed: 25.0, // 50 knots
      trueAirspeed: 27.0, // 52 knots
      altitude: 305.0, // 1000 feet
      verticalSpeed: 2.5, // 500 fpm climb
      bankAngle: -15.0, // Left turn
      pitchAngle: 5.0, // Slight climb
      wind: WindData(
        direction: 270.0, // From west
        speed: 10.0, // 20 knots
        accuracy: WindAccuracy.estimated,
        timestamp: DateTime.now(),
      ),
      solution: solution,
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