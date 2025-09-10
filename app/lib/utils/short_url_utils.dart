/// Short URL utilities for UFOBeep
/// The API now provides short URLs - mobile app uses the API response directly

/// Get short alert URL for sharing with language support
/// Uses the short_url provided by the API response
String getShortAlertUrl(String? shortUrl, {String locale = 'en'}) {
  if (shortUrl == null || shortUrl.isEmpty) {
    return '/'; // Fallback to home if no short URL available
  }
  
  // Return language-specific URL with optional locale suffix
  if (locale == 'en') {
    return '/$shortUrl';  // Default English: just /b4uux
  } else {
    return '/$shortUrl/$locale';  // Other languages: /b4uux/es
  }
}