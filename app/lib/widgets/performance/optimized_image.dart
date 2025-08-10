import 'dart:io';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:path_provider/path_provider.dart';
import 'package:crypto/crypto.dart';
import 'dart:convert';

/// High-performance image widget with advanced caching and lazy loading
class OptimizedImage extends StatefulWidget {
  final String? url;
  final String? assetPath;
  final File? file;
  final Uint8List? bytes;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool fadeIn;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? cacheExpiration;
  final Map<String, String>? headers;
  final bool preloadImage;
  final VoidCallback? onImageLoaded;
  final VoidCallback? onImageError;
  final ImageQuality quality;
  final bool enableProgressive;
  final double? memoryScale;

  const OptimizedImage({
    Key? key,
    this.url,
    this.assetPath,
    this.file,
    this.bytes,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeOut,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.cacheExpiration,
    this.headers,
    this.preloadImage = false,
    this.onImageLoaded,
    this.onImageError,
    this.quality = ImageQuality.high,
    this.enableProgressive = true,
    this.memoryScale,
  }) : super(key: key);

  @override
  State<OptimizedImage> createState() => _OptimizedImageState();
}

class _OptimizedImageState extends State<OptimizedImage> {
  bool _isInView = false;
  bool _hasLoaded = false;

  @override
  void initState() {
    super.initState();
    if (widget.preloadImage) {
      _preloadImage();
    }
  }

