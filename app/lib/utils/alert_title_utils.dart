import '../l10n/app_localizations.dart';
import '../models/enriched_alert.dart';
import '../models/api_models.dart';
import '../providers/alerts_provider.dart';

abstract class AlertTitleUtils {
  /// Generate dynamic title for mobile app using translations
  static String getDynamicTitle(AppLocalizations l10n, Alert alert) {
    // Check for MUFON case with enrichment data first
    final caseNumber = alert.enrichment?['mufon_case_number'];
    if (caseNumber != null) {
      // Try to get clean classification from enrichment data
      String? classification = _extractCleanClassification(alert.enrichment);

      if (classification != null && classification.isNotEmpty) {
        // Use classification-aware title format
        return l10n.mufonTitleFormat(classification);
      } else {
        // Fallback to case title
        return l10n.mufonCaseTitle(caseNumber);
      }
    }

    // Check if this is a translatable title format (using same logic as web frontend)
    if (alert.title != null && alert.title!.isNotEmpty) {
      // Handle MUFON titles: detect "MUFON [Shape] Sighting" pattern
      if (alert.title!.startsWith('MUFON ')) {
        final parts = alert.title!.split(' ');
        if (parts.length >= 3 && parts.last == 'Sighting') {
          // Extract the shape part between "MUFON" and "Sighting"
          final shapeParts = parts.sublist(1, parts.length - 1);
          final shape = shapeParts.join(' ').toLowerCase();

          // Get shape translation key using same mapping as web
          final shapeKey = _getShapeTranslationKey(shape);
          if (shapeKey != null) {
            // Build translated title: "MUFON [TranslatedShape] [TranslatedSightingReport]"
            final shapeTranslation = _getShapeTranslation(l10n, shapeKey);
            return 'MUFON $shapeTranslation ${l10n.sightingReport}';
          }
        }
        // Generic MUFON title
        return 'MUFON ${l10n.sightingReport}';
      }

      // Handle UFOBeep titles
      if (alert.title!.startsWith('UFOBeep Alert') ||
          alert.title! == 'UFO Sighting') {
        return 'UFOBeep ${l10n.ufoAlert}';
      }

      // Use existing title if it doesn't match our patterns
      return alert.title!;
    }

    // No title - use contextual generation
    return _generateContextualTitle(
      title: alert.title,
      description: alert.description,
      hasMedia: alert.mediaFiles.isNotEmpty,
      hasPhoto: alert.mediaFiles.any((media) =>
        media['type']?.toString() == 'photo' ||
        media['type']?.toString() == 'image'),
      hasVideo: alert.mediaFiles.any((media) =>
        media['type']?.toString() == 'video'),
      createdAt: alert.createdAt,
    );
  }

  /// Get shape translation key (mirrors web frontend logic)
  static String? _getShapeTranslationKey(String shape) {
    switch (shape.toLowerCase()) {
      case 'triangle':
        return 'mufonTriangle';
      case 'sphere':
        return 'mufonSphere';
      case 'light':
        return 'mufonLight';
      case 'disk':
      case 'disc':
        return 'mufonDisk';
      case 'cigar':
        return 'mufonCigar';
      case 'oval':
        return 'mufonOval';
      case 'cylinder':
        return 'mufonCylinder';
      case 'rectangle':
        return 'mufonRectangle';
      case 'diamond':
        return 'mufonDiamond';
      case 'fireball':
        return 'mufonFireball';
      case 'flash':
        return 'mufonFlash';
      case 'formation':
        return 'mufonFormation';
      case 'changing':
        return 'mufonChanging';
      case 'chevron':
        return 'mufonChevron';
      case 'cone':
        return 'mufonCone';
      case 'cross':
        return 'mufonCross';
      case 'egg':
        return 'mufonEgg';
      default:
        return null;
    }
  }

  /// Extract clean classification from enrichment data
  static String? _extractCleanClassification(Map<String, dynamic>? enrichment) {
    if (enrichment == null) return null;

    String? classification;

    // Try ufo_type first (simpler field)
    classification = enrichment['ufo_type']?.toString().toLowerCase().trim();

    // If no ufo_type, try to parse classification field
    if (classification == null || classification.isEmpty) {
      final classField = enrichment['classification'];
      if (classField is String) {
        // Clean the string first - remove HTML tags and decode entities
        String cleanField = classField
            .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
            .replaceAll('&lt;', '<')
            .replaceAll('&gt;', '>')
            .replaceAll('&amp;', '&')
            .replaceAll('&quot;', '"')
            .replaceAll('&#39;', "'");

        // Extract just the type if it's a formatted string like "type: sphere"
        final match = RegExp(r'type:\s*(\w+)').firstMatch(cleanField);
        classification = match?.group(1)?.toLowerCase().trim() ?? cleanField.toLowerCase().trim();
      } else if (classField is Map) {
        // If it's a complex object, try to extract 'type' field
        classification = classField['type']?.toString().toLowerCase().trim();
      }
    }

    // Clean the final classification of any remaining HTML or special chars
    if (classification != null) {
      classification = classification
          .replaceAll(RegExp(r'<[^>]*>'), '') // Remove HTML tags
          .replaceAll(RegExp(r'[^\w\s]'), '') // Remove special chars except word chars and spaces
          .trim();
    }

    return classification;
  }

