// lib/services/upload_helper.dart
import 'dart:io';
import 'dart:typed_data';
import 'package:dio/dio.dart';
import 'package:mime/mime.dart' as mime;
import 'package:path/path.dart' as p;
import 'package:image_picker/image_picker.dart';

class UploadHelper {
  /// Builds safe FormData for a beep with optional media + description.
  static Future<FormData> buildBeepForm({
    String? description,
    XFile? galleryFile,   // from ImagePicker (gallery)
    File? cameraFile,     // from camera capture
  }) async {
    final form = FormData();

    // Text field (safe even when combined with media)
    final desc = (description ?? '').trim();
    if (desc.isNotEmpty) {
      form.fields.add(MapEntry('description', desc));
    }

    // Choose the media source if present
    final bool hasGallery = galleryFile != null;
    final bool hasCamera  = cameraFile != null;

    if (hasGallery || hasCamera) {
      // Read bytes safely (XFile handles content:// URIs correctly)
      late Uint8List bytes;
      late String name;

      if (hasGallery) {
        // XFile gives us a .name that doesn't require split hacks
        name  = galleryFile!.name.isNotEmpty ? galleryFile!.name : 'gallery.bin';
        bytes = await galleryFile!.readAsBytes();
      } else {
        final file = cameraFile!;
        name  = p.basename(file.path);
        if (name.isEmpty) name = 'camera.bin';
        bytes = await file.readAsBytes();
      }

      // MIME type detection (don't rely on extension parsing)
      final detected = mime.lookupMimeType(name, headerBytes: bytes) ?? 'application/octet-stream';

      // Ensure a sane filename with extension when missing
      final ext = p.extension(name);
      String safeName = name;
      if (ext.isEmpty) {
        final fallbackExt = _fallbackExtForMime(detected);
        safeName = '$name$fallbackExt';
      }

      form.files.add(
        MapEntry(
          'media',
          MultipartFile.fromBytes(
            bytes,
            filename: safeName,
            contentType: MediaType.parse(detected),
          ),
        ),
      );
    }

    return form;
  }

  static String _fallbackExtForMime(String m) {
    if (m.startsWith('image/jpeg')) return '.jpg';
    if (m.startsWith('image/png'))  return '.png';
    if (m.startsWith('image/webp')) return '.webp';
    if (m.startsWith('video/'))     return '.mp4';
    return '.bin';
  }
}