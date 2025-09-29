import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Real-time content translation service using Google Translate
/// Makes UFO reports accessible in any language globally
class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  // Session-based translation cache to avoid repeated API calls
  final Map<String, String> _translationCache = {};

  /// Language code mapping for Google Translate API
  static const Map<String, String> languageNames = {
    'en': 'English',
    'es': 'Español',
    'de': 'Deutsch',
    'fr': 'Français',
    'it': 'Italiano',
    'pt': 'Português',
    'ru': 'Русский',
    'ja': '日本語',
    'zh': '中文',
    'ar': 'العربية',
    'nl': 'Nederlands',
    'pl': 'Polski',
    'cs': 'Čeština',
    'tr': 'Türkçe',
    'ko': '한국어',
    'hi': 'हिन्दी',
    'sv': 'Svenska',
    'da': 'Dansk',
    'no': 'Norsk',
    'fi': 'Suomi',
    'el': 'Ελληνικά',
    'he': 'עברית',
  };

  /// Detect if content needs translation based on user's language preference
  bool needsTranslation(String? contentLanguage, String userLanguage) {
    // If we can't detect content language, assume it might need translation
    if (contentLanguage == null || contentLanguage.isEmpty) {
      return true;
    }

    // Don't translate if same language
    if (contentLanguage.toLowerCase() == userLanguage.toLowerCase()) {
      return false;
    }

    // Check if languages are similar (en-US vs en-GB)
    final contentBase = contentLanguage.split('-')[0].toLowerCase();
    final userBase = userLanguage.split('-')[0].toLowerCase();

    return contentBase != userBase;
  }

  /// Get display name for language code
  String getLanguageDisplayName(String languageCode) {
    return languageNames[languageCode.toLowerCase()] ?? languageCode.toUpperCase();
  }

  /// Detect primary language of text content
  /// Simple heuristic - can be enhanced with ML detection later
  String detectContentLanguage(String text) {
    if (text.length < 10) return 'unknown';

    // Simple pattern matching for common languages
    // This is basic - could use actual language detection library
    if (RegExp(r'\b(the|and|or|is|was|were|are|a|an|in|on|at|to|for|of|with)\b', caseSensitive: false).hasMatch(text)) {
      return 'en';
    }
    if (RegExp(r'\b(el|la|los|las|y|o|es|fue|fueron|son|un|una|en|de|para|con)\b', caseSensitive: false).hasMatch(text)) {
      return 'es';
    }
    if (RegExp(r'\b(der|die|das|und|oder|ist|war|waren|sind|ein|eine|in|an|zu|für|von|mit)\b', caseSensitive: false).hasMatch(text)) {
      return 'de';
    }
    if (RegExp(r'\b(le|la|les|et|ou|est|était|étaient|sont|un|une|dans|de|pour|avec)\b', caseSensitive: false).hasMatch(text)) {
      return 'fr';
    }

    // Default to unknown if can't detect
    return 'unknown';
  }

  /// Translate single text using Google Translate
  Future<String> translateText(String text, String targetLanguage) async {
    if (text.trim().isEmpty) return text;

    // Check cache first
    final cacheKey = '${text.hashCode}:$targetLanguage';
    if (_translationCache.containsKey(cacheKey)) {
      debugPrint('📝 Using cached translation');
      return _translationCache[cacheKey]!;
    }

    try {
      debugPrint('🌐 Translating to $targetLanguage: "${text.substring(0, text.length > 50 ? 50 : text.length)}..."');

      final translatedText = await _callGoogleTranslate(text, targetLanguage);

      // Cache the result
      _translationCache[cacheKey] = translatedText;

      debugPrint('✅ Translation result: "${translatedText.substring(0, translatedText.length > 50 ? 50 : translatedText.length)}..."');
      return translatedText;

    } catch (e) {
      debugPrint('❌ Translation failed: $e');
      return text; // Return original text on failure
    }
  }

  /// Batch translate multiple texts efficiently
  Future<List<String>> batchTranslate(List<String> texts, String targetLanguage) async {
    if (texts.isEmpty) return texts;

    // Filter out empty texts but preserve positions
    final textMap = <int, String>{};
    final textsToTranslate = <String>[];

    for (int i = 0; i < texts.length; i++) {
      if (texts[i].trim().isNotEmpty) {
        textMap[i] = texts[i];
        textsToTranslate.add(texts[i]);
      }
    }

    if (textsToTranslate.isEmpty) return texts;

    try {
      debugPrint('🚀 Batch translating ${textsToTranslate.length} texts to $targetLanguage');

      // Batch translate using individual calls with small delays
      final results = <String>[];

      for (final text in textsToTranslate) {
        final translated = await _callGoogleTranslate(text, targetLanguage);
        results.add(translated);

        // Small delay between requests to avoid rate limiting
        if (results.length < textsToTranslate.length) {
          await Future.delayed(const Duration(milliseconds: 100));
        }
      }

      // Map results back to original positions
      final translatedTexts = List<String>.from(texts);
      int resultIndex = 0;

      for (final entry in textMap.entries) {
        if (resultIndex < results.length) {
          translatedTexts[entry.key] = results[resultIndex];
          resultIndex++;
        }
      }

      debugPrint('✅ Batch translation completed');
      return translatedTexts;

    } catch (e) {
      debugPrint('❌ Batch translation failed: $e');
      return texts; // Return original texts on failure
    }
  }

  /// Translate using Google Translate web API (free, unofficial)
  Future<String> _callGoogleTranslate(String text, String targetLanguage) async {
    try {
      // Use Google Translate unofficial API endpoint
      final url = Uri.parse('https://translate.googleapis.com/translate_a/single')
          .replace(queryParameters: {
        'client': 'gtx',
        'sl': 'auto', // Auto-detect source language
        'tl': targetLanguage,
        'dt': 't',
        'q': text,
      });

      final response = await http.get(url);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body);
        if (decoded != null && decoded[0] != null && decoded[0][0] != null) {
          return decoded[0][0][0] as String;
        }
      }

      throw Exception('Translation API returned invalid response');
    } catch (e) {
      debugPrint('❌ Google Translate API error: $e');
      rethrow;
    }
  }

  /// Clear translation cache (useful for language changes)
  void clearCache() {
    _translationCache.clear();
    debugPrint('🗑️ Translation cache cleared');
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cachedTranslations': _translationCache.length,
      'memoryUsage': _translationCache.toString().length,
    };
  }
}

/// Global translation service instance
final translationService = TranslationService();