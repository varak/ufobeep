import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../services/performance/performance_monitor.dart';

/// Performance-optimized provider base classes
abstract class OptimizedNotifier<T> extends Notifier<T> 
    with PerformanceTrackingMixin {
  
  @override
  T build() {
    trackPerformance('build_${runtimeType}', () => buildState());
    return buildState();
  }
  
  /// Subclasses should override this instead of build()
  T buildState();
  
  @override
  set state(T newState) {
    trackPerformance('setState_${runtimeType}', () {
      super.state = newState;
    });
  }
}

abstract class OptimizedAsyncNotifier<T> extends AsyncNotifier<T> 
    with PerformanceTrackingMixin {
  
  @override
  Future<T> build() {
    return trackPerformanceAsync('build_${runtimeType}', () => buildState());
  }
  
  /// Subclasses should override this instead of build()
  Future<T> buildState();
  
  @override
  set state(AsyncValue<T> newState) {
    trackPerformance('setState_${runtimeType}', () {
      super.state = newState;
    });
  }
}

/// Mixin for tracking provider performance
mixin PerformanceTrackingMixin {
  final PerformanceMonitorService _monitor = PerformanceMonitorService.instance;
  
  /// Track synchronous performance
  R trackPerformance<R>(String operationName, R Function() operation) {
    final tracker = _monitor.startTracker(operationName);
    try {
      return operation();
    } finally {
      tracker.stop();
    }
  }
  
  /// Track asynchronous performance
  Future<R> trackPerformanceAsync<R>(String operationName, Future<R> Function() operation) async {
    final tracker = _monitor.startTracker(operationName);
    try {
      return await operation();
    } finally {
      tracker.stop();
    }
  }
  
  /// Increment a performance counter
  void incrementCounter(String name) {
    _monitor.incrementCounter(name);
  }
  
  /// Record a custom metric
  void recordMetric(String name, double value, {String? unit}) {
    _monitor.recordMetric(name, value, unit: unit);
  }
}

/// Memoized provider for expensive computations
class MemoizedProvider<T> {
  final Map<String, _MemoizedEntry<T>> _cache = {};
  final int maxCacheSize;
  final Duration? expiration;
  
  MemoizedProvider({
    this.maxCacheSize = 100,
    this.expiration,
  });
  
  /// Get or compute value with memoization
  T getOrCompute(String key, T Function() computation) {
    // Check cache first
    final entry = _cache[key];
    if (entry != null) {
      if (expiration == null || 
          DateTime.now().difference(entry.timestamp) < expiration!) {
        return entry.value;
      } else {
        _cache.remove(key);
      }
    }
    
    // Compute new value
    final value = computation();
    
    // Add to cache
    if (_cache.length >= maxCacheSize) {
      _evictOldestEntry();
    }
    
    _cache[key] = _MemoizedEntry(value, DateTime.now());
    return value;
  }
  
  /// Clear cache
  void clear() {
    _cache.clear();
  }
  
  /// Clear expired entries
  void clearExpired() {
    if (expiration == null) return;
    
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => 
        now.difference(entry.timestamp) > expiration!);
  }
  
  void _evictOldestEntry() {
    if (_cache.isEmpty) return;
    
    final oldestKey = _cache.keys.first;
    _cache.remove(oldestKey);
  }
}

class _MemoizedEntry<T> {
  final T value;
  final DateTime timestamp;
  
  _MemoizedEntry(this.value, this.timestamp);
}

/// Selectable provider for fine-grained updates
abstract class SelectableNotifier<T> extends Notifier<T> 
    with PerformanceTrackingMixin {
  final Map<String, dynamic> _selectors = {};
  final StreamController<SelectorUpdate> _selectorController = 
      StreamController.broadcast();
  
  /// Select a specific part of the state
  R select<R>(String key, R Function(T state) selector) {
    final currentValue = selector(state);
    final previousValue = _selectors[key];
    
    if (previousValue != currentValue) {
      _selectors[key] = currentValue;
      _selectorController.add(SelectorUpdate(key, currentValue, previousValue));
    }
    
    return currentValue;
  }
  
  /// Get selector updates stream
  Stream<SelectorUpdate> get selectorUpdates => _selectorController.stream;
  
  @override
  void dispose() {
    _selectorController.close();
    super.dispose();
  }
}

class SelectorUpdate {
  final String key;
  final dynamic newValue;
  final dynamic previousValue;
  
  SelectorUpdate(this.key, this.newValue, this.previousValue);
}

