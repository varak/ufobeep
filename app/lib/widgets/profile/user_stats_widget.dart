import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/device_service.dart';

class UserStatsWidget extends ConsumerWidget {
  const UserStatsWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadUserStats(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPrimary),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final stats = snapshot.data!;
        return _buildStatsContent(stats);
      },
    );
  }

  Future<Map<String, dynamic>?> _loadUserStats() async {
    try {
      final deviceId = await DeviceService.getDeviceId();
      if (deviceId == null) return null;
      
      final apiClient = ApiClient.instance;
      final response = await apiClient.get('/users/stats/$deviceId');
      
      if (response['success'] == true || response.containsKey('total_alerts_created')) {
        return response;
      }
      return null;
    } catch (e) {
      print('Error loading user stats: $e');
      return null;
    }
  }

  Widget _buildErrorState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.analytics_outlined,
            color: AppColors.textTertiary,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'Stats not available',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsContent(Map<String, dynamic> stats) {
    final recentActivity = stats['recent_activity'] ?? {};
    
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          const Row(
            children: [
              Icon(
                Icons.analytics_outlined,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Your Activity',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Stats Grid
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Alerts Created',
                  '${stats['total_alerts_created'] ?? 0}',
                  Icons.add_alert_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Witnesses',
                  '${stats['total_witnesses_confirmed'] ?? 0}',
                  Icons.visibility_outlined,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Media Shared',
                  '${stats['total_media_uploaded'] ?? 0}',
                  Icons.photo_camera_outlined,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: _buildStatItem(
                  'Account Age',
                  '${stats['account_age_days'] ?? 0} days',
                  Icons.calendar_today_outlined,
                ),
              ),
            ],
          ),
          
          // Recent Activity
          if (recentActivity.isNotEmpty) ...[
            const SizedBox(height: 20),
            const Divider(color: AppColors.darkBorder),
            const SizedBox(height: 16),
            const Text(
              'Recent Activity',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                Expanded(
                  child: _buildRecentActivityItem(
                    'Last 7 days',
                    '${recentActivity['alerts_last_7_days'] ?? 0} alerts',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildRecentActivityItem(
                    'Last 30 days',
                    '${recentActivity['alerts_last_30_days'] ?? 0} alerts',
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatItem(String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: AppColors.brandPrimary,
            size: 20,
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivityItem(String period, String value) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            period,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}