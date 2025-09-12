import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:image_picker/image_picker.dart';

/// SafeUploader handles content:// URIs and XFiles without hanging
/// - Never converts content:// into File
/// - Never reads whole media into memory
/// - Uses streaming with chunked transfer
/// - Provides per-part length when available
class SafeUploader {
  SafeUploader(this.endpoint, {http.Client? client, this.timeout = const Duration(seconds: 45)})
      : _client = client ?? http.Client();

  final Uri endpoint;
  final http.Client _client;
  final Duration timeout;

  Future<http.Response> uploadXFile({
    required XFile xfile,
    required Map<String, String> headers,
    String fieldName = 'file',
    Map<String, String>? fields,
  }) async {
    final req = http.MultipartRequest('POST', endpoint);

    // Auth and any other headers
    req.headers.addAll(headers);

    // Optional simple fields
    if (fields != null) req.fields.addAll(fields);

    // Try to determine mime without reading the whole file
    final mime = xfile.mimeType ?? _guessMimeFromName(xfile.name);
    final mediaType = MediaType.parse(mime);

    // Length via XFile.length() works for both file paths and content://
    // But use chunked transfer if length is unknown
    int? length;
    try {
      length = await xfile.length().timeout(Duration(seconds: 5));
      if (length == -1) length = null; // Use chunked transfer
    } catch (e) {
      length = null; // Use chunked transfer
    }

    // Open a stream directly from the content resolver or file
    final stream = xfile.openRead();

    // Create MultipartFile - use 0 length if unknown (enables chunked transfer)
    final part = http.MultipartFile(
      fieldName,
      stream,
      length ?? 0, // 0 enables chunked transfer encoding
      filename: xfile.name,
      contentType: mediaType,
    );
    req.files.add(part);

    // Send + drain
    final streamed = await _client.send(req).timeout(timeout);
    return http.Response.fromStream(streamed).timeout(timeout);
  }

  String _guessMimeFromName(String name) {
    final n = name.toLowerCase();
    if (n.endsWith('.jpg') || n.endsWith('.jpeg')) return 'image/jpeg';
    if (n.endsWith('.png')) return 'image/png';
    if (n.endsWith('.webp')) return 'image/webp';
    if (n.endsWith('.mp4')) return 'video/mp4';
    if (n.endsWith('.mov')) return 'video/quicktime';
    return 'application/octet-stream';
  }

  void close() => _client.close();
}