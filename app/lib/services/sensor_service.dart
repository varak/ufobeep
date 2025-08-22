import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:geolocator/geolocator.dart';
import 'package:device_info_plus/device_info_plus.dart';

import '../models/sensor_data.dart';

class SensorService {
  static const Duration _sensorTimeout = Duration(seconds: 5);
  static const int _sensorSamples = 10;
  
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Request location permission for proximity alerts
  Future<bool> requestLocationPermission() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return false;
      }

      // Check permission status
      LocationPermission permission = await Geolocator.checkPermission();
      
      if (permission == LocationPermission.denied) {
        // Request permission
        permission = await Geolocator.requestPermission();
        debugPrint('Location permission requested: $permission');
      }

      final granted = permission == LocationPermission.whileInUse || 
                     permission == LocationPermission.always;
      
      if (granted) {
        debugPrint('Location permission granted for proximity alerts');
      } else {
        debugPrint('Location permission denied: $permission');
      }
      
      return granted;
    } catch (e) {
      debugPrint('Error requesting location permission: $e');
      return false;
    }
  }

  Future<SensorData> captureSensorData() async {
    try {
      // Capture all sensor readings with individual timeout handling
      Position? position;
      DeviceOrientation? orientation;
      double? hfov;

      // Capture location with its own timeout
      try {
        position = await _captureLocation().timeout(
          const Duration(seconds: 4),
          onTimeout: () {
            debugPrint('Location capture timed out');
            return null;
          },
        );
      } catch (e) {
        debugPrint('Location capture failed: $e');
        position = null;
      }

      // Capture orientation with its own timeout
      try {
        orientation = await _captureDeviceOrientation().timeout(
          const Duration(seconds: 6),
          onTimeout: () {
            debugPrint('Orientation capture timed out');
            return _getDefaultOrientation();
          },
        );
      } catch (e) {
        debugPrint('Orientation capture failed: $e');
        orientation = _getDefaultOrientation();
      }

      // Capture HFOV (this should be fast)
      try {
        hfov = await _estimateCameraHFOV().timeout(
          const Duration(seconds: 2),
          onTimeout: () => 66.0,
        );
      } catch (e) {
        debugPrint('HFOV capture failed: $e');
        hfov = 66.0;
      }

      return SensorData(
        utc: DateTime.now().toUtc(),
        latitude: position?.latitude ?? 0.0, // Default to 0.0 if no location
        longitude: position?.longitude ?? 0.0, // Default to 0.0 if no location
        accuracy: position?.accuracy ?? 0.0,
        altitude: position?.altitude ?? 0.0,
        azimuthDeg: orientation?.azimuth ?? 0.0,
        pitchDeg: orientation?.pitch ?? 0.0,
        rollDeg: orientation?.roll ?? 0.0,
        hfovDeg: hfov ?? 66.0,
      );
    } catch (e) {
      debugPrint('SensorService: Error capturing sensor data: $e');
      // Return default sensor data instead of throwing
      return SensorData(
        utc: DateTime.now().toUtc(),
        latitude: 0.0,
        longitude: 0.0,
        accuracy: 0.0,
        altitude: 0.0,
        azimuthDeg: 0.0,
        pitchDeg: 0.0,
        rollDeg: 0.0,
        hfovDeg: 66.0,
      );
    }
  }

  DeviceOrientation _getDefaultOrientation() {
    return const DeviceOrientation(
      azimuth: 0.0,
      pitch: 0.0,
      roll: 0.0,
    );
  }

  Future<Position?> _captureLocation() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        debugPrint('Location services are disabled');
        return null;
      }

      // Check permissions (should be granted during app initialization)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
        debugPrint('Location permission denied: $permission');
        return null;
      }

      // Get current position with high accuracy and shorter timeout
      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 3), // Reduced timeout
      );
    } catch (e) {
      debugPrint('Failed to get location: $e');
      return null; // Return null instead of throwing
    }
  }

  Future<DeviceOrientation> _captureDeviceOrientation() async {
    // Quick sensor availability check first
    try {
      final sensorCheck = await checkSensorAvailability().timeout(
        const Duration(seconds: 2),
        onTimeout: () => false,
      );
      
      if (!sensorCheck) {
        debugPrint('Sensors not available, using default orientation');
        return _getDefaultOrientation();
      }
    } catch (e) {
      debugPrint('Sensor check failed: $e, using default orientation');
      return _getDefaultOrientation();
    }

    StreamSubscription<AccelerometerEvent>? accelSub;
    StreamSubscription<MagnetometerEvent>? magSub;
    
    try {
      // Collect multiple samples for stability
      final List<AccelerometerEvent> accelSamples = [];
      final List<MagnetometerEvent> magSamples = [];

      final accelCompleter = Completer<void>();
      final magCompleter = Completer<void>();

      // Collect accelerometer samples
      accelSub = accelerometerEvents.listen(
        (event) {
          accelSamples.add(event);
          if (accelSamples.length >= _sensorSamples && !accelCompleter.isCompleted) {
            accelSub?.cancel();
            accelCompleter.complete();
          }
        },
        onError: (e) {
          debugPrint('Accelerometer error: $e');
          if (!accelCompleter.isCompleted) accelCompleter.complete();
        },
      );

      // Collect magnetometer samples
      magSub = magnetometerEvents.listen(
        (event) {
          magSamples.add(event);
          if (magSamples.length >= _sensorSamples && !magCompleter.isCompleted) {
            magSub?.cancel();
            magCompleter.complete();
          }
        },
        onError: (e) {
          debugPrint('Magnetometer error (likely no sensor): $e');
          if (!magCompleter.isCompleted) magCompleter.complete();
        },
      );

      // Wait for both sensors with shorter timeouts
      try {
        await Future.wait([
          accelCompleter.future.timeout(
            const Duration(seconds: 2), // Reduced timeout
            onTimeout: () {
              debugPrint('Accelerometer timeout - using partial samples: ${accelSamples.length}');
              if (!accelCompleter.isCompleted) accelCompleter.complete();
            },
          ),
          magCompleter.future.timeout(
            const Duration(seconds: 2), // Reduced timeout
            onTimeout: () {
              debugPrint('Magnetometer timeout (no sensor) - using partial samples: ${magSamples.length}');
              if (!magCompleter.isCompleted) magCompleter.complete();
            },
          ),
        ]);
      } catch (e) {
        debugPrint('Sensor timeout or error: $e');
        // Continue with whatever samples we have
      }

      // Use accelerometer-only orientation if no magnetometer
      if (accelSamples.isEmpty) {
        debugPrint('No accelerometer samples, using default orientation');
        return _getDefaultOrientation();
      }
      
      if (magSamples.isEmpty) {
        debugPrint('No magnetometer samples, using accelerometer-only orientation');
        return _calculateOrientationAccelOnly(accelSamples);
      }

      // Calculate averaged readings with both sensors
      return _calculateOrientation(accelSamples, magSamples);
    } catch (e) {
      debugPrint('Failed to capture device orientation: $e');
      return _getDefaultOrientation();
    } finally {
      // Always cleanup subscriptions
      accelSub?.cancel();
      magSub?.cancel();
    }
  }

  /// Calculate orientation using only accelerometer (for devices without magnetometer)
  DeviceOrientation _calculateOrientationAccelOnly(List<AccelerometerEvent> accelSamples) {
    // Average the accelerometer readings
    double avgAccelX = accelSamples.map((e) => e.x).reduce((a, b) => a + b) / accelSamples.length;
    double avgAccelY = accelSamples.map((e) => e.y).reduce((a, b) => a + b) / accelSamples.length;
    double avgAccelZ = accelSamples.map((e) => e.z).reduce((a, b) => a + b) / accelSamples.length;

    // Calculate pitch (elevation angle)
    final pitch = atan2(-avgAccelX, sqrt(avgAccelY * avgAccelY + avgAccelZ * avgAccelZ));
    final pitchDeg = pitch * 180 / pi;

    // Calculate roll
    final roll = atan2(avgAccelY, avgAccelZ);
    final rollDeg = roll * 180 / pi;

    return DeviceOrientation(
      azimuth: 0.0, // No compass heading without magnetometer
      pitch: pitchDeg,
      roll: rollDeg,
    );
  }

  DeviceOrientation _calculateOrientation(
    List<AccelerometerEvent> accelSamples,
    List<MagnetometerEvent> magSamples,
  ) {
    // Average the sensor readings for stability
    double avgAccelX = accelSamples.map((e) => e.x).reduce((a, b) => a + b) / accelSamples.length;
    double avgAccelY = accelSamples.map((e) => e.y).reduce((a, b) => a + b) / accelSamples.length;
    double avgAccelZ = accelSamples.map((e) => e.z).reduce((a, b) => a + b) / accelSamples.length;

    double avgMagX = magSamples.map((e) => e.x).reduce((a, b) => a + b) / magSamples.length;
    double avgMagY = magSamples.map((e) => e.y).reduce((a, b) => a + b) / magSamples.length;
    double avgMagZ = magSamples.map((e) => e.z).reduce((a, b) => a + b) / magSamples.length;

    // Calculate pitch (elevation angle)
    final pitch = atan2(-avgAccelX, sqrt(avgAccelY * avgAccelY + avgAccelZ * avgAccelZ));
    final pitchDeg = pitch * 180 / pi;

    // Calculate roll
    final roll = atan2(avgAccelY, avgAccelZ);
    final rollDeg = roll * 180 / pi;

    // Calculate azimuth (compass heading)
    // Apply tilt compensation
    final cosRoll = cos(roll);
    final sinRoll = sin(roll);
    final cosPitch = cos(pitch);
    final sinPitch = sin(pitch);

    final magXComp = avgMagX * cosPitch + avgMagZ * sinPitch;
    final magYComp = avgMagX * sinRoll * sinPitch + avgMagY * cosRoll - avgMagZ * sinRoll * cosPitch;

    // Calculate azimuth
    double azimuth = atan2(-magYComp, magXComp);
    double azimuthDeg = azimuth * 180 / pi;

    // Normalize to 0-360 degrees
    if (azimuthDeg < 0) azimuthDeg += 360;

    return DeviceOrientation(
      azimuth: azimuthDeg,
      pitch: pitchDeg,
      roll: rollDeg,
    );
  }

  Future<double?> _estimateCameraHFOV() async {
    try {
      // Get device info to estimate camera specs
      if (defaultTargetPlatform == TargetPlatform.android) {
        final androidInfo = await _deviceInfo.androidInfo;
        return _estimateHFOVFromDevice(androidInfo.model, androidInfo.manufacturer);
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return _estimateHFOVFromDevice(iosInfo.model, 'Apple');
      }
      return null;
    } catch (e) {
      debugPrint('SensorService: Could not estimate HFOV: $e');
      return null;
    }
  }

  double? _estimateHFOVFromDevice(String model, String manufacturer) {
    // Common device HFOV estimates (in degrees)
    // These are approximations based on typical camera specs
    final Map<String, double> deviceHFOV = {
      // iPhone models
      'iPhone': 65.0,
      'iPad': 60.0,
      
      // Common Android manufacturers
      'samsung': 68.0,
      'google': 67.0,
      'pixel': 67.0,
      'huawei': 66.0,
      'xiaomi': 67.0,
      'oneplus': 68.0,
      'lg': 65.0,
      'sony': 64.0,
      'motorola': 66.0,
    };

    // Try to match device
    final modelLower = model.toLowerCase();
    final manufacturerLower = manufacturer.toLowerCase();

    for (final entry in deviceHFOV.entries) {
      if (modelLower.contains(entry.key) || manufacturerLower.contains(entry.key)) {
        return entry.value;
      }
    }

    // Default estimate for unknown devices
    return 66.0;
  }

  Future<bool> checkSensorAvailability() async {
    try {
      // Test if sensors are available by attempting to get a reading
      final accelCompleter = Completer<bool>();
      final magCompleter = Completer<bool>();

      late StreamSubscription<AccelerometerEvent> accelSub;
      late StreamSubscription<MagnetometerEvent> magSub;

      accelSub = accelerometerEvents.listen((event) {
        accelSub.cancel();
        accelCompleter.complete(true);
      });

      magSub = magnetometerEvents.listen((event) {
        magSub.cancel();
        magCompleter.complete(true);
      });

      final results = await Future.wait([
        accelCompleter.future.timeout(const Duration(seconds: 2), onTimeout: () => false),
        magCompleter.future.timeout(const Duration(seconds: 2), onTimeout: () => false),
      ]);

      return results.every((available) => available);
    } catch (e) {
      debugPrint('SensorService: Sensor availability check failed: $e');
      return false;
    }
  }
}

class DeviceOrientation {
  final double azimuth;  // Compass heading (0-360°)
  final double pitch;    // Elevation angle (-90 to +90°)
  final double roll;     // Device roll (-180 to +180°)

  const DeviceOrientation({
    required this.azimuth,
    required this.pitch,
    required this.roll,
  });

  @override
  String toString() => 'DeviceOrientation(azimuth: ${azimuth.toStringAsFixed(1)}°, pitch: ${pitch.toStringAsFixed(1)}°, roll: ${roll.toStringAsFixed(1)}°)';
}