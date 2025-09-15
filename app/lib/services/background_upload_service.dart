import 'dart:async';
import 'dart:io';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart' as path;

import '../config/environment.dart';

class BackgroundUploadService {
  static final BackgroundUploadService _instance = BackgroundUploadService._internal();
  factory BackgroundUploadService() => _instance;
  BackgroundUploadService._internal();
  
  static BackgroundUploadService get instance => _instance;

  static const String _pendingUploadsKey = 'pending_media_uploads';
  static const String _failedUploadsKey = 'failed_media_uploads';
  
  final Dio _dio = Dio();
  bool _isUploading = false;
  Timer? _retryTimer;

  Future<void> initialize() async {
    // Configure Dio for large file uploads
    _dio.options.connectTimeout = const Duration(seconds: 30);
    _dio.options.sendTimeout = const Duration(minutes: 10); // Large videos
    _dio.options.receiveTimeout = const Duration(seconds: 30);
    
    // Start processing any pending uploads
    _startUploadProcessor();
  }

  Future<void> scheduleUpload({
    required String alertId,
    required File mediaFile,
    required bool isVideo,
  }) async {
    try {
      // Add to pending uploads queue
      final uploadTask = {
        'alertId': alertId,
        'filePath': mediaFile.path,
        'isVideo': isVideo,
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'retryCount': 0,
      };

      await _addToPendingUploads(uploadTask);
      
      // Start upload processor if not already running
      if (!_isUploading) {
        _processNextUpload();
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error scheduling upload: $e');
      }
    }
  }

  Future<void> _addToPendingUploads(Map<String, dynamic> uploadTask) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final existingUploads = await _getPendingUploads();
      existingUploads.add(uploadTask);
      
      await prefs.setString(_pendingUploadsKey, jsonEncode(existingUploads));
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error adding to pending uploads: $e');
      }
    }
  }

  Future<List<Map<String, dynamic>>> _getPendingUploads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final uploadsJson = prefs.getString(_pendingUploadsKey);
      if (uploadsJson == null) return [];
      
      final List<dynamic> uploadsList = jsonDecode(uploadsJson);
      return uploadsList.cast<Map<String, dynamic>>();
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error getting pending uploads: $e');
      }
      return [];
    }
  }

  void _startUploadProcessor() {
    _retryTimer = Timer.periodic(const Duration(seconds: 30), (timer) {
      if (!_isUploading) {
        _processNextUpload();
      }
    });
  }

  Future<void> _processNextUpload() async {
    if (_isUploading) return;
    
    _isUploading = true;
    
    try {
      final pendingUploads = await _getPendingUploads();
      if (pendingUploads.isEmpty) {
        _isUploading = false;
        return;
      }

      // Get next upload task
      final uploadTask = pendingUploads.first;
      final String alertId = uploadTask['alertId'];
      final String filePath = uploadTask['filePath'];
      final bool isVideo = uploadTask['isVideo'];
      final int retryCount = uploadTask['retryCount'] ?? 0;
      
      if (kDebugMode) {
        print('BackgroundUploadService: Processing upload for alert $alertId');
      }

      // Attempt upload
      final success = await _uploadMedia(alertId, filePath, isVideo);
      
      if (success) {
        // Remove from pending uploads
        pendingUploads.removeAt(0);
        await _savePendingUploads(pendingUploads);
        
        if (kDebugMode) {
          print('BackgroundUploadService: Upload successful for alert $alertId');
        }
      } else {
        // Increment retry count
        uploadTask['retryCount'] = retryCount + 1;
        
        if (retryCount >= 3) {
          // Move to failed uploads after 3 retries
          pendingUploads.removeAt(0);
          await _savePendingUploads(pendingUploads);
          await _addToFailedUploads(uploadTask);
          
          if (kDebugMode) {
            print('BackgroundUploadService: Upload failed permanently for alert $alertId');
          }
        } else {
          // Update retry count and try again later
          pendingUploads[0] = uploadTask;
          await _savePendingUploads(pendingUploads);
          
          if (kDebugMode) {
            print('BackgroundUploadService: Upload failed, retry ${retryCount + 1}/3 for alert $alertId');
          }
        }
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error processing uploads: $e');
      }
    } finally {
      _isUploading = false;
    }
  }

  Future<bool> _uploadMedia(String alertId, String filePath, bool isVideo) async {
    try {
      final File mediaFile = File(filePath);
      if (!await mediaFile.exists()) {
        if (kDebugMode) {
          print('BackgroundUploadService: Media file no longer exists: $filePath');
        }
        return true; // Consider this "successful" so we don't retry
      }

      // Get presigned upload URL from API
      final presignResponse = await _dio.post(
        '${AppEnvironment.apiBaseUrl}/media/presign',
        data: {
          'alert_id': alertId,
          'content_type': isVideo ? 'video/mp4' : 'image/jpeg',
          'file_extension': path.extension(filePath),
        },
      );

      if (presignResponse.statusCode != 200) {
        if (kDebugMode) {
          print('BackgroundUploadService: Failed to get presign URL: ${presignResponse.statusCode}');
        }
        return false;
      }

      final String uploadUrl = presignResponse.data['upload_url'];
      final String mediaId = presignResponse.data['media_id'];

      // Upload file to presigned URL
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(filePath),
      });

      final uploadResponse = await _dio.put(uploadUrl, data: formData);
      
      if (uploadResponse.statusCode == 200 || uploadResponse.statusCode == 204) {
        // Confirm upload with API
        await _dio.post(
          '${AppEnvironment.apiBaseUrl}/media/confirm',
          data: {
            'media_id': mediaId,
            'alert_id': alertId,
          },
        );
        
        return true;
      } else {
        if (kDebugMode) {
          print('BackgroundUploadService: Upload failed with status: ${uploadResponse.statusCode}');
        }
        return false;
      }
      
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Upload error: $e');
      }
      return false;
    }
  }

  Future<void> _savePendingUploads(List<Map<String, dynamic>> uploads) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_pendingUploadsKey, jsonEncode(uploads));
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error saving pending uploads: $e');
      }
    }
  }

  Future<void> _addToFailedUploads(Map<String, dynamic> uploadTask) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final failedUploadsJson = prefs.getString(_failedUploadsKey);
      final List<Map<String, dynamic>> failedUploads = failedUploadsJson != null
          ? (jsonDecode(failedUploadsJson) as List).cast<Map<String, dynamic>>()
          : [];
      
      failedUploads.add(uploadTask);
      await prefs.setString(_failedUploadsKey, jsonEncode(failedUploads));
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error adding to failed uploads: $e');
      }
    }
  }

  Future<int> getPendingUploadCount() async {
    final uploads = await _getPendingUploads();
    return uploads.length;
  }

  Future<void> retryFailedUploads() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final failedUploadsJson = prefs.getString(_failedUploadsKey);
      if (failedUploadsJson == null) return;
      
      final List<Map<String, dynamic>> failedUploads = 
          (jsonDecode(failedUploadsJson) as List).cast<Map<String, dynamic>>();
      
      if (failedUploads.isNotEmpty) {
        // Reset retry counts and move back to pending
        for (final upload in failedUploads) {
          upload['retryCount'] = 0;
          await _addToPendingUploads(upload);
        }
        
        // Clear failed uploads
        await prefs.remove(_failedUploadsKey);
        
        // Start processing
        if (!_isUploading) {
          _processNextUpload();
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('BackgroundUploadService: Error retrying failed uploads: $e');
      }
    }
  }

  void dispose() {
    _retryTimer?.cancel();
    _dio.close();
  }
}