  void _preloadImage() {
    if (widget.url != null) {
      precacheImage(
        CachedNetworkImageProvider(widget.url!),
        context,
      ).then((_) {
        widget.onImageLoaded?.call();
      }).catchError((error) {
        widget.onImageError?.call();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (widget.bytes != null) {
      return _buildMemoryImage();
    } else if (widget.file != null) {
      return _buildFileImage();
    } else if (widget.assetPath != null) {
      return _buildAssetImage();
    } else if (widget.url != null) {
      return _buildNetworkImage();
    } else {
      return _buildErrorWidget();
    }
  }

  Widget _buildMemoryImage() {
    return Image.memory(
      widget.bytes!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      scale: widget.memoryScale ?? 1.0,
      frameBuilder: widget.fadeIn ? _buildFadeInFrame : null,
    );
  }

  Widget _buildFileImage() {
    return Image.file(
      widget.file!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: widget.fadeIn ? _buildFadeInFrame : null,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildAssetImage() {
    return Image.asset(
      widget.assetPath!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      frameBuilder: widget.fadeIn ? _buildFadeInFrame : null,
      errorBuilder: (context, error, stackTrace) => _buildErrorWidget(),
    );
  }

  Widget _buildNetworkImage() {
    return LazyLoadImage(
      url: widget.url!,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: widget.placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: widget.errorWidget ?? _buildErrorWidget(),
      fadeIn: widget.fadeIn,
      fadeInDuration: widget.fadeInDuration,
      fadeInCurve: widget.fadeInCurve,
      enableMemoryCache: widget.enableMemoryCache,
      enableDiskCache: widget.enableDiskCache,
      cacheExpiration: widget.cacheExpiration,
      headers: widget.headers,
      quality: widget.quality,
      enableProgressive: widget.enableProgressive,
      onImageLoaded: () {
        setState(() => _hasLoaded = true);
        widget.onImageLoaded?.call();
      },
      onImageError: widget.onImageError,
    );
  }

  Widget _buildFadeInFrame(
    BuildContext context,
    Widget child,
    int? frame,
    bool wasSynchronouslyLoaded,
  ) {
    if (wasSynchronouslyLoaded) return child;
    
    return AnimatedOpacity(
      opacity: frame == null ? 0 : 1,
      duration: widget.fadeInDuration,
      curve: widget.fadeInCurve,
      child: child,
    );
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      child: const Center(
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return widget.errorWidget ?? Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.grey,
        ),
      ),
    );
  }
}

/// Lazy loading image widget that only loads when visible
class LazyLoadImage extends StatefulWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final bool fadeIn;
  final Duration fadeInDuration;
  final Curve fadeInCurve;
  final bool enableMemoryCache;
  final bool enableDiskCache;
  final Duration? cacheExpiration;
  final Map<String, String>? headers;
  final VoidCallback? onImageLoaded;
  final VoidCallback? onImageError;
  final ImageQuality quality;
  final bool enableProgressive;

  const LazyLoadImage({
    Key? key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.fadeIn = true,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.fadeInCurve = Curves.easeOut,
    this.enableMemoryCache = true,
    this.enableDiskCache = true,
    this.cacheExpiration,
    this.headers,
    this.onImageLoaded,
    this.onImageError,
    this.quality = ImageQuality.high,
    this.enableProgressive = true,
  }) : super(key: key);

  @override
  State<LazyLoadImage> createState() => _LazyLoadImageState();
}

class _LazyLoadImageState extends State<LazyLoadImage> {
  bool _isVisible = false;
  bool _hasStartedLoading = false;

  @override
  Widget build(BuildContext context) {
    return VisibilityDetector(
      key: ValueKey(widget.url),
      onVisibilityChanged: (info) {
        if (info.visibleFraction > 0.1 && !_hasStartedLoading) {
          setState(() {
            _isVisible = true;
            _hasStartedLoading = true;
          });
        }
      },
      child: _isVisible ? _buildImage() : _buildPlaceholder(),
    );
  }

  Widget _buildImage() {
    return CachedNetworkImage(
      imageUrl: widget.url,
      width: widget.width,
      height: widget.height,
      fit: widget.fit,
      placeholder: (context, url) => widget.placeholder ?? _buildDefaultPlaceholder(),
      errorWidget: (context, url, error) {
        widget.onImageError?.call();
        return widget.errorWidget ?? _buildDefaultErrorWidget();
      },
      fadeInDuration: widget.fadeIn ? widget.fadeInDuration : Duration.zero,
      fadeInCurve: widget.fadeInCurve,
      memCacheWidth: _getMemoryCacheSize()?.width,
      memCacheHeight: _getMemoryCacheSize()?.height,
      httpHeaders: widget.headers,
      cacheManager: CustomCacheManager.instance,
      imageBuilder: (context, imageProvider) {
        widget.onImageLoaded?.call();
        return Image(
          image: imageProvider,
          width: widget.width,
          height: widget.height,
          fit: widget.fit,
        );
      },
    );
  }

  Widget _buildPlaceholder() {
    return widget.placeholder ?? _buildDefaultPlaceholder();
  }

  Widget _buildDefaultPlaceholder() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.image_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  Widget _buildDefaultErrorWidget() {
    return Container(
      width: widget.width,
      height: widget.height,
      color: Colors.grey.shade300,
      child: const Center(
        child: Icon(
          Icons.broken_image_outlined,
          color: Colors.grey,
        ),
      ),
    );
  }

  Size? _getMemoryCacheSize() {
    if (widget.width != null && widget.height != null) {
      final scale = _getQualityScale();
      return Size(
        (widget.width! * scale).round().toDouble(),
        (widget.height! * scale).round().toDouble(),
      );
    }
    return null;
  }

  double _getQualityScale() {
    switch (widget.quality) {
      case ImageQuality.low:
        return 0.5;
      case ImageQuality.medium:
        return 0.75;
      case ImageQuality.high:
        return 1.0;
      case ImageQuality.original:
        return 2.0;
    }
  }
}

/// Custom visibility detector for lazy loading
class VisibilityDetector extends StatefulWidget {
  final Key key;
  final Widget child;
  final Function(VisibilityInfo) onVisibilityChanged;

  const VisibilityDetector({
    required this.key,
    required this.child,
    required this.onVisibilityChanged,
  }) : super(key: key);

  @override
  State<VisibilityDetector> createState() => _VisibilityDetectorState();
}

class _VisibilityDetectorState extends State<VisibilityDetector> {
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          _checkVisibility();
        });
        return false;
      },
      child: widget.child,
    );
  }

  void _checkVisibility() {
    final renderObject = context.findRenderObject();
    if (renderObject != null && renderObject is RenderBox) {
      final viewport = RenderAbstractViewport.of(renderObject);
      if (viewport != null) {
        final offsetToRevealTop = viewport.getOffsetToReveal(renderObject, 0.0);
        final offsetToRevealBottom = viewport.getOffsetToReveal(renderObject, 1.0);
        
        final visibleFraction = _calculateVisibleFraction(
          offsetToRevealTop.offset,
          offsetToRevealBottom.offset,
          renderObject.size.height,
          viewport.semanticBounds.height,
        );

        widget.onVisibilityChanged(VisibilityInfo(
          visibleFraction: visibleFraction,
        ));
      }
    }
  }

  double _calculateVisibleFraction(
    double offsetTop,
    double offsetBottom,
    double itemHeight,
    double viewportHeight,
  ) {
    if (offsetTop >= viewportHeight || offsetBottom <= 0) {
      return 0.0; // Not visible
    }
    
    final visibleTop = offsetTop < 0 ? 0.0 : offsetTop;
    final visibleBottom = offsetBottom > viewportHeight ? viewportHeight : offsetBottom;
    final visibleHeight = visibleBottom - visibleTop;
    
    return (visibleHeight / itemHeight).clamp(0.0, 1.0);
  }
}

