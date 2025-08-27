/// Firebase Auth Service for UFOBeep
/// Handles anonymous auth, phone verification, and email link auth
/// Replaces Twilio SMS with Firebase's built-in phone auth

import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class FirebaseAuthService {
  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  static const String _usernameKey = 'username';
  static const String _userIdKey = 'firebase_uid';
  
  static final FirebaseAuthService _instance = FirebaseAuthService._internal();
  factory FirebaseAuthService() => _instance;
  FirebaseAuthService._internal();

  /// Get current Firebase user
  User? get currentUser => _auth.currentUser;
  
  /// Get current user ID (Firebase UID)
  String? get currentUserId => _auth.currentUser?.uid;
  
  /// Check if user is signed in
  bool get isSignedIn => _auth.currentUser != null;
  
  /// Check if user has authenticated (not anonymous, only email/phone auth allowed)
  bool get isAuthenticated => _auth.currentUser != null;

  /// Initialize auth listener - NO automatic sign in
  /// App must remain in unauthenticated state until user explicitly signs in
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  /// Store username in Firestore and local storage
  Future<void> setUsername(String username) async {
    if (currentUser == null) {
      throw Exception('No authenticated user');
    }

    try {
      // Store in Firestore - only for authenticated users
      await _firestore.collection('users').doc(currentUser!.uid).set({
        'username': username,
        'uid': currentUser!.uid,
        'authProvider': 'email', // Only email/phone auth allowed now
        'createdAt': FieldValue.serverTimestamp(),
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      // Store locally for offline access
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usernameKey, username);
      await prefs.setString(_userIdKey, currentUser!.uid);
      
      print('Username saved: $username for UID: ${currentUser!.uid}');
    } catch (e) {
      print('Error saving username: $e');
      throw Exception('Failed to save username: $e');
    }
  }

  /// Get username from local storage or Firestore
  Future<String?> getUsername() async {
    try {
      // Try local storage first (faster)
      final prefs = await SharedPreferences.getInstance();
      String? localUsername = prefs.getString(_usernameKey);
      
      if (localUsername != null) {
        return localUsername;
      }

      // Fallback to Firestore if user is signed in
      if (currentUser != null) {
        final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
        if (doc.exists) {
          final username = doc.data()?['username'] as String?;
          if (username != null) {
            // Cache it locally
            await prefs.setString(_usernameKey, username);
            return username;
          }
        }
      }

      return null;
    } catch (e) {
      print('Error getting username: $e');
      return null;
    }
  }

  /// Start phone number verification
  Future<String?> verifyPhoneNumber({
    required String phoneNumber,
    required Function(PhoneAuthCredential) verificationCompleted,
    required Function(FirebaseAuthException) verificationFailed,
    required Function(String, int?) codeSent,
    required Function(String) codeAutoRetrievalTimeout,
  }) async {
    try {
      print('Starting phone verification for: $phoneNumber');
      
      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: verificationCompleted,
        verificationFailed: verificationFailed,
        codeSent: codeSent,
        codeAutoRetrievalTimeout: codeAutoRetrievalTimeout,
        timeout: const Duration(seconds: 60),
      );
      
      return null; // Success - callbacks will handle the rest
    } catch (e) {
      print('Error starting phone verification: $e');
      return 'Failed to send verification code: $e';
    }
  }

  /// Verify SMS code and link to current account
  Future<Map<String, dynamic>> verifySmsCode({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      print('Verifying SMS code...');
      
      // Create phone credential
      final PhoneAuthCredential credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      // Always sign in with phone credential - no anonymous users allowed
      print('Signing in with phone credential...');
      final userCredential = await _auth.signInWithCredential(credential);
      
      // Create/update user document in Firestore
      await _firestore.collection('users').doc(userCredential.user!.uid).set({
        'phoneNumber': userCredential.user?.phoneNumber,
        'phoneVerified': true,
        'authProvider': 'phone',
        'lastActive': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
      
      return {
        'success': true,
        'message': 'Phone number verified successfully',
        'uid': userCredential.user?.uid,
        'phoneNumber': userCredential.user?.phoneNumber,
      };
    } catch (e) {
      print('Error verifying SMS code: $e');
      return {
        'success': false,
        'error': 'Invalid verification code: $e',
      };
    }
  }

  /// Send email link for passwordless authentication
  Future<Map<String, dynamic>> sendEmailLink(String email) async {
    try {
      print('Sending email link to: $email');
      
      final actionCodeSettings = ActionCodeSettings(
        url: 'https://ufobeep.com/auth/email-link', // Deep link back to app
        handleCodeInApp: true,
        iOSBundleId: 'com.ufobeep.ufobeep',
        androidPackageName: 'com.ufobeep.ufobeep',
        androidMinimumVersion: '1',
      );

      await _auth.sendSignInLinkToEmail(
        email: email,
        actionCodeSettings: actionCodeSettings,
      );

      // Store email locally for verification
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('auth_email', email);

      return {
        'success': true,
        'message': 'Verification email sent to $email',
        'email': email,
      };
    } catch (e) {
      print('Error sending email link: $e');
      return {
        'success': false,
        'error': 'Failed to send email: $e',
      };
    }
  }

  /// Sign in with email link and optionally link to anonymous account
  Future<Map<String, dynamic>> signInWithEmailLink(String emailLink) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final email = prefs.getString('auth_email');
      
      if (email == null) {
        return {
          'success': false,
          'error': 'No email found for verification',
        };
      }

      if (_auth.isSignInWithEmailLink(emailLink)) {
        // Create email credential
        final AuthCredential credential = EmailAuthProvider.credentialWithLink(
          email: email,
          emailLink: emailLink,
        );

        // Always sign in with email credential - no anonymous users allowed
        print('Signing in with email link credential...');
        final userCredential = await _auth.signInWithCredential(credential);
        
        // Create/update user document in Firestore
        await _firestore.collection('users').doc(userCredential.user!.uid).set({
          'email': email,
          'emailVerified': true,
          'authProvider': 'email',
          'lastActive': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        
        return {
          'success': true,
          'message': 'Email verified successfully',
          'uid': userCredential.user?.uid,
          'email': email,
        };
      } else {
        return {
          'success': false,
          'error': 'Invalid email verification link',
        };
      }
    } catch (e) {
      print('Error signing in with email link: $e');
      return {
        'success': false,
        'error': 'Email verification failed: $e',
      };
    }
  }

  /// Get user profile data
  Future<Map<String, dynamic>?> getUserProfile() async {
    if (currentUser == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(currentUser!.uid).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error getting user profile: $e');
      return null;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_usernameKey);
      await prefs.remove(_userIdKey);
      await prefs.remove('auth_email');
      
      print('User signed out successfully');
    } catch (e) {
      print('Error signing out: $e');
    }
  }

  /// Delete account
  Future<Map<String, dynamic>> deleteAccount() async {
    if (currentUser == null) {
      return {'success': false, 'error': 'No user signed in'};
    }

    try {
      final uid = currentUser!.uid;
      
      // Delete Firestore data
      await _firestore.collection('users').doc(uid).delete();
      
      // Delete Firebase Auth account
      await currentUser!.delete();
      
      // Clear local storage
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();

      return {'success': true, 'message': 'Account deleted successfully'};
    } catch (e) {
      print('Error deleting account: $e');
      return {'success': false, 'error': 'Failed to delete account: $e'};
    }
  }
}

/// Global instance
final firebaseAuthService = FirebaseAuthService();