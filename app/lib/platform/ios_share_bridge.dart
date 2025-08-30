
import 'dart:async';
import 'package:flutter/services.dart';

/// Receives iOS share trigger and payload via MethodChannel.
class IOSShareBridge {
  static const MethodChannel _ch = MethodChannel('com.ufobeep/share');
  static final IOSShareBridge instance = IOSShareBridge._();
  IOSShareBridge._();

  final StreamController<Map<String, dynamic>> _ctrl = StreamController.broadcast();
  Stream<Map<String, dynamic>> get stream => _ctrl.stream;

  Future<void> init() async {
    _ch.setMethodCallHandler((call) async {
      if (call.method == 'onSharePayload') {
        final Map<dynamic, dynamic>? map = call.arguments;
        if (map != null) {
          _ctrl.add(Map<String, dynamic>.from(map));
        }
      }
    });
  }
}
