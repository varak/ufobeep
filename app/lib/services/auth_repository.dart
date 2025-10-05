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
import 'device_service.dart';

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
  DateTime? _tokenExpiresAt;
  Timer? _refreshTimer;

  UserModel? get currentUser => _currentUser;
  bool get isReady => _isReady && !_isHydrating;
  bool get isHydrating => _isHydrating;

  /// Call once on startup to ensure tokens are loaded into memory
  Future<void> ensureLoaded() async {
    if (_loaded) return;
    print('[AuthRepo] ensureLoaded() - loading tokens from secure storage');

    final tokenData = await _secureStorage.readTokens();
    _access = tokenData['access'];
    _refresh = tokenData['refresh'];
    final expiryStr = tokenData['expires_at'];
    if (expiryStr != null) {
      _tokenExpiresAt = DateTime.tryParse(expiryStr);
    }
    _loaded = true;

    print('[AuthRepo] ensureLoaded() complete - access: ${_access != null}, refresh: ${_refresh != null}');

    // Start proactive refresh if we have tokens
    if (_access != null && _refresh != null) {
      _scheduleProactiveRefresh();
    }
  }

  /// Check if token needs refresh (within 30 minutes of expiry)
  bool _needsProactiveRefresh() {
    if (_tokenExpiresAt == null) return false;
    final now = DateTime.now();
    final timeUntilExpiry = _tokenExpiresAt!.difference(now);
    // Refresh if less than 30 minutes remaining
    return timeUntilExpiry.inMinutes < 30;
  }

  /// Schedule proactive token refresh
  void _scheduleProactiveRefresh() {
    _refreshTimer?.cancel();

    if (_tokenExpiresAt == null || _refresh == null) return;

    final now = DateTime.now();
    final timeUntilRefresh = _tokenExpiresAt!.subtract(const Duration(minutes: 30)).difference(now);

    if (timeUntilRefresh.isNegative || _needsProactiveRefresh()) {
      // Need to refresh now
      print('[AuthRepo] Token needs immediate refresh');
      _performProactiveRefresh();
    } else {
      // Schedule refresh for later
      print('[AuthRepo] Scheduling token refresh in ${timeUntilRefresh.inMinutes} minutes');
      _refreshTimer = Timer(timeUntilRefresh, _performProactiveRefresh);
    }
  }

  /// Perform proactive token refresh
  Future<void> _performProactiveRefresh() async {
    try {
      print('[AuthRepo] Performing proactive token refresh');
      await _refreshTokens();
      print('[AuthRepo] Proactive token refresh successful');
      // Schedule next refresh
      _scheduleProactiveRefresh();
    } catch (e) {
      print('[AuthRepo] Proactive token refresh failed: $e');
      // Will retry on next API call via interceptor
    }
  }

  Future<void> loadSessionOnStartup() async {
    print('[Bootstrap] Starting session load');
    _isHydrating = true;

    try {
      // Add timeout to prevent hanging indefinitely (reduced from 10s to 5s for faster fresh installs)
      await Future.any([
        _performSessionLoad(),
        Future.delayed(const Duration(seconds: 5), () => throw TimeoutException('Session load timeout', const Duration(seconds: 5))),
      ]);

      // CRITICAL: Check if tokens need refresh when app starts/resumes
      if (_access != null && _refresh != null && _needsProactiveRefresh()) {
        print('[Bootstrap] Tokens need refresh on startup - refreshing now');
        try {
          await _refreshTokens();
          print('[Bootstrap] Startup token refresh successful');
        } catch (e) {
          print('[Bootstrap] Startup token refresh failed: $e - will retry on first API call');
        }
      }
    } catch (e) {
      print('[Bootstrap] Session load failed: $e');
      if (e is TimeoutException) {
        print('[Bootstrap] Session load timed out after 5s - proceeding without authentication');
      } else {
        print('[Bootstrap] Session load error - clearing session');
        await clearSession();
      }
    } finally {
      // CRITICAL: Always ensure these are set to prevent infinite hanging
      _isReady = true;
      _isHydrating = false;
      print('[Bootstrap] Complete - ready=${_isReady}, user=${_currentUser?.username ?? "none"}');
      notifyListeners();
    }
  }

  Future<void> _performSessionLoad() async {
    // Ensure tokens are loaded into memory cache
    await ensureLoaded();

    if (_access == null || _access!.isEmpty) {
      print('[Bootstrap] No tokens found - starting unauthenticated');
      return;
    }

    print('[Bootstrap] Tokens found - validating with /me');
    ApiClient.setBearer(_access!);

    try {
      await fetchMe();
      print('[Bootstrap] Session restored successfully - user: ${_currentUser?.username}');
    } catch (e) {
      print('[Bootstrap] /me validation failed: $e - continuing with tokens intact');
      // DO NOT clear tokens on fetchMe failure - tokens are still valid
      // User profile will be fetched later when network/API is available
    }
  }

  Future<void> setTokens({required String access, required String refresh}) async {
    print('[Auth] ========== TOKEN STORAGE START ==========');
    print('[Auth] Saving tokens: access(${access.length}), refresh(${refresh.length})');

    try {
      // Update in-memory cache first
      _access = access;
      _refresh = refresh;
      _loaded = true;
      // Backend tokens expire in 24 hours, but we'll refresh proactively after 23.5 hours
      _tokenExpiresAt = DateTime.now().add(const Duration(hours: 24));

      // Then persist to secure storage
      await _secureStorage.writeTokens(
        access: access,
        refresh: refresh,
        expiresAt: _tokenExpiresAt,
      );

      ApiClient.setBearer(access);
      print('[Auth] ✅ ApiClient bearer token updated');
      print('[Auth] ✅ In-memory cache updated');
      print('[Auth] ✅ Token expires at: ${_tokenExpiresAt?.toIso8601String()}');

      // Schedule proactive refresh
      _scheduleProactiveRefresh();

      // Trigger device registration now that we have auth token
      DeviceRegistrationManager().onAuthTokenAvailable(access);

      print('[Auth] ========== TOKEN STORAGE SUCCESS ==========');
    } catch (e, stackTrace) {
      print('[Auth] ❌ CRITICAL: Token storage failed: $e');
      print('[Auth] ❌ Stack trace: $stackTrace');
      print('[Auth] ========== TOKEN STORAGE FAILED ==========');
      rethrow;
    }
  }

  /// Check and refresh tokens when app resumes from background
  Future<void> onAppResume() async {
    if (_access != null && _refresh != null && _needsProactiveRefresh()) {
      print('[AuthRepo] App resumed - tokens need refresh');
      try {
        await _refreshTokens();
        print('[AuthRepo] App resume token refresh successful');
      } catch (e) {
        print('[AuthRepo] App resume token refresh failed: $e');
        // Interceptor will handle on next API call
      }
    } else {
      print('[AuthRepo] App resumed - tokens still valid');
    }
  }

  /// This is the key fix: read-through cache pattern
  Future<String?> getAccessToken() async {
    print('[AuthRepo] getAccessToken() - loaded: $_loaded, cached access: ${_access != null}');

    if (!_loaded || (_access == null || _access!.isEmpty)) {
      print('[AuthRepo] getAccessToken() - cache miss, loading from storage');
      await ensureLoaded();
    }

    // Check if token needs refresh before returning it
    if (_access != null && _refresh != null && _needsProactiveRefresh()) {
      print('[AuthRepo] Token needs refresh before use');
      try {
        await _refreshTokens();
      } catch (e) {
        print('[AuthRepo] Pre-use token refresh failed: $e');
        // Return existing token, interceptor will handle 401 if it's actually expired
      }
    }

    print('[AuthRepo] getAccessToken() - returning: ${_access != null ? "token(${_access!.length})" : "null"}');
    return _access;
  }
  
  Future<String?> getRefreshToken() async {
    print('[AuthRepo] getRefreshToken() - loaded: $_loaded, cached refresh: ${_refresh != null}');
    
    if (!_loaded || (_refresh == null || _refresh!.isEmpty)) {
      print('[AuthRepo] getRefreshToken() - cache miss, loading from storage');
      await ensureLoaded();
    }
    
    print('[AuthRepo] getRefreshToken() - returning: ${_refresh != null ? "token(${_refresh!.length})" : "null"}');
    return _refresh;
  }

  Future<void> fetchMe({bool noCache = false}) async {
    final options = noCache 
        ? Options(headers: {
            'Cache-Control': 'no-cache, no-store, must-revalidate',
            'Pragma': 'no-cache',
            'Expires': '0'
          })
        : null;
    final res = await _dio.get('/users/me', options: options);
    
    // Handle both response formats: direct user object OR { "user": {...} }
    Map<String, dynamic> userData;
    if (res.data.containsKey('user')) {
      userData = res.data['user'] as Map<String, dynamic>;
    } else {
      userData = res.data as Map<String, dynamic>;
    }
    
    _currentUser = UserModel.fromJson(userData);
    print('✅ fetchMe() - username updated to: ${_currentUser?.username}');
    notifyListeners();
  }

  Future<void> setUsername(String username) async {
    final response = await _dio.post('/users/set-username', data: {
      'username': username,
    });
    
    // Immediately fetch fresh user data with no-cache
    await fetchMe(noCache: true);
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
    // Cancel refresh timer
    _refreshTimer?.cancel();
    _refreshTimer = null;

    // Clear in-memory cache
    _access = null;
    _refresh = null;
    _loaded = false;
    _tokenExpiresAt = null;

    // Clear secure storage
    await _secureStorage.clearTokens();
    ApiClient.clearBearer();
    _currentUser = null;

    // Notify DeviceRegistrationManager that auth is cleared
    DeviceRegistrationManager().onAuthCleared();

    print('[AuthRepo] clearSession() - cache and storage cleared');
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

    print('[AuthRepo] Refreshing tokens...');
    final res = await _dio.post('/auth/refresh', data: {'refresh': refresh});

    final access = res.data['access'] ?? res.data['access_token'] as String?;
    final newRefresh = res.data['refresh'] ?? res.data['refresh_token'] ?? refresh;

    if (access == null) throw Exception('No access token in refresh response');

    print('[AuthRepo] Token refresh successful');
    await setTokens(access: access, refresh: newRefresh);
  }
}