/// Batched state updates to reduce rebuilds
abstract class BatchedNotifier<T> extends Notifier<T> 
    with PerformanceTrackingMixin {
  Timer? _batchTimer;
  T? _pendingState;
  final Duration batchDuration;
  
  BatchedNotifier({this.batchDuration = const Duration(milliseconds: 16)});
  
  /// Schedule a batched state update
  void batchedUpdate(T newState) {
    _pendingState = newState;
    
    _batchTimer?.cancel();
    _batchTimer = Timer(batchDuration, () {
      if (_pendingState != null) {
        state = _pendingState!;
        _pendingState = null;
      }
    });
  }
  
  @override
  void dispose() {
    _batchTimer?.cancel();
    super.dispose();
  }
}

/// Debounced provider for rapid state changes
abstract class DebouncedNotifier<T> extends Notifier<T> 
    with PerformanceTrackingMixin {
  Timer? _debounceTimer;
  final Duration debounceDuration;
  
  DebouncedNotifier({this.debounceDuration = const Duration(milliseconds: 300)});
  
  /// Update state with debouncing
  void debouncedUpdate(T newState) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(debounceDuration, () {
      state = newState;
    });
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}

/// Cached async provider with intelligent cache management
abstract class CachedAsyncNotifier<T> extends AsyncNotifier<T> 
    with PerformanceTrackingMixin {
  final Duration cacheDuration;
  final bool cacheFailures;
  DateTime? _lastCacheTime;
  T? _cachedValue;
  Object? _cachedError;
  
  CachedAsyncNotifier({
    this.cacheDuration = const Duration(minutes: 5),
    this.cacheFailures = false,
  });
  
  @override
  Future<T> build() async {
    // Check if we have valid cached data
    if (_lastCacheTime != null && 
        DateTime.now().difference(_lastCacheTime!) < cacheDuration) {
      if (_cachedValue != null) {
        return _cachedValue!;
      } else if (cacheFailures && _cachedError != null) {
        throw _cachedError!;
      }
    }
    
    try {
      final value = await fetchData();
      _cachedValue = value;
      _cachedError = null;
      _lastCacheTime = DateTime.now();
      return value;
    } catch (error) {
      if (cacheFailures) {
        _cachedError = error;
        _lastCacheTime = DateTime.now();
      }
      rethrow;
    }
  }
  
  /// Subclasses should implement this
  Future<T> fetchData();
  
  /// Force cache invalidation
  void invalidateCache() {
    _lastCacheTime = null;
    _cachedValue = null;
    _cachedError = null;
  }
  
  /// Check if cache is valid
  bool get isCacheValid {
    return _lastCacheTime != null && 
           DateTime.now().difference(_lastCacheTime!) < cacheDuration;
  }
}

/// State manager for complex state with optimizations
class OptimizedStateManager<T> {
  T _state;
  final StreamController<StateUpdate<T>> _controller = StreamController.broadcast();
  final Map<String, StateSelector<T, dynamic>> _selectors = {};
  final Queue<StateUpdate<T>> _history = Queue();
  final int maxHistorySize;
  
  OptimizedStateManager(
    T initialState, {
    this.maxHistorySize = 50,
  }) : _state = initialState;
  
  /// Current state
  T get state => _state;
  
  /// State updates stream
  Stream<StateUpdate<T>> get updates => _controller.stream;
  
  /// Update state with performance tracking
  void updateState(T newState, {String? reason}) {
    final previousState = _state;
    if (identical(previousState, newState)) return;
    
    final update = StateUpdate(previousState, newState, reason);
    
    _state = newState;
    _addToHistory(update);
    _notifySelectors(previousState, newState);
    _controller.add(update);
    
    PerformanceMonitorService.instance.incrementCounter('state_updates');
  }
  
  /// Select a part of the state with memoization
  R select<R>(String key, R Function(T state) selector) {
    final existingSelector = _selectors[key];
    if (existingSelector != null) {
      return existingSelector.select(_state) as R;
    }
    
    final newSelector = StateSelector<T, R>(selector);
    _selectors[key] = newSelector;
    return newSelector.select(_state);
  }
  
  /// Batch multiple updates
  void batchUpdate(List<T Function(T)> updates, {String? reason}) {
    T newState = _state;
    for (final update in updates) {
      newState = update(newState);
    }
    updateState(newState, reason: reason);
  }
  
  /// Undo last state change
  bool undo() {
    if (_history.length < 2) return false;
    
    _history.removeLast(); // Remove current state
    final previousUpdate = _history.last;
    _state = previousUpdate.previousState;
    
    _controller.add(StateUpdate(_state, _state, 'undo'));
    return true;
  }
  
  /// Get state history
  List<StateUpdate<T>> get history => _history.toList();
  
  void _addToHistory(StateUpdate<T> update) {
    _history.add(update);
    if (_history.length > maxHistorySize) {
      _history.removeFirst();
    }
  }
  
  void _notifySelectors(T previousState, T newState) {
    for (final selector in _selectors.values) {
      selector.checkForChanges(previousState, newState);
    }
  }
  
