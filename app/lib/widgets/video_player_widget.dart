import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../theme/app_theme.dart';

class VideoPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double? width;
  final double? height;

  const VideoPlayerWidget({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.width,
    this.height,
  }) : assert(videoUrl != null || videoFile != null, 'Either videoUrl or videoFile must be provided');

  @override
  State<VideoPlayerWidget> createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  VideoPlayerController? _videoController;
  bool _isVideoInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializeVideoPlayer();
  }

  Future<void> _initializeVideoPlayer() async {
    try {
      if (widget.videoFile != null) {
        _videoController = VideoPlayerController.file(widget.videoFile!);
      } else {
        _videoController = VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));
      }
      
      await _videoController!.initialize();
      
      if (mounted) {
        setState(() {
          _isVideoInitialized = true;
        });
      }
      
      debugPrint('🎥 VIDEO: Player initialized');
    } catch (e) {
      debugPrint('❌ VIDEO: Failed to initialize player: $e');
      if (mounted) {
        setState(() {
          _isVideoInitialized = false;
        });
      }
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    String twoDigitMinutes = twoDigits(duration.inMinutes.remainder(60));
    String twoDigitSeconds = twoDigits(duration.inSeconds.remainder(60));
    return '$twoDigitMinutes:$twoDigitSeconds';
  }

  @override
  Widget build(BuildContext context) {
    if (!_isVideoInitialized || _videoController == null) {
      return Container(
        width: widget.width ?? double.infinity,
        height: widget.height ?? 300,
        color: AppColors.darkSurface,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.brandPrimary,
              ),
              SizedBox(height: 16),
              Text(
                'Loading video...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      );
    }
    
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: Stack(
        alignment: Alignment.center,
        children: [
          AspectRatio(
            aspectRatio: _videoController!.value.aspectRatio,
            child: VideoPlayer(_videoController!),
          ),
          // Play/pause button overlay
          Container(
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.3),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              onPressed: () async {
                setState(() {
                  if (_videoController!.value.isPlaying) {
                    _videoController!.pause();
                  } else {
                    _videoController!.play();
                  }
                });
              },
              icon: Icon(
                _videoController!.value.isPlaying
                    ? Icons.pause
                    : Icons.play_arrow,
                color: Colors.white,
                size: 48,
              ),
            ),
          ),
          // Video duration indicator
          Positioned(
            bottom: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.black.withOpacity(0.7),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                _formatDuration(_videoController!.value.duration),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    super.dispose();
  }
}