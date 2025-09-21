import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../models/alerts_filter.dart';
import '../providers/alerts_provider.dart';
import '../providers/user_preferences_provider.dart';

class AlertsFilterDialog extends ConsumerStatefulWidget {
  const AlertsFilterDialog({super.key});

  @override
  ConsumerState<AlertsFilterDialog> createState() => _AlertsFilterDialogState();
}

class _AlertsFilterDialogState extends ConsumerState<AlertsFilterDialog> {
  AlertsFilter? _workingFilter;
  double _distanceSliderValue = 100.0;
  
  @override
  void initState() {
    super.initState();
    // Initialize working filter from current state
    _workingFilter = ref.read(alertsFilterStateProvider);
    // Initialize slider value based on current filter
    _distanceSliderValue = _workingFilter!.maxDistanceKm == null
        ? 100.0
        : ((_workingFilter!.maxDistanceKm! - 5.0) / 195.0) * 100.0;
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
    // Initialize working filter from current state if not set
    _workingFilter ??= ref.read(alertsFilterStateProvider);

    return Dialog(
      backgroundColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
        decoration: BoxDecoration(
          color: AppColors.glassCardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: AppColors.glassCardBorder,
            width: 1,
          ),
          boxShadow: const [
            BoxShadow(
              blurRadius: 18,
              offset: Offset(0, 6),
              color: Colors.black26,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              child: Text(
                'Filter Alerts',
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),

            // Filter Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // UFOBeep Only Toggle Section
                    _buildSectionTitle('Alert Source'),
                    const SizedBox(height: 12),
                    _buildUfoBeepOnlyToggle(),
                    const SizedBox(height: 24),

                    // Distance Slider Section
                    _buildSectionTitle('Alert Distance Range'),
                    const SizedBox(height: 12),
                    _buildDistanceSlider(),
                  ],
                ),
              ),
            ),

            // Footer Actions
            Container(
              padding: const EdgeInsets.all(20),
              decoration: const BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.textSecondary,
                        side: const BorderSide(color: AppColors.darkBorder),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _applyFilter,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.brandPrimary,
                        foregroundColor: Colors.black,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Text('Apply Filters'),
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

  Widget _buildDistanceSlider() {
    String getDistanceLabel() {
      if (_distanceSliderValue >= 100.0) {
        return 'Show All Alerts';
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
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Current value display
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.location_on,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                getDistanceLabel(),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Slider
        Row(
          children: [
            const Text(
              'Visibility',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
              ),
            ),
            Expanded(
              child: Slider(
                value: _distanceSliderValue,
                min: 0.0,
                max: 100.0,
                divisions: 20,
                activeColor: AppColors.brandPrimary,
                inactiveColor: AppColors.darkBorder,
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
        
        // Helper text
        const SizedBox(height: 8),
        Text(
          'Drag to adjust how far you want to see alerts. Start from weather visibility distance up to showing all alerts regardless of distance.',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildUfoBeepOnlyToggle() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
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
                const Text(
                  'UFOBeep Only',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Show only original UFOBeep reports (exclude MUFON database)',
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