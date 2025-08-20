import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path/path.dart' as path;

import '../models/shared_media_data.dart';

class ShareIntentService {
  static final ShareIntentService _instance = ShareIntentService._internal();
  factory ShareIntentService() => _instance;
  ShareIntentService._internal();

  static const MethodChannel _channel = MethodChannel('com.ufobeep/share_intent');
  bool _initialized = false;
  
  // Callback for handling shared media navigation
  static void Function(SharedMediaData sharedMedia)? _onSharedMedia;
  
  static void setOnSharedMediaCallback(void Function(SharedMediaData sharedMedia) callback) {
    _onSharedMedia = callback;
  }

  Future<void> initialize() async {
    if (_initialized) return;

    if (kDebugMode) {
      print('ShareIntentService: Initialized with native platform channel');
    }

    _initialized = true;
  }

  // Method to manually check for shared files (call after callback is set)
  static Future<void> checkForSharedFiles() async {
    final instance = ShareIntentService();
    
    // Simple retry: try now, then try again after 1 second
    await instance._checkForSharedFile();
    await Future.delayed(Duration(seconds: 1));
    await instance._checkForSharedFile();
  }

  Future<void> _checkForSharedFile() async {
    try {
      if (kDebugMode) {
        print('ShareIntentService: Checking for shared file...');
      }
      final String? sharedFileUri = await _channel.invokeMethod('getSharedFile');
      if (kDebugMode) {
        print('ShareIntentService: Received URI: $sharedFileUri');
      }
      if (sharedFileUri != null && sharedFileUri.isNotEmpty) {
        await _handleSharedUri(sharedFileUri);
      } else {
        if (kDebugMode) {
          print('ShareIntentService: No shared file found');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('ShareIntentService: Error checking for shared file: $e');
      }
    }
  }

  Future<void> _handleSharedUri(String uriString) async {
    try {
      if (kDebugMode) {
        print('ShareIntentService: Received shared URI: $uriString');
      }

      // Convert URI to file path
      // On Android, we might get content:// URIs which need special handling
      String filePath;
      if (uriString.startsWith('content://')) {
        // For content URIs, we'd need to copy to app directory
        // For now, let's use the URI string directly and handle in native code
        filePath = uriString;
        if (kDebugMode) {
          print('ShareIntentService: Processing content URI: $filePath');
        }
      } else if (uriString.startsWith('file://')) {
        filePath = uriString.substring(7); // Remove file:// prefix
        if (kDebugMode) {
          print('ShareIntentService: Converted file URI to path: $filePath');
        }
      } else {
        filePath = uriString;
        if (kDebugMode) {
          print('ShareIntentService: Using direct path: $filePath');
        }
      }

      // Verify file exists before proceeding
      final file = File(filePath);
      if (!await file.exists()) {
        if (kDebugMode) {
          print('ShareIntentService: ERROR - File does not exist at path: $filePath');
        }
        return;
      }

      // Determine if it's video based on URI
      final String lowerUri = uriString.toLowerCase();
      final bool isVideo = lowerUri.contains('video') || 
                          lowerUri.contains('.mp4') || 
                          lowerUri.contains('.mov') ||
                          lowerUri.contains('.avi');

      if (kDebugMode) {
        print('ShareIntentService: Detected ${isVideo ? 'video' : 'image'} file at: $filePath');
        print('ShareIntentService: File size: ${await file.length()} bytes');
      }

      // Create SharedMediaData object
      final sharedMedia = SharedMediaData(
        filePath: filePath,
        isVideo: isVideo,
        sharedAt: DateTime.now(),
      );
      
      // Call the navigation callback
      if (_onSharedMedia != null) {
        if (kDebugMode) {
          print('ShareIntentService: Calling navigation callback with ${isVideo ? 'video' : 'image'}: $filePath');
        }
        _onSharedMedia!(sharedMedia);
      } else {
        if (kDebugMode) {
          print('ShareIntentService: ERROR - No navigation callback registered');
        }
      }
      
    } catch (e, stackTrace) {
      if (kDebugMode) {
        print('ShareIntentService: Error handling shared URI: $e');
        print('ShareIntentService: Stack trace: $stackTrace');
      }
    }
  }

  // Manual method for testing share functionality
  // This can be called from the beep screen to simulate sharing a photo
  static void simulateSharedMedia(File mediaFile, bool isVideo) {
    if (_onSharedMedia != null) {
      final sharedMedia = SharedMediaData(
        filePath: mediaFile.path,
        isVideo: isVideo,
        sharedAt: DateTime.now(),
      );
      _onSharedMedia!(sharedMedia);
    } else {
      if (kDebugMode) {
        print('ShareIntentService: No navigation callback registered');
      }
    }
  }

  void dispose() {
    _initialized = false;
  }
}