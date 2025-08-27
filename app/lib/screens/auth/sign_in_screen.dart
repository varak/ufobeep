import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/social_auth_service.dart';
import '../../services/user_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isGoogleLoading = false;
  bool _isMagicLinkLoading = false;
  String? _errorMessage;
  String? _successMessage;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleGoogleSignIn() async {
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      final socialAuthService = SocialAuthService();
      final result = await socialAuthService.signInWithGoogle();
      
      if (result.success) {
        if (mounted) {
          // Check if user has a username
          if (result.username != null && result.username!.isNotEmpty) {
            // User has complete profile - go to main app
            print('Google Sign-In: User has username "${result.username}", going to alerts');
            context.go('/alerts');
          } else {
            // User needs to create username - go to registration
            print('Google Sign-In: User needs username, going to registration');
            context.go('/register');
          }
        }
      } else {
        setState(() {
          _isGoogleLoading = false;
          _errorMessage = result.error ?? 'Google Sign-In failed. Please try again.';
          _successMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        _isGoogleLoading = false;
        _errorMessage = 'Google Sign-In error. Please try again.';
        _successMessage = null;
      });
    }
  }

  Future<void> _sendMagicLink() async {
    print('SIGN-IN DEBUG: _sendMagicLink called');
    final email = _emailController.text.trim();
    print('SIGN-IN DEBUG: Email entered: $email');
    
    if (email.isEmpty) {
      print('SIGN-IN DEBUG: Email is empty');
      setState(() {
        _errorMessage = 'Please enter your email address';
        _successMessage = null;
      });
      return;
    }

    // Basic email validation
    if (!email.contains('@') || !email.contains('.')) {
      print('SIGN-IN DEBUG: Email validation failed');
      setState(() {
        _errorMessage = 'Please enter a valid email address';
        _successMessage = null;
      });
      return;
    }

    setState(() {
      _isMagicLinkLoading = true;
      _errorMessage = null;
      _successMessage = null;
    });

    try {
      print('SIGN-IN DEBUG: Calling backend magic link API...');
      final result = await userService.sendMagicLink(email);
      
      if (result['success'] == true) {
        print('SIGN-IN DEBUG: Backend magic link sent successfully');
        setState(() {
          _isMagicLinkLoading = false;
          _successMessage = result['message'] ?? 'Magic link sent! Check your email and click the link to sign in.';
          _errorMessage = null;
        });
      } else {
        print('SIGN-IN DEBUG: Backend magic link failed: ${result['message']}');
        setState(() {
          _isMagicLinkLoading = false;
          _errorMessage = result['message'] ?? 'Failed to send magic link. Please try again.';
          _successMessage = null;
        });
      }
    } catch (e) {
      print('SIGN-IN DEBUG: Error sending magic link: $e');
      setState(() {
        _isMagicLinkLoading = false;
        _errorMessage = e is AuthException ? e.message : 'Failed to send magic link. Please try again.';
        _successMessage = null;
      });
    }
  }

  Future<void> _handleClearAllData() async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Clear All Data',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will completely reset the app and clear all authentication data. You will start fresh as a new user.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: AppColors.semanticError),
            child: const Text('Clear All Data'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    try {
      // Show loading indicator
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
      );

      print('CLEAR DATA: Starting complete data clear...');

      // 1. Sign out from Firebase Auth
      await authService.signOut();
      print('CLEAR DATA: Firebase Auth signed out');

      // 2. Sign out from Social Auth (Google)
      await SocialAuthService().signOut();
      print('CLEAR DATA: Social Auth signed out');

      // 3. Clear ALL SharedPreferences data
      final prefs = await SharedPreferences.getInstance();
      await prefs.clear();
      print('CLEAR DATA: SharedPreferences cleared');

      print('CLEAR DATA: All data cleared successfully');

      // Dismiss loading dialog
      if (mounted) {
        Navigator.pop(context);
      }

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('All data cleared! You can now sign in fresh.'),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );
      }

    } catch (e) {
      print('CLEAR DATA: Error during data clear: $e');
      
      // Dismiss loading dialog if still showing
      if (mounted) {
        Navigator.pop(context);
        
        // Show error message
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to clear data: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 48),
              
              // UFO Logo and Title
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: AppColors.brandPrimary.withOpacity(0.3),
                    width: 2,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.brandPrimary.withOpacity(0.1),
                      blurRadius: 20,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      '🛸',
                      style: TextStyle(
                        fontSize: 64,
                        shadows: [
                          Shadow(
                            color: AppColors.brandPrimary.withOpacity(0.5),
                            blurRadius: 20,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'UFOBeep',
                      style: TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Real-time Sighting Alerts',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 48),
              
              // Google Sign-In Button (Primary)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isGoogleLoading || _isMagicLinkLoading) ? null : _handleGoogleSignIn,
                  icon: _isGoogleLoading 
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          color: Colors.black87,
                          strokeWidth: 2,
                        ),
                      )
                    : Image.network(
                        'https://developers.google.com/identity/images/g-logo.png',
                        height: 18,
                        width: 18,
                        errorBuilder: (context, error, stackTrace) => const Icon(
                          Icons.login,
                          size: 18,
                          color: Colors.black87,
                        ),
                      ),
                  label: Text(
                    _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                    style: const TextStyle(
                      color: Colors.black87,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black87,
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: Colors.grey, width: 0.5),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Divider
              const Row(
                children: [
                  Expanded(child: Divider(color: AppColors.textTertiary)),
                  Padding(
                    padding: EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'or',
                      style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
                    ),
                  ),
                  Expanded(child: Divider(color: AppColors.textTertiary)),
                ],
              ),
              
              const SizedBox(height: 24),
              
              // Email Magic Link Form
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.darkBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Sign in with Email',
                      style: TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 8),
                    
                    const Text(
                      'Enter your email to receive a secure magic link',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Email Input
                    TextField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      enabled: !_isGoogleLoading && !_isMagicLinkLoading,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: 'Email Address',
                        labelStyle: const TextStyle(color: AppColors.textSecondary),
                        hintText: 'your@email.com',
                        hintStyle: TextStyle(color: AppColors.textSecondary.withOpacity(0.5)),
                        filled: true,
                        fillColor: AppColors.darkBackground,
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
                          borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
                        ),
                        prefixIcon: const Icon(
                          Icons.email_outlined,
                          color: AppColors.textSecondary,
                        ),
                      ),
                      onSubmitted: (_) => _sendMagicLink(),
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Send Magic Link Button
                    ElevatedButton(
                      onPressed: (_isGoogleLoading || _isMagicLinkLoading) ? null : _sendMagicLink,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        elevation: 0,
                      ),
                      child: _isMagicLinkLoading
                          ? Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                const Text(
                                  'Sending Magic Link...',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            )
                          : const Text(
                              'Send Magic Link',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                    ),
                    
                    const SizedBox(height: 16),
                    
                    // Error Message
                    if (_errorMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.semanticError.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.semanticError.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.error_outline,
                              color: AppColors.semanticError,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _errorMessage!,
                                style: const TextStyle(
                                  color: AppColors.semanticError,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    
                    // Success Message
                    if (_successMessage != null)
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.semanticSuccess.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: AppColors.semanticSuccess.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(
                              Icons.check_circle_outline,
                              color: AppColors.semanticSuccess,
                              size: 20,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _successMessage!,
                                style: const TextStyle(
                                  color: AppColors.semanticSuccess,
                                  fontSize: 14,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // Security Notice
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.darkBorder.withOpacity(0.5),
                  ),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.security,
                          color: AppColors.brandPrimary,
                          size: 20,
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Secure Authentication',
                          style: TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Use Google Sign-In for instant access, or email magic links that expire in 15 minutes.',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),
              
              // DEBUG: Clear all data option
              Center(
                child: TextButton(
                  onPressed: _handleClearAllData,
                  child: const Text(
                    'Clear All Data (Debug)',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}