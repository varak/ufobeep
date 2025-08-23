import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';

class UserRegistrationScreen extends StatefulWidget {
  const UserRegistrationScreen({super.key});

  @override
  State<UserRegistrationScreen> createState() => _UserRegistrationScreenState();
}

class _UserRegistrationScreenState extends State<UserRegistrationScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  
  bool _isGeneratingUsername = false;
  bool _isRegistering = false;
  double _alertRangeKm = 50.0;
  bool _unitsMetric = true;
  String _preferredLanguage = 'en';
  
  String? _generatedUsername;
  List<String> _usernameAlternatives = [];
  String? _selectedUsername;
  
  @override
  void initState() {
    super.initState();
    _generateInitialUsername();
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _generateInitialUsername() async {
    setState(() => _isGeneratingUsername = true);
    
    try {
      final response = await userService.generateUsername();
      setState(() {
        _generatedUsername = response.username;
        _usernameAlternatives = response.alternatives;
        _selectedUsername = response.username;
        _isGeneratingUsername = false;
      });
    } catch (e) {
      setState(() => _isGeneratingUsername = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to generate username: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }


  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isRegistering = true);

    try {
      final username = _selectedUsername;
      final email = _emailController.text.trim();

      final response = await userService.registerUser(
        customUsername: username,
        email: email.isNotEmpty ? email : null,
        alertRangeKm: _alertRangeKm,
        unitsMetric: _unitsMetric,
        preferredLanguage: _preferredLanguage,
      );

      if (mounted) {
        // Registration successful - show quick success message and navigate
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to UFOBeep, ${response.username}!'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );
        
        // Small delay to show the success message, then navigate
        await Future.delayed(const Duration(milliseconds: 1500));
        
        if (mounted) {
          // Navigate to main app
          context.go('/alerts');
        }
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Your UFO ID'),
        backgroundColor: AppColors.darkSurface,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header
              const Text(
                'Welcome to UFOBeep!',
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brandPrimary,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Create your unique cosmic identity to start reporting and witnessing UFO sightings.',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 32),

              // Username section
              _buildUsernameSection(),
              const SizedBox(height: 24),

              // Email section (optional)
              _buildEmailSection(),
              const SizedBox(height: 24),

              // Preferences section
              _buildPreferencesSection(),
              const SizedBox(height: 32),

              // Register button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: _isRegistering ? null : _register,
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppColors.brandPrimary),
                    foregroundColor: AppColors.brandPrimary,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    textStyle: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isRegistering
                      ? const CircularProgressIndicator(color: AppColors.brandPrimary)
                      : const Text('Create UFO ID'),
                ),
              ),
              const SizedBox(height: 16),

              // Note about required registration
              Center(
                child: Text(
                  'Registration helps us provide personalized alerts and better moderation',
                  style: TextStyle(
                    color: AppColors.textSecondary.withOpacity(0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUsernameSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.person, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            const Text(
              'Your UFO ID',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),

        // Generated username section
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Generated cosmic username:',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                
                if (_isGeneratingUsername)
                  const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
                else if (_generatedUsername != null) ...[
                  Text(
                    _selectedUsername ?? _generatedUsername!,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  
                  // Alternative options
                  if (_usernameAlternatives.isNotEmpty) ...[
                    const Text(
                      'Or choose from alternatives:',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: _usernameAlternatives.map((alt) {
                        return GestureDetector(
                          onTap: () => setState(() => _selectedUsername = alt),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: _selectedUsername == alt 
                                  ? AppColors.brandPrimary.withOpacity(0.2)
                                  : AppColors.darkBorder.withOpacity(0.3),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: _selectedUsername == alt
                                    ? AppColors.brandPrimary
                                    : Colors.transparent,
                              ),
                            ),
                            child: Text(
                              alt,
                              style: TextStyle(
                                color: _selectedUsername == alt 
                                    ? AppColors.brandPrimary
                                    : AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                  
                  const SizedBox(height: 12),
                  Center(
                    child: TextButton.icon(
                      onPressed: _generateInitialUsername,
                      icon: const Icon(Icons.refresh, size: 16),
                      label: const Text('Generate New'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.brandPrimary,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildEmailSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.email, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            const Text(
              'Email (Optional)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        const Text(
          'Add email for account recovery and notifications',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        TextFormField(
          controller: _emailController,
          keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            hintText: 'your.email@example.com',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
          ),
          validator: (value) {
            if (value != null && value.isNotEmpty) {
              if (!value.contains('@')) {
                return 'Please enter a valid email address';
              }
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildPreferencesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.settings, color: AppColors.brandPrimary),
            const SizedBox(width: 8),
            const Text(
              'Preferences',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),

        // Alert range
        Text(
          'Alert Range: ${_alertRangeKm.round()} km',
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        Slider(
          value: _alertRangeKm,
          min: 1,
          max: 200,
          divisions: 199,
          activeColor: AppColors.brandPrimary,
          onChanged: (value) => setState(() => _alertRangeKm = value),
        ),
        const SizedBox(height: 16),

        // Units preference
        SwitchListTile(
          title: const Text('Use Metric Units'),
          subtitle: Text(_unitsMetric ? 'kilometers, meters' : 'miles, feet'),
          value: _unitsMetric,
          activeColor: AppColors.brandPrimary,
          onChanged: (value) => setState(() => _unitsMetric = value),
        ),
      ],
    );
  }
}