import 'dart:io';

/// Wrapper for shared short URL generation
/// Uses the canonical implementation from shared/get_short_hash.js
/// Calls the single source of truth Node.js module

/// Generate a 4-character clean short ID from an input string.
/// Calls the shared/get_short_hash.js module to ensure consistency.
Future<String> generateCleanShortId(String input) async {
  if (input.isEmpty) throw ArgumentError('Input cannot be empty');
  
  // Call the shared Node.js module
  final result = await Process.run('node', ['shared/get_short_hash.js', input]);
  
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  } else {
    throw Exception('Error calling shared hash function: ${result.stderr}');
  }
}

/// Synchronous version for compatibility - not recommended
String generateCleanShortIdSync(String input) {
  if (input.isEmpty) throw ArgumentError('Input cannot be empty');
  
  // Call the shared Node.js module synchronously
  final result = Process.runSync('node', ['shared/get_short_hash.js', input]);
  
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  } else {
    throw Exception('Error calling shared hash function: ${result.stderr}');
  }
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