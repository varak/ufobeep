import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../dialogs/blacksky_info_dialog.dart';

class BlackSkyCard extends StatelessWidget {
  const BlackSkyCard({super.key, required this.blackskyData});
  
  final Map<String, dynamic> blackskyData;

  @override
  Widget build(BuildContext context) {
    final pricing = blackskyData['pricing'] ?? {};
    final estimatedCost = pricing['estimated_cost_usd'] ?? '\$50-100';
    
    return Card(
      color: AppColors.darkSurface,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _showBlackSkyInfo(context),
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
                
                // BlackSky info box (green box)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppColors.brandPrimary,
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
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'BlackSky 35cm Resolution',
                              style: TextStyle(
                                color: AppColors.brandPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              '$estimatedCost • Coming Soon',
                              style: TextStyle(
                                color: AppColors.brandPrimary,
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

  void _showBlackSkyInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const BlackSkyInfoDialog(),
    );
  }
}