import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/device_service.dart';
import '../../providers/user_preferences_provider.dart';

class UsernameRegenerateWidget extends ConsumerStatefulWidget {
  const UsernameRegenerateWidget({super.key});

  @override
  ConsumerState<UsernameRegenerateWidget> createState() => _UsernameRegenerateWidgetState();
}

class _UsernameRegenerateWidgetState extends ConsumerState<UsernameRegenerateWidget> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.refresh_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Username',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          
          const Text(
            'Want a new cosmic identity? Generate a fresh username while keeping all your alerts and activity.',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 16),
          
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isLoading ? null : _regenerateUsername,
              icon: _isLoading 
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppColors.brandPrimary,
                    ),
                  )
                : const Icon(Icons.auto_awesome_outlined),
              label: Text(_isLoading ? 'Generating...' : 'Generate New Username'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.brandPrimary,
                side: BorderSide(color: AppColors.brandPrimary.withOpacity(0.5)),
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _regenerateUsername() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final deviceId = await DeviceService.getDeviceId();
      if (deviceId == null) {
        throw Exception('Device ID not found');
      }

      final apiClient = ApiClient.instance;
      final response = await apiClient.post('/users/regenerate-username', {
        'device_id': deviceId,
        'force_regenerate': true,
      });

      if (response['success'] == true || response['username'] != null) {
        final newUsername = response['username'];
        final message = response['message'] ?? 'Username updated successfully!';

        if (mounted) {
          // Show success message
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: AppColors.brandPrimary,
              duration: const Duration(seconds: 3),
            ),
          );

          // Show confirmation dialog with new username
          _showUsernameDialog(newUsername);
          
          // Refresh user preferences to update UI
          ref.read(userPreferencesProvider.notifier).refresh();
        }
      } else {
        throw Exception(response['message'] ?? 'Failed to generate username');
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 3),
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

  void _showUsernameDialog(String newUsername) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: const Row(
          children: [
            Icon(
              Icons.celebration_outlined,
              color: AppColors.brandPrimary,
              size: 24,
            ),
            SizedBox(width: 8),
            Text(
              'New Username!',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.brandPrimary.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Your new cosmic identity:',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    newUsername,
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'All your alerts and activity have been updated with your new username.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Perfect!',
              style: TextStyle(color: AppColors.brandPrimary),
            ),
          ),
        ],
      ),
    );
  }
}