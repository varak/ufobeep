import 'dart:convert';
import 'dart:io';
import 'package:hive/hive.dart';
import 'package:path_provider/path_provider.dart';

import '../models/api_models.dart';
import '../models/alert_enrichment.dart';
import '../models/enriched_alert.dart';

/// Offline cache service for storing alerts and API responses
class OfflineCacheService {
  static const String _alertsCacheBox = 'alerts_cache';
  static const String _apiCacheBox = 'api_cache';
  static const String _metadataBox = 'cache_metadata';
  
  // Cache expiration times
  static const Duration _alertCacheExpiry = Duration(hours: 24);
  static const Duration _apiCacheExpiry = Duration(minutes: 30);
  
  Box<String>? _alertsBox;
  Box<String>? _apiBox;
  Box<String>? _metadataBox;
  
  bool _initialized = false;

  static final OfflineCacheService _instance = OfflineCacheService._internal();
  factory OfflineCacheService() => _instance;
  OfflineCacheService._internal();

  /// Initialize Hive and open boxes
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      // Get application documents directory
      final appDocDir = await getApplicationDocumentsDirectory();
      final cacheDir = Directory('${appDocDir.path}/cache');
      
      // Create cache directory if it doesn't exist
      if (!await cacheDir.exists()) {
        await cacheDir.create(recursive: true);
      }
      
      // Initialize Hive with cache directory
      Hive.init(cacheDir.path);
      
      // Open cache boxes
      _alertsBox = await Hive.openBox<String>(_alertsCacheBox);
      _apiBox = await Hive.openBox<String>(_apiCacheBox);
      _metadataBox = await Hive.openBox<String>(_metadataBox);
      
      _initialized = true;
      
