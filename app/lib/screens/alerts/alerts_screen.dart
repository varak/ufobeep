import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../models/alerts_filter.dart';
import '../../models/user_preferences.dart';
import '../../models/alert_enrichment.dart';
import '../../services/visibility_service.dart';
import '../../widgets/alerts_filter_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/alerts/visibility_indicator.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(filteredAlertsProvider);
    final filter = ref.watch(alertsFilterStateProvider);
    final preferencesAsync = ref.watch(userPreferencesProvider);
    final preferences = preferencesAsync;

    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildAppBar(context, ref, filter),
        body: RefreshIndicator(
          onRefresh: () => ref.read(alertsListProvider.notifier).refresh(),
          backgroundColor: AppColors.darkSurface,
          color: AppColors.brandPrimary,
          child: _buildBody(context, ref, alertsAsync, filter, preferences),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar(BuildContext context, WidgetRef ref, AlertsFilter filter) {
    final l10n = AppLocalizations.of(context);
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.alertsTitle,
            style: TextStyle(
              color: Colors.white,
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
        // MUFON toggle
        PopupMenuButton<String>(
          icon: Icon(
            filter.showUfoBeepOnly == true ? Icons.visibility_off : Icons.visibility,
            color: filter.showUfoBeepOnly == true 
                ? AppColors.brandPrimary 
                : AppColors.textSecondary,
          ),
          tooltip: l10n.toggleMufonTooltip,
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'toggle',
              child: Row(
                children: [
                  Icon(
                    filter.showUfoBeepOnly == true ? Icons.visibility : Icons.visibility_off,
                    color: AppColors.textSecondary,
                    size: 20,
                  ),
                  const SizedBox(width: 12),
                  Text(
                    filter.showUfoBeepOnly == true ? l10n.showMufonData : l10n.hideMufonData,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ],
              ),
            ),
            const PopupMenuDivider(),
            PopupMenuItem<String>(
              value: 'info',
              enabled: false,
              child: Text(
                filter.showUfoBeepOnly == true 
                    ? l10n.showingUfoBeepOnly
                    : l10n.showingAllReports,
                style: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ),
          ],
          onSelected: (value) {
            if (value == 'toggle') {
              final newFilter = filter.copyWith(
                showUfoBeepOnly: filter.showUfoBeepOnly != true ? true : null,
              );
              ref.read(alertsFilterStateProvider.notifier).updateFilter(newFilter);
            }
          },
        ),
        
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
    // Get the raw alerts data to access pagination info
    final alertsDataAsync = ref.watch(alertsListProvider);
    
    return alertsAsync.when(
      data: (alerts) => _buildAlertsList(context, ref, alerts, filter, preferences, alertsDataAsync.value),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context).loading,
              style: const TextStyle(
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
              Text(
                AppLocalizations.of(context).errorGeneric,
                style: const TextStyle(
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
                child: Text(AppLocalizations.of(context).retry),
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
    AlertsListData? alertsData,
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
                  '(${alerts.length - visibleAlerts.length} ${AppLocalizations.of(context).filteredSuffix})',
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 12,
                  ),
                ),
              ],
            ],
          ),
        ),
        
        // Alerts list with pagination
        Expanded(
          child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            itemCount: visibleAlerts.length + (alertsData?.hasMore == true ? 1 : 0), // +1 for load more button if has more
            itemBuilder: (context, index) {
              // Show load more button at the end
              if (index == visibleAlerts.length) {
                return _buildLoadMoreButton(context, ref, alertsData);
              }
              
              final alert = visibleAlerts[index];
              return AlertCard(alert: alert);
            },
          ),
        ),
      ],
    );
  }

  Widget _buildLoadMoreButton(
    BuildContext context, 
    WidgetRef ref,
    AlertsListData? alertsData,
  ) {
    if (alertsData == null || !alertsData.hasMore) {
      return const SizedBox.shrink();
    }
    
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: Column(
          children: [
            Text(
              'Showing ${alertsData.alerts.length} of ${alertsData.total} alerts',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
            const SizedBox(height: 8),
            ElevatedButton.icon(
              onPressed: () {
                ref.read(alertsListProvider.notifier).loadMore();
              },
              icon: const Icon(Icons.expand_more),
              label: Text(AppLocalizations.of(context).loadMoreAlerts),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.darkSurface,
                foregroundColor: AppColors.brandPrimary,
                side: const BorderSide(color: AppColors.brandPrimary),
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
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
              hasFilters ? AppLocalizations.of(context).noAlertsFound : AppLocalizations.of(context).noAlerts,
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              hasFilters
                  ? AppLocalizations.of(context).alertsFilterHelp
                  : AppLocalizations.of(context).noAlerts,
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
