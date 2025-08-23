import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class PhoneSetupScreen extends ConsumerStatefulWidget {
  const PhoneSetupScreen({super.key});

  @override
  ConsumerState<PhoneSetupScreen> createState() => _PhoneSetupScreenState();
}

class _PhoneSetupScreenState extends ConsumerState<PhoneSetupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _codeController = TextEditingController();
  
  bool _isPhoneStep = true;
  bool _isLoading = false;
  String? _errorMessage;
  String? _phoneSent;

  @override
  void dispose() {
    _phoneController.dispose();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _sendSMSCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await userService.addPhoneNumber(_phoneController.text);
      
      if (result['success'] == true) {
        setState(() {
          _isPhoneStep = false;
          _phoneSent = _phoneController.text;
        });
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Failed to send SMS code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _verifyCode() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final result = await userService.verifyPhoneNumber(_codeController.text);
      
      if (result['success'] == true) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Phone number verified!')),
          );
          context.go('/profile');
        }
      } else {
        setState(() {
          _errorMessage = result['error'] ?? 'Invalid verification code';
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Network error. Please try again.';
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => context.go('/profile'),
        ),
        title: Text(
          _isPhoneStep ? 'Add Phone Number' : 'Verify SMS Code',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isPhoneStep) ...[
                const Text(
                  'Phone Number',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Add your phone number to enable SMS account recovery',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  style: const TextStyle(color: AppColors.textPrimary),
                  decoration: InputDecoration(
                    labelText: 'Phone Number',
                    hintText: '+1234567890',
                    prefixIcon: const Icon(Icons.phone, color: AppColors.brandPrimary),
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
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
                const Text(
                  'Verification Code',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Enter the 6-digit code sent to $_phoneSent',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 32),
                TextFormField(
                  controller: _codeController,
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    letterSpacing: 2,
                  ),
                  decoration: InputDecoration(
                    labelText: 'SMS Code',
                    hintText: '123456',
                    prefixIcon: const Icon(Icons.sms, color: AppColors.brandPrimary),
                    filled: true,
                    fillColor: AppColors.darkSurface,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter the verification code';
                    }
                    if (value.trim().length != 6) {
                      return 'Please enter the 6-digit code';
                    }
                    return null;
                  },
                ),
              ],
              
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.red.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: Colors.red, size: 20),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              const Spacer(),
              
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : (_isPhoneStep ? _sendSMSCode : _verifyCode),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.black)
                      : Text(
                          _isPhoneStep ? 'Send SMS Code' : 'Verify Code',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),
              
              if (!_isPhoneStep) ...[
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: TextButton(
                    onPressed: () {
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
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}