import 'dart:async';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';
import 'package:vibration/vibration.dart';

class UiFeedbackService {
  static final UiFeedbackService _i = UiFeedbackService._internal();
  factory UiFeedbackService() => _i;
  UiFeedbackService._internal();

  final Soundpool _pool = Soundpool(streamType: StreamType.notification);
  
  int? _clickId;
  bool _warmed = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Load the UI click sound
      if (_clickId == null) {
        final byteData = await rootBundle.load('assets/sounds/tap_click.mp3');
        _clickId = await _pool.load(byteData);
        print('🔊 UI feedback service loaded tap_click.mp3');
      }
      
      await _warmIfNeeded();
      _initialized = true;
      print('🔊 UI feedback service initialized successfully');
    } catch (e) {
      print('🔊 UI feedback service init error: $e');
    }
  }

  Future<void> _warmIfNeeded() async {
    if (_warmed || _clickId == null) return;
    // Moto warm-up: play once to prime audio channel
    try {
      print('🔊 UI feedback: warming up Soundpool for Moto...');
      await _pool.play(_clickId!);
      await Future.delayed(const Duration(milliseconds: 120));
      _warmed = true;
      print('🔊 UI feedback: warm-up complete');
    } catch (e) {
      print('🔊 UI feedback warm-up error: $e');
    }
  }

  Future<void> click({bool haptic = true}) async {
    try {
      // Ensure initialized
      if (!_initialized) await init();
      
      // Play UI click sound with Soundpool for immediate response
      if (_clickId != null) {
        await _pool.play(_clickId!);
        print('🔊 UI feedback: played click sound');
      }
    } catch (e) {
      print('🔊 UI feedback click sound error: $e');
    }

    // Haptic feedback
    if (haptic) {
      try {
        final hasVibrator = await Vibration.hasVibrator() ?? false;
        print('🔊 UI feedback: device has vibrator: $hasVibrator');
        
        if (hasVibrator) {
          // Short, crisp haptic; OEM-friendly
          await Vibration.vibrate(duration: 20, amplitude: 180);
          print('🔊 UI feedback: triggered explicit vibration');
        } else {
          // Fallback to framework haptic if no vibrator API
          HapticFeedback.lightImpact();
          print('🔊 UI feedback: triggered framework haptic');
        }
      } catch (e) {
        print('🔊 UI feedback haptic error: $e');
        // Final fallback to system haptic
        try {
          HapticFeedback.lightImpact();
        } catch (_) {}
      }
    }
  }

  Future<void> capture({bool haptic = true}) async {
    // Same as click but with medium haptic for capture action
    try {
      if (!_initialized) await init();
      
      // Play capture sound with Soundpool for immediate response
      if (_clickId != null) {
        await _pool.play(_clickId!);
        print('🔊 UI feedback: played capture sound');
      }
    } catch (e) {
      print('🔊 UI feedback capture sound error: $e');
    }

    if (haptic) {
      try {
        final hasVibrator = await Vibration.hasVibrator() ?? false;
        
        if (hasVibrator) {
          // Slightly longer haptic for capture action
          await Vibration.vibrate(duration: 40, amplitude: 200);
          print('🔊 UI feedback: triggered capture vibration');
        } else {
          HapticFeedback.mediumImpact();
          print('🔊 UI feedback: triggered medium haptic');
        }
      } catch (e) {
        print('🔊 UI feedback capture haptic error: $e');
        try {
          HapticFeedback.mediumImpact();
        } catch (_) {}
      }
    }
  }

  Future<void> dispose() async {
    try {
      await _pool.dispose();
      _initialized = false;
      _warmed = false;
      _clickId = null;
    } catch (e) {
      print('🔊 UI feedback dispose error: $e');
    }
  }
}