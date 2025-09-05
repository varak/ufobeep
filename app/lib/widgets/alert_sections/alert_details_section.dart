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
          
          // MUFON-specific metadata
          if (alert.source == 'mufon') ...[
            // MUFON case number
            if (alert.enrichment?['mufon_case_number'] != null)
              _buildDetailRow(
                Icons.numbers,
                'MUFON Case',
                '${alert.enrichment!['mufon_case_number']}',
              ),
            
            // Reported when (original sighting date)
            if (alert.enrichment?['reported_when'] != null)
              _buildDetailRow(
                Icons.event,
                'Sighting Date',
                alert.enrichment!['reported_when'],
              ),
            
            // Entered into database when
            if (alert.enrichment?['database_when'] != null)
              _buildDetailRow(
                Icons.storage,
                'Database Entry',
                alert.enrichment!['database_when'],
              ),
            
            // Location (always show for MUFON)
            if (showLocation) ...[
              _buildDetailRow(
                Icons.location_on,
                'Location',
                _getMufonLocationName(alert),
                subtitle: alert.latitude != 0.0 && alert.longitude != 0.0 
                    ? '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}'
                    : null,
              ),
              if (alert.distance != null)
                _buildDetailRow(
                  Icons.straighten,
                  'Distance',
                  '${alert.distance!.toStringAsFixed(1)} km away',
                ),
            ],
          ],
          
          // UFOBeep-specific metadata (non-MUFON)
          if (alert.source != 'mufon') ...[
            // Time info
            _buildDetailRow(
              Icons.access_time,
              'Time',
              _formatDateTime(alert.createdAt),
              subtitle: _formatFullDateTime(alert.createdAt),
            ),
            
            // Reporter info
            if (alert.reporterUsername != null) 
              _buildDetailRow(
                Icons.person,
                'Reported by',
                alert.reporterUsername!,
                subtitle: null,
              ),
            
            // Witness count (if more than 1)
            if (alert.witnessCount > 1)
              _buildWitnessRow(),
            
            // Location info (if enabled)
            if (showLocation) ...[
              _buildDetailRow(
                Icons.location_on,
                'Location',
                '${alert.locationName ?? 'Unknown Location'}',
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
        ],
      ),
    );
  }


  Widget _buildWitnessRow() {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.visibility, size: 20, color: AppColors.semanticSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Text(
                      'Witnesses: ',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.semanticSuccess.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.semanticSuccess,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${alert.witnessCount}',
                            style: const TextStyle(
                              color: AppColors.semanticSuccess,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  '${alert.witnessCount} people confirmed this sighting',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
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

  String _getMufonLocationName(Alert alert) {
    // For MUFON alerts, use the locationName field which contains the city, state format
    if (alert.locationName != null && alert.locationName!.isNotEmpty) {
      return alert.locationName!;
    }
    
    // Last resort fallback
    return 'Location Unknown';
  }
}