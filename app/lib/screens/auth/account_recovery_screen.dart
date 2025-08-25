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
  final _phoneController = TextEditingController();
  final _recoveryCodeController = TextEditingController();
  
  bool _isEmailStep = true;
  bool _isLoading = false;
  bool _useEmail = true;
  String? _errorMessage;
  String? _contactSent;
  bool _hasLoadedSavedData = false;

  @override
  void initState() {
    super.initState();
    _loadSavedContactInfo();
  }

  /// Load saved email and phone from user storage
  Future<void> _loadSavedContactInfo() async {
    try {
      final userService = UserService.instance;
      final savedEmail = await userService.getSavedEmail();
      final savedPhone = await userService.getSavedPhone();
      
      if (mounted) {
        setState(() {
          if (savedEmail != null) {
            _emailController.text = savedEmail;
          }
          if (savedPhone != null) {
            _phoneController.text = savedPhone;
          }
          
          // Default to email if we have it, otherwise phone
          if (savedEmail != null) {
            _useEmail = true;
          } else if (savedPhone != null) {
            _useEmail = false;
          }
          
          _hasLoadedSavedData = true;
        });
      }
    } catch (e) {
      print('Failed to load saved contact info: $e');
      if (mounted) {
        setState(() {
          _hasLoadedSavedData = true;
        });
      }
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _phoneController.dispose();
    _recoveryCodeController.dispose();
    super.dispose();
  }

  Future<void> _sendRecoveryCode() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final userService = ref.read(userServiceProvider);
      Map<String, dynamic> result;
      
      if (_useEmail) {
        result = await userService.recoverAccount(_emailController.text.trim());
        _contactSent = _emailController.text.trim();
      } else {
        result = await userService.recoverAccountWithPhone(_phoneController.text.trim());
        _contactSent = _phoneController.text.trim();
      }
      
      if (result['success'] == true) {
        setState(() {
          _isEmailStep = false;
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
          'Sign In with Email/SMS',
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
                        'Sign In to Your Account',
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
                  // Recovery Method Toggle
                  Container(
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useEmail = true),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: _useEmail ? AppColors.brandPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.email,
                                    color: _useEmail ? Colors.black : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'Email',
                                    style: TextStyle(
                                      color: _useEmail ? Colors.black : AppColors.textSecondary,
                                      fontWeight: _useEmail ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _useEmail = false),
                            child: Container(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              decoration: BoxDecoration(
                                color: !_useEmail ? AppColors.brandPrimary : Colors.transparent,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    Icons.sms,
                                    color: !_useEmail ? Colors.black : AppColors.textSecondary,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    'SMS',
                                    style: TextStyle(
                                      color: !_useEmail ? Colors.black : AppColors.textSecondary,
                                      fontWeight: !_useEmail ? FontWeight.w600 : FontWeight.normal,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: 24),
                  
                  Text(
                    _useEmail 
                        ? (_emailController.text.isNotEmpty 
                            ? 'Your saved email address is ready. Tap Send Sign-In Code to continue:'
                            : 'Enter your verified email address to receive a sign-in code:')
                        : (_phoneController.text.isNotEmpty 
                            ? 'Your saved phone number is ready. Tap Send Sign-In Code to continue:'
                            : 'Enter your verified phone number to receive a sign-in code:'),
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  if (_useEmail)
                    TextFormField(
                      controller: _emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: _emailController.text.isNotEmpty ? 'Email Address (saved)' : 'Email Address',
                        labelStyle: TextStyle(
                          color: _emailController.text.isNotEmpty ? AppColors.brandPrimary : AppColors.textSecondary,
                        ),
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
                        prefixIcon: Icon(
                          _emailController.text.isNotEmpty ? Icons.check_circle_outline : Icons.email, 
                          color: _emailController.text.isNotEmpty ? AppColors.brandPrimary : AppColors.textSecondary,
                        ),
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
                    )
                  else
                    TextFormField(
                      controller: _phoneController,
                      keyboardType: TextInputType.phone,
                      style: const TextStyle(color: AppColors.textPrimary),
                      decoration: InputDecoration(
                        labelText: _phoneController.text.isNotEmpty ? 'Phone Number (saved)' : 'Phone Number',
                        hintText: '+1234567890',
                        labelStyle: TextStyle(
                          color: _phoneController.text.isNotEmpty ? AppColors.brandPrimary : AppColors.textSecondary,
                        ),
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
                        prefixIcon: Icon(
                          _phoneController.text.isNotEmpty ? Icons.check_circle_outline : Icons.phone, 
                          color: _phoneController.text.isNotEmpty ? AppColors.brandPrimary : AppColors.textSecondary,
                        ),
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Please enter your phone number';
                        }
                        if (value.trim().length < 10) {
                          return 'Please enter a valid phone number';
                        }
                        return null;
                      },
                    ),
                  
                ] else ...[
                  // Sign-In Code Step
                  Column(
                    children: [
                      Icon(
                        _useEmail ? Icons.email_outlined : Icons.sms_outlined,
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
                        _useEmail 
                            ? 'Check your email ($_contactSent) for a 6-digit recovery code.'
                            : 'Check your phone ($_contactSent) for a 6-digit SMS recovery code.',
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
                      labelText: 'Sign-In Code',
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
                  onPressed: _isLoading ? null : (_isEmailStep ? _sendRecoveryCode : _verifyRecoveryCode),
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
                        _isEmailStep ? 'Send Sign-In Code' : 'Sign In',
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