import 'dart:async';
import 'dart:collection';
import 'dart:developer' as developer;
import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Memory optimization and garbage collection management service
class MemoryOptimizerService {
  static final MemoryOptimizerService _instance = MemoryOptimizerService._();
  static MemoryOptimizerService get instance => _instance;

  MemoryOptimizerService._();

  final StreamController<MemoryReport> _reportController = 
      StreamController<MemoryReport>.broadcast();
  
  Timer? _monitoringTimer;
  Timer? _cleanupTimer;
  bool _isOptimizing = false;
  
  // Memory pools and caches
  final LRUCache<String, Uint8List> _imageCache = LRUCache<String, Uint8List>(50);
  final LRUCache<String, dynamic> _dataCache = LRUCache<String, dynamic>(100);
  final ObjectPool<ByteData> _byteDataPool = ObjectPool<ByteData>(() => ByteData(1024));
  
  // Memory thresholds
  static const int _criticalMemoryThreshold = 256 * 1024 * 1024; // 256MB
  static const int _warningMemoryThreshold = 128 * 1024 * 1024;  // 128MB
  static const Duration _monitoringInterval = Duration(seconds: 30);
  static const Duration _cleanupInterval = Duration(minutes: 5);

  /// Initialize memory optimizer
  Future<void> initialize() async {
    if (_isOptimizing) return;
    
    try {
      _startMemoryMonitoring();
      _startPeriodicCleanup();
      _setupGCObserver();
      
      _isOptimizing = true;
      debugPrint('Memory optimizer initialized');
    } catch (e) {
      debugPrint('Failed to initialize memory optimizer: $e');
    }
  }

  /// Get memory reports stream
  Stream<MemoryReport> get reportsStream => _reportController.stream;

  /// Get current memory usage
  Future<MemoryUsage> getCurrentMemoryUsage() async {
    try {
      final info = await developer.Service.getInfo();
      final isolate = await developer.Service.getIsolate(info.serverUri.toString());
      
      final heapUsage = isolate?.heapUsage ?? 0;
      final heapCapacity = isolate?.heapCapacity ?? 0;
      final externalUsage = isolate?.externalUsage ?? 0;
      
      return MemoryUsage(
        heapUsed: heapUsage,
        heapCapacity: heapCapacity,
        externalUsage: externalUsage,
        timestamp: DateTime.now(),
      );
    } catch (e) {
      debugPrint('Failed to get memory usage: $e');
      return MemoryUsage(
        heapUsed: 0,
        heapCapacity: 0,
        externalUsage: 0,
        timestamp: DateTime.now(),
      );
    }
  }

  /// Force garbage collection
  void forceGarbageCollection() {
    try {
      developer.Service.forceGC();
      debugPrint('Forced garbage collection');
    } catch (e) {
      debugPrint('Failed to force GC: $e');
    }
  }

  /// Optimize memory usage
  Future<void> optimizeMemory() async {
    debugPrint('Starting memory optimization...');
    
    // Clear caches
    _imageCache.clear();
    _dataCache.clear();
    
    // Clear image cache
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    
    // Trim memory pools
    _byteDataPool.clear();
    
    // Force garbage collection
    forceGarbageCollection();
    
    // Wait a moment for GC to complete
    await Future.delayed(const Duration(milliseconds: 100));
    
    final usage = await getCurrentMemoryUsage();
    debugPrint('Memory optimization complete. Current usage: ${usage.heapUsed / 1024 / 1024:.1f}MB');
  }

  /// Setup memory monitoring
  void _startMemoryMonitoring() {
    _monitoringTimer = Timer.periodic(_monitoringInterval, (_) async {
      await _checkMemoryUsage();
    });
  }

