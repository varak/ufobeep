import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/auth_repository.dart';
import '../../models/user_model.dart';
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
  late final AuthRepository _auth;
  final _scrollController = ScrollController();
  bool _showAdminAccess = false;
  int _adminTapCount = 0;
  String _appVersion = '0.1.0';

  @override
  void initState() {
    super.initState();
    _auth = AuthRepository();
    _auth.addListener(_onAuthChange);
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
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: const Text('Profile'),
          backgroundColor: AppColors.darkSurface,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16),
          child: _LoggedOutCard(onLoginPressed: () {
            context.go('/sign-in');
          }),
        ),
      );
    }

    // User is authenticated, try to load preferences
    final userPreferences = ref.watch(userPreferencesProvider);
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('Profile'),
        centerTitle: true,
        backgroundColor: AppColors.darkSurface,
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
            ],
            
            // Permissions Management
            _buildPermissionsSection(),
            
            const SizedBox(height: 32),
            
            // Hidden Admin Access (debug builds and beta versions)
            if (kDebugMode || _appVersion.contains('beta')) _buildAdminAccess(),
            
            // Logout Button
            _buildLogoutButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileHeader(UserModel user) {
    final username = user.username!; // Always present - auto-generated or user-set
    final email = user.email; // Might be null for SMS-only users
    
    return Container(
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
          Text(
            username,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
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
              'v$_appVersion',
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
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'Basic Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: const Text(
            'Alert range, language, units settings - Coming soon',
            style: TextStyle(color: AppColors.textPrimary),
          ),
        ),
      ],
    );
  }
  
  Widget _buildAppSettings(UserPreferences preferences) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4),
          child: Text(
            'App Settings',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: const Text(
            'Quiet hours, DND, alert filters - Coming soon',
            style: TextStyle(color: AppColors.textPrimary),
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
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text(
                'Permissions',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
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
      Permission.storage,
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
        _getPermissionName(permission),
        style: const TextStyle(color: AppColors.textPrimary),
      ),
      subtitle: Text(
        isGranted ? 'Granted' : 'Not granted',
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
            child: const Text('Grant'),
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
      case Permission.storage:
        return Icons.storage;
      default:
        return Icons.security;
    }
  }
  
  String _getPermissionName(Permission permission) {
    switch (permission) {
      case Permission.location:
      case Permission.locationAlways:
      case Permission.locationWhenInUse:
        return 'Location';
      case Permission.camera:
        return 'Camera';
      case Permission.notification:
        return 'Notifications';
      case Permission.storage:
        return 'Storage';
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
        label: const Text(
          'Sign Out',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
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