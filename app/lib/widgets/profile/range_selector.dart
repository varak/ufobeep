import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/user_preferences.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';

class RangeSelector extends ConsumerWidget {
  final double selectedRange;
  final ValueChanged<double> onRangeChanged;
  final bool enabled;

  const RangeSelector({
    super.key,
    required this.selectedRange,
    required this.onRangeChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final units = ref.watch(unitsProvider);
    final isMetric = units == 'metric';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Alert Range',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '1 ${isMetric ? 'km' : 'mi'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  Text(
                    _formatRange(selectedRange, units),
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '100 ${isMetric ? 'km' : 'mi'}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              SliderTheme(
                data: SliderTheme.of(context).copyWith(
                  activeTrackColor: AppColors.brandPrimary,
                  inactiveTrackColor: AppColors.darkBorder,
                  thumbColor: AppColors.brandPrimary,
                  overlayColor: AppColors.brandPrimary.withOpacity(0.2),
                  valueIndicatorColor: AppColors.brandPrimary,
                  valueIndicatorTextStyle: const TextStyle(
                    color: AppColors.textInverse,
                    fontSize: 12,
                  ),
                ),
                child: Slider(
                  value: selectedRange.clamp(1.0, 100.0),
                  min: 1.0,
                  max: 100.0,
                  divisions: 99,
                  label: _formatRange(selectedRange, units),
                  onChanged: enabled ? onRangeChanged : null,
                ),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: UserPreferences.commonRanges
                    .map((range) => _RangeChip(
                          range: range,
                          units: units,
                          isSelected: (selectedRange - range).abs() < 0.1,
                          onTap: enabled ? () => onRangeChanged(range) : null,
                        ))
                    .toList(),
              ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'You will receive notifications for sightings within this distance from your location.',
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  String _formatRange(double range, String units) {
    if (units == 'imperial') {
      final miles = range * 0.621371;
      return '${miles.toStringAsFixed(1)} mi';
    } else {
      return '${range.toStringAsFixed(1)} km';
    }
  }
}

class _RangeChip extends StatelessWidget {
  final double range;
  final String units;
  final bool isSelected;
  final VoidCallback? onTap;

  const _RangeChip({
    required this.range,
    required this.units,
    required this.isSelected,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final displayRange = units == 'imperial' ? range * 0.621371 : range;
    final unitLabel = units == 'imperial' ? 'mi' : 'km';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandPrimary.withOpacity(0.2)
              : AppColors.darkBackground,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.darkBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Text(
          '${displayRange.toStringAsFixed(displayRange < 10 ? 1 : 0)} $unitLabel',
          style: TextStyle(
            color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class UnitsSelector extends ConsumerWidget {
  final String selectedUnits;
  final ValueChanged<String> onUnitsChanged;
  final bool enabled;

  const UnitsSelector({
    super.key,
    required this.selectedUnits,
    required this.onUnitsChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Units',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(
              child: _UnitOption(
                title: 'Metric',
                subtitle: 'km, celsius',
                value: 'metric',
                selectedValue: selectedUnits,
                onChanged: enabled ? onUnitsChanged : null,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _UnitOption(
                title: 'Imperial',
                subtitle: 'miles, fahrenheit',
                value: 'imperial',
                selectedValue: selectedUnits,
                onChanged: enabled ? onUnitsChanged : null,
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _UnitOption extends StatelessWidget {
  final String title;
  final String subtitle;
  final String value;
  final String selectedValue;
  final ValueChanged<String>? onChanged;

  const _UnitOption({
    required this.title,
    required this.subtitle,
    required this.value,
    required this.selectedValue,
    this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isSelected = value == selectedValue;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(value) : null,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.brandPrimary.withOpacity(0.1)
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.brandPrimary : AppColors.darkBorder,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: TextStyle(
                      color: isSelected
                          ? AppColors.brandPrimary
                          : AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (isSelected)
                  const Icon(
                    Icons.check_circle,
                    color: AppColors.brandPrimary,
                    size: 20,
                  ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}