  /// Setup periodic cleanup
  void _startPeriodicCleanup() {
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) async {
      await _performPeriodicCleanup();
    });
  }

  /// Setup garbage collection observer
  void _setupGCObserver() {
    if (kDebugMode) {
      developer.Service.controlWebServer(enable: true);
    }
  }

  /// Check current memory usage and take action if needed
  Future<void> _checkMemoryUsage() async {
    final usage = await getCurrentMemoryUsage();
    final totalMemory = usage.heapUsed + usage.externalUsage;
    
    MemoryStatus status;
    if (totalMemory > _criticalMemoryThreshold) {
      status = MemoryStatus.critical;
      await optimizeMemory();
    } else if (totalMemory > _warningMemoryThreshold) {
      status = MemoryStatus.warning;
      await _performLightCleanup();
    } else {
      status = MemoryStatus.normal;
    }
    
    final report = MemoryReport(
      usage: usage,
      status: status,
      timestamp: DateTime.now(),
      cacheStats: _getCacheStats(),
    );
    
    _reportController.add(report);
  }

  /// Perform light cleanup
  Future<void> _performLightCleanup() async {
    // Trim caches to 70% of capacity
    _imageCache.trimToSize((_imageCache.maxSize * 0.7).round());
    _dataCache.trimToSize((_dataCache.maxSize * 0.7).round());
    
    // Clear old image cache entries
    PaintingBinding.instance.imageCache.maximumSize = 
        (PaintingBinding.instance.imageCache.maximumSize * 0.8).round();
  }

  /// Perform periodic cleanup
  Future<void> _performPeriodicCleanup() async {
    // Cleanup expired cache entries
    _imageCache.removeExpired();
    _dataCache.removeExpired();
    
    // Trim object pools
    _byteDataPool.trim();
    
    // Clear unused images
    PaintingBinding.instance.imageCache.clearLiveImages();
  }

  /// Get cache statistics
  Map<String, dynamic> _getCacheStats() {
    return {
      'image_cache_size': _imageCache.length,
      'image_cache_max': _imageCache.maxSize,
      'data_cache_size': _dataCache.length,
      'data_cache_max': _dataCache.maxSize,
      'byte_pool_size': _byteDataPool.size,
      'flutter_image_cache': PaintingBinding.instance.imageCache.currentSize,
      'flutter_image_cache_max': PaintingBinding.instance.imageCache.maximumSize,
    };
  }

  /// Cache image data
  void cacheImageData(String key, Uint8List data) {
    _imageCache.put(key, data);
  }

  /// Get cached image data
  Uint8List? getCachedImageData(String key) {
    return _imageCache.get(key);
  }

  /// Cache generic data
  void cacheData(String key, dynamic data) {
    _dataCache.put(key, data);
  }

  /// Get cached data
  T? getCachedData<T>(String key) {
    return _dataCache.get(key) as T?;
  }

  /// Get or create ByteData from pool
  ByteData getBorrowByteData(int size) {
    return _byteDataPool.borrow() ?? ByteData(size);
  }

  /// Return ByteData to pool
  void returnByteData(ByteData data) {
    _byteDataPool.return(data);
  }

  /// Dispose the service
  void dispose() {
    _monitoringTimer?.cancel();
    _cleanupTimer?.cancel();
    _reportController.close();
    _imageCache.clear();
    _dataCache.clear();
    _byteDataPool.clear();
    _isOptimizing = false;
  }
}

/// LRU Cache implementation
class LRUCache<K, V> {
  final int maxSize;
  final Duration? expiration;
  final LinkedHashMap<K, _CacheEntry<V>> _cache = LinkedHashMap();

  LRUCache(this.maxSize, {this.expiration});

  int get length => _cache.length;

  /// Put item in cache
  void put(K key, V value) {
    if (_cache.containsKey(key)) {
      _cache.remove(key);
    } else if (_cache.length >= maxSize) {
      _cache.remove(_cache.keys.first);
    }
    
    _cache[key] = _CacheEntry(value, DateTime.now());
  }

  /// Get item from cache
  V? get(K key) {
    final entry = _cache.remove(key);
    if (entry == null) return null;
    
    // Check expiration
    if (expiration != null && 
        DateTime.now().difference(entry.timestamp) > expiration!) {
      return null;
    }
    
    // Move to end (most recently used)
    _cache[key] = entry;
    return entry.value;
  }

  /// Remove expired entries
  void removeExpired() {
    if (expiration == null) return;
    
    final now = DateTime.now();
    _cache.removeWhere((key, entry) => 
        now.difference(entry.timestamp) > expiration!);
  }

  /// Trim cache to specific size
  void trimToSize(int newSize) {
    while (_cache.length > newSize && _cache.isNotEmpty) {
      _cache.remove(_cache.keys.first);
    }
  }

  /// Clear all entries
  void clear() {
    _cache.clear();
  }
}

class _CacheEntry<V> {
  final V value;
  final DateTime timestamp;

  _CacheEntry(this.value, this.timestamp);
}

/// Object pool for reusing expensive objects
class ObjectPool<T> {
  final T Function() factory;
  final Queue<T> _pool = Queue();
  final int maxSize;
  
  ObjectPool(this.factory, {this.maxSize = 20});

