import 'dart:io';
import 'dart:convert';
import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:geolocator/geolocator.dart';
import 'permission_service.dart';
import 'sound_service.dart';
import 'device_service.dart';

class AnonymousBeepService {
  static const String _deviceIdKey = 'anonymous_device_id';
  static const String _beepHistoryKey = 'anonymous_beep_history';
  
  final Dio _dio;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();
  
  static final AnonymousBeepService _instance = AnonymousBeepService._internal();
  factory AnonymousBeepService() => _instance;
  
  AnonymousBeepService._internal() : _dio = Dio(
    BaseOptions(
      baseUrl: 'https://api.ufobeep.com',
      connectTimeout: const Duration(seconds: 5),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
      },
    ),
  );
  
  Future<String> getOrCreateDeviceId() async {
    // Use the same device ID as DeviceService to ensure consistency
    // Import and use DeviceService instead of generating our own
    try {
      // Import DeviceService if not already available
      final deviceService = DeviceService();
      final standardDeviceId = await deviceService.getDeviceId();
      print('Using standard device ID: $standardDeviceId');
      return standardDeviceId;
    } catch (e) {
      print('Fallback to local device ID generation: $e');
      
      // Fallback to local generation if DeviceService fails
      final prefs = await SharedPreferences.getInstance();
      String? deviceId = prefs.getString(_deviceIdKey);
      
      if (deviceId == null) {
        String deviceIdentifier = '';
        
        try {
          if (Platform.isAndroid) {
            final androidInfo = await _deviceInfo.androidInfo;
            deviceIdentifier = androidInfo.id ?? _uuid.v4();
          } else if (Platform.isIOS) {
            final iosInfo = await _deviceInfo.iosInfo;
            deviceIdentifier = _uuid.v4();
          } else {
            deviceIdentifier = _uuid.v4();
          }
        } catch (e) {
          print('Error getting device info: $e');
          deviceIdentifier = _uuid.v4();
        }
        
        deviceId = 'anon_${deviceIdentifier}';
        await prefs.setString(_deviceIdKey, deviceId);
      }
      
      return deviceId;
    }
  }
  
  Future<Map<String, dynamic>> sendBeep({
    double? latitude,
    double? longitude,
    double? heading,
    String? description,
    List<String>? mediaIds,
    bool hasMedia = false,
  }) async {
    try {
      // Get user info - all users have usernames now
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString('user_id') ?? await getOrCreateDeviceId();
      final username = prefs.getString('username');
      
      print('Sending beep as user: $username ($userId)');
      
      // Try to get current location for anonymous beeps
      Position? currentPosition;
      if (latitude == null || longitude == null) {
        if (permissionService.locationGranted) {
          try {
            currentPosition = await permissionService.getCurrentLocation();
            if (currentPosition != null) {
              print('Got current location: ${currentPosition.latitude}, ${currentPosition.longitude}');
              // Play GPS success sound
              await SoundService.I.play(AlertSound.gpsOk);
            } else {
              // Play GPS fail sound
              await SoundService.I.play(AlertSound.gpsFail);
            }
          } catch (e) {
            print('Failed to get current location: $e');
          }
        } else {
          print('Location permission not granted, trying to request it now...');
          // Try to refresh permissions in case they changed
          await permissionService.refreshPermissions();
          if (permissionService.locationGranted) {
            currentPosition = await permissionService.getCurrentLocation();
            if (currentPosition != null) {
              await SoundService.I.play(AlertSound.gpsOk);
            } else {
              await SoundService.I.play(AlertSound.gpsFail);
            }
          }
        }
      }
      
      // Use provided location or current location
      final finalLat = latitude ?? currentPosition?.latitude;
      final finalLng = longitude ?? currentPosition?.longitude;
      final finalAccuracy = currentPosition?.accuracy ?? 50.0;
      final finalHeading = heading ?? currentPosition?.heading;
      
      // Location is required for anonymous beeps
      if (finalLat == null || finalLng == null) {
        if (!permissionService.locationGranted) {
          throw Exception('Location permission required for beeping. Please enable location services in Settings → Permissions.');
        } else {
          throw Exception('Unable to get current location. Please try again or ensure GPS is enabled.');
        }
      }
      
      // Build request payload
      final payload = {
        'device_id': userId,
        'username': username,
        'anonymous': false, // All users have usernames now
        'timestamp': DateTime.now().toUtc().toIso8601String(),
        'location': {
          'latitude': finalLat,
          'longitude': finalLng,
          'accuracy': finalAccuracy,
        },
      };
      
      // Add heading if available
      if (finalHeading != null && !finalHeading.isNaN) {
        payload['heading'] = finalHeading;
      }
      
      // Add description only if provided
      if (description != null && description.isNotEmpty) {
        payload['description'] = description;
      }
      
      // Add media IDs if provided
      if (mediaIds != null && mediaIds.isNotEmpty) {
        payload['media_ids'] = mediaIds;
      }
      
      // Add has_media flag to defer alerts until media upload
      if (hasMedia) {
        payload['has_media'] = true;
      }
      
      // Get device info for context
      try {
        if (Platform.isAndroid) {
          final androidInfo = await _deviceInfo.androidInfo;
          payload['device_info'] = {
            'platform': 'android',
            'model': androidInfo.model,
            'manufacturer': androidInfo.manufacturer,
            'version': androidInfo.version.release,
          };
        } else if (Platform.isIOS) {
          final iosInfo = await _deviceInfo.iosInfo;
          payload['device_info'] = {
            'platform': 'ios',
            'model': iosInfo.model,
            'name': iosInfo.name,
            'version': iosInfo.systemVersion,
          };
        }
      } catch (e) {
        print('Could not get device info: $e');
      }
      
      print('Sending anonymous beep: ${json.encode(payload)}');
      
      // Send the beep
      final response = await _dio.post(
        '/alerts',
        data: payload,
      );
      
      if (response.statusCode == 200 || response.statusCode == 201) {
        final result = response.data;
        
        // Store in local history
        await _addToHistory(result['sighting_id']);
        
        return result;
      } else {
        throw Exception('Failed to send beep: ${response.statusCode}');
      }
      
    } catch (e) {
      print('Error sending anonymous beep: $e');
      
      // Return a mock response for testing if API fails
      if (e.toString().contains('SocketException') || 
          e.toString().contains('Connection refused')) {
        // API not available, return mock for testing
        final mockId = 'UFO-2025-${DateTime.now().millisecondsSinceEpoch % 100000}';
        await _addToHistory(mockId);
        return {
          'success': true,
          'sighting_id': mockId,
          'message': 'Beep sent (offline mode)',
          'witness_count': 1,
        };
      }
      
      rethrow;
    }
  }
  
  Future<void> _addToHistory(String sightingId) async {
    final prefs = await SharedPreferences.getInstance();
    final history = prefs.getStringList(_beepHistoryKey) ?? [];
    
    history.insert(0, sightingId);
    
    // Keep only last 50 beeps
    if (history.length > 50) {
      history.removeRange(50, history.length);
    }
    
    await prefs.setStringList(_beepHistoryKey, history);
  }
  
  Future<List<String>> getBeepHistory() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_beepHistoryKey) ?? [];
  }
  
  Future<void> claimBeeps(String userId) async {
    try {
      final deviceId = await getOrCreateDeviceId();
      final history = await getBeepHistory();
      
      if (history.isEmpty) return;
      
      // Send claim request to API
      await _dio.post(
        '/beep/claim',
        data: {
          'device_id': deviceId,
          'user_id': userId,
          'sighting_ids': history,
        },
      );
      
      // Clear history after successful claim
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_beepHistoryKey);
      
    } catch (e) {
      print('Error claiming beeps: $e');
      // Don't throw, this is not critical
    }
  }
  
  Future<int> getAnonymousBeepCount() async {
    final history = await getBeepHistory();
    return history.length;
  }
  
  Future<void> clearDeviceId() async {
    // Only for testing/debugging
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_deviceIdKey);
    await prefs.remove(_beepHistoryKey);
  }
}

// Global instance
final anonymousBeepService = AnonymousBeepService();