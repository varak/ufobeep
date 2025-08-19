import 'package:flutter/material.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';

class AlertActionsSection extends StatelessWidget {
  const AlertActionsSection({
    super.key,
    required this.alert,
    this.onJoinChat,
    this.onAddPhotos,
    this.onReportToMufon,
    this.showAllActions = true,
  });

  final Alert alert;
  final VoidCallback? onJoinChat;
  final VoidCallback? onAddPhotos;
  final VoidCallback? onReportToMufon;
  final bool showAllActions;

  @override
  Widget build(BuildContext context) {
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
          const Row(
            children: [
              Icon(
                Icons.touch_app,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Actions',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Chat button (always primary action)
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: onJoinChat,
              icon: const Icon(Icons.chat, size: 18),
              label: const Text('Join Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                textStyle: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          
          if (showAllActions) ...[
            const SizedBox(height: 12),
            
            // Add Photos button (secondary action)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onAddPhotos,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Add Photos & Videos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Report to MUFON button (tertiary action)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: onReportToMufon,
                icon: const Icon(Icons.report_outlined, size: 18),
                label: const Text('Report to MUFON'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.textSecondary,
                  side: const BorderSide(color: AppColors.textSecondary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}