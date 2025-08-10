import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:isolate';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';

/// Comprehensive performance monitoring service
class PerformanceMonitorService {
  static final PerformanceMonitorService _instance = PerformanceMonitorService._();
  static PerformanceMonitorService get instance => _instance;

  PerformanceMonitorService._();

  final StreamController<PerformanceMetric> _metricsController = 
      StreamController<PerformanceMetric>.broadcast();
  
  final Queue<PerformanceMetric> _metricsBuffer = Queue();
  final Map<String, PerformanceTracker> _trackers = {};
  final Map<String, int> _counters = {};
  
  Timer? _reportingTimer;
  Timer? _gcTimer;
  bool _isMonitoring = false;
  int _frameCount = 0;
  Duration _totalFrameTime = Duration.zero;
  List<Duration> _frameTimes = [];
  
  // Configuration
  static const int _maxBufferSize = 1000;
  static const Duration _reportingInterval = Duration(seconds: 10);
  static const int _maxFrameTimeHistory = 60; // Keep last 60 frame times

  /// Initialize performance monitoring
  Future<void> initialize() async {
    if (_isMonitoring) return;
    
    try {
      _setupFrameCallback();
      _setupMemoryMonitoring();
      _setupTimingMetrics();
      _startReporting();
      
      _isMonitoring = true;
      debugPrint('Performance monitoring initialized');
    } catch (e) {
      debugPrint('Failed to initialize performance monitoring: $e');
    }
  }

  /// Get metrics stream
  Stream<PerformanceMetric> get metricsStream => _metricsController.stream;

  /// Start a performance tracker
  PerformanceTracker startTracker(String name) {
    final tracker = PerformanceTracker._(name);
    _trackers[name] = tracker;
    return tracker;
  }

  /// Record a custom metric
  void recordMetric(String name, double value, {String? unit}) {
    final metric = PerformanceMetric(
      name: name,
      value: value,
      unit: unit ?? 'ms',
      timestamp: DateTime.now(),
      type: MetricType.custom,
    );
    
    _addMetricToBuffer(metric);
  }

  /// Increment a counter
  void incrementCounter(String name, [int count = 1]) {
    _counters[name] = (_counters[name] ?? 0) + count;
  }

  /// Get current counter value
  int getCounter(String name) => _counters[name] ?? 0;

  /// Reset a counter
  void resetCounter(String name) => _counters.remove(name);

  /// Setup frame timing monitoring
  void _setupFrameCallback() {
    SchedulerBinding.instance.addPersistentFrameCallback((timeStamp) {
      _recordFrameTiming(timeStamp);
    });
  }

  /// Record frame timing data
  void _recordFrameTiming(Duration timeStamp) {
    if (_frameTimes.isNotEmpty) {
      final frameTime = timeStamp - _frameTimes.last;
      _frameTimes.add(timeStamp);
      
      // Keep only recent frame times
      if (_frameTimes.length > _maxFrameTimeHistory) {
        _frameTimes.removeAt(0);
      }
      
      _frameCount++;
      _totalFrameTime += frameTime;
      
      // Record frame metrics
      if (_frameCount % 60 == 0) { // Every 60 frames (1 second at 60fps)
        final avgFrameTime = _totalFrameTime.inMicroseconds / _frameCount / 1000;
        final fps = 1000 / avgFrameTime;
        
        recordMetric('fps', fps, unit: 'fps');
        recordMetric('frame_time', avgFrameTime, unit: 'ms');
        
        _frameCount = 0;
        _totalFrameTime = Duration.zero;
      }
      
      // Check for frame drops (jank)
      if (frameTime.inMilliseconds > 16.67) { // Dropped frames at 60fps
        incrementCounter('dropped_frames');
        recordMetric('jank', frameTime.inMicroseconds / 1000, unit: 'ms');
      }
    } else {
      _frameTimes.add(timeStamp);
    }
  }

  /// Setup memory monitoring
  void _setupMemoryMonitoring() {
    _gcTimer = Timer.periodic(const Duration(seconds: 5), (_) async {
      await _recordMemoryMetrics();
    });
  }

