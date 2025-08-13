import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../theme/app_theme.dart';
import '../models/alerts_filter.dart';
import '../providers/alerts_provider.dart';

class AlertsFilterDialog extends ConsumerStatefulWidget {
  const AlertsFilterDialog({super.key});

  @override
  ConsumerState<AlertsFilterDialog> createState() => _AlertsFilterDialogState();
}

class _AlertsFilterDialogState extends ConsumerState<AlertsFilterDialog> {
  late AlertsFilter _workingFilter;
  late double _distanceSliderValue;
  
  @override
  void initState() {
    super.initState();
    _workingFilter = ref.read(alertsFilterStateProvider);
    // Initialize slider value: 0 = visibility (~5km), 100 = show all
    _distanceSliderValue = _workingFilter.maxDistanceKm == null 
        ? 100.0 
        : ((_workingFilter.maxDistanceKm! - 5.0) / 195.0) * 100.0;
  }

  void _updateWorkingFilter(AlertsFilter filter) {
    setState(() {
      _workingFilter = filter;
    });
  }

  void _applyFilter() {
    ref.read(alertsFilterStateProvider.notifier).updateFilter(_workingFilter);
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
        _workingFilter = _workingFilter.copyWith(maxDistanceKm: null);
      } else {
        // Map 0-100 to 5km-200km (weather visibility to very far)
        final distance = 5.0 + (value / 100.0) * 195.0;
        _workingFilter = _workingFilter.copyWith(maxDistanceKm: distance);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(maxHeight: 600),
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
              child: Row(
                children: [
                  const Text(
                    'Filter Alerts',
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: _resetFilter,
                    child: const Text('Reset'),
                  ),
                ],
              ),
            ),

            // Filter Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Distance Slider Section
                    _buildSectionTitle('Alert Distance Range'),
                    const SizedBox(height: 12),
                    _buildDistanceSlider(),
                    
                    const SizedBox(height: 24),
                    
                    // Sorting Section
                    _buildSectionTitle('Sort By'),
                    const SizedBox(height: 12),
                    _buildSortingFilter(),
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
        return 'Weather Visibility (~5km)';
      } else {
        final distance = 5.0 + (_distanceSliderValue / 100.0) * 195.0;
        return '${distance.toInt()}km radius';
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

  Widget _buildSortingFilter() {
    return Column(
      children: [
        DropdownButtonFormField<AlertSortBy>(
          value: _workingFilter.sortBy,
          decoration: InputDecoration(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.darkBorder),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.brandPrimary),
            ),
            filled: true,
            fillColor: AppColors.darkBackground,
          ),
          dropdownColor: AppColors.darkSurface,
          style: const TextStyle(color: AppColors.textPrimary),
          items: AlertSortBy.values.map((sortBy) {
            return DropdownMenuItem(
              value: sortBy,
              child: Text(sortBy.displayName),
            );
          }).toList(),
          onChanged: (sortBy) {
            if (sortBy != null) {
              _updateWorkingFilter(_workingFilter.copyWith(sortBy: sortBy));
            }
          },
        ),
        
        const SizedBox(height: 12),
        
        Row(
          children: [
            Expanded(
              child: CheckboxListTile(
                title: const Text(
                  'Ascending order',
                  style: TextStyle(color: AppColors.textPrimary),
                ),
                value: _workingFilter.ascending,
                onChanged: (value) {
                  _updateWorkingFilter(_workingFilter.copyWith(ascending: value ?? false));
                },
                activeColor: AppColors.brandPrimary,
                contentPadding: EdgeInsets.zero,
              ),
            ),
          ],
        ),
      ],
    );
  }

}