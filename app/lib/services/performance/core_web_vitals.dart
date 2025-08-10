import 'dart:async';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

/// Core Web Vitals monitoring and optimization service
class CoreWebVitalsService {
  static final CoreWebVitalsService _instance = CoreWebVitalsService._();
  static CoreWebVitalsService get instance => _instance;

  CoreWebVitalsService._();

  final StreamController<WebVitalMetric> _metricsController = 
      StreamController<WebVitalMetric>.broadcast();
  
  bool _initialized = false;
  final Map<String, double> _metrics = {};
  Timer? _performanceObserverTimer;

  /// Initialize Core Web Vitals monitoring
  Future<void> initialize() async {
    if (_initialized || !kIsWeb) return;
    
    try {
      await _setupPerformanceObserver();
      await _setupResourceTiming();
      _setupLayoutShiftObserver();
      _setupInputDelayObserver();
      
      _initialized = true;
      debugPrint('Core Web Vitals monitoring initialized');
    } catch (e) {
      debugPrint('Failed to initialize Core Web Vitals: $e');
    }
  }

  /// Get metrics stream
  Stream<WebVitalMetric> get metricsStream => _metricsController.stream;

  /// Get current metrics
  Map<String, double> get currentMetrics => Map.from(_metrics);

  /// Setup Performance Observer for Core Web Vitals
  Future<void> _setupPerformanceObserver() async {
    if (!kIsWeb) return;

    try {
      // Setup observer for LCP (Largest Contentful Paint)
      js.context.callMethod('eval', ['''
        if ('PerformanceObserver' in window) {
          const lcpObserver = new PerformanceObserver((list) => {
            const entries = list.getEntries();
            const lastEntry = entries[entries.length - 1];
            window.reportCWV('LCP', lastEntry.startTime);
          });
          lcpObserver.observe({entryTypes: ['largest-contentful-paint']});
          
          // Setup observer for FID (First Input Delay)
          const fidObserver = new PerformanceObserver((list) => {
            const entries = list.getEntries();
            entries.forEach(entry => {
              window.reportCWV('FID', entry.processingStart - entry.startTime);
            });
          });
          fidObserver.observe({entryTypes: ['first-input']});
          
          // Setup observer for FCP (First Contentful Paint)
          const fcpObserver = new PerformanceObserver((list) => {
            const entries = list.getEntries();
            entries.forEach(entry => {
              if (entry.name === 'first-contentful-paint') {
                window.reportCWV('FCP', entry.startTime);
              }
            });
          });
          fcpObserver.observe({entryTypes: ['paint']});
        }
      ''']);

      // Setup callback to receive metrics from JavaScript
      js.context['reportCWV'] = (String metric, num value) {
        _reportMetric(metric, value.toDouble());
      };
    } catch (e) {
      debugPrint('Failed to setup performance observer: $e');
    }
  }

  /// Setup resource timing monitoring
  Future<void> _setupResourceTiming() async {
    if (!kIsWeb) return;

    try {
      js.context.callMethod('eval', ['''
        window.addEventListener('load', () => {
          setTimeout(() => {
            const perfEntries = performance.getEntriesByType('navigation');
            if (perfEntries.length > 0) {
              const entry = perfEntries[0];
              window.reportCWV('TTFB', entry.responseStart - entry.requestStart);
              window.reportCWV('DOMContentLoaded', entry.domContentLoadedEventEnd - entry.domContentLoadedEventStart);
              window.reportCWV('LoadComplete', entry.loadEventEnd - entry.loadEventStart);
            }
          }, 0);
        });
      ''']);
    } catch (e) {
      debugPrint('Failed to setup resource timing: $e');
    }
  }

  /// Setup Cumulative Layout Shift (CLS) observer
  void _setupLayoutShiftObserver() {
    if (!kIsWeb) return;

    try {
      js.context.callMethod('eval', ['''
        if ('PerformanceObserver' in window) {
          let clsValue = 0;
          let clsEntries = [];
          let sessionValue = 0;
          let sessionEntries = [];
          
          const clsObserver = new PerformanceObserver((list) => {
            for (const entry of list.getEntries()) {
              if (!entry.hadRecentInput) {
                const firstSessionEntry = sessionEntries[0];
                const lastSessionEntry = sessionEntries[sessionEntries.length - 1];
                
                if (sessionValue && 
                    entry.startTime - lastSessionEntry.startTime < 1000 &&
                    entry.startTime - firstSessionEntry.startTime < 5000) {
                  sessionValue += entry.value;
                  sessionEntries.push(entry);
                } else {
                  sessionValue = entry.value;
                  sessionEntries = [entry];
                }
                
                if (sessionValue > clsValue) {
                  clsValue = sessionValue;
                  clsEntries = [...sessionEntries];
                  window.reportCWV('CLS', clsValue);
                }
              }
            }
          });
          
          clsObserver.observe({entryTypes: ['layout-shift']});
        }
      ''']);
    } catch (e) {
      debugPrint('Failed to setup CLS observer: $e');
    }
  }

  /// Setup First Input Delay monitoring
  void _setupInputDelayObserver() {
    if (!kIsWeb) return;

    try {
      js.context.callMethod('eval', ['''
        let fidReported = false;
        
        function measureFID(event) {
          if (fidReported) return;
          
          const start = performance.now();
          requestIdleCallback(() => {
            const delay = performance.now() - start;
            window.reportCWV('InputDelay', delay);
            fidReported = true;
          });
        }
        
        ['keydown', 'click', 'mousedown', 'touchstart'].forEach(type => {
          document.addEventListener(type, measureFID, {once: true, passive: true});
        });
      ''']);
    } catch (e) {
      debugPrint('Failed to setup input delay observer: $e');
    }
  }

  /// Report metric value
  void _reportMetric(String name, double value) {
    _metrics[name] = value;
    
    final metric = WebVitalMetric(
      name: name,
      value: value,
      timestamp: DateTime.now(),
      rating: _getMetricRating(name, value),
    );
    
    _metricsController.add(metric);
    debugPrint('Core Web Vital: $name = ${value.toStringAsFixed(2)}ms (${metric.rating})');
  }

  /// Get metric rating based on thresholds
  MetricRating _getMetricRating(String metric, double value) {
    switch (metric) {
      case 'LCP':
        if (value <= 2500) return MetricRating.good;
        if (value <= 4000) return MetricRating.needsImprovement;
        return MetricRating.poor;
      
      case 'FID':
        if (value <= 100) return MetricRating.good;
        if (value <= 300) return MetricRating.needsImprovement;
        return MetricRating.poor;
      
      case 'CLS':
        if (value <= 0.1) return MetricRating.good;
        if (value <= 0.25) return MetricRating.needsImprovement;
        return MetricRating.poor;
      
      case 'FCP':
        if (value <= 1800) return MetricRating.good;
        if (value <= 3000) return MetricRating.needsImprovement;
        return MetricRating.poor;
      
      case 'TTFB':
        if (value <= 800) return MetricRating.good;
        if (value <= 1800) return MetricRating.needsImprovement;
        return MetricRating.poor;
      
      default:
        return MetricRating.unknown;
    }
  }

  /// Get performance score (0-100)
  int getPerformanceScore() {
    if (_metrics.isEmpty) return 0;
    
    double totalScore = 0;
    int metricCount = 0;
    
    for (final entry in _metrics.entries) {
      final rating = _getMetricRating(entry.key, entry.value);
      double score = 0;
      
      switch (rating) {
        case MetricRating.good:
          score = 100;
          break;
        case MetricRating.needsImprovement:
          score = 50;
          break;
        case MetricRating.poor:
          score = 0;
          break;
        case MetricRating.unknown:
          continue;
      }
      
      totalScore += score;
      metricCount++;
    }
    
    return metricCount > 0 ? (totalScore / metricCount).round() : 0;
  }

  /// Get detailed performance report
  Map<String, dynamic> getPerformanceReport() {
    return {
      'score': getPerformanceScore(),
      'metrics': _metrics.map((key, value) => MapEntry(key, {
        'value': value,
        'rating': _getMetricRating(key, value).toString(),
        'unit': _getMetricUnit(key),
      })),
      'recommendations': _getRecommendations(),
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  String _getMetricUnit(String metric) {
    switch (metric) {
      case 'CLS':
        return 'score';
      default:
        return 'ms';
    }
  }

  List<String> _getRecommendations() {
    final recommendations = <String>[];
    
    final lcp = _metrics['LCP'];
    if (lcp != null && lcp > 2500) {
      recommendations.add('Optimize Largest Contentful Paint by reducing image sizes and improving server response times');
    }
    
    final fid = _metrics['FID'];
    if (fid != null && fid > 100) {
      recommendations.add('Reduce First Input Delay by minimizing JavaScript execution time');
    }
    
    final cls = _metrics['CLS'];
    if (cls != null && cls > 0.1) {
      recommendations.add('Improve Cumulative Layout Shift by specifying image dimensions and avoiding dynamic content insertion');
    }
    
    final fcp = _metrics['FCP'];
    if (fcp != null && fcp > 1800) {
      recommendations.add('Speed up First Contentful Paint by optimizing critical rendering path');
    }
    
    return recommendations;
  }

  /// Dispose the service
  void dispose() {
    _performanceObserverTimer?.cancel();
    _metricsController.close();
  }
}

/// Web vital metric data class
class WebVitalMetric {
  final String name;
  final double value;
  final DateTime timestamp;
  final MetricRating rating;

  const WebVitalMetric({
    required this.name,
    required this.value,
    required this.timestamp,
    required this.rating,
  });

  Map<String, dynamic> toJson() => {
    'name': name,
    'value': value,
    'timestamp': timestamp.toIso8601String(),
    'rating': rating.toString(),
  };
}

/// Metric rating enumeration
enum MetricRating {
  good,
  needsImprovement,
  poor,
  unknown,
}

/// Performance optimization utilities
class PerformanceOptimizer {
  /// Optimize image loading for better LCP
  static Widget optimizeImageForLCP({
    required String src,
    double? width,
    double? height,
    BoxFit? fit,
  }) {
    return Image.network(
      src,
      width: width,
      height: height,
      fit: fit,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          width: width,
          height: height,
          color: Colors.grey[300],
          child: const Icon(Icons.error),
        );
      },
    );
  }

  /// Reduce layout shifts with sized containers
  static Widget preventLayoutShift({
    required Widget child,
    required double width,
    required double height,
  }) {
    return SizedBox(
      width: width,
      height: height,
      child: child,
    );
  }

  /// Optimize list rendering for better performance
  static Widget optimizeListView<T>({
    required List<T> items,
    required Widget Function(BuildContext, int, T) itemBuilder,
    double? itemExtent,
    ScrollController? controller,
  }) {
    return ListView.builder(
      controller: controller,
      itemExtent: itemExtent,
      itemCount: items.length,
      cacheExtent: 500,
      itemBuilder: (context, index) {
        return RepaintBoundary(
          child: itemBuilder(context, index, items[index]),
        );
      },
    );
  }

  /// Debounce function calls to reduce input delay
  static VoidCallback debounce(
    VoidCallback function,
    Duration delay,
  ) {
    Timer? timer;
    
    return () {
      timer?.cancel();
      timer = Timer(delay, function);
    };
  }

  /// Throttle function calls for better performance
  static VoidCallback throttle(
    VoidCallback function,
    Duration interval,
  ) {
    bool canExecute = true;
    
    return () {
      if (!canExecute) return;
      
      canExecute = false;
      function();
      
      Timer(interval, () {
        canExecute = true;
      });
    };
  }

  /// Lazy load widgets below the fold
  static Widget lazyLoadBelowFold({
    required Widget child,
    Widget? placeholder,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return FutureBuilder(
          future: SchedulerBinding.instance.endOfFrame,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return child;
            }
            return placeholder ?? const SizedBox.shrink();
          },
        );
      },
    );
  }
}

/// Performance monitoring widget
class PerformanceMonitor extends StatefulWidget {
  final Widget child;
  final bool showOverlay;
  final VoidCallback? onPerformanceIssue;

  const PerformanceMonitor({
    Key? key,
    required this.child,
    this.showOverlay = false,
    this.onPerformanceIssue,
  }) : super(key: key);

  @override
  State<PerformanceMonitor> createState() => _PerformanceMonitorState();
}

class _PerformanceMonitorState extends State<PerformanceMonitor> {
  final CoreWebVitalsService _cwvService = CoreWebVitalsService.instance;
  Map<String, double> _metrics = {};
  int _performanceScore = 100;

  @override
  void initState() {
    super.initState();
    _cwvService.initialize();
    
    _cwvService.metricsStream.listen((metric) {
      if (mounted) {
        setState(() {
          _metrics = _cwvService.currentMetrics;
          _performanceScore = _cwvService.getPerformanceScore();
        });
        
        if (_performanceScore < 50) {
          widget.onPerformanceIssue?.call();
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && kDebugMode)
          Positioned(
            top: 40,
            right: 16,
            child: _buildPerformanceOverlay(),
          ),
      ],
    );
  }

  Widget _buildPerformanceOverlay() {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Performance Score: $_performanceScore',
            style: TextStyle(
              color: _getScoreColor(_performanceScore),
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          ..._metrics.entries.map((entry) {
            final rating = _cwvService._getMetricRating(entry.key, entry.value);
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: _getRatingColor(rating),
                      shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '${entry.key}: ${entry.value.toStringAsFixed(1)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ],
      ),
    );
  }

  Color _getScoreColor(int score) {
    if (score >= 90) return Colors.green;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }

  Color _getRatingColor(MetricRating rating) {
    switch (rating) {
      case MetricRating.good:
        return Colors.green;
      case MetricRating.needsImprovement:
        return Colors.orange;
      case MetricRating.poor:
        return Colors.red;
      case MetricRating.unknown:
        return Colors.grey;
    }
  }
}