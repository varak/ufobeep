import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/shared_media_data.dart';

class SharedMediaNotifier extends StateNotifier<SharedMediaData?> {
  SharedMediaNotifier() : super(null);

  void setSharedMedia(SharedMediaData sharedMedia) {
    state = sharedMedia;
  }

  void clearSharedMedia() {
    state = null;
  }
}

final sharedMediaProvider = StateNotifierProvider<SharedMediaNotifier, SharedMediaData?>(
  (ref) => SharedMediaNotifier(),
);