
import 'dart:io';

class SharedMediaItem {
  final Uri uri;
  final String? mimeType;
  final String? text;
  SharedMediaItem({required this.uri, this.mimeType, this.text});
}

class PendingShareQueue {
  static final PendingShareQueue _i = PendingShareQueue._();
  PendingShareQueue._();
  factory PendingShareQueue() => _i;

  List<SharedMediaItem> _items = [];
  DateTime? _queuedAt;

  bool get hasItems => _items.isNotEmpty;
  List<SharedMediaItem> get items => List.unmodifiable(_items);

  void clear() {
    _items = [];
    _queuedAt = null;
  }

  void enqueue(List<SharedMediaItem> items) {
    _items = items;
    _queuedAt = DateTime.now();
  }

  /// If your UI requires real files, adapt this to resolve content:// URIs
  Future<List<File>> materializeFiles() async {
    final files = <File>[];
    for (final i in _items) {
      files.add(File(i.uri.toString()));
    }
    return files;
  }
}
