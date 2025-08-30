import 'package:permission_handler/permission_handler.dart';
import 'package:flutter/services.dart';
import 'sound_service.dart';

class Notifications {
  static const String channelId = 'ufobeep_alerts';

  static Future<void> ensureNotificationPermission() async {
    final status = await Permission.notification.status;
    if (!status.isGranted) {
      await Permission.notification.request();
    }
  }

  static Future<void> handleForegroundBeep() async {
    try {
      // Haptic feedback for immediate physical alert
      HapticFeedback.mediumImpact();
      
      // Play alert sound using our sound service (includes warm-up)
      await SoundService.I.play(AlertSound.normal, haptic: true);
    } catch (e) {
      print('Error handling foreground beep: $e');
    }
  }
}