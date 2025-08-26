import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class SkyFiInfoDialog extends StatelessWidget {
  const SkyFiInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: Row(
        children: [
          Icon(Icons.satellite_alt, color: const Color(0xFF6B46C1)),
          const SizedBox(width: 8),
          const Text('SkyFi Satellite Imagery'),
        ],
      ),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'About SkyFi',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'SkyFi provides on-demand, ultra-high resolution satellite imagery from a constellation of commercial satellites.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Technical Capabilities',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '• 10cm to 50cm resolution\n'
              '• Optical, SAR, and multispectral sensors\n'
              '• Blue, green, red, and near-infrared bands\n'
              '• Global coverage with daily passes\n'
              '• Multiple sensor types available',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            
            const Text(
              'Premium Feature',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'UFOBeep will offer SkyFi satellite imagery as a premium feature, allowing users to purchase high-resolution images of their sighting locations.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Pricing available upon request',
              style: TextStyle(
                color: Color(0xFF6B46C1),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6B46C1).withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: const Color(0xFF6B46C1),
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text(
                      'Coming Soon! This feature is in development.',
                      style: TextStyle(
                        color: Color(0xFF6B46C1),
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
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Got it',
            style: TextStyle(
              color: Color(0xFF6B46C1),
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

}