import 'dart:convert';
import 'dart:html' as html;
import 'dart:js' as js;
import 'package:flutter/material.dart';
import 'better_player_widget.dart';

/// Shared media gallery widget that uses the same core logic as web
/// Bridges to JavaScript MediaGalleryCore for consistency
class SharedMediaGallery extends StatefulWidget {
  final List<MediaItem> items;
  final bool enableDeepLinking;
  final bool enableKeyboardNav;
  final bool enableLazyLoading;
  final String? className;
  final Function(MediaItem, int)? onMediaOpen;
  final Function()? onMediaClose;
  final Function(MediaItem, int)? onMediaChange;

  const SharedMediaGallery({
    super.key,
    required this.items,
    this.enableDeepLinking = true,
    this.enableKeyboardNav = true,
    this.enableLazyLoading = true,
    this.className,
    this.onMediaOpen,
    this.onMediaClose,
    this.onMediaChange,
  });

  @override
  State<SharedMediaGallery> createState() => _SharedMediaGalleryState();
}

class _SharedMediaGalleryState extends State<SharedMediaGallery> {
  late js.JsObject _galleryCore;
  int? _currentIndex;
  bool _isFullscreen = false;

  @override
  void initState() {
    super.initState();
    _initializeGalleryCore();
  }

  void _initializeGalleryCore() {
    final config = {
      'items': widget.items.map((item) => item.toJson()).toList(),
      'enableDeepLinking': widget.enableDeepLinking,
      'enableKeyboardNav': widget.enableKeyboardNav,
      'enableLazyLoading': widget.enableLazyLoading,
      'thumbnailCols': {
        'mobile': 2,
        'tablet': 3,
        'desktop': 4,
      },
    };

    final callbacks = js.JsObject.jsify({
      'onMediaOpen': (item, index) {
        setState(() {
          _currentIndex = index;
          _isFullscreen = true;
        });
        widget.onMediaOpen?.call(MediaItem.fromJson(item), index);
      },
      'onMediaClose': () {
        setState(() {
          _currentIndex = null;
          _isFullscreen = false;
        });
        widget.onMediaClose?.call();
      },
      'onMediaChange': (item, index) {
        setState(() {
          _currentIndex = index;
        });
        widget.onMediaChange?.call(MediaItem.fromJson(item), index);
      },
    });

    // Initialize the JavaScript MediaGalleryCore
    _galleryCore = js.JsObject(
      js.context['MediaGalleryCore'],
      [js.JsObject.jsify(config), callbacks]
    );
  }

  void _openMedia(int index) {
    _galleryCore.callMethod('openMedia', [index]);
  }

  void _closeMedia() {
    _galleryCore.callMethod('closeMedia');
  }

  void _nextMedia() {
    _galleryCore.callMethod('nextMedia');
  }

  void _prevMedia() {
    _galleryCore.callMethod('prevMedia');
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Thumbnail grid
        _buildThumbnailGrid(),

        // Fullscreen overlay
        if (_isFullscreen) _buildFullscreenOverlay(),
      ],
    );
  }

  Widget _buildThumbnailGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: _getCrossAxisCount(),
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
        childAspectRatio: 1.0,
      ),
      itemCount: widget.items.length,
      itemBuilder: (context, index) {
        return _buildThumbnail(widget.items[index], index);
      },
    );
  }

  int _getCrossAxisCount() {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 2; // mobile
    if (width < 1200) return 3; // tablet
    return 4; // desktop
  }

  Widget _buildThumbnail(MediaItem item, int index) {
    return GestureDetector(
      onTap: () => _openMedia(index),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(8),
          color: Colors.grey[200],
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Image/Video thumbnail
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: item.type == 'image'
                  ? Image.network(
                      item.thumbnail ?? item.url,
                      fit: BoxFit.cover,
                      loadingBuilder: (context, child, loadingProgress) {
                        if (loadingProgress == null) return child;
                        return Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        );
                      },
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          color: Colors.grey[300],
                          child: const Icon(Icons.error),
                        );
                      },
                    )
                  : Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          item.thumbnail ?? item.url,
                          fit: BoxFit.cover,
                        ),
                        const Center(
                          child: Icon(
                            Icons.play_circle_filled,
                            size: 48,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
            ),

            // Hover overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.1),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFullscreenOverlay() {
    if (_currentIndex == null) return const SizedBox.shrink();

    final item = widget.items[_currentIndex!];

    return Positioned.fill(
      child: Material(
        color: Colors.black87,
        child: Stack(
          children: [
            // Background tap to close
            GestureDetector(
              onTap: _closeMedia,
              child: Container(color: Colors.transparent),
            ),

            // Media content
            Center(
              child: Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: item.type == 'image'
                    ? Image.network(
                        item.url,
                        fit: BoxFit.contain,
                      )
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayerWidget(videoUrl: item.url),
                      ),
              ),
            ),

            // Navigation controls
            if (widget.items.length > 1) ...[
              // Previous button
              if (_currentIndex! > 0)
                Positioned(
                  left: 16,
                  top: MediaQuery.of(context).size.height / 2 - 24,
                  child: IconButton(
                    onPressed: _prevMedia,
                    icon: const Icon(Icons.chevron_left, size: 48, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),

              // Next button
              if (_currentIndex! < widget.items.length - 1)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height / 2 - 24,
                  child: IconButton(
                    onPressed: _nextMedia,
                    icon: const Icon(Icons.chevron_right, size: 48, color: Colors.white),
                    style: IconButton.styleFrom(
                      backgroundColor: Colors.black54,
                    ),
                  ),
                ),
            ],

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: IconButton(
                onPressed: _closeMedia,
                icon: const Icon(Icons.close, size: 32, color: Colors.white),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black54,
                ),
              ),
            ),

            // Counter
            if (widget.items.length > 1)
              Positioned(
                bottom: MediaQuery.of(context).padding.bottom + 16,
                left: 0,
                right: 0,
                child: Center(
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${_currentIndex! + 1} / ${widget.items.length}',
                      style: const TextStyle(color: Colors.white, fontSize: 16),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class MediaItem {
  final String id;
  final String type;
  final String url;
  final String? thumbnail;
  final String? title;
  final String? alt;
  final int? width;
  final int? height;

  const MediaItem({
    required this.id,
    required this.type,
    required this.url,
    this.thumbnail,
    this.title,
    this.alt,
    this.width,
    this.height,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'url': url,
      'thumbnail': thumbnail,
      'title': title,
      'alt': alt,
      'width': width,
      'height': height,
    };
  }

  factory MediaItem.fromJson(Map<String, dynamic> json) {
    return MediaItem(
      id: json['id'],
      type: json['type'],
      url: json['url'],
      thumbnail: json['thumbnail'],
      title: json['title'],
      alt: json['alt'],
      width: json['width'],
      height: json['height'],
    );
  }
}

// Video player widget using the existing BetterPlayerWidget
class VideoPlayerWidget extends StatelessWidget {
  final String videoUrl;

  const VideoPlayerWidget({super.key, required this.videoUrl});

  @override
  Widget build(BuildContext context) {
    return BetterPlayerWidget(
      videoUrl: videoUrl,
      autoPlay: true,
      showControls: true,
    );
  }
}