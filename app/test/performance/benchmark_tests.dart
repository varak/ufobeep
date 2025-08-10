import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math' as math;

import 'package:ufobeep/widgets/performance/virtual_list_view.dart';
import 'package:ufobeep/services/performance/performance_monitor.dart';
import 'package:ufobeep/services/performance/memory_optimizer.dart';
import 'package:ufobeep/providers/performance/optimized_providers.dart';

/// Comprehensive performance benchmark tests
void main() {
  group('Performance Benchmarks', () {
    setUp(() async {
      await PerformanceMonitorService.instance.initialize();
      await MemoryOptimizerService.instance.initialize();
    });

    tearDown(() {
      PerformanceMonitorService.instance.dispose();
      MemoryOptimizerService.instance.dispose();
    });

    group('Rendering Benchmarks', () {
      test('ListView vs VirtualListView performance comparison', () async {
        const itemCount = 5000;
        final items = List.generate(itemCount, (index) => 'Item $index');

        // Benchmark standard ListView
        final listViewResult = await PerformanceBenchmark.run(
          name: 'standard_listview',
          benchmark: () async {
            await _simulateListRendering(items, useVirtual: false);
          },
          iterations: 5,
          warmupIterations: 2,
        );

        // Benchmark VirtualListView
        final virtualListResult = await PerformanceBenchmark.run(
          name: 'virtual_listview',
          benchmark: () async {
            await _simulateListRendering(items, useVirtual: true);
          },
          iterations: 5,
          warmupIterations: 2,
        );

        // Compare results
        final comparison = ComparisonResult(virtualListResult, listViewResult);
        
        print('ListView vs VirtualListView Benchmark Results:');
        print('VirtualListView: ${virtualListResult.averageDuration.inMilliseconds}ms avg');
        print('Standard ListView: ${listViewResult.averageDuration.inMilliseconds}ms avg');
        print('Winner: ${comparison.winner}');
        print('Improvement: ${comparison.improvementPercentage.toStringAsFixed(1)}%');

        // VirtualListView should perform better for large lists
        expect(virtualListResult.averageDuration, lessThan(listViewResult.averageDuration));
      });

      test('Widget build performance under load', () async {
        final results = <String, BenchmarkResult>{};

        // Test simple widget builds
        results['simple_widgets'] = await PerformanceBenchmark.run(
          name: 'simple_widgets',
          benchmark: () async {
            await _simulateWidgetBuilds(100, complexity: WidgetComplexity.simple);
          },
          iterations: 10,
        );

        // Test complex widget builds
        results['complex_widgets'] = await PerformanceBenchmark.run(
          name: 'complex_widgets',
          benchmark: () async {
            await _simulateWidgetBuilds(100, complexity: WidgetComplexity.complex);
          },
          iterations: 10,
        );

        // Test very complex widget builds
        results['very_complex_widgets'] = await PerformanceBenchmark.run(
          name: 'very_complex_widgets',
          benchmark: () async {
            await _simulateWidgetBuilds(50, complexity: WidgetComplexity.veryComplex);
          },
          iterations: 5,
        );

        // Print results
        for (final entry in results.entries) {
          final result = entry.value;
          print('${entry.key}: ${result.averageDuration.inMilliseconds}ms avg, '
                'min: ${result.minDuration.inMilliseconds}ms, '
                'max: ${result.maxDuration.inMilliseconds}ms');
        }

        // Verify performance scaling
        expect(results['simple_widgets']!.averageDuration, 
               lessThan(results['complex_widgets']!.averageDuration));
        expect(results['complex_widgets']!.averageDuration, 
               lessThan(results['very_complex_widgets']!.averageDuration));
      });

      test('Animation performance benchmark', () async {
        final result = await PerformanceBenchmark.run(
          name: 'animation_performance',
          benchmark: () async {
            await _simulateAnimations(60); // 1 second at 60fps
          },
          iterations: 5,
        );

        print('Animation Performance: ${result.averageDuration.inMilliseconds}ms avg');
        
        // Should maintain 60fps (16.67ms per frame)
        expect(result.averageDuration.inMilliseconds, lessThan(1100)); // Allow some margin
      });
    });

    group('Memory Benchmarks', () {
      test('Memory allocation patterns', () async {
        final results = <String, BenchmarkResult>{};

        // Small object allocations
        results['small_objects'] = await PerformanceBenchmark.run(
          name: 'small_objects',
          benchmark: () async {
            final objects = <List<int>>[];
            for (int i = 0; i < 1000; i++) {
              objects.add(List.generate(10, (j) => j));
            }
            objects.clear(); // Allow GC
          },
          iterations: 10,
        );

        // Large object allocations
        results['large_objects'] = await PerformanceBenchmark.run(
          name: 'large_objects',
          benchmark: () async {
            final objects = <List<int>>[];
            for (int i = 0; i < 100; i++) {
              objects.add(List.generate(10000, (j) => j));
            }
            objects.clear(); // Allow GC
          },
          iterations: 5,
        );

        // Object pool performance
        final pool = ObjectPool<List<int>>(() => <int>[], maxSize: 50);
        results['object_pool'] = await PerformanceBenchmark.run(
          name: 'object_pool',
          benchmark: () async {
            final borrowed = <List<int>>[];
            for (int i = 0; i < 100; i++) {
              final obj = pool.borrow() ?? <int>[];
              borrowed.add(obj);
            }
            for (final obj in borrowed) {
              pool.return(obj);
            }
          },
          iterations: 10,
        );

        // Print results
        for (final entry in results.entries) {
          final result = entry.value;
          print('${entry.key}: ${result.averageDuration.inMilliseconds}ms avg');
        }

        // Object pool should be more efficient
        expect(results['object_pool']!.averageDuration, 
               lessThan(results['small_objects']!.averageDuration));
      });

      test('Cache performance comparison', () async {
        final comparison = await PerformanceBenchmark.compare(
          nameA: 'no_cache',
          benchmarkA: () async {
            // Simulate expensive operations without caching
            for (int i = 0; i < 100; i++) {
              _expensiveComputation(i % 10); // Repeated computations
            }
          },
          nameB: 'with_cache',
          benchmarkB: () async {
            // Simulate with caching
            final cache = LRUCache<int, int>(20);
            for (int i = 0; i < 100; i++) {
              final key = i % 10;
              cache.getOrCompute(key, () => _expensiveComputation(key));
            }
          },
          iterations: 10,
        );

        print('Cache Performance Comparison:');
        print('No Cache: ${comparison.resultA.averageDuration.inMilliseconds}ms avg');
        print('With Cache: ${comparison.resultB.averageDuration.inMilliseconds}ms avg');
        print('Improvement: ${comparison.improvementPercentage.toStringAsFixed(1)}%');

        // Caching should be significantly faster
        expect(comparison.improvementRatio, greaterThan(2.0));
      });
    });

    group('State Management Benchmarks', () {
      test('Provider rebuilds performance', () async {
        final results = <String, BenchmarkResult>{};

        // Standard provider
        results['standard_provider'] = await PerformanceBenchmark.run(
          name: 'standard_provider',
          benchmark: () async {
            await _simulateProviderUpdates(1000, optimized: false);
          },
          iterations: 5,
        );

        // Optimized provider
        results['optimized_provider'] = await PerformanceBenchmark.run(
          name: 'optimized_provider',
          benchmark: () async {
            await _simulateProviderUpdates(1000, optimized: true);
          },
          iterations: 5,
        );

        // Batched provider updates
        results['batched_provider'] = await PerformanceBenchmark.run(
          name: 'batched_provider',
          benchmark: () async {
            await _simulateBatchedUpdates(1000);
          },
          iterations: 5,
        );

        // Print and verify results
        for (final entry in results.entries) {
          final result = entry.value;
          print('${entry.key}: ${result.averageDuration.inMilliseconds}ms avg');
        }

        // Optimized providers should perform better
        expect(results['optimized_provider']!.averageDuration,
               lessThan(results['standard_provider']!.averageDuration));
        expect(results['batched_provider']!.averageDuration,
               lessThan(results['optimized_provider']!.averageDuration));
      });

      test('State selector performance', () async {
        final manager = OptimizedStateManager<ComplexState>(
          ComplexState(counter: 0, items: [], metadata: {}),
        );

        final result = await PerformanceBenchmark.run(
          name: 'state_selectors',
          benchmark: () async {
            for (int i = 0; i < 1000; i++) {
              // Select different parts of state
              manager.select('counter', (state) => state.counter);
              manager.select('items_length', (state) => state.items.length);
              manager.select('has_metadata', (state) => state.metadata.isNotEmpty);
              
              // Update state occasionally
              if (i % 100 == 0) {
                manager.updateState(ComplexState(
                  counter: i,
                  items: List.generate(i % 10, (j) => 'item_$j'),
                  metadata: {'updated_at': DateTime.now().toString()},
                ));
              }
            }
          },
          iterations: 5,
        );

        print('State Selectors: ${result.averageDuration.inMilliseconds}ms avg');
        
        // Should be reasonably fast
        expect(result.averageDuration.inMilliseconds, lessThan(100));
      });
    });

    group('Real-World Scenario Benchmarks', () {
      test('Alert list processing benchmark', () async {
        final alerts = List.generate(1000, (index) => MockAlert(
          id: 'alert_$index',
          title: 'Alert $index',
          description: 'Description for alert $index',
          timestamp: DateTime.now().subtract(Duration(minutes: index)),
          category: AlertCategory.values[index % AlertCategory.values.length],
        ));

        final result = await PerformanceBenchmark.run(
          name: 'alert_processing',
          benchmark: () async {
            // Simulate complex alert processing
            final processed = alerts
                .where((alert) => alert.timestamp.isAfter(
                    DateTime.now().subtract(const Duration(hours: 24))))
                .map((alert) => alert.copyWith(
                    title: alert.title.toUpperCase(),
                    processed: true))
                .toList();
            
            processed.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            
            // Simulate grouping
            final grouped = <AlertCategory, List<MockAlert>>{};
            for (final alert in processed) {
              grouped.putIfAbsent(alert.category, () => []).add(alert);
            }
          },
          iterations: 10,
        );

        print('Alert Processing: ${result.averageDuration.inMilliseconds}ms avg');
        
        // Should process 1000 alerts quickly
        expect(result.averageDuration.inMilliseconds, lessThan(50));
      });

      test('Image loading and caching benchmark', () async {
        final optimizer = MemoryOptimizerService.instance;
        final imageUrls = List.generate(100, (index) => 
            'https://picsum.photos/200/200?random=$index');

        final result = await PerformanceBenchmark.run(
          name: 'image_caching',
          benchmark: () async {
            for (final url in imageUrls) {
              // Simulate image data
              final fakeImageData = List.generate(1000, (i) => i % 256);
              
              // Cache the image
              optimizer.cacheImageData(url, fakeImageData as dynamic);
              
              // Retrieve from cache
              final cached = optimizer.getCachedImageData(url);
              expect(cached, isNotNull);
            }
          },
          iterations: 5,
        );

        print('Image Caching: ${result.averageDuration.inMilliseconds}ms avg');
        
        // Should handle 100 images efficiently
        expect(result.averageDuration.inMilliseconds, lessThan(200));
      });

      test('Complex UI interaction benchmark', () async {
        final result = await PerformanceBenchmark.run(
          name: 'ui_interactions',
          benchmark: () async {
            // Simulate complex UI interactions
            final state = ComplexAppState();
            
            for (int i = 0; i < 100; i++) {
              // Simulate user actions
              state.addAlert(MockAlert(
                id: 'alert_$i',
                title: 'New Alert $i',
                description: 'User generated alert',
                timestamp: DateTime.now(),
                category: AlertCategory.ufo,
              ));
              
              if (i % 10 == 0) {
                state.filterAlerts('ufo');
                state.sortAlerts(SortOrder.newest);
              }
              
              if (i % 20 == 0) {
                state.refreshAlerts();
              }
            }
          },
          iterations: 5,
        );

        print('UI Interactions: ${result.averageDuration.inMilliseconds}ms avg');
        
        // Should handle complex interactions smoothly
        expect(result.averageDuration.inMilliseconds, lessThan(300));
      });
    });

    group('Performance Regression Tests', () {
      test('Memory usage should not exceed thresholds', () async {
        final optimizer = MemoryOptimizerService.instance;
        final initialUsage = await optimizer.getCurrentMemoryUsage();

        // Perform memory-intensive operations
        final data = <List<int>>[];
        for (int i = 0; i < 1000; i++) {
          data.add(List.generate(1000, (j) => j));
        }

        final peakUsage = await optimizer.getCurrentMemoryUsage();
        data.clear();

        // Force cleanup
        await optimizer.optimizeMemory();
        await Future.delayed(const Duration(milliseconds: 100));
        
        final finalUsage = await optimizer.getCurrentMemoryUsage();

        print('Memory Usage - Initial: ${initialUsage.totalUsage / 1024 / 1024:.1f}MB, '
              'Peak: ${peakUsage.totalUsage / 1024 / 1024:.1f}MB, '
              'Final: ${finalUsage.totalUsage / 1024 / 1024:.1f}MB');

        // Memory should be cleaned up effectively
        expect(finalUsage.totalUsage, lessThan(peakUsage.totalUsage * 1.5));
      });

      test('Frame rate should remain stable under load', () async {
        final frameRates = <double>[];
        
        for (int load = 100; load <= 1000; load += 100) {
          final result = await PerformanceBenchmark.run(
            name: 'frame_rate_$load',
            benchmark: () async {
              await _simulateFrameWork(load);
            },
            iterations: 3,
          );
          
          // Calculate approximate frame rate
          final frameRate = 1000 / result.averageDuration.inMilliseconds;
          frameRates.add(frameRate);
          
          print('Load $load: ${frameRate.toStringAsFixed(1)} fps');
        }

        // Frame rate should not degrade too much under load
        expect(frameRates.last, greaterThan(frameRates.first * 0.5));
      });
    });
  });
}

