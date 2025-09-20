class ViewMedia {
  final String id;
  final String type; // "image" | "video"
  final String url;  // full-size (or best available)
  final String? thumbUrl; // optional, for faster initial paint
  final String? caption;

  const ViewMedia({
    required this.id,
    required this.type,
    required this.url,
    this.thumbUrl,
    this.caption,
  });

  bool get isVideo => type == 'video';
  bool get isImage => type == 'image';
}