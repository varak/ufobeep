import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';
import 'storage.dart';
import 'secure_storage.dart';
import 'device_registration_manager.dart';

/// ChatGPT: Single source of truth for user + tokens.
/// - Stores only tokens in secure storage
/// - User model is memory + fetched via /me
/// - Exposes ready + user notifiers for UI binding
class AuthRepository with ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  final _dio = ApiClient.dio;
  final _secureStorage = SecureStorage();

  UserModel? _currentUser;
  bool _isReady = false;
  bool _isHydrating = false;

  UserModel? get currentUser => _currentUser;
  bool get isReady => _isReady && !_isHydrating;
  bool get isHydrating => _isHydrating;

  Future<void> loadSessionOnStartup() async {
    debugPrint('[Bootstrap] Starting session load');
    _isHydrating = true;
    
    try {
      final tokenData = await _secureStorage.readTokens();
      final access = tokenData['access'];
      final refresh = tokenData['refresh'];
      
      if (access == null || access.isEmpty) {
        debugPrint('[Bootstrap] No tokens found - starting unauthenticated');
        _isReady = true;
        _isHydrating = false;
        notifyListeners();
        return;
      }
      
      debugPrint('[Bootstrap] Tokens found - validating with /me');
      ApiClient.setBearer(access);
      
      try {
        await fetchMe();
        debugPrint('[Bootstrap] Session restored successfully - user: ${_currentUser?.username}');
      } catch (e) {
        debugPrint('[Bootstrap] /me validation failed: $e - clearing tokens');
        await clearSession();
      }
      
    } catch (e) {
      debugPrint('[Bootstrap] Session load failed: $e, clearing session');
      await clearSession();
    } finally {
      _isReady = true;
      _isHydrating = false;
      debugPrint('[Bootstrap] Complete - ready=${_isReady}, user=${_currentUser?.username ?? "none"}');
      notifyListeners();
    }
  }

  Future<void> setTokens({required String access, required String refresh}) async {
    debugPrint('[Auth] ========== TOKEN STORAGE START ==========');
    debugPrint('[Auth] Saving tokens: access(${access.length}), refresh(${refresh.length})');
    
    try {
      await _secureStorage.writeTokens(
        access: access,
        refresh: refresh,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      
      ApiClient.setBearer(access);
      debugPrint('[Auth] ✅ ApiClient bearer token updated');
      
      // Trigger device registration now that we have auth token
      DeviceRegistrationManager().onAuthTokenAvailable(access);
      
      debugPrint('[Auth] ========== TOKEN STORAGE SUCCESS ==========');
    } catch (e, stackTrace) {
      debugPrint('[Auth] ❌ CRITICAL: Token storage failed: $e');
      debugPrint('[Auth] ❌ Stack trace: $stackTrace');
      debugPrint('[Auth] ========== TOKEN STORAGE FAILED ==========');
      rethrow;
    }
  }

  Future<String?> getAccessToken() async {
    final tokenData = await _secureStorage.readTokens();
    return tokenData['access'];
  }
  
  Future<String?> getRefreshToken() async {
    final tokenData = await _secureStorage.readTokens();
    return tokenData['refresh'];
  }

  Future<void> fetchMe() async {
    final res = await _dio.get('/users/me');
    final userData = res.data['user'] as Map<String, dynamic>;
    _currentUser = UserModel.fromJson(userData);
    notifyListeners();
  }


  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {/* best-effort */}
    await clearSession();
    
    // Notify DeviceRegistrationManager that auth is cleared
    DeviceRegistrationManager().onAuthCleared();
  }

  Future<void> clearSession() async {
    await _secureStorage.clearTokens();
    ApiClient.clearBearer();
    _currentUser = null;
    
    // Notify DeviceRegistrationManager that auth is cleared
    DeviceRegistrationManager().onAuthCleared();
    
    notifyListeners();
  }

  /// Used by interceptor on 401
  Future<bool> tryRefreshTokensFromInterceptor() async {
    try {
      await _refreshTokens();
      return true;
    } catch (_) {
      await clearSession();
      return false;
    }
  }

  Future<void> _refreshTokens() async {
    final refresh = await getRefreshToken();
    if (refresh == null || refresh.isEmpty) throw Exception('No refresh token');
    final res = await _dio.post('/auth/refresh', data: {'refresh': refresh});
    final access = res.data['access'] as String?;
    final newRefresh = res.data['refresh'] as String? ?? refresh;
    if (access == null) throw Exception('No access token in refresh response');
    await setTokens(access: access, refresh: newRefresh);
  }
}