class VisibilityInfo {
  final double visibleFraction;
  
  const VisibilityInfo({
    required this.visibleFraction,
  });
}

/// Custom cache manager for advanced image caching
class CustomCacheManager {
  static CustomCacheManager? _instance;
  static CustomCacheManager get instance => _instance ??= CustomCacheManager._();

  CustomCacheManager._();

  // Cache configuration
  static const Duration _maxCacheAge = Duration(days: 30);
  static const int _maxNrOfCacheObjects = 200;
  static const int _maxCacheSizeBytes = 100 * 1024 * 1024; // 100 MB

  /// Get cached image file or download and cache
  Future<File?> getSingleFile(
    String url, {
    Map<String, String>? headers,
    Duration? maxAge,
  }) async {
    try {
      final cacheKey = _generateCacheKey(url);
      final cacheFile = await _getCacheFile(cacheKey);
      
      // Check if cached file exists and is still valid
      if (await cacheFile.exists()) {
        final fileAge = DateTime.now().difference(
          await cacheFile.lastModified(),
        );
        
        if (fileAge < (maxAge ?? _maxCacheAge)) {
          return cacheFile;
        }
      }
      
      // Download and cache the file
      return await _downloadAndCache(url, cacheFile, headers);
    } catch (e) {
      debugPrint('Cache manager error: $e');
      return null;
    }
  }

