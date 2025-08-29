import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'device_service.dart';
import 'auth_repository.dart';
import '../models/api_models.dart';
import 'package:package_info_plus/package_info_plus.dart';

/// Coordinates device registration after BOTH auth and FCM tokens are available
/// Prevents the timing issue where device registration fails due to missing JWT
class DeviceRegistrationManager {
  static final DeviceRegistrationManager _instance = DeviceRegistrationManager._internal();
  factory DeviceRegistrationManager() => _instance;
  DeviceRegistrationManager._internal();

  String? _jwt;
  String? _fcmToken;
  bool _pushEnabled = false;
  bool _inFlight = false;
  bool _registered = false;
  Timer? _retryTimer;
  
  final DeviceService _deviceService = DeviceService();

  /// Called when auth token becomes available
  void onAuthTokenAvailable(String jwt) {
    debugPrint('🔐 DeviceRegistration: Auth token available');
    _jwt = jwt;
    _attemptRegister();
  }

  /// Called when auth is cleared (logout)
  void onAuthCleared() {
    debugPrint('🔐 DeviceRegistration: Auth cleared');
    _jwt = null;
    _registered = false;
    _retryTimer?.cancel();
  }

  /// Called when FCM token becomes available
  void onFcmTokenAvailable(String token) {
    debugPrint('🔔 DeviceRegistration: FCM token available');
    _fcmToken = token;
    _attemptRegister();
  }

  /// Called when push permission changes
  void onPushPermissionChanged(bool enabled) {
    debugPrint('🔔 DeviceRegistration: Push permission = $enabled');
    _pushEnabled = enabled;
    _attemptRegister();
  }

  /// Attempt device registration if all prerequisites are met
  Future<void> _attemptRegister() async {
    if (_inFlight) {
      debugPrint('📱 DeviceRegistration: Already in flight, skipping');
      return;
    }
    
    if (_jwt == null) {
      debugPrint('📱 DeviceRegistration: No JWT token, waiting for auth');
      return;
    }
    
    if (_fcmToken == null) {
      debugPrint('📱 DeviceRegistration: No FCM token, waiting for push service');
      return;
    }
    
    if (!_pushEnabled) {
      debugPrint('📱 DeviceRegistration: Push not enabled, skipping registration');
      return;
    }

    _inFlight = true;
    debugPrint('📱 DeviceRegistration: All prerequisites met, registering device...');
    
    try {
      final deviceResponse = await _deviceService.registerDevice(
        pushToken: _fcmToken!,
        alertNotifications: true,
        chatNotifications: true,
        systemNotifications: true,
        includeLocation: true,
      );
      
      if (deviceResponse != null) {
        _registered = true;
        debugPrint('✅ DeviceRegistration: Device registered successfully');
      } else {
        debugPrint('❌ DeviceRegistration: Registration returned null');
        _scheduleRetry();
      }
    } catch (e) {
      debugPrint('❌ DeviceRegistration: Registration failed: $e');
      _scheduleRetry();
    } finally {
      _inFlight = false;
    }
  }

  /// Schedule a retry with exponential backoff
  void _scheduleRetry() {
    _retryTimer?.cancel();
    _retryTimer = Timer(const Duration(seconds: 10), () {
      debugPrint('🔄 DeviceRegistration: Retrying registration...');
      _attemptRegister();
    });
  }

  /// Public method to nudge registration attempt
  Future<void> ensureRegisteredSoon() async {
    debugPrint('📱 DeviceRegistration: Manual registration check requested');
    await _attemptRegister();
  }

  /// Check if device is currently registered
  bool get isRegistered => _registered;
  
  /// Dispose resources
  void dispose() {
    _retryTimer?.cancel();
  }
}