      // Clean expired cache entries on startup
      await _cleanExpiredEntries();
    } catch (e) {
      print('Failed to initialize offline cache: $e');
      rethrow;
    }
  }

  /// Store alerts in offline cache
  Future<void> cacheAlerts(List<EnrichedAlert> alerts, {String? key}) async {
    await _ensureInitialized();
    
    final cacheKey = key ?? 'alerts_${DateTime.now().millisecondsSinceEpoch}';
    
    try {
      // Convert alerts to JSON
      final alertsJson = alerts.map((alert) => alert.toJson()).toList();
      final cacheData = {
        'data': alertsJson,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'alerts',
      };
      
      await _alertsBox!.put(cacheKey, jsonEncode(cacheData));
      await _updateCacheMetadata(cacheKey, CacheEntryType.alerts);
    } catch (e) {
      print('Failed to cache alerts: $e');
    }
  }

  /// Retrieve alerts from offline cache
  Future<List<EnrichedAlert>?> getCachedAlerts({String? key}) async {
    await _ensureInitialized();
    
    try {
      String? cacheKey = key;
      
      // If no key provided, get the most recent alerts cache
      if (cacheKey == null) {
        final metadata = await getCacheMetadata();
        final alertsEntries = metadata.entries
            .where((e) => e.value.type == CacheEntryType.alerts)
            .toList()
          ..sort((a, b) => b.value.timestamp.compareTo(a.value.timestamp));
        
        if (alertsEntries.isEmpty) return null;
        cacheKey = alertsEntries.first.key;
      }
      
      final cached = _alertsBox!.get(cacheKey);
      if (cached == null) return null;
      
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      
      // Check if cache has expired
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _alertCacheExpiry) {
        await _alertsBox!.delete(cacheKey);
        await _removeCacheMetadata(cacheKey);
        return null;
      }
      
      // Convert JSON back to EnrichedAlert objects
      final alertsJson = cacheData['data'] as List;
      final alerts = alertsJson
          .map((json) => EnrichedAlert.fromJson(json as Map<String, dynamic>))
          .toList();
      
      return alerts;
    } catch (e) {
      print('Failed to retrieve cached alerts: $e');
      return null;
    }
  }

  /// Cache API response
  Future<void> cacheApiResponse(
    String endpoint,
    Map<String, dynamic> response, {
    Duration? customExpiry,
  }) async {
    await _ensureInitialized();
    
    try {
      final cacheData = {
        'data': response,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'api_response',
        'endpoint': endpoint,
      };
      
      await _apiBox!.put(endpoint, jsonEncode(cacheData));
      await _updateCacheMetadata(
        endpoint, 
        CacheEntryType.apiResponse,
        customExpiry: customExpiry,
      );
    } catch (e) {
      print('Failed to cache API response for $endpoint: $e');
    }
  }

  /// Retrieve cached API response
  Future<Map<String, dynamic>?> getCachedApiResponse(String endpoint) async {
    await _ensureInitialized();
    
    try {
      final cached = _apiBox!.get(endpoint);
      if (cached == null) return null;
      
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      
      // Check if cache has expired
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      final metadata = await getCacheMetadata();
      final entryMetadata = metadata[endpoint];
      final expiry = entryMetadata?.customExpiry ?? _apiCacheExpiry;
      
      if (DateTime.now().difference(timestamp) > expiry) {
        await _apiBox!.delete(endpoint);
        await _removeCacheMetadata(endpoint);
        return null;
      }
      
      return cacheData['data'] as Map<String, dynamic>;
    } catch (e) {
      print('Failed to retrieve cached API response for $endpoint: $e');
      return null;
    }
  }

  /// Cache single alert
  Future<void> cacheSingleAlert(EnrichedAlert alert) async {
    await _ensureInitialized();
    
    try {
      final cacheKey = 'alert_${alert.id}';
      final cacheData = {
        'data': alert.toJson(),
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'single_alert',
        'alertId': alert.id,
      };
      
      await _alertsBox!.put(cacheKey, jsonEncode(cacheData));
      await _updateCacheMetadata(cacheKey, CacheEntryType.singleAlert);
    } catch (e) {
      print('Failed to cache single alert ${alert.id}: $e');
    }
  }

  /// Retrieve single cached alert
  Future<EnrichedAlert?> getCachedAlert(String alertId) async {
    await _ensureInitialized();
    
    try {
      final cacheKey = 'alert_$alertId';
      final cached = _alertsBox!.get(cacheKey);
      if (cached == null) return null;
      
      final cacheData = jsonDecode(cached) as Map<String, dynamic>;
      
      // Check if cache has expired
      final timestamp = DateTime.parse(cacheData['timestamp'] as String);
      if (DateTime.now().difference(timestamp) > _alertCacheExpiry) {
        await _alertsBox!.delete(cacheKey);
        await _removeCacheMetadata(cacheKey);
        return null;
      }
      
      return EnrichedAlert.fromJson(cacheData['data'] as Map<String, dynamic>);
    } catch (e) {
      print('Failed to retrieve cached alert $alertId: $e');
      return null;
    }
  }

  /// Store pending submissions (for offline sync)
  Future<void> cachePendingSubmission(Map<String, dynamic> submission) async {
    await _ensureInitialized();
    
    try {
      final submissionId = submission['id'] ?? 
          'submission_${DateTime.now().millisecondsSinceEpoch}';
      
      final cacheData = {
        'data': submission,
        'timestamp': DateTime.now().toIso8601String(),
        'type': 'pending_submission',
        'status': 'pending',
      };
      
      await _apiBox!.put('pending_$submissionId', jsonEncode(cacheData));
      await _updateCacheMetadata('pending_$submissionId', CacheEntryType.pendingSubmission);
    } catch (e) {
      print('Failed to cache pending submission: $e');
    }
  }

  /// Get all pending submissions
  Future<List<Map<String, dynamic>>> getPendingSubmissions() async {
    await _ensureInitialized();
    
    try {
      final metadata = await getCacheMetadata();
      final pendingEntries = metadata.entries
          .where((e) => e.value.type == CacheEntryType.pendingSubmission)
          .map((e) => e.key)
          .toList();
      
      final submissions = <Map<String, dynamic>>[];
      
      for (final key in pendingEntries) {
        final cached = _apiBox!.get(key);
        if (cached != null) {
          final cacheData = jsonDecode(cached) as Map<String, dynamic>;
          submissions.add(cacheData['data'] as Map<String, dynamic>);
        }
      }
      
      return submissions;
    } catch (e) {
      print('Failed to get pending submissions: $e');
      return [];
    }
  }

  /// Mark pending submission as synchronized
  Future<void> markSubmissionSynced(String submissionId) async {
    await _ensureInitialized();
    
    try {
      final key = 'pending_$submissionId';
      await _apiBox!.delete(key);
      await _removeCacheMetadata(key);
    } catch (e) {
      print('Failed to mark submission as synced: $e');
    }
  }

  /// Clear all cache data
  Future<void> clearAllCache() async {
    await _ensureInitialized();
    
    try {
      await _alertsBox!.clear();
      await _apiBox!.clear();
      await _metadataBox!.clear();
    } catch (e) {
      print('Failed to clear all cache: $e');
    }
  }

  /// Clear expired cache entries
  Future<void> _cleanExpiredEntries() async {
    try {
      final metadata = await getCacheMetadata();
      final now = DateTime.now();
      final expiredKeys = <String>[];
      
      for (final entry in metadata.entries) {
        final key = entry.key;
        final meta = entry.value;
        
        Duration expiry;
        switch (meta.type) {
          case CacheEntryType.alerts:
          case CacheEntryType.singleAlert:
            expiry = _alertCacheExpiry;
            break;
          case CacheEntryType.apiResponse:
            expiry = meta.customExpiry ?? _apiCacheExpiry;
            break;
          case CacheEntryType.pendingSubmission:
            continue; // Don't expire pending submissions
        }
        
        if (now.difference(meta.timestamp) > expiry) {
          expiredKeys.add(key);
        }
      }
      
      // Remove expired entries
      for (final key in expiredKeys) {
        if (metadata[key]!.type == CacheEntryType.apiResponse) {
          await _apiBox!.delete(key);
        } else {
          await _alertsBox!.delete(key);
        }
        await _removeCacheMetadata(key);
      }
      
      if (expiredKeys.isNotEmpty) {
        print('Cleaned ${expiredKeys.length} expired cache entries');
      }
    } catch (e) {
      print('Failed to clean expired cache entries: $e');
    }
  }

  /// Update cache metadata
  Future<void> _updateCacheMetadata(
    String key, 
    CacheEntryType type, {
    Duration? customExpiry,
  }) async {
    try {
      final metadata = CacheEntryMetadata(
        key: key,
        type: type,
        timestamp: DateTime.now(),
        customExpiry: customExpiry,
      );
      
      await _metadataBox!.put(key, jsonEncode(metadata.toJson()));
    } catch (e) {
      print('Failed to update cache metadata for $key: $e');
    }
  }

  /// Remove cache metadata
  Future<void> _removeCacheMetadata(String key) async {
    try {
      await _metadataBox!.delete(key);
    } catch (e) {
      print('Failed to remove cache metadata for $key: $e');
    }
  }

  /// Get all cache metadata
  Future<Map<String, CacheEntryMetadata>> getCacheMetadata() async {
    await _ensureInitialized();
    
    try {
      final metadata = <String, CacheEntryMetadata>{};
      
      for (final key in _metadataBox!.keys) {
        final cached = _metadataBox!.get(key);
        if (cached != null) {
          final data = jsonDecode(cached) as Map<String, dynamic>;
          metadata[key] = CacheEntryMetadata.fromJson(data);
        }
      }
      
      return metadata;
    } catch (e) {
      print('Failed to get cache metadata: $e');
      return {};
    }
  }

  /// Get cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    await _ensureInitialized();
    
    try {
      final metadata = await getCacheMetadata();
      int alertsCount = 0;
      int apiResponsesCount = 0;
      int pendingSubmissionsCount = 0;
      int expiredEntriesCount = 0;
      
      final now = DateTime.now();
      
      for (final meta in metadata.values) {
        Duration expiry;
        switch (meta.type) {
          case CacheEntryType.alerts:
          case CacheEntryType.singleAlert:
            alertsCount++;
            expiry = _alertCacheExpiry;
            break;
          case CacheEntryType.apiResponse:
            apiResponsesCount++;
            expiry = meta.customExpiry ?? _apiCacheExpiry;
            break;
          case CacheEntryType.pendingSubmission:
            pendingSubmissionsCount++;
            continue; // Don't count as expired
        }
        
        if (now.difference(meta.timestamp) > expiry) {
          expiredEntriesCount++;
        }
      }
      
      // Calculate storage sizes (approximate)
      final alertsBoxSize = _alertsBox?.length ?? 0;
      final apiBoxSize = _apiBox?.length ?? 0;
      
      return CacheStatistics(
        totalEntries: metadata.length,
        alertsCount: alertsCount,
        apiResponsesCount: apiResponsesCount,
        pendingSubmissionsCount: pendingSubmissionsCount,
        expiredEntriesCount: expiredEntriesCount,
        alertsBoxSize: alertsBoxSize,
        apiBoxSize: apiBoxSize,
        lastCleanup: now, // This would be tracked separately in a real implementation
      );
    } catch (e) {
      print('Failed to get cache statistics: $e');
      return const CacheStatistics();
    }
  }

  /// Ensure cache is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Dispose cache service
  Future<void> dispose() async {
    try {
      await _alertsBox?.close();
      await _apiBox?.close();
      await _metadataBox?.close();
      _initialized = false;
    } catch (e) {
      print('Failed to dispose cache service: $e');
    }
  }
}

