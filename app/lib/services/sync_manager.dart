import 'dart:async';
import 'dart:convert';
import 'dart:math';
import 'package:flutter/foundation.dart';

import '../models/api_models.dart';
import '../models/enriched_alert.dart';
import 'api_client.dart';
import 'network_connectivity_service.dart';
import 'offline_cache.dart';
import 'retry_policy.dart';

/// Manages synchronization between local cache and remote API
class SyncManager {
  static final SyncManager _instance = SyncManager._internal();
  factory SyncManager() => _instance;
  SyncManager._internal();

  final NetworkConnectivityService _networkService = NetworkConnectivityService();
  final OfflineCacheService _cacheService = OfflineCacheService();
  final ApiClient _apiClient = ApiClient.instance;
  final EnhancedRetryHandler _retryHandler = EnhancedRetryHandler();

  // Sync state
  bool _initialized = false;
  bool _syncInProgress = false;
  Timer? _periodicSyncTimer;
  Timer? _backgroundSyncTimer;
  
  // Sync configuration
  static const Duration _periodicSyncInterval = Duration(minutes: 30);
  static const Duration _backgroundSyncInterval = Duration(minutes: 5);
  static const int _maxConcurrentSyncs = 3;
  static const int _maxRetryAttempts = 3;
  
  // Sync statistics
  final SyncStatistics _syncStats = SyncStatistics();
  
  // Event streams
  final StreamController<SyncEvent> _syncEventController = 
      StreamController<SyncEvent>.broadcast();
  final StreamController<SyncStatus> _syncStatusController = 
      StreamController<SyncStatus>.broadcast();

  /// Initialize the sync manager
  Future<void> initialize() async {
    if (_initialized) return;
    
    try {
      await _networkService.initialize();
      await _cacheService.initialize();
      
      _setupNetworkListener();
      _startPeriodicSync();
      _startBackgroundSync();
      
      _initialized = true;
      _updateSyncStatus(SyncStatus.idle);
    } catch (e) {
      print('Failed to initialize sync manager: $e');
      rethrow;
    }
  }

  /// Get sync event stream
  Stream<SyncEvent> get syncEventStream => _syncEventController.stream;
  
  /// Get sync status stream
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;
  
  /// Get current sync statistics
  SyncStatistics get syncStatistics => _syncStats;
  
  /// Check if sync is currently in progress
  bool get isSyncInProgress => _syncInProgress;

