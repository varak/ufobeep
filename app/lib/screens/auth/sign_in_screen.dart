import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../theme/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/social_auth_service.dart';
import '../../services/user_service.dart';
import '../../services/ui_feedback.dart';
import '../../widgets/glass_card.dart';

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
  bool _magicLinkSent = false;
  int _cooldownSeconds = 0;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Timer? _cooldownTimer;
  
  void _startCooldown() {
    _cooldownSeconds = 60;
    _cooldownTimer?.cancel();
    _cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_cooldownSeconds <= 0) {
        timer.cancel();
        if (mounted) {
          setState(() {
            _cooldownSeconds = 0;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _cooldownSeconds--;
          });
        }
      }
    });
  }

  Future<void> _handleGoogleSignIn() async {
    await UiFeedback.click();
    
    setState(() {
      _isGoogleLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('🔐 Starting Google Sign-In...');
      final result = await SocialAuthService().signInWithGoogle();
      
      if (result.success && result.userId != null) {
        debugPrint('✅ Google Sign-In successful for: ${result.email}');
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome ${result.username ?? result.email}!'),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );
        
        // Navigate to home screen after successful login
        if (mounted && context.mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      debugPrint('❌ Google Sign-In failed: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Sign-in failed: $e'),
          backgroundColor: AppColors.semanticError,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isGoogleLoading = false;
        });
      }
    }
  }

  Future<void> _sendMagicLink() async {
    await UiFeedback.click();
    
    if (_emailController.text.trim().isEmpty) {
      setState(() {
        _errorMessage = 'Please enter your email address';
      });
      return;
    }

    if (!_emailController.text.trim().contains('@')) {
      setState(() {
        _errorMessage = 'Please enter a valid email address';
      });
      return;
    }

    setState(() {
      _isMagicLinkLoading = true;
      _errorMessage = null;
    });

    try {
      debugPrint('📧 Sending magic link to: ${_emailController.text.trim()}');
      await AuthService().sendMagicLink(_emailController.text.trim());
      
      setState(() {
        _successMessage = 'Magic link sent! Check your email and click the link to sign in.';
        _magicLinkSent = true;
      });
      
      _startCooldown();
      debugPrint('✅ Magic link sent successfully');
      
    } catch (e) {
      debugPrint('❌ Magic link failed: $e');
      setState(() {
        _errorMessage = 'Failed to send magic link. Please try again.';
      });
    } finally {
      if (mounted) {
        setState(() {
          _isMagicLinkLoading = false;
        });
      }
    }
  }
  
  Future<void> _handleClearAllData() async {
    debugPrint('🗑️ Clearing all local data...');
    
    // Clear SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    
    // Clear AuthService data  
    await AuthService().signOut();
    
    setState(() {
      _emailController.clear();
      _magicLinkSent = false;
      _successMessage = null;
      _errorMessage = null;
      _cooldownSeconds = 0;
    });
    
    debugPrint('✅ All data cleared');
    
    // Show snackbar after clearing
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('All data cleared'),
          backgroundColor: AppColors.brandPrimary,
        ),
      );
    }
  }
  
  Future<void> _checkExistingAuth() async {
    debugPrint('🔍 Checking for existing authentication...');
    try {
      final user = await UserService.instance.getCurrentUser();
      if (user['userId'] != null && user['userId']!.isNotEmpty) {
        debugPrint('👤 Found existing user: ${user['username']}');
        if (mounted && context.mounted) {
          context.go('/');
        }
      }
    } catch (e) {
      debugPrint('⚠️ No existing auth found: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 48),
                
                // UFO Logo and Title
                GlassCard(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      // UFO Icon
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: RadialGradient(
                            colors: [
                              AppColors.brandPrimary.withOpacity(0.8),
                              AppColors.brandPrimary.withOpacity(0.4),
                              Colors.transparent,
                            ],
                          ),
                        ),
                        child: const Center(
                          child: Text(
                            '🛸',
                            style: TextStyle(fontSize: 64),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // App Title
                      const Text(
                        'UFOBeep',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                        ),
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'Real-time UFO sighting alerts and MUFON reports',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Google Sign-In Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton.icon(
                    onPressed: _isGoogleLoading ? null : _handleGoogleSignIn,
                    icon: _isGoogleLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Image.asset(
                            'assets/google_logo.png',
                            width: 20,
                            height: 20,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.login, color: Colors.white);
                            },
                          ),
                    label: Text(
                      _isGoogleLoading ? 'Signing in...' : 'Continue with Google',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: Colors.black87,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                
                const SizedBox(height: 24),
                
                const Row(
                  children: [
                    Expanded(child: Divider(color: Colors.white30)),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'or',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: Colors.white30)),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Email Magic Link Form
                GlassCard(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Text(
                        'Sign in with Email',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 8),
                      
                      const Text(
                        'We\'ll send you a secure link to sign in',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Email input
                      TextFormField(
                        controller: _emailController,
                        keyboardType: TextInputType.emailAddress,
                        style: const TextStyle(color: Colors.white),
                        decoration: InputDecoration(
                          labelText: 'Email address',
                          labelStyle: const TextStyle(color: Colors.white70),
                          hintText: 'your@email.com',
                          hintStyle: const TextStyle(color: Colors.white54),
                          prefixIcon: const Icon(Icons.email, color: Colors.white70),
                          fillColor: Colors.transparent,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: Colors.white30),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 24),
                      
                      // Send Magic Link Button
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: (_isMagicLinkLoading || _cooldownSeconds > 0) ? null : _sendMagicLink,
                          icon: _isMagicLinkLoading
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Icon(Icons.send),
                          label: Text(
                            _cooldownSeconds > 0 
                                ? 'Try again in ${_cooldownSeconds}s'
                                : _isMagicLinkLoading 
                                    ? 'Sending...' 
                                    : 'Send Magic Link',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.brandPrimary,
                            foregroundColor: Colors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                        ),
                      ),
                      
                      // Success message
                      if (_successMessage != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
                          decoration: BoxDecoration(
                            color: AppColors.semanticSuccess.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.semanticSuccess.withOpacity(0.3),
                            ),
                          ),
                          child: Row(
                            children: [
                              Icon(
                                Icons.mark_email_read,
                                color: AppColors.semanticSuccess,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _successMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Error message
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 16),
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
                              Icon(
                                Icons.error_outline,
                                color: AppColors.semanticError,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  _errorMessage!,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      
                      // Link resent message
                      if (_magicLinkSent) ...[
                        const SizedBox(height: 16),
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
                              Icon(
                                Icons.check_circle_outline,
                                color: AppColors.semanticSuccess,
                                size: 20,
                              ),
                              const SizedBox(width: 12),
                              const Expanded(
                                child: Text(
                                  'Check your email! The link expires in 15 minutes.',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 14,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                // Security Notice
                GlassCard(
                  padding: const EdgeInsets.all(16),
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
                              color: Colors.white,
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
                          color: Colors.white70,
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
                        color: Colors.white70,
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
      ),
    );
  }
}