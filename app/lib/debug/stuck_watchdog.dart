import 'dart:async';

class StuckWatchdog {
  final _log = <String>[];
  Timer? _timer;
  
  void mark(String m) {
    _log.add("${DateTime.now().toIso8601String()}  $m");
    // reset 5s watchdog on each mark
    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 5), () {
      // ignore: avoid_print
      debugPrint("🛑 WATCHDOG: no progress >5s. Last steps:\n${_log.join("\n")}");
    });
    // also print each mark so you see forward motion
    // ignore: avoid_print
    debugPrint("➡️  ${_log.last}");
  }

  void dispose() { _timer?.cancel(); }
}