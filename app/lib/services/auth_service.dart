/// Hardened Authentication Service for UFOBeep
/// Handles ONLY email magic link authentication
/// NO anonymous auth - users are either null (unauthenticated) or authenticated via email

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:developer';
import 'dart:io';
import 'device_service.dart';
import 'api_client.dart';
import 'auth_repository.dart';
import 'storage.dart';
import 'device_registration_manager.dart';
import 'user_service.dart';
import '../config/environment.dart';
import '../models/user_preferences.dart';
import '../features/auth/auth_gate.dart';

/// Authentication phases to prevent race conditions
enum AuthPhase { unknown, processingLink, authenticated, unauthenticated }

/// Authentication state model (ChatGPT's recommendation)
class AuthState {
  final AuthPhase phase;
  final String? userId;
  final String? username;
  final String? email;
  
  const AuthState._(this.phase, {this.userId, this.username, this.email});
  
  /// Factory for unknown state
  factory AuthState.unknown() => const AuthState._(AuthPhase.unknown);
  
  /// Factory for processing magic link state
  factory AuthState.processingLink() => const AuthState._(AuthPhase.processingLink);
  
  /// Factory for unauthenticated state
  factory AuthState.unauthenticated() => const AuthState._(AuthPhase.unauthenticated);
  
  /// Factory for authenticated state
  factory AuthState.authenticated({
    required String userId,
    required String username,
    String? email,
  }) {
    return AuthState._(
      AuthPhase.authenticated,
      userId: userId,
      username: username,
      email: email,
    );
  }
  
  /// Convenience getter for checking authentication
  bool get isAuthenticated => phase == AuthPhase.authenticated;
  
  @override
  String toString() {
    return 'AuthState(isAuth: $isAuthenticated, userId: $userId, username: $username, email: $email)';
  }
}

class MagicLinkResult {
  final bool success;
  final String? userId;
  final String? username;
  final String? email;
  final bool isNewUser;
  final String? error;

  MagicLinkResult({
    required this.success,
    this.userId,
    this.username,
    this.email,
    this.isNewUser = false,
    this.error,
  });

  factory MagicLinkResult.success({
    required String userId,
    String? username,
    String? email,
    bool isNewUser = false,
  }) {
    return MagicLinkResult(
      success: true,
      userId: userId,
      username: username,
      email: email,
      isNewUser: isNewUser,
    );
  }

  factory MagicLinkResult.failure(String error) {
    return MagicLinkResult(
      success: false,
      error: error,
    );
  }
}

