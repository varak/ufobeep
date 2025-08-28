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

  final _storage = const FlutterSecureStorage();
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
    debugPrint('[AuthRepository] 🚀 Starting session load');
    
    try {
      final refresh = await _storage.read(key: _kRefresh);
      if (refresh == null || refresh.isEmpty) {
        debugPrint('[AuthRepository] 🚀 No refresh token found, marking as ready');
        _isReady = true;
        notifyListeners();
        return;
      }
      
      debugPrint('[AuthRepository] 🚀 Refresh token found, attempting silent refresh');
      // Try silent refresh
      await _refreshTokens();
      await fetchMe();
      debugPrint('[AuthRepository] 🚀 Session loaded successfully');
    } catch (e) {
      debugPrint('[AuthRepository] 🚀 Session load failed: $e, clearing session');
      // If refresh fails, clear tokens
      await clearSession();
    } finally {
      _isReady = true;
      debugPrint('[AuthRepository] 🚀 Session load complete, marked as ready');
      notifyListeners();
    }
  }

  Future<void> setTokens({required String access, required String refresh}) async {
    await _storage.write(key: _kAccess, value: access);
    await _storage.write(key: _kRefresh, value: refresh);
    ApiClient.setBearer(access);
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

      if (access == null || refresh == null || user == null) {
        throw Exception('Bad magic link exchange payload: missing required fields');
      }
      
      debugPrint('[AuthRepository] 🔄 Payload validation passed');
      debugPrint('[AuthRepository] 🔄 Setting tokens...');
      
      // Store tokens atomically
      await setTokens(access: access, refresh: refresh);
      
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