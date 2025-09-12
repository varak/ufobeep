import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../glass_card.dart';
import '../../l10n/app_localizations.dart';
import '../dialogs/blacksky_info_dialog.dart';
import '../dialogs/skyfi_info_dialog.dart';

class PremiumSatelliteCard extends StatelessWidget {
  const PremiumSatelliteCard({
    super.key, 
    required this.blackskyData,
    required this.skyfiData,
  });
  
  final Map<String, dynamic>? blackskyData;
  final Map<String, dynamic>? skyfiData;

  @override
  Widget build(BuildContext context) {
    // Don't show if neither service has data
    if (blackskyData == null && skyfiData == null) {
      return const SizedBox.shrink();
    }

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
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
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumImageryTitle,
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppColors.textPrimary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      Builder(
                        builder: (context) => Text(
                          AppLocalizations.of(context)!.premiumImagerySubtitle,
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // BlackSky option
            if (blackskyData != null) ...[
              _buildSatelliteOption(
                context,
                'BlackSky',
                '35cm Resolution',
                'Coming Soon',
                AppColors.brandPrimary,
                () => _showBlackSkyInfo(context),
              ),
              const SizedBox(height: 12),
            ],
            
            // SkyFi option  
            if (skyfiData != null) ...[
              _buildSatelliteOption(
                context,
                'SkyFi',
                '10-50cm Resolution',
                'Coming Soon',
                AppColors.brandPrimary,
                () => _showSkyFiInfo(context),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSatelliteOption(
    BuildContext context,
    String name,
    String resolution,
    String status,
    Color color,
    VoidCallback onTap,
  ) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.brandPrimary),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(6),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(4),
            child: Row(
              children: [
                Icon(
                  Icons.circle,
                  size: 8,
                  color: AppColors.brandPrimary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '$name - $resolution',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        status,
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 10,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.info_outline,
                  size: 12,
                  color: AppColors.brandPrimary,
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

  void _showSkyFiInfo(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) => const SkyFiInfoDialog(),
    );
  }
}
