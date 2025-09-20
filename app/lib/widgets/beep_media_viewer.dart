import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import '../models/view_media.dart';
import 'better_player_widget.dart';

class BeepMediaViewer extends StatefulWidget {
  final List<ViewMedia> items;
  final int initialIndex;
  final String? title; // optional: e.g., "MUFON Sighting"

  const BeepMediaViewer({
    super.key,
    required this.items,
    this.initialIndex = 0,
    this.title,
  });

  static Future<void> open(
    BuildContext context, {
    required List<ViewMedia> items,
    int initialIndex = 0,
    String? title,
  }) async {
    await Navigator.of(context).push(
      PageRouteBuilder(
        opaque: true,
        barrierColor: Colors.black,
        pageBuilder: (_, __, ___) => BeepMediaViewer(
          items: items,
          initialIndex: initialIndex,
          title: title,
        ),
        transitionsBuilder: (_, anim, __, child) =>
            FadeTransition(opacity: anim, child: child),
      ),
    );
  }

  @override
  State<BeepMediaViewer> createState() => _BeepMediaViewerState();
}

class _BeepMediaViewerState extends State<BeepMediaViewer> {
  late PageController _controller;
  late ValueNotifier<int> _index;

  @override
  void initState() {
    super.initState();
    _controller = PageController(initialPage: widget.initialIndex);
    _index = ValueNotifier<int>(widget.initialIndex);
  }

  @override
  void dispose() {
    _controller.dispose();
    _index.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final items = widget.items;
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        elevation: 0,
        title: ValueListenableBuilder<int>(
          valueListenable: _index,
          builder: (_, i, __) {
            final total = items.length;
            final left = widget.title ?? 'Media';
            return Text('$left  •  ${i + 1}/$total');
          },
        ),
      ),
      body: PageView.builder(
        controller: _controller,
        onPageChanged: (i) => _index.value = i,
        itemCount: items.length,
        itemBuilder: (_, i) {
          final m = items[i];
          if (m.isVideo) {
            return _VideoPage(url: m.url, caption: m.caption);
          }
          return _ImagePage(url: m.url, thumbUrl: m.thumbUrl, caption: m.caption);
        },
      ),
    );
  }
}

class _ImagePage extends StatelessWidget {
  final String url;
  final String? thumbUrl;
  final String? caption;

  const _ImagePage({
    required this.url,
    this.thumbUrl,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PhotoView(
          backgroundDecoration: const BoxDecoration(color: Colors.black),
          imageProvider: CachedNetworkImageProvider(url),
          heroAttributes: PhotoViewHeroAttributes(tag: url),
          minScale: PhotoViewComputedScale.contained,
          maxScale: PhotoViewComputedScale.covered * 4.0,
          loadingBuilder: (_, __) => Center(
            child: thumbUrl == null
                ? const CircularProgressIndicator(color: Colors.white)
                : CachedNetworkImage(
                    imageUrl: thumbUrl!,
                    fit: BoxFit.contain,
                    placeholder: (_, __) => const CircularProgressIndicator(color: Colors.white),
                  ),
          ),
          errorBuilder: (_, __, ___) => const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 64, color: Colors.red),
                SizedBox(height: 16),
                Text(
                  'Failed to load image',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
              ],
            ),
          ),
        ),
        if ((caption ?? '').isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 18,
            child: _Caption(text: caption!),
          ),
      ],
    );
  }
}

class _VideoPage extends StatelessWidget {
  final String url;
  final String? caption;

  const _VideoPage({
    required this.url,
    this.caption,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: BetterPlayerWidget(
            videoUrl: url,
            autoPlay: false,
            showControls: false, // Disable built-in controls, they stay too long
          ),
        ),
        if ((caption ?? '').isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 18,
            child: _Caption(text: caption!),
          ),
      ],
    );
  }
}

class _Caption extends StatelessWidget {
  final String text;

  const _Caption({required this.text});

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.55),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Text(
          text,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          textAlign: TextAlign.center,
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
      ),
    );
  }
}