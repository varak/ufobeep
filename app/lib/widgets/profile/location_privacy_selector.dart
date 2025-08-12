import 'package:flutter/material.dart';
import '../../models/user_preferences.dart';
import '../../theme/app_theme.dart';

class LocationPrivacySelector extends StatelessWidget {
  final LocationPrivacy selectedPrivacy;
  final ValueChanged<LocationPrivacy> onPrivacyChanged;
  final bool enabled;

  const LocationPrivacySelector({
    super.key,
    required this.selectedPrivacy,
    required this.onPrivacyChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Location Privacy',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Choose how location data is shared in your sightings',
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
            children: LocationPrivacy.values.map((privacy) {
              final isLast = privacy == LocationPrivacy.values.last;
              return Column(
                children: [
                  _buildPrivacyTile(privacy),
                  if (!isLast) _buildDivider(),
                ],
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  Widget _buildPrivacyTile(LocationPrivacy privacy) {
    final isSelected = selectedPrivacy == privacy;
    
    return InkWell(
      onTap: enabled ? () => onPrivacyChanged(privacy) : null,
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
                privacy.icon,
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
                    privacy.displayName,
                    style: TextStyle(
                      color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    privacy.description,
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