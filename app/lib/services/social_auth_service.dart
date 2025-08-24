/// Social Authentication Service - MP15
/// Handles Google Sign-In and Apple Sign-In for UFOBeep
/// Integrates with backend social login endpoints

import 'dart:convert';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/device_service.dart';

class SocialAuthResult {
  final bool success;
  final String? userId;
  final String? username;
  final String? email;
  final List<String>? loginMethods;
  final bool isNewUser;
  final String? error;

  SocialAuthResult({
    required this.success,
    this.userId,
    this.username,
    this.email,
    this.loginMethods,
    this.isNewUser = false,
    this.error,
  });

  factory SocialAuthResult.success({
    required String userId,
    required String username,
    String? email,
    List<String>? loginMethods,
    bool isNewUser = false,
  }) {
    return SocialAuthResult(
      success: true,
      userId: userId,
      username: username,
      email: email,
      loginMethods: loginMethods,
      isNewUser: isNewUser,
    );
  }

  factory SocialAuthResult.failure(String error) {
    return SocialAuthResult(
      success: false,
      error: error,
    );
  }
}

class SocialAuthService {
  static const String _apiBaseUrl = 'https://api.ufobeep.com';
  static const String _userIdKey = 'user_id';
  static const String _usernameKey = 'username';
  static const String _isRegisteredKey = 'is_registered';
  
