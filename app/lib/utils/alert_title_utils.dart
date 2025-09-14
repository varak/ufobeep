import '../l10n/app_localizations.dart';
import '../models/enriched_alert.dart';
import '../models/api_models.dart';
import '../providers/alerts_provider.dart';

abstract class AlertTitleUtils {
  /// Generate dynamic title for mobile app using translations
  static String getDynamicTitle(AppLocalizations l10n, Alert alert) {
    // For MUFON cases, generate dynamic translated title
    if (alert.reporterUsername == 'MUFON') {
      final enrichment = alert.enrichment;
      final classification = enrichment?['classification'] as Map<String, dynamic>?;
      final type = classification?['type'] as String?;
      final confidence = (classification?['confidence'] as num?)?.toDouble() ?? 0.0;

      // If high confidence classification, use specific shape
      if (confidence >= 0.2 && type != null && type != 'unknown') {
        switch (type.toLowerCase()) {
          case 'sphere':
            return l10n.mufonSphereSighting;
          case 'disc':
            return l10n.mufonDiscSighting;
          case 'triangle':
            return l10n.mufonTriangleSighting;
          case 'light':
            return l10n.mufonLightSighting;
          case 'cigar':
            return l10n.mufonCigarSighting;
          case 'oval':
            return l10n.mufonOvalSighting;
          case 'rectangle':
            return l10n.mufonRectangleSighting;
          case 'cylinder':
            return l10n.mufonCylinderSighting;
          case 'boomerang':
            return l10n.mufonBoomerangSighting;
          case 'starlike':
            return l10n.mufonStarlikeSighting;
          default:
            return l10n.mufonSighting;
        }
      }
      // Low confidence - generic MUFON sighting
      return l10n.mufonSighting;
    }

    // Non-MUFON cases - use regular logic
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