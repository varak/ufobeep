import 'package:dio/dio.dart';
import '../models/comment.dart';
import '../services/api_client.dart';

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
      final response = await ApiClient.dio.post('/alerts/$sightingId/comments', data: {
        'body': body,
        'media_url': mediaUrl,
      });
      
      if (response.statusCode == 201) {
        // Need to fetch the created comment since API only returns ID
        final commentId = response.data['id'];
        final comments = await getComments(sightingId, limit: 1);
        return comments.first; // Should be the newly created comment
      } else {
        throw Exception('Failed to post comment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error posting comment: $e');
      rethrow;
    }
  }
  
  /// Follow a sighting for notifications
  Future<void> followSighting(String sightingId) async {
    try {
      final response = await ApiClient.dio.post('/alerts/$sightingId/follow');
      
      if (response.statusCode != 201) {
        throw Exception('Failed to follow sighting: ${response.statusCode}');
      }
    } catch (e) {
      print('Error following sighting: $e');
      rethrow;
    }
  }
}