  /// Force a full synchronization
  Future<SyncResult> forceSync({
    bool syncPendingSubmissions = true,
    bool syncCacheUpdates = true,
    bool syncMetadata = false,
  }) async {
    if (!_initialized) {
      throw StateError('SyncManager not initialized');
    }
    
    if (_syncInProgress) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        timestamp: DateTime.now(),
      );
    }
    
    return await _performSync(
      syncPendingSubmissions: syncPendingSubmissions,
      syncCacheUpdates: syncCacheUpdates,
      syncMetadata: syncMetadata,
      isForced: true,
    );
  }

  /// Sync pending submissions to the server
  Future<SyncResult> syncPendingSubmissions() async {
    if (!_networkService.hasConnection) {
      return SyncResult(
        success: false,
        message: 'No network connection',
        timestamp: DateTime.now(),
      );
    }
    
    try {
      _updateSyncStatus(SyncStatus.syncing);
      _emitSyncEvent(SyncEventType.submissionSyncStarted);
      
      final pendingSubmissions = await _cacheService.getPendingSubmissions();
      
      if (pendingSubmissions.isEmpty) {
        _emitSyncEvent(SyncEventType.submissionSyncCompleted, 
            data: {'count': 0});
        return SyncResult(
          success: true,
          message: 'No pending submissions to sync',
          timestamp: DateTime.now(),
        );
      }
      
      int successCount = 0;
      int failureCount = 0;
      final errors = <String>[];
      
      // Process submissions with limited concurrency
      final batches = _createBatches(pendingSubmissions, _maxConcurrentSyncs);
      
      for (final batch in batches) {
        final futures = batch.map((submission) => _syncSingleSubmission(submission));
        final results = await Future.wait(futures, eagerError: false);
        
        for (int i = 0; i < results.length; i++) {
          final result = results[i];
          if (result.success) {
            successCount++;
            await _cacheService.markSubmissionSynced(batch[i]['id'] as String);
          } else {
            failureCount++;
            errors.add(result.message ?? 'Unknown error');
          }
        }
      }
      
      _syncStats.recordSubmissionSync(successCount, failureCount);
      _emitSyncEvent(SyncEventType.submissionSyncCompleted, data: {
        'success': successCount,
        'failures': failureCount,
      });
      
      final allSuccess = failureCount == 0;
      return SyncResult(
        success: allSuccess,
        message: allSuccess 
            ? 'All $successCount submissions synced successfully'
            : '$successCount synced, $failureCount failed',
        timestamp: DateTime.now(),
        details: {'errors': errors},
      );
    } catch (e) {
      _emitSyncEvent(SyncEventType.syncError, data: {'error': e.toString()});
      return SyncResult(
        success: false,
        message: 'Sync failed: $e',
        timestamp: DateTime.now(),
      );
    } finally {
      _updateSyncStatus(SyncStatus.idle);
    }
  }

  /// Sync cache updates from server
  Future<SyncResult> syncCacheUpdates({List<String>? specificAlerts}) async {
    if (!_networkService.hasConnection) {
      return SyncResult(
        success: false,
        message: 'No network connection',
        timestamp: DateTime.now(),
      );
    }
    
    try {
      _updateSyncStatus(SyncStatus.syncing);
      _emitSyncEvent(SyncEventType.cacheSyncStarted);
      
      int updatedCount = 0;
      final errors = <String>[];
      
      if (specificAlerts != null) {
        // Sync specific alerts
        for (final alertId in specificAlerts) {
          try {
            final result = await _syncSingleAlert(alertId);
            if (result.success) {
              updatedCount++;
            } else {
              errors.add('${alertId}: ${result.message}');
            }
          } catch (e) {
            errors.add('${alertId}: $e');
          }
        }
      } else {
        // Sync all cached alerts
        final cacheMetadata = await _cacheService.getCacheMetadata();
        final alertKeys = cacheMetadata.keys
            .where((key) => key.startsWith('alert_'))
            .toList();
        
        // Process in batches to avoid overwhelming the server
        final batches = _createBatches(alertKeys, _maxConcurrentSyncs);
        
        for (final batch in batches) {
          final futures = batch.map((key) {
            final alertId = key.replaceFirst('alert_', '');
            return _syncSingleAlert(alertId);
          });
          
          final results = await Future.wait(futures, eagerError: false);
          
          for (int i = 0; i < results.length; i++) {
            final result = results[i];
            if (result.success) {
              updatedCount++;
            } else {
              errors.add('${batch[i]}: ${result.message}');
            }
          }
        }
      }
      
      _syncStats.recordCacheSync(updatedCount, errors.length);
      _emitSyncEvent(SyncEventType.cacheSyncCompleted, data: {
        'updated': updatedCount,
        'failures': errors.length,
      });
      
      final allSuccess = errors.isEmpty;
      return SyncResult(
        success: allSuccess,
        message: allSuccess
            ? '$updatedCount alerts updated successfully'
            : '$updatedCount updated, ${errors.length} failed',
        timestamp: DateTime.now(),
        details: {'errors': errors},
      );
    } catch (e) {
      _emitSyncEvent(SyncEventType.syncError, data: {'error': e.toString()});
      return SyncResult(
        success: false,
        message: 'Cache sync failed: $e',
        timestamp: DateTime.now(),
      );
    } finally {
      _updateSyncStatus(SyncStatus.idle);
    }
  }

  /// Sync a single submission
  Future<SyncResult> _syncSingleSubmission(Map<String, dynamic> submission) async {
    final submissionId = submission['id'] as String;
    
    try {
      return await _retryHandler.executeWithRetry(
        operationName: 'syncSubmission_$submissionId',
        operation: () async {
          // Convert cached submission to API format
          // This is a placeholder - would need actual API call
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Simulate API call success
          return SyncResult(
            success: true,
            message: 'Submission synced successfully',
            timestamp: DateTime.now(),
          );
        },
        policy: RetryPolicy.aggressivePolicy,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Sync a single alert
  Future<SyncResult> _syncSingleAlert(String alertId) async {
    try {
      return await _retryHandler.executeWithRetry(
        operationName: 'syncAlert_$alertId',
        operation: () async {
          final response = await _apiClient.getAlertDetails(alertId);
          
          if (response['success'] == true && response['data'] != null) {
            final sightingData = response['data'] as Map<String, dynamic>;
            final sighting = Sighting.fromJson(sightingData);
            final enrichedAlert = EnrichedAlert.fromSighting(sighting);
            
            // Update cache with fresh data
            await _cacheService.cacheSingleAlert(enrichedAlert);
            
            return SyncResult(
              success: true,
              message: 'Alert updated successfully',
              timestamp: DateTime.now(),
            );
          } else {
            return SyncResult(
              success: false,
              message: 'Failed to fetch alert from server',
              timestamp: DateTime.now(),
            );
          }
        },
        policy: RetryPolicy.quickPolicy,
      );
    } catch (e) {
      return SyncResult(
        success: false,
        message: e.toString(),
        timestamp: DateTime.now(),
      );
    }
  }

  /// Perform comprehensive sync
  Future<SyncResult> _performSync({
    bool syncPendingSubmissions = true,
    bool syncCacheUpdates = true,
    bool syncMetadata = false,
    bool isForced = false,
  }) async {
    if (_syncInProgress && !isForced) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        timestamp: DateTime.now(),
      );
    }
    
    _syncInProgress = true;
    _updateSyncStatus(SyncStatus.syncing);
    
    try {
      final results = <SyncResult>[];
      
      // Sync pending submissions first
      if (syncPendingSubmissions) {
        final submissionResult = await syncPendingSubmissions();
        results.add(submissionResult);
      }
      
      // Sync cache updates
      if (syncCacheUpdates) {
        final cacheResult = await syncCacheUpdates();
        results.add(cacheResult);
      }
      
      // Sync metadata if requested
      if (syncMetadata) {
        final metadataResult = await _syncMetadata();
        results.add(metadataResult);
      }
      
      // Aggregate results
      final allSuccessful = results.every((r) => r.success);
      final messages = results.map((r) => r.message ?? 'Unknown').toList();
      
      _syncStats.recordFullSync(allSuccessful);
      
      return SyncResult(
        success: allSuccessful,
        message: allSuccessful 
            ? 'Full sync completed successfully'
            : 'Sync completed with errors: ${messages.join(', ')}',
        timestamp: DateTime.now(),
        details: {'results': results.map((r) => r.toJson()).toList()},
      );
    } catch (e) {
      _emitSyncEvent(SyncEventType.syncError, data: {'error': e.toString()});
      return SyncResult(
        success: false,
        message: 'Full sync failed: $e',
        timestamp: DateTime.now(),
      );
    } finally {
      _syncInProgress = false;
      _updateSyncStatus(SyncStatus.idle);
    }
  }

  /// Sync metadata (placeholder)
  Future<SyncResult> _syncMetadata() async {
    // Placeholder for metadata synchronization
    // This could include user preferences, settings, etc.
    return SyncResult(
      success: true,
      message: 'Metadata sync not implemented',
      timestamp: DateTime.now(),
    );
  }

  /// Setup network connectivity listener
  void _setupNetworkListener() {
    _networkService.networkStatusStream.listen((status) {
      if (status == NetworkStatus.connected) {
        _onNetworkReconnected();
      }
    });
  }

  /// Handle network reconnection
  void _onNetworkReconnected() {
    // Trigger a sync when network comes back
    if (!_syncInProgress) {
      _performSync(isForced: false);
    }
  }

  /// Start periodic sync timer
  void _startPeriodicSync() {
    _periodicSyncTimer = Timer.periodic(_periodicSyncInterval, (_) {
      if (_networkService.hasConnection && !_syncInProgress) {
        _performSync();
      }
    });
  }

  /// Start background sync timer (more frequent, lighter operations)
  void _startBackgroundSync() {
    _backgroundSyncTimer = Timer.periodic(_backgroundSyncInterval, (_) {
      if (_networkService.hasConnection && !_syncInProgress) {
        // Only sync pending submissions in background
        syncPendingSubmissions();
      }
    });
  }

  /// Stop all sync timers
  void _stopSyncTimers() {
    _periodicSyncTimer?.cancel();
    _backgroundSyncTimer?.cancel();
  }

  /// Create batches from list for concurrent processing
  List<List<T>> _createBatches<T>(List<T> items, int batchSize) {
    final batches = <List<T>>[];
    for (int i = 0; i < items.length; i += batchSize) {
      final end = min(i + batchSize, items.length);
      batches.add(items.sublist(i, end));
    }
    return batches;
  }

  /// Update sync status and notify listeners
  void _updateSyncStatus(SyncStatus status) {
    _syncStatusController.add(status);
  }

  /// Emit sync event
  void _emitSyncEvent(SyncEventType type, {Map<String, dynamic>? data}) {
    _syncEventController.add(SyncEvent(
      type: type,
      timestamp: DateTime.now(),
      data: data,
    ));
  }

  /// Dispose the sync manager
  Future<void> dispose() async {
    _stopSyncTimers();
    await _syncEventController.close();
    await _syncStatusController.close();
  }
}

