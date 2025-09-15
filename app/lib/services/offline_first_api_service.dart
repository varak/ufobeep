import 'dart:async';
import 'dart:convert';
import 'package:dio/dio.dart';

import '../models/api_models.dart';
import '../models/enriched_alert.dart';
import 'api_client.dart';
import 'network_connectivity_service.dart';
import 'offline_cache.dart';
import 'retry_policy.dart';

/// Offline-first API service that handles caching and synchronization
class OfflineFirstApiService {
  static final OfflineFirstApiService _instance = OfflineFirstApiService._internal();
  factory OfflineFirstApiService() => _instance;
  OfflineFirstApiService._internal();

  final ApiClient _apiClient = ApiClient.instance;
  final NetworkConnectivityService _networkService = NetworkConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  final EnhancedRetryHandler _retryHandler = EnhancedRetryHandler();

  bool _initialized = false;
  Timer? _syncTimer;
  
  // Sync configuration
  static const Duration _backgroundSyncInterval = Duration(minutes: 15);
  static const Duration _cacheValidityPeriod = Duration(hours: 1);

  /// Initialize the offline-first API service
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _networkService.initialize();
      await _cacheService.initialize();
      
      _startBackgroundSync();
      _initialized = true;
    } catch (e) {
      print('Failed to initialize offline-first API service: $e');
      rethrow;
    }
  }

  /// Get alerts with offline-first approach
  Future<AlertsResponse> getAlerts(AlertsQuery query, {
    bool forceRefresh = false,
    bool allowStale = true,
  }) async {
    await _ensureInitialized();
    
    try {
      // Generate cache key based on query parameters
      final cacheKey = _generateAlertsCacheKey(query);
      
      // Try to get from cache first (if not forcing refresh)
      if (!forceRefresh) {
        final cachedAlerts = await _cacheService.getCachedAlerts(key: cacheKey);
        if (cachedAlerts != null && cachedAlerts.isNotEmpty) {
          print('Serving ${cachedAlerts.length} alerts from cache');
          return _createAlertsResponse(cachedAlerts, fromCache: true);
        }
      }
      
      // If we have network connection, try to fetch fresh data
      if (_networkService.hasConnection) {
        return await _retryHandler.executeWithRetry<AlertsResponse>(
          operationName: 'getAlerts',
          operation: () async {
            final response = await _apiClient.getAlerts(query);
            
            if (response.success) {
              // Convert sightings to enriched alerts
              final enrichedAlerts = response.data.sightings
                  .map((sighting) => EnrichedAlert.fromSighting(sighting))
                  .toList();
              
              // Cache the fresh data
              await _cacheService.cacheAlerts(enrichedAlerts, key: cacheKey);
              
              return _createAlertsResponse(enrichedAlerts, fromCache: false);
            } else {
              throw ApiClientException(response.message ?? 'Failed to fetch alerts');
            }
          },
          policy: RetryPolicy.defaultPolicy,
        );
      } else {
        // No network connection, try to serve stale cache if allowed
        if (allowStale) {
          final staleAlerts = await _cacheService.getCachedAlerts(key: cacheKey);
          if (staleAlerts != null && staleAlerts.isNotEmpty) {
            print('Serving ${staleAlerts.length} stale alerts from cache (offline)');
            return _createAlertsResponse(staleAlerts, fromCache: true, isStale: true);
          }
        }
        
        throw NetworkException('No network connection and no cached data available');
      }
    } catch (e) {
      print('Error in getAlerts: $e');
      
      // Last resort: try to serve any cached data
      if (allowStale) {
        final cacheKey = _generateAlertsCacheKey(query);
        final cachedAlerts = await _cacheService.getCachedAlerts(key: cacheKey);
        if (cachedAlerts != null && cachedAlerts.isNotEmpty) {
          print('Serving cached alerts as fallback');
          return _createAlertsResponse(cachedAlerts, fromCache: true, isStale: true);
        }
      }
      
      rethrow;
    }
  }

  /// Get single alert with offline-first approach
  Future<EnrichedAlert?> getAlert(String alertId, {
    bool forceRefresh = false,
    bool allowStale = true,
  }) async {
    await _ensureInitialized();
    
    try {
      // Try cache first (if not forcing refresh)
      if (!forceRefresh) {
        final cachedAlert = await _cacheService.getCachedAlert(alertId);
        if (cachedAlert != null) {
          return cachedAlert;
        }
      }
      
      // If we have network connection, try to fetch from API
      if (_networkService.hasConnection) {
        return await _retryHandler.executeWithRetry<EnrichedAlert?>(
          operationName: 'getAlert',
          operation: () async {
            final response = await _apiClient.getAlertDetails(alertId);
            
            if (response['success'] == true && response['data'] != null) {
              final sightingData = response['data'] as Map<String, dynamic>;
              final sighting = Sighting.fromJson(sightingData);
              final enrichedAlert = EnrichedAlert.fromSighting(sighting);
              
              // Cache the fresh data
              await _cacheService.cacheSingleAlert(enrichedAlert);
              
              return enrichedAlert;
            }
            return null;
          },
          policy: RetryPolicy.quickPolicy,
        );
      } else {
        // No network connection, return stale cache if allowed
        if (allowStale) {
          return await _cacheService.getCachedAlert(alertId);
        }
        
        throw NetworkException('No network connection and no cached data available');
      }
    } catch (e) {
      print('Error in getAlert: $e');
      
      // Fallback to cached data
      if (allowStale) {
        return await _cacheService.getCachedAlert(alertId);
      }
      
      rethrow;
    }
  }

  /// Submit sighting with offline support
  Future<String> submitSighting(Map<String, dynamic> sightingData, {
    bool requiresConnection = false,
  }) async {
    await _ensureInitialized();
    
    try {
      if (_networkService.hasConnection) {
        // Try to submit directly if online
        return await _retryHandler.executeWithRetry<String>(
          operationName: 'submitSighting',
          operation: () async {
            // This would use the actual API client submission method
            // For now, simulate the submission
            final submissionId = 'sighting_${DateTime.now().millisecondsSinceEpoch}';
            
            // In a real implementation, this would call:
            // final response = await _apiClient.submitSighting(submission);
            // return response.data['sighting_id'] as String;
            
            return submissionId;
          },
          policy: RetryPolicy.conservativePolicy,
        );
      } else {
        if (requiresConnection) {
          throw NetworkException('Network connection required for sighting submission');
        }
        
        // Store for offline sync
        await _cachePendingSubmission(sightingData);
        
        // Return a temporary ID
        final tempId = 'pending_${DateTime.now().millisecondsSinceEpoch}';
        return tempId;
      }
    } catch (e) {
      if (!requiresConnection) {
        // Fallback to offline storage
        await _cachePendingSubmission(sightingData);
        return 'pending_${DateTime.now().millisecondsSinceEpoch}';
      }
      rethrow;
    }
  }

  /// Cache API response for offline use
  Future<void> cacheApiResponse(String endpoint, Map<String, dynamic> response) async {
    await _ensureInitialized();
    await _cacheService.cacheApiResponse(endpoint, response);
  }

  /// Get cached API response
  Future<Map<String, dynamic>?> getCachedApiResponse(String endpoint) async {
    await _ensureInitialized();
    return await _cacheService.getCachedApiResponse(endpoint);
  }

  /// Sync pending submissions when online
  Future<void> syncPendingSubmissions() async {
    await _ensureInitialized();
    
    if (!_networkService.hasConnection) {
      print('Cannot sync pending submissions: no network connection');
      return;
    }
    
    try {
      final pendingSubmissions = await _cacheService.getPendingSubmissions();
      
      if (pendingSubmissions.isEmpty) {
        print('No pending submissions to sync');
        return;
      }
      
      print('Syncing ${pendingSubmissions.length} pending submissions');
      
      for (final submission in pendingSubmissions) {
        try {
          await _retryHandler.executeWithRetry(
            operationName: 'syncSubmission',
            operation: () async {
              // In a real implementation, this would submit the cached data
              // For now, just simulate success
              await Future.delayed(const Duration(milliseconds: 500));
              
              final submissionId = submission['id'] as String? ?? 
                  'unknown_${DateTime.now().millisecondsSinceEpoch}';
              
              // Mark as synced
              await _cacheService.markSubmissionSynced(submissionId);
            },
            policy: RetryPolicy.aggressivePolicy,
          );
        } catch (e) {
          print('Failed to sync submission ${submission['id']}: $e');
          // Continue with other submissions
        }
      }
    } catch (e) {
      print('Error syncing pending submissions: $e');
    }
  }

  /// Force refresh alerts from API
  Future<void> refreshAlerts(AlertsQuery query) async {
    await getAlerts(query, forceRefresh: true);
  }

  /// Check if data is available offline
  Future<bool> hasOfflineData(AlertsQuery query) async {
    await _ensureInitialized();
    
    final cacheKey = _generateAlertsCacheKey(query);
    final cachedAlerts = await _cacheService.getCachedAlerts(key: cacheKey);
    
    return cachedAlerts != null && cachedAlerts.isNotEmpty;
  }

  /// Get offline cache statistics
  Future<CacheStatistics> getCacheStatistics() async {
    await _ensureInitialized();
    return await _cacheService.getCacheStatistics();
  }

  /// Clear offline cache
  Future<void> clearCache() async {
    await _ensureInitialized();
    await _cacheService.clearAllCache();
  }

  /// Helper: Generate cache key for alerts query
  String _generateAlertsCacheKey(AlertsQuery query) {
    final keyData = {
      'centerLat': query.centerLat?.toStringAsFixed(4),
      'centerLng': query.centerLng?.toStringAsFixed(4),
      'radiusKm': query.radiusKm?.toString(),
      'category': query.category?.toString(),
      'minAlertLevel': query.minAlertLevel?.toString(),
      'verifiedOnly': query.verifiedOnly.toString(),
      'limit': query.limit.toString(),
    };
    
    // Remove null values and create a hash-like key
    final cleanedData = keyData..removeWhere((key, value) => value == null);
    final keyString = cleanedData.entries
        .map((e) => '${e.key}=${e.value}')
        .join('&');
    
    return 'alerts_${keyString.hashCode.abs()}';
  }

  /// Helper: Create AlertsResponse from enriched alerts
  AlertsResponse _createAlertsResponse(
    List<EnrichedAlert> enrichedAlerts, {
    bool fromCache = false,
    bool isStale = false,
  }) {
    // Convert enriched alerts back to sightings for the response
    final sightings = enrichedAlerts.map((alert) => alert.sighting).toList();
    
    final alertsData = AlertsData(
      sightings: sightings,
      totalCount: sightings.length,
      offset: 0,
      limit: sightings.length,
      hasMore: false,
    );
    
    return AlertsResponse(
      success: true,
      message: fromCache 
          ? (isStale ? 'Served from stale cache' : 'Served from cache')
          : 'Fresh data from API',
      timestamp: DateTime.now(),
      data: alertsData,
    );
  }

  /// Helper: Cache pending submission
  Future<void> _cachePendingSubmission(Map<String, dynamic> sightingData) async {
    final submission = {
      ...sightingData,
      'id': sightingData['id'] ?? 'submission_${DateTime.now().millisecondsSinceEpoch}',
      'cached_at': DateTime.now().toIso8601String(),
      'status': 'pending_sync',
    };
    
    await _cacheService.cachePendingSubmission(submission);
  }

  /// Start background sync timer
  void _startBackgroundSync() {
    _syncTimer = Timer.periodic(_backgroundSyncInterval, (_) async {
      if (_networkService.hasConnection) {
        await syncPendingSubmissions();
      }
    });
  }

  /// Stop background sync
  void _stopBackgroundSync() {
    _syncTimer?.cancel();
    _syncTimer = null;
  }

  /// Ensure service is initialized
  Future<void> _ensureInitialized() async {
    if (!_initialized) {
      await initialize();
    }
  }

  /// Dispose the service
  Future<void> dispose() async {
    _stopBackgroundSync();
    await _cacheService.dispose();
    await _networkService.dispose();
  }
}

