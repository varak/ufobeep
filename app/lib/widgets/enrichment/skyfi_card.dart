import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../dialogs/skyfi_info_dialog.dart';

class SkyFiCard extends StatelessWidget {
  const SkyFiCard({super.key, required this.skyfiData});
  
  final Map<String, dynamic> skyfiData;

  @override
  Widget build(BuildContext context) {
    
    return Card(
      color: AppColors.darkSurface,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showSkyFiInfo(context),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  children: [
                    Icon(Icons.satellite_alt, color: AppColors.brandPrimary, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Premium Satellite Imagery',
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: AppColors.textPrimary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            'High-resolution imagery of this location',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // SkyFi info box (purple box)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF6B46C1).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: const Color(0xFF6B46C1),
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
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'SkyFi 10-50cm Resolution',
                              style: TextStyle(
                                color: const Color(0xFF6B46C1),
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Coming Soon',
                              style: TextStyle(
                                color: const Color(0xFF6B46C1),
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _showSkyFiInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SkyFiInfoDialog(),
    );
  }
}