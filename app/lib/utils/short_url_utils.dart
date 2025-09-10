/// Wrapper for shared short URL generation
/// Uses the exact same algorithm as shared/get_short_hash.js
/// CRITICAL: This implementation must match JavaScript exactly for consistency

const String _safeChars = '23456789abcdefghjkmnpqrstuvwxyz';

/// Generate a 4-character clean short ID from an input string.
/// This is a faithful Dart port of the canonical shared/get_short_hash.js implementation.
/// CRITICAL: The algorithm must never change to maintain URL consistency.
String generateCleanShortId(String input) {
  if (input.isEmpty) return '';
  
  // Generate hash using the exact shared algorithm
  // CRITICAL: Use 32-bit signed integer math exactly like JavaScript
  int hash = 0;
  for (int i = 0; i < input.length; i++) {
    final char = input.codeUnitAt(i);
    hash = ((hash << 5) - hash) + char;
    
    // CRITICAL: Convert to 32-bit signed integer like JavaScript
    // JavaScript: hash = hash & hash (32-bit conversion)
    // Dart equivalent: Force to signed 32-bit range
    hash = (hash << 32) >> 32; // Force 32-bit signed integer
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
  // Use synchronous version for immediate response
  final cleanShortId = generateCleanShortIdSync(alertId);
  
  // Return language-specific URL
  if (locale == 'en') {
    return '/$cleanShortId';  // Default English: just /ehf3
  } else {
    return '/$cleanShortId/$locale';  // Other languages: /ehf3/es
  }
}

/// Get short alert URL for sharing (async version)
Future<String> getShortAlertUrlAsync(String alertId, {String locale = 'en'}) async {
  // Generate clean 4-character URL for sharing with language support
  final cleanShortId = await generateCleanShortId(alertId);
  
  // Return language-specific URL
  if (locale == 'en') {
    return '/$cleanShortId';  // Default English: just /ehf3
  } else {
    return '/$cleanShortId/$locale';  // Other languages: /ehf3/es
  }
}