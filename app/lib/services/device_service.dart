import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../config/environment.dart' as env;
import '../models/api_models.dart';
import 'sensor_service.dart';

/// Device platform enumeration
enum DevicePlatform {
  ios('ios'),
  android('android'),
  web('web');

  const DevicePlatform(this.value);
  final String value;
}

/// Push provider enumeration  
enum PushProvider {
  fcm('fcm'),
  apns('apns'),
  webpush('webpush');

  const PushProvider(this.value);
  final String value;
}

/// Device registration request model
class DeviceRegistrationRequest {
  final String deviceId;
  final String? deviceName;
  final DevicePlatform platform;
  final String? appVersion;
  final String? osVersion;
  final String? deviceModel;
  final String? manufacturer;
  final String? pushToken;
  final PushProvider? pushProvider;
  final bool alertNotifications;
  final bool chatNotifications;
  final bool systemNotifications;
  final String? timezone;
  final String? locale;
  final double? lat;
  final double? lon;

  DeviceRegistrationRequest({
    required this.deviceId,
    this.deviceName,
    required this.platform,
    this.appVersion,
    this.osVersion,
    this.deviceModel,
    this.manufacturer,
    this.pushToken,
    this.pushProvider,
    this.alertNotifications = true,
    this.chatNotifications = true,
    this.systemNotifications = true,
    this.timezone,
    this.locale,
    this.lat,
    this.lon,
  });

  Map<String, dynamic> toJson() {
    return {
      'device_id': deviceId,
      'device_name': deviceName,
      'platform': platform.value,
      'app_version': appVersion,
      'os_version': osVersion,
      'device_model': deviceModel,
      'manufacturer': manufacturer,
      'push_token': pushToken,
      'push_provider': pushProvider?.value,
      'alert_notifications': alertNotifications,
      'chat_notifications': chatNotifications,
      'system_notifications': systemNotifications,
      'timezone': timezone,
      'locale': locale,
      'lat': lat,
      'lon': lon,
    };
  }
}

/// Device response model
class DeviceResponse {
  final String id;
  final String deviceId;
  final String? deviceName;
  final DevicePlatform platform;
  final String? appVersion;
  final String? osVersion;
  final String? deviceModel;
  final String? manufacturer;
  final bool pushEnabled;
  final bool alertNotifications;
  final bool chatNotifications;
  final bool systemNotifications;
  final bool isActive;
  final DateTime? lastSeen;
  final String? timezone;
  final String? locale;
  final int notificationsSent;
  final int notificationsOpened;
  final DateTime registeredAt;
  final DateTime updatedAt;

  DeviceResponse({
    required this.id,
    required this.deviceId,
    this.deviceName,
    required this.platform,
    this.appVersion,
    this.osVersion,
    this.deviceModel,
    this.manufacturer,
    required this.pushEnabled,
    required this.alertNotifications,
    required this.chatNotifications,
    required this.systemNotifications,
    required this.isActive,
    this.lastSeen,
    this.timezone,
    this.locale,
    required this.notificationsSent,
    required this.notificationsOpened,
    required this.registeredAt,
    required this.updatedAt,
  });

  factory DeviceResponse.fromJson(Map<String, dynamic> json) {
    return DeviceResponse(
      id: json['id'],
      deviceId: json['device_id'],
      deviceName: json['device_name'],
      platform: DevicePlatform.values.firstWhere(
        (p) => p.value == json['platform'],
        orElse: () => DevicePlatform.android,
      ),
      appVersion: json['app_version'],
      osVersion: json['os_version'],
      deviceModel: json['device_model'],
      manufacturer: json['manufacturer'],
      pushEnabled: json['push_enabled'] ?? true,
      alertNotifications: json['alert_notifications'] ?? true,
      chatNotifications: json['chat_notifications'] ?? true,
      systemNotifications: json['system_notifications'] ?? true,
      isActive: json['is_active'] ?? true,
      lastSeen: json['last_seen'] != null 
          ? DateTime.parse(json['last_seen'])
          : null,
      timezone: json['timezone'],
      locale: json['locale'],
      notificationsSent: json['notifications_sent'] ?? 0,
      notificationsOpened: json['notifications_opened'] ?? 0,
      registeredAt: DateTime.parse(json['registered_at']),
      updatedAt: DateTime.parse(json['updated_at']),
    );
  }
}

/// Device service for managing push tokens and device registration
class DeviceService {
  static const String _deviceIdKey = 'device_id';
  static const String _registeredDeviceKey = 'registered_device';
  static const String _lastHeartbeatKey = 'last_heartbeat';

  final http.Client _httpClient = http.Client();
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();

