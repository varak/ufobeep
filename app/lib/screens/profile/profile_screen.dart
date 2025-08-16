import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../admin/admin_screen.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scrollController = ScrollController();
  bool _showAdminAccess = false;
  int _adminTapCount = 0;
  String _appVersion = '0.1.0';

  @override
  void initState() {
    super.initState();
    _loadAppVersion();
  }
  
  Future<void> _loadAppVersion() async {
    final version = await AppEnvironment.getAppVersion();
    if (mounted) {
      setState(() {
        _appVersion = version;
      });
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userPreferences = ref.watch(userPreferencesProvider);
    final isRegistered = ref.watch(isRegisteredProvider);

    // If user is not registered, show registration prompt
    if (!isRegistered || userPreferences == null) {
      return _buildRegistrationPrompt();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(userPreferences),
            
            const SizedBox(height: 32),
            
            // Profile Settings
            _buildProfileSettings(userPreferences),
            
            const SizedBox(height: 24),
            
            // App Settings
            _buildAppSettings(userPreferences),
            
            const SizedBox(height: 32),
            
            // Action Buttons
            _buildActionButtons(),
            
            const SizedBox(height: 24),
            
            // Hidden Admin Access (debug builds and beta versions)
            if (kDebugMode || _appVersion.contains('beta')) _buildAdminAccess(),
          ],
        ),
      ),
    );
  }

  Widget _buildRegistrationPrompt() {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.person_add,
                color: AppColors.brandPrimary,
                size: 60,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Set up your profile',
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Configure your preferences to get personalized sighting alerts and make the most of UFOBeep.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 32),
            // Privacy Policy and Terms Links
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  onPressed: _openPrivacyPolicy,
                  child: const Text(
                    'Privacy Policy',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
                const Text(
                  ' • ',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                TextButton(
                  onPressed: _openTermsOfService,
                  child: const Text(
                    'Terms of Service',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 56,
              child: ElevatedButton(
                onPressed: () => context.push('/register'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: AppColors.textInverse,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Get Started',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            TextButton(
              onPressed: () => context.go('/'),
              child: const Text(
                'Continue without profile',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.brandPrimary.withOpacity(0.2),
            child: const Icon(
              Icons.person,
              color: AppColors.brandPrimary,
              size: 40,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UFOBeep User',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                GestureDetector(
                  onTap: _handleAdminTap,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.darkBorder.withOpacity(0.3),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      'v$_appVersion',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }


  Widget _buildProfileSettings(UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Basic Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Alert Range - Always editable
          _buildSimpleSettingItem(
            icon: Icons.notifications,
            title: 'Alert Range',
            value: preferences.alertRangeDisplay,
            onTap: () => _showRangeSelector(preferences),
          ),
          
          const SizedBox(height: 16),
          
          // Language - Always editable (but fix crash first)
          _buildSimpleSettingItem(
            icon: Icons.language,
            title: 'Language',
            value: preferences.language.toUpperCase(),
            onTap: () => _showLanguageSelector(preferences),
          ),
          
          const SizedBox(height: 16),
          
          // Units - Always editable
          _buildSimpleSettingItem(
            icon: Icons.straighten,
            title: 'Units',
            value: preferences.units == 'metric' ? 'Metric' : 'Imperial',
            onTap: () => _toggleUnits(preferences),
          ),
        ],
      ),
    );
  }

  Widget _buildAppSettings(UserPreferences preferences) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'App Settings',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          _buildSettingsTile(
            icon: Icons.notifications,
            title: 'Push Notifications',
            subtitle: 'Receive alerts for nearby sightings',
            value: preferences.enablePushNotifications,
            onChanged: _togglePushNotifications,
          ),
          
          _buildSettingsTile(
            icon: Icons.location_on,
            title: 'Location Alerts',
            subtitle: 'Get notified based on your location',
            value: preferences.enableLocationAlerts,
            onChanged: _toggleLocationAlerts,
          ),
        ],
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.brandPrimary.withOpacity(0.2)
                  : AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              icon,
              color: value ? AppColors.brandPrimary : AppColors.textSecondary,
              size: 20,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandPrimary,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: TextButton(
        onPressed: () => _showLogoutDialog(),
        child: const Text(
          'Clear Profile Data',
          style: TextStyle(color: AppColors.semanticError),
        ),
      ),
    );
  }

  Widget _buildSimpleSettingItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                icon,
                color: AppColors.brandPrimary,
                size: 18,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _getInitials(String name) {
    final words = name.trim().split(' ');
    if (words.length >= 2) {
      return '${words[0][0]}${words[1][0]}'.toUpperCase();
    } else if (words.isNotEmpty) {
      return words[0][0].toUpperCase();
    }
    return 'U';
  }

  void _showRangeSelector(UserPreferences preferences) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Alert Range',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildRangeOption('5 km', 5.0, preferences.alertRangeKm),
            _buildRangeOption('10 km', 10.0, preferences.alertRangeKm),
            _buildRangeOption('25 km', 25.0, preferences.alertRangeKm),
            _buildRangeOption('50 km', 50.0, preferences.alertRangeKm),
            _buildRangeOption('100 km', 100.0, preferences.alertRangeKm),
            _buildRangeOption('Show all alerts', 999999.0, preferences.alertRangeKm),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildRangeOption(String label, double value, double currentValue) {
    final isSelected = value == currentValue;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandPrimary) : null,
      onTap: () async {
        // Only pop if we can safely navigate back
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Do the update after dialog closes to avoid rebuild issues
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _updateAlertRange(value);
        }
      },
    );
  }

  void _showLanguageSelector(UserPreferences preferences) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Language',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('English', 'en', preferences.language),
            _buildLanguageOption('Español', 'es', preferences.language),
            _buildLanguageOption('Français', 'fr', preferences.language),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageOption(String label, String code, String currentCode) {
    final isSelected = code == currentCode;
    return ListTile(
      title: Text(
        label,
        style: TextStyle(
          color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected ? const Icon(Icons.check, color: AppColors.brandPrimary) : null,
      onTap: () async {
        // Only pop if we can safely navigate back
        if (Navigator.canPop(context)) {
          Navigator.pop(context);
        }
        // Do the update after dialog closes to avoid rebuild issues
        await Future.delayed(const Duration(milliseconds: 100));
        if (mounted) {
          _updateLanguage(code);
        }
      },
    );
  }

  void _toggleUnits(UserPreferences preferences) {
    final newUnits = preferences.units == 'metric' ? 'imperial' : 'metric';
    _updateUnits(newUnits);
  }

  void _updateLanguage(String language) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.updateLanguage(language);
  }

  void _updateAlertRange(double range) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.updateAlertRange(range);
  }

  void _updateUnits(String units) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.updateUnits(units);
  }


  void _togglePushNotifications(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.togglePushNotifications();
  }

  void _toggleLocationAlerts(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.toggleLocationAlerts();
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Clear Profile Data',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'This will remove all your profile data and preferences. This action cannot be undone.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              Navigator.of(context).pop();
              final notifier = ref.read(userPreferencesProvider.notifier);
              await notifier.clearPreferences();
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Profile data cleared'),
                    backgroundColor: AppColors.semanticWarning,
                  ),
                );
              }
            },
            child: const Text(
              'Clear Data',
              style: TextStyle(color: AppColors.semanticError),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://ufobeep.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Privacy Policy'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  Future<void> _openTermsOfService() async {
    final url = Uri.parse('https://ufobeep.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not open Terms of Service'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  void _handleAdminTap() {
    // Allow admin access in debug mode or for beta builds  
    if (!kDebugMode && !_appVersion.contains('beta')) return;
    
    setState(() {
      _adminTapCount++;
    });
    
    // Reset count after 3 seconds
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _adminTapCount = 0;
        });
      }
    });
    
    // Show admin access after 5 taps
    if (_adminTapCount >= 5) {
      setState(() {
        _showAdminAccess = true;
        _adminTapCount = 0;
      });
      
      // Show feedback
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('🛡️ Admin mode activated'),
          backgroundColor: AppColors.brandPrimary,
          duration: Duration(seconds: 2),
        ),
      );
    } else if (_adminTapCount >= 3) {
      // Give hint after 3 taps
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${5 - _adminTapCount} more taps...'),
          backgroundColor: AppColors.textSecondary,
          duration: const Duration(seconds: 1),
        ),
      );
    }
  }

  Widget _buildAdminAccess() {
    if (!_showAdminAccess) return const SizedBox.shrink();
    
    return Column(
      children: [
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.admin_panel_settings,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Admin Tools',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.brandPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    onPressed: () {
                      setState(() {
                        _showAdminAccess = false;
                      });
                    },
                    icon: const Icon(
                      Icons.close,
                      color: AppColors.textSecondary,
                      size: 18,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              
              // Admin Panel Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => const AdminScreen(),
                      ),
                    );
                  },
                  icon: const Icon(Icons.dashboard),
                  label: const Text('Open Admin Panel'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimary,
                    foregroundColor: AppColors.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              // Web Admin Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () async {
                    final url = Uri.parse('https://api.ufobeep.com/admin/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.web),
                  label: const Text('Web Admin Interface'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimaryLight,
                    foregroundColor: AppColors.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              const Text(
                '⚠️ Beta builds only. Admin tools for testing proximity alerts, push notifications, and system diagnostics.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}