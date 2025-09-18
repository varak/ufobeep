import 'dart:io';
import 'package:flutter/material.dart';
import 'package:better_player_plus/better_player_plus.dart';
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
    this.initializationTimeout = const Duration(seconds: 30),
  }) : assert(videoUrl != null || videoFile != null, 'Either videoUrl or videoFile must be provided');

  @override
  State<BetterPlayerWidget> createState() => _BetterPlayerWidgetState();
}

class _BetterPlayerWidgetState extends State<BetterPlayerWidget> {
  BetterPlayerController? _betterPlayerController;
  bool _isInitialized = false;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      debugPrint('🎥 BETTER_PLAYER: Starting initialization...');
      debugPrint('🎥 BETTER_PLAYER: Device info - mounted: $mounted');

      // Add timeout for tablet compatibility
      await Future.any([
        _doInitializePlayer(),
        Future.delayed(widget.initializationTimeout!).then((_) => throw 'Initialization timeout'),
      ]);
    } catch (e) {
      debugPrint('❌ BETTER_PLAYER: Failed to initialize player: $e');
      debugPrint('❌ BETTER_PLAYER: Video URL was: ${widget.videoUrl}');
      debugPrint('❌ BETTER_PLAYER: Video file was: ${widget.videoFile?.path}');

      if (mounted) {
        setState(() {
          _isInitialized = false;
          _hasError = true;
          _errorMessage = e.toString();
        });
      }
    }
  }

  Future<void> _doInitializePlayer() async {
      // Create data source
      BetterPlayerDataSource dataSource;

      if (widget.videoFile != null) {
        debugPrint('🎥 BETTER_PLAYER: Initializing with local file: ${widget.videoFile!.path}');
        final fileExists = await widget.videoFile!.exists();
        debugPrint('🎥 BETTER_PLAYER: File exists: $fileExists');
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
            minBufferMs: 3000,        // Increased for tablets
            maxBufferMs: 15000,       // Increased buffer for better stability
            bufferForPlaybackMs: 1500, // Slightly higher threshold
            bufferForPlaybackAfterRebufferMs: 3000, // More rebuffer protection
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
          enableFullscreen: true, // Enable fullscreen controls
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

      // Add event listener for debugging tablet issues
      _betterPlayerController!.addEventsListener((BetterPlayerEvent event) {
        debugPrint('🎥 BETTER_PLAYER: Event - ${event.betterPlayerEventType}');
        if (event.betterPlayerEventType == BetterPlayerEventType.initialized) {
          debugPrint('🎥 BETTER_PLAYER: Video successfully initialized');
        } else if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
          debugPrint('❌ BETTER_PLAYER: Exception occurred: ${event.parameters}');
        }
      });

      debugPrint('🎥 BETTER_PLAYER: Setting up data source...');
      await _betterPlayerController!.setupDataSource(dataSource);

      if (mounted) {
        setState(() {
          _isInitialized = true;
        });
      }

      debugPrint('🎥 BETTER_PLAYER: Player initialized successfully');
  }

  @override
  void dispose() {
    debugPrint('🎥 BETTER_PLAYER: Disposing controller...');
    _betterPlayerController?.dispose();
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

    // Show initialized player
    return Container(
      width: widget.width ?? double.infinity,
      height: widget.height ?? 300,
      child: BetterPlayer(
        controller: _betterPlayerController!,
      ),
    );
  }
}