import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_preferences.dart';
import '../../models/alert_enrichment.dart';
import '../../services/visibility_service.dart';
import '../../theme/app_theme.dart';

/// Widget that shows visibility status and impact on alert filtering
class VisibilityIndicator extends ConsumerWidget {
  final UserPreferences preferences;
  final WeatherData? weather;
  final bool compact;
  final VoidCallback? onTap;

  const VisibilityIndicator({
    super.key,
    required this.preferences,
    this.weather,
    this.compact = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityService = VisibilityService();
    final impact = visibilityService.calculateVisibilityImpact(
      preferences: preferences,
      weather: weather,
    );
    
    final status = visibilityService.getVisibilityStatus(
      preferences: preferences,
      weather: weather,
    );

    if (compact) {
      return _buildCompactIndicator(impact, status);
    } else {
      return _buildFullIndicator(impact, status);
    }
  }

  Widget _buildCompactIndicator(VisibilityImpact impact, VisibilityStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case VisibilityStatus.critical:
        statusColor = AppColors.semanticError;
        statusIcon = Icons.visibility_off;
        break;
      case VisibilityStatus.warning:
        statusColor = AppColors.semanticWarning;
        statusIcon = Icons.visibility_off;
        break;
      case VisibilityStatus.reduced:
        statusColor = AppColors.semanticInfo;
        statusIcon = Icons.visibility;
        break;
      case VisibilityStatus.good:
        statusColor = AppColors.semanticSuccess;
        statusIcon = Icons.visibility;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(statusIcon, color: statusColor, size: 14),
            const SizedBox(width: 4),
            Text(
              impact.effectiveRangeFormatted,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
            if (impact.isReduced) ...[
              const SizedBox(width: 4),
              Text(
                '↓${impact.reductionPercent.toStringAsFixed(0)}%',
                style: TextStyle(
                  color: statusColor,
                  fontSize: 10,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFullIndicator(VisibilityImpact impact, VisibilityStatus status) {
    Color statusColor;
    IconData statusIcon;
    
    switch (status) {
      case VisibilityStatus.critical:
        statusColor = AppColors.semanticError;
        statusIcon = Icons.warning;
        break;
      case VisibilityStatus.warning:
        statusColor = AppColors.semanticWarning;
        statusIcon = Icons.visibility_off;
        break;
      case VisibilityStatus.reduced:
        statusColor = AppColors.semanticInfo;
        statusIcon = Icons.visibility;
        break;
      case VisibilityStatus.good:
        statusColor = AppColors.semanticSuccess;
        statusIcon = Icons.visibility;
        break;
    }

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: statusColor.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(statusIcon, color: statusColor, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        impact.category.emoji,
                        style: const TextStyle(fontSize: 16),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '${impact.category.displayName} Visibility',
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Range: ${impact.profileRangeFormatted} → ${impact.effectiveRangeFormatted}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  if (weather != null)
                    Text(
                      'Weather visibility: ${impact.weatherVisibilityFormatted}',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 11,
                      ),
                    ),
                ],
              ),
            ),
            if (impact.isReduced)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.semanticWarning.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  impact.formattedReduction,
                  style: const TextStyle(
                    color: AppColors.semanticWarning,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Simple visibility badge for alert items
class VisibilityBadge extends StatelessWidget {
  final double distanceKm;
  final bool isVisible;
  final VisibilityCategory? category;

  const VisibilityBadge({
    super.key,
    required this.distanceKm,
    required this.isVisible,
    this.category,
  });

  @override
  Widget build(BuildContext context) {
    if (isVisible && category == null) {
      return const SizedBox.shrink(); // Don't show badge for normal visible alerts
    }

    Color badgeColor;
    IconData badgeIcon;
    String badgeText;

    if (!isVisible) {
      badgeColor = AppColors.textTertiary;
      badgeIcon = Icons.visibility_off;
      badgeText = 'Out of range';
    } else if (category != null) {
      switch (category!) {
        case VisibilityCategory.veryPoor:
          badgeColor = AppColors.semanticError;
          badgeIcon = Icons.fog;
          badgeText = 'Very poor visibility';
          break;
        case VisibilityCategory.poor:
          badgeColor = AppColors.semanticWarning;
          badgeIcon = Icons.cloud;
          badgeText = 'Poor visibility';
          break;
        case VisibilityCategory.fair:
          badgeColor = AppColors.semanticInfo;
          badgeIcon = Icons.visibility;
          badgeText = 'Fair visibility';
          break;
        case VisibilityCategory.good:
        case VisibilityCategory.excellent:
          return const SizedBox.shrink(); // Don't show for good conditions
      }
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(badgeIcon, color: badgeColor, size: 12),
          const SizedBox(width: 3),
          Text(
            badgeText,
            style: TextStyle(
              color: badgeColor,
              fontSize: 9,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Visibility filter summary widget for alerts list header
class VisibilityFilterSummary extends ConsumerWidget {
  final UserPreferences preferences;
  final WeatherData? weather;
  final int totalAlerts;
  final int filteredAlerts;
  final VoidCallback? onToggleFilters;

  const VisibilityFilterSummary({
    super.key,
    required this.preferences,
    this.weather,
    required this.totalAlerts,
    required this.filteredAlerts,
    this.onToggleFilters,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hiddenAlerts = totalAlerts - filteredAlerts;
    
    if (hiddenAlerts <= 0 || !preferences.enableVisibilityFilters) {
      return const SizedBox.shrink();
    }

    final visibilityService = VisibilityService();
    final impact = visibilityService.calculateVisibilityImpact(
      preferences: preferences,
      weather: weather,
    );

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.semanticInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.semanticInfo.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(
            Icons.filter_alt,
            color: AppColors.semanticInfo,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$hiddenAlerts alert${hiddenAlerts == 1 ? '' : 's'} filtered by visibility',
                  style: const TextStyle(
                    color: AppColors.semanticInfo,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${impact.category.displayName} conditions (${impact.effectiveRangeFormatted} range)',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (onToggleFilters != null)
            TextButton(
              onPressed: onToggleFilters,
              style: TextButton.styleFrom(
                minimumSize: Size.zero,
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              ),
              child: const Text(
                'Show All',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }
}