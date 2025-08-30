import 'package:flutter/services.dart';

class UiFeedback {
  static const _ch = MethodChannel('ui_sfx');
  static bool _warmed = false;

  static Future<void> init() async {
    if (_warmed) return;
    try {
      await _ch.invokeMethod('warm'); // Moto warm-up
      _warmed = true;
    } catch (_) {}
  }

  static Future<void> click() async {
    try { 
      await _ch.invokeMethod('click'); 
    } catch (_) {}
    HapticFeedback.lightImpact(); // simple, reliable haptic
  }
}