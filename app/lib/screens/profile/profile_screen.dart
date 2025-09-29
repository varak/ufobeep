import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/auth_repository.dart';
import '../../services/api_client.dart';
import '../../services/device_service.dart';
import '../../models/user_model.dart';
import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';
import '../../config/environment.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/profile/language_selector.dart';
import '../admin/admin_screen.dart';
import '../onboarding/onboarding_screen.dart';
import '../../l10n/app_localizations.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  late final AuthRepository _auth;
  final _scrollController = ScrollController();
  bool _showAdminAccess = false;
  int _adminTapCount = 0;
  String _appVersion = '0.1.0';
  String _buildNumber = '';

  @override
  void initState() {
    super.initState();
    _auth = AuthRepository();
    _auth.addListener(_onAuthChange);
    _loadAppVersion();
  }
  
  Future<void> _loadAppVersion() async {
    final version = await AppEnvironment.getAppVersion();
    final buildNumber = await AppEnvironment.getBuildNumber();
    if (mounted) {
      setState(() {
        _appVersion = version;
        _buildNumber = buildNumber;
      });
    }
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChange);
    _scrollController.dispose();
    super.dispose();
  }

  void _onAuthChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (!_auth.isReady) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    final UserModel? user = _auth.currentUser;
    
    if (user == null) {
      return NightSkyBackground(
        child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
            title: const Text('Profile', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Padding(
            padding: const EdgeInsets.all(16),
            child: _LoggedOutCard(onLoginPressed: () {
              context.go('/sign-in');
            }),
          ),
        ),
      );
    }

    // User is authenticated, try to load preferences
    final userPreferences = ref.watch(userPreferencesProvider);
    
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
          appBar: AppBar(
          title: Text(AppLocalizations.of(context)!.profile, style: const TextStyle(color: Colors.white)),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            _buildProfileHeader(user),
            
            const SizedBox(height: 24),
            
            // Basic Settings (if we have preferences)
            if (userPreferences != null) ...[
              _buildProfileSettings(userPreferences),
              const SizedBox(height: 24),
              _buildAppSettings(userPreferences),
              const SizedBox(height: 24),
              _buildPrivacySection(),
              const SizedBox(height: 24),
            ],

            // Permissions Management
            _buildPermissionsSection(),
            
            const SizedBox(height: 32),
            
            // Hidden Admin Access (debug builds and beta versions)
            if (kDebugMode || _appVersion.contains('beta')) _buildAdminAccess(),

            // View Onboarding Again Button
            _buildViewOnboardingButton(),

            const SizedBox(height: 16),

            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    ), // Close Scaffold
    ); // Close NightSkyBackground
  }

  Widget _buildProfileHeader(UserModel user) {
    final username = user.username!; // Always present - auto-generated or user-set
    final email = user.email; // Might be null for SMS-only users
    
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          // Simple avatar
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.brandPrimary.withOpacity(0.2),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.account_circle,
              color: AppColors.brandPrimary,
              size: 32,
            ),
          ),
          
          const SizedBox(height: 16),
          
          // Username and email for authenticated user
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                username,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => _regenerateUsername(user),
                icon: const Icon(Icons.refresh, size: 20),
                color: AppColors.brandPrimary,
                tooltip: AppLocalizations.of(context)!.generateUsername,
                constraints: const BoxConstraints(),
                padding: const EdgeInsets.all(4),
              ),
            ],
          ),
          const SizedBox(height: 4),
          if (email != null)
            Text(
              email,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: _handleAdminTap,
            child: Text(
              'v$_appVersion${_buildNumber.isNotEmpty ? ' (Build $_buildNumber)' : ''}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
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
            AppLocalizations.of(context)!.basicSettings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        GlassCard(
          child: Column(
            children: [
              // Removed Alert Range - now handled in filter dialog
              
              _buildSimpleSettingItem(
                icon: Icons.language_outlined,
                title: AppLocalizations.of(context)!.language,
                value: preferences.language.toUpperCase(),
                onTap: () => context.push('/profile/language'),
              ),
              
              _buildDivider(),
              
              _buildSimpleSettingItem(
                icon: Icons.straighten_outlined,
                title: AppLocalizations.of(context)!.units,
                value: preferences.units == 'metric'
                    ? AppLocalizations.of(context)!.unitsMetric
                    : AppLocalizations.of(context)!.unitsImperial,
                onTap: () => _toggleUnits(preferences),
              ),

              _buildDivider(),

              _buildSimpleSettingItem(
                icon: Icons.access_time_outlined,
                title: AppLocalizations.of(context)!.timeFormat,
                value: preferences.use24HourTime
                    ? AppLocalizations.of(context)!.timeFormat24Hour
                    : AppLocalizations.of(context)!.timeFormat12Hour,
                onTap: () => _toggleTimeFormat(preferences),
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
            AppLocalizations.of(context)!.appSettings,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),
        
        // App Settings
        GlassCard(
          child: Column(
            children: [
              _buildNavItemWithSubtitle(
                icon: Icons.notifications_outlined,
                title: AppLocalizations.of(context)!.notifications,
                subtitle: AppLocalizations.of(context)!.manageNotificationsDesc,
                onTap: () => context.push('/profile/notifications'),
                isFirst: true,
                isLast: true,
              ),
            ],
          ),
        ),
        
        // Removed Alert Filters section (covered in Notifications settings)
      ],
    );
  }

  Widget _buildPrivacySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            AppLocalizations.of(context)!.privacyData,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        const SizedBox(height: 16),

        GlassCard(
          child: Column(
            children: [
              _buildNavItemWithSubtitle(
                icon: Icons.shield_outlined,
                title: AppLocalizations.of(context)!.privacyPolicy,
                subtitle: AppLocalizations.of(context)!.privacyPolicyDesc,
                onTap: () => _openPrivacyPolicy(),
                isFirst: true,
              ),

              _buildDivider(),

              _buildNavItemWithSubtitle(
                icon: Icons.gavel_outlined,
                title: AppLocalizations.of(context)!.termsOfService,
                subtitle: AppLocalizations.of(context)!.termsOfServiceDesc,
                onTap: () => _openTermsOfService(),
              ),

              _buildDivider(),

              _buildNavItemWithSubtitle(
                icon: Icons.my_location_outlined,
                title: AppLocalizations.of(context)!.locationTracking,
                subtitle: AppLocalizations.of(context)!.locationTrackingDesc,
                onTap: () => context.push('/profile/location-tracking'),
              ),

              _buildDivider(),

              _buildNavItemWithSubtitle(
                icon: Icons.folder_delete_outlined,
                title: AppLocalizations.of(context)!.dataManagement,
                subtitle: AppLocalizations.of(context)!.dataManagementDesc,
                onTap: () => context.push('/profile/data-management'),
                isLast: true,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionsSection() {
    return FutureBuilder<List<Permission>>(
      future: _getAppPermissions(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        
        final permissions = snapshot.data!;
        
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                AppLocalizations.of(context)!.permissionsTitle,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            const SizedBox(height: 16),
            GlassCard(
              child: Column(
                children: permissions.map((permission) {
                  return FutureBuilder<PermissionStatus>(
                    future: permission.status,
                    builder: (context, statusSnapshot) {
                      if (!statusSnapshot.hasData) {
                        return const SizedBox.shrink();
                      }
                      return _buildPermissionTile(permission, statusSnapshot.data!);
                    },
                  );
                }).toList(),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<List<Permission>> _getAppPermissions() async {
    return [
      Permission.location,
      Permission.camera,
      Permission.notification,
      Permission.photos, // Modern replacement for deprecated storage permission
    ];
  }
  
  Widget _buildPermissionTile(Permission permission, PermissionStatus status) {
    final isGranted = status == PermissionStatus.granted;
    
    return ListTile(
      leading: Icon(
        _getPermissionIcon(permission),
        color: isGranted ? AppColors.brandPrimary : AppColors.textSecondary,
      ),
      title: Text(
        _getPermissionName(context, permission),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        isGranted 
          ? AppLocalizations.of(context)!.permissionGranted 
          : AppLocalizations.of(context)!.permissionNotGranted,
        style: TextStyle(
          color: isGranted ? AppColors.brandPrimary : AppColors.textSecondary,
        ),
      ),
      trailing: isGranted 
        ? const Icon(Icons.check, color: AppColors.brandPrimary)
        : TextButton(
            onPressed: () async {
              await permission.request();
              setState(() {}); // Refresh the UI
            },
            child: Text(AppLocalizations.of(context)!.permissionGrant),
          ),
    );
  }
  
  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return Icons.location_on;
      case Permission.camera:
        return Icons.camera_alt;
      case Permission.notification:
        return Icons.notifications;
      case Permission.photos:
        return Icons.photo_library;
      default:
        return Icons.security;
    }
  }
  
  String _getPermissionName(BuildContext context, Permission permission) {
    switch (permission) {
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return AppLocalizations.of(context)!.permissionLocation;
      case Permission.camera:
        return AppLocalizations.of(context)!.permissionCamera;
      case Permission.notification:
        return AppLocalizations.of(context)!.permissionNotifications;
      case Permission.photos:
        return AppLocalizations.of(context)!.permissionPhotos;
      default:
        return permission.toString().split('.').last;
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
        GlassCard(
          padding: const EdgeInsets.all(20),
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
                  Text(
                    AppLocalizations.of(context)!.adminTools,
                    style: const TextStyle(
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
                  label: Text(AppLocalizations.of(context)!.openAdminPanel),
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
                    final url = Uri.parse('https://ufobeep.com/api/admin/');
                    if (await canLaunchUrl(url)) {
                      await launchUrl(url, mode: LaunchMode.externalApplication);
                    }
                  },
                  icon: const Icon(Icons.web),
                  label: Text(AppLocalizations.of(context)!.webAdminInterface),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimaryLight,
                    foregroundColor: AppColors.darkBackground,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                  ),
                ),
              ),
              
              const SizedBox(height: 12),
              
              Text(
                AppLocalizations.of(context)!.adminBetaNotice,
                style: const TextStyle(
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

  Widget _buildViewOnboardingButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: OutlinedButton.icon(
        onPressed: () async {
          // Reset onboarding flag and navigate to onboarding
          await OnboardingService.resetOnboarding();
          if (mounted) {
            context.go('/onboarding');
          }
        },
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.help_outline, size: 20),
        label: Text(
          AppLocalizations.of(context)!.viewOnboardingAgain,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  Widget _buildLogoutButton() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: ElevatedButton.icon(
        onPressed: () => _auth.logout(),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.semanticError,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.logout, size: 20),
        label: Text(
          AppLocalizations.of(context)!.signOut,
          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
        ),
      ),
    );
  }

  // Helper methods for settings UI
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
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 16,
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
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
          ],
        ),
      ),
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
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(
              icon,
              color: AppColors.brandPrimary,
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
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
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

  // Navigation tile with subtitle below the title (no right-side value)
  Widget _buildNavItemWithSubtitle({
    required IconData icon,
    required String title,
    required String subtitle,
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
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.brandPrimary,
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
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            const Icon(
              Icons.chevron_right,
              color: AppColors.textSecondary,
              size: 20,
            ),
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

  // Alert Range setting removed - now handled in filter dialog

  void _showLanguageSelector(UserPreferences preferences) {
    showDialog(
      context: context,
      builder: (context) => LanguageSelectorDialog(
        selectedLanguage: preferences.language,
        onLanguageChanged: (newLanguage) {
          // Update language and sync to backend
          ref.read(userPreferencesProvider.notifier).updateLanguage(newLanguage);
        },
      ),
    );
  }

  void _toggleUnits(UserPreferences preferences) {
    final newUnits = preferences.units == 'metric' ? 'imperial' : 'metric';
    ref.read(userPreferencesProvider.notifier).updatePreferences(
      preferences.copyWith(units: newUnits),
    );
  }

  void _toggleTimeFormat(UserPreferences preferences) {
    final newTimeFormat = !preferences.use24HourTime;
    ref.read(userPreferencesProvider.notifier).updatePreferences(
      preferences.copyWith(use24HourTime: newTimeFormat),
    );
  }

  void _toggleQuietHours(bool enabled) {
    final preferences = ref.read(userPreferencesProvider);
    if (preferences != null) {
      ref.read(userPreferencesProvider.notifier).updatePreferences(
        preferences.copyWith(quietHoursEnabled: enabled),
      );
    }
  }

  Widget _buildQuietHoursTimePickers(UserPreferences preferences) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildTimePicker(
            'From',
            preferences.quietHoursStart,
            (hour) => _updateQuietHoursStart(preferences, hour),
          ),
          const SizedBox(height: 16),
          _buildTimePicker(
            'Until',
            preferences.quietHoursEnd,
            (hour) => _updateQuietHoursEnd(preferences, hour),
          ),
        ],
      ),
    );
  }

  Widget _buildTimePicker(String label, int hour, Function(int) onChanged) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _showTimePicker(hour, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                Text(
                  _formatHour(hour),
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _formatHour(int hour) {
    if (hour == 0) return '12:00 AM';
    if (hour < 12) return '${hour}:00 AM';
    if (hour == 12) return '12:00 PM';
    return '${hour - 12}:00 PM';
  }

  void _showTimePicker(int currentHour, Function(int) onChanged) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Select Time',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: SizedBox(
          width: double.maxFinite,
          height: 200,
          child: ListView.builder(
            itemCount: 24,
            itemBuilder: (context, index) {
              final hour = index;
              final isSelected = hour == currentHour;
              return ListTile(
                title: Text(
                  _formatHour(hour),
                  style: TextStyle(
                    color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
                onTap: () {
                  onChanged(hour);
                  Navigator.of(context).pop();
                },
                selected: isSelected,
                selectedTileColor: AppColors.brandPrimary.withOpacity(0.1),
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
        ],
      ),
    );
  }

  void _updateQuietHoursStart(UserPreferences preferences, int hour) {
    ref.read(userPreferencesProvider.notifier).updatePreferences(
      preferences.copyWith(quietHoursStart: hour),
    );
  }

  void _updateQuietHoursEnd(UserPreferences preferences, int hour) {
    ref.read(userPreferencesProvider.notifier).updatePreferences(
      preferences.copyWith(quietHoursEnd: hour),
    );
  }

  void _toggleMediaOnlyAlerts(bool enabled) {
    final preferences = ref.read(userPreferencesProvider);
    if (preferences != null) {
      ref.read(userPreferencesProvider.notifier).updatePreferences(
        preferences.copyWith(mediaOnlyAlerts: enabled),
      );
    }
  }

  Future<void> _openPrivacyPolicy() async {
    final url = Uri.parse('https://ufobeep.com/privacy');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _openTermsOfService() async {
    final url = Uri.parse('https://ufobeep.com/terms');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _regenerateUsername(UserModel user) async {
    final response = await ApiClient.dio.post('/users/generate-username');
    final data = response.data;
    final primary = data['username'] as String;
    final alternatives = List<String>.from(data['alternatives'] ?? []);
    _showUsernameSelectionDialog([primary, ...alternatives]);
  }

  void _showUsernameSelectionDialog(List<String> initialOptions) {
    final usernameOptions = List<String>.from(initialOptions);
    
    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Choose Your Username',
          style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Container(
          width: double.maxFinite,
          constraints: const BoxConstraints(maxHeight: 400),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Flexible(
                child: ListView.separated(
                  shrinkWrap: true,
                  itemCount: usernameOptions.length,
                  separatorBuilder: (context, index) => const SizedBox(height: 8),
                  itemBuilder: (context, index) {
                    final username = usernameOptions[index];
                    
                    return Material(
                      color: Colors.transparent,
                      child: InkWell(
                        borderRadius: BorderRadius.circular(12),
                        onTap: () async {
                          Navigator.of(context).pop();
                          
                          try {
                            debugPrint('🔄 Attempting to set username: $username');
                            await _auth.setUsername(username);
                            debugPrint('✅ Username set successfully: $username');
                            
                            // AuthRepository.notifyListeners() will trigger _onAuthChange automatically
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Username updated to: $username'),
                                  backgroundColor: AppColors.brandPrimary,
                                ),
                              );
                            }
                          } catch (e) {
                            debugPrint('❌ Username update failed: $e');
                            if (mounted) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to update username: $e'),
                                  backgroundColor: AppColors.semanticError,
                                ),
                              );
                            }
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkBorder.withOpacity(0.3),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.darkBorder.withOpacity(0.5),
                            ),
                          ),
                          child: Text(
                            username,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () async {
              // Don't close dialog - update list in place
              try {
                final response = await ApiClient.dio.post('/users/generate-username');
                final data = response.data;
                final primary = data['username'] as String;
                final alternatives = List<String>.from(data['alternatives'] ?? []);
                final newOptions = [primary, ...alternatives];
                
                // Update the dialog with new options
                setDialogState(() {
                  usernameOptions.clear();
                  usernameOptions.addAll(newOptions);
                });
              } catch (e) {
                debugPrint('Failed to get more names: $e');
              }
            },
            child: const Text(
              'More Names',
              style: TextStyle(color: AppColors.brandPrimary),
            ),
          ),
        ],
      ),
      ),
    );
  }




}

class _LoggedOutCard extends StatelessWidget {
  final VoidCallback onLoginPressed;
  const _LoggedOutCard({required this.onLoginPressed});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('You are not logged in.', style: TextStyle(color: AppColors.textPrimary)),
        const SizedBox(height: 12),
        ElevatedButton(
          onPressed: onLoginPressed, 
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.brandPrimary),
          child: const Text('Sign In'),
        ),
      ]),
    );
  }
}
