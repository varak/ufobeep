import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../models/alerts_filter.dart';
import '../../models/user_preferences.dart';
import '../../models/alert_enrichment.dart';
import '../../services/visibility_service.dart';
import '../../widgets/alerts_filter_dialog.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/alerts/visibility_indicator.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsListProvider);
    final filter = ref.watch(alertsFilterStateProvider);
    final preferencesAsync = ref.watch(userPreferencesProvider);
    final preferences = preferencesAsync;

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(context, ref, filter),
      body: RefreshIndicator(
        onRefresh: () => ref.read(alertsListProvider.notifier).refresh(),
        backgroundColor: AppColors.darkSurface,
        color: AppColors.brandPrimary,
        child: _buildBody(context, ref, alertsAsync, filter, preferences),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, AlertsFilter filter) {
    return AppBar(
      backgroundColor: AppColors.darkSurface,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'All Alerts',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (filter.hasActiveFilters)
            Text(
              filter.filterSummary,
              style: const TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
        ],
      ),
      actions: [
        // Filter button
        IconButton(
          icon: Icon(
            Icons.filter_list,
            color: filter.hasActiveFilters 
                ? AppColors.brandPrimary 
                : AppColors.textSecondary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const AlertsFilterDialog(),
            );
          },
        ),
        
        // Clear filters button (if filters active)
        if (filter.hasActiveFilters)
          IconButton(
            icon: const Icon(
              Icons.clear,
              color: AppColors.semanticWarning,
            ),
            onPressed: () {
              ref.read(alertsFilterStateProvider.notifier).resetFilter();
            },
            tooltip: 'Clear filters',
          ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<List<Alert>> alertsAsync, 
    AlertsFilter filter,
    UserPreferences? preferences,
  ) {
    return alertsAsync.when(
      data: (alerts) => _buildAlertsList(context, ref, alerts, filter, preferences),
      loading: () => const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppColors.brandPrimary),
            SizedBox(height: 16),
            Text(
              'Loading alerts...',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              const Text(
                'Failed to load alerts',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () {
                  ref.invalidate(alertsListProvider);
                },
                child: const Text('Try Again'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAlertsList(
    BuildContext context, 
    WidgetRef ref,
    List<Alert> alerts, 
    AlertsFilter filter,
    UserPreferences? preferences,
  ) {
    if (alerts.isEmpty) {
      return _EmptyAlertsView(hasFilters: filter.hasActiveFilters);
    }

    // Apply visibility filtering if preferences available and enabled
    List<Alert> visibleAlerts = alerts;
    WeatherData? currentWeather; // TODO: Get from weather service
    
    if (preferences != null && preferences.enableVisibilityFilters) {
      final visibilityService = VisibilityService();
      final effectiveRange = visibilityService.calculateEffectiveRange(
        preferences: preferences,
        weather: currentWeather,
      );
      
      // Filter alerts by effective range
      visibleAlerts = alerts.where((alert) {
        final distance = alert.distance ?? 0.0;
        return distance <= effectiveRange;
      }).toList();
    }

    return Column(
      children: [
        // Visibility filter summary
        if (preferences != null && preferences.enableVisibilityFilters)
          VisibilityFilterSummary(
            preferences: preferences,
            weather: currentWeather,
            totalAlerts: alerts.length,
            filteredAlerts: visibleAlerts.length,
            onToggleFilters: () {
              // Toggle visibility filters
              final updatedPrefs = preferences.copyWith(
                enableVisibilityFilters: !preferences.enableVisibilityFilters,
              );
              ref.read(userPreferencesProvider.notifier).updatePreferences(updatedPrefs);
            },
          ),
        
        // Visibility status indicator
        if (preferences != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: VisibilityIndicator(
              preferences: preferences,
              weather: currentWeather,
              compact: true,
            ),
          ),
        
        // Results header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${visibleAlerts.length} alert${visibleAlerts.length != 1 ? 's' : ''} found',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              if (preferences != null && visibleAlerts.length < alerts.length) ...[
                const SizedBox(width: 8),
                Text(
                  '(${alerts.length - visibleAlerts.length} filtered)',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Alerts list
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: visibleAlerts.length,
            itemBuilder: (context, index) {
              final alert = visibleAlerts[index];
              return AlertCard(alert: alert);
            },
          ),
        ),
      ],
    );
  }
}

class _EmptyAlertsView extends StatelessWidget {
  const _EmptyAlertsView({this.hasFilters = false});

  final bool hasFilters;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.brandPrimary.withOpacity(0.1),
                    AppColors.brandPrimary.withOpacity(0.05),
                    Colors.transparent,
                  ],
                ),
              ),
              child: const Center(
                child: Text(
                  '👽',
                  style: TextStyle(fontSize: 48),
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              hasFilters ? 'No matching alerts' : 'No alerts available',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              hasFilters
                  ? 'Try adjusting your filters to see more results'
                  : 'No alerts have been reported yet',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}