  int get size => _pool.length;

  /// Borrow object from pool
  T? borrow() {
    if (_pool.isNotEmpty) {
      return _pool.removeFirst();
    }
    return null;
  }

  /// Return object to pool
  void return(T object) {
    if (_pool.length < maxSize) {
      _pool.add(object);
    }
  }

  /// Trim pool size
  void trim() {
    while (_pool.length > maxSize ~/ 2) {
      _pool.removeLast();
    }
  }

  /// Clear pool
  void clear() {
    _pool.clear();
  }
}

/// Memory usage data class
class MemoryUsage {
  final int heapUsed;
  final int heapCapacity;
  final int externalUsage;
  final DateTime timestamp;

  const MemoryUsage({
    required this.heapUsed,
    required this.heapCapacity,
    required this.externalUsage,
    required this.timestamp,
  });

  int get totalUsage => heapUsed + externalUsage;
  double get heapUtilization => heapCapacity > 0 ? heapUsed / heapCapacity : 0;

  Map<String, dynamic> toJson() => {
    'heap_used': heapUsed,
    'heap_capacity': heapCapacity,
    'external_usage': externalUsage,
    'total_usage': totalUsage,
    'heap_utilization': heapUtilization,
    'timestamp': timestamp.toIso8601String(),
  };
}

/// Memory report data class
class MemoryReport {
  final MemoryUsage usage;
  final MemoryStatus status;
  final DateTime timestamp;
  final Map<String, dynamic> cacheStats;

  const MemoryReport({
    required this.usage,
    required this.status,
    required this.timestamp,
    required this.cacheStats,
  });

  Map<String, dynamic> toJson() => {
    'usage': usage.toJson(),
    'status': status.toString(),
    'timestamp': timestamp.toIso8601String(),
    'cache_stats': cacheStats,
  };
}

/// Memory status enumeration
enum MemoryStatus {
  normal,
  warning,
  critical,
}

/// Memory-optimized widget base classes
abstract class MemoryOptimizedStatelessWidget extends StatelessWidget {
  const MemoryOptimizedStatelessWidget({Key? key}) : super(key: key);

  @override
  StatelessElement createElement() {
    return _MemoryOptimizedStatelessElement(this);
  }
}

abstract class MemoryOptimizedStatefulWidget extends StatefulWidget {
  const MemoryOptimizedStatefulWidget({Key? key}) : super(key: key);

  @override
  StatefulElement createElement() {
    return _MemoryOptimizedStatefulElement(this);
  }
}

class _MemoryOptimizedStatelessElement extends StatelessElement {
  _MemoryOptimizedStatelessElement(StatelessWidget widget) : super(widget);

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _registerMemoryUsage();
  }

  @override
  void unmount() {
    _unregisterMemoryUsage();
    super.unmount();
  }

  void _registerMemoryUsage() {
    // Track widget memory usage
  }

  void _unregisterMemoryUsage() {
    // Clean up widget resources
  }
}

class _MemoryOptimizedStatefulElement extends StatefulElement {
  _MemoryOptimizedStatefulElement(StatefulWidget widget) : super(widget);

  @override
  void mount(Element? parent, dynamic newSlot) {
    super.mount(parent, newSlot);
    _registerMemoryUsage();
  }

  @override
  void unmount() {
    _unregisterMemoryUsage();
    super.unmount();
  }

  void _registerMemoryUsage() {
    // Track widget memory usage
  }

  void _unregisterMemoryUsage() {
    // Clean up widget resources
  }
}

/// Memory-efficient image widget
class MemoryEfficientImage extends StatefulWidget {
  final String? url;
  final String? assetPath;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;

  const MemoryEfficientImage({
    Key? key,
    this.url,
    this.assetPath,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
  }) : super(key: key);

  @override
  State<MemoryEfficientImage> createState() => _MemoryEfficientImageState();
}

class _MemoryEfficientImageState extends State<MemoryEfficientImage> {
  final MemoryOptimizerService _optimizer = MemoryOptimizerService.instance;
  Uint8List? _cachedImageData;
  ui.Image? _decodedImage;

  @override
  void initState() {
    super.initState();
    _loadImage();
  }

  @override
  void dispose() {
    _decodedImage?.dispose();
    super.dispose();
  }

