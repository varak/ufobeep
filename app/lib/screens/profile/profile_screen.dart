import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../services/auth_repository.dart';
import '../../models/user_model.dart';
import '../../theme/app_theme.dart';

/// ChatGPT: Minimal, unified Profile using ONLY AuthRepository.
/// Removed "Account Security" block entirely to avoid parallel sources.
/// Future: add "Add Phone" CTA when Phone Auth exists.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late final AuthRepository _auth;

  @override
  void initState() {
    super.initState();
    _auth = AuthRepository();
    _auth.addListener(_onAuthChange);
  }

  @override
  void dispose() {
    _auth.removeListener(_onAuthChange);
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
    return Scaffold(
            backgroundColor: AppColors.darkBackground,
            appBar: AppBar(
              title: const Text('Profile'),
              backgroundColor: AppColors.darkSurface,
            ),
            body: Padding(
              padding: const EdgeInsets.all(16),
              child: user == null
                  ? _LoggedOutCard(onLoginPressed: () {
                      // ChatGPT: Navigate to sign-in screen
                      context.go('/sign-in');
                    })
                  : _ProfileDetails(
                      user: user,
                      onLogout: () => _auth.logout(),
                      onAddPhone: () {
                        // ChatGPT: Future enhancement — SMS phone verification screen
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Phone linking coming soon.')),
                        );
                      },
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

class _ProfileDetails extends StatelessWidget {
  final UserModel user;
  final VoidCallback onLogout;
  final VoidCallback onAddPhone;

  const _ProfileDetails({required this.user, required this.onLogout, required this.onAddPhone});

  @override
  Widget build(BuildContext context) {
    return ListView(
      children: [
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.darkBorder.withOpacity(0.5)),
          ),
          child: Column(
            children: [
              ListTile(
                leading: const Icon(Icons.badge, color: AppColors.brandPrimary),
                title: Text(user.username ?? '(no username)', style: const TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('UFO ID', style: TextStyle(color: AppColors.textSecondary)),
              ),
              const Divider(color: AppColors.darkBorder),
              ListTile(
                leading: const Icon(Icons.email, color: AppColors.brandPrimary),
                title: Text(user.email ?? '(no email)', style: const TextStyle(color: AppColors.textPrimary)),
                subtitle: const Text('Email', style: TextStyle(color: AppColors.textSecondary)),
              ),
              if ((user.phone ?? '').isNotEmpty) ...[
                const Divider(color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.phone, color: AppColors.brandPrimary),
                  title: Text(user.phone!, style: const TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Phone', style: TextStyle(color: AppColors.textSecondary)),
                ),
              ] else ...[
                const Divider(color: AppColors.darkBorder),
                ListTile(
                  leading: const Icon(Icons.phone_iphone, color: AppColors.textSecondary),
                  title: const Text('Add Phone Number', style: TextStyle(color: AppColors.textPrimary)),
                  subtitle: const Text('Verify via SMS (optional)', style: TextStyle(color: AppColors.textSecondary)),
                  trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
                  onTap: onAddPhone,
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton.icon(
          onPressed: onLogout,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.semanticError,
            foregroundColor: Colors.white,
          ),
          icon: const Icon(Icons.logout),
          label: const Text('Sign Out'),
        ),
      ],
    );
  }
}