import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/locale_config.dart';
import '../../theme/app_theme.dart';

class LanguageSelector extends ConsumerWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;
  final bool enabled;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Language',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
          decoration: BoxDecoration(
            color: AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.darkBorder),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedLanguage,
              isExpanded: true,
              dropdownColor: AppColors.darkSurface,
              style: const TextStyle(color: AppColors.textPrimary),
              onChanged: enabled
                  ? (String? newValue) {
                      if (newValue != null) {
                        onLanguageChanged(newValue);
                      }
                    }
                  : null,
              items: LocaleConfig.supportedLocales
                  .map((locale) => DropdownMenuItem<String>(
                        value: locale.languageCode,
                        child: Row(
                          children: [
                            Text(
                              LocaleConfig.getLocaleFlag(locale.languageCode),
                              style: const TextStyle(fontSize: 20),
                            ),
                            const SizedBox(width: 12),
                            Text(
                              LocaleConfig.getLocaleName(locale.languageCode),
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ))
                  .toList(),
            ),
          ),
        ),
      ],
    );
  }
}

class LanguageSelectorDialog extends StatelessWidget {
  final String selectedLanguage;
  final ValueChanged<String> onLanguageChanged;

  const LanguageSelectorDialog({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: AppColors.darkSurface,
      title: const Text(
        'Select Language',
        style: TextStyle(color: AppColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: LocaleConfig.supportedLocales
            .map((locale) => ListTile(
                  leading: Text(
                    LocaleConfig.getLocaleFlag(locale.languageCode),
                    style: const TextStyle(fontSize: 24),
                  ),
                  title: Text(
                    LocaleConfig.getLocaleName(locale.languageCode),
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                  trailing: selectedLanguage == locale.languageCode
                      ? const Icon(
                          Icons.check_circle,
                          color: AppColors.brandPrimary,
                        )
                      : null,
                  onTap: () {
                    onLanguageChanged(locale.languageCode);
                    Navigator.of(context).pop();
                  },
                ))
            .toList(),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(
            'Cancel',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      ],
    );
  }
}