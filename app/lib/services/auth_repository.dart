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
  
  // In-memory token cache to prevent race conditions
  String? _access;
  String? _refresh;
  bool _loaded = false;

  UserModel? get currentUser => _currentUser;
  bool get isReady => _isReady && !_isHydrating;
  bool get isHydrating => _isHydrating;

  /// Call once on startup to ensure tokens are loaded into memory
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    debugPrint('[AuthRepo] ensureLoaded() - loading tokens from secure storage');
    
    final tokenData = await _secureStorage.readTokens();
    _access = tokenData['access'];
    _refresh = tokenData['refresh'];
    _loaded = true;
    
    debugPrint('[AuthRepo] ensureLoaded() complete - access: ${_access != null}, refresh: ${_refresh != null}');
  }

  Future<void> loadSessionOnStartup() async {
    debugPrint('[Bootstrap] Starting session load');
    _isHydrating = true;
    
    try {
      // Ensure tokens are loaded into memory cache
      await ensureLoaded();
      
      if (_access == null || _access!.isEmpty) {
        debugPrint('[Bootstrap] No tokens found - starting unauthenticated');
        _isReady = true;
        _isHydrating = false;
        notifyListeners();
        return;
      }
      
      debugPrint('[Bootstrap] Tokens found - validating with /me');
      ApiClient.setBearer(_access!);
      
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
      // Update in-memory cache first
      _access = access;
      _refresh = refresh;
      _loaded = true;
      
      // Then persist to secure storage
      await _secureStorage.writeTokens(
        access: access,
        refresh: refresh,
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      
      ApiClient.setBearer(access);
      debugPrint('[Auth] ✅ ApiClient bearer token updated');
      debugPrint('[Auth] ✅ In-memory cache updated');
      
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

  /// This is the key fix: read-through cache pattern
  Future<String?> getAccessToken() async {
    debugPrint('[AuthRepo] getAccessToken() - loaded: $_loaded, cached access: ${_access != null}');
    
    if (!_loaded || (_access == null || _access!.isEmpty)) {
      debugPrint('[AuthRepo] getAccessToken() - cache miss, loading from storage');
      await ensureLoaded();
    }
    
    debugPrint('[AuthRepo] getAccessToken() - returning: ${_access != null ? "token(${_access!.length})" : "null"}');
    return _access;
  }
  
  Future<String?> getRefreshToken() async {
    debugPrint('[AuthRepo] getRefreshToken() - loaded: $_loaded, cached refresh: ${_refresh != null}');
    
    if (!_loaded || (_refresh == null || _refresh!.isEmpty)) {
      debugPrint('[AuthRepo] getRefreshToken() - cache miss, loading from storage');
      await ensureLoaded();
    }
    
    debugPrint('[AuthRepo] getRefreshToken() - returning: ${_refresh != null ? "token(${_refresh!.length})" : "null"}');
    return _refresh;
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
    // Clear in-memory cache
    _access = null;
    _refresh = null;
    _loaded = false;
    
    // Clear secure storage
    await _secureStorage.clearTokens();
    ApiClient.clearBearer();
    _currentUser = null;
    
    // Notify DeviceRegistrationManager that auth is cleared
    DeviceRegistrationManager().onAuthCleared();
    
    debugPrint('[AuthRepo] clearSession() - cache and storage cleared');
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