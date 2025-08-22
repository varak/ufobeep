import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../services/device_service.dart';
import '../../theme/app_theme.dart';

class AccountRecoveryScreen extends ConsumerStatefulWidget {
  const AccountRecoveryScreen({super.key});

  @override
  ConsumerState<AccountRecoveryScreen> createState() => _AccountRecoveryScreenState();
}

class _AccountRecoveryScreenState extends ConsumerState<AccountRecoveryScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _recoveryCodeController = TextEditingController();
  
  bool _isEmailStep = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _emailSent;

  @override
  void dispose() {
    _emailController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryEmail() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final result = await userService.recoverAccount(_emailController.text.trim());
      
      if (result['success'] == true) {
        setState(() {
          _isEmailStep = false;
          _emailSent = _emailController.text.trim();
        });
      } else {
        setState(() {
          _errorMessage = result['message'] ?? 'Recovery request failed';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please check your connection and try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _verifyRecoveryCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      final deviceService = DeviceService();
      final deviceId = await deviceService.getDeviceId();
      
      final result = await userService.verifyRecoveryCode(
        _recoveryCodeController.text.trim(),
        deviceId,
      );
      
      if (result['success'] == true) {
        // Recovery successful - user data is now restored
        final username = result['username'];
        
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Welcome back, $username! Your account has been restored.'),
              backgroundColor: AppColors.semanticSuccess,
              duration: const Duration(seconds: 3),
            ),
          );
          
          // Navigate to main app
          context.go('/alerts');
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Invalid or expired recovery code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
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
        title: const Text(
          'Account Recovery',
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
                // UFO Icon and Title
                const Center(
                  child: Column(
                    children: [
                      Text(
                        '🛸',
                        style: TextStyle(fontSize: 64),
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Recover Your Account',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                
                const SizedBox(height: 32),
                
                if (_isEmailStep) ...[
                  // Email Step
                  const Text(
                    'Enter your verified email address to receive a recovery code:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    style: const TextStyle(color: AppColors.textPrimary),
                    decoration: InputDecoration(
                      labelText: 'Email Address',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.brandPrimary),
                      ),
                      prefixIcon: const Icon(Icons.email, color: AppColors.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!value.contains('@') || !value.contains('.')) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                  ),
                  
                ] else ...[
                  // Recovery Code Step
                  Column(
                    children: [
                      Icon(
                        Icons.email_outlined,
                        size: 48,
                        color: AppColors.brandPrimary,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Recovery code sent!',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Check your email ($_emailSent) for a 6-digit recovery code.',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 32),
                  
                  TextFormField(
                    controller: _recoveryCodeController,
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
                      labelText: 'Recovery Code',
                      labelStyle: const TextStyle(color: AppColors.textSecondary),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBorder),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.darkBorder),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(color: AppColors.brandPrimary),
                      ),
                      counterText: '',
                      hintText: '000000',
                      hintStyle: const TextStyle(color: AppColors.textSecondary),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter the recovery code';
                      }
                      if (value.trim().length != 6) {
                        return 'Recovery code must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ],
                
                const SizedBox(height: 24),
                
                // Error Message
                if (_errorMessage != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.semanticError.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.semanticError.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        Icon(
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
                  const SizedBox(height: 16),
                ],
                
                // Action Button
                ElevatedButton(
                  onPressed: _isLoading ? null : (_isEmailStep ? _sendRecoveryEmail : _verifyRecoveryCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: AppColors.textPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(AppColors.textPrimary),
                        ),
                      )
                    : Text(
                        _isEmailStep ? 'Send Recovery Code' : 'Recover Account',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ),
                
                const SizedBox(height: 16),
                
                // Secondary Actions
                if (!_isEmailStep) ...[
                  TextButton(
                    onPressed: _isLoading ? null : () {
                      setState(() {
                        _isEmailStep = true;
                        _errorMessage = null;
                        _recoveryCodeController.clear();
                      });
                    },
                    child: const Text(
                      'Use Different Email',
                      style: TextStyle(color: AppColors.textSecondary),
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Help Text
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Column(
                    children: [
                      Text(
                        '💡 Account Recovery',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        'Only works with verified email addresses. If you haven\'t verified your email, you\'ll need to create a new account.',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}