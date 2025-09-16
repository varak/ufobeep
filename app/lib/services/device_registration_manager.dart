import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'device_service.dart';
import 'auth_repository.dart';
import 'sensor_service.dart';

/// NEW Reactive DeviceRegistrationManager that listens to BOTH auth + FCM token changes
/// Registers device only when BOTH JWT token AND FCM token are available
/// Automatically re-registers on either token changing
class DeviceRegistrationManager {
  static final DeviceRegistrationManager _instance = DeviceRegistrationManager._internal();
  factory DeviceRegistrationManager() => _instance;
  DeviceRegistrationManager._internal();

  StreamSubscription<String>? _fcmSub;
  Timer? _debounce;
  String? _lastRegisteredFcm;
  String? _lastRegisteredUser;
  bool _isStarted = false;
  
  final DeviceService _deviceService = DeviceService();

  /// Start listening for FCM token changes and trigger registration
  void start() {
    if (_isStarted) return;
    _isStarted = true;
    
    print('🔄 DeviceRegistrationManager: Starting listeners');
    
    // Listen for FCM token changes
    _fcmSub?.cancel();
    _fcmSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      print('🔔 DeviceRegistrationManager: FCM token refreshed');
      _trigger();
    });
    
    // Also trigger once at start
    _trigger();
  }

  /// Trigger device registration check (with debouncing)
  Future<void> _trigger() async {
    // Debounce rapid bursts
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 250), () async {
      await _attemptRegistration();
    });
  }

  /// Attempt device registration if tokens are available AND location can be obtained
  /// Tries authenticated registration first, falls back to anonymous if no auth
  Future<void> _attemptRegistration() async {
    try {
      // Get current FCM token first (required for both modes)
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        print('📱 DeviceRegistrationManager: No FCM token - skipping registration');
        return;
      }

      // Get current auth token
      final accessToken = await AuthRepository().getAccessToken();
      final isAuthenticated = accessToken != null && accessToken.isNotEmpty;

      // Create a user key to detect user changes
      final userKey = isAuthenticated ? accessToken.hashCode.toString() : 'anonymous';

      // Check if we already registered this combination
      final isSameAsLast = (_lastRegisteredFcm == fcmToken) && (_lastRegisteredUser == userKey);
      if (isSameAsLast) {
        print('📱 DeviceRegistrationManager: Already registered (user: $userKey, fcm: ...${fcmToken.substring(fcmToken.length - 6)}) - skipping');
        return;
      }

      print('📱 DeviceRegistrationManager: 🚀 Attempting registration');
      print('📱 DeviceRegistrationManager: ├── Mode: ${isAuthenticated ? "AUTHENTICATED" : "ANONYMOUS"}');
      print('📱 DeviceRegistrationManager: ├── User key: $userKey');
      print('📱 DeviceRegistrationManager: ├── FCM: ...${fcmToken.substring(fcmToken.length - 6)}');
      print('📱 DeviceRegistrationManager: └── Platform: ${Platform.isAndroid ? "android" : Platform.isIOS ? "ios" : "unknown"}');

      // CRITICAL: Get location FIRST - fail registration if no location available
      print('📱 DeviceRegistrationManager: Getting location for proximity alerts...');
      final sensorService = SensorService();
      final position = await sensorService.getPreciseLocation();

      if (position == null) {
        print('❌ DeviceRegistrationManager: FAILED - Cannot get device location');
        print('📱 DeviceRegistrationManager: Registration requires location for proximity alerts');
        print('📱 DeviceRegistrationManager: Skipping device registration due to location requirement');
        return;
      }

      print('✅ DeviceRegistrationManager: Got location: ${position.latitude}, ${position.longitude}');

      // Choose registration method based on auth status
      final DeviceResponse? deviceResponse;
      if (isAuthenticated) {
        print('📱 DeviceRegistrationManager: Using authenticated registration');
        deviceResponse = await _deviceService.registerDevice(
          pushToken: fcmToken,
          latitude: position.latitude,
          longitude: position.longitude,
          alertNotifications: true,
          chatNotifications: true,
          systemNotifications: true,
        );
      } else {
        print('📱 DeviceRegistrationManager: Using anonymous registration for proximity alerts');
        deviceResponse = await _deviceService.registerDeviceAnonymously(
          pushToken: fcmToken,
          latitude: position.latitude,
          longitude: position.longitude,
          alertNotifications: true,
          chatNotifications: true,
          systemNotifications: true,
        );
      }

      if (deviceResponse != null) {
        _lastRegisteredFcm = fcmToken;
        _lastRegisteredUser = userKey;

        print('✅ DeviceRegistrationManager: SUCCESS - Device registered with location');
        print('📱 DeviceRegistrationManager: ├── Device ID: ${deviceResponse.deviceId}');
        print('📱 DeviceRegistrationManager: ├── Platform: ${deviceResponse.platform.value}');
        print('📱 DeviceRegistrationManager: ├── Push enabled: ${deviceResponse.pushEnabled}');
        print('📱 DeviceRegistrationManager: ├── Mode: ${isAuthenticated ? "authenticated" : "anonymous"}');
        print('📱 DeviceRegistrationManager: └── Location: ${position.latitude}, ${position.longitude}');
      } else {
        print('❌ DeviceRegistrationManager: FAILED - Registration returned null');
      }

    } catch (e, stackTrace) {
      print('❌ DeviceRegistrationManager: EXCEPTION during registration: $e');
      print('📱 DeviceRegistrationManager: Stack trace: $stackTrace');

      // Parse specific errors
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        print('📱 DeviceRegistrationManager: ├── 401 UNAUTHORIZED - JWT token may be invalid/expired');
        print('📱 DeviceRegistrationManager: ├── Retrying with anonymous registration...');

        // Fallback to anonymous registration on auth failure
        try {
          final fcmToken = await FirebaseMessaging.instance.getToken();
          final sensorService = SensorService();
          final position = await sensorService.getPreciseLocation();

          if (fcmToken != null && position != null) {
            final deviceResponse = await _deviceService.registerDeviceAnonymously(
              pushToken: fcmToken,
              latitude: position.latitude,
              longitude: position.longitude,
              alertNotifications: true,
              chatNotifications: true,
              systemNotifications: true,
            );

            if (deviceResponse != null) {
              _lastRegisteredFcm = fcmToken;
              _lastRegisteredUser = 'anonymous';
              print('✅ DeviceRegistrationManager: Fallback to anonymous registration succeeded');
            }
          }
        } catch (fallbackError) {
          print('❌ DeviceRegistrationManager: Anonymous fallback also failed: $fallbackError');
        }
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        print('📱 DeviceRegistrationManager: ├── 403 FORBIDDEN - insufficient permissions');
      }
    }
  }

  /// Manual trigger for immediate registration attempt
  Future<void> nudge() async {
    print('📱 DeviceRegistrationManager: Manual nudge requested');
    await _trigger();
  }

  /// Backward compatibility methods from old implementation
  void onAuthTokenAvailable(String jwt) {
    print('🔐 DeviceRegistrationManager: Auth token available (backward compat) - triggering');
    _trigger();
  }

  void onAuthCleared() {
    print('🔐 DeviceRegistrationManager: Auth cleared - resetting state');
    _lastRegisteredFcm = null;
    _lastRegisteredUser = null;
  }

  void onFcmTokenAvailable(String token) {
    print('🔔 DeviceRegistrationManager: FCM token available (backward compat) - triggering');
    _trigger();
  }

  void onPushPermissionChanged(bool enabled) {
    print('🔔 DeviceRegistrationManager: Push permission changed: $enabled');
    if (enabled) {
      _trigger();
    }
  }

  Future<void> ensureRegisteredSoon() async {
    print('📱 DeviceRegistrationManager: ensureRegisteredSoon (backward compat)');
    await _trigger();
  }

  bool get isRegistered => _lastRegisteredFcm != null && _lastRegisteredUser != null;

  void dispose() {
    _debounce?.cancel();
    _fcmSub?.cancel();
    _isStarted = false;
    print('📱 DeviceRegistrationManager: Disposed');
  }
}