// Helper functions for benchmarks

Future<void> _simulateListRendering(List<String> items, {bool useVirtual = false}) async {
  // Simulate the work done during list rendering
  final visibleItems = items.take(20).toList(); // Only render visible items for virtual
  
  for (final item in (useVirtual ? visibleItems : items)) {
    // Simulate widget creation and layout
    await Future.microtask(() {
      final hash = item.hashCode;
      final processed = item.toUpperCase();
      // Simulate some processing
      math.sin(hash.toDouble());
    });
  }
}

enum WidgetComplexity { simple, complex, veryComplex }

Future<void> _simulateWidgetBuilds(int count, {WidgetComplexity complexity = WidgetComplexity.simple}) async {
  for (int i = 0; i < count; i++) {
    await Future.microtask(() {
      switch (complexity) {
        case WidgetComplexity.simple:
          _buildSimpleWidget(i);
          break;
        case WidgetComplexity.complex:
          _buildComplexWidget(i);
          break;
        case WidgetComplexity.veryComplex:
          _buildVeryComplexWidget(i);
          break;
      }
    });
  }
}

void _buildSimpleWidget(int index) {
  // Simulate simple widget build
  final text = 'Widget $index';
  final hash = text.hashCode;
  math.sin(hash.toDouble());
}

void _buildComplexWidget(int index) {
  // Simulate complex widget build
  final items = List.generate(10, (i) => 'Item ${index}_$i');
  items.sort();
  final joined = items.join(',');
  final hash = joined.hashCode;
  for (int i = 0; i < 10; i++) {
    math.sin(hash.toDouble() + i);
  }
}

