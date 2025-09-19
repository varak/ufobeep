import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../config/locale_config.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/user_preferences_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/profile/language_selector.dart';

class LanguageSettingsScreen extends ConsumerWidget {
  const LanguageSettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context)!;
    final currentLanguage = ref.watch(userLanguageProvider);
    final preferencesNotifier = ref.watch(userPreferencesProvider.notifier);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text(l10n.language),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current language display
            Card(
              color: AppColors.darkSurface,
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.language,
                      color: AppColors.brandPrimary,
                      size: 24,
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Current Language',
                            style: TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 14,
                            ),
                          ),
                          Text(
                            LocaleConfig.getLocaleDisplayName(
                              LocaleConfig.supportedLocales.firstWhere(
                                (locale) => locale.languageCode == currentLanguage,
                                orElse: () => LocaleConfig.defaultLocale,
                              ),
                            ),
                            style: TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Language selection list
            Text(
              'Available Languages',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Expanded(
              child: ListView.builder(
                itemCount: LocaleConfig.supportedLocales.length,
                itemBuilder: (context, index) {
                  final locale = LocaleConfig.supportedLocales[index];
                  final isSelected = locale.languageCode == currentLanguage;
                  
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    color: isSelected ? AppColors.brandPrimary.withValues(alpha: 0.1) : AppColors.darkSurface,
                    child: ListTile(
                      leading: Text(
                        LocaleConfig.getLocaleFlag(locale.languageCode),
                        style: const TextStyle(fontSize: 28),
                      ),
                      title: Text(
                        LocaleConfig.getLocaleName(locale.languageCode),
                        style: TextStyle(
                          color: isSelected ? AppColors.brandPrimary : AppColors.textPrimary,
                          fontSize: 16,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                        ),
                      ),
                      subtitle: Text(
                        _getLanguageDescription(locale.languageCode),
                        style: TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                      trailing: isSelected
                          ? Icon(
                              Icons.check_circle,
                              color: AppColors.brandPrimary,
                            )
                          : Icon(
                              Icons.radio_button_unchecked,
                              color: AppColors.textTertiary,
                            ),
                      onTap: () => _changeLanguage(
                        context,
                        ref,
                        preferencesNotifier,
                        locale.languageCode,
                      ),
                    ),
                  );
                },
              ),
            ),
            
            // Info card
            Card(
              color: AppColors.semanticInfo.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.semanticInfo,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Language changes take effect immediately. The app interface will be translated to your selected language.',
                        style: TextStyle(
                          color: AppColors.semanticInfo,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getLanguageDescription(String languageCode) {
    switch (languageCode) {
      case 'en':
        return 'English (United States)';
      case 'es':
        return 'Español (España)';
      case 'de':
        return 'Deutsch (Deutschland)';
      default:
        return languageCode.toUpperCase();
    }
  }

  Future<void> _changeLanguage(
    BuildContext context,
    WidgetRef ref,
    UserPreferencesNotifier preferencesNotifier,
    String languageCode,
  ) async {
    // Non-blocking feedback instead of modal dialog to avoid UI hang
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Changing language...'),
          duration: const Duration(milliseconds: 800),
          backgroundColor: AppColors.textSecondary,
        ),
      );
    }

    // Update language and sync to backend for push notifications
    final success = await preferencesNotifier.updateLanguage(languageCode);

    if (!context.mounted) return;

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          success
              ? 'Language changed to ${LocaleConfig.getLocaleName(languageCode)}'
              : 'Failed to change language',
        ),
        backgroundColor:
            success ? AppColors.semanticSuccess : AppColors.semanticError,
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
