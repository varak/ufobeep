/// Firebase Email Link Authentication Screen  
/// Handles passwordless email authentication using Firebase Auth
/// Provides account recovery via email without passwords

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:go_router/go_router.dart';
import '../../services/firebase_auth_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/app_localizations.dart';

class FirebaseEmailAuthScreen extends StatefulWidget {
  const FirebaseEmailAuthScreen({super.key});

  @override
  State<FirebaseEmailAuthScreen> createState() => _FirebaseEmailAuthScreenState();
}

class _FirebaseEmailAuthScreenState extends State<FirebaseEmailAuthScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  
  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _sendEmailLink() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final result = await firebaseAuthService.sendEmailLink(_emailController.text.trim());
      
      if (result['success'] == true) {
        setState(() {
          _isLoading = false;
          _successMessage = result['message'];
        });
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(_successMessage!),
              backgroundColor: AppColors.semanticSuccess,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      } else {
        setState(() {
          _isLoading = false;
          _errorMessage = result['error'] ?? AppLocalizations.of(context)!.emailAuthFailedToSend;
        });
      }
    } catch (e) {
      debugPrint('Error sending email link: $e');
      setState(() {
        _isLoading = false;
        _errorMessage = AppLocalizations.of(context)!.emailAuthFailedToSendTryAgain;
      });
    }
  }

  String _getErrorMessage(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return AppLocalizations.of(context)!.emailAuthInvalidEmail;
      case 'user-not-found':
        return AppLocalizations.of(context)!.emailAuthUserNotFound;
      case 'too-many-requests':
        return AppLocalizations.of(context)!.emailAuthTooManyRequests;
      case 'operation-not-allowed':
        return AppLocalizations.of(context)!.emailAuthOperationNotAllowed;
      case 'quota-exceeded':
        return AppLocalizations.of(context)!.emailAuthQuotaExceeded;
      default:
        return e.message ?? AppLocalizations.of(context)!.emailAuthVerificationFailed;
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
          AppLocalizations.of(context)!.emailAuthTitle,
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
                  AppLocalizations.of(context)!.emailAuthVerifyYourEmail,
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 16),
                
                Text(
                  AppLocalizations.of(context)!.emailAuthDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                
                const SizedBox(height: 32),
                
                // Email Input
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: AppLocalizations.of(context)!.emailAuthEmailAddress,
                    hintText: AppLocalizations.of(context)!.emailAuthEmailPlaceholder,
                    labelStyle: const TextStyle(color: AppColors.textSecondary),
                    prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
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
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return AppLocalizations.of(context)!.emailAuthPleaseEnterEmail;
                    }
                    if (!value.contains('@') || !value.contains('.')) {
                      return AppLocalizations.of(context)!.emailAuthPleaseEnterValidEmail;
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                // Success Message
                if (_successMessage != null)
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.semanticSuccess.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.mark_email_read,
                          color: AppColors.semanticSuccess,
                          size: 32,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          _successMessage!,
                          style: const TextStyle(
                            color: AppColors.semanticSuccess,
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppLocalizations.of(context)!.emailAuthCheckEmailToContinue,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                
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
                
                // Send Email Button
                SizedBox(
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _sendEmailLink,
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
                            _successMessage != null ? AppLocalizations.of(context)!.emailAuthResendEmail : AppLocalizations.of(context)!.emailAuthSendVerificationEmail,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                // How it Works Section
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: AppColors.brandPrimary,
                            size: 20,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            AppLocalizations.of(context)!.emailAuthHowItWorks,
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        AppLocalizations.of(context)!.emailAuthHowItWorksSteps,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const Spacer(),
                
                // Footer Info
                Text(
                  AppLocalizations.of(context)!.emailAuthSecurityNotice,
                  style: TextStyle(
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