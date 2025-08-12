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

  Future<SensorData> captureSensorData() async {
    try {
      // Capture all sensor readings in parallel (location can fail)
      final results = await Future.wait([
        _captureLocation(),
        _captureDeviceOrientation(),
        _estimateCameraHFOV(),
      ], eagerError: false); // Don't fail if location fails

      final position = results[0] as Position?;
      final orientation = results[1] as DeviceOrientation;
      final hfov = results[2] as double?;

      return SensorData(
        utc: DateTime.now().toUtc(),
        latitude: position?.latitude ?? 0.0, // Default to 0.0 if no location
        longitude: position?.longitude ?? 0.0, // Default to 0.0 if no location
        accuracy: position?.accuracy ?? 0.0,
        altitude: position?.altitude ?? 0.0,
        azimuthDeg: orientation.azimuth,
        pitchDeg: orientation.pitch,
        rollDeg: orientation.roll,
        hfovDeg: hfov,
      );
    } catch (e) {
      debugPrint('SensorService: Error capturing sensor data: $e');
      rethrow;
    }
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
    try {
      // Collect multiple samples for stability
      final List<AccelerometerEvent> accelSamples = [];
      final List<MagnetometerEvent> magSamples = [];

      final accelCompleter = Completer<void>();
      final magCompleter = Completer<void>();

      // Collect accelerometer samples
      late StreamSubscription<AccelerometerEvent> accelSub;
      accelSub = accelerometerEvents.listen((event) {
        accelSamples.add(event);
        if (accelSamples.length >= _sensorSamples) {
          accelSub.cancel();
          accelCompleter.complete();
        }
      });

      // Collect magnetometer samples
      late StreamSubscription<MagnetometerEvent> magSub;
      magSub = magnetometerEvents.listen((event) {
        magSamples.add(event);
        if (magSamples.length >= _sensorSamples) {
          magSub.cancel();
          magCompleter.complete();
        }
      });

      // Wait for both sensors with timeout
      await Future.wait([
        accelCompleter.future.timeout(_sensorTimeout),
        magCompleter.future.timeout(_sensorTimeout),
      ]);

      // Calculate averaged readings
      return _calculateOrientation(accelSamples, magSamples);
    } catch (e) {
      throw Exception('Failed to capture device orientation: $e');
    }
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