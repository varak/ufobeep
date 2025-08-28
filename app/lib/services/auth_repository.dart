import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:dio/dio.dart';
import '../models/user_model.dart';
import 'api_client.dart';

/// ChatGPT: Single source of truth for user + tokens.
/// - Stores only tokens in secure storage
/// - User model is memory + fetched via /me
/// - Exposes ready + user notifiers for UI binding
class AuthRepository with ChangeNotifier {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
    iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
  );
  final _dio = ApiClient.dio;

  UserModel? _currentUser;
  bool _isReady = false;
  bool _isHydrating = false;

  UserModel? get currentUser => _currentUser;
  bool get isReady => _isReady && !_isHydrating;
  bool get isHydrating => _isHydrating;

  static const _kAccess = 'access_token';
  static const _kRefresh = 'refresh_token';

  Future<void> loadSessionOnStartup() async {
    debugPrint('[Bootstrap] Starting session load');
    
    try {
      final refresh = await _storage.read(key: _kRefresh);
      final access = await _storage.read(key: _kAccess);
      
      debugPrint('[Bootstrap] Stored tokens found: refresh=${refresh != null}, access=${access != null}');
      
      if (refresh == null || refresh.isEmpty) {
        debugPrint('[Bootstrap] No refresh token - starting unauthenticated');
        _isReady = true;
        notifyListeners();
        return;
      }
      
      // NEW: If we have both tokens, use them directly (no refresh needed)
      if (access != null && access.isNotEmpty) {
        debugPrint('[Bootstrap] Both tokens found - using stored access token directly');
        ApiClient.setBearer(access);
        await fetchMe(); // Get user info with stored access token
        debugPrint('[Bootstrap] Session restored successfully - user: ${_currentUser?.username}');
      } else {
        // Only refresh if access token is missing
        debugPrint('[Bootstrap] Access token missing, attempting refresh');
        await _refreshTokens();
        await fetchMe();
        debugPrint('[Bootstrap] Session refreshed successfully - user: ${_currentUser?.username}');
      }
    } catch (e) {
      debugPrint('[Bootstrap] Session load failed: $e, clearing session');
      // If anything fails, clear tokens
      await clearSession();
    } finally {
      _isReady = true;
      debugPrint('[Bootstrap] Complete - ready=${_isReady}, user=${_currentUser?.username ?? "none"}');
      notifyListeners();
    }
  }

  Future<void> setTokens({required String access, required String refresh}) async {
    debugPrint('[Auth] Saving tokens: access(${access.length}), refresh(${refresh.length})');
    try {
      await _storage.write(key: _kAccess, value: access);
      debugPrint('[Auth] Access token written to secure storage');
      await _storage.write(key: _kRefresh, value: refresh);
      debugPrint('[Auth] Refresh token written to secure storage');
      ApiClient.setBearer(access);
      debugPrint('[Auth] Tokens saved successfully and ApiClient updated');
    } catch (e, stackTrace) {
      debugPrint('[Auth] ❌ CRITICAL: Token storage failed: $e');
      debugPrint('[Auth] ❌ Stack trace: $stackTrace');
      rethrow;
    }
  }

  Future<String?> getAccessToken() => _storage.read(key: _kAccess);
  Future<String?> getRefreshToken() => _storage.read(key: _kRefresh);

  Future<void> fetchMe() async {
    final res = await _dio.get('/me');
    _currentUser = UserModel.fromJson(res.data);
    notifyListeners();
  }

  Future<void> updateFromMagicLinkResponse(Map<String, dynamic> payload) async {
    // Set hydrating state to prevent race conditions
    _isHydrating = true;
    notifyListeners();
    
    debugPrint('[AuthRepository] 🔄 Starting magic link response update (hydrating)');
    
    try {
      // ChatGPT: Expect backend to return { access, refresh, user: {...} }
      final access = payload['access'] as String?;
      final refresh = payload['refresh'] as String?;
      final user = payload['user'] as Map<String, dynamic>?;

      if (access == null || user == null) {
        throw Exception('Bad magic link exchange payload: missing required fields');
      }
      
      debugPrint('[AuthRepository] 🔄 Payload validation passed');
      debugPrint('[AuthRepository] 🔄 Setting tokens...');
      
      // Store tokens atomically
      await setTokens(access: access, refresh: refresh ?? '');
      
      debugPrint('[AuthRepository] 🔄 Creating user model...');
      
      // Update user model
      _currentUser = UserModel.fromJson(user);
      
      debugPrint('[AuthRepository] ✅ Magic link update complete - user: ${_currentUser?.username}');
      
      // Complete hydration atomically
      await Future.microtask(() {
        _isHydrating = false;
        notifyListeners();
      });
      
      debugPrint('[AuthRepository] ✅ Auth state ready and hydrated');
      
    } catch (e, stackTrace) {
      debugPrint('[AuthRepository] ❌ Magic link update failed: $e');
      debugPrint('[AuthRepository] ❌ Stack trace: $stackTrace');
      
      // Rollback to clean state on failure
      _isHydrating = false;
      await clearSession();
      
      rethrow;
    }
  }

  Future<void> logout() async {
    try {
      await _dio.post('/auth/logout');
    } catch (_) {/* best-effort */}
    await clearSession();
  }

  Future<void> clearSession() async {
    await _storage.delete(key: _kAccess);
    await _storage.delete(key: _kRefresh);
    ApiClient.clearBearer();
    _currentUser = null;
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