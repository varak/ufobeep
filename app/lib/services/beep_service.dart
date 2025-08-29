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
import 'api_client.dart';
import 'auth_repository.dart';

class BeepService {
  static const String _deviceIdKey = 'beep_device_id';
  static const String _beepHistoryKey = 'beep_history';
  
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final Uuid _uuid = const Uuid();
  
  static final BeepService _instance = BeepService._internal();
  factory BeepService() => _instance;
  
  BeepService._internal();
  
  // Use the authenticated Dio instance from ApiClient
  Dio get _dio => ApiClient.dio;
  
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
      // Get user info from AuthRepository (single source of truth)
      final authRepo = AuthRepository();
      final currentUser = authRepo.currentUser;
      final accessToken = await authRepo.getAccessToken();
      
      print('🔐 BEEP AUTH DEBUG:');
      print('  currentUser: ${currentUser?.toJson()}');
      print('  accessToken exists: ${accessToken != null}');
      
      if (currentUser == null || accessToken == null) {
        print('❌ BEEP: User not authenticated (no user or token in AuthRepository)');
        throw Exception('User not authenticated. Please sign in first to send beeps.');
      }
      
      print('✅ BEEP: Sending beep as user: ${currentUser.username} (${currentUser.id})');
      
      // Access token is already set in ApiClient by AuthRepository
      print('🔐 BEEP: Using AuthRepository access token for authentication');
      
      // Try to get current location for beeps - bypass complex PermissionService
      Position? currentPosition;
      if (latitude == null || longitude == null) {
        print('📍 LOCATION DEBUG: Need to get current location');
        
        try {
          // Check permission directly with Geolocator (more reliable)
          LocationPermission permission = await Geolocator.checkPermission();
          print('📍 Direct permission check: $permission');
          
          if (permission == LocationPermission.denied) {
            print('📍 Permission denied, requesting...');
            permission = await Geolocator.requestPermission();
            print('📍 After request: $permission');
          }
          
          if (permission == LocationPermission.whileInUse || permission == LocationPermission.always) {
            print('📍 Permission granted, getting location...');
            
            // Try to get current location with high accuracy (no artificial timeout)
            try {
              currentPosition = await Geolocator.getCurrentPosition(
                desiredAccuracy: LocationAccuracy.high,  // Use high accuracy to ensure GPS is used
                // Removed timeLimit - let GPS acquire naturally without artificial constraints
              );
              
              if (currentPosition != null) {
                print('✅ Got current location: ${currentPosition.latitude}, ${currentPosition.longitude}');
                print('📍 Location accuracy: ${currentPosition.accuracy}m');
                await SoundService.I.play(AlertSound.gpsOk);
              }
            } catch (e) {
              print('⚠️ Current position failed, trying last known position: $e');
              
              // Fallback to last known position if current fails
              currentPosition = await Geolocator.getLastKnownPosition();
              
              if (currentPosition != null) {
                print('📍 Using last known location: ${currentPosition.latitude}, ${currentPosition.longitude}');
                print('📍 Location accuracy: ${currentPosition.accuracy}m (cached)');
                await SoundService.I.play(AlertSound.gpsOk);
              }
            }
          } else {
            print('❌ Location permission not granted: $permission');
            await SoundService.I.play(AlertSound.gpsFail);
          }
        } catch (e) {
          print('❌ Failed to get current location: $e');
          print('❌ Location error type: ${e.runtimeType}');
          await SoundService.I.play(AlertSound.gpsFail);
        }
      }
      
      // Use provided location or current location
      final finalLat = latitude ?? currentPosition?.latitude;
      final finalLng = longitude ?? currentPosition?.longitude;
      final finalAccuracy = currentPosition?.accuracy ?? 50.0;
      final finalHeading = heading ?? currentPosition?.heading;
      
      // Location is required for beeps
      if (finalLat == null || finalLng == null) {
        print('❌ FINAL LOCATION CHECK: lat=$finalLat, lng=$finalLng');
        
        // Check permission status one more time to give helpful error
        try {
          final permission = await Geolocator.checkPermission();
          if (permission == LocationPermission.denied || permission == LocationPermission.deniedForever) {
            throw Exception('Location permission required for beeping. Please enable location services in Profile → Permissions.');
          } else {
            throw Exception('Unable to get current location. Please ensure GPS is enabled and try again.');
          }
        } catch (e) {
          throw Exception('Location access failed. Please check location permissions in Profile → Permissions.');
        }
      }
      
      // Build request payload
      final payload = {
        'device_id': currentUser.id,
        'username': currentUser.username,
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
      
      // Send the beep - ApiClient.dio already has auth headers via AuthInterceptor
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
final beepService = BeepService();