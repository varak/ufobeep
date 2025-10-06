import 'dart:io';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// Service for persisting data in iOS Keychain (survives app uninstalls)
class KeychainService {
  static const _storage = FlutterSecureStorage(
    iOptions: IOSOptions(
      // These settings ensure the data persists after app uninstall
      accessibility: KeychainAccessibility.first_unlock_this_device,
      synchronizable: false,
    ),
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  static const String _deviceIdKey = 'ufobeep_persistent_device_id';

  /// Get the persistent device ID from Keychain/Secure storage
  static Future<String?> getDeviceId() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        return await _storage.read(key: _deviceIdKey);
      }
    } catch (e) {
      print('Error reading device ID from keychain: $e');
    }
    return null;
  }

  /// Save the device ID to Keychain/Secure storage
  static Future<bool> saveDeviceId(String deviceId) async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        await _storage.write(key: _deviceIdKey, value: deviceId);
        return true;
      }
    } catch (e) {
      print('Error saving device ID to keychain: $e');
    }
    return false;
  }

  /// Clear the device ID (for logout/testing purposes)
  static Future<void> clearDeviceId() async {
    try {
      if (Platform.isIOS || Platform.isAndroid) {
        await _storage.delete(key: _deviceIdKey);
      }
    } catch (e) {
      print('Error clearing device ID from keychain: $e');
    }
  }
}