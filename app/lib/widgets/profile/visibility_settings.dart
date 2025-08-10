import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_preferences.dart';
import '../../models/alert_enrichment.dart';
import '../../services/visibility_service.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';

class VisibilitySettings extends ConsumerWidget {
  final UserPreferences preferences;
  final ValueChanged<UserPreferences> onPreferencesChanged;
  final bool enabled;
  final WeatherData? currentWeather;

  const VisibilitySettings({
    super.key,
    required this.preferences,
    required this.onPreferencesChanged,
    this.enabled = true,
    this.currentWeather,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final visibilityService = VisibilityService();
    final impact = visibilityService.calculateVisibilityImpact(
      preferences: preferences,
      weather: currentWeather,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Visibility Settings',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              // Current visibility status
              _buildVisibilityStatus(impact),
              
              const SizedBox(height: 16),
              
              // Weather visibility toggle
              _buildWeatherVisibilityToggle(),
              
              const SizedBox(height: 12),
              
              // Visibility filters toggle
              _buildVisibilityFiltersToggle(),
              
              if (currentWeather != null) ...[
                const SizedBox(height: 16),
                _buildCurrentConditions(),
              ],
              
              const SizedBox(height: 16),
              _buildVisibilityAdvice(impact),
            ],
          ),
        ),
        
        const SizedBox(height: 8),
        Text(
          'Visibility settings affect which alerts you see based on weather conditions and your profile range.',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityStatus(VisibilityImpact impact) {
    final status = VisibilityService().getVisibilityStatus(
      preferences: preferences,
      weather: currentWeather,
    );
    
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

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: statusColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: statusColor.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${impact.category.emoji} ${impact.category.displayName} Visibility',
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Effective range: ${impact.effectiveRangeFormatted}',
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          if (impact.isReduced)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.semanticWarning.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
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
    );
  }

  Widget _buildWeatherVisibilityToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Use Weather Data',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Apply weather visibility to alert range calculations',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: preferences.useWeatherVisibility,
          onChanged: enabled ? (value) {
            final updated = preferences.copyWith(
              useWeatherVisibility: value,
            );
            onPreferencesChanged(updated);
          } : null,
          activeColor: AppColors.brandPrimary,
        ),
      ],
    );
  }

  Widget _buildVisibilityFiltersToggle() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Visibility Filters',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Hide distant alerts in poor visibility conditions',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
        Switch(
          value: preferences.enableVisibilityFilters,
          onChanged: enabled ? (value) {
            final updated = preferences.copyWith(
              enableVisibilityFilters: value,
            );
            onPreferencesChanged(updated);
          } : null,
          activeColor: AppColors.brandPrimary,
        ),
      ],
    );
  }

  Widget _buildCurrentConditions() {
    if (currentWeather == null) return const SizedBox.shrink();
    
    final weather = currentWeather!;
    final category = VisibilityService().getVisibilityCategory(weather.visibility);
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Current Weather',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                category.emoji,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherItem('Visibility', weather.visibilityFormatted),
              _buildWeatherItem('Condition', weather.condition),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildWeatherItem('Wind', weather.windFormatted),
              _buildWeatherItem('Clouds', weather.cloudCoverageFormatted),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildWeatherItem(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildVisibilityAdvice(VisibilityImpact impact) {
    final recommendations = VisibilityService().getVisibilityRecommendations(
      preferences: preferences,
      weather: currentWeather,
    );

    if (recommendations.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.lightbulb_outline,
                color: AppColors.brandPrimary,
                size: 16,
              ),
              const SizedBox(width: 8),
              const Text(
                'Visibility Tips',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ...recommendations.map((rec) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Text(
              '• $rec',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          )),
        ],
      ),
    );
  }
}