import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Lazy widget loader for code splitting and deferred loading
class LazyWidgetLoader<T extends Widget> extends StatefulWidget {
  final Future<T> Function() widgetFactory;
  final Widget? placeholder;
  final Widget Function(Object error, StackTrace? stackTrace)? errorBuilder;
  final bool preload;
  final Duration? delay;
  final VoidCallback? onLoadStart;
  final VoidCallback? onLoadComplete;
  final Function(Object error)? onLoadError;

  const LazyWidgetLoader({
    Key? key,
    required this.widgetFactory,
    this.placeholder,
    this.errorBuilder,
    this.preload = false,
    this.delay,
    this.onLoadStart,
    this.onLoadComplete,
    this.onLoadError,
  }) : super(key: key);

  @override
  State<LazyWidgetLoader<T>> createState() => _LazyWidgetLoaderState<T>();
}

class _LazyWidgetLoaderState<T extends Widget> extends State<LazyWidgetLoader<T>> {
  Widget? _loadedWidget;
  bool _isLoading = false;
  Object? _error;
  Timer? _delayTimer;

  @override
  void initState() {
    super.initState();
    if (widget.preload) {
      _startLoading();
    }
  }

  @override
  void dispose() {
    _delayTimer?.cancel();
    super.dispose();
  }

  void _startLoading() {
    if (_isLoading || _loadedWidget != null) return;

    setState(() {
      _isLoading = true;
      _error = null;
    });

    widget.onLoadStart?.call();

    final loadFunction = () async {
      try {
        final widget = await this.widget.widgetFactory();
        if (mounted) {
          setState(() {
            _loadedWidget = widget;
            _isLoading = false;
          });
          this.widget.onLoadComplete?.call();
        }
      } catch (error, stackTrace) {
        if (mounted) {
          setState(() {
            _error = error;
            _isLoading = false;
          });
          this.widget.onLoadError?.call(error);
        }
      }
    };

    if (widget.delay != null) {
      _delayTimer = Timer(widget.delay!, loadFunction);
    } else {
      loadFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_error != null) {
      return widget.errorBuilder?.call(_error!, null) ?? _buildDefaultError();
    }

    if (_loadedWidget != null) {
      return _loadedWidget!;
    }

    if (!_isLoading && !widget.preload) {
      // Start loading when widget becomes visible
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          _startLoading();
        }
      });
    }

    return widget.placeholder ?? _buildDefaultPlaceholder();
  }

  Widget _buildDefaultPlaceholder() {
    return const Center(
      child: SizedBox(
        width: 24,
        height: 24,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildDefaultError() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.error_outline, color: Colors.red),
          const SizedBox(height: 8),
          Text(
            'Failed to load widget',
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () {
              setState(() {
                _error = null;
                _loadedWidget = null;
              });
              _startLoading();
            },
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }
}

/// Code splitting manager for deferred widget loading
class CodeSplittingManager {
  static final CodeSplittingManager _instance = CodeSplittingManager._();
  static CodeSplittingManager get instance => _instance;
  
  CodeSplittingManager._();

  final Map<String, Future<Widget> Function()> _widgetFactories = {};
  final Map<String, Widget> _loadedWidgets = {};
  final Set<String> _preloadedKeys = {};

  /// Register a widget factory for lazy loading
  void registerWidget<T extends Widget>(
    String key,
    Future<T> Function() factory,
  ) {
    _widgetFactories[key] = factory;
  }

  /// Load a widget by key
  Future<Widget?> loadWidget(String key) async {
    if (_loadedWidgets.containsKey(key)) {
      return _loadedWidgets[key];
    }

    final factory = _widgetFactories[key];
    if (factory == null) {
      throw ArgumentError('No widget factory registered for key: $key');
    }

    try {
      final widget = await factory();
      _loadedWidgets[key] = widget;
      return widget;
    } catch (e) {
      rethrow;
    }
  }

  /// Preload widgets for better performance
  Future<void> preloadWidgets(List<String> keys) async {
    final futures = <Future<void>>[];
    
    for (final key in keys) {
      if (!_preloadedKeys.contains(key) && !_loadedWidgets.containsKey(key)) {
        _preloadedKeys.add(key);
        futures.add(loadWidget(key).then((_) {}));
      }
    }
    
    await Future.wait(futures, eagerError: false);
  }

  /// Check if a widget is loaded
  bool isWidgetLoaded(String key) {
    return _loadedWidgets.containsKey(key);
  }

  /// Clear loaded widgets to free memory
  void clearWidget(String key) {
    _loadedWidgets.remove(key);
    _preloadedKeys.remove(key);
  }

  /// Clear all loaded widgets
  void clearAll() {
    _loadedWidgets.clear();
    _preloadedKeys.clear();
  }

  /// Get memory usage statistics
  Map<String, dynamic> getStats() {
    return {
      'registered_widgets': _widgetFactories.length,
      'loaded_widgets': _loadedWidgets.length,
      'preloaded_widgets': _preloadedKeys.length,
    };
  }
}

/// Widget that loads content based on visibility
class VisibilityBasedLoader extends StatefulWidget {
  final Widget Function() builder;
  final Widget? placeholder;
  final double visibilityThreshold;
  final Duration? delay;

  const VisibilityBasedLoader({
    Key? key,
    required this.builder,
    this.placeholder,
    this.visibilityThreshold = 0.1,
    this.delay,
  }) : super(key: key);

  @override
  State<VisibilityBasedLoader> createState() => _VisibilityBasedLoaderState();
}

class _VisibilityBasedLoaderState extends State<VisibilityBasedLoader> {
  bool _isVisible = false;
  bool _hasLoaded = false;
  Widget? _loadedContent;
  Timer? _loadTimer;

  @override
  void dispose() {
    _loadTimer?.cancel();
    super.dispose();
  }

  void _loadContent() {
    if (_hasLoaded) return;

    _hasLoaded = true;
    
    final loadFunction = () {
      if (mounted) {
        setState(() {
          _loadedContent = widget.builder();
        });
      }
    };

    if (widget.delay != null) {
      _loadTimer = Timer(widget.delay!, loadFunction);
    } else {
      loadFunction();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_loadedContent != null) {
      return _loadedContent!;
    }

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (!_isVisible && !_hasLoaded) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _checkVisibility();
          });
        }
        return false;
      },
      child: widget.placeholder ?? const SizedBox.shrink(),
    );
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject == null) return;

    final viewport = RenderAbstractViewport.of(renderObject);
    if (viewport == null) return;

    final offsetToReveal = viewport.getOffsetToReveal(renderObject, 0.0);
    final size = renderObject.semanticBounds.size;
    final viewportSize = viewport.semanticBounds.size;

    // Simple visibility check
    final isVisible = offsetToReveal.offset < viewportSize.height &&
        offsetToReveal.offset + size.height > 0;

    if (isVisible && !_isVisible) {
      _isVisible = true;
      _loadContent();
    }
  }
}

