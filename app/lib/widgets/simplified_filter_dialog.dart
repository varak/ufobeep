import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../models/alerts_filter.dart';
import '../providers/alerts_provider.dart';
import '../l10n/app_localizations.dart';

enum SourceFilter { both, ufobeepOnly, mufonOnly }
enum SortOption { newest, nearest }

class SimplifiedFilterDialog extends ConsumerStatefulWidget {
  const SimplifiedFilterDialog({super.key});

  @override
  ConsumerState<SimplifiedFilterDialog> createState() => _SimplifiedFilterDialogState();
}

class _SimplifiedFilterDialogState extends ConsumerState<SimplifiedFilterDialog> {
  // Simplified filter state
  SourceFilter _sourceFilter = SourceFilter.both;
  SortOption _sortOption = SortOption.newest;
  double _pushRadiusKm = 25.0;  // Default to 25km (exists in dropdown)
  bool _ufobeepAlertsEnabled = true;

  @override
  void initState() {
    super.initState();
    // Initialize from current filter state
    final currentFilter = ref.read(alertsFilterStateProvider);
    final userPrefs = ref.read(userPreferencesProvider);

    // Initialize source filter
    if (currentFilter.showUfoBeepOnly == true) {
      _sourceFilter = SourceFilter.ufobeepOnly;
    } else if (currentFilter.showUfoBeepOnly == false) {
      _sourceFilter = SourceFilter.mufonOnly;
    } else {
      _sourceFilter = SourceFilter.both;
    }

    // Initialize sort option
    _sortOption = currentFilter.sortBy == AlertSortBy.distance
        ? SortOption.nearest
        : SortOption.newest;

    // Read alert range from user preferences (not filter state)
    final currentRadius = userPrefs?.alertRangeKm ?? 25.0;
    final radiusOptions = [10.0, 25.0, 50.0, 100.0, 200.0];
    _pushRadiusKm = radiusOptions.contains(currentRadius) ? currentRadius : 25.0;
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 500),
        decoration: BoxDecoration(
          color: AppColors.nightSkyMiddle.withOpacity(0.95),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: AppColors.glassCardBorder, width: 1),
          boxShadow: const [
            BoxShadow(blurRadius: 18, offset: Offset(0, 6), color: Colors.black26),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                l10n.filterAlerts,
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Filter Content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  children: [
                    // SOURCE CARD
                    _buildSourceCard(l10n),
                    const SizedBox(height: 12),

                    // BROWSE CARD
                    _buildBrowseCard(l10n),
                    const SizedBox(height: 12),

                    // PUSH ALERTS CARD
                    _buildPushCard(l10n),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.nightSkyMiddle.withOpacity(0.6),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      child: Text(l10n.cancel),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilters,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.black,
                      ),
                      child: Text(l10n.applyFilters),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSourceCard(AppLocalizations l10n) {
    return _buildCard(
      title: l10n.sourceFilters,
      subtitle: l10n.sourceFiltersDescription,
      child: Column(
        children: [
          RadioListTile<SourceFilter>(
            title: Text(l10n.ufobeepAndMufon),
            value: SourceFilter.both,
            groupValue: _sourceFilter,
            onChanged: (value) => setState(() => _sourceFilter = value!),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<SourceFilter>(
            title: Text(l10n.ufobeepOnlySource),
            value: SourceFilter.ufobeepOnly,
            groupValue: _sourceFilter,
            onChanged: (value) => setState(() => _sourceFilter = value!),
            contentPadding: EdgeInsets.zero,
          ),
          RadioListTile<SourceFilter>(
            title: Text(l10n.mufonOnlySource),
            value: SourceFilter.mufonOnly,
            groupValue: _sourceFilter,
            onChanged: (value) => setState(() => _sourceFilter = value!),
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }

  Widget _buildBrowseCard(AppLocalizations l10n) {
    return _buildCard(
      title: l10n.browseFilters,
      subtitle: l10n.browseFiltersDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.sortBy, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          Row(
            children: [
              Expanded(
                child: RadioListTile<SortOption>(
                  title: Text(l10n.sortByNewest),
                  value: SortOption.newest,
                  groupValue: _sortOption,
                  onChanged: (value) => setState(() => _sortOption = value!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              Expanded(
                child: RadioListTile<SortOption>(
                  title: Text(l10n.sortByNearest),
                  value: SortOption.nearest,
                  groupValue: _sortOption,
                  onChanged: (value) => setState(() => _sortOption = value!),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPushCard(AppLocalizations l10n) {
    final radiusOptions = [10.0, 25.0, 50.0, 100.0, 200.0];

    return _buildCard(
      title: l10n.pushAlertsTitle,
      subtitle: l10n.pushAlertsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.alertRadius, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          DropdownButtonFormField<double>(
            value: _pushRadiusKm,
            decoration: InputDecoration(
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fillColor: AppColors.nightSkyMiddle.withOpacity(0.3),
              filled: true,
            ),
            dropdownColor: AppColors.darkSurface,
            style: const TextStyle(color: AppColors.textPrimary),
            items: radiusOptions.map((radius) => DropdownMenuItem(
              value: radius,
              child: Text('${radius.toInt()}km'),
            )).toList(),
            onChanged: (value) => setState(() => _pushRadiusKm = value!),
          ),
          const SizedBox(height: 12),

          // Removed confusing toggle - UFOBeep alerts should always be enabled
          // Users control the radius, not whether alerts are enabled

          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.info_outline, size: 16, color: AppColors.textTertiary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  l10n.mufonNoPushInfo,
                  style: const TextStyle(color: AppColors.textTertiary, fontSize: 12),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCard({required String title, required String subtitle, required Widget child}) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nightSkyMiddle.withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 4),
          Text(subtitle, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  void _applyFilters() {
    // Convert simplified state back to AlertsFilter
    bool? showUfoBeepOnly;
    if (_sourceFilter == SourceFilter.ufobeepOnly) {
      showUfoBeepOnly = true;
    } else if (_sourceFilter == SourceFilter.mufonOnly) {
      showUfoBeepOnly = false; // Show MUFON only
    } else {
      showUfoBeepOnly = null; // Show both
    }

    // Convert sort option to AlertSortBy
    final sortBy = _sortOption == SortOption.nearest
        ? AlertSortBy.distance
        : AlertSortBy.newest;

    final currentFilter = ref.read(alertsFilterStateProvider);
    final newFilter = currentFilter.copyWith(
      showUfoBeepOnly: showUfoBeepOnly,
      alertRangeKm: _pushRadiusKm,
      sortBy: sortBy,
      clearUfoBeepOnly: _sourceFilter == SourceFilter.both,
    );

    debugPrint('🔧 DIALOG: Applying filter - source=$_sourceFilter, sort=$_sortOption, radius=$_pushRadiusKm');
    debugPrint('🔧 DIALOG: New filter - showUfoBeepOnly=$showUfoBeepOnly, sortBy=$sortBy');

    ref.read(alertsFilterStateProvider.notifier).updateFilter(newFilter);

    // Also update user preferences to sync with backend device table
    final userPrefs = ref.read(userPreferencesProvider);
    if (userPrefs != null) {
      ref.read(userPreferencesProvider.notifier).updatePreferences(
        userPrefs.copyWith(alertRangeKm: _pushRadiusKm)
      );
    }

    // Force AlertsList provider to rebuild with new filter
    ref.invalidate(alertsListProvider);

    debugPrint('🔧 DIALOG: Filter applied, user preferences updated, and AlertsList invalidated');

    Navigator.of(context).pop();
  }
}