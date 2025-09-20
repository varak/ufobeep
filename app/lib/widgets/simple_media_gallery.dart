import 'package:flutter/material.dart';
import 'better_player_widget.dart';

/// Simple media gallery widget for mobile Flutter app
/// Displays media items in a grid with fullscreen viewer
class SimpleMediaGallery extends StatefulWidget {
  final List<MediaItem> items;
  final bool enableLazyLoading;
  final Function(MediaItem, int)? onMediaOpen;
  final Function()? onMediaClose;
  final Function(MediaItem, int)? onMediaChange;

  const SimpleMediaGallery({
    super.key,
    required this.items,
    this.enableLazyLoading = true,
    this.onMediaOpen,
    this.onMediaClose,
    this.onMediaChange,
  });

  @override
  State<SimpleMediaGallery> createState() => _SimpleMediaGalleryState();
}

class _SimpleMediaGalleryState extends State<SimpleMediaGallery> {
  int? _currentIndex;
  bool _isFullscreen = false;

  void _openMedia(int index) {
    // Call external handler instead of internal fullscreen
    final item = widget.items[index];
    widget.onMediaOpen?.call(item, index);
    widget.onMediaChange?.call(item, index);

    // Disable internal fullscreen - use external viewer
    // setState(() {
    //   _currentIndex = index;
    //   _isFullscreen = true;
    // });
  }

  void _closeMedia() {
    setState(() {
      _currentIndex = null;
      _isFullscreen = false;
    });
    widget.onMediaClose?.call();
  }

  void _nextMedia() {
    if (_currentIndex == null || _currentIndex! >= widget.items.length - 1) return;

    final newIndex = _currentIndex! + 1;
    setState(() {
      _currentIndex = newIndex;
    });

    final item = widget.items[newIndex];
    widget.onMediaChange?.call(item, newIndex);
  }

  void _prevMedia() {
    if (_currentIndex == null || _currentIndex! <= 0) return;

    final newIndex = _currentIndex! - 1;
    setState(() {
      _currentIndex = newIndex;
    });

    final item = widget.items[newIndex];
    widget.onMediaChange?.call(item, newIndex);
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
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
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.grey[800],
                              child: const Icon(
                                Icons.videocam,
                                color: Colors.white,
                                size: 32,
                              ),
                            );
                          },
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
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(8),
                  onTap: () => _openMedia(index),
                  child: Container(),
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
                  maxWidth: MediaQuery.of(context).size.width * 0.95,
                  maxHeight: MediaQuery.of(context).size.height * 0.9,
                ),
                child: item.type == 'image'
                    ? InteractiveViewer(
                        child: Image.network(
                          item.url,
                          fit: BoxFit.contain,
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return const Center(
                              child: CircularProgressIndicator(color: Colors.white),
                            );
                          },
                          errorBuilder: (context, error, stackTrace) {
                            return const Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.error, color: Colors.white, size: 48),
                                  SizedBox(height: 16),
                                  Text(
                                    'Failed to load image',
                                    style: TextStyle(color: Colors.white),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      )
                    : AspectRatio(
                        aspectRatio: 16 / 9,
                        child: BetterPlayerWidget(
                          videoUrl: item.url,
                          autoPlay: true,
                          showControls: true,
                        ),
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
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _prevMedia,
                      icon: const Icon(Icons.chevron_left, size: 32, color: Colors.white),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),

              // Next button
              if (_currentIndex! < widget.items.length - 1)
                Positioned(
                  right: 16,
                  top: MediaQuery.of(context).size.height / 2 - 24,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      borderRadius: BorderRadius.circular(24),
                    ),
                    child: IconButton(
                      onPressed: _nextMedia,
                      icon: const Icon(Icons.chevron_right, size: 32, color: Colors.white),
                      padding: const EdgeInsets.all(12),
                    ),
                  ),
                ),
            ],

            // Close button
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.black54,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: IconButton(
                  onPressed: _closeMedia,
                  icon: const Icon(Icons.close, size: 24, color: Colors.white),
                  padding: const EdgeInsets.all(12),
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