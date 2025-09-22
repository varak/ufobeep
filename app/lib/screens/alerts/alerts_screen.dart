import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/alerts_provider.dart';
import '../../providers/user_preferences_provider.dart';
import '../../models/alerts_filter.dart';
import '../../models/user_preferences.dart';
import '../../models/alert_enrichment.dart';
import '../../services/visibility_service.dart';
import '../../widgets/simplified_filter_dialog.dart';
import '../../l10n/app_localizations.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/alerts/visibility_indicator.dart';
import '../../widgets/glass_card.dart';
import '../../theme/app_theme.dart';

class AlertsScreen extends ConsumerStatefulWidget {
  const AlertsScreen({super.key});

  @override
  ConsumerState<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends ConsumerState<AlertsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsListProvider);
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
    final l10n = AppLocalizations.of(context)!;
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n?.alertsTitle ?? 'Alerts',
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
        // Single filter button
        IconButton(
          icon: Icon(
            Icons.tune,
            color: filter.hasActiveFilters
                ? AppColors.brandPrimary
                : AppColors.textSecondary,
          ),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => const SimplifiedFilterDialog(),
            );
          },
          tooltip: 'Filters',
        ),
      ],
    );
  }

  Widget _buildBody(
    BuildContext context,
    WidgetRef ref,
    AsyncValue<AlertsListData> alertsAsync,
    AlertsFilter filter,
    UserPreferences? preferences,
  ) {
    // Get the raw alerts data to access pagination info
    final alertsDataAsync = ref.watch(alertsListProvider);
    
    return alertsAsync.when(
      data: (alertsData) => _buildAlertsList(context, ref, alertsData.alerts, filter, preferences, alertsData),
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.brandPrimary),
            const SizedBox(height: 16),
            Text(
              AppLocalizations.of(context)?.loading ?? 'Loading...',
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
                AppLocalizations.of(context)?.errorGeneric ?? 'An error occurred',
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
                child: Text(AppLocalizations.of(context)?.retry ?? 'Retry'),
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
        
        // Removed obsolete visibility indicator (10.0 km artifact)
        
        
        // Alerts list with page-based pagination
        Expanded(
          child: Column(
            children: [
              // Page indicators
              if (alertsData != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Page info
                      Text(
                        'Page ${alertsData.page} of ${alertsData.totalPages}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                      ),
                      // Navigation buttons
                      Row(
                        children: [
                          // Previous page
                          IconButton(
                            onPressed: alertsData.hasPrevPage
                                ? () => _goToPreviousPage(ref, alertsData.page)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: alertsData.hasPrevPage
                                ? AppColors.brandPrimary
                                : AppColors.textTertiary,
                          ),
                          // Next page
                          IconButton(
                            onPressed: alertsData.hasNextPage
                                ? () => _goToNextPage(ref, alertsData.page)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: alertsData.hasNextPage
                                ? AppColors.brandPrimary
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              // Alerts list for current page
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                  itemCount: visibleAlerts.length,
                  itemBuilder: (context, index) {
                    final alert = visibleAlerts[index];
                    return AlertCard(alert: alert);
                  },
                ),
              ),
              // Bottom navigation controls
              if (alertsData != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface.withOpacity(0.9),
                    border: Border(
                      top: BorderSide(color: AppColors.darkBorder),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Total count info
                      Text(
                        'Showing ${alertsData.alerts.length} of ${alertsData.total}',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      // Navigation buttons
                      Row(
                        children: [
                          // Previous page
                          IconButton(
                            onPressed: alertsData.hasPrevPage
                                ? () => _goToPreviousPage(ref, alertsData.page)
                                : null,
                            icon: const Icon(Icons.chevron_left),
                            color: alertsData.hasPrevPage
                                ? AppColors.brandPrimary
                                : AppColors.textTertiary,
                          ),
                          // Page indicator
                          Text(
                            '${alertsData.page}/${alertsData.totalPages}',
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          // Next page
                          IconButton(
                            onPressed: alertsData.hasNextPage
                                ? () => _goToNextPage(ref, alertsData.page)
                                : null,
                            icon: const Icon(Icons.chevron_right),
                            color: alertsData.hasNextPage
                                ? AppColors.brandPrimary
                                : AppColors.textTertiary,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  void _goToPreviousPage(WidgetRef ref, int currentPage) {
    if (currentPage > 1) {
      ref.read(alertsListProvider.notifier).loadPage(currentPage - 1);
      _scrollToTop();
    }
  }

  void _goToNextPage(WidgetRef ref, int currentPage) {
    ref.read(alertsListProvider.notifier).loadPage(currentPage + 1);
    _scrollToTop();
  }

  void _scrollToTop() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
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
              hasFilters ? AppLocalizations.of(context)?.noAlertsFound ?? 'No alerts found' : AppLocalizations.of(context)?.noAlerts ?? 'No alerts',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              hasFilters
                  ? AppLocalizations.of(context)?.alertsFilterHelp ?? 'Try adjusting your filters or check back later.'
                  : AppLocalizations.of(context)?.noAlerts ?? 'No alerts',
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