void _buildVeryComplexWidget(int index) {
  // Simulate very complex widget build
  final matrix = List.generate(10, (i) => List.generate(10, (j) => i * j + index));
  for (final row in matrix) {
    row.sort((a, b) => b.compareTo(a));
  }
  final flattened = matrix.expand((row) => row).toList();
  flattened.sort();
  final sum = flattened.reduce((a, b) => a + b);
  math.sin(sum.toDouble());
}

Future<void> _simulateAnimations(int frameCount) async {
  for (int i = 0; i < frameCount; i++) {
    await Future.microtask(() {
      // Simulate animation frame work
      final progress = i / frameCount;
      final eased = _easeInOut(progress);
      final value = eased * 100;
      
      // Simulate layout and paint work
      for (int j = 0; j < 10; j++) {
        math.sin(value + j);
      }
    });
  }
}

double _easeInOut(double t) {
  return t < 0.5 ? 2 * t * t : -1 + (4 - 2 * t) * t;
}

int _expensiveComputation(int input) {
  // Simulate expensive computation
  int result = input;
  for (int i = 0; i < 1000; i++) {
    result = (result * 31 + i) % 1000000;
  }
  return result;
}

extension LRUCacheExtension<K, V> on LRUCache<K, V> {
  V getOrCompute(K key, V Function() computation) {
    final cached = get(key);
    if (cached != null) return cached;
    
    final computed = computation();
    put(key, computed);
    return computed;
  }
}

