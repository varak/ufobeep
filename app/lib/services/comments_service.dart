import 'package:dio/dio.dart';
import '../models/comment.dart';
import '../services/api_client.dart';
import '../services/auth_repository.dart';
import '../services/device_service.dart';

class CommentsService {
  static final CommentsService _instance = CommentsService._internal();
  factory CommentsService() => _instance;
  CommentsService._internal();
  
  /// Get comments for a sighting/alert
  Future<List<Comment>> getComments(String sightingId, {int limit = 30}) async {
    try {
      final response = await ApiClient.dio.get('/beep/$sightingId/comments?limit=$limit');
      
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Error getting comments: $e');
      rethrow;
    }
  }
  
  /// Post a new comment
  Future<Comment> postComment(String sightingId, String body, {String? mediaUrl}) async {
    try {
      debugPrint('🗣️ Posting comment to sighting: $sightingId');
      debugPrint('🗣️ Comment body: $body');
      
      // Ensure we have the latest access token
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Authentication required to post comments');
      }
      
      // Get device ID for proper notification exclusion
      final deviceService = DeviceService();
      final deviceId = await deviceService.getDeviceId();
      debugPrint('📱 Using device ID for comment: $deviceId');
      
      // Set the bearer token before making the request
      ApiClient.setBearer(accessToken);
      debugPrint('🔑 Bearer token set for comments request');
      
      final response = await ApiClient.dio.post('/beep/$sightingId/comments', data: {
        'body': body,
        'media_url': mediaUrl,
        'device_id': deviceId, // Include device ID for proper exclusion
      });
      
      debugPrint('🗣️ Comment post response status: ${response.statusCode}');
      debugPrint('🗣️ Comment post response data: ${response.data}');
      
      if (response.statusCode == 201) {
        // Need to fetch the created comment since API only returns ID
        final commentId = response.data['id'];
        final comments = await getComments(sightingId, limit: 1);
        return comments.first; // Should be the newly created comment
      } else {
        throw Exception('Failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error posting comment: $e');
      if (e is DioException) {
        debugPrint('❌ DioException response: ${e.response?.data}');
        debugPrint('❌ DioException status: ${e.response?.statusCode}');
        debugPrint('❌ DioException headers: ${e.response?.headers}');
        debugPrint('❌ DioException request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }
  
  /// Follow a sighting for notifications
  Future<void> followSighting(String sightingId) async {
    try {
      debugPrint('👀 Following sighting: $sightingId');
      
      // Ensure we have the latest access token
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Authentication required to follow sightings');
      }
      
      // Set the bearer token before making the request
      ApiClient.setBearer(accessToken);
      debugPrint('🔑 Bearer token set for follow request');
      
      final response = await ApiClient.dio.post('/beep/$sightingId/follow');
      
      debugPrint('👀 Follow response status: ${response.statusCode}');
      debugPrint('👀 Follow response data: ${response.data}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to follow sighting: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('❌ Error following sighting: $e');
      if (e is DioException) {
        debugPrint('❌ DioException response: ${e.response?.data}');
        debugPrint('❌ DioException status: ${e.response?.statusCode}');
        debugPrint('❌ DioException headers: ${e.response?.headers}');
        debugPrint('❌ DioException request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }
}