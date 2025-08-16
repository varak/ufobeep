// lib/services/sound_service.dart
//
// UFOBeep — Phase 0 SoundService
// - Preloads all alert/UI sounds from assets/sounds/
// - Simple API: SoundService.I.play(AlertSound.emergency)
// - Respects user mute setting (except emergency if you choose to bypass)
// - Avoids overlapping chaos with a tiny "one-at-a-time" policy for short SFX
//
// Requirements in pubspec.yaml:
//   dependencies:
//     audioplayers: ^6.0.0
//     vibration: ^2.0.1   // optional, if you want haptics alongside sounds
//
// Assets (already included by directory in your pubspec):
//   assets:
//     - assets/sounds/
//
// File names expected (Phase-0 pack):
//   beep_normal.mp3
//   beep_urgent.mp3
//   beep_emergency.mp3
//   tap_click.mp3
//   gps_ok.mp3
//   gps_fail.mp3
//   push_ping.mp3
//   compass_lock.mp3
//   test_beep.mp3
//   admin_override.mp3
//
// Usage:
//   await SoundService.I.init(); // call once on app start (e.g., in main())
//   SoundService.I.play(AlertSound.normal);
//   SoundService.I.play(AlertSound.emergency); // your escalation logic
//
// Optional haptics:
//   SoundService.I.play(AlertSound.normal, haptic: true);

import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Optional vibration. If you don't want it, remove and ignore the parameter.
// import 'package:vibration/vibration.dart';

enum AlertSound {
  normal,         // single-witness alert tone
  urgent,         // multi-witness escalation
  emergency,      // mass-sighting siren (can bypass mute if you decide)
  tap,            // UI tap confirm (BIG BEEP button)
  gpsOk,          // GPS lock acquired
  gpsFail,        // GPS lock failed -> manual direction fallback
  pushPing,       // push notification arrived
  compassLock,    // compass overlay stabilized
  test,           // QA / diagnostics tone
  adminOverride,  // admin emergency stinger (distinct from emergency)
}

class SoundService {
  SoundService._();
  static final SoundService I = SoundService._();

  /// Prefix under /assets. Keep this in one place.
  static const String _assetPrefix = 'sounds';

  /// Map enum -> filename inside assets/sounds/
  static const Map<AlertSound, String> _fileMap = {
    AlertSound.normal:        'beep_normal.mp3',
    AlertSound.urgent:        'beep_urgent.mp3',
    AlertSound.emergency:     'beep_emergency.mp3',
    AlertSound.tap:           'tap_click.mp3',
    AlertSound.gpsOk:         'gps_ok.mp3',
    AlertSound.gpsFail:       'gps_fail.mp3',
    AlertSound.pushPing:      'push_ping.mp3',
    AlertSound.compassLock:   'compass_lock.mp3',
    AlertSound.test:          'test_beep.mp3',
    AlertSound.adminOverride: 'admin_override.mp3',
  };

  /// Keep one player per sound so we can "preload" by setting sources at init.
  final Map<AlertSound, AudioPlayer> _players = {};

  /// Track what is currently playing to prevent chaotic overlaps.
  AlertSound? _current;

  /// Global mute (for user settings). Emergency can bypass this if you want.
  bool _muted = false;

  /// Master volume 0.0–1.0 applied to all players.
  double _volume = 1.0;

  /// Whether we allow emergency/adminOverride to play when muted.
  bool bypassMuteForCritical = true;

  /// Quiet hours override settings
  static const String _quietHoursEnabledKey = 'quiet_hours_enabled';
  static const String _quietHoursStartKey = 'quiet_hours_start';
  static const String _quietHoursEndKey = 'quiet_hours_end';
  
  /// Rate limiting for alerts (max 3 per 15 minutes)
  static const String _alertTimestampsKey = 'recent_alert_timestamps';
  static const int _maxAlertsPerPeriod = 3;
  static const int _rateLimitMinutes = 15;

  bool _initialized = false;

  /// Call once on app startup. This sets audio focus/context and pre-assigns sources.
  Future<void> init() async {
    if (_initialized) return;

    // Configure global audio context for mobile OS behavior:
    // - category: ambient/solo based on your UX
    // - respectSilence: if true, device "silent" mutes normal sounds
    // - contentType: sonification lowers latency and hint OS it's UI SFX
    // Note: Audio context setup skipped for compatibility
    // Basic playback will work with default settings

    // Create players and pre-assign sources so first playback has minimal lag.
    for (final entry in _fileMap.entries) {
      final player = AudioPlayer();
      await player.setReleaseMode(ReleaseMode.stop); // short SFX, no loop
      await player.setVolume(_volume);
      // Set the asset source now (lazy decoding still happens at first play).
      await player.setSource(AssetSource('$_assetPrefix/${entry.value}'));
      _players[entry.key] = player;
    }

    _initialized = true;
  }

  /// Toggle mute for non-critical sounds (UI/chimes).
  /// Emergency/adminOverride can bypass if [bypassMuteForCritical] is true.
  void setMuted(bool muted) {
    _muted = muted;
  }

  bool get isMuted => _muted;

  /// Set master volume 0.0–1.0 for all players.
  Future<void> setVolume(double v) async {
    _volume = v.clamp(0.0, 1.0);
    for (final p in _players.values) {
      await p.setVolume(_volume);
    }
  }

  double get volume => _volume;

