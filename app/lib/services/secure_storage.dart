import 'dart:async';
import 'dart:developer';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SecureStorage {
  static final SecureStorage _instance = SecureStorage._internal();
  factory SecureStorage() => _instance;
  SecureStorage._internal();

  static const _kAccess = 'auth.access';
  static const _kRefresh = 'auth.refresh';
  static const _kExpiry = 'auth.expires_at';
  static const _kUser = 'auth.user_data';

  // Use EncryptedSharedPreferences on Android to avoid device/keystore edge cases.
  static const _aOpts = AndroidOptions(
    encryptedSharedPreferences: true,
    resetOnError: true,
  );
  static const _iOpts = IOSOptions(
    accessibility: KeychainAccessibility.first_unlock, // fine for background relaunch
  );

  final FlutterSecureStorage _s =
      const FlutterSecureStorage(aOptions: _aOpts, iOptions: _iOpts);

  Future<void> writeTokens({
    required String access,
    required String refresh,
    DateTime? expiresAt,
    Map<String, dynamic>? userData,
  }) async {
    log('[SecureStorage] Writing tokens...');
    await _s.write(key: _kAccess, value: access);
    await _s.write(key: _kRefresh, value: refresh);
    if (expiresAt != null) {
      await _s.write(key: _kExpiry, value: expiresAt.toIso8601String());
    }
    if (userData != null) {
      await _s.write(key: _kUser, value: jsonEncode(userData));
      log('[SecureStorage] User data written: ${userData['username']}');
    }
    log('[SecureStorage] Tokens written: access=${access.isNotEmpty}, refresh=${refresh.isNotEmpty}');
  }

  Future<Map<String, String?>> readTokens() async {
    final access = await _s.read(key: _kAccess);
    final refresh = await _s.read(key: _kRefresh);
    final expiry = await _s.read(key: _kExpiry);
    log('[SecureStorage] Read tokens: access=${access != null}, refresh=${refresh != null}, expiry=${expiry ?? 'none'}');
    return {'access': access, 'refresh': refresh, 'expires_at': expiry};
  }

  Future<void> clearTokens() async {
    log('[SecureStorage] Clearing tokens...');
    await _s.delete(key: _kAccess);
    await _s.delete(key: _kRefresh);
    await _s.delete(key: _kExpiry);
    log('[SecureStorage] Cleared.');
  }
}