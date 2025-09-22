/// Firebase Phone Authentication Screen
/// Handles phone number verification using Firebase Auth
/// Replaces Twilio SMS with Firebase's built-in phone auth

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class FirebasePhoneAuthScreen extends StatefulWidget {
  const FirebasePhoneAuthScreen({super.key});

  @override
  State<FirebasePhoneAuthScreen> createState() => _FirebasePhoneAuthScreenState();
}

class _FirebasePhoneAuthScreenState extends State<FirebasePhoneAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isPhoneStep = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _verificationId;
  int? _resendToken;
  
  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  String _formatPhoneNumber(String phone) {
    // Remove all non-digits
    String digits = phone.replaceAll(RegExp(r'[^0-9]'), '');
    
    // Add +1 if no country code and looks like US number
    if (digits.length == 10) {
      digits = '1$digits';
    }
    
    return '+$digits';
  }

  Future<void> _sendVerificationCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
      debugPrint('Sending verification code to: $formattedPhone');

      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          // Auto-verification completed (Android only)
          debugPrint('Auto-verification completed');
          await _linkPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          debugPrint('Verification failed: ${e.message}');
          setState(() {
            _isLoading = false;
            _errorMessage = _getErrorMessage(e);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          debugPrint('Code sent, verification ID: $verificationId');
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isPhoneStep = false;
            _isLoading = false;
          });
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          debugPrint('Auto-retrieval timeout for: $verificationId');
          setState(() {
            _verificationId = verificationId;
          });
        },
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      debugPrint('Error sending verification code: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.phoneAuthFailedToSendCode;
      });
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate() || _verificationId == null) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // Create phone credential
      final credential = PhoneAuthProvider.credential(
        verificationId: _verificationId!,
        smsCode: _codeController.text.trim(),
      );

      await _linkPhoneCredential(credential);
    } catch (e) {
      debugPrint('Error verifying code: $e');
      setState(() {
        _isLoading = false;
        if (e is FirebaseAuthException) {
          _errorMessage = _getErrorMessage(e);
        } else {
          _errorMessage = AppLocalizations.of(context)!.phoneAuthInvalidCodeTryAgain;
        }
      });
    }
  }

  Future<void> _linkPhoneCredential(PhoneAuthCredential credential) async {
    try {
      // No anonymous users allowed - always sign in with phone
      debugPrint('Signing in with phone credential...');
      final userCredential = await FirebaseAuth.instance.signInWithCredential(credential);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(AppLocalizations.of(context)!.phoneAuthPhoneVerified(userCredential.user?.phoneNumber ?? '')),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );
        
        context.pop(); // Return to previous screen
      }
    } catch (e) {
      debugPrint('Error linking/signing in with phone: $e');
      setState(() {
        _isLoading = false;
        if (e is FirebaseAuthException) {
          _errorMessage = _getErrorMessage(e);
        } else {
          _errorMessage = AppLocalizations.of(context)!.phoneAuthVerificationFailed;
        }
      });
    }
  }

  Future<void> _resendCode() async {
    if (_resendToken == null) {
      await _sendVerificationCode();
      return;
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final formattedPhone = _formatPhoneNumber(_phoneController.text.trim());
      
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,
        verificationCompleted: (PhoneAuthCredential credential) async {
          await _linkPhoneCredential(credential);
        },
        verificationFailed: (FirebaseAuthException e) {
          setState(() {
            _isLoading = false;
            _errorMessage = _getErrorMessage(e);
          });
        },
        codeSent: (String verificationId, int? resendToken) {
          setState(() {
            _verificationId = verificationId;
            _resendToken = resendToken;
            _isLoading = false;
          });
          
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text(AppLocalizations.of(context)!.phoneAuthCodeResent),
                backgroundColor: AppColors.semanticSuccess,
              ),
            );
          }
        },
        codeAutoRetrievalTimeout: (String verificationId) {
          setState(() {
            _verificationId = verificationId;
          });
        },
        forceResendingToken: _resendToken,
        timeout: const Duration(seconds: 60),
      );
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.phoneAuthFailedToResendCode;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-phone-number':
        return AppLocalizations.of(context)!.phoneAuthInvalidPhoneNumber;
      case 'too-many-requests':
        return AppLocalizations.of(context)!.phoneAuthTooManyRequests;
      case 'invalid-verification-code':
        return 'Invalid verification code. Please check and try again.';
      case 'session-expired':
        return 'Verification session expired. Please request a new code.';
      case 'quota-exceeded':
        return 'SMS quota exceeded. Please try again tomorrow.';
      case 'credential-already-in-use':
        return 'This phone number is already linked to another account.';
      default:
        return e.message ?? 'Verification failed. Please try again.';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.pop(),
        ),
        title: Text(
          AppLocalizations.of(context)!.phoneAuthTitle,
          style: TextStyle(color: AppColors.textPrimary),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Header
                Text(
                  _isPhoneStep ? AppLocalizations.of(context)!.phoneAuthVerifyYourPhone : AppLocalizations.of(context)!.phoneAuthEnterVerificationCode,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  _isPhoneStep 
                    ? AppLocalizations.of(context)!.phoneAuthAddPhoneForSecurity
                    : AppLocalizations.of(context)!.phoneAuthEnterSixDigitCode(_phoneController.text),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                if (_isPhoneStep) ...[
                  // Phone Number Step
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneAuthPhoneNumber,
                      hintText: AppLocalizations.of(context)!.phoneAuthPhonePlaceholder,
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      prefixIcon: const Icon(Icons.phone, color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandPrimary),
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9+\-\(\)\s]')),
                    ],
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return AppLocalizations.of(context)!.phoneAuthPleaseEnterPhone;
                      }
                      final digits = value.replaceAll(RegExp(r'[^0-9]'), '');
                      if (digits.length < 10) {
                        return AppLocalizations.of(context)!.phoneAuthPleaseEnterValidPhone;
                      }
                      return null;
                    },
                  ),
                ] else ...[
                  // Verification Code Step
                  TextFormField(
                    controller: _codeController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                    textAlign: TextAlign.center,
                    maxLength: 6,
                    decoration: InputDecoration(
                      labelText: AppLocalizations.of(context)!.phoneAuthVerificationCode,
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: AppColors.brandPrimary),
                      ),
                      filled: true,
                      fillColor: AppColors.darkSurface,
                      counterText: '',
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    validator: (value) {
                      if (value == null || value.length != 6) {
                        return AppLocalizations.of(context)!.phoneAuthPleaseEnterSixDigitCode;
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Resend Code Button
                  TextButton(
                    onPressed: _isLoading ? null : _resendCode,
                    child: const Text(
                      'Resend Code',
                      style: TextStyle(color: AppColors.brandPrimary),
                    ),
                  ),
                ],
                
                const SizedBox(height: 16),
                
                // Error Message
                if (_errorMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.semanticError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(
                        color: AppColors.semanticError,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                
                const SizedBox(height: 32),
                
                // Action Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : (_isPhoneStep ? _sendVerificationCode : _verifyCode),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary,
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.black,
                              strokeWidth: 2,
                            ),
                          )
                        : Text(
                            _isPhoneStep ? 'Send Verification Code' : 'Verify Code',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Back Button (for code step)
                if (!_isPhoneStep)
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _isPhoneStep = true;
                        _errorMessage = null;
                        _codeController.clear();
                      });
                    },
                    child: const Text(
                      'Change Phone Number',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                
                const Spacer(),
                
                // Info Text
                Text(
                  _isPhoneStep 
                    ? 'We\'ll send you a verification code via SMS. Standard message rates may apply.'
                    : 'Code expires in 60 seconds. Check your messages.',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}