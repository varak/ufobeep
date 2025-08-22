import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../theme/app_theme.dart';

class SkyFiInfoDialog extends StatelessWidget {
  const SkyFiInfoDialog({super.key});

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.satellite_alt,
                    color: const Color(0xFF6B46C1),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'SkyFi Satellite Imagery',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Ultra-high resolution commercial imagery',
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: Icon(
                    Icons.close,
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // What is SkyFi
            _buildSection(
              '🛰️ What is SkyFi?',
              'SkyFi provides on-demand, ultra-high resolution satellite imagery from a constellation of commercial satellites. Perfect for verifying UFO sightings with detailed aerial context.',
            ),
            const SizedBox(height: 16),

            // Technical Specs
            _buildSection(
              '📊 Technical Specifications',
              '• 10cm to 50cm resolution options\n'
              '• Optical, SAR, and multispectral sensors\n'
              '• Blue, green, red, and near-infrared bands\n'
              '• Global coverage with daily satellite passes\n'
              '• Starting at \$25 for commercial imagery',
            ),
            const SizedBox(height: 16),

            // For UFO Research
            _buildSection(
              '🔬 Perfect for UFO Research',
              '• SAR imagery penetrates clouds and vegetation\n'
              '• Multi-spectral analysis reveals hidden details\n'
              '• Existing images delivered within 24 hours\n'
              '• New tasked images available in 48 hours\n'
              '• Multiple sensor types for comprehensive analysis\n'
              '• Verify environmental conditions at sighting time',
            ),
            const SizedBox(height: 24),

            // Coming Soon Notice
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFF6B46C1).withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFF6B46C1),
                  width: 1,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.schedule,
                        color: const Color(0xFF6B46C1),
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Coming Soon',
                        style: TextStyle(
                          color: const Color(0xFF6B46C1),
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'SkyFi integration is being developed. You\'ll be able to order high-resolution satellite imagery of your sighting location directly from UFOBeep.',
                    style: TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton(
                  onPressed: () => _launchSkyFiWebsite(),
                  child: Text(
                    'Learn More About SkyFi',
                    style: TextStyle(
                      color: const Color(0xFF6B46C1),
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => Navigator.of(context).pop(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B46C1),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Got it',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          content,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ],
    );
  }

  Future<void> _launchSkyFiWebsite() async {
    final Uri url = Uri.parse('https://skyfi.com');
    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    }
  }
}