  /// Record memory usage metrics
  Future<void> _recordMemoryMetrics() async {
    try {
      // Get current memory info
      final info = await developer.Service.getInfo();
      final isolate = await developer.Service.getIsolate(info.serverUri.toString());
      
      if (isolate != null) {
        recordMetric('heap_size', isolate.heapUsage?.toDouble() ?? 0, unit: 'bytes');
        recordMetric('heap_capacity', isolate.heapCapacity?.toDouble() ?? 0, unit: 'bytes');
      }
      
      // Platform-specific memory metrics
      if (Platform.isAndroid || Platform.isIOS) {
        final platformMemory = await _getPlatformMemoryUsage();
        if (platformMemory != null) {
          recordMetric('platform_memory', platformMemory, unit: 'bytes');
        }
      }
    } catch (e) {
      debugPrint('Failed to record memory metrics: $e');
    }
  }

  /// Get platform-specific memory usage
  Future<double?> _getPlatformMemoryUsage() async {
    try {
      const platform = MethodChannel('performance_monitor');
      final result = await platform.invokeMethod('getMemoryUsage');
      return result?.toDouble();
    } catch (e) {
      return null; // Platform channel not implemented
    }
  }

  /// Setup timing metrics collection
  void _setupTimingMetrics() {
    // Monitor widget build times
    WidgetsBinding.instance.addBuildObserver(
      _PerformanceBuildObserver(this),
    );
  }

  /// Start periodic reporting
  void _startReporting() {
    _reportingTimer = Timer.periodic(_reportingInterval, (_) {
      _generatePerformanceReport();
    });
  }

  /// Generate comprehensive performance report
  void _generatePerformanceReport() {
    final report = PerformanceReport(
      timestamp: DateTime.now(),
      frameMetrics: _getFrameMetrics(),
      memoryMetrics: _getMemoryMetrics(),
      customMetrics: _getCustomMetrics(),
      counters: Map.from(_counters),
      recommendations: _generateRecommendations(),
    );
    
    final metric = PerformanceMetric(
      name: 'performance_report',
      value: 0,
      timestamp: DateTime.now(),
      type: MetricType.report,
      data: report.toJson(),
    );
    
    _addMetricToBuffer(metric);
  }

  /// Get frame-related metrics
  Map<String, double> _getFrameMetrics() {
    if (_frameTimes.length < 2) return {};
    
    final frameDurations = <double>[];
    for (int i = 1; i < _frameTimes.length; i++) {
      final duration = _frameTimes[i] - _frameTimes[i - 1];
      frameDurations.add(duration.inMicroseconds / 1000);
    }
    
    frameDurations.sort();
    
    return {
      'avg_frame_time': frameDurations.isNotEmpty 
          ? frameDurations.reduce((a, b) => a + b) / frameDurations.length
          : 0,
      'p95_frame_time': frameDurations.isNotEmpty 
          ? frameDurations[(frameDurations.length * 0.95).round()]
          : 0,
      'p99_frame_time': frameDurations.isNotEmpty 
          ? frameDurations[(frameDurations.length * 0.99).round()]
          : 0,
      'max_frame_time': frameDurations.isNotEmpty 
          ? frameDurations.last
          : 0,
      'dropped_frames': getCounter('dropped_frames').toDouble(),
    };
  }

  /// Get memory-related metrics
  Map<String, double> _getMemoryMetrics() {
    final recentMetrics = _metricsBuffer
        .where((m) => m.name.contains('heap') || m.name.contains('memory'))
        .toList();
    
    if (recentMetrics.isEmpty) return {};
    
    final latest = <String, double>{};
    for (final metric in recentMetrics) {
      latest[metric.name] = metric.value;
    }
    
    return latest;
  }

  /// Get custom metrics
  Map<String, double> _getCustomMetrics() {
    final customMetrics = _metricsBuffer
        .where((m) => m.type == MetricType.custom)
        .toList();
    
    final aggregated = <String, List<double>>{};
    for (final metric in customMetrics) {
      aggregated.putIfAbsent(metric.name, () => []).add(metric.value);
    }
    
    final result = <String, double>{};
    for (final entry in aggregated.entries) {
      result['${entry.key}_avg'] = entry.value.reduce((a, b) => a + b) / entry.value.length;
      result['${entry.key}_max'] = entry.value.reduce((a, b) => a > b ? a : b);
      result['${entry.key}_min'] = entry.value.reduce((a, b) => a < b ? a : b);
    }
    
    return result;
  }