/// Network exception for offline scenarios
class NetworkException implements Exception {
  final String message;
  NetworkException(this.message);

  @override
  String toString() => 'NetworkException: $message';
}

/// Offline-first service extensions
extension OfflineFirstApiServiceExtension on OfflineFirstApiService {
  /// Execute operation with automatic fallback to cache
  Future<T> executeWithFallback<T>({
    required String operationName,
    required Future<T> Function() onlineOperation,
    required Future<T?> Function() cacheOperation,
    required T fallbackValue,
  }) async {
    await _ensureInitialized();
    
    try {
      if (_networkService.hasConnection) {
        return await _retryHandler.executeWithRetry<T>(
          operationName: operationName,
          operation: onlineOperation,
          policy: RetryPolicy.defaultPolicy,
        );
      }
    } catch (e) {
      print('Online operation failed: $e');
    }
    
    // Try cache fallback
    try {
      final cached = await cacheOperation();
      if (cached != null) return cached;
    } catch (e) {
      print('Cache operation failed: $e');
    }
    
    return fallbackValue;
  }

  /// Prefetch data for offline use
  Future<void> prefetchForOffline(List<AlertsQuery> queries) async {
    if (!_networkService.hasConnection) {
      print('Cannot prefetch: no network connection');
      return;
    }
    
    for (final query in queries) {
      try {
        await getAlerts(query, forceRefresh: true);
        print('Prefetched alerts for query: ${_generateAlertsCacheKey(query)}');
      } catch (e) {
        print('Failed to prefetch alerts: $e');
      }
    }
  }

  /// Check if service is operating in offline mode
  bool get isOfflineMode => !_networkService.hasConnection;
  
  /// Get service status
  Map<String, dynamic> get serviceStatus => {
    'initialized': _initialized,
    'hasConnection': _networkService.hasConnection,
    'connectionType': _networkService.currentConnectivity.map((c) => c.toString()).toList(),
    'networkStatus': _networkService.currentStatus.toString(),
  };
}