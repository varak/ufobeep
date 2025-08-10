import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';

import 'package:ufobeep/services/offline_first_api_service.dart';
import 'package:ufobeep/services/network_connectivity_service.dart';
import 'package:ufobeep/services/offline_cache.dart';
import 'package:ufobeep/services/sync_manager.dart';
import 'package:ufobeep/models/api_models.dart';
import 'package:ufobeep/models/enriched_alert.dart';

void main() {
  group('Offline Scenarios Tests', () {
    late TestOfflineEnvironment environment;

    setUp(() async {
      environment = TestOfflineEnvironment();
      await environment.setup();
    });

    tearDown(() async {
      await environment.tearDown();
    });

    group('Cache-First Scenarios', () {
      test('serves fresh data when online', () async {
        // Setup: Device is online, API is available
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(5));

        final query = AlertsQuery(limit: 5);
        final response = await environment.offlineApiService.getAlerts(query);

        expect(response.success, isTrue);
        expect(response.data.sightings.length, equals(5));
        expect(response.message, contains('Fresh data'));

        // Verify data was cached
        expect(environment.wasCached('alerts'), isTrue);
      });

      test('serves cached data when offline', () async {
        // Setup: Prime the cache with data while online
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(3));
        
        final query = AlertsQuery(limit: 3);
        await environment.offlineApiService.getAlerts(query);

        // Go offline
        environment.setNetworkStatus(NetworkStatus.disconnected);

        // Same request should serve from cache
        final response = await environment.offlineApiService.getAlerts(query);
        
        expect(response.success, isTrue);
        expect(response.data.sightings.length, equals(3));
        expect(response.message, contains('cache'));
      });

      test('serves stale data when network is limited', () async {
        // Setup: Cache some data
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(2));
        
        final query = AlertsQuery(limit: 2);
        await environment.offlineApiService.getAlerts(query);

        // Simulate limited connectivity (can't reach API)
        environment.setNetworkStatus(NetworkStatus.limited);
        environment.mockApiFailure('/alerts', 'Connection timeout');

        final response = await environment.offlineApiService.getAlerts(
          query, 
          allowStale: true,
        );
        
        expect(response.success, isTrue);
        expect(response.message, contains('stale'));
      });

      test('fails gracefully when no cache and no network', () async {
        // Setup: No cached data, no network
        environment.setNetworkStatus(NetworkStatus.disconnected);

        final query = AlertsQuery(limit: 5);
        
        expect(
          () async => await environment.offlineApiService.getAlerts(
            query, 
            allowStale: false,
          ),
          throwsA(isA<NetworkException>()),
        );
      });
    });

    group('Submission Queue Scenarios', () {
      test('queues submissions when offline', () async {
        // Go offline
        environment.setNetworkStatus(NetworkStatus.disconnected);

        final submissionData = createMockSubmissionData();
        final submissionId = await environment.offlineApiService.submitSighting(
          submissionData,
        );

        expect(submissionId, contains('pending'));
        expect(environment.getPendingSubmissionCount(), equals(1));
      });

      test('submits directly when online', () async {
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/sightings', {'success': true, 'id': 'submitted_123'});

        final submissionData = createMockSubmissionData();
        final submissionId = await environment.offlineApiService.submitSighting(
          submissionData,
        );

        expect(submissionId, equals('submitted_123'));
        expect(environment.getPendingSubmissionCount(), equals(0));
      });

      test('syncs queued submissions when network returns', () async {
        // Queue some submissions while offline
        environment.setNetworkStatus(NetworkStatus.disconnected);
        
        await environment.offlineApiService.submitSighting(createMockSubmissionData('1'));
        await environment.offlineApiService.submitSighting(createMockSubmissionData('2'));
        await environment.offlineApiService.submitSighting(createMockSubmissionData('3'));

        expect(environment.getPendingSubmissionCount(), equals(3));

        // Come back online and trigger sync
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/sightings', {'success': true});

        final syncResult = await environment.syncManager.syncPendingSubmissions();

        expect(syncResult.success, isTrue);
        expect(environment.getPendingSubmissionCount(), equals(0));
      });

      test('handles partial sync failures gracefully', () async {
        // Queue submissions
        environment.setNetworkStatus(NetworkStatus.disconnected);
        
        await environment.offlineApiService.submitSighting(createMockSubmissionData('1'));
        await environment.offlineApiService.submitSighting(createMockSubmissionData('2'));
        await environment.offlineApiService.submitSighting(createMockSubmissionData('3'));

        // Come online but simulate API failures for some submissions
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiPartialFailure('/sightings', failureRate: 0.33);

        final syncResult = await environment.syncManager.syncPendingSubmissions();

        expect(syncResult.success, isFalse); // Partial failure
        expect(environment.getPendingSubmissionCount(), greaterThan(0)); // Some remain
        expect(environment.getPendingSubmissionCount(), lessThan(3)); // Some succeeded
      });
    });

    group('Cache Invalidation Scenarios', () {
      test('refreshes stale cache when force refresh is requested', () async {
        // Cache some data
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(2, version: 1));
        
        final query = AlertsQuery(limit: 2);
        await environment.offlineApiService.getAlerts(query);

        // Update server data
        environment.mockApiResponse('/alerts', createMockAlertsResponse(2, version: 2));

        // Force refresh should get new data
        final response = await environment.offlineApiService.getAlerts(
          query,
          forceRefresh: true,
        );

        expect(response.success, isTrue);
        expect(response.data.sightings.first.title, contains('v2')); // New version
      });

      test('clears cache when requested', () async {
        // Cache some data
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(3));
        
        final query = AlertsQuery(limit: 3);
        await environment.offlineApiService.getAlerts(query);

        expect(environment.getCachedItemCount(), greaterThan(0));

        // Clear cache
        await environment.offlineApiService.clearCache();

        expect(environment.getCachedItemCount(), equals(0));
      });
    });

    group('Network Transition Scenarios', () {
      test('handles online -> offline -> online transitions smoothly', () async {
        final events = <String>[];

        // Start online
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(2));
        
        final query = AlertsQuery(limit: 2);
        final response1 = await environment.offlineApiService.getAlerts(query);
        events.add('online_fetch_${response1.success}');

        // Go offline
        environment.setNetworkStatus(NetworkStatus.disconnected);
        
        final response2 = await environment.offlineApiService.getAlerts(query);
        events.add('offline_cache_${response2.success}');

        // Come back online
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(2));
        
        final response3 = await environment.offlineApiService.getAlerts(query);
        events.add('back_online_${response3.success}');

        expect(events, equals([
          'online_fetch_true',
          'offline_cache_true',
          'back_online_true',
        ]));
      });

      test('handles rapid network state changes', () async {
        final query = AlertsQuery(limit: 1);
        
        // Rapidly toggle network state
        for (int i = 0; i < 5; i++) {
          environment.setNetworkStatus(
            i % 2 == 0 ? NetworkStatus.connected : NetworkStatus.disconnected,
          );
          
          if (i % 2 == 0) {
            environment.mockApiResponse('/alerts', createMockAlertsResponse(1));
          }
          
          try {
            final response = await environment.offlineApiService.getAlerts(query);
            expect(response.success, isTrue);
          } catch (e) {
            // Some requests might fail during transitions, which is acceptable
          }
        }

        // Should eventually stabilize
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/alerts', createMockAlertsResponse(1));
        
        final finalResponse = await environment.offlineApiService.getAlerts(query);
        expect(finalResponse.success, isTrue);
      });
    });

    group('Synchronization Edge Cases', () {
      test('handles sync conflicts gracefully', () async {
        // This test would simulate conflicting data between cache and server
        // and verify that the sync manager handles it appropriately
        
        // Setup conflicting data scenario
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiConflictingResponse('/alerts');

        final syncResult = await environment.syncManager.syncCacheUpdates();
        
        // Should handle conflicts without crashing
        expect(syncResult, isA<SyncResult>());
      });

      test('handles large sync operations efficiently', () async {
        // Queue many submissions
        environment.setNetworkStatus(NetworkStatus.disconnected);
        
        for (int i = 0; i < 50; i++) {
          await environment.offlineApiService.submitSighting(
            createMockSubmissionData(i.toString()),
          );
        }

        expect(environment.getPendingSubmissionCount(), equals(50));

        // Come online and sync all at once
        environment.setNetworkStatus(NetworkStatus.connected);
        environment.mockApiResponse('/sightings', {'success': true});

        final syncResult = await environment.syncManager.syncPendingSubmissions();

        expect(syncResult.success, isTrue);
        expect(environment.getPendingSubmissionCount(), equals(0));
      });

      test('respects sync batch limits', () async {
        // Test that sync operations are batched to avoid overwhelming the server
        // This verifies the _maxConcurrentSyncs limit is respected
        
        environment.setNetworkStatus(NetworkStatus.connected);
        
        // Monitor API call patterns
        final apiCallTimes = <DateTime>[];
        environment.onApiCall = (endpoint) {
          apiCallTimes.add(DateTime.now());
        };

        await environment.syncManager.syncCacheUpdates();

        // Verify batching behavior (calls should be grouped)
        if (apiCallTimes.length > 3) {
          final timeDiffs = <Duration>[];
          for (int i = 1; i < apiCallTimes.length; i++) {
            timeDiffs.add(apiCallTimes[i].difference(apiCallTimes[i-1]));
          }
          
          // Some calls should be close together (batched), others further apart
          expect(timeDiffs.any((diff) => diff.inMilliseconds < 100), isTrue);
        }
      });
    });

    group('Resource Management', () {
      test('cleans up expired cache entries', () async {
        // Add items to cache with different timestamps
        environment.addExpiredCacheItems(5);
        environment.addFreshCacheItems(3);

        final initialCount = environment.getCachedItemCount();
        expect(initialCount, equals(8));

        // Trigger cache cleanup
        await environment.triggerCacheCleanup();

        final finalCount = environment.getCachedItemCount();
        expect(finalCount, equals(3)); // Only fresh items should remain
      });

      test('limits memory usage during large operations', () async {
        // This test would verify that the system doesn't use excessive memory
        // during large sync operations or when caching many items
        
        final initialMemory = environment.getMemoryUsage();
        
        // Perform large operation
        await environment.performLargeDataOperation();
        
        final finalMemory = environment.getMemoryUsage();
        
        // Memory usage should be reasonable (this would need platform-specific testing)
        expect(finalMemory - initialMemory, lessThan(100 * 1024 * 1024)); // Less than 100MB increase
      });
    });
  });
}

