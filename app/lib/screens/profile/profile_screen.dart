import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';

import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../services/sound_service.dart';
import '../../services/permission_service.dart';
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
    
    // If user has no preferences at all, show registration prompt
    // But if they have preferences (even without display name), show the full profile
    if (userPreferences == null) {
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
            _buildProfileHeader(userPreferences!),
            
            const SizedBox(height: 32),
            
            // Profile Settings
            _buildProfileSettings(userPreferences!),
            
            const SizedBox(height: 24),
            
            // App Settings
            _buildAppSettings(userPreferences!),
            
            const SizedBox(height: 24),
            
            // Permissions Management
            _buildPermissionsSection(),
            
            const SizedBox(height: 32),
            
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
              onPressed: () => context.go('/alerts'),
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
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.brandPrimary.withOpacity(0.1),
            AppColors.brandPrimary.withOpacity(0.05),
            AppColors.darkSurface,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.brandPrimary.withOpacity(0.2),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandPrimary.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  AppColors.brandPrimary.withOpacity(0.3),
                  AppColors.brandPrimary.withOpacity(0.1),
                ],
              ),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandPrimary.withOpacity(0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: AppColors.brandPrimary,
              size: 36,
            ),
          ),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'UFOBeep User',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkBackground.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: AppColors.brandPrimary.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: 6,
                        height: 6,
                        decoration: const BoxDecoration(
                          color: AppColors.brandPrimary,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _handleAdminTap,
                        child: Text(
                          'v$_appVersion',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Basic Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildSimpleSettingItem(
                icon: Icons.notifications_outlined,
                title: 'Alert Range',
                value: preferences.alertRangeDisplay,
                onTap: () => _showRangeSelector(preferences),
                isFirst: true,
              ),
              
              _buildDivider(),
              
              _buildSimpleSettingItem(
                icon: Icons.language_outlined,
                title: 'Language',
                value: preferences.language.toUpperCase(),
                onTap: () => _showLanguageSelector(preferences),
              ),
              
              _buildDivider(),
              
              _buildSimpleSettingItem(
                icon: Icons.straighten_outlined,
                title: 'Units',
                value: preferences.units == 'metric' ? 'Metric' : 'Imperial',
                onTap: () => _toggleUnits(preferences),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildAppSettings(UserPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'App Settings',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // Quiet Hours Toggle
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: _buildSettingsTile(
            icon: Icons.bedtime_outlined,
            title: 'Quiet Hours',
            subtitle: 'Silence alerts during sleep hours',
            value: preferences.quietHoursEnabled,
            onChanged: _toggleQuietHours,
            standalone: true,
          ),
        ),
        
        const SizedBox(height: 20),
        
        // Do Not Disturb Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Do Not Disturb',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: _buildDndSection(preferences),
        ),
        
        const SizedBox(height: 20),
        
        // Alert Filters Section
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Alert Filters',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 12),
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              _buildSettingsTile(
                icon: Icons.photo_camera_outlined,
                title: 'Media-Only Alerts',
                subtitle: 'Only receive alerts with photos/videos',
                value: preferences.mediaOnlyAlerts ?? false,
                onChanged: _toggleMediaOnlyAlerts,
                isFirst: true,
              ),
              
              _buildDivider(),
              
              _buildSettingsTile(
                icon: Icons.verified_user_outlined,
                title: 'Verified Users Only',
                subtitle: 'Ignore alerts from anonymous users',
                value: preferences.ignoreAnonymousBeeps ?? false,
                onChanged: _toggleIgnoreAnonymousBeeps,
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    ValueChanged<bool>? onChanged,
    bool isFirst = false,
    bool isLast = false,
    bool standalone = false,
  }) {
    return Padding(
      padding: EdgeInsets.symmetric(
        vertical: standalone ? 16 : 12,
        horizontal: 20,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: value
                  ? AppColors.brandPrimary.withOpacity(0.2)
                  : AppColors.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: value 
                    ? AppColors.brandPrimary.withOpacity(0.3)
                    : AppColors.darkBorder.withOpacity(0.3),
                width: 1,
              ),
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
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Switch.adaptive(
            value: value,
            onChanged: onChanged,
            activeColor: AppColors.brandPrimary,
            activeTrackColor: AppColors.brandPrimary.withOpacity(0.3),
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.darkBorder,
          ),
        ],
      ),
    );
  }

  
  Widget _buildPermissionsSection() {
    final missingCriticalPermissions = !permissionService.locationGranted || !permissionService.notificationGranted;
    
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Row(
            children: [
              Text(
                'Permissions',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (missingCriticalPermissions)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.semanticError.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        size: 14,
                        color: AppColors.semanticError,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        'Action Required',
                        style: TextStyle(
                          color: AppColors.semanticError,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              // Location Permission (Critical)
              _buildPermissionItem(
                icon: Icons.location_on_outlined,
                title: 'Location Access',
                isGranted: permissionService.locationGranted,
                isCritical: true,
                isFirst: true,
                onTap: () => _handlePermissionTap('location'),
              ),
              
              _buildDivider(),
              
              // Notification Permission (Critical)
              _buildPermissionItem(
                icon: Icons.notifications_outlined,
                title: 'Push Notifications',
                isGranted: permissionService.notificationGranted,
                isCritical: true,
                onTap: () => _handlePermissionTap('notifications'),
              ),
              
              _buildDivider(),
              
              // Camera Permission (Optional)
              _buildPermissionItem(
                icon: Icons.camera_alt_outlined,
                title: 'Camera',
                isGranted: permissionService.cameraGranted,
                isCritical: false,
                onTap: () => _handlePermissionTap('camera'),
              ),
              
              _buildDivider(),
              
              // Photos Permission (Optional)
              _buildPermissionItem(
                icon: Icons.photo_library_outlined,
                title: 'Photo Library',
                isGranted: permissionService.photosGranted,
                isCritical: false,
                isLast: true,
                onTap: () => _handlePermissionTap('photos'),
              ),
            ],
          ),
        ),
        
        if (missingCriticalPermissions) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.semanticError.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.semanticError.withOpacity(0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.info_outline_rounded,
                  color: AppColors.semanticError,
                  size: 20,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Location and notifications are required for UFOBeep to work properly.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
        
        const SizedBox(height: 16),
        
        // Manage Permissions Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () async {
              await permissionService.openPermissionSettings();
            },
            icon: const Icon(Icons.settings_outlined, size: 18),
            label: const Text('Manage in Settings'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.brandPrimary,
              side: BorderSide(color: AppColors.brandPrimary.withOpacity(0.5)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required bool isGranted,
    required bool isCritical,
    required VoidCallback onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    final statusColor = isGranted
        ? AppColors.semanticSuccess
        : (isCritical ? AppColors.semanticError : AppColors.semanticWarning);
    
    return InkWell(
      onTap: isGranted ? null : onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: statusColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: statusColor,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.textPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 8),
                      if (isCritical)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.semanticError.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            'REQUIRED',
                            style: TextStyle(
                              color: AppColors.semanticError,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    isGranted 
                        ? 'Granted' 
                        : (isCritical ? 'Required for app functionality' : 'Optional'),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isGranted ? Icons.check_rounded : Icons.close_rounded,
                    color: statusColor,
                    size: 16,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    isGranted ? 'Allowed' : 'Denied',
                    style: TextStyle(
                      color: statusColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _handlePermissionTap(String permissionType) async {
    switch (permissionType) {
      case 'location':
        if (!permissionService.locationGranted) {
          final granted = await permissionService.requestPermission(Permission.location);
          if (!granted) {
            await permissionService.openPermissionSettings();
          }
        }
        break;
      case 'notifications':
        if (!permissionService.notificationGranted) {
          final granted = await permissionService.requestPermission(Permission.notification);
          if (!granted) {
            await permissionService.openPermissionSettings();
          }
        }
        break;
      case 'camera':
        if (!permissionService.cameraGranted) {
          final granted = await permissionService.requestCameraForCapture();
          if (!granted) {
            await permissionService.openPermissionSettings();
          }
        }
        break;
      case 'photos':
        if (!permissionService.photosGranted) {
          final granted = await permissionService.requestPhotosForGallery();
          if (!granted) {
            await permissionService.openPermissionSettings();
          }
        }
        break;
    }
    
    if (mounted) {
      setState(() {});
    }
  }

  Widget _buildSimpleSettingItem({
    required IconData icon,
    required String title,
    required String value,
    VoidCallback? onTap,
    bool isFirst = false,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.vertical(
        top: isFirst ? const Radius.circular(16) : Radius.zero,
        bottom: isLast ? const Radius.circular(16) : Radius.zero,
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.brandPrimary.withOpacity(0.2),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                color: AppColors.brandPrimary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (onTap != null) ...[
              const SizedBox(width: 12),
              Icon(
                Icons.chevron_right_rounded,
                color: AppColors.textTertiary,
                size: 20,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      height: 1,
      color: AppColors.darkBorder.withOpacity(0.3),
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



  void _toggleQuietHours(bool value) async {
    if (value) {
      // Show configuration dialog when enabling
      _showQuietHoursDialog();
    } else {
      // Just disable when turning off
      final currentPrefs = ref.read(userPreferencesProvider);
      if (currentPrefs != null) {
        final updatedPrefs = currentPrefs.copyWith(quietHoursEnabled: false);
        await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
      }
    }
  }

  void _showQuietHoursDialog() {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs == null) return;
    
    // Local state for dialog
    int startHour = currentPrefs.quietHoursStart;
    int endHour = currentPrefs.quietHoursEnd;
    bool allowOverride = currentPrefs.allowEmergencyOverride;
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: AppColors.darkSurface,
          title: const Text(
            'Quiet Hours',
            style: TextStyle(color: AppColors.textPrimary),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Set when to silence alerts during sleep hours.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 20),
              
              // Start time
              _buildTimePickerRow(
                'Start time:', 
                startHour, 
                (hour) => setDialogState(() => startHour = hour),
              ),
              
              const SizedBox(height: 16),
              
              // End time  
              _buildTimePickerRow(
                'End time:', 
                endHour, 
                (hour) => setDialogState(() => endHour = hour),
              ),
              
              const SizedBox(height: 20),
              
              // Emergency override checkbox
              Row(
                children: [
                  Checkbox(
                    value: allowOverride,
                    onChanged: (value) => setDialogState(() => allowOverride = value ?? true),
                    activeColor: AppColors.brandPrimary,
                    checkColor: AppColors.textInverse,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setDialogState(() => allowOverride = !allowOverride),
                      child: const Text(
                        'Allow emergency alerts to override (10+ witnesses)',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                // Save all settings to UserPreferences
                final updatedPrefs = currentPrefs.copyWith(
                  quietHoursEnabled: true,
                  quietHoursStart: startHour,
                  quietHoursEnd: endHour,
                  allowEmergencyOverride: allowOverride,
                );
                await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
              ),
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimePickerRow(String label, int currentHour, Function(int) onChanged) {
    return Row(
      children: [
        SizedBox(
          width: 80,
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Expanded(
          child: DropdownButton<int>(
            value: currentHour,
            isExpanded: true,
            dropdownColor: AppColors.darkSurface,
            style: const TextStyle(color: AppColors.textPrimary),
            items: List.generate(24, (index) {
              return DropdownMenuItem<int>(
                value: index,
                child: Text(
                  _formatHour(index),
                  style: const TextStyle(color: AppColors.textPrimary),
                ),
              );
            }),
            onChanged: (value) {
              if (value != null) {
                onChanged(value);
              }
            },
          ),
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '$hour:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  void _toggleMediaOnlyAlerts(bool value) async {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs != null) {
      final updatedPrefs = currentPrefs.copyWith(mediaOnlyAlerts: value);
      await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
    }
  }

  void _toggleIgnoreAnonymousBeeps(bool value) async {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs != null) {
      final updatedPrefs = currentPrefs.copyWith(ignoreAnonymousBeeps: value);
      await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
    }
  }

  Widget _buildDndSection(UserPreferences preferences) {
    final isDndActive = preferences.dndUntil != null && 
                        preferences.dndUntil!.isAfter(DateTime.now());
    
    if (isDndActive) {
      final remainingTime = preferences.dndUntil!.difference(DateTime.now());
      final hours = remainingTime.inHours;
      final minutes = remainingTime.inMinutes % 60;
      
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              Icons.do_not_disturb_on,
              color: AppColors.brandPrimary,
              size: 24,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Do Not Disturb Active',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    hours > 0 
                      ? 'Ends in $hours hour${hours > 1 ? "s" : ""} $minutes min'
                      : 'Ends in $minutes minute${minutes != 1 ? "s" : ""}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            TextButton(
              onPressed: () => _disableDnd(),
              child: const Text(
                'Turn Off',
                style: TextStyle(color: AppColors.semanticError),
              ),
            ),
          ],
        ),
      );
    }
    
    return Column(
      children: [
        const Text(
          'Snooze & silence all alerts temporarily',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildDndButton('1 hour', 1),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDndButton('8 hours', 8),
            ),
            const SizedBox(width: 8),
            Expanded(
              child: _buildDndButton('24 hours', 24),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDndButton(String label, int hours) {
    return ElevatedButton(
      onPressed: () => _enableDnd(hours),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 14),
      ),
    );
  }

  void _enableDnd(int hours) async {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs != null) {
      final dndUntil = DateTime.now().add(Duration(hours: hours));
      final updatedPrefs = currentPrefs.copyWith(dndUntil: dndUntil);
      await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Do Not Disturb enabled for $hours hour${hours > 1 ? "s" : ""}'),
            backgroundColor: AppColors.brandPrimary,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    }
  }

  void _disableDnd() async {
    final currentPrefs = ref.read(userPreferencesProvider);
    if (currentPrefs != null) {
      // Pass a special marker value that will be interpreted as null in copyWith
      final updatedPrefs = UserPreferences(
        displayName: currentPrefs.displayName,
        email: currentPrefs.email,
        language: currentPrefs.language,
        alertRangeKm: currentPrefs.alertRangeKm,
        enablePushNotifications: currentPrefs.enablePushNotifications,
        enableLocationAlerts: currentPrefs.enableLocationAlerts,
        enableArCompass: currentPrefs.enableArCompass,
        enablePilotMode: currentPrefs.enablePilotMode,
        alertCategories: currentPrefs.alertCategories,
        units: currentPrefs.units,
        darkMode: currentPrefs.darkMode,
        useWeatherVisibility: currentPrefs.useWeatherVisibility,
        enableVisibilityFilters: currentPrefs.enableVisibilityFilters,
        locationPrivacy: currentPrefs.locationPrivacy,
        mediaOnlyAlerts: currentPrefs.mediaOnlyAlerts,
        ignoreAnonymousBeeps: currentPrefs.ignoreAnonymousBeeps,
        quietHoursEnabled: currentPrefs.quietHoursEnabled,
        quietHoursStart: currentPrefs.quietHoursStart,
        quietHoursEnd: currentPrefs.quietHoursEnd,
        allowEmergencyOverride: currentPrefs.allowEmergencyOverride,
        dndUntil: null, // Clear DND
        lastUpdated: DateTime.now(),
      );
      await ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Do Not Disturb disabled'),
            backgroundColor: AppColors.textSecondary,
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
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