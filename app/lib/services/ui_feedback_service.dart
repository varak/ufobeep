import 'dart:async';
import 'package:flutter/services.dart';
import 'package:soundpool/soundpool.dart';

class UiFeedbackService {
  static final UiFeedbackService _i = UiFeedbackService._();
  factory UiFeedbackService() => _i;
  UiFeedbackService._();

  late final Soundpool _pool;
  int? _clickId;
  bool _warmed = false;

  Future<void> init() async {
    _pool = Soundpool(streamType: StreamType.notification);
    final bd = await rootBundle.load('assets/sounds/ui_click.wav');
    _clickId = await _pool.load(bd);
    await _warm();
  }

  Future<void> _warm() async {
    if (_warmed || _clickId == null) return;
    try {
      // Moto warm-up: play then small delay to prime audio channel
      await _pool.play(_clickId!);
      await Future.delayed(const Duration(milliseconds: 120));
      _warmed = true;
    } catch (_) {}
  }

  Future<void> click() async {
    if (_clickId == null) await init();
    try {
      await _pool.play(_clickId!);
    } catch (_) {}
    HapticFeedback.lightImpact(); // simple, reliable haptic
  }

  Future<void> dispose() async {
    try { 
      await _pool.release(); 
    } catch (_) {}
    _clickId = null;
    _warmed = false;
  }
}