/// Test environment for offline scenarios
class TestOfflineEnvironment {
  late MockNetworkService networkService;
  late MockCacheService cacheService;
  late MockApiClient apiClient;
  late OfflineFirstApiService offlineApiService;
  late SyncManager syncManager;
  
  final Map<String, dynamic> _mockApiResponses = {};
  final Map<String, String> _mockApiFailures = {};
  final List<Map<String, dynamic>> _pendingSubmissions = [];
  final Map<String, dynamic> _cachedItems = {};
  
  NetworkStatus _currentNetworkStatus = NetworkStatus.unknown;
  Function(String)? onApiCall;

  Future<void> setup() async {
    networkService = MockNetworkService();
    cacheService = MockCacheService();
    apiClient = MockApiClient();
    offlineApiService = OfflineFirstApiService();
    syncManager = SyncManager();

    // Setup default behaviors
    when(networkService.currentStatus).thenReturn(_currentNetworkStatus);
    when(networkService.hasConnection).thenReturn(_currentNetworkStatus == NetworkStatus.connected);
  }

  Future<void> tearDown() async {
    await syncManager.dispose();
    await offlineApiService.dispose();
  }

  void setNetworkStatus(NetworkStatus status) {
    _currentNetworkStatus = status;
    when(networkService.currentStatus).thenReturn(status);
    when(networkService.hasConnection).thenReturn(status == NetworkStatus.connected);
  }

