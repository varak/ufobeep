import 'dart:async';
import 'package:flutter/services.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:vibration/vibration.dart';

class UiFeedbackService {
  static final UiFeedbackService _i = UiFeedbackService._internal();
  factory UiFeedbackService() => _i;
  UiFeedbackService._internal();

  final AudioPlayer _player = AudioPlayer();
  bool _warmed = false;
  bool _initialized = false;

  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Configure for ultra-low-latency UI sounds with Android sonification
      await _player.setAudioContext(
        AudioContext(
          android: AudioContextAndroid(
            contentType: AndroidContentType.sonification,
            usageType: AndroidUsageType.assistanceSonification,
            audioFocus: AndroidAudioFocus.none, // Don't steal focus for UI sounds
          ),
        ),
      );
      
      // Preload the sound
      await _player.setSource(AssetSource('sounds/tap_click.mp3'));
      
      await _warmIfNeeded();
      _initialized = true;
      print('🔊 UI feedback service initialized successfully');
    } catch (e) {
      print('🔊 UI feedback service init error: $e');
    }
  }

  Future<void> _warmIfNeeded() async {
    if (_warmed) return;
    // Moto warm-up: play once at low volume to prime audio channel
    try {
      print('🔊 UI feedback: warming up AudioPlayer for Moto...');
      await _player.setVolume(0.1);
      await _player.resume();
      await Future.delayed(const Duration(milliseconds: 120));
      await _player.stop();
      await _player.setVolume(1.0);
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
      
      // Play UI click sound - fast restart for immediate response
      await _player.stop();
      await _player.resume();
      print('🔊 UI feedback: played click sound');
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
      
      // Play capture sound - restart for immediate response
      await _player.stop();
      await _player.resume();
      print('🔊 UI feedback: played capture sound');
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
      await _player.stop();
      await _player.dispose();
      _initialized = false;
      _warmed = false;
    } catch (e) {
      print('🔊 UI feedback dispose error: $e');
    }
  }
}