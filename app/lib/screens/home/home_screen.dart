import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:latlong2/latlong.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../models/alerts_filter.dart';
import '../../widgets/alerts_filter_dialog.dart';
import '../../widgets/alert_card.dart';
import '../../widgets/map_widget.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filteredAlertsAsync = ref.watch(filteredAlertsProvider);
    final filter = ref.watch(alertsFilterStateProvider);
    final isLoading = ref.watch(alertsLoadingStateProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: _buildAppBar(context, ref, filter),
      body: RefreshIndicator(
        onRefresh: () => ref.read(alertsLoadingStateProvider.notifier).refresh(),
        backgroundColor: AppColors.darkSurface,
        color: AppColors.brandPrimary,
        child: _buildAsyncBody(context, ref, filteredAlertsAsync, isLoading, filter),
      ),
      floatingActionButton: _buildFAB(context),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
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
            'UFOBeep',
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
        // Sort button
        PopupMenuButton<AlertSortBy>(
          icon: Icon(
            Icons.sort,
            color: filter.sortBy != AlertSortBy.newest 
                ? AppColors.brandPrimary 
                : AppColors.textSecondary,
          ),
          color: AppColors.darkSurface,
          onSelected: (sortBy) {
            ref.read(alertsFilterStateProvider.notifier).setSorting(sortBy);
          },
          itemBuilder: (context) => AlertSortBy.values.map((sortBy) {
            return PopupMenuItem(
              value: sortBy,
              child: Row(
                children: [
                  if (filter.sortBy == sortBy)
                    const Icon(
                      Icons.check,
                      color: AppColors.brandPrimary,
                      size: 16,
                    )
                  else
                    const SizedBox(width: 16),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      sortBy.displayName,
                      style: TextStyle(
                        color: filter.sortBy == sortBy 
                            ? AppColors.brandPrimary 
                            : AppColors.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
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

  Widget _buildAsyncBody(
    BuildContext context, 
    WidgetRef ref, 
    AsyncValue<List<Alert>> alertsAsync, 
    bool isLoading, 
    AlertsFilter filter
  ) {
    return alertsAsync.when(
      data: (alerts) => _buildBody(context, ref, alerts, isLoading, filter),
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

  Widget _buildBody(
    BuildContext context, 
    WidgetRef ref, 
    List<Alert> alerts, 
    bool isLoading, 
    AlertsFilter filter
  ) {
    if (isLoading && alerts.isEmpty) {
      return const Center(
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
      );
    }

    if (alerts.isEmpty) {
      return _EmptyAlertsView(hasFilters: filter.hasActiveFilters);
    }

    return Column(
      children: [
        // Results header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                '${alerts.length} alert${alerts.length != 1 ? 's' : ''} found',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              if (isLoading)
                const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AppColors.brandPrimary,
                  ),
                ),
            ],
          ),
        ),
        
        // Map view
        Expanded(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 100), // Bottom padding for FAB
            child: Column(
              children: [
                // Map widget
                Expanded(
                  flex: 2,
                  child: MapWidget(
                    alerts: alerts,
                    showControls: true,
                    onAlertTap: (alert) {
                      context.go('/alert/${alert.id}');
                    },
                  ),
                ),
                
                const SizedBox(height: 16),
                
                // Recent alerts list (compact)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Recent Alerts',
                        style: TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child: ListView.builder(
                          itemCount: alerts.length,
                          itemBuilder: (context, index) {
                            final alert = alerts[index];
                            return AlertCard(alert: alert);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFAB(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 32),
      child: FloatingActionButton.extended(
        onPressed: () => context.go('/beep'),
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.black,
        elevation: 4,
        icon: const Icon(Icons.camera_alt, size: 24),
        label: const Text(
          'Report Sighting - Send a Beep!',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
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
              hasFilters ? 'No matching alerts' : 'No alerts nearby',
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
                  : 'Be the first to report a sighting in your area',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 16,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
            ),
            
            const SizedBox(height: 32),
            
            if (!hasFilters)
              OutlinedButton.icon(
                onPressed: () => context.go('/beep'),
                icon: const Icon(Icons.camera_alt),
                label: const Text('Report Sighting - Send a Beep!'),
                style: OutlinedButton.styleFrom(
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