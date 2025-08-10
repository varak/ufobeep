import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:typed_data';

import 'package:ufobeep/widgets/performance/virtual_list_view.dart';
import 'package:ufobeep/widgets/performance/optimized_image.dart';
import 'package:ufobeep/widgets/performance/lazy_widget_loader.dart';
import 'package:ufobeep/services/performance/performance_monitor.dart';
import 'package:ufobeep/services/performance/memory_optimizer.dart';
import 'package:ufobeep/providers/performance/optimized_providers.dart';

void main() {
  group('Performance Tests', () {
    setUp(() async {
      await PerformanceMonitorService.instance.initialize();
      await MemoryOptimizerService.instance.initialize();
    });

    tearDown(() {
      PerformanceMonitorService.instance.dispose();
      MemoryOptimizerService.instance.dispose();
    });

    group('Virtual List Performance', () {
      testWidgets('VirtualListView renders large lists efficiently', (tester) async {
        const itemCount = 10000;
        final items = List.generate(itemCount, (index) => 'Item $index');
        int builtItemCount = 0;

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: VirtualListView<String>(
                items: items,
                itemExtent: 50.0,
                itemBuilder: (context, index, item) {
                  builtItemCount++;
                  return Container(
                    height: 50,
                    child: Text(item),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();

        // Should only build visible items, not all 10000
        expect(builtItemCount, lessThan(100));
        expect(find.text('Item 0'), findsOneWidget);
      });

      testWidgets('OptimizedAlertListView handles large datasets', (tester) async {
        final alerts = List.generate(1000, (index) => MockAlert(
          id: 'alert_$index',
          title: 'Alert $index',
          description: 'Description for alert $index',
        ));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: OptimizedAlertListView<MockAlert>(
                alerts: alerts,
                alertBuilder: (context, index, alert) {
                  return ListTile(
                    title: Text(alert.title),
                    subtitle: Text(alert.description),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Verify initial render performance
        expect(find.byType(ListTile), findsWidgets);
        expect(find.text('Alert 0'), findsOneWidget);
      });
    });

    group('Image Loading Performance', () {
      testWidgets('OptimizedImage handles multiple images efficiently', (tester) async {
        final imageUrls = List.generate(20, (index) => 
            'https://picsum.photos/200/200?random=$index');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView.builder(
                itemCount: imageUrls.length,
                itemBuilder: (context, index) {
                  return OptimizedImage(
                    url: imageUrls[index],
                    width: 200,
                    height: 200,
                    placeholder: Container(
                      width: 200,
                      height: 200,
                      color: Colors.grey,
                    ),
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Should show placeholders initially
        expect(find.byType(Container), findsWidgets);
      });

      test('MemoryEfficientImage caches images properly', () async {
        final optimizer = MemoryOptimizerService.instance;
        final imageData = Uint8List.fromList([1, 2, 3, 4, 5]);
        
        // Cache image
        optimizer.cacheImageData('test_image', imageData);
        
        // Retrieve cached image
        final cached = optimizer.getCachedImageData('test_image');
        
        expect(cached, isNotNull);
        expect(cached, equals(imageData));
      });
    });

    group('Widget Loading Performance', () {
      testWidgets('LazyWidgetLoader defers widget creation', (tester) async {
        bool widgetFactoryCalled = false;
        
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: LazyWidgetLoader<Widget>(
                widgetFactory: () async {
                  widgetFactoryCalled = true;
                  await Future.delayed(const Duration(milliseconds: 100));
                  return const Text('Loaded Widget');
                },
                placeholder: const CircularProgressIndicator(),
              ),
            ),
          ),
        );

        // Initially should show placeholder
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(widgetFactoryCalled, isFalse);

        // Wait for widget to load
        await tester.pump(const Duration(milliseconds: 200));
        
        expect(widgetFactoryCalled, isTrue);
        expect(find.text('Loaded Widget'), findsOneWidget);
      });

      test('CodeSplittingManager manages widget loading', () async {
        final manager = CodeSplittingManager.instance;
        
        // Register widget factory
        manager.registerWidget<Widget>(
          'test_widget',
          () async => const Text('Test Widget'),
        );
        
        // Load widget
        final widget = await manager.loadWidget('test_widget');
        
        expect(widget, isA<Text>());
        expect(manager.isWidgetLoaded('test_widget'), isTrue);
      });
    });

    group('Memory Optimization', () {
      test('LRUCache evicts old entries', () {
        final cache = LRUCache<String, String>(3);
        
        cache.put('a', 'value_a');
        cache.put('b', 'value_b');
        cache.put('c', 'value_c');
        
        expect(cache.length, equals(3));
        
        // Add one more, should evict 'a'
        cache.put('d', 'value_d');
        
        expect(cache.length, equals(3));
        expect(cache.get('a'), isNull);
        expect(cache.get('d'), equals('value_d'));
      });

      test('ObjectPool reuses objects efficiently', () {
        final pool = ObjectPool<ByteData>(() => ByteData(1024), maxSize: 5);
        
        // Borrow and return objects
        final obj1 = pool.borrow() ?? ByteData(1024);
        final obj2 = pool.borrow() ?? ByteData(1024);
        
        pool.return(obj1);
        pool.return(obj2);
        
        expect(pool.size, equals(2));
        
        // Borrow again, should get recycled object
        final obj3 = pool.borrow();
        expect(obj3, isNotNull);
        expect(pool.size, equals(1));
      });

      test('MemoryOptimizerService tracks memory usage', () async {
        final optimizer = MemoryOptimizerService.instance;
        
        final usage = await optimizer.getCurrentMemoryUsage();
        
        expect(usage.heapUsed, greaterThanOrEqualTo(0));
        expect(usage.heapCapacity, greaterThanOrEqualTo(0));
        expect(usage.timestamp, isA<DateTime>());
      });
    });

    group('State Management Performance', () {
      test('MemoizedProvider caches expensive computations', () {
        final provider = MemoizedProvider<int>();
        int computationCount = 0;
        
        int expensiveComputation() {
          computationCount++;
          return 42;
        }
        
        // First call should compute
        final result1 = provider.getOrCompute('test', expensiveComputation);
        expect(result1, equals(42));
        expect(computationCount, equals(1));
        
        // Second call should use cache
        final result2 = provider.getOrCompute('test', expensiveComputation);
        expect(result2, equals(42));
        expect(computationCount, equals(1)); // No additional computation
      });

      test('OptimizedStateManager handles state updates efficiently', () {
        final manager = OptimizedStateManager<int>(0);
        final updates = <StateUpdate<int>>[];
        
        manager.updates.listen(updates.add);
        
        manager.updateState(1, reason: 'increment');
        manager.updateState(2, reason: 'increment');
        manager.updateState(3, reason: 'increment');
        
        expect(manager.state, equals(3));
        expect(updates.length, equals(3));
        expect(manager.history.length, equals(3));
        
        // Test undo
        final undoSuccess = manager.undo();
        expect(undoSuccess, isTrue);
        expect(manager.state, equals(2));
      });
    });

    group('Benchmark Tests', () {
      test('List rendering benchmark', () async {
        final result = await PerformanceBenchmark.run(
          name: 'list_rendering',
          benchmark: () async {
            // Simulate list rendering work
            final items = List.generate(1000, (i) => 'Item $i');
            final processed = items.map((item) => item.toUpperCase()).toList();
            expect(processed.length, equals(1000));
          },
          iterations: 10,
        );
        
        expect(result.iterations, equals(10));
        expect(result.averageDuration.inMilliseconds, lessThan(100));
      });

      test('Image processing benchmark', () async {
        final result = await PerformanceBenchmark.run(
          name: 'image_processing',
          benchmark: () async {
            final data = Uint8List(1024 * 1024); // 1MB
            for (int i = 0; i < data.length; i++) {
              data[i] = i % 256;
            }
          },
          iterations: 5,
        );
        
        expect(result.iterations, equals(5));
        expect(result.name, equals('image_processing'));
      });

      test('State update benchmark', () async {
        final manager = OptimizedStateManager<Map<String, dynamic>>({});
        
        final result = await PerformanceBenchmark.run(
          name: 'state_updates',
          benchmark: () async {
            for (int i = 0; i < 100; i++) {
              manager.updateState({'counter': i});
            }
          },
          iterations: 5,
        );
        
        expect(result.averageDuration.inMilliseconds, lessThan(50));
      });

      test('Performance comparison benchmark', () async {
        // Compare List.add vs List.addAll performance
        final comparison = await PerformanceBenchmark.compare(
          nameA: 'list_add',
          benchmarkA: () async {
            final list = <int>[];
            for (int i = 0; i < 1000; i++) {
              list.add(i);
            }
          },
          nameB: 'list_addAll',
          benchmarkB: () async {
            final list = <int>[];
            final batch = List.generate(1000, (i) => i);
            list.addAll(batch);
          },
          iterations: 10,
        );
        
        expect(comparison.resultA.name, equals('list_add'));
        expect(comparison.resultB.name, equals('list_addAll'));
        expect(comparison.winner, isA<String>());
      });
    });

    group('Performance Monitoring', () {
      test('PerformanceMonitorService tracks metrics', () async {
        final monitor = PerformanceMonitorService.instance;
        
        // Record some metrics
        monitor.recordMetric('test_metric', 42.5);
        monitor.incrementCounter('test_counter');
        
        final tracker = monitor.startTracker('test_operation');
        await Future.delayed(const Duration(milliseconds: 10));
        tracker.stop();
        
        expect(monitor.getCounter('test_counter'), equals(1));
        
        final summary = monitor.getSummary();
        expect(summary['is_monitoring'], isTrue);
        expect(summary['counters']['test_counter'], equals(1));
      });

      test('ProviderPerformanceMonitor tracks provider stats', () {
        ProviderPerformanceMonitor.recordRebuild('test_provider');
        ProviderPerformanceMonitor.recordAccess('test_provider');
        ProviderPerformanceMonitor.recordAccess('test_provider');
        
        final stats = ProviderPerformanceMonitor.getStats();
        final testProviderStats = stats['test_provider'];
        
        expect(testProviderStats['rebuilds'], equals(1));
        expect(testProviderStats['accesses'], equals(2));
        expect(testProviderStats['rebuild_rate'], equals(0.5));
      });
    });

    group('Integration Performance Tests', () {
      testWidgets('Complete alert list rendering performance', (tester) async {
        final alerts = List.generate(500, (index) => MockAlert(
          id: 'alert_$index',
          title: 'Performance Test Alert $index',
          description: 'Testing performance with alert $index',
        ));

        final stopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          ProviderScope(
            child: MaterialApp(
              home: Scaffold(
                body: OptimizedAlertListView<MockAlert>(
                  alerts: alerts,
                  alertBuilder: (context, index, alert) {
                    return Card(
                      child: ListTile(
                        leading: CircleAvatar(
                          child: Text('${index + 1}'),
                        ),
                        title: Text(alert.title),
                        subtitle: Text(alert.description),
                        trailing: const Icon(Icons.arrow_forward_ios),
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );

        await tester.pump();
        stopwatch.stop();

        // Should render quickly
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(find.byType(Card), findsWidgets);
      });

      testWidgets('Memory-efficient image grid performance', (tester) async {
        const imageCount = 50;
        final images = List.generate(imageCount, (index) => 
            'https://picsum.photos/150/150?random=$index');

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 4,
                  mainAxisSpacing: 4,
                ),
                itemCount: images.length,
                itemBuilder: (context, index) {
                  return MemoryEfficientImage(
                    url: images[index],
                    width: 150,
                    height: 150,
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
          ),
        );

        await tester.pump();
        
        // Should handle many images without performance issues
        expect(find.byType(MemoryEfficientImage), findsWidgets);
      });
    });
  });
}

/// Mock alert class for testing
class MockAlert {
  final String id;
  final String title;
  final String description;

  MockAlert({
    required this.id,
    required this.title,
    required this.description,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MockAlert &&
          runtimeType == other.runtimeType &&
          id == other.id;

  @override
  int get hashCode => id.hashCode;
}

/// Mock performance tracker for testing
class MockPerformanceTracker {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  
  MockPerformanceTracker(this.name) {
    _stopwatch.start();
  }
  
  void stop() {
    _stopwatch.stop();
  }
  
  Duration get elapsed => _stopwatch.elapsed;
}