  /// Get shape translation using AppLocalizations
  static String _getShapeTranslation(AppLocalizations l10n, String shapeKey) {
    switch (shapeKey) {
      case 'mufonTriangle':
        return l10n.mufonTriangle;
      case 'mufonSphere':
        return l10n.mufonSphere;
      case 'mufonLight':
        return l10n.mufonLight;
      case 'mufonDisk':
        return l10n.mufonDisk;
      case 'mufonCigar':
        return l10n.mufonCigar;
      case 'mufonOval':
        return l10n.mufonOval;
      case 'mufonCylinder':
        return l10n.mufonCylinder;
      case 'mufonRectangle':
        return l10n.mufonRectangle;
      case 'mufonDiamond':
        return l10n.mufonDiamond;
      case 'mufonFireball':
        return l10n.mufonFireball;
      case 'mufonFlash':
        return l10n.mufonFlash;
      case 'mufonFormation':
        return l10n.mufonFormation;
      case 'mufonChanging':
        return l10n.mufonChanging;
      case 'mufonChevron':
        return l10n.mufonChevron;
      case 'mufonCone':
        return l10n.mufonCone;
      case 'mufonCross':
        return l10n.mufonCross;
      case 'mufonEgg':
        return l10n.mufonEgg;
      default:
        return l10n.mufonUnknown;
    }
  }

  /// Generate a contextual title for an EnrichedAlert
  static String getContextualTitle(EnrichedAlert alert) {
    return _generateContextualTitle(
      title: alert.title,
      description: alert.description,
      hasMedia: alert.mediaFiles.isNotEmpty,
      hasPhoto: alert.mediaFiles.any((media) => media.type == MediaType.photo),
      hasVideo: alert.mediaFiles.any((media) => media.type == MediaType.video),
      createdAt: alert.createdAt,
    );
  }

  /// Generate a contextual title for an Alert from alerts_provider
  static String getContextualTitleFromAlert(Alert alert) {
    return _generateContextualTitle(
      title: alert.title,
      description: alert.description,
      hasMedia: alert.mediaFiles.isNotEmpty,
      hasPhoto: alert.mediaFiles.any((media) => 
        media['type']?.toString() == 'photo' || 
        media['type']?.toString() == 'image'),
      hasVideo: alert.mediaFiles.any((media) => 
        media['type']?.toString() == 'video'),
      createdAt: alert.createdAt,
    );
  }

  /// Internal method to generate titles
  static String _generateContextualTitle({
    required String? title,
    required String? description,
    required bool hasMedia,
    required bool hasPhoto,
    required bool hasVideo,
    required DateTime createdAt,
  }) {
    // If user provided a title, use it
    if (title != null && title.isNotEmpty) {
      return title;
    }
    
    // If user provided description, use first few words as title
    if (description != null && description.isNotEmpty) {
      final words = description.trim().split(' ');
      if (words.length <= 4) {
        return description;
      } else {
        return '${words.take(4).join(' ')}...';
      }
    }
    
    // Generate contextual title based on available data
    if (hasMedia) {
      
      if (hasPhoto && hasVideo) {
        return 'Visual sighting (photo & video)';
      } else if (hasVideo) {
        return 'Visual sighting (video)';
      } else if (hasPhoto) {
        return 'Visual sighting (photo)';
      } else {
        return 'Visual sighting';
      }
    }
    
    // Check if it's recent (within last hour)
    final now = DateTime.now();
    final timeDiff = now.difference(createdAt);
    
    if (timeDiff.inMinutes < 60) {
      return 'Recent sighting';
    } else if (timeDiff.inHours < 24) {
      return 'Sighting today';
    }
    
    // Final fallback
    return 'Sighting';
  }
  
  /// Get a short title for EnrichedAlert
  static String getShortTitle(EnrichedAlert alert) {
    return _generateShortTitle(
      title: alert.title,
      description: alert.description,
      hasMedia: alert.mediaFiles.isNotEmpty,
      createdAt: alert.createdAt,
    );
  }

  /// Get a short title for Alert from alerts_provider
  static String getShortTitleFromAlert(Alert alert) {
    return _generateShortTitle(
      title: alert.title,
      description: alert.description,
      hasMedia: alert.mediaFiles.isNotEmpty,
      createdAt: alert.createdAt,
    );
  }

  /// Internal method to generate short titles
  static String _generateShortTitle({
    required String? title,
    required String? description,
    required bool hasMedia,
    required DateTime createdAt,
  }) {
    // If user provided a title, use it
    if (title != null && title.isNotEmpty) {
      return title;
    }
    
    // If user provided description, use first 3 words
    if (description != null && description.isNotEmpty) {
      final words = description.trim().split(' ');
      if (words.length <= 3) {
        return description;
      } else {
        return '${words.take(3).join(' ')}...';
      }
    }
    
    // Check for media
    if (hasMedia) {
      return 'Visual sighting';
    }
    
    // Check timing
    final now = DateTime.now();
    final timeDiff = now.difference(createdAt);
    
    if (timeDiff.inMinutes < 10) {
      return 'Live sighting';
    } else if (timeDiff.inMinutes < 60) {
      return 'Recent sighting';
    }
    
    return 'Sighting';
  }
}