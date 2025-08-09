import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../widgets/profile/language_selector.dart';
import '../../widgets/profile/range_selector.dart';
import '../../theme/app_theme.dart';
import '../../config/environment.dart';

class RegistrationScreen extends ConsumerStatefulWidget {
  const RegistrationScreen({super.key});

  @override
  ConsumerState<RegistrationScreen> createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends ConsumerState<RegistrationScreen> {
  final _displayNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _scrollController = ScrollController();

  bool _isLoading = false;

  @override
  void dispose() {
    _displayNameController.dispose();
    _emailController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final registration = ref.watch(registrationProvider);
    final registrationNotifier = ref.read(registrationProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Welcome to UFOBeep'),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
                ),
                child: Column(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: AppColors.brandPrimary.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.visibility,
                        color: AppColors.brandPrimary,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Set up your account',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Configure your preferences for receiving sighting alerts and managing your UFOBeep experience.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Display Name
              _buildSection(
                title: 'Display Name',
                required: true,
                child: TextFormField(
                  controller: _displayNameController,
                  decoration: InputDecoration(
                    hintText: 'Enter your display name',
                    filled: true,
                    fillColor: AppColors.darkSurface,
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
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Display name is required';
                    }
                    if (value.trim().length < 2) {
                      return 'Display name must be at least 2 characters';
                    }
                    return null;
                  },
                  onChanged: registrationNotifier.updateDisplayName,
                ),
              ),

              const SizedBox(height: 24),

              // Email (Optional)
              _buildSection(
                title: 'Email (Optional)',
                child: TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: InputDecoration(
                    hintText: 'Enter your email address',
                    filled: true,
                    fillColor: AppColors.darkSurface,
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
                  ),
                  style: const TextStyle(color: AppColors.textPrimary),
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');
                      if (!emailRegex.hasMatch(value)) {
                        return 'Please enter a valid email address';
                      }
                    }
                    return null;
                  },
                  onChanged: registrationNotifier.updateEmail,
                ),
              ),

              const SizedBox(height: 24),

              // Language Selection
              _buildSection(
                title: 'Language',
                child: LanguageSelector(
                  selectedLanguage: registration.language,
                  onLanguageChanged: registrationNotifier.updateLanguage,
                ),
              ),

              const SizedBox(height: 24),

              // Alert Range
              _buildSection(
                title: 'Alert Range',
                child: RangeSelector(
                  selectedRange: registration.alertRangeKm,
                  onRangeChanged: registrationNotifier.updateAlertRange,
                ),
              ),

              const SizedBox(height: 24),

              // Notifications Toggle
              _buildSection(
                title: 'Notifications',
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        registration.enableNotifications 
                            ? Icons.notifications_active
                            : Icons.notifications_off,
                        color: registration.enableNotifications 
                            ? AppColors.brandPrimary
                            : AppColors.textSecondary,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Push Notifications',
                              style: TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 2),
                            const Text(
                              'Receive alerts for nearby sightings',
                              style: TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Switch(
                        value: registration.enableNotifications,
                        onChanged: (_) => registrationNotifier.toggleNotifications(),
                        activeColor: AppColors.brandPrimary,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // Legal Agreements
              _buildLegalSection(registration, registrationNotifier),

              const SizedBox(height: 32),

              // Register Button
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: registration.isValid && !_isLoading
                      ? () => _handleRegistration()
                      : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    disabledBackgroundColor: AppColors.brandPrimary.withOpacity(0.3),
                    foregroundColor: AppColors.textInverse,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.textInverse,
                            ),
                          ),
                        )
                      : const Text(
                          'Complete Setup',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                ),
              ),

              const SizedBox(height: 16),

              // Skip Button
              Center(
                child: TextButton(
                  onPressed: _isLoading ? null : () => context.go('/'),
                  child: const Text(
                    'Skip for now',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required Widget child,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(
                  color: AppColors.semanticError,
                  fontSize: 18,
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildLegalSection(
    RegistrationData registration,
    RegistrationNotifier registrationNotifier,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Legal Agreement',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 16),
          _buildCheckboxTile(
            value: registration.agreeToTerms,
            onChanged: (_) => registrationNotifier.toggleTermsAgreement(),
            title: 'I agree to the Terms of Service',
            required: true,
          ),
          const SizedBox(height: 12),
          _buildCheckboxTile(
            value: registration.agreeToPrivacyPolicy,
            onChanged: (_) => registrationNotifier.togglePrivacyAgreement(),
            title: 'I agree to the Privacy Policy',
            required: true,
          ),
        ],
      ),
    );
  }

  Widget _buildCheckboxTile({
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String title,
    bool required = false,
  }) {
    return Row(
      children: [
        Checkbox(
          value: value,
          onChanged: onChanged,
          activeColor: AppColors.brandPrimary,
          checkColor: AppColors.textInverse,
        ),
        Expanded(
          child: GestureDetector(
            onTap: () => onChanged(!value),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                if (required) ...[
                  const Text(
                    ' *',
                    style: TextStyle(
                      color: AppColors.semanticError,
                      fontSize: 14,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegistration() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final registration = ref.read(registrationProvider);
      final userPreferences = registration.toUserPreferences();
      
      final preferencesNotifier = ref.read(userPreferencesProvider.notifier);
      final success = await preferencesNotifier.updatePreferences(userPreferences);

      if (success && mounted) {
        // Reset registration state
        ref.read(registrationProvider.notifier).reset();
        
        // Navigate to home
        context.go('/');
        
        // Show success message
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Profile set up successfully!'),
            backgroundColor: AppColors.semanticSuccess,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Failed to save profile. Please try again.'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}