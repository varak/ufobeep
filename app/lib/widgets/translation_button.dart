import 'package:flutter/material.dart';
import '../l10n/app_localizations.dart';
import '../services/translation_service.dart';
import '../theme/app_theme.dart';

/// Translation button widget for alert content
/// Shows "Translate to [Language]" and handles translation state
class TranslationButton extends StatefulWidget {
  const TranslationButton({
    super.key,
    required this.originalText,
    required this.targetLanguage,
    required this.onTranslationChanged,
    this.contentLanguage,
    this.isTranslated = false,
  });

  final String originalText;
  final String targetLanguage;
  final String? contentLanguage;
  final bool isTranslated;
  final Function(String translatedText, bool isTranslated) onTranslationChanged;

  @override
  State<TranslationButton> createState() => _TranslationButtonState();
}

class _TranslationButtonState extends State<TranslationButton> {
  bool _isTranslating = false;
  String? _cachedTranslation;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final targetLanguageName = TranslationService.languageNames[widget.targetLanguage] ?? widget.targetLanguage.toUpperCase();

    // Don't show button if translation not needed
    if (!_shouldShowTranslateButton()) {
      return const SizedBox.shrink();
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton.icon(
              onPressed: _isTranslating ? null : _handleTranslateToggle,
              style: OutlinedButton.styleFrom(
                foregroundColor: widget.isTranslated ? AppColors.brandPrimary : AppColors.textSecondary,
                side: BorderSide(
                  color: widget.isTranslated ? AppColors.brandPrimary : AppColors.textSecondary,
                ),
                padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              ),
              icon: _isTranslating
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      widget.isTranslated ? Icons.undo : Icons.translate,
                      size: 18,
                    ),
              label: Text(
                _getButtonText(l10n, targetLanguageName),
                style: const TextStyle(fontSize: 14),
              ),
            ),
          ),
          if (widget.isTranslated) ...[
            const SizedBox(width: 8),
            Text(
              AppLocalizations.of(context)!.translatedFrom(_getSourceLanguageName()),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  bool _shouldShowTranslateButton() {
    // Always show if we have content to translate
    if (widget.originalText.trim().isEmpty) return false;

    // Show if we don't know the content language (might need translation)
    if (widget.contentLanguage == null || widget.contentLanguage == 'unknown') {
      return true;
    }

    // Show if content language differs from user language
    // EVERYONE deserves to read foreign content - English users traveling, etc.
    return TranslationService().needsTranslation(widget.contentLanguage, widget.targetLanguage);
  }

  String _getButtonText(AppLocalizations l10n, String targetLanguageName) {
    if (_isTranslating) {
      return l10n.translating;
    } else if (widget.isTranslated) {
      return l10n.showOriginal;
    } else {
      return l10n.translateTo(targetLanguageName);
    }
  }

  String _getSourceLanguageName() {
    if (widget.contentLanguage != null) {
      return TranslationService.languageNames[widget.contentLanguage!] ?? widget.contentLanguage!.toUpperCase();
    }
    return 'Original Language';
  }

  Future<void> _handleTranslateToggle() async {
    if (widget.isTranslated) {
      // Switch back to original
      widget.onTranslationChanged(widget.originalText, false);
      return;
    }

    // Translate to target language
    setState(() {
      _isTranslating = true;
    });

    try {
      String translatedText;

      // Use cached translation if available
      if (_cachedTranslation != null) {
        translatedText = _cachedTranslation!;
      } else {
        // Get fresh translation
        translatedText = await TranslationService().translateText(
          widget.originalText,
          widget.targetLanguage,
        );
        _cachedTranslation = translatedText;
      }

      widget.onTranslationChanged(translatedText, true);

    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Translation failed: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isTranslating = false;
        });
      }
    }
  }
}