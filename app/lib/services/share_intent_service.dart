
import 'dart:async';
import 'package:receive_sharing_intent/receive_sharing_intent.dart';
import 'pending_share_queue.dart';

typedef OnShareQueued = void Function();

class ShareIntentService {
  static final ShareIntentService _i = ShareIntentService._();
  ShareIntentService._();
  factory ShareIntentService() => _i;

  StreamSubscription? _sub;

  Future<void> init({required OnShareQueued onQueued}) async {
    // Foreground stream (app already open)
    _sub = ReceiveSharingIntent.instance.getMediaStream().listen((value) {
      _handleIncoming(value, onQueued);
    }, onError: (err) {});

    // Cold start / background
    final initial = await ReceiveSharingIntent.instance.getInitialMedia();
    if (initial != null && initial.isNotEmpty) {
      _handleIncoming(initial, onQueued);
      ReceiveSharingIntent.instance.reset();
    }

    // Note: Text sharing methods (getTextStream/getInitialText) were removed in recent versions
    // UFOBeep primarily handles media files (photos/videos), so this is acceptable
  }

  void _handleIncoming(List<SharedMediaFile> files, OnShareQueued onQueued) {
    final items = files.map((f) => SharedMediaItem(
      uri: Uri.parse(f.path),
      mimeType: f.mimeType,
      text: null,
    )).toList();
    PendingShareQueue().enqueue(items);
    onQueued();
  }

  void dispose() {
    _sub?.cancel();
    _sub = null;
  }
}
