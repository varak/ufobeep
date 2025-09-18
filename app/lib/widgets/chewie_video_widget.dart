import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import '../theme/app_theme.dart';

class ChewieVideoWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double? width;
  final double? height;
  final String? returnRoute;
  final bool autoPlay;
  final bool showControls;

  const ChewieVideoWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.width,
    this.height,
    this.returnRoute,
    this.autoPlay = false,
    this.showControls = true,
  }) : assert(videoUrl != null || videoFile != null, 'Either videoUrl or videoFile must be provided');

  @override
  State<ChewieVideoWidget> createState() => _ChewieVideoWidgetState();
}

class _ChewieVideoWidgetState extends State<ChewieVideoWidget> {
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isInitialized = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create video player controller
      if (widget.videoFile != null) {
        debugPrint('🎥 CHEWIE: Initializing with local file: ${widget.videoFile!.path}');
        _videoController = VideoPlayerController.file(widget.videoFile!);
      } else {
        debugPrint('🎥 CHEWIE: Initializing with network URL: ${widget.videoUrl!}');
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      }

      debugPrint('🎥 CHEWIE: Starting video controller initialization...');
      await _videoController!.initialize();

      // Create simple chewie controller (minimal configuration)
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: widget.autoPlay,
        looping: false,
        showControls: widget.showControls,
        allowFullScreen: false,  // Disable fullscreen to avoid conflicts
      );

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      debugPrint('🎥 CHEWIE: Player initialized successfully - Duration: ${_videoController!.value.duration}');
    } catch (e) {
      debugPrint('❌ CHEWIE: Failed to initialize player: $e');
      debugPrint('❌ CHEWIE: Video URL was: ${widget.videoUrl}');
      debugPrint('❌ CHEWIE: Video file was: ${widget.videoFile?.path}');

      if (mounted) {
        setState(() {
          _errorMessage = e.toString();
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🎥 CHEWIE: Disposing video controllers...');
    _chewieController?.dispose();
    _videoController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_errorMessage != null) {
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
                'Video Error',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                _errorMessage!,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 12,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _chewieController == null) {
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

    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      child: Chewie(
        controller: _chewieController!,
      ),
    );
  }
}