import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player/better_player.dart';
import '../theme/app_theme.dart';

class BetterPlayerWidget extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final double? width;
  final double? height;
  final String? returnRoute;
  final bool autoPlay;
  final bool showControls;

  const BetterPlayerWidget({
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
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Create data source
      BetterPlayerDataSource dataSource;

      if (widget.videoFile != null) {
        debugPrint('🎥 BETTER_PLAYER: Initializing with local file: ${widget.videoFile!.path}');
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.file,
          widget.videoFile!.path,
        );
      } else {
        debugPrint('🎥 BETTER_PLAYER: Initializing with network URL: ${widget.videoUrl!}');
        dataSource = BetterPlayerDataSource(
          BetterPlayerDataSourceType.network,
          widget.videoUrl!,
          // Add configuration for better codec support
          bufferingConfiguration: const BetterPlayerBufferingConfiguration(
            minBufferMs: 2000,        // 2 seconds minimum buffer
            maxBufferMs: 10000,       // 10 seconds maximum buffer
            bufferForPlaybackMs: 1000, // 1 second to start playback
            bufferForPlaybackAfterRebufferMs: 2000, // 2 seconds after rebuffer
          ),
        );
      }

      // Create better player configuration
      final betterPlayerConfiguration = BetterPlayerConfiguration(
        autoPlay: widget.autoPlay,
        looping: false,
        controlsConfiguration: BetterPlayerControlsConfiguration(
          showControls: widget.showControls,
          enableSkips: false,
          enableFullscreen: false, // Disable to avoid conflicts
          controlBarColor: AppColors.darkSurface.withOpacity(0.8),
          progressBarPlayedColor: AppColors.brandPrimary,
          progressBarHandleColor: AppColors.brandPrimary,
          loadingColor: AppColors.brandPrimary,
        ),
        placeholder: Container(
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
        ),
        errorBuilder: (context, errorMessage) {
          return Container(
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
                    errorMessage ?? 'Unknown video error',
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
        },
      );

      debugPrint('🎥 BETTER_PLAYER: Creating controller...');
      _betterPlayerController = BetterPlayerController(betterPlayerConfiguration);

      debugPrint('🎥 BETTER_PLAYER: Setting up data source...');
      await _betterPlayerController!.setupDataSource(dataSource);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      debugPrint('🎥 BETTER_PLAYER: Player initialized successfully');
    } catch (e) {
      debugPrint('❌ BETTER_PLAYER: Failed to initialize player: $e');
      debugPrint('❌ BETTER_PLAYER: Video URL was: ${widget.videoUrl}');
      debugPrint('❌ BETTER_PLAYER: Video file was: ${widget.videoFile?.path}');

      if (mounted) {
        setState(() {
          _isInitialized = false;
        });
      }
    }
  }

  @override
  void dispose() {
    debugPrint('🎥 BETTER_PLAYER: Disposing controller...');
    _betterPlayerController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isInitialized || _betterPlayerController == null) {
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
      child: BetterPlayer(
        controller: _betterPlayerController!,
      ),
    );
  }
}