  /// Clear all cached images
  Future<void> clearCache() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (await cacheDir.exists()) {
        await cacheDir.delete(recursive: true);
        await cacheDir.create();
      }
    } catch (e) {
      debugPrint('Failed to clear cache: $e');
    }
  }

  /// Get cache size in bytes
  Future<int> getCacheSize() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return 0;
      
      int totalSize = 0;
      await for (final entity in cacheDir.list(recursive: true)) {
        if (entity is File) {
          totalSize += await entity.length();
        }
      }
      return totalSize;
    } catch (e) {
      debugPrint('Failed to get cache size: $e');
      return 0;
    }
  }

  /// Clean up old cache files
  Future<void> cleanup() async {
    try {
      final cacheDir = await _getCacheDirectory();
      if (!await cacheDir.exists()) return;
      
      final files = <File>[];
      await for (final entity in cacheDir.list()) {
        if (entity is File) {
          files.add(entity);
        }
      }
      
      // Sort by last modified date
      files.sort((a, b) => a.lastModifiedSync().compareTo(b.lastModifiedSync()));
      
      // Remove old files if we exceed limits
      if (files.length > _maxNrOfCacheObjects) {
        final filesToDelete = files.take(files.length - _maxNrOfCacheObjects);
        for (final file in filesToDelete) {
          try {
            await file.delete();
          } catch (e) {
            debugPrint('Failed to delete cache file: $e');
          }
        }
      }
      
      // Check size limits
      final cacheSize = await getCacheSize();
      if (cacheSize > _maxCacheSizeBytes) {
        // Delete oldest files until under size limit
        final remainingFiles = files.skip(files.length - _maxNrOfCacheObjects).toList();
        int currentSize = cacheSize;
        
        for (final file in remainingFiles) {
          if (currentSize <= _maxCacheSizeBytes * 0.8) break; // Leave some buffer
          
          try {
            final fileSize = await file.length();
            await file.delete();
            currentSize -= fileSize;
          } catch (e) {
            debugPrint('Failed to delete cache file: $e');
          }
        }
      }
    } catch (e) {
      debugPrint('Cache cleanup failed: $e');
    }
  }

  String _generateCacheKey(String url) {
    final bytes = utf8.encode(url);
    final digest = sha256.convert(bytes);
    return digest.toString();
  }

  Future<Directory> _getCacheDirectory() async {
    final tempDir = await getTemporaryDirectory();
    final cacheDir = Directory('${tempDir.path}/image_cache');
    if (!await cacheDir.exists()) {
      await cacheDir.create(recursive: true);
    }
    return cacheDir;
  }

  Future<File> _getCacheFile(String cacheKey) async {
    final cacheDir = await _getCacheDirectory();
    return File('${cacheDir.path}/$cacheKey');
  }

  Future<File?> _downloadAndCache(
    String url,
    File cacheFile,
    Map<String, String>? headers,
  ) async {
    try {
      final httpClient = HttpClient();
      final request = await httpClient.getUrl(Uri.parse(url));
      
      // Add headers
      headers?.forEach((key, value) {
        request.headers.add(key, value);
      });
      
      final response = await request.close();
      
      if (response.statusCode == 200) {
        final bytes = await consolidateHttpClientResponseBytes(response);
        await cacheFile.writeAsBytes(bytes);
        return cacheFile;
      }
    } catch (e) {
      debugPrint('Failed to download and cache image: $e');
    }
    
    return null;
  }
}

/// Image quality presets
enum ImageQuality {
  low,      // 0.5x scale
  medium,   // 0.75x scale
  high,     // 1.0x scale
  original, // 2.0x scale
}

/// Progressive image loading widget
class ProgressiveImage extends StatefulWidget {
  final String url;
  final String? lowResUrl;
  final double? width;
  final double? height;
  final BoxFit? fit;
  final Widget? placeholder;

  const ProgressiveImage({
    Key? key,
    required this.url,
    this.lowResUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
  }) : super(key: key);

  @override
  State<ProgressiveImage> createState() => _ProgressiveImageState();
}

class _ProgressiveImageState extends State<ProgressiveImage> {
  bool _highResLoaded = false;

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // Low resolution image (loads first)
        if (widget.lowResUrl != null)
          OptimizedImage(
            url: widget.lowResUrl!,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            placeholder: widget.placeholder,
            quality: ImageQuality.low,
          ),
        
        // High resolution image (loads second)
        AnimatedOpacity(
          opacity: _highResLoaded ? 1.0 : 0.0,
          duration: const Duration(milliseconds: 300),
          child: OptimizedImage(
            url: widget.url,
            width: widget.width,
            height: widget.height,
            fit: widget.fit,
            quality: ImageQuality.high,
            onImageLoaded: () {
              setState(() => _highResLoaded = true);
            },
          ),
        ),
      ],
    );
  }
}