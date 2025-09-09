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
    
    debugPrint('🔄 DeviceRegistrationManager: Starting listeners');
    
    // Listen for FCM token changes
    _fcmSub?.cancel();
    _fcmSub = FirebaseMessaging.instance.onTokenRefresh.listen((token) {
      debugPrint('🔔 DeviceRegistrationManager: FCM token refreshed');
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

  /// Attempt device registration if both tokens are available AND location can be obtained
  Future<void> _attemptRegistration() async {
    try {
      // Get current auth token
      final accessToken = await AuthRepository().getAccessToken();
      if (accessToken == null || accessToken.isEmpty) {
        debugPrint('📱 DeviceRegistrationManager: No auth token - skipping registration');
        return;
      }

      // Get current FCM token  
      final fcmToken = await FirebaseMessaging.instance.getToken();
      if (fcmToken == null || fcmToken.isEmpty) {
        debugPrint('📱 DeviceRegistrationManager: No FCM token - skipping registration');
        return;
      }

      // Create a user key to detect user changes (simple hash of token)
      final userKey = accessToken.hashCode.toString();
      
      // Check if we already registered this combination
      final isSameAsLast = (_lastRegisteredFcm == fcmToken) && (_lastRegisteredUser == userKey);
      if (isSameAsLast) {
        debugPrint('📱 DeviceRegistrationManager: Already registered (user: $userKey, fcm: ...${fcmToken.substring(fcmToken.length - 6)}) - skipping');
        return;
      }

      debugPrint('📱 DeviceRegistrationManager: 🚀 Attempting registration');
      debugPrint('📱 DeviceRegistrationManager: ├── User key: $userKey');  
      debugPrint('📱 DeviceRegistrationManager: ├── FCM: ...${fcmToken.substring(fcmToken.length - 6)}');
      debugPrint('📱 DeviceRegistrationManager: └── Platform: ${Platform.isAndroid ? "android" : Platform.isIOS ? "ios" : "unknown"}');

      // CRITICAL: Get location FIRST - fail registration if no location available
      debugPrint('📱 DeviceRegistrationManager: Getting location for proximity alerts...');
      final sensorService = SensorService();
      final position = await sensorService.getPreciseLocation();
      
      if (position == null) {
        debugPrint('❌ DeviceRegistrationManager: FAILED - Cannot get device location');
        debugPrint('📱 DeviceRegistrationManager: Registration requires location for proximity alerts');
        // Don't throw - just log and skip registration
        debugPrint('📱 DeviceRegistrationManager: Skipping device registration due to location requirement');
        return;
      }

      debugPrint('✅ DeviceRegistrationManager: Got location: ${position.latitude}, ${position.longitude}');

      // Call the existing DeviceService method with explicit location
      final deviceResponse = await _deviceService.registerDevice(
        pushToken: fcmToken,
        latitude: position.latitude,
        longitude: position.longitude,
        alertNotifications: true,
        chatNotifications: true,
        systemNotifications: true,
      );

      if (deviceResponse != null) {
        _lastRegisteredFcm = fcmToken;
        _lastRegisteredUser = userKey;
        
        debugPrint('✅ DeviceRegistrationManager: SUCCESS - Device registered with location');
        debugPrint('📱 DeviceRegistrationManager: ├── Device ID: ${deviceResponse.deviceId}');
        debugPrint('📱 DeviceRegistrationManager: ├── Platform: ${deviceResponse.platform.value}');
        debugPrint('📱 DeviceRegistrationManager: ├── Push enabled: ${deviceResponse.pushEnabled}');
        debugPrint('📱 DeviceRegistrationManager: └── Location: ${position.latitude}, ${position.longitude}');
      } else {
        debugPrint('❌ DeviceRegistrationManager: FAILED - Registration returned null');
      }

    } catch (e, stackTrace) {
      debugPrint('❌ DeviceRegistrationManager: EXCEPTION during registration: $e');
      debugPrint('📱 DeviceRegistrationManager: Stack trace: $stackTrace');
      
      // Parse specific errors
      if (e.toString().contains('401') || e.toString().contains('Unauthorized')) {
        debugPrint('📱 DeviceRegistrationManager: ├── 401 UNAUTHORIZED - JWT token may be invalid/expired');
      } else if (e.toString().contains('403') || e.toString().contains('Forbidden')) {
        debugPrint('📱 DeviceRegistrationManager: ├── 403 FORBIDDEN - insufficient permissions');
      }
    }
  }

  /// Manual trigger for immediate registration attempt
  Future<void> nudge() async {
    debugPrint('📱 DeviceRegistrationManager: Manual nudge requested');
    await _trigger();
  }

  /// Backward compatibility methods from old implementation
  void onAuthTokenAvailable(String jwt) {
    debugPrint('🔐 DeviceRegistrationManager: Auth token available (backward compat) - triggering');
    _trigger();
  }

  void onAuthCleared() {
    debugPrint('🔐 DeviceRegistrationManager: Auth cleared - resetting state');
    _lastRegisteredFcm = null;
    _lastRegisteredUser = null;
  }

  void onFcmTokenAvailable(String token) {
    debugPrint('🔔 DeviceRegistrationManager: FCM token available (backward compat) - triggering');
    _trigger();
  }

  void onPushPermissionChanged(bool enabled) {
    debugPrint('🔔 DeviceRegistrationManager: Push permission changed: $enabled');
    if (enabled) {
      _trigger();
    }
  }

  Future<void> ensureRegisteredSoon() async {
    debugPrint('📱 DeviceRegistrationManager: ensureRegisteredSoon (backward compat)');
    await _trigger();
  }

  bool get isRegistered => _lastRegisteredFcm != null && _lastRegisteredUser != null;

  void dispose() {
    _debounce?.cancel();
    _fcmSub?.cancel();
    _isStarted = false;
    debugPrint('📱 DeviceRegistrationManager: Disposed');
  }
}