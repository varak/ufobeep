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
  
  @override
  void initState() {
    super.initState();
    _workingFilter = ref.read(alertsFilterStateProvider);
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
                    // Categories Section
                    _buildSectionTitle('Categories'),
                    const SizedBox(height: 12),
                    _buildCategoryFilters(),
                    
                    const SizedBox(height: 24),
                    
                    // Distance Section
                    _buildSectionTitle('Max Distance'),
                    const SizedBox(height: 12),
                    _buildDistanceFilter(),
                    
                    const SizedBox(height: 24),
                    
                    // Time Section
                    _buildSectionTitle('Max Age'),
                    const SizedBox(height: 12),
                    _buildTimeFilter(),
                    
                    const SizedBox(height: 24),
                    
                    // Verification Section
                    _buildSectionTitle('Verification'),
                    const SizedBox(height: 12),
                    _buildVerificationFilter(),
                    
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

  Widget _buildCategoryFilters() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: AlertCategory.all.map((category) {
        final isSelected = _workingFilter.categories.contains(category.key);
        
        return FilterChip(
          label: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(category.icon),
              const SizedBox(width: 6),
              Text(category.displayName),
            ],
          ),
          selected: isSelected,
          onSelected: (selected) {
            final categories = Set<String>.from(_workingFilter.categories);
            if (selected) {
              categories.add(category.key);
            } else {
              categories.remove(category.key);
            }
            _updateWorkingFilter(_workingFilter.copyWith(categories: categories));
          },
          backgroundColor: AppColors.darkBackground,
          selectedColor: AppColors.brandPrimary.withOpacity(0.2),
          checkmarkColor: AppColors.brandPrimary,
          labelStyle: TextStyle(
            color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDistanceFilter() {
    final distances = [1.0, 5.0, 10.0, 25.0, 50.0];
    
    return Column(
      children: [
        if (_workingFilter.maxDistanceKm != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Within ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  '${_workingFilter.maxDistanceKm!.toInt()} km',
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _updateWorkingFilter(_workingFilter.clearDistance()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: distances.map((distance) {
            final isSelected = _workingFilter.maxDistanceKm == distance;
            
            return FilterChip(
              label: Text('${distance.toInt()}km'),
              selected: isSelected,
              onSelected: (selected) {
                _updateWorkingFilter(_workingFilter.copyWith(
                  maxDistanceKm: selected ? distance : null,
                ));
              },
              backgroundColor: AppColors.darkBackground,
              selectedColor: AppColors.brandPrimary.withOpacity(0.2),
              checkmarkColor: AppColors.brandPrimary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildTimeFilter() {
    final timeOptions = [
      (1, '1 hour'),
      (6, '6 hours'),
      (24, '24 hours'),
      (72, '3 days'),
      (168, '1 week'),
    ];
    
    return Column(
      children: [
        if (_workingFilter.maxAgeHours != null)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              children: [
                const Text(
                  'Within ',
                  style: TextStyle(color: AppColors.textSecondary),
                ),
                Text(
                  _getTimeLabel(_workingFilter.maxAgeHours!),
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _updateWorkingFilter(_workingFilter.clearAge()),
                  child: const Text('Clear'),
                ),
              ],
            ),
          ),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: timeOptions.map((option) {
            final hours = option.$1;
            final label = option.$2;
            final isSelected = _workingFilter.maxAgeHours == hours;
            
            return FilterChip(
              label: Text(label),
              selected: isSelected,
              onSelected: (selected) {
                _updateWorkingFilter(_workingFilter.copyWith(
                  maxAgeHours: selected ? hours : null,
                ));
              },
              backgroundColor: AppColors.darkBackground,
              selectedColor: AppColors.brandPrimary.withOpacity(0.2),
              checkmarkColor: AppColors.brandPrimary,
              labelStyle: TextStyle(
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildVerificationFilter() {
    return Row(
      children: [
        Expanded(
          child: CheckboxListTile(
            title: const Text(
              'Verified only',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            subtitle: const Text(
              'Show only verified alerts',
              style: TextStyle(color: AppColors.textTertiary, fontSize: 12),
            ),
            value: _workingFilter.verifiedOnly ?? false,
            onChanged: (value) {
              _updateWorkingFilter(_workingFilter.copyWith(
                verifiedOnly: value == true ? true : null,
              ));
            },
            activeColor: AppColors.brandPrimary,
            contentPadding: EdgeInsets.zero,
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

  String _getTimeLabel(int hours) {
    if (hours < 24) {
      return '$hours hour${hours > 1 ? 's' : ''}';
    } else {
      final days = hours ~/ 24;
      return '$days day${days > 1 ? 's' : ''}';
    }
  }
}