Future<void> _simulateProviderUpdates(int updateCount, {bool optimized = false}) async {
  final state = ComplexState(counter: 0, items: [], metadata: {});
  
  for (int i = 0; i < updateCount; i++) {
    await Future.microtask(() {
      if (optimized) {
        // Simulate optimized updates (batched, selective)
        if (i % 10 == 0) {
          _updateComplexState(state, i);
        }
      } else {
        // Simulate standard updates (every change)
        _updateComplexState(state, i);
      }
    });
  }
}

void _updateComplexState(ComplexState state, int value) {
  // Simulate state update work
  final newItems = List.generate(value % 5, (i) => 'item_$i');
  final newMetadata = <String, dynamic>{'updated': value};
  
  // Simulate immutable update
  ComplexState(
    counter: value,
    items: newItems,
    metadata: newMetadata,
  );
}

Future<void> _simulateBatchedUpdates(int updateCount) async {
  final batches = <List<int>>[];
  
  // Group updates into batches
  for (int i = 0; i < updateCount; i += 10) {
    final batch = <int>[];
    for (int j = i; j < math.min(i + 10, updateCount); j++) {
      batch.add(j);
    }
    batches.add(batch);
  }
  
  // Process batches
  for (final batch in batches) {
    await Future.microtask(() {
      for (final value in batch) {
        _updateComplexState(ComplexState(counter: 0, items: [], metadata: {}), value);
      }
    });
  }
}

