import 'package:flutter/material.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';

class AlertDetailsSection extends StatelessWidget {
  const AlertDetailsSection({
    super.key,
    required this.alert,
    this.showDescription = true,
    this.showLocation = true,
  });

  final Alert alert;
  final bool showDescription;
  final bool showLocation;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          const Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Details',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description (if available and enabled)
          if (showDescription && alert.description != null && alert.description!.isNotEmpty) ...[
            Text(
              alert.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // Time info
          _buildDetailRow(
            Icons.access_time,
            'Time',
            _formatDateTime(alert.createdAt),
            subtitle: _formatFullDateTime(alert.createdAt),
          ),
          
          // Location info (if enabled)
          if (showLocation) ...[
            _buildDetailRow(
              Icons.info_outline,
              'Location',
              '📍 ${alert.locationName ?? 'Unknown Location'}',
              subtitle: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
            ),
            if (alert.distance != null)
              _buildDetailRow(
                Icons.straighten,
                'Distance',
                '${alert.distance!.toStringAsFixed(1)} km away',
              ),
          ],
        ],
      ),
    );
  }


  Widget _buildDetailRow(IconData icon, String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '$label: ',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Expanded(
                      child: Text(
                        value,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    // Ensure both times are in the same timezone (local)
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

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

  String _formatFullDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Convert to local timezone first
    final localDateTime = dateTime.toLocal();
    
    final month = months[localDateTime.month - 1];
    final day = localDateTime.day;
    final year = localDateTime.year;
    final hour = localDateTime.hour == 0 ? 12 : (localDateTime.hour > 12 ? localDateTime.hour - 12 : localDateTime.hour);
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final amPm = localDateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year at $hour:$minute $amPm';
  }
}