/// Sync result data class
class SyncResult {
  final bool success;
  final String? message;
  final DateTime timestamp;
  final Map<String, dynamic>? details;

  const SyncResult({
    required this.success,
    this.message,
    required this.timestamp,
    this.details,
  });

  Map<String, dynamic> toJson() => {
    'success': success,
    'message': message,
    'timestamp': timestamp.toIso8601String(),
    'details': details,
  };
}

/// Sync event data class
class SyncEvent {
  final SyncEventType type;
  final DateTime timestamp;
  final Map<String, dynamic>? data;

  const SyncEvent({
    required this.type,
    required this.timestamp,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'type': type.name,
    'timestamp': timestamp.toIso8601String(),
    'data': data,
  };
}

/// Sync event types
enum SyncEventType {
  syncStarted,
  syncCompleted,
  syncError,
  submissionSyncStarted,
  submissionSyncCompleted,
  cacheSyncStarted,
  cacheSyncCompleted,
  metadataSyncStarted,
  metadataSyncCompleted,
}

/// Sync status enumeration
enum SyncStatus {
  idle,
  syncing,
  error,
  paused,
}

/// Sync statistics tracking
class SyncStatistics {
  int _totalSyncs = 0;
  int _successfulSyncs = 0;
  int _failedSyncs = 0;
  int _submissionsSynced = 0;
  int _submissionsFailed = 0;
  int _alertsUpdated = 0;
  int _alertUpdatesFailed = 0;
  DateTime? _lastSyncTime;
  DateTime? _lastSuccessfulSyncTime;