  /// Generate performance recommendations
  List<String> _generateRecommendations() {
    final recommendations = <String>[];
    
    final frameMetrics = _getFrameMetrics();
    final avgFrameTime = frameMetrics['avg_frame_time'] ?? 0;
    final droppedFrames = frameMetrics['dropped_frames'] ?? 0;
    
    if (avgFrameTime > 20) {
      recommendations.add('High average frame time detected. Consider optimizing widget builds and reducing expensive operations.');
    }
    
    if (droppedFrames > 10) {
      recommendations.add('Frequent frame drops detected. Review animations and list scrolling performance.');
    }
    
    final memoryMetrics = _getMemoryMetrics();
    final heapSize = memoryMetrics['heap_size'] ?? 0;
    if (heapSize > 100 * 1024 * 1024) { // 100MB
      recommendations.add('High memory usage detected. Consider optimizing image caching and widget memory usage.');
    }
    
    return recommendations;
  }

  /// Add metric to buffer
  void _addMetricToBuffer(PerformanceMetric metric) {
    _metricsBuffer.add(metric);
    
    // Maintain buffer size
    while (_metricsBuffer.length > _maxBufferSize) {
      _metricsBuffer.removeFirst();
    }
    
    _metricsController.add(metric);
  }

  /// Get performance summary
  Map<String, dynamic> getSummary() {
    return {
      'is_monitoring': _isMonitoring,
      'tracked_metrics': _metricsBuffer.length,
      'active_trackers': _trackers.length,
      'counters': _counters,
      'uptime': DateTime.now().difference(_startTime ?? DateTime.now()).inSeconds,
    };
  }

  DateTime? _startTime;

  /// Dispose the service
  void dispose() {
    _reportingTimer?.cancel();
    _gcTimer?.cancel();
    _metricsController.close();
    _isMonitoring = false;
  }
}

/// Performance tracker for measuring execution time
class PerformanceTracker {
  final String name;
  final Stopwatch _stopwatch = Stopwatch();
  final DateTime _startTime = DateTime.now();

  PerformanceTracker._(this.name) {
    _stopwatch.start();
  }

  /// Stop tracking and record metric
  void stop() {
    _stopwatch.stop();
    PerformanceMonitorService.instance.recordMetric(
      name,
      _stopwatch.elapsedMicroseconds / 1000,
    );
  }

  /// Get elapsed time without stopping
  Duration get elapsed => _stopwatch.elapsed;
}

/// Performance metric data class
class PerformanceMetric {
  final String name;
  final double value;
  final String unit;
  final DateTime timestamp;
  final MetricType type;
  final Map<String, dynamic>? data;

  const PerformanceMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    this.unit = 'ms',
    this.type = MetricType.timing,
    this.data,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'unit': unit,
    'timestamp': timestamp.toIso8601String(),
    'type': type.toString(),
    'data': data,
  };
}

/// Performance report data class
class PerformanceReport {
  final DateTime timestamp;
  final Map<String, double> frameMetrics;
  final Map<String, double> memoryMetrics;
  final Map<String, double> customMetrics;
  final Map<String, int> counters;
  final List<String> recommendations;

  const PerformanceReport({
    required this.timestamp,
    required this.frameMetrics,
    required this.memoryMetrics,
    required this.customMetrics,
    required this.counters,
    required this.recommendations,
  });

  Map<String, dynamic> toJson() => {
    'timestamp': timestamp.toIso8601String(),
    'frame_metrics': frameMetrics,
    'memory_metrics': memoryMetrics,
    'custom_metrics': customMetrics,
    'counters': counters,
    'recommendations': recommendations,
  };
}

/// Metric type enumeration
enum MetricType {
  timing,
  memory,
  counter,
  custom,
  report,
}

/// Build observer for monitoring widget performance
class _PerformanceBuildObserver extends WidgetInspectorService {
  final PerformanceMonitorService _monitor;
  final Map<String, Stopwatch> _buildTimers = {};

  _PerformanceBuildObserver(this._monitor);

  @override
  bool isWidgetCreationTracked() => true;

  void startBuildTimer(String widgetName) {
    final stopwatch = Stopwatch()..start();
    _buildTimers[widgetName] = stopwatch;
  }

