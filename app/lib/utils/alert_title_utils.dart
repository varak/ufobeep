import '../models/enriched_alert.dart';

class AlertTitleUtils {
  /// Generate a contextual title for an alert based on available data
  static String getContextualTitle(EnrichedAlert alert) {
    // If user provided a title, use it
    if (alert.title != null && alert.title!.isNotEmpty) {
      return alert.title!;
    }
    
    // If user provided description, use first few words as title
    if (alert.description != null && alert.description!.isNotEmpty) {
      final words = alert.description!.trim().split(' ');
      if (words.length <= 4) {
        return alert.description!;
      } else {
        return '${words.take(4).join(' ')}...';
      }
    }
    
    // Check if alert has media
    final hasMedia = alert.mediaFiles.isNotEmpty;
    
    // Generate contextual title based on available data
    if (hasMedia) {
      final hasPhoto = alert.mediaFiles.any((media) => 
        media.type.toLowerCase().contains('image') || 
        media.contentType.toLowerCase().contains('image'));
      final hasVideo = alert.mediaFiles.any((media) => 
        media.type.toLowerCase().contains('video') || 
        media.contentType.toLowerCase().contains('video'));
      
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
    final alertTime = alert.timestamp;
    final timeDiff = now.difference(alertTime);
    
    if (timeDiff.inMinutes < 60) {
      return 'Recent sighting';
    } else if (timeDiff.inHours < 24) {
      return 'Sighting today';
    }
    
    // Final fallback
    return 'UFO Sighting';
  }
  
  /// Get a short title for lists (more concise than contextual title)
  static String getShortTitle(EnrichedAlert alert) {
    // If user provided a title, use it
    if (alert.title != null && alert.title!.isNotEmpty) {
      return alert.title!;
    }
    
    // If user provided description, use first 3 words
    if (alert.description != null && alert.description!.isNotEmpty) {
      final words = alert.description!.trim().split(' ');
      if (words.length <= 3) {
        return alert.description!;
      } else {
        return '${words.take(3).join(' ')}...';
      }
    }
    
    // Check for media
    if (alert.mediaFiles.isNotEmpty) {
      return 'Visual sighting';
    }
    
    // Check timing
    final now = DateTime.now();
    final alertTime = alert.timestamp;
    final timeDiff = now.difference(alertTime);
    
    if (timeDiff.inMinutes < 10) {
      return 'Live sighting';
    } else if (timeDiff.inMinutes < 60) {
      return 'Recent sighting';
    }
    
    return 'UFO Sighting';
  }
}