  /// Dispose the manager
  void dispose() {
    _controller.close();
  }
}

class StateUpdate<T> {
  final T previousState;
  final T newState;
  final String? reason;
  final DateTime timestamp;
  
  StateUpdate(this.previousState, this.newState, this.reason) 
      : timestamp = DateTime.now();
}

class StateSelector<T, R> {
  final R Function(T state) selector;
  R? _lastValue;
  final StreamController<R> _controller = StreamController.broadcast();
  
  StateSelector(this.selector);
  
  Stream<R> get updates => _controller.stream;
  
  R select(T state) {
    final value = selector(state);
    _lastValue = value;
    return value;
  }
  
  void checkForChanges(T previousState, T newState) {
    final previousValue = _lastValue;
    final newValue = selector(newState);
    
    if (previousValue != newValue) {
      _lastValue = newValue;
      _controller.add(newValue);
    }
  }
  
  void dispose() {
    _controller.close();
  }
}

/// Optimized list provider with virtual scrolling support
abstract class OptimizedListNotifier<T> extends Notifier<List<T>> 
    with PerformanceTrackingMixin {
  final int pageSize;
  final int maxItems;
  bool _isLoading = false;
  int _currentPage = 0;
  
  OptimizedListNotifier({
    this.pageSize = 20,
    this.maxItems = 1000,
  });
  
  bool get isLoading => _isLoading;
  int get currentPage => _currentPage;
  
  /// Load next page of items
  Future<void> loadNextPage() async {
    if (_isLoading || state.length >= maxItems) return;
    
    _isLoading = true;
    incrementCounter('list_page_loads');
    
    try {
      final items = await trackPerformanceAsync(
        'loadPage_${runtimeType}',
        () => fetchPage(_currentPage, pageSize),
      );
      
      final newList = List<T>.from(state)..addAll(items);
      
      // Trim list if it exceeds maxItems
      if (newList.length > maxItems) {
        newList.removeRange(0, newList.length - maxItems);
      }
      
      state = newList;
      _currentPage++;
    } catch (e) {
      recordMetric('list_load_errors', 1);
      rethrow;
    } finally {
      _isLoading = false;
    }
  }
  
  /// Fetch a specific page of items
  Future<List<T>> fetchPage(int page, int size);
  
  /// Add item to list with optimization
  void addItem(T item) {
    trackPerformance('addItem_${runtimeType}', () {
      final newList = List<T>.from(state)..add(item);
      state = newList;
    });
  }
  
  /// Remove item from list with optimization
  void removeItem(T item) {
    trackPerformance('removeItem_${runtimeType}', () {
      final newList = List<T>.from(state)..remove(item);
      state = newList;
    });
  }
  
  /// Update item in list with optimization
  void updateItem(T oldItem, T newItem) {
    trackPerformance('updateItem_${runtimeType}', () {
      final index = state.indexOf(oldItem);
      if (index >= 0) {
        final newList = List<T>.from(state);
        newList[index] = newItem;
        state = newList;
      }
    });
  }
  
  /// Clear list and reset pagination
  void clear() {
    state = <T>[];
    _currentPage = 0;
  }
  
  /// Refresh the list from the beginning
  Future<void> refresh() async {
    clear();
    await loadNextPage();
  }
}

/// Performance monitoring for providers
class ProviderPerformanceMonitor {
  static final Map<String, ProviderStats> _stats = {};
  
  /// Record provider rebuild
  static void recordRebuild(String providerName) {
    _stats.putIfAbsent(providerName, () => ProviderStats(providerName))
        .recordRebuild();
  }
  
  /// Record provider access
  static void recordAccess(String providerName) {
    _stats.putIfAbsent(providerName, () => ProviderStats(providerName))
        .recordAccess();
  }
  
  /// Get performance statistics
  static Map<String, dynamic> getStats() {
    return _stats.map((key, value) => MapEntry(key, value.toJson()));
  }
  
  /// Clear statistics
  static void clearStats() {
    _stats.clear();
  }
}

class ProviderStats {
  final String name;
  int rebuilds = 0;
  int accesses = 0;
  DateTime? lastRebuild;
  DateTime? lastAccess;
  final DateTime createdAt = DateTime.now();
  
  ProviderStats(this.name);
  
  void recordRebuild() {
    rebuilds++;
    lastRebuild = DateTime.now();
  }
  
  void recordAccess() {
    accesses++;
    lastAccess = DateTime.now();
  }
  
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'rebuilds': rebuilds,
      'accesses': accesses,
      'last_rebuild': lastRebuild?.toIso8601String(),
      'last_access': lastAccess?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'rebuild_rate': rebuilds > 0 && accesses > 0 ? rebuilds / accesses : 0,
    };
  }
}