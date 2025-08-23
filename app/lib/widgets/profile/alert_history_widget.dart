import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../theme/app_theme.dart';
import '../../services/api_client.dart';
import '../../services/device_service.dart';

class AlertHistoryWidget extends ConsumerWidget {
  const AlertHistoryWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return FutureBuilder<Map<String, dynamic>?>(
      future: _loadAlertHistory(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.brandPrimary),
          );
        }

        if (snapshot.hasError || !snapshot.hasData) {
          return _buildErrorState();
        }

        final historyData = snapshot.data!;
        final alerts = historyData['alerts'] as List<dynamic>? ?? [];
        
        if (alerts.isEmpty) {
          return _buildEmptyState();
        }

        return _buildHistoryContent(alerts, historyData['total_count'] ?? 0);
      },
    );
  }

  Future<Map<String, dynamic>?> _loadAlertHistory() async {
    try {
      final deviceService = DeviceService();
      final deviceId = await deviceService.getDeviceId();
      
      final apiClient = ApiClient.instance;
      final response = await apiClient.getJson('/users/alerts/$deviceId?per_page=10');
      
      if (response['success'] == true || response.containsKey('alerts')) {
        return response;
      }
      return null;
    } catch (e) {
      print('Error loading alert history: $e');
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
            Icons.history_outlined,
            color: AppColors.textTertiary,
            size: 32,
          ),
          SizedBox(height: 8),
          Text(
            'History not available',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.add_alert_outlined,
              color: AppColors.brandPrimary,
              size: 32,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'No alerts yet',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Create your first UFO alert to see it here',
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryContent(List<dynamic> alerts, int totalCount) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              children: [
                const Icon(
                  Icons.history_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Text(
                  'Your Alerts',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                if (totalCount > alerts.length)
                  Text(
                    'Showing ${alerts.length} of $totalCount',
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
          
          // Alert List
          Column(
            children: alerts.take(5).map((alert) => _buildAlertItem(context, alert)).toList(),
          ),
          
          // View All Button
          if (totalCount > 5)
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton(
                  onPressed: () {
                    // Navigate to full alert history screen
                    // TODO: Implement full history screen
                  },
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.brandPrimary,
                    side: BorderSide(color: AppColors.brandPrimary.withOpacity(0.5)),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: Text('View All $totalCount Alerts'),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAlertItem(BuildContext context, dynamic alert) {
    final mediaCount = alert['media_count'] ?? 0;
    final createdAt = DateTime.tryParse(alert['created_at'] ?? '');
    final timeAgo = createdAt != null ? _formatTimeAgo(createdAt) : 'Unknown';
    
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: InkWell(
        onTap: () => _navigateToAlert(context, alert['id']),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // UFO Icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🛸',
                  style: TextStyle(fontSize: 16),
                ),
              ),
              
              const SizedBox(width: 12),
              
              // Alert Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert['title'] ?? 'UFO Alert',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Text(
                          timeAgo,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        if (mediaCount > 0) ...[
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          Icon(
                            Icons.photo_camera,
                            color: AppColors.brandPrimary,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            mediaCount.toString(),
                            style: const TextStyle(
                              color: AppColors.brandPrimary,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                        if (alert['is_verified'] == true) ...[
                          const SizedBox(width: 8),
                          const Icon(
                            Icons.verified,
                            color: AppColors.brandPrimary,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToAlert(BuildContext context, String? alertId) {
    if (alertId != null) {
      // Use GoRouter to navigate to alert detail
      // Note: Assuming the route exists
      try {
        context.go('/alert/$alertId');
      } catch (e) {
        // Fallback navigation or error handling
        print('Navigation error: $e');
      }
    }
  }

  String _formatTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}