  /// Play a sound. Optionally add a light haptic.
  Future<void> play(AlertSound sound, {bool haptic = false}) async {
    if (!_initialized) {
      // Fail-safe: init on first use if caller forgot.
      await init();
    }

    final isCritical = (sound == AlertSound.emergency || sound == AlertSound.adminOverride);
    final isAlert = (sound == AlertSound.normal || sound == AlertSound.urgent || sound == AlertSound.emergency);
    
    // Rate limiting for alert sounds (non-critical only)
    if (isAlert && !isCritical) {
      final canPlay = await _checkRateLimit();
      if (!canPlay) {
        print('Rate limited: Skipping alert sound (max 3 per 15 minutes)');
        return;
      }
    }
    
    // Quiet hours check (emergency can override)
    if (isAlert && !isCritical) {
      final inQuietHours = await _isInQuietHours();
      if (inQuietHours) {
        print('In quiet hours: Skipping non-emergency alert sound');
        return;
      }
    }

    if (_muted && !(isCritical && bypassMuteForCritical)) {
      return;
    }

    // Simple anti-overlap policy:
    // - If something is currently playing and this is NOT critical, stop it first.
    // - Critical can interrupt anything immediately.
    if (_current != null && !isCritical) {
      final currentPlayer = _players[_current!];
      if (currentPlayer != null) {
        await currentPlayer.stop();
      }
      _current = null;
    }

    final player = _players[sound];
    if (player == null) return; // missing asset or not initialized

    _current = sound;

    // Optional haptics (uncomment package import/use if you want this).
    // if (haptic) {
    //   final canVibrate = await Vibration.hasVibrator() ?? false;
    //   if (canVibrate) {
    //     Vibration.vibrate(duration: isCritical ? 120 : 40);
    //   }
    // }

    // If this is critical, give it a tiny head start by ensuring source is set fresh.
    // (This can help on some devices where the decoder got evicted.)
    if (isCritical) {
      await player.setSource(AssetSource('$_assetPrefix/${_fileMap[sound]}'));
    }

    // Fire-and-forget: short SFX. We await to keep _current accurate.
    try {
      await player.resume(); // source already set; resume triggers immediate play
    } catch (_) {
      // Fallback if resume fails (rare): try full play with explicit source.
      await player.play(AssetSource('$_assetPrefix/${_fileMap[sound]}'));
    }

    // After it finishes, clear _current. Attach a one-shot completion listener.
    // audioplayers v6: onPlayerComplete is a Stream.
    unawaited(_attachCompletion(player, sound));
  }

  Future<void> _attachCompletion(AudioPlayer player, AlertSound sound) async {
    late final StreamSubscription<void> sub;
    sub = player.onPlayerComplete.listen((_) {
      if (_current == sound) {
        _current = null;
      }
      sub.cancel();
    });
  }

  /// Check if we're in quiet hours (emergency sounds can override)
  Future<bool> _isInQuietHours() async {
    final prefs = await SharedPreferences.getInstance();
    final enabled = prefs.getBool(_quietHoursEnabledKey) ?? false;
    
    if (!enabled) return false;
    
    final startHour = prefs.getInt(_quietHoursStartKey) ?? 22; // 10 PM default
    final endHour = prefs.getInt(_quietHoursEndKey) ?? 7; // 7 AM default
    
    final now = DateTime.now();
    final currentHour = now.hour;
    
    if (startHour <= endHour) {
      return currentHour >= startHour && currentHour < endHour;
    } else {
      // Overnight period (e.g., 22:00 to 07:00)
      return currentHour >= startHour || currentHour < endHour;
    }
  }

  /// Check rate limiting (max 3 alerts per 15 minutes)
  Future<bool> _checkRateLimit() async {
    final prefs = await SharedPreferences.getInstance();
    final now = DateTime.now().millisecondsSinceEpoch;
    final cutoff = now - (_rateLimitMinutes * 60 * 1000); // 15 minutes ago
    
    // Get recent alert timestamps
    final timestamps = prefs.getStringList(_alertTimestampsKey) ?? [];
    final recentTimestamps = timestamps
        .map((t) => int.tryParse(t) ?? 0)
        .where((t) => t > cutoff)
        .toList();
    
    if (recentTimestamps.length >= _maxAlertsPerPeriod) {
      return false; // Rate limited
    }
    
    // Add current timestamp and clean old ones
    recentTimestamps.add(now);
    await prefs.setStringList(_alertTimestampsKey, 
        recentTimestamps.map((t) => t.toString()).toList());
    
    return true; // Can play
  }

  /// Settings methods for quiet hours configuration
  Future<void> setQuietHours({required bool enabled, int startHour = 22, int endHour = 7}) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_quietHoursEnabledKey, enabled);
    await prefs.setInt(_quietHoursStartKey, startHour);
    await prefs.setInt(_quietHoursEndKey, endHour);
  }

  Future<Map<String, dynamic>> getQuietHoursSettings() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'enabled': prefs.getBool(_quietHoursEnabledKey) ?? false,
      'startHour': prefs.getInt(_quietHoursStartKey) ?? 22,
      'endHour': prefs.getInt(_quietHoursEndKey) ?? 7,
    };
  }

  /// Dispose all players (e.g., on app shutdown or hot-restart if needed).
  Future<void> dispose() async {
    for (final p in _players.values) {
      await p.stop();
      await p.dispose();
    }
    _players.clear();
    _current = null;
    _initialized = false;
  }
}
