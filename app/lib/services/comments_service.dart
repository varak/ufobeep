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
      final response = await ApiClient.dio.get('/alerts/$sightingId/comments?limit=$limit');
      
      if (response.statusCode == 200) {
        final items = response.data['items'] as List;
        return items.map((json) => Comment.fromJson(json)).toList();
      } else {
        throw Exception('Failed to load comments: ${response.statusCode}');
      }
    } catch (e) {
      print('Error getting comments: $e');
      rethrow;
    }
  }
  
  /// Post a new comment
  Future<Comment> postComment(String sightingId, String body, {String? mediaUrl}) async {
    try {
      print('🗣️ Posting comment to sighting: $sightingId');
      print('🗣️ Comment body: $body');
      
      // Ensure we have the latest access token
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Authentication required to post comments');
      }
      
      // Get device ID for proper notification exclusion
      final deviceService = DeviceService();
      final deviceId = await deviceService.getDeviceId();
      print('📱 Using device ID for comment: $deviceId');
      
      // Set the bearer token before making the request
      ApiClient.setBearer(accessToken);
      print('🔑 Bearer token set for comments request');
      
      final response = await ApiClient.dio.post('/alerts/$sightingId/comments', data: {
        'body': body,
        'media_url': mediaUrl,
        'device_id': deviceId, // Include device ID for proper exclusion
      });
      
      print('🗣️ Comment post response status: ${response.statusCode}');
      print('🗣️ Comment post response data: ${response.data}');
      
      if (response.statusCode == 201) {
        // Need to fetch the created comment since API only returns ID
        final commentId = response.data['id'];
        final comments = await getComments(sightingId, limit: 1);
        return comments.first; // Should be the newly created comment
      } else {
        throw Exception('Failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error posting comment: $e');
      if (e is DioException) {
        print('❌ DioException response: ${e.response?.data}');
        print('❌ DioException status: ${e.response?.statusCode}');
        print('❌ DioException headers: ${e.response?.headers}');
        print('❌ DioException request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }
  
  /// Follow a sighting for notifications
  Future<void> followSighting(String sightingId) async {
    try {
      print('👀 Following sighting: $sightingId');
      
      // Ensure we have the latest access token
      final authRepo = AuthRepository();
      final accessToken = await authRepo.getAccessToken();
      
      if (accessToken == null) {
        throw Exception('Authentication required to follow sightings');
      }
      
      // Set the bearer token before making the request
      ApiClient.setBearer(accessToken);
      print('🔑 Bearer token set for follow request');
      
      final response = await ApiClient.dio.post('/alerts/$sightingId/follow');
      
      print('👀 Follow response status: ${response.statusCode}');
      print('👀 Follow response data: ${response.data}');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to follow sighting: ${response.statusCode}');
      }
    } catch (e) {
      print('❌ Error following sighting: $e');
      if (e is DioException) {
        print('❌ DioException response: ${e.response?.data}');
        print('❌ DioException status: ${e.response?.statusCode}');
        print('❌ DioException headers: ${e.response?.headers}');
        print('❌ DioException request headers: ${e.requestOptions.headers}');
      }
      rethrow;
    }
  }
}