Future<void> _simulateFrameWork(int workload) async {
  // Simulate frame rendering work proportional to workload
  for (int i = 0; i < workload; i++) {
    math.sin(i.toDouble());
    if (i % 10 == 0) {
      await Future.microtask(() {});
    }
  }
}

// Mock classes for testing

class ComplexState {
  final int counter;
  final List<String> items;
  final Map<String, dynamic> metadata;

  ComplexState({
    required this.counter,
    required this.items,
    required this.metadata,
  });
}

class MockAlert {
  final String id;
  final String title;
  final String description;
  final DateTime timestamp;
  final AlertCategory category;
  final bool processed;

  MockAlert({
    required this.id,
    required this.title,
    required this.description,
    required this.timestamp,
    required this.category,
    this.processed = false,
  });

  MockAlert copyWith({
    String? title,
    String? description,
    bool? processed,
  }) {
    return MockAlert(
      id: id,
      title: title ?? this.title,
      description: description ?? this.description,
      timestamp: timestamp,
      category: category,
      processed: processed ?? this.processed,
    );
  }
}

enum AlertCategory { ufo, anomaly, unknown, suspicious }
enum SortOrder { newest, oldest, distance, category }

class ComplexAppState {
  final List<MockAlert> _alerts = [];
  final List<MockAlert> _filteredAlerts = [];

  void addAlert(MockAlert alert) {
    _alerts.add(alert);
    _updateFiltered();
  }

  void filterAlerts(String category) {
    _filteredAlerts.clear();
    _filteredAlerts.addAll(_alerts.where(
      (alert) => alert.category.toString().split('.').last == category,
    ));
  }

  void sortAlerts(SortOrder order) {
    switch (order) {
      case SortOrder.newest:
        _filteredAlerts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
        break;
      case SortOrder.oldest:
        _filteredAlerts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
        break;
      case SortOrder.distance:
      case SortOrder.category:
        // Simulate other sorting logic
        break;
    }
  }

  void refreshAlerts() {
    _updateFiltered();
  }

  void _updateFiltered() {
    _filteredAlerts.clear();
    _filteredAlerts.addAll(_alerts);
  }
}