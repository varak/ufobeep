// Copyright 2025 UFOBeep
library ufobeep_camera_caps;

import 'dart:async';
import 'package:flutter/services.dart';

/// Camera capabilities (effective zoom factors, not normalized).
class CameraCaps {
  /// Minimum "×" factor supported by the camera. Typically 1.0×.
  final double minX;

  /// Maximum "×" factor supported by the camera (may include digital).
  final double maxX;

  /// Useful anchor factors that map to physical or virtual lenses when present,
  /// e.g., [0.5, 1.0, 3.0]. Always non-empty; contains 1.0 at minimum.
  final List<double> anchorsX;

  const CameraCaps({
    required this.minX,
    required this.maxX,
    required this.anchorsX,
  });

  @override
  String toString() => 'CameraCaps(minX: $minX, maxX: $maxX, anchorsX: $anchorsX)';
}

/// Public API
class UfobeepCameraCaps {
  static const MethodChannel _ch = MethodChannel('ufobeep/caps');

  /// Get camera zoom capabilities.
  static Future<CameraCaps> getCaps() async {
    try {
      final m = await _ch.invokeMapMethod<String, dynamic>('getCaps');
      if (m == null) return const CameraCaps(minX: 1.0, maxX: 8.0, anchorsX: [1.0]);
      final minX = (m['minX'] as num?)?.toDouble() ?? 1.0;
      final maxX = (m['maxX'] as num?)?.toDouble() ?? 8.0;
      final List anchors = (m['anchorsX'] as List?) ?? const [1.0];
      final ax = anchors.map((e) => (e as num).toDouble()).toList()..sort();
      return CameraCaps(minX: minX, maxX: maxX, anchorsX: ax);
    } catch (_) {
      return const CameraCaps(minX: 1.0, maxX: 8.0, anchorsX: [1.0]);
    }
  }

  /// Map normalized (0..1) -> real "×" factor using [caps].
  static double normToFactor(double norm, CameraCaps caps) {
    final z = norm.clamp(0.0, 1.0);
    return caps.minX + z * (caps.maxX - caps.minX);
  }

  /// Map real "×" factor -> normalized (0..1) using [caps].
  static double factorToNorm(double factor, CameraCaps caps) {
    final f = factor.clamp(caps.minX, caps.maxX);
    if (caps.maxX == caps.minX) return 0.0;
    return (f - caps.minX) / (caps.maxX - caps.minX);
  }
}