/// Cache entry metadata
class CacheEntryMetadata {
  final String key;
  final CacheEntryType type;
  final DateTime timestamp;
  final Duration? customExpiry;

  const CacheEntryMetadata({
    required this.key,
    required this.type,
    required this.timestamp,
    this.customExpiry,
  });

  Map<String, dynamic> toJson() => {
    'key': key,
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'customExpiry': customExpiry?.inMilliseconds,
  };

  factory CacheEntryMetadata.fromJson(Map<String, dynamic> json) {
    return CacheEntryMetadata(
      key: json['key'] as String,
      type: CacheEntryType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => CacheEntryType.apiResponse,
      ),
      timestamp: DateTime.parse(json['timestamp'] as String),
      customExpiry: json['customExpiry'] != null 
          ? Duration(milliseconds: json['customExpiry'] as int)
          : null,
    );
  }
}

/// Cache entry types
enum CacheEntryType {
  alerts,
  singleAlert,
  apiResponse,
  pendingSubmission,
}

/// Cache statistics
class CacheStatistics {
  final int totalEntries;
  final int alertsCount;
  final int apiResponsesCount;
  final int pendingSubmissionsCount;
  final int expiredEntriesCount;
  final int alertsBoxSize;
  final int apiBoxSize;
  final DateTime lastCleanup;

  const CacheStatistics({
    this.totalEntries = 0,
    this.alertsCount = 0,
    this.apiResponsesCount = 0,
    this.pendingSubmissionsCount = 0,
    this.expiredEntriesCount = 0,
    this.alertsBoxSize = 0,
    this.apiBoxSize = 0,
    DateTime? lastCleanup,
  }) : lastCleanup = lastCleanup ?? const Duration().inMilliseconds != 0 
        ? const Duration().inMilliseconds != 0 
            ? DateTime.fromMillisecondsSinceEpoch(0) 
            : DateTime.fromMillisecondsSinceEpoch(0)
        : DateTime.fromMillisecondsSinceEpoch(0);

  Map<String, dynamic> toJson() => {
    'totalEntries': totalEntries,
    'alertsCount': alertsCount,
    'apiResponsesCount': apiResponsesCount,
    'pendingSubmissionsCount': pendingSubmissionsCount,
    'expiredEntriesCount': expiredEntriesCount,
    'alertsBoxSize': alertsBoxSize,
    'apiBoxSize': apiBoxSize,
    'lastCleanup': lastCleanup.toIso8601String(),
  };
}