  // Google Sign-In configuration
  static final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId: '346511467728-gblvob9j4gvfviijtp1723pt4f2934im.apps.googleusercontent.com',
  );

  // Firebase Auth instance
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final DeviceService _deviceService = DeviceService();

  /// Sign in with Google - MP15
  /// Creates new account or links to existing account
  Future<SocialAuthResult> signInWithGoogle() async {
    try {
      print('Starting Google Sign-In...');
      
      // Nuke cached account to avoid stale tokens/permissions
      await _googleSignIn.signOut();
      await _googleSignIn.disconnect().catchError((_) {});
      
      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        return SocialAuthResult.failure('Google Sign-In cancelled by user');
      }

      print('Google Sign-In successful: ${googleUser.email}');
      
      // Get authentication details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      
      final hasId = googleAuth.idToken != null && googleAuth.idToken!.isNotEmpty;
      // TEMP diagnostic logs (remove later)
      // ignore: avoid_print
      print('GSIGN: idToken? ' + (hasId ? 'YES len=' + googleAuth.idToken!.length.toString() : 'NO'));
      // ignore: avoid_print
      print('GSIGN: accessToken? ' + ((googleAuth.accessToken?.isNotEmpty ?? false) ? 'YES' : 'NO'));
      
      if (!hasId) {
        return SocialAuthResult.failure('No Google idToken (likely consent/tester/cache issue)');
      }

      // Create Firebase credential from Google tokens
      final credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: googleAuth.accessToken,
      );
      
      // Sign in to Firebase with Google credential
      final UserCredential firebaseUser = await _firebaseAuth.signInWithCredential(credential);
      
      if (firebaseUser.user == null) {
        return SocialAuthResult.failure('Firebase authentication failed');
      }
      
      // Get Firebase ID token (this is what we send to backend)
      final firebaseIdToken = await firebaseUser.user!.getIdToken();
      
      // Get device info
      final deviceId = await _deviceService.getDeviceId();
      final platform = Platform.isAndroid ? 'android' : 'ios';

      print('FIREBASE: idToken len=' + (firebaseIdToken?.length.toString() ?? 'null'));

      // Call backend Firebase auth endpoint
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/auth/firebase'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $firebaseIdToken',
        },
        body: jsonEncode({
          'device_id': deviceId,
          'platform': platform,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store user info locally
        await _storeUserInfo(
          userId: data['user']['user_id'],
          username: data['user']['username'],
          deviceId: deviceId,
        );

        print('Google login successful: ${data['user']['username']}');
        
        return SocialAuthResult.success(
          userId: data['user']['user_id'],
          username: data['user']['username'],
          email: data['user']['email'],
          loginMethods: List<String>.from(data['user']['login_methods'] ?? []),
          isNewUser: data['is_new_user'] ?? false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return SocialAuthResult.failure(errorData['detail'] ?? 'Google login failed');
      }
    } catch (e) {
      print('Google Sign-In error: $e');
      return SocialAuthResult.failure('Google Sign-In error: $e');
    }
  }

  /// Sign in with Apple - MP15 (iOS only)
  /// Creates new account or links to existing account  
  Future<SocialAuthResult> signInWithApple() async {
    try {
      if (!Platform.isIOS) {
        return SocialAuthResult.failure('Apple Sign-In is only available on iOS');
      }

      print('Starting Apple Sign-In...');

      // Check if Apple Sign-In is available
      if (!await SignInWithApple.isAvailable()) {
        return SocialAuthResult.failure('Apple Sign-In is not available on this device');
      }

      // Trigger Apple Sign-In flow
      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      print('Apple Sign-In successful: ${credential.userIdentifier}');

      // Get device info
      final deviceId = await _deviceService.getDeviceId();
      final platform = 'ios';

      // Call backend Apple login endpoint
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/auth/apple'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'token': credential.identityToken,
          'user_id': credential.userIdentifier,
          'device_id': deviceId,
          'platform': platform,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        
        // Store user info locally
        await _storeUserInfo(
          userId: data['user']['user_id'],
          username: data['user']['username'],
          deviceId: deviceId,
        );

        print('Apple login successful: ${data['user']['username']}');
        
        return SocialAuthResult.success(
          userId: data['user']['user_id'],
          username: data['user']['username'],
          email: data['user']['email'],
          loginMethods: List<String>.from(data['user']['login_methods'] ?? []),
          isNewUser: data['is_new_user'] ?? false,
        );
      } else {
        final errorData = jsonDecode(response.body);
        return SocialAuthResult.failure(errorData['detail'] ?? 'Apple login failed');
      }
    } catch (e) {
      print('Apple Sign-In error: $e');
      return SocialAuthResult.failure('Apple Sign-In error: $e');
    }
  }

  /// Request magic link for passwordless login - MP15
  Future<bool> requestMagicLink(String email) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/request-magic-link'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'device_id': deviceId,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] ?? false;
      } else {
        return false;
      }
    } catch (e) {
      print('Magic link request error: $e');
      return false;
    }
  }

  /// Set password for enhanced security - MP15
  Future<bool> setPassword(String password) async {
    try {
      final deviceId = await _deviceService.getDeviceId();
      
      final response = await http.post(
        Uri.parse('$_apiBaseUrl/users/set-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'password': password,
          'device_id': deviceId,
        }),
      );

      return response.statusCode == 200;
    } catch (e) {
      print('Set password error: $e');
      return false;
    }
  }

  /// Sign out from social providers
  Future<void> signOut() async {
    try {
      // Sign out from Google
      if (await _googleSignIn.isSignedIn()) {
        await _googleSignIn.signOut();
      }
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_userIdKey);
      await prefs.remove(_usernameKey);
      await prefs.remove(_isRegisteredKey);
      
      print('Social auth sign out complete');
    } catch (e) {
      print('Sign out error: $e');
    }
  }

  /// Check if user is signed in with social providers
  Future<bool> isSignedIn() async {
    try {
      // Check Google Sign-In status
      final isGoogleSignedIn = await _googleSignIn.isSignedIn();
      
      // Check local storage
      final prefs = await SharedPreferences.getInstance();
      final hasLocalUser = prefs.containsKey(_userIdKey) && prefs.containsKey(_usernameKey);
      
      return isGoogleSignedIn || hasLocalUser;
    } catch (e) {
      print('Sign-in check error: $e');
      return false;
    }
  }

  /// Store user info locally
  Future<void> _storeUserInfo({
    required String userId,
    required String username,
    required String deviceId,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userIdKey, userId);
    await prefs.setString(_usernameKey, username);
    await prefs.setBool(_isRegisteredKey, true);
    
    print('User info stored locally: $username ($userId)');
  }

  /// Get current user info
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userId = prefs.getString(_userIdKey);
      final username = prefs.getString(_usernameKey);
      
      if (userId != null && username != null) {
        return {
          'userId': userId,
          'username': username,
        };
      }
      
      return null;
    } catch (e) {
      print('Get current user error: $e');
      return null;
    }
  }
}