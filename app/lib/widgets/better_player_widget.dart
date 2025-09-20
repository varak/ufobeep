import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class BetterPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double? width;
  final double? height;
  final String? returnRoute;
  final bool autoPlay;
  final bool showControls;
  final Duration? initializationTimeout;

  const BetterPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.width,
    this.height,
    this.returnRoute,
    this.autoPlay = false,
    this.showControls = true,
    this.initializationTimeout = const Duration(seconds: 15),
  }) : assert(videoUrl != null || videoFile != null, 'Either videoUrl or videoFile must be provided');

  @override
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget> {
  VideoPlayerController? _controller;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('🎥 VIDEO_PLAYER: Starting initialization...');

      // Create video player controller
      if (widget.videoFile != null) {
        debugPrint('🎥 VIDEO_PLAYER: Initializing with local file: ${widget.videoFile!.path}');
        _controller = VideoPlayerController.file(widget.videoFile!);
      } else {
        debugPrint('🎥 VIDEO_PLAYER: Initializing with network URL: ${widget.videoUrl!}');
        _controller = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      }

      // Add timeout handling
      await Future.any([
        _controller!.initialize(),
        Future.delayed(widget.initializationTimeout!).then((_) => throw 'Player initialization timeout'),
      ]);

      if (widget.autoPlay) {
        await _controller!.play();
      }

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      debugPrint('🎥 VIDEO_PLAYER: Player initialized successfully');
    } catch (e) {
      debugPrint('❌ VIDEO_PLAYER: Failed to initialize player: $e');

      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  void _togglePlayPause() {
    if (_controller?.value.isPlaying ?? false) {
      _controller?.pause();
    } else {
      _controller?.play();
    }
    setState(() {});
  }


  void _toggleFullscreen() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => FullscreenVideoPlayer(
          controller: _controller!,
          videoUrl: widget.videoUrl,
          videoFile: widget.videoFile,
        ),
      ),
    );
  }

  @override
  void dispose() {
    debugPrint('🎥 VIDEO_PLAYER: Disposing controller...');
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Show error state if initialization failed
    if (_hasError) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 300,
        color: AppColors.darkSurface,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 48,
              ),
              const SizedBox(height: 12),
              const Text(
                'Video failed to load',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage ?? 'Unknown error',
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              TextButton(
                onPressed: () {
                  setState(() {
                    _hasError = false;
                    _errorMessage = null;
                    _isInitialized = false;
                  });
                  _initializePlayer();
                },
                child: const Text(
                  'Retry',
                  style: TextStyle(color: AppColors.brandPrimary),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Show loading state while initializing
    if (!_isInitialized || _controller == null) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 300,
        color: AppColors.darkSurface,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(color: AppColors.brandPrimary),
              SizedBox(height: 12),
              Text(
                'Loading video...',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),
      );
    }

    // Show initialized player
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Video player
            SizedBox.expand(
              child: FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: _controller!.value.size.width,
                  height: _controller!.value.size.height,
                  child: VideoPlayer(_controller!),
                ),
              ),
            ),

            // Controls overlay
            if (widget.showControls && _showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top controls (empty for now)
                      const SizedBox(height: 8),

                      const Spacer(),

                      // Center play/pause button
                      Center(
                        child: IconButton(
                          iconSize: 64,
                          icon: Icon(
                            _controller!.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                          ),
                          onPressed: _togglePlayPause,
                        ),
                      ),

                      const Spacer(),

                      // Bottom controls
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            IconButton(
                              icon: Icon(
                                _controller!.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                color: Colors.white,
                              ),
                              onPressed: _togglePlayPause,
                            ),
                            Expanded(
                              child: VideoProgressIndicator(
                                _controller!,
                                allowScrubbing: true,
                                colors: const VideoProgressColors(
                                  playedColor: AppColors.brandPrimary,
                                  bufferedColor: Colors.grey,
                                  backgroundColor: Colors.white24,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.fullscreen, color: Colors.white),
                              onPressed: _toggleFullscreen,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class FullscreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final String? videoUrl;
  final File? videoFile;

  const FullscreenVideoPlayer({
    super.key,
    required this.controller,
    this.videoUrl,
    this.videoFile,
  });

  @override
  State<FullscreenVideoPlayer> createState() => _FullscreenVideoPlayerState();
}

class _FullscreenVideoPlayerState extends State<FullscreenVideoPlayer> {
  bool _showControls = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTap: () {
          setState(() {
            _showControls = !_showControls;
          });
        },
        child: Stack(
          children: [
            // Full screen video
            Center(
              child: AspectRatio(
                aspectRatio: widget.controller.value.aspectRatio,
                child: VideoPlayer(widget.controller),
              ),
            ),

            // Controls overlay
            if (_showControls)
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.7),
                        Colors.transparent,
                        Colors.black.withOpacity(0.7),
                      ],
                      stops: const [0.0, 0.5, 1.0],
                    ),
                  ),
                  child: Column(
                    children: [
                      // Top controls
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.arrow_back, color: Colors.white, size: 32),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.fullscreen_exit, color: Colors.white, size: 32),
                                onPressed: () => Navigator.of(context).pop(),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const Spacer(),

                      // Center play/pause button
                      Center(
                        child: IconButton(
                          iconSize: 80,
                          icon: Icon(
                            widget.controller.value.isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled,
                            color: Colors.white,
                          ),
                          onPressed: () {
                            if (widget.controller.value.isPlaying) {
                              widget.controller.pause();
                            } else {
                              widget.controller.play();
                            }
                            setState(() {});
                          },
                        ),
                      ),

                      const Spacer(),

                      // Bottom controls
                      SafeArea(
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              IconButton(
                                icon: Icon(
                                  widget.controller.value.isPlaying ? Icons.pause : Icons.play_arrow,
                                  color: Colors.white,
                                  size: 32,
                                ),
                                onPressed: () {
                                  if (widget.controller.value.isPlaying) {
                                    widget.controller.pause();
                                  } else {
                                    widget.controller.play();
                                  }
                                  setState(() {});
                                },
                              ),
                              Expanded(
                                child: VideoProgressIndicator(
                                  widget.controller,
                                  allowScrubbing: true,
                                  colors: const VideoProgressColors(
                                    playedColor: AppColors.brandPrimary,
                                    bufferedColor: Colors.grey,
                                    backgroundColor: Colors.white24,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 16),
                              Text(
                                '${_formatDuration(widget.controller.value.position)} / ${_formatDuration(widget.controller.value.duration)}',
                                style: const TextStyle(color: Colors.white),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }
}