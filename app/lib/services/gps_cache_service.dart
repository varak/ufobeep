import 'dart:async';

class GPSCacheService {
  static final GPSCacheService _instance = GPSCacheService._internal();
  factory GPSCacheService() => _instance;
  GPSCacheService._internal();

  static GPSCacheService get I => _instance;

  Map<String, double>? _cachedGPS;
  DateTime? _cacheTime;
  static const Duration _cacheValidDuration = Duration(minutes: 5); // GPS valid for 5 minutes

  /// Cache GPS coordinates
  void cacheGPS(Map<String, double> coordinates) {
    _cachedGPS = Map.from(coordinates);
    _cacheTime = DateTime.now();
    print('📍 GPS Cache: Stored coordinates: ${coordinates['lat']}, ${coordinates['lon']}');
  }

  /// Get cached GPS if still valid
  Map<String, double>? getCachedGPS() {
    if (_cachedGPS == null || _cacheTime == null) {
      print('📍 GPS Cache: No cached GPS available');
      return null;
    }

    final age = DateTime.now().difference(_cacheTime!);
    if (age > _cacheValidDuration) {
      print('📍 GPS Cache: Cached GPS expired (${age.inMinutes} minutes old)');
      _cachedGPS = null;
      _cacheTime = null;
      return null;
    }

    print('📍 GPS Cache: Using cached GPS (${age.inSeconds}s old): ${_cachedGPS!['lat']}, ${_cachedGPS!['lon']}');
    return Map.from(_cachedGPS!);
  }

  /// Check if cached GPS is available and valid
  bool hasCachedGPS() {
    return getCachedGPS() != null;
  }

  /// Clear cached GPS
  void clearCache() {
    _cachedGPS = null;
    _cacheTime = null;
    print('📍 GPS Cache: Cleared');
  }
}