  // Getters
  int get totalSyncs => _totalSyncs;
  int get successfulSyncs => _successfulSyncs;
  int get failedSyncs => _failedSyncs;
  int get submissionsSynced => _submissionsSynced;
  int get submissionsFailed => _submissionsFailed;
  int get alertsUpdated => _alertsUpdated;
  int get alertUpdatesFailed => _alertUpdatesFailed;
  DateTime? get lastSyncTime => _lastSyncTime;
  DateTime? get lastSuccessfulSyncTime => _lastSuccessfulSyncTime;

  double get successRate => _totalSyncs > 0 ? _successfulSyncs / _totalSyncs : 0.0;

  void recordFullSync(bool success) {
    _totalSyncs++;
    _lastSyncTime = DateTime.now();
    
    if (success) {
      _successfulSyncs++;
      _lastSuccessfulSyncTime = DateTime.now();
    } else {
      _failedSyncs++;
    }
  }

  void recordSubmissionSync(int success, int failures) {
    _submissionsSynced += success;
    _submissionsFailed += failures;
  }

  void recordCacheSync(int success, int failures) {
    _alertsUpdated += success;
    _alertUpdatesFailed += failures;
  }

  Map<String, dynamic> toJson() => {
    'totalSyncs': _totalSyncs,
    'successfulSyncs': _successfulSyncs,
    'failedSyncs': _failedSyncs,
    'submissionsSynced': _submissionsSynced,
    'submissionsFailed': _submissionsFailed,
    'alertsUpdated': _alertsUpdated,
    'alertUpdatesFailed': _alertUpdatesFailed,
    'successRate': successRate,
    'lastSyncTime': _lastSyncTime?.toIso8601String(),
    'lastSuccessfulSyncTime': _lastSuccessfulSyncTime?.toIso8601String(),
  };
}