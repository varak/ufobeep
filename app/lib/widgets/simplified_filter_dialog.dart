import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../models/alerts_filter.dart';
import '../providers/alerts_provider.dart';
import '../providers/user_preferences_provider.dart';
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
  double _pushRadiusKm = 100.0;  // Default to 100km
  bool _ufobeepAlertsEnabled = true;

  // Text controller for custom range input
  final TextEditingController _rangeController = TextEditingController();
  String? _rangeError;

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

    // Read alert range from user preferences and populate text controller
    if (userPrefs?.alertRangeKm == null) {
      throw StateError('User preferences not loaded or alertRangeKm is null - this should not happen');
    }
    final currentRadius = userPrefs!.alertRangeKm;
    _pushRadiusKm = currentRadius;
    _rangeController.text = currentRadius.toInt().toString();
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
    return _buildCard(
      title: l10n.pushAlertsTitle,
      subtitle: l10n.pushAlertsDescription,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.customAlertRange, style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600)),
          const SizedBox(height: 8),
          TextFormField(
            controller: _rangeController,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.textPrimary),
            decoration: InputDecoration(
              hintText: l10n.enterRangeKm,
              hintStyle: const TextStyle(color: AppColors.textTertiary),
              suffixText: 'km',
              suffixStyle: const TextStyle(color: AppColors.textSecondary),
              errorText: _rangeError,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.textTertiary),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8),
                borderSide: const BorderSide(color: AppColors.brandPrimary, width: 2),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              fillColor: AppColors.nightSkyMiddle.withOpacity(0.3),
              filled: true,
            ),
            onChanged: _validateAndUpdateRange,
          ),
          if (_pushRadiusKm > 1000) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.public, size: 16, color: AppColors.semanticError),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.globalRangeWarning,
                    style: const TextStyle(color: AppColors.semanticError, fontSize: 12),
                  ),
                ),
              ],
            ),
          ] else if (_pushRadiusKm > 100) ...[
            const SizedBox(height: 8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.warning_outlined, size: 16, color: AppColors.semanticWarning),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    l10n.largeRangeWarning,
                    style: const TextStyle(color: AppColors.semanticWarning, fontSize: 12),
                  ),
                ),
              ],
            ),
          ],
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

  void _validateAndUpdateRange(String value) {
    setState(() {
      _rangeError = null;

      // Sanitize input: trim whitespace, remove non-numeric characters except decimal point
      final sanitizedValue = value.trim().replaceAll(RegExp(r'[^\d.]'), '');

      if (sanitizedValue.isEmpty) {
        _rangeError = AppLocalizations.of(context)!.invalidRange;
        return;
      }

      final range = double.tryParse(sanitizedValue);
      if (range == null || range < 1 || range > 99999 || !range.isFinite) {
        _rangeError = AppLocalizations.of(context)!.invalidRange;
        return;
      }

      // Round to reasonable precision (no need for sub-kilometer precision)
      _pushRadiusKm = double.parse(range.toStringAsFixed(1));
    });
  }

  @override
  void dispose() {
    _rangeController.dispose();
    super.dispose();
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