import 'dart:developer';
import 'package:meta/meta.dart';
import '../services/secure_storage.dart';

@immutable
class AuthTokens {
  final String access;
  final String refresh;
  final DateTime? expiresAt;
  
  const AuthTokens({
    required this.access, 
    required this.refresh, 
    this.expiresAt
  });
}

class AuthRepository {
  static final AuthRepository _instance = AuthRepository._internal();
  factory AuthRepository() => _instance;
  AuthRepository._internal();

  final _storage = SecureStorage();
  AuthTokens? _cached;

  Future<void> persist(AuthTokens t) async {
    log('[AuthRepository] Persist called');
    _cached = t;
    await _storage.writeTokens(
      access: t.access,
      refresh: t.refresh,
      expiresAt: t.expiresAt,
    );
    log('[AuthRepository] Persist complete');
  }

  Future<AuthTokens?> load() async {
    final m = await _storage.readTokens();
    final access = m['access'];
    final refresh = m['refresh'];
    final expiryStr = m['expires_at'];
    
    if (access == null || access.isEmpty || refresh == null || refresh.isEmpty) {
      log('[AuthRepository] load(): no tokens found');
      _cached = null;
      return null;
    }
    
    DateTime? exp;
    if (expiryStr != null && expiryStr.isNotEmpty) {
      try { 
        exp = DateTime.parse(expiryStr); 
      } catch (_) {}
    }
    
    _cached = AuthTokens(access: access, refresh: refresh, expiresAt: exp);
    log('[AuthRepository] load(): tokens present');
    return _cached;
  }

  Future<void> clear() async {
    _cached = null;
    await _storage.clearTokens();
    log('[AuthRepository] Tokens cleared');
  }

  AuthTokens? get current => _cached;
}