class AuthService extends ChangeNotifier implements AuthStateProvider {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    _apiClient = ApiClient.instance;
  }

  static const String _pendingEmailKey = 'pending_magic_link_email';
  static const String _apiBaseUrl = 'https://ufobeep.com/api';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  
  final DeviceService _deviceService = DeviceService();
  late final ApiClient _apiClient;
  
  // State management (ChatGPT's recommendation)
  final StreamController<AuthState> _authStream = StreamController<AuthState>.broadcast();
  AuthState _state = AuthState.unknown();
  
  /// Stream of authentication state changes
  Stream<AuthState> get authStream => _authStream.stream;
  
  /// Current authentication state
  AuthState get authState => _state;
  
  /// Centralized token persistence method
  Future<void> handleLoginSuccess(Map<String, dynamic> json) async {
    log('[AuthService] handleLoginSuccess called');
    
    // Expecting standardized format:
    // { "success": true, "access": "...", "refresh": "...", "user": {...}, "expires_in": 3600? }
    final access = (json['access'] ?? json['access_token'])?.toString() ?? '';
    final refresh = (json['refresh'] ?? json['refresh_token'])?.toString() ?? '';
    
    if (access.isEmpty || refresh.isEmpty) {
      log('[AuthService] Missing tokens in response → cannot persist');
      throw Exception('Auth response missing tokens');
    }
    
    DateTime? expiresAt;
    final expiresIn = json['expires_in'];
    if (expiresIn is num) {
      expiresAt = DateTime.now().add(Duration(seconds: expiresIn.toInt()));
    }

    log('[AuthService] Persisting tokens...');
    await AuthRepository().setTokens(access: access, refresh: refresh);
    log('[AuthService] Tokens persisted successfully');

    // Set auth token in ApiClient for immediate use
    _apiClient.setAuthToken(access);
    log('[AuthService] ApiClient auth token set');
    
    // IMMEDIATELY emit authenticated state after successful token storage
    await _emit(AuthState.authenticated(userId: 'authenticated-user', username: 'user'));
    print('[AuthService] ✅ IMMEDIATE authenticated state emission after login');

    // Fetch user profile in background - don't block authentication
    log('[AuthService] Starting background user profile fetch...');
    _fetchUserProfileInBackground();
    
    // Trigger device registration now that we have auth token
    log('[AuthService] Triggering device registration after successful login...');
    DeviceRegistrationManager().nudge();
  }

  /// Initialize the AuthService - call this early in app startup
  Future<void> initialize() async {
    await _checkStoredAuth();
  }

  /// Fetch user profile in background with retry logic
  void _fetchUserProfileInBackground() {
    // Fire and forget - don't block authentication flow
    Future.microtask(() async {
      int attempts = 0;
      const maxAttempts = 3;
      
      while (attempts < maxAttempts) {
        try {
          await AuthRepository().fetchMe();
          log('[AuthService] ✅ Background profile fetch successful');
          return;
        } catch (e) {
          attempts++;
          log('[AuthService] Background profile fetch attempt $attempts/$maxAttempts failed: $e');
          
          if (attempts < maxAttempts) {
            // Exponential backoff: 2s, 4s, 8s
            final delay = Duration(seconds: 2 * attempts);
            await Future.delayed(delay);
          }
        }
      }
      
      log('[AuthService] Background profile fetch failed after $maxAttempts attempts - user remains authenticated with placeholder data');
    });
  }
  
  /// Emit new auth state (ChatGPT's recommendation)
  Future<void> _emit(AuthState newState) async {
    print('[Auth] State change: ${_state.phase} -> ${newState.phase}');
    print('[Auth] New state: $newState');
    _state = newState;
    _authStream.add(newState);
    notifyListeners();
  }
  
  /// Signal to UI we're processing a magic link (prevents premature Login screen)
  Future<void> beginProcessingLink() async {
    print('[Auth] beginProcessingLink()');
    await _emit(AuthState.processingLink());
  }

  /// Get current user (null if not authenticated)
  User? get currentUser => _auth.currentUser;

  /// Check if user is authenticated (not anonymous - only email auth)
  bool get isAuthenticated => _auth.currentUser != null;

  /// Listen to authentication state changes
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// AuthStateProvider implementation for ChatGPT's AuthGate pattern
  @override
  AuthStatus get status {
    // Use the current state instead of checking tokens directly
    return _state.isAuthenticated ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }
  
  /// Current auth state getter for streaming auth gate
  AuthState get state => _state;

  /// Check if user has valid authentication (Firebase Auth OR stored JWT token)
  bool _hasValidAuth() {
    // Check both Firebase Auth and stored JWT tokens
    return isAuthenticated || _hasStoredToken;
  }

  /// Cached token check result to avoid repeated async calls
  bool _hasStoredToken = false;
  
  /// Check stored authentication and update state (ChatGPT's recommendation)
  Future<void> _checkStoredAuth() async {
    print('[Auth] Checking stored authentication...');
    try {
      // Use AuthRepository to load tokens  
      final access = await AuthRepository().getAccessToken();
      
      if (access != null && access.isNotEmpty) {
        print('[Auth] ✅ Found valid stored authentication tokens');
        
        // Set auth token in ApiClient for all future requests
        _apiClient.setAuthToken(access);
        print('[Auth] ✅ ApiClient auth token restored from storage');
        
        // TODO: Get user info from /me endpoint or cached storage
        // For now, use placeholder values - this will be updated in bootstrap logic
        await _emit(AuthState.authenticated(
          userId: 'token-user',
          username: 'token-username',
          email: null,
        ));
      } else {
        print('[Auth] ❌ No valid stored tokens found');
        await _emit(AuthState.unauthenticated());
      }
    } catch (e, st) {
      print('[Auth][ERROR] checkStoredAuth exception: $e');
      print('[Auth][ERROR] Stack trace: $st');
      await _emit(AuthState.unauthenticated());
    }
  }

  /// Send magic link email for authentication
  /// This does NOT create any user session until the link is verified
  Future<void> sendMagicLink(String email) async {
    try {
      print('MAGIC LINK DEBUG: Starting magic link send for: $email');
      
      // Configure the action code settings for magic link
      final ActionCodeSettings actionCodeSettings = ActionCodeSettings(
        // Use Firebase's default domain which should always work
        url: 'https://ufobeep.firebaseapp.com',
        handleCodeInApp: true,
        // Android configuration
        androidPackageName: 'com.ufobeep',
        androidInstallApp: true,
        androidMinimumVersion: '21',
        // iOS configuration (if needed later)
        iOSBundleId: 'com.ufobeep.ios',
      );

      print('MAGIC LINK DEBUG: ActionCodeSettings configured');
      print('MAGIC LINK DEBUG: URL: ${actionCodeSettings.url}');
      print('MAGIC LINK DEBUG: Package: ${actionCodeSettings.androidPackageName}');

      // Send the magic link email
      print('MAGIC LINK DEBUG: Calling Firebase sendSignInLinkToEmail...');
      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      // Store the email locally for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingEmailKey, email);

      // CRITICAL FIX: Actually call backend API to send magic link
      final userService = UserService();
      await userService.sendMagicLink(email);

      print('MAGIC LINK DEBUG: Magic link sent successfully to: $email');
      print('MAGIC LINK DEBUG: Email stored locally for verification');
    } on FirebaseAuthException catch (e) {
      print('MAGIC LINK DEBUG: Firebase Auth error sending magic link:');
      print('  Code: ${e.code}');
      print('  Message: ${e.message}');
      print('  Details: ${e.toString()}');
      throw AuthException._fromFirebaseAuthException(e);
    } catch (e) {
      print('MAGIC LINK DEBUG: Unknown error sending magic link: $e');
      print('MAGIC LINK DEBUG: Error type: ${e.runtimeType}');
      throw AuthException._fromFirebaseAuthException(e);
    }
  }

  /// Handle JWT-based magic link completion (new system)
  Future<MagicLinkResult> handleJWTMagicLink({
    required String token,
    required String userId,
    required String username,
    String? email,
  }) async {
    try {
      print('🔑 JWT MAGIC LINK AUTH DEBUG:');
      print('   Token: ${token.substring(0, 20)}...');
      print('   User ID: $userId');
      print('   Username: $username');
      print('   Email: $email');
      
      // Store auth data securely with fallback
      await AppStorage.saveWithFallback(AppStorage.accessKey, token);
      await AppStorage.saveWithFallback(AppStorage.userIdKey, userId);
      await AppStorage.saveWithFallback(AppStorage.usernameKey, username);
      
      if (email != null) {
        await AppStorage.saveWithFallback(AppStorage.emailKey, email);
      }
      
      print('✅ JWT auth data stored securely');
      
      return MagicLinkResult.success(
        userId: userId,
        username: username, 
        email: email,
      );
      
    } catch (e, stackTrace) {
      print('❌ JWT magic link auth failed: $e');
      print('📚 Stack trace: $stackTrace');
      return MagicLinkResult.failure('Authentication failed: ${e.toString()}');
    }
  }

  /// ChatGPT's enhanced magic token authentication method
  /// Handles both custom scheme (full data) and HTTPS App Links (token-only)  
  Future<bool> loginWithMagicToken({
    required String token,
    String? userId,
    String? username,
  }) async {
    print('[Auth] loginWithMagicToken start. httpsOnly=${userId == null && username == null}');
    print('[Auth] token length: ${token.length}');
    
    try {
      Map<String, dynamic>? respJson;

      if (userId != null && username != null) {
        // CUSTOM SCHEME: already have identity; still verify token with backend
        print('[Auth] Custom scheme flow - verifying token with backend');
        respJson = await _apiClient.exchangeMagicToken(token);
      } else {
        // HTTPS APP LINK: only token present; must exchange with backend
        print('[Auth] HTTPS App Link flow - exchanging token with backend');
        respJson = await _apiClient.exchangeMagicToken(token);
      }

      if (respJson == null) {
        print('[Auth][ERROR] Empty response from backend.');
        _showDevSnack('Magic link failed: empty response');
        return false;
      }

      print('[Auth] Backend response keys: ${respJson.keys}');
      print('[Auth] Backend response: $respJson');

      // NEW: Handle the correct response format from /auth/magic/exchange
      // { access_token, refresh_token, user: { id, username, email } }
      // Try both field names for compatibility
      final access = respJson['access'] ?? respJson['access_token'] as String?;
      final refreshToken = respJson['refresh'] ?? respJson['refresh_token'] as String?;
      final userObject = respJson['user'] as Map<String, dynamic>?;
      
      // Extract user fields from nested user object
      final backendUserId = userObject?['id']?.toString() ?? userId?.toString();
      final backendUsername = userObject?['username']?.toString() ?? username?.toString();
      final email = userObject?['email']?.toString();
      final isNewUser = respJson['is_new_user'] as bool? ?? false;
      final firebaseToken = respJson['firebase_custom_token'] as String?;
      
      print('[Auth] Parsed fields - email: "$email", userId: "$backendUserId", username: "$backendUsername"');
      print('[Auth] Refresh token available: ${refreshToken != null}');

      if ([access, backendUserId, backendUsername].any((v) => v == null || (v as String).isEmpty)) {
        print('[Auth][ERROR] Missing fields in backend response: $respJson');
        _showDevSnack('Magic link failed: missing fields in response');
        return false;
      }

      print('[Auth] Valid response - using AuthRepository');

      // Use centralized token persistence
      await handleLoginSuccess({
        'access': access,
        'refresh': refreshToken,
        'user': userObject,
        'expires_in': 3600,
      });

      print('[Auth] AuthRepository updated. userId=$backendUserId username=$backendUsername email=$email isNew=$isNewUser');
      
      // Handle Firebase custom token if provided
      if (firebaseToken != null && firebaseToken.isNotEmpty) {
        try {
          await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
          print('[Auth] ✅ Firebase authentication successful');
        } catch (e) {
          print('[Auth] ⚠️ Firebase authentication failed: $e');
          // Continue without Firebase auth - not critical for basic auth
        }
      }
      
      // Update auth state
      await _emit(AuthState.authenticated(
        userId: backendUserId!,
        username: backendUsername!,
        email: email,
      ));
      
      print('[Auth] ✅ Authentication successful - state updated');
      return true;
    } catch (e, st) {
      print('[Auth][ERROR] loginWithMagicToken failed: $e');
      print('[Auth][ERROR] Stack trace: $st');
      // If DioError, surface HTTP status & body
      if (e is DioException) {
        final code = e.response?.statusCode;
        final body = e.response?.data;
        print('[Auth][ERROR] HTTP $code body=$body');
        _showDevSnack('Magic link HTTP $code');
      } else {
        _showDevSnack('Magic link exception: $e');
      }
      return false;
    }
  }

  /// NEW: Authorization code flow magic link authentication with timeout and deterministic error handling
  Future<bool> loginWithMagicCode({required String code}) async {
    final startedAt = DateTime.now();
    final reqId = "magic-${startedAt.millisecondsSinceEpoch}";
    print('[MAGIC][$reqId] loginWithMagicCode start');
    print('[MAGIC][$reqId] code length: ${code.length}');
    print('[MAGIC][$reqId] code preview: ${code.substring(0, code.length.clamp(0, 8))}...');
    
    try {
      // Exchange authorization code for tokens with 8-second timeout
      print('[MAGIC][$reqId] calling _apiClient.exchangeMagicCode() with timeout');
      final respJson = await _apiClient.exchangeMagicCode(code).timeout(
        const Duration(seconds: 8),
        onTimeout: () {
          print('[MAGIC][$reqId] TIMEOUT after 8 seconds');
          throw TimeoutException('Magic link verification timed out', const Duration(seconds: 8));
        },
      );
      print('[MAGIC][$reqId] API call completed in ${DateTime.now().difference(startedAt).inMilliseconds}ms');
      
      if (respJson == null) {
        print('[MAGIC][$reqId] ERROR: Empty response from backend');
        _showDevSnack('Magic link failed: No response from server');
        return false;
      }
      
      print('[MAGIC][$reqId] Backend response keys: ${respJson.keys}');
      print('[MAGIC][$reqId] Backend response data: $respJson');
      
      // Expected JSON: { access, refresh, user: {id, username, email} }
      // Try both field names for compatibility
      final accessToken = respJson['access'] ?? respJson['access_token'] as String?;
      final refreshToken = respJson['refresh'] ?? respJson['refresh_token'] as String?;
      final userObj = respJson['user'] as Map<String, dynamic>?;
      
      if (accessToken == null || userObj == null) {
        print('[MAGIC][$reqId] ERROR: Missing required fields - accessToken: ${accessToken != null}, userObj: ${userObj != null}');
        _showDevSnack('Magic link failed: Invalid server response');
        return false;
      }
      
      final userId = userObj['id']?.toString();
      final username = userObj['username']?.toString();
      final email = userObj['email']?.toString();
      
      if (userId == null || username == null) {
        print('[MAGIC][$reqId] ERROR: Missing user data - userId: $userId, username: $username');
        _showDevSnack('Magic link failed: Missing user information');
        return false;
      }
      
      // Use centralized token persistence
      print('[MAGIC][$reqId] ==================== TOKEN PERSISTENCE START ====================');
      final updateStartTime = DateTime.now();
      try {
        await handleLoginSuccess({
          'access': accessToken,
          'refresh': refreshToken ?? '',
          'user': userObj,
          'expires_in': 3600,
        });
        
        final updateDuration = DateTime.now().difference(updateStartTime).inMilliseconds;
        print('[MAGIC][$reqId] ✅ Token persistence completed in ${updateDuration}ms');
        print('[MAGIC][$reqId] ==================== TOKEN PERSISTENCE SUCCESS ====================');
      } catch (e, stackTrace) {
        final updateDuration = DateTime.now().difference(updateStartTime).inMilliseconds;
        print('[MAGIC][$reqId] ==================== TOKEN PERSISTENCE ERROR ====================');
        print('[MAGIC][$reqId] ❌ Token persistence failed after ${updateDuration}ms: $e');
        print('[MAGIC][$reqId] ❌ Error type: ${e.runtimeType}');
        print('[MAGIC][$reqId] ❌ Stack trace: $stackTrace');
        print('[MAGIC][$reqId] ==================== TOKEN PERSISTENCE FAILURE ====================');
        _showDevSnack('Failed to store authentication data: ${e.toString()}');
        return false;
      }
      
      final totalMs = DateTime.now().difference(startedAt).inMilliseconds;
      print('[MAGIC][$reqId] ✅ Magic link authentication successful in ${totalMs}ms - userId: $userId, username: $username');
      
      // Emit authenticated state
      print('[MAGIC][$reqId] Emitting authenticated state');
      await _emit(AuthState.authenticated(
        userId: userId,
        username: username,
        email: email,
      ));
      
      print('[MAGIC][$reqId] ✅ Magic link authentication completed successfully');
      print('[MAGIC][$reqId] Final auth state - AuthRepository ready: ${AuthRepository().isReady}');
      print('[MAGIC][$reqId] Final auth state - AuthRepository user: ${AuthRepository().currentUser?.username}');
      
      _showDevSnack('Welcome back, $username!');
      return true;
      
    } on TimeoutException catch (e) {
      print('[MAGIC][$reqId] ❌ TIMEOUT: ${e.message}');
      _showDevSnack('Magic link verification timed out. Please try again.');
      return false;
    } catch (e, st) {
      final errorMs = DateTime.now().difference(startedAt).inMilliseconds;
      print('[MAGIC][$reqId] ❌ ERROR after ${errorMs}ms: $e');
      print('[MAGIC][$reqId] ❌ Stack trace: $st');
      
      // Handle specific error cases with detailed logging
      if (e is DioException) {
        final code = e.response?.statusCode;
        final body = e.response?.data;
        print('[MAGIC][$reqId] ❌ DioException HTTP $code body=$body');
        
        if (code == 410) {
          _showDevSnack('Magic link expired or already used');
        } else if (code == 400) {
          _showDevSnack('Invalid magic link format');
        } else if (code == 404) {
          _showDevSnack('Magic link not found');
        } else if (code == 500) {
          _showDevSnack('Server error processing magic link');
        } else {
          _showDevSnack('Magic link failed (HTTP $code)');
        }
      } else {
        print('[MAGIC][$reqId] ❌ Non-DioException: ${e.runtimeType}');
        _showDevSnack('Magic link verification failed: ${e.toString()}');
      }
      
      return false;
    }
  }

  /// Handle incoming Firebase magic link from deep link or web redirect (legacy)
  /// This creates an authenticated session AND checks/creates backend user
  Future<MagicLinkResult> handleMagicLink(String emailLink) async {
    try {
      // Get the pending email from storage
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString(_pendingEmailKey);

      if (email == null) {
        return MagicLinkResult.failure('No pending email found. Please request a new magic link.');
      }

      // Verify the link is valid for email authentication
      if (!_auth.isSignInWithEmailLink(emailLink)) {
        return MagicLinkResult.failure('Invalid magic link. Please request a new one.');
      }

      // Sign in with the email link - this creates the authenticated session
      final UserCredential userCredential = await _auth.signInWithEmailLink(
        email: email,
        emailLink: emailLink,
      );

      // Clear the pending email
      await prefs.remove(_pendingEmailKey);

      if (userCredential.user == null) {
        return MagicLinkResult.failure('Firebase authentication failed');
      }

      print('Firebase magic link sign-in successful: ${userCredential.user?.uid}');

      // Get Firebase ID token to call backend
      final firebaseIdToken = await userCredential.user!.getIdToken(true);
      if (firebaseIdToken == null || firebaseIdToken.isEmpty) {
        return MagicLinkResult.failure('Failed to get Firebase ID token');
      }

      try {
        // Get device info for backend
        final deviceId = await _deviceService.getDeviceId();
        final platform = Platform.isAndroid ? 'android' : (Platform.isIOS ? 'ios' : 'unknown');
        
        // Call backend to check/create user account
        final response = await http.post(
          Uri.parse('$_apiBaseUrl/users/auth/firebase'),
          headers: {
            'Authorization': 'Bearer $firebaseIdToken',
            'Content-Type': 'application/json',
          },
          body: jsonEncode({
            'token': firebaseIdToken,
            'device_id': deviceId,
            'platform': platform,
          }),
        ).timeout(const Duration(seconds: 12));
        
        print('Magic link backend auth response: ${response.statusCode} ${response.body}');
        
        if (response.statusCode < 200 || response.statusCode >= 300) {
          return MagicLinkResult.failure('Backend authentication failed: ${response.statusCode}');
        }
        
        // Parse response and store user info locally
        final data = jsonDecode(response.body);
        print('MAGIC LINK DEBUG: Full backend response: $data');
        
        final user = data['user'] ?? {};
        print('MAGIC LINK DEBUG: User object from response: $user');
        
        final userId = user['user_id'] ?? userCredential.user!.uid;
        final username = user['username'];
        final userEmail = user['email'] ?? email;
        
        print('MAGIC LINK DEBUG: Extracted values:');
        print('  - userId: $userId');
        print('  - username: $username');
        print('  - userEmail: $userEmail');
        print('  - isNewUser: ${data['is_new_user'] ?? false}');
        
        // Store user info locally if we have a username
        if (username != null && username.isNotEmpty) {
          await _storeUserInfo(
            userId: userId,
            username: username,
            deviceId: deviceId,
            email: userEmail,
          );
          
          print('Magic link auth success: user has username $username');
          return MagicLinkResult.success(
            userId: userId,
            username: username,
            email: userEmail,
            isNewUser: data['is_new_user'] ?? false,
          );
        } else {
          // User exists but no username set - they need to create one
          print('Magic link auth success: user needs to set username');
          return MagicLinkResult.success(
            userId: userId,
            username: null,
            email: userEmail,
            isNewUser: true, // Treat as new user flow for username setup
          );
        }
        
      } catch (e) {
        print('Backend integration error: $e');
        return MagicLinkResult.failure('Failed to verify account: $e');
      }
      
    } catch (e) {
      print('Error handling magic link: $e');
      
      // Clear any pending email on failure to prevent stale state
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailKey);
      
      return MagicLinkResult.failure('Magic link authentication failed: $e');
    }
  }

  /// Store user info locally (similar to SocialAuthService)
  Future<void> _storeUserInfo({
    required String userId,
    required String username,
    required String deviceId,
    String? email,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool('is_registered', true);
    
    if (email != null && email.isNotEmpty) {
      await prefs.setString('user_email', email);
    }
    
    // Also create default user preferences so profile screen shows full view
    final defaultPrefs = UserPreferences(
      language: AppEnvironment.defaultLocale,
      alertRangeKm: 10.0, // Default from UserPreferences model
      displayName: username,
      email: email,
    );
    
    await prefs.setString('user_preferences', jsonEncode(defaultPrefs.toJson()));
    
    print('MAGIC LINK DEBUG: User info and preferences stored locally:');
    print('  - username: $username');
    print('  - userId: $userId'); 
    print('  - email: ${email ?? "none"}');
    print('  - preferences: ${defaultPrefs.toJson()}');
    
    // Verify storage worked
    final storedUsername = prefs.getString(_usernameKey);
    final storedPrefs = prefs.getString('user_preferences');
    print('MAGIC LINK DEBUG: Verification - stored username: $storedUsername');
    print('MAGIC LINK DEBUG: Verification - stored preferences: $storedPrefs');
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      // Clear all auth data using AuthRepository
      await AuthRepository().clearSession();
      
      // Clear auth token in ApiClient
      _apiClient.setAuthToken(null);
      
      // Clear any pending email
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailKey);
      
      // Update auth state
      await _emit(AuthState.unauthenticated());
      
      print('[Auth] ✅ User signed out successfully');
    } catch (e) {
      print('[Auth][ERROR] Error signing out: $e');
      // Still emit unauthenticated state even if cleanup fails
      await _emit(AuthState.unauthenticated());
    }
  }

  /// Get the pending email (if any) for magic link verification
  Future<String?> getPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_pendingEmailKey);
  }

  /// Clear pending email (useful for error handling)
  Future<void> clearPendingEmail() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingEmailKey);
  }
  
  /// Show development error messages (no-op in release)
  void _showDevSnack(String msg) {
    // No-op in release; in debug show a global snack. Replace with your app's logger/toast solution.
    assert(() {
      print('[DEV-SNACK] $msg');
      return true;
    }());
  }
}

/// Custom exception class for authentication errors
class AuthException implements Exception {
  final String code;
  final String message;

  AuthException({required this.code, required this.message});

  factory AuthException._fromFirebaseAuthException(dynamic error) {
    if (error is FirebaseAuthException) {
      return AuthException(
        code: error.code,
        message: _getErrorMessage(error.code),
      );
    } else {
      return AuthException(
        code: 'unknown',
        message: 'Authentication failed: ${error.toString()}',
      );
    }
  }

  static String _getErrorMessage(String code) {
    switch (code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'network-request-failed':
        return 'Network error. Please check your connection and try again.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait a moment and try again.';
      case 'invalid-action-code':
      case 'expired-action-code':
        return 'This magic link has expired. Please request a new one.';
      case 'invalid-link':
        return 'Invalid magic link. Please request a new one.';
      case 'missing-email':
        return 'No pending email found. Please request a new magic link.';
      default:
        return 'Authentication failed. Please try again.';
    }
  }

  @override
  String toString() => 'AuthException($code): $message';
}

/// Global auth service instance
final authService = AuthService();

/// Extension to add dispose method to AuthService

extension AuthServiceDisposal on AuthService {
  /// Clean up resources
  void disposeResources() {
    _authStream.close();
  }
}