  void stopBuildTimer(String widgetName) {
    final stopwatch = _buildTimers.remove(widgetName);
    if (stopwatch != null) {
      stopwatch.stop();
      _monitor.recordMetric(
        'build_time_$widgetName',
        stopwatch.elapsedMicroseconds / 1000,
      );
    }
  }
}

/// Performance-aware widget mixin
mixin PerformanceAware on Widget {
  String get performanceName => runtimeType.toString();

  @override
  StatelessElement createElement() {
    final monitor = PerformanceMonitorService.instance;
    monitor.incrementCounter('widget_builds_$performanceName');
    
    final element = super.createElement();
    
    // Track build time
    final tracker = monitor.startTracker('build_$performanceName');
    SchedulerBinding.instance.addPostFrameCallback((_) {
      tracker.stop();
    });
    
    return element;
  }
}

/// Performance benchmark utility
class PerformanceBenchmark {
  /// Run a benchmark function multiple times and collect statistics
  static Future<BenchmarkResult> run({
    required String name,
    required Future<void> Function() benchmark,
    int iterations = 10,
    int warmupIterations = 3,
  }) async {
    final durations = <Duration>[];
    
    // Warmup iterations
    for (int i = 0; i < warmupIterations; i++) {
      await benchmark();
    }
    
    // Actual benchmark iterations
    for (int i = 0; i < iterations; i++) {
      final stopwatch = Stopwatch()..start();
      await benchmark();
      stopwatch.stop();
      durations.add(stopwatch.elapsed);
    }
    
    return BenchmarkResult(
      name: name,
      iterations: iterations,
      durations: durations,
    );
  }

  /// Compare two benchmark functions
  static Future<ComparisonResult> compare({
    required String nameA,
    required Future<void> Function() benchmarkA,
    required String nameB,
    required Future<void> Function() benchmarkB,
    int iterations = 10,
  }) async {
    final resultA = await run(
      name: nameA,
      benchmark: benchmarkA,
      iterations: iterations,
    );
    
    final resultB = await run(
      name: nameB,
      benchmark: benchmarkB,
      iterations: iterations,
    );
    
    return ComparisonResult(resultA, resultB);
  }
}

/// Benchmark result data class
class BenchmarkResult {
  final String name;
  final int iterations;
  final List<Duration> durations;

  const BenchmarkResult({
    required this.name,
    required this.iterations,
    required this.durations,
  });

  Duration get averageDuration {
    final totalMicroseconds = durations
        .map((d) => d.inMicroseconds)
        .reduce((a, b) => a + b);
    return Duration(microseconds: totalMicroseconds ~/ durations.length);
  }

  Duration get minDuration => durations.reduce((a, b) => a < b ? a : b);
  Duration get maxDuration => durations.reduce((a, b) => a > b ? a : b);

  double get standardDeviation {
    final avgMicros = averageDuration.inMicroseconds.toDouble();
    final variance = durations
        .map((d) => (d.inMicroseconds - avgMicros) * (d.inMicroseconds - avgMicros))
        .reduce((a, b) => a + b) / durations.length;
    return variance.isNaN ? 0.0 : variance;
  }

  Map<String, dynamic> toJson() => {
    'name': name,
    'iterations': iterations,
    'average_ms': averageDuration.inMicroseconds / 1000,
    'min_ms': minDuration.inMicroseconds / 1000,
    'max_ms': maxDuration.inMicroseconds / 1000,
    'std_dev': standardDeviation / 1000,
  };
}

/// Comparison result for benchmarks
class ComparisonResult {
  final BenchmarkResult resultA;
  final BenchmarkResult resultB;

  const ComparisonResult(this.resultA, this.resultB);

  double get improvementRatio =>
      resultB.averageDuration.inMicroseconds / resultA.averageDuration.inMicroseconds;

  String get winner => improvementRatio > 1 ? resultA.name : resultB.name;

  double get improvementPercentage => ((improvementRatio - 1) * 100).abs();

  Map<String, dynamic> toJson() => {
    'result_a': resultA.toJson(),
    'result_b': resultB.toJson(),
    'winner': winner,
    'improvement_ratio': improvementRatio,
    'improvement_percentage': improvementPercentage,
  };
}