  Future<void> _loadImage() async {
    if (widget.url == null && widget.assetPath == null) return;
    
    final cacheKey = widget.url ?? widget.assetPath!;
    
    // Try to get from cache first
    _cachedImageData = _optimizer.getCachedImageData(cacheKey);
    
    if (_cachedImageData != null) {
      await _decodeImage(_cachedImageData!);
      return;
    }
    
    // Load and cache image
    try {
      Uint8List? imageData;
      
      if (widget.url != null) {
        final client = HttpClient();
        final request = await client.getUrl(Uri.parse(widget.url!));
        final response = await request.close();
        imageData = await consolidateHttpClientResponseBytes(response);
      } else if (widget.assetPath != null) {
        final data = await rootBundle.load(widget.assetPath!);
        imageData = data.buffer.asUint8List();
      }
      
      if (imageData != null) {
        _optimizer.cacheImageData(cacheKey, imageData);
        await _decodeImage(imageData);
      }
    } catch (e) {
      debugPrint('Failed to load image: $e');
    }
  }

  Future<void> _decodeImage(Uint8List data) async {
    try {
      final codec = await ui.instantiateImageCodec(
        data,
        targetWidth: widget.width?.toInt(),
        targetHeight: widget.height?.toInt(),
      );
      final frame = await codec.getNextFrame();
      
      if (mounted) {
        setState(() {
          _decodedImage = frame.image;
        });
      }
    } catch (e) {
      debugPrint('Failed to decode image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_decodedImage != null) {
      return CustomPaint(
        size: Size(
          widget.width ?? _decodedImage!.width.toDouble(),
          widget.height ?? _decodedImage!.height.toDouble(),
        ),
        painter: _ImagePainter(_decodedImage!, widget.fit),
      );
    }
    
    return widget.placeholder ?? 
      Container(
        width: widget.width,
        height: widget.height,
        color: Colors.grey[300],
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
  }
}

class _ImagePainter extends CustomPainter {
  final ui.Image image;
  final BoxFit? fit;

  _ImagePainter(this.image, this.fit);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint();
    
    // Calculate scaling and positioning based on BoxFit
    final imageSize = Size(image.width.toDouble(), image.height.toDouble());
    final fittedSizes = applyBoxFit(fit ?? BoxFit.cover, imageSize, size);
    final sourceSize = fittedSizes.source;
    final destinationSize = fittedSizes.destination;
    
    final sourceRect = Rect.fromLTWH(0, 0, sourceSize.width, sourceSize.height);
    final destinationRect = Rect.fromLTWH(
      (size.width - destinationSize.width) / 2,
      (size.height - destinationSize.height) / 2,
      destinationSize.width,
      destinationSize.height,
    );
    
    canvas.drawImageRect(image, sourceRect, destinationRect, paint);
  }

  @override
  bool shouldRepaint(_ImagePainter oldDelegate) {
    return oldDelegate.image != image || oldDelegate.fit != fit;
  }
}

/// Memory monitoring widget
class MemoryMonitorWidget extends StatefulWidget {
  final Widget child;
  final bool showOverlay;

  const MemoryMonitorWidget({
    Key? key,
    required this.child,
    this.showOverlay = false,
  }) : super(key: key);

  @override
  State<MemoryMonitorWidget> createState() => _MemoryMonitorWidgetState();
}

class _MemoryMonitorWidgetState extends State<MemoryMonitorWidget> {
  final MemoryOptimizerService _optimizer = MemoryOptimizerService.instance;
  MemoryUsage? _currentUsage;
  StreamSubscription<MemoryReport>? _subscription;

  @override
  void initState() {
    super.initState();
    _optimizer.initialize();
    
    _subscription = _optimizer.reportsStream.listen((report) {
      if (mounted) {
        setState(() {
          _currentUsage = report.usage;
        });
      }
    });
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        widget.child,
        if (widget.showOverlay && _currentUsage != null && kDebugMode)
          Positioned(
            top: 80,
            right: 16,
            child: _buildMemoryOverlay(),
          ),
      ],
    );
  }

  Widget _buildMemoryOverlay() {
    final usage = _currentUsage!;
    final heapMB = usage.heapUsed / 1024 / 1024;
    final totalMB = usage.totalUsage / 1024 / 1024;
    
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(4),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Memory Usage',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            'Heap: ${heapMB.toStringAsFixed(1)} MB',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Total: ${totalMB.toStringAsFixed(1)} MB',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
          Text(
            'Utilization: ${(usage.heapUtilization * 100).toStringAsFixed(1)}%',
            style: const TextStyle(color: Colors.white, fontSize: 10),
          ),
        ],
      ),
    );
  }
}