  /// Get or generate device ID
  Future<String> getDeviceId() async {
    final prefs = await SharedPreferences.getInstance();
    String? deviceId = prefs.getString(_deviceIdKey);

    if (deviceId == null) {
      // Generate new device ID based on platform-specific info
      deviceId = await _generateDeviceId();
      await prefs.setString(_deviceIdKey, deviceId);
    }

    return deviceId;
  }

  /// Generate unique device ID
  Future<String> _generateDeviceId() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return 'android_${androidInfo.id}_${DateTime.now().millisecondsSinceEpoch}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return 'ios_${iosInfo.identifierForVendor}_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        return 'unknown_${DateTime.now().millisecondsSinceEpoch}';
      }
    } catch (e) {
      print('Error generating device ID: $e');
      return 'fallback_${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  /// Get device platform
  DevicePlatform getDevicePlatform() {
    if (Platform.isAndroid) return DevicePlatform.android;
    if (Platform.isIOS) return DevicePlatform.ios;
    return DevicePlatform.android; // fallback
  }

  /// Get push provider for current platform
  PushProvider getPushProvider() {
    // For now, use FCM for both platforms
    // In production, you might use APNS for iOS
    return PushProvider.fcm;
  }

  /// Collect device information
  Future<Map<String, dynamic>> collectDeviceInfo() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        return {
          'app_version': packageInfo.version,
          'os_version': 'Android ${androidInfo.version.release}',
          'device_model': androidInfo.model,
          'manufacturer': androidInfo.manufacturer,
        };
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        return {
          'app_version': packageInfo.version,
          'os_version': '${iosInfo.systemName} ${iosInfo.systemVersion}',
          'device_model': iosInfo.model,
          'manufacturer': 'Apple',
        };
      }
    } catch (e) {
      print('Error collecting device info: $e');
    }

    return {};
  }

  /// Update device location for proximity alerts
  Future<bool> updateDeviceLocation() async {
    try {
      final deviceId = await getDeviceId();
      
      // Get current location
      final sensorService = SensorService();
      final hasPermission = await sensorService.requestLocationPermission();
      
      if (!hasPermission) {
        print('Device location update: Permission denied');
        return false;
      }
      
      final sensorData = await sensorService.captureSensorData();
      if (sensorData == null || sensorData.latitude == 0.0 || sensorData.longitude == 0.0) {
        print('Device location update: No valid GPS data');
        return false;
      }
      
      // Update device location via API
      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/$deviceId/location');
      final response = await _httpClient.patch(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'lat': sensorData.latitude,
          'lon': sensorData.longitude,
          'updated_at': DateTime.now().toIso8601String(),
        }),
      );
      
      if (response.statusCode == 200) {
        print('Device location updated: lat=${sensorData.latitude}, lon=${sensorData.longitude}');
        return true;
      } else {
        print('Device location update failed: ${response.statusCode} ${response.body}');
        return false;
      }
    } catch (e) {
      print('Error updating device location: $e');
      return false;
    }
  }

  /// Register device with push token
  Future<DeviceResponse?> registerDevice({
    required String pushToken,
    String? deviceName,
    bool alertNotifications = true,
    bool chatNotifications = true,
    bool systemNotifications = true,
    bool includeLocation = true,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final deviceInfo = await collectDeviceInfo();
      final platform = getDevicePlatform();
      final pushProvider = getPushProvider();

      // Try to get current location for proximity alerts
      double? lat, lon;
      if (includeLocation) {
        try {
          // First check/request location permission
          final sensorService = SensorService();
          final hasPermission = await sensorService.requestLocationPermission();
          
          if (hasPermission) {
            final sensorData = await sensorService.captureSensorData();
            if (sensorData != null && sensorData.latitude != 0.0 && sensorData.longitude != 0.0) {
              lat = sensorData.latitude;
              lon = sensorData.longitude;
              print('Device registration: Including location lat=$lat, lon=$lon');
            } else {
              print('Device registration: Location permission granted but no valid GPS data');
            }
          } else {
            print('Device registration: Location permission denied - registering without location');
          }
        } catch (e) {
          print('Device registration: Failed to get location: $e');
        }
      }

      final request = DeviceRegistrationRequest(
        deviceId: deviceId,
        deviceName: deviceName,
        platform: platform,
        appVersion: deviceInfo['app_version'],
        osVersion: deviceInfo['os_version'],
        deviceModel: deviceInfo['device_model'],
        manufacturer: deviceInfo['manufacturer'],
        pushToken: pushToken,
        pushProvider: pushProvider,
        alertNotifications: alertNotifications,
        chatNotifications: chatNotifications,
        systemNotifications: systemNotifications,
        timezone: DateTime.now().timeZoneName,
        locale: Platform.localeName,
        lat: lat,
        lon: lon,
      );

      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/register');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
        },
        body: jsonEncode(request.toJson()),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final deviceResponse = DeviceResponse.fromJson(data['data']);
          
          // Cache registration info
          await _cacheRegisteredDevice(deviceResponse);
          
          print('Device registered successfully: ${deviceResponse.deviceId}');
          return deviceResponse;
        }
      }

      print('Device registration failed: ${response.statusCode} ${response.body}');
      return null;
    } catch (e) {
      print('Error registering device: $e');
      return null;
    }
  }

  /// Update push token
  Future<bool> updatePushToken(String pushToken) async {
    try {
      final deviceId = await getDeviceId();
      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/$deviceId');

      final response = await _httpClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
        },
        body: jsonEncode({
          'push_token': pushToken,
          'push_provider': getPushProvider().value,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          print('Push token updated successfully');
          return true;
        }
      }

      print('Push token update failed: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error updating push token: $e');
      return false;
    }
  }

  /// Update device preferences
  Future<bool> updateDevicePreferences({
    bool? alertNotifications,
    bool? chatNotifications,
    bool? systemNotifications,
    bool? pushEnabled,
  }) async {
    try {
      final deviceId = await getDeviceId();
      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/$deviceId');

      final updates = <String, dynamic>{};
      if (alertNotifications != null) updates['alert_notifications'] = alertNotifications;
      if (chatNotifications != null) updates['chat_notifications'] = chatNotifications;
      if (systemNotifications != null) updates['system_notifications'] = systemNotifications;
      if (pushEnabled != null) updates['push_enabled'] = pushEnabled;

      if (updates.isEmpty) return true;

      final response = await _httpClient.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
        },
        body: jsonEncode(updates),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Error updating device preferences: $e');
      return false;
    }
  }

  /// Send device heartbeat
  Future<void> sendHeartbeat() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastHeartbeat = prefs.getInt(_lastHeartbeatKey) ?? 0;
      final now = DateTime.now().millisecondsSinceEpoch;

      // Send heartbeat at most once every 5 minutes
      if (now - lastHeartbeat < 300000) return;

      final deviceId = await getDeviceId();
      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/$deviceId/heartbeat');

      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          // TODO: Add authorization header
        },
      );

      if (response.statusCode == 200) {
        await prefs.setInt(_lastHeartbeatKey, now);
      }
    } catch (e) {
      print('Error sending device heartbeat: $e');
    }
  }

  /// Unregister device
  Future<bool> unregisterDevice() async {
    try {
      final deviceId = await getDeviceId();
      final url = Uri.parse('${env.AppEnvironment.apiBaseUrl}/devices/$deviceId');

      final response = await _httpClient.delete(
        url,
        headers: {
          // TODO: Add authorization header
        },
      );

      if (response.statusCode == 200) {
        // Clear cached registration
        await _clearCachedDevice();
        print('Device unregistered successfully');
        return true;
      }

      return false;
    } catch (e) {
      print('Error unregistering device: $e');
      return false;
    }
  }

  /// Get cached registered device
  Future<DeviceResponse?> getCachedDevice() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final deviceJson = prefs.getString(_registeredDeviceKey);

      if (deviceJson != null) {
        final deviceData = jsonDecode(deviceJson);
        return DeviceResponse.fromJson(deviceData);
      }

      return null;
    } catch (e) {
      print('Error getting cached device: $e');
      return null;
    }
  }

  /// Cache registered device info
  Future<void> _cacheRegisteredDevice(DeviceResponse device) async {
    final prefs = await SharedPreferences.getInstance();
    final deviceJson = jsonEncode({
      'id': device.id,
      'device_id': device.deviceId,
      'device_name': device.deviceName,
      'platform': device.platform.value,
      'app_version': device.appVersion,
      'os_version': device.osVersion,
      'device_model': device.deviceModel,
      'manufacturer': device.manufacturer,
      'push_enabled': device.pushEnabled,
      'alert_notifications': device.alertNotifications,
      'chat_notifications': device.chatNotifications,
      'system_notifications': device.systemNotifications,
      'is_active': device.isActive,
      'last_seen': device.lastSeen?.toIso8601String(),
      'timezone': device.timezone,
      'locale': device.locale,
      'notifications_sent': device.notificationsSent,
      'notifications_opened': device.notificationsOpened,
      'registered_at': device.registeredAt.toIso8601String(),
      'updated_at': device.updatedAt.toIso8601String(),
    });

    await prefs.setString(_registeredDeviceKey, deviceJson);
  }

  /// Clear cached device info
  Future<void> _clearCachedDevice() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_registeredDeviceKey);
    await prefs.remove(_lastHeartbeatKey);
  }

  /// Check if device is registered
  Future<bool> isDeviceRegistered() async {
    final cachedDevice = await getCachedDevice();
    return cachedDevice != null && cachedDevice.isActive;
  }

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
  }
}

// Global device service instance
final deviceService = DeviceService();