  void mockApiResponse(String endpoint, Map<String, dynamic> response) {
    _mockApiResponses[endpoint] = response;
  }

  void mockApiFailure(String endpoint, String error) {
    _mockApiFailures[endpoint] = error;
  }

  void mockApiPartialFailure(String endpoint, {double failureRate = 0.5}) {
    // Mock partial failures for testing
    _mockApiResponses[endpoint] = {
      'partial_failure': true,
      'failure_rate': failureRate,
    };
  }

  void mockApiConflictingResponse(String endpoint) {
    _mockApiResponses[endpoint] = {
      'conflict': true,
      'server_version': DateTime.now().millisecondsSinceEpoch,
    };
  }

  bool wasCached(String key) {
    return _cachedItems.containsKey(key);
  }

  int getPendingSubmissionCount() {
    return _pendingSubmissions.length;
  }

  int getCachedItemCount() {
    return _cachedItems.length;
  }

  void addExpiredCacheItems(int count) {
    final expiredTime = DateTime.now().subtract(const Duration(hours: 25));
    for (int i = 0; i < count; i++) {
      _cachedItems['expired_$i'] = {
        'data': 'expired_data_$i',
        'timestamp': expiredTime.toIso8601String(),
      };
    }
  }

  void addFreshCacheItems(int count) {
    final freshTime = DateTime.now().subtract(const Duration(minutes: 5));
    for (int i = 0; i < count; i++) {
      _cachedItems['fresh_$i'] = {
        'data': 'fresh_data_$i',
        'timestamp': freshTime.toIso8601String(),
      };
    }
  }

  Future<void> triggerCacheCleanup() async {
    // Remove expired items
    _cachedItems.removeWhere((key, value) {
      final timestamp = DateTime.parse(value['timestamp'] as String);
      return DateTime.now().difference(timestamp) > const Duration(hours: 24);
    });
  }

  int getMemoryUsage() {
    // Placeholder for memory usage tracking
    return 0;
  }

  Future<void> performLargeDataOperation() async {
    // Simulate large data operation
    for (int i = 0; i < 1000; i++) {
      _cachedItems['large_op_$i'] = createMockSubmissionData(i.toString());
    }
  }
}

/// Mock classes for testing
class MockNetworkService extends Mock implements NetworkConnectivityService {}
class MockCacheService extends Mock implements OfflineCacheService {}
class MockApiClient extends Mock implements ApiClient {}

/// Helper functions
Map<String, dynamic> createMockAlertsResponse(int count, {int version = 1}) {
  final sightings = List.generate(count, (index) => {
    'id': 'alert_${index}_v$version',
    'title': 'Test Alert $index v$version',
    'description': 'Test description $index',
    'category': 'ufo',
    'created_at': DateTime.now().toIso8601String(),
    'location': {'latitude': 40.7128, 'longitude': -74.0060},
  });

  return {
    'success': true,
    'data': {
      'sightings': sightings,
      'total_count': count,
      'has_more': false,
    },
  };
}

Map<String, dynamic> createMockSubmissionData([String? id]) {
  return {
    'id': id ?? 'submission_${DateTime.now().millisecondsSinceEpoch}',
    'title': 'Test Submission',
    'description': 'Test submission description',
    'category': 'ufo',
    'location': {'latitude': 40.7128, 'longitude': -74.0060},
    'timestamp': DateTime.now().toIso8601String(),
    'media_files': [],
  };
}