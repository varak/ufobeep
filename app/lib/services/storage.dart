import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Unified storage layer for authentication data
/// Provides secure storage with SharedPreferences fallback for reliability
class AppStorage {
  // Storage keys
  static const String accessKey = 'access_token';
  static const String refreshKey = 'refresh_token';
  static const String userIdKey = 'user_id';
  static const String usernameKey = 'username';
  static const String emailKey = 'email';
  
  // Mirror key prefix for SharedPreferences fallback
  static const String _mirrorPrefix = 'm_';

  // Consistent Android options to avoid OEM-specific issues
  static const AndroidOptions _androidOptions = AndroidOptions(
    encryptedSharedPreferences: true,
    sharedPreferencesName: 'ufobeep_secure_store',
    preferencesKeyPrefix: 'auth_',
    // resetOnError left default - we want errors visible, not silent wipes
  );

  static const IOSOptions _iosOptions = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock_this_device,
  );

  // Single FlutterSecureStorage instance used app-wide
  static const FlutterSecureStorage secure = FlutterSecureStorage(
    aOptions: _androidOptions,
    iOptions: _iosOptions,
  );

  /// Save value to secure storage with SharedPreferences mirror fallback
  static Future<void> saveWithFallback(String key, String value) async {
    // Write to secure storage
    await secure.write(key: key, value: value);
    
    // Mirror to SharedPreferences for fallback
    final sp = await SharedPreferences.getInstance();
    await sp.setString(_mirrorPrefix + key, value);
  }

  /// Read value with fallback recovery
  /// If secure storage is empty but fallback exists, repopulate secure storage
  static Future<String?> readWithFallback(String key) async {
    try {
      // Try secure storage first
      String? value = await secure.read(key: key);
      
      if (value != null && value.isNotEmpty) {
        return value;
      }
      
      // Fallback to SharedPreferences mirror
      final sp = await SharedPreferences.getInstance();
      value = sp.getString(_mirrorPrefix + key);
      
      if (value != null && value.isNotEmpty) {
        // Repopulate secure storage for future reads
        await secure.write(key: key, value: value);
        return value;
      }
      
      return null;
    } catch (e) {
      // If secure storage fails, try fallback
      final sp = await SharedPreferences.getInstance();
      return sp.getString(_mirrorPrefix + key);
    }
  }

  /// Delete value from both secure storage and fallback
  static Future<void> deleteWithFallback(String key) async {
    await secure.delete(key: key);
    final sp = await SharedPreferences.getInstance();
    await sp.remove(_mirrorPrefix + key);
  }

  /// Clear all authentication data
  static Future<void> clearAllAuthData() async {
    final keys = [accessKey, refreshKey, userIdKey, usernameKey, emailKey];
    
    for (final key in keys) {
      await deleteWithFallback(key);
    }
  }
}