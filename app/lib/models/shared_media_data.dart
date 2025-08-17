import 'dart:io';

class SharedMediaData {
  final String filePath;
  final bool isVideo;
  final DateTime sharedAt;

  SharedMediaData({
    required this.filePath,
    required this.isVideo,
    required this.sharedAt,
  });

  File get file => File(filePath);
  
  String get mediaType => isVideo ? 'video' : 'image';
}