import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';
import 'package:video_player/video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../models/view_media.dart';

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
          if (m.isMuseAiVideo) {
            return _MuseAiVideoPage(url: m.url, caption: m.caption);
          } else if (m.isVideo) {
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

class _VideoPage extends StatefulWidget {
  final String url;
  final String? caption;

  const _VideoPage({
    required this.url,
    this.caption,
  });

  @override
  State<_VideoPage> createState() => _VideoPageState();
}

class _VideoPageState extends State<_VideoPage> {
  VideoPlayerController? _controller;
  bool _showControls = true;
  bool _isPlaying = false;
  bool _isMuted = false;
  double _volume = 1.0;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _initializeVideo();
  }

  @override
  void dispose() {
    _hideTimer?.cancel();
    _controller?.dispose();
    super.dispose();
  }

  Future<void> _initializeVideo() async {
    _controller = VideoPlayerController.networkUrl(Uri.parse(widget.url));
    await _controller!.initialize();
    if (mounted) {
      setState(() {});
      _startHideTimer();
    }
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _showControlsTemporarily() {
    setState(() {
      _showControls = true;
    });
    _startHideTimer();
  }

  void _togglePlayPause() {
    if (_controller == null) return;

    if (_controller!.value.isPlaying) {
      _controller!.pause();
      setState(() {
        _isPlaying = false;
      });
    } else {
      _controller!.play();
      setState(() {
        _isPlaying = true;
      });
    }
  }

  void _toggleMute() {
    if (_controller == null) return;

    if (_isMuted) {
      _controller!.setVolume(_volume);
      setState(() {
        _isMuted = false;
      });
    } else {
      _volume = _controller!.value.volume;
      _controller!.setVolume(0.0);
      setState(() {
        _isMuted = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Clean video player
        Center(
          child: GestureDetector(
            onTap: _showControlsTemporarily,
            child: _controller?.value.isInitialized == true
                ? AspectRatio(
                    aspectRatio: _controller!.value.aspectRatio,
                    child: VideoPlayer(_controller!),
                  )
                : const Center(
                    child: CircularProgressIndicator(color: Colors.white),
                  ),
          ),
        ),
        // Custom clean controls at bottom
        if (_showControls && _controller?.value.isInitialized == true)
          Positioned(
            left: 20,
            right: 20,
            bottom: 40,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  // Play/Pause button
                  IconButton(
                    onPressed: _togglePlayPause,
                    icon: Icon(
                      _isPlaying ? Icons.pause : Icons.play_arrow,
                      color: Colors.white,
                      size: 28,
                    ),
                  ),
                  // Time display (current)
                  Text(
                    _formatDuration(_controller!.value.position),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  const SizedBox(width: 8),
                  // Progress indicator (scrubable)
                  Expanded(
                    child: VideoProgressIndicator(
                      _controller!,
                      allowScrubbing: true,
                      colors: const VideoProgressColors(
                        playedColor: Colors.white,
                        bufferedColor: Colors.white30,
                        backgroundColor: Colors.white10,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Time display (total)
                  Text(
                    _formatDuration(_controller!.value.duration),
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                  // Volume/Mute button
                  IconButton(
                    onPressed: _toggleMute,
                    icon: Icon(
                      _isMuted ? Icons.volume_off : Icons.volume_up,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if ((widget.caption ?? '').isNotEmpty)
          Positioned(
            left: 12,
            right: 12,
            bottom: 120,
            child: _Caption(text: widget.caption!),
          ),
      ],
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
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
/// Muse.ai Video Player Page (uses WebView to embed Muse.ai player)
class _MuseAiVideoPage extends StatefulWidget {
  final String url; // https://muse.ai/v/kamzZm8
  final String? caption;

  const _MuseAiVideoPage({
    required this.url,
    this.caption,
  });

  @override
  State<_MuseAiVideoPage> createState() => _MuseAiVideoPageState();
}

class _MuseAiVideoPageState extends State<_MuseAiVideoPage> {
  late final WebViewController _webViewController;

  @override
  void initState() {
    super.initState();

    // Extract video ID from URL (https://muse.ai/v/kamzZm8 -> kamzZm8)
    final videoId = widget.url.split('/').last;
    final embedUrl = 'https://muse.ai/embed/$videoId';

    _webViewController = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.black)
      ..loadRequest(Uri.parse(embedUrl));
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Center(
          child: WebViewWidget(controller: _webViewController),
        ),
        if (widget.caption != null && widget.caption!.isNotEmpty)
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.caption!,
                style: const TextStyle(color: Colors.white, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
      ],
    );
  }
}
