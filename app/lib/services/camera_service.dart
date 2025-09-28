// lib/services/camera_service.dart
// UFOBeep — Camera service focused on WYSIWYG preview = captured photo.
// Key points:
// - Uses AspectRatio(controller.value.aspectRatio) so preview is NOT cropped.
// - Locks zoom to 1.0 to avoid silent center-cropping by OEM pipelines.
// - Prefers high/maximum ResolutionPreset for consistent preview/capture linkage.
// - Front camera preview is mirrored; captured image remains non-mirrored (normal).
// - Provides a ready-to-use CameraPreviewBox widget that you can drop into any page.

import 'dart:async';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraService {
  CameraController? _controller;
  CameraDescription? _camera;
  List<CameraDescription> _cameras = const [];
  bool _initialized = false;

  // Expose a singleton if you prefer; otherwise instantiate where needed.
  static final CameraService instance = CameraService._internal();
  CameraService._internal();

  CameraController? get controller => _controller;
  bool get isInitialized => _initialized && _controller?.value.isInitialized == true;
  CameraLensDirection? get lensDirection => _camera?.lensDirection;

  Future<void> initialize({
    CameraLensDirection preferred = CameraLensDirection.back,
    // Use max for the still/preview to share a stable aspect on most devices.
    ResolutionPreset preset = ResolutionPreset.max,
    ImageFormatGroup imageFormat = ImageFormatGroup.yuv420,
    bool enableAudio = false,
  }) async {
    if (_initialized) return;

    _cameras = await availableCameras();

    // Pick the preferred lens if available; else fall back to first camera.
    _camera = _cameras.firstWhere(
      (c) => c.lensDirection == preferred,
      orElse: () => _cameras.isNotEmpty ? _cameras.first : throw StateError('No cameras found'),
    );

    _controller = CameraController(
      _camera!,
      preset,
      enableAudio: enableAudio,
      imageFormatGroup: imageFormat,
    );

    await _controller!.initialize();

    // Explicitly lock zoom to 1.0 to avoid silent crops from default preview stream.
    try {
      final minZ = _controller!.value.minZoomLevel;
      final maxZ = _controller!.value.maxZoomLevel;
      // Clamp to 1.0 within supported range just in case.
      final target = 1.0.clamp(minZ, maxZ);
      await _controller!.setZoomLevel(target);
    } catch (_) {
      // Some devices may throw if zoom isn't supported — ignore.
    }

    // Optional: set a sensible flash mode default (won't affect FOV).
    try {
      await _controller!.setFlashMode(FlashMode.off);
    } catch (_) {}

    _initialized = true;
  }

  Future<void> switchCamera() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    if (_cameras.isEmpty) throw StateError('No cameras available to switch.');

    final currentIndex = _cameras.indexOf(_camera!);
    final nextIndex = (currentIndex + 1) % _cameras.length;
    _camera = _cameras[nextIndex];

    final wasInitialized = isInitialized;
    if (wasInitialized) {
      await _controller?.dispose();
      _controller = null;
      _initialized = false;
    }

    _controller = CameraController(
      _camera!,
      // Keep the same preset to maintain behavior across switches.
      _controller?.value.previewSize != null ? _choosePresetFromExisting() : ResolutionPreset.max,
      enableAudio: false,
      imageFormatGroup: ImageFormatGroup.yuv420,
    );

    await _controller!.initialize();

    // Re-lock zoom to 1.0 on the new lens.
    try {
      final minZ = _controller!.value.minZoomLevel;
      final maxZ = _controller!.value.maxZoomLevel;
      final target = 1.0.clamp(minZ, maxZ);
      await _controller!.setZoomLevel(target);
    } catch (_) {}

    // Keep flash off by default.
    try {
      await _controller!.setFlashMode(FlashMode.off);
    } catch (_) {}

    _initialized = true;
  }

  // Helper: choose a "high" preset — we prefer max for consistent sensor usage.
  ResolutionPreset _choosePresetFromExisting() {
    // You can customize: ResolutionPreset.max or .ultraHigh depending on plugin version.
    return ResolutionPreset.max;
  }

  // Take a still photo.
  Future<XFile> takePicture() async {
    if (!isInitialized) {
      throw StateError('Camera not initialized.');
    }
    // Ensure not taking multiple shots simultaneously.
    if (_controller!.value.isTakingPicture) {
      throw StateError('Already taking a picture.');
    }
    return await _controller!.takePicture();
  }

  Future<void> dispose() async {
    _initialized = false;
    final c = _controller;
    _controller = null;
    if (c != null) {
      await c.dispose();
    }
  }
}

/// Drop-in preview widget that guarantees WYSIWYG:
/// - Uses the controller's aspectRatio to avoid any crop
/// - Centers with letterbox/pillarbox as needed
/// - Mirrors front camera preview (standard UX)
class CameraPreviewBox extends StatelessWidget {
  final CameraService service;
  final Color backgroundColor;

  const CameraPreviewBox({
    super.key,
    required this.service,
    this.backgroundColor = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    final controller = service.controller;
    if (controller == null || !service.isInitialized) {
      return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(),
      );
    }

    final aspect = controller.value.aspectRatio;

    // Front camera: mirror preview only (captures remain non-mirrored — correct behavior).
    final isFront = service.lensDirection == CameraLensDirection.front;

    final preview = AspectRatio(
      aspectRatio: aspect,
      child: CameraPreview(controller),
    );

    return Container(
      color: backgroundColor,
      alignment: Alignment.center,
      // Center + AspectRatio ensures NO BoxFit.cover crop. What you see == what you get.
      child: isFront
          ? Transform(
              alignment: Alignment.center,
              transform: Matrix4.identity()..scale(-1.0, 1.0, 1.0),
              child: preview,
            )
          : preview,
    );
  }
}