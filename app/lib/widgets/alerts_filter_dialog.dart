import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../models/alerts_filter.dart';
import '../providers/alerts_provider.dart';
import '../providers/user_preferences_provider.dart';
import '../l10n/app_localizations.dart';

enum SourceFilter { both, ufobeepOnly, mufonOnly }
enum SortOption { newest, nearest }

class AlertsFilterDialog extends ConsumerStatefulWidget {
  const AlertsFilterDialog({super.key});

  @override
  ConsumerState<AlertsFilterDialog> createState() => _AlertsFilterDialogState();
}

class _AlertsFilterDialogState extends ConsumerState<AlertsFilterDialog> {
  AlertsFilter? _workingFilter;

  // Simplified filter state
  SourceFilter _sourceFilter = SourceFilter.both;
  SortOption _sortOption = SortOption.newest;
  double _pushRadiusKm = 30.0;
  bool _ufobeepAlertsEnabled = true;
  
  @override
  void initState() {
    super.initState();
    // Initialize from current filter state
    final currentFilter = ref.read(alertsFilterStateProvider);
    _workingFilter = currentFilter;

    // Initialize simplified state from current filter
    if (currentFilter.showUfoBeepOnly == true) {
      _sourceFilter = SourceFilter.ufobeepOnly;
    } else {
      _sourceFilter = SourceFilter.both; // Default to both sources
    }

    _pushRadiusKm = currentFilter.alertRangeKm ?? 30.0;
    _ufobeepAlertsEnabled = true; // Default enabled
  }

  void _updateWorkingFilter(AlertsFilter filter) {
    setState(() {
      _workingFilter = filter;
    });
  }

  void _applyFilter() {
    if (_workingFilter != null) {
      ref.read(alertsFilterStateProvider.notifier).updateFilter(_workingFilter!);
    }
    Navigator.of(context).pop();
  }

  void _resetFilter() {
    setState(() {
      _workingFilter = const AlertsFilter();
      _distanceSliderValue = 100.0; // Reset to show all
    });
  }

  void _updateDistanceFromSlider(double value) {
    setState(() {
      _distanceSliderValue = value;
      if (value >= 100.0) {
        // Show all alerts
        _workingFilter = _workingFilter!.copyWith(maxDistanceKm: null);
      } else {
        // Map 0-100 to 5km-200km (weather visibility to very far)
        final distance = 5.0 + (value / 100.0) * 195.0;
        _workingFilter = _workingFilter!.copyWith(maxDistanceKm: distance);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
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
            Container(
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

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.w600,
      ),
    );
  }

  Widget _buildNotificationRangeSlider() {
    final range = _workingFilter!.alertRangeKm ?? 30.0;

    return Column(
      children: [
        // Compact notification range control
        Row(
          children: [
            const Icon(Icons.notifications_active, color: AppColors.brandPrimary, size: 16),
            const SizedBox(width: 8),
            Text('${range.toInt()}km', style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            Expanded(
              child: Slider(
                value: range.clamp(10.0, 200.0),
                min: 10.0,
                max: 200.0,
                divisions: 19,
                onChanged: (value) => _updateWorkingFilter(_workingFilter!.copyWith(alertRangeKm: value)),
                activeColor: AppColors.brandPrimary,
                inactiveColor: AppColors.textTertiary,
              ),
            ),
          ],
        ),
        Text(
          AppLocalizations.of(context)!.pushAlertsWithinDistance,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildViewingRangeSlider() {
    String getViewingLabel() {
      if (_distanceSliderValue >= 100.0) {
        return AppLocalizations.of(context)!.showAllAlerts;
      } else if (_distanceSliderValue <= 0.0) {
        final units = ref.read(userPreferencesProvider)?.units ?? 'metric';
        return units == 'imperial' ? 'Weather Visibility (~3mi)' : 'Weather Visibility (~5km)';
      } else {
        final units = ref.read(userPreferencesProvider)?.units ?? 'metric';
        final distance = 5.0 + (_distanceSliderValue / 100.0) * 195.0;
        if (units == 'imperial') {
          final distanceMi = distance * 0.621371;
          return '${distanceMi.toInt()}mi radius';
        } else {
          return '${distance.toInt()}km radius';
        }
      }
    }

    return Column(
      children: [
        // Compact viewing range control
        Row(
          children: [
            const Icon(Icons.map, color: AppColors.brandPrimary, size: 16),
            const SizedBox(width: 8),
            Text(getViewingLabel(), style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.w600)),
            Expanded(
              child: Slider(
                value: _distanceSliderValue,
                min: 0.0,
                max: 100.0,
                divisions: 20,
                activeColor: AppColors.brandPrimary,
                inactiveColor: AppColors.textTertiary,
                onChanged: _updateDistanceFromSlider,
              ),
            ),
            const Text(
              'Show All',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
          ],
        ),
        
        Text(
          AppLocalizations.of(context)!.showAlertsWhenBrowsing,
          style: const TextStyle(color: AppColors.textTertiary, fontSize: 10),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildUfoBeepOnlyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.nightSkyMiddle.withOpacity(0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.nightSkyMiddle.withOpacity(0.95),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
            ),
            child: const Text(
              '🛸',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.ufobeepOnly,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  AppLocalizations.of(context)!.ufobeepOnlyDescription,
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: _workingFilter!.showUfoBeepOnly ?? false,
            onChanged: (value) {
              print('DEBUG: Toggle switched to: $value');
              print('DEBUG: Current _workingFilter.showUfoBeepOnly: ${_workingFilter!.showUfoBeepOnly}');

              if (value) {
                // Turn on UFOBeep only
                final newFilter = _workingFilter!.copyWith(showUfoBeepOnly: true);
                print('DEBUG: Setting UFOBeep ON, new filter: ${newFilter.showUfoBeepOnly}');
                _updateWorkingFilter(newFilter);
              } else {
                // Turn off UFOBeep only - use clearUfoBeepOnly method
                final newFilter = _workingFilter!.clearUfoBeepOnly();
                print('DEBUG: Setting UFOBeep OFF, new filter: ${newFilter.showUfoBeepOnly}');
                _updateWorkingFilter(newFilter);
              }
            },
            activeColor: AppColors.brandPrimary,
            inactiveThumbColor: AppColors.textTertiary,
            inactiveTrackColor: AppColors.darkBorder,
          ),
        ],
      ),
    );
  }

}