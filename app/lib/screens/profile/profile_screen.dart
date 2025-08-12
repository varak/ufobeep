import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../widgets/profile/language_selector.dart';
import '../../widgets/profile/range_selector.dart';
import '../../widgets/profile/visibility_settings.dart';
import '../../widgets/profile/location_privacy_selector.dart';
import '../../theme/app_theme.dart';
import '../../config/environment.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _scrollController = ScrollController();
  bool _isEditing = false;

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
        actions: [
          TextButton(
            onPressed: () => setState(() => _isEditing = !_isEditing),
            child: Text(
              _isEditing ? 'Done' : 'Edit',
              style: const TextStyle(color: AppColors.brandPrimary),
            ),
          ),
        ],
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
            const SizedBox(height: 40),
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
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: AppColors.brandPrimary.withOpacity(0.2),
            child: Text(
              _getInitials(preferences.displayName ?? 'U'),
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            preferences.displayName ?? 'Anonymous User',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          if (preferences.email?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              preferences.email!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
          const SizedBox(height: 16),
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildStatItem(
                    icon: Icons.notifications,
                    label: 'Range',
                    value: preferences.alertRangeDisplay,
                  ),
                  _buildStatItem(
                    icon: Icons.language,
                    label: 'Language',
                    value: preferences.language.toUpperCase(),
                  ),
                  _buildStatItem(
                    icon: Icons.straighten,
                    label: 'Units',
                    value: preferences.units == 'metric' ? 'Metric' : 'Imperial',
                  ),
                ],
              ),
              const SizedBox(height: 12),
              _buildStatItem(
                icon: Icons.info_outline,
                label: 'App Version',
                value: 'v${AppEnvironment.appVersion}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppColors.brandPrimary,
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
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
            'Preferences',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 20),
          
          // Language
          LanguageSelector(
            selectedLanguage: preferences.language,
            onLanguageChanged: _isEditing
                ? (language) => _updateLanguage(language)
                : (_) {},
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 24),
          
          // Alert Range
          RangeSelector(
            selectedRange: preferences.alertRangeKm,
            onRangeChanged: _isEditing
                ? (range) => _updateAlertRange(range)
                : (_) {},
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 24),
          
          // Units
          UnitsSelector(
            selectedUnits: preferences.units,
            onUnitsChanged: _isEditing
                ? (units) => _updateUnits(units)
                : (_) {},
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 24),
          
          // Location Privacy Settings
          LocationPrivacySelector(
            selectedPrivacy: preferences.locationPrivacy,
            onPrivacyChanged: _isEditing
                ? (privacy) => _updateLocationPrivacy(privacy)
                : (_) {},
            enabled: _isEditing,
          ),
          
          const SizedBox(height: 24),
          
          // Visibility Settings
          VisibilitySettings(
            preferences: preferences,
            onPreferencesChanged: _isEditing
                ? (updatedPrefs) => _updateVisibilitySettings(updatedPrefs)
                : (_) {},
            enabled: _isEditing,
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
            onChanged: _isEditing ? _togglePushNotifications : null,
          ),
          
          _buildSettingsTile(
            icon: Icons.location_on,
            title: 'Location Alerts',
            subtitle: 'Get notified based on your location',
            value: preferences.enableLocationAlerts,
            onChanged: _isEditing ? _toggleLocationAlerts : null,
          ),
          
          if (AppEnvironment.enableArCompass)
            _buildSettingsTile(
              icon: Icons.explore,
              title: 'AR Compass',
              subtitle: 'Augmented reality navigation',
              value: preferences.enableArCompass,
              onChanged: _isEditing ? _toggleArCompass : null,
            ),
          
          if (AppEnvironment.enablePilotMode)
            _buildSettingsTile(
              icon: Icons.flight,
              title: 'Pilot Mode',
              subtitle: 'Advanced aviation features',
              value: preferences.enablePilotMode,
              onChanged: _isEditing ? _togglePilotMode : null,
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
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          height: 48,
          child: OutlinedButton(
            onPressed: () {
              // TODO: Navigate to settings
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Settings coming soon!')),
              );
            },
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.darkBorder),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.settings, color: AppColors.textPrimary),
                SizedBox(width: 8),
                Text(
                  'App Settings',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          height: 48,
          child: TextButton(
            onPressed: () => _showLogoutDialog(),
            child: const Text(
              'Clear Profile Data',
              style: TextStyle(color: AppColors.semanticError),
            ),
          ),
        ),
      ],
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

  void _updateLocationPrivacy(LocationPrivacy privacy) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.updateLocationPrivacy(privacy);
  }

  void _updateVisibilitySettings(UserPreferences updatedPrefs) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.updatePreferences(updatedPrefs);
  }

  void _togglePushNotifications(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.togglePushNotifications();
  }

  void _toggleLocationAlerts(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.toggleLocationAlerts();
  }

  void _toggleArCompass(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.toggleArCompass();
  }

  void _togglePilotMode(bool value) async {
    final notifier = ref.read(userPreferencesProvider.notifier);
    await notifier.togglePilotMode();
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
}