import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UnitsSelector extends StatelessWidget {
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
  Widget build(BuildContext context) {
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
        const Text(
          'Choose your preferred measurement units',
          style: TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.darkBackground,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: Column(
            children: [
              _buildUnitTile(
                value: 'metric',
                title: 'Metric',
                subtitle: 'Kilometers, Celsius, km/h',
                icon: Icons.straighten,
              ),
              _buildDivider(),
              _buildUnitTile(
                value: 'imperial',
                title: 'Imperial',
                subtitle: 'Miles, Fahrenheit, mph',
                icon: Icons.straighten,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildUnitTile({
    required String value,
    required String title,
    required String subtitle,
    required IconData icon,
  }) {
    final isSelected = selectedUnits == value;
    
    return InkWell(
      onTap: enabled ? () => onUnitsChanged(value) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: isSelected
                    ? AppColors.brandPrimary.withOpacity(0.2)
                    : AppColors.darkSurface,
                borderRadius: BorderRadius.circular(8),
                border: isSelected
                    ? Border.all(color: AppColors.brandPrimary)
                    : Border.all(color: AppColors.darkBorder),
              ),
              child: Icon(
                icon,
                color: isSelected ? AppColors.brandPrimary : AppColors.textSecondary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.brandPrimary,
                size: 24,
              )
            else if (enabled)
              const Icon(
                Icons.radio_button_unchecked,
                color: AppColors.textSecondary,
                size: 24,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildDivider() {
    return Container(
      height: 1,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      color: AppColors.darkBorder,
    );
  }
}