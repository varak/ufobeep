/// Hardened Authentication Service for UFOBeep
/// Handles ONLY email magic link authentication
/// NO anonymous auth - users are either null (unauthenticated) or authenticated via email

import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'device_service.dart';
import '../config/environment.dart';
import '../models/user_preferences.dart';
import '../features/auth/auth_gate.dart';

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

class AuthService implements AuthStateProvider {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _pendingEmailKey = 'pending_magic_link_email';
  static const String _apiBaseUrl = 'https://api.ufobeep.com';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  
  final DeviceService _deviceService = DeviceService();

  /// Initialize the AuthService - call this early in app startup
  Future<void> initialize() async {
    await _checkStoredAuth();
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
    // Check both Firebase auth and stored JWT token
    return _hasValidAuth() ? AuthStatus.authenticated : AuthStatus.unauthenticated;
  }

  /// Check if user has valid authentication (Firebase Auth OR stored JWT token)
  bool _hasValidAuth() {
    // Check both Firebase Auth and stored JWT tokens
    return isAuthenticated || _hasStoredToken;
  }

  /// Cached token check result to avoid repeated async calls
  bool _hasStoredToken = false;
  
  /// Initialize and check for stored authentication tokens
  Future<void> _checkStoredAuth() async {
    try {
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
      );
      
      final token = await storage.read(key: 'access_token');
      final userId = await storage.read(key: 'user_id');
      final username = await storage.read(key: 'username');
      
      _hasStoredToken = token != null && token.isNotEmpty && 
                       userId != null && userId.isNotEmpty && 
                       username != null && username.isNotEmpty;
                       
      if (_hasStoredToken) {
        print('✅ Found stored authentication tokens');
      }
    } catch (e) {
      print('⚠️ Error checking stored auth: $e');
      _hasStoredToken = false;
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
      
      // Store auth data securely
      const storage = FlutterSecureStorage(
        aOptions: AndroidOptions(encryptedSharedPreferences: true),
        iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
      );
      
      await storage.write(key: 'access_token', value: token);
      await storage.write(key: 'user_id', value: userId);
      await storage.write(key: 'username', value: username);
      await storage.write(key: 'is_registered', value: 'true');
      
      if (email != null) {
        await storage.write(key: 'user_email', value: email);
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

  /// ChatGPT's recommended method: Login with magic token data 
  /// Handles both custom scheme (full data) and HTTPS App Links (token-only)
  Future<void> loginWithMagicToken(Map<String, String> tokenData) async {
    final token = tokenData['token'];
    
    if (token == null || token.isEmpty) {
      throw Exception('Missing token in magic link data');
    }
    
    print('🔑 ChatGPT loginWithMagicToken: Processing token data');
    print('   Token: ${token.substring(0, 20)}...');
    
    // Check if we have full user data (custom scheme) or just token (HTTPS App Link)
    String? userId = tokenData['user_id'];
    String? username = tokenData['username'];
    String? email = tokenData['email'];
    bool isNewUser = tokenData['is_new_user'] == 'true';
    
    // If HTTPS App Link (token only), exchange with backend for user data
    if (userId == null || username == null) {
      print('🔄 HTTPS App Link detected - exchanging token with backend');
      
      try {
        final dio = Dio();
        final response = await dio.post(
          '${AppEnvironment.apiBaseUrl}/auth/magic/complete/app',
          data: {'token': token},
          options: Options(
            headers: {'Accept': 'application/json'},
            validateStatus: (status) => status != null && status < 500,
          ),
        );
        
        if (response.statusCode == 200) {
          final data = response.data as Map<String, dynamic>;
          userId = data['user_id'] as String?;
          username = data['username'] as String?;  
          email = email ?? data['email'] as String?;
          isNewUser = data['is_new_user'] as bool? ?? false;
          
          // Get Firebase custom token if provided
          final firebaseToken = data['firebase_custom_token'] as String?;
          if (firebaseToken != null && firebaseToken.isNotEmpty) {
            try {
              await FirebaseAuth.instance.signInWithCustomToken(firebaseToken);
              print('✅ Firebase authentication successful');
            } catch (e) {
              print('⚠️ Firebase authentication failed: $e');
              // Continue without Firebase auth - not critical
            }
          }
          
          print('✅ Token exchange successful');
          print('   User ID: $userId');
          print('   Username: $username');
          print('   Is New User: $isNewUser');
        } else {
          final errorData = response.data;
          final errorMessage = errorData is Map ? (errorData['detail'] ?? 'Token exchange failed') : 'Token exchange failed';
          throw Exception('Backend token exchange failed: $errorMessage');
        }
      } on DioException catch (e) {
        print('❌ Token exchange network error: ${e.message}');
        if (e.response?.statusCode == 400) {
          final errorData = e.response?.data;
          final errorMessage = errorData is Map ? (errorData['detail'] ?? 'Invalid or expired magic link') : 'Invalid or expired magic link';
          throw Exception(errorMessage);
        }
        throw Exception('Network error during token exchange. Please check your connection.');
      } catch (e) {
        print('❌ Token exchange failed: $e');
        throw Exception('Authentication failed: ${e.toString()}');
      }
    } else {
      print('✅ Custom scheme detected - using provided user data');
    }
    
    // Validate we now have required user data
    if (userId == null || username == null) {
      throw Exception('Failed to get user data from token exchange');
    }
    
    // Store auth data securely
    const storage = FlutterSecureStorage(
      aOptions: AndroidOptions(encryptedSharedPreferences: true),
      iOptions: IOSOptions(accessibility: KeychainAccessibility.first_unlock_this_device),
    );
    
    try {
      await storage.write(key: 'access_token', value: token);
      await storage.write(key: 'user_id', value: userId);
      await storage.write(key: 'username', value: username);
      await storage.write(key: 'is_registered', value: 'true');
      
      if (email != null) {
        await storage.write(key: 'user_email', value: email);
      }
      
      print('✅ ChatGPT loginWithMagicToken: Auth data stored securely');
      print('   Final User ID: $userId');
      print('   Final Username: $username');
      
      // Update auth state to reflect the new authentication
      await _checkStoredAuth();
      
      // User is now authenticated and ready to use the app
    } catch (e, stackTrace) {
      print('❌ ChatGPT loginWithMagicToken failed: $e');
      print('📚 Stack trace: $stackTrace');
      throw Exception('Failed to store authentication data: ${e.toString()}');
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
      await _auth.signOut();
      
      // Clear any pending email
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_pendingEmailKey);
      
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
      throw AuthException._fromFirebaseAuthException(e);
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