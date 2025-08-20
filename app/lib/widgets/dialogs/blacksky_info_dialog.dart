import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class BlackSkyInfoDialog extends StatelessWidget {
  const BlackSkyInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: const Row(
        children: [
          Icon(Icons.satellite_alt, color: AppColors.brandPrimary),
          SizedBox(width: 8),
          Text('BlackSky Satellite Imagery'),
        ],
      ),
      content: const SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'About BlackSky',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'BlackSky operates a constellation of high-resolution imaging satellites that can capture detailed imagery of any location on Earth.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            
            Text(
              'Technical Capabilities',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              '• 35cm ground resolution\n'
              '• RGB optical imaging\n'
              '• Multiple daily revisits\n'
              '• 90-minute average delivery\n'
              '• Worldwide coverage',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 16),
            
            Text(
              'Premium Feature',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'UFOBeep will offer BlackSky satellite imagery as a premium feature, allowing users to purchase high-resolution images of their sighting locations.',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Estimated cost: \$50-100 per image',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 16),
            
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: AppColors.brandPrimary.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Coming Soon! This feature is in development.',
                      style: TextStyle(
                        color: AppColors.brandPrimary,
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
              color: AppColors.brandPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}