/// Deferred route loader for navigation
class DeferredRoute<T> extends MaterialPageRoute<T> {
  final Future<Widget> Function() widgetBuilder;
  final Widget? placeholder;

  DeferredRoute({
    required this.widgetBuilder,
    this.placeholder,
    RouteSettings? settings,
  }) : super(
          builder: (context) => _DeferredRouteContent(
            widgetBuilder: widgetBuilder,
            placeholder: placeholder,
          ),
          settings: settings,
        );
}

class _DeferredRouteContent extends StatelessWidget {
  final Future<Widget> Function() widgetBuilder;
  final Widget? placeholder;

  const _DeferredRouteContent({
    required this.widgetBuilder,
    this.placeholder,
  });

  @override
  Widget build(BuildContext context) {
    return LazyWidgetLoader<Widget>(
      widgetFactory: widgetBuilder,
      placeholder: placeholder ?? const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      ),
      errorBuilder: (error, stackTrace) => Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 48, color: Colors.red),
              const SizedBox(height: 16),
              Text(
                'Failed to load page',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Bundle analyzer for tracking widget sizes
class BundleAnalyzer {
  static final BundleAnalyzer _instance = BundleAnalyzer._();
  static BundleAnalyzer get instance => _instance;

  BundleAnalyzer._();

  final Map<String, int> _widgetSizes = {};
  final Map<String, DateTime> _loadTimes = {};

  /// Record widget size
  void recordWidgetSize(String widgetName, int sizeInBytes) {
    _widgetSizes[widgetName] = sizeInBytes;
  }

  /// Record widget load time
  void recordLoadTime(String widgetName) {
    _loadTimes[widgetName] = DateTime.now();
  }

  /// Get performance report
  Map<String, dynamic> getPerformanceReport() {
    final totalSize = _widgetSizes.values.fold<int>(0, (sum, size) => sum + size);
    
    return {
      'total_widgets': _widgetSizes.length,
      'total_size_bytes': totalSize,
      'total_size_mb': (totalSize / (1024 * 1024)).toStringAsFixed(2),
      'average_size_bytes': _widgetSizes.isNotEmpty 
          ? (totalSize / _widgetSizes.length).round()
          : 0,
      'largest_widgets': _getLargestWidgets(),
      'recently_loaded': _getRecentlyLoaded(),
    };
  }

  List<Map<String, dynamic>> _getLargestWidgets() {
    final sorted = _widgetSizes.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return sorted.take(10).map((entry) => {
      'name': entry.key,
      'size_bytes': entry.value,
      'size_kb': (entry.value / 1024).toStringAsFixed(2),
    }).toList();
  }

  List<Map<String, dynamic>> _getRecentlyLoaded() {
    final now = DateTime.now();
    final recent = _loadTimes.entries
        .where((entry) => now.difference(entry.value).inMinutes < 10)
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return recent.map((entry) => {
      'name': entry.key,
      'loaded_at': entry.value.toIso8601String(),
      'minutes_ago': now.difference(entry.value).inMinutes,
    }).toList();
  }

  /// Clear analytics data
  void clearAnalytics() {
    _widgetSizes.clear();
    _loadTimes.clear();
  }
}

/// Mixin for performance-aware widgets
mixin PerformanceAware on Widget {
  String get performanceName => runtimeType.toString();

  @override
  StatelessElement createElement() {
    final element = super.createElement();
    BundleAnalyzer.instance.recordLoadTime(performanceName);
    return element;
  }
}

/// Performance-optimized stateless widget base class
abstract class OptimizedStatelessWidget extends StatelessWidget 
    with PerformanceAware {
  const OptimizedStatelessWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context);
}

/// Performance-optimized stateful widget base class
abstract class OptimizedStatefulWidget extends StatefulWidget 
    with PerformanceAware {
  const OptimizedStatefulWidget({Key? key}) : super(key: key);

  @override
  State<OptimizedStatefulWidget> createState();
}

/// Widget preloader for critical widgets
class WidgetPreloader {
  static final WidgetPreloader _instance = WidgetPreloader._();
  static WidgetPreloader get instance => _instance;

  WidgetPreloader._();

  final Set<String> _criticalWidgets = {};
  final Map<String, Timer> _preloadTimers = {};

  /// Mark widgets as critical for preloading
  void markAsCritical(List<String> widgetKeys) {
    _criticalWidgets.addAll(widgetKeys);
  }

  /// Preload critical widgets with staggered loading
  Future<void> preloadCriticalWidgets() async {
    if (_criticalWidgets.isEmpty) return;

    final codeManager = CodeSplittingManager.instance;
    int delayMs = 0;

    for (final widgetKey in _criticalWidgets) {
      _preloadTimers[widgetKey] = Timer(
        Duration(milliseconds: delayMs),
        () async {
          try {
            await codeManager.loadWidget(widgetKey);
          } catch (e) {
            debugPrint('Failed to preload widget $widgetKey: $e');
          }
        },
      );
      
      delayMs += 100; // Stagger by 100ms
    }
  }

  /// Cancel all preload operations
  void cancelPreloading() {
    for (final timer in _preloadTimers.values) {
      timer.cancel();
    }
    _preloadTimers.clear();
  }

  /// Get preloading status
  Map<String, dynamic> getStatus() {
    final codeManager = CodeSplittingManager.instance;
    final loaded = _criticalWidgets
        .where((key) => codeManager.isWidgetLoaded(key))
        .length;

    return {
      'critical_widgets': _criticalWidgets.length,
      'loaded_widgets': loaded,
      'loading_progress': _criticalWidgets.isNotEmpty 
          ? (loaded / _criticalWidgets.length) 
          : 1.0,
      'active_preloads': _preloadTimers.length,
    };
  }
}