/// Shared utility for generating short URLs consistently across platforms.
/// This is the single source of truth for short URL generation.
/// 
/// Characters safe for short IDs (excludes O,I,L,0,1,o,l,i for clarity)
const String _safeChars = '23456789abcdefghjkmnpqrstuvwxyz';

/// Generate a 4-character clean short ID from an input string.
/// This matches the web implementation exactly for consistency.
String generateCleanShortId(String input) {
  // Generate a 4-character clean ID from input string
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    final char = input.codeUnitAt(i);
    hash = ((hash << 5) - hash) + char;
    hash = hash & hash; // Convert to 32-bit integer
  }
  
  // Convert hash to base-29 using safe characters
  String shortId = '';
  int num = hash.abs();
  
  for (int i = 0; i < 4; i++) {
    shortId = _safeChars[num % _safeChars.length] + shortId;
    num = num ~/ _safeChars.length;
  }
  
  return shortId;
}

/// Get short alert URL for sharing with language support
String getShortAlertUrl(String alertId, {String locale = 'en'}) {
  // Generate clean 4-character URL for sharing with language support
  final cleanShortId = generateCleanShortId(alertId);
  
  // Return language-specific URL
  if (locale == 'en') {
    return '/$cleanShortId';  // Default English: just /ehf3
  } else {
    return '/$cleanShortId/$locale';  // Other languages: /ehf3/es
  }
}