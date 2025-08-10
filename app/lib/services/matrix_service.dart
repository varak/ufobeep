import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/environment.dart';
import '../models/api_models.dart';

/// Matrix SSO token response
class MatrixSSOResponse {
  final String ssoToken;
  final String matrixUserId;
  final String serverName;
  final String loginUrl;
  final DateTime expiresAt;

  MatrixSSOResponse({
    required this.ssoToken,
    required this.matrixUserId,
    required this.serverName,
    required this.loginUrl,
    required this.expiresAt,
  });

  factory MatrixSSOResponse.fromJson(Map<String, dynamic> json) {
    return MatrixSSOResponse(
      ssoToken: json['sso_token'],
      matrixUserId: json['matrix_user_id'],
      serverName: json['server_name'],
      loginUrl: json['login_url'],
      expiresAt: DateTime.parse(json['expires_at']),
    );
  }
}

/// Matrix room information
class MatrixRoomInfo {
  final String roomId;
  final String? roomAlias;
  final String? roomName;
  final String? topic;
  final int memberCount;
  final String joinUrl;
  final String matrixToUrl;

  MatrixRoomInfo({
    required this.roomId,
    this.roomAlias,
    this.roomName,
    this.topic,
    required this.memberCount,
    required this.joinUrl,
    required this.matrixToUrl,
  });

  factory MatrixRoomInfo.fromJson(Map<String, dynamic> json) {
    return MatrixRoomInfo(
      roomId: json['room_id'],
      roomAlias: json['room_alias'],
      roomName: json['room_name'],
      topic: json['topic'],
      memberCount: json['member_count'] ?? 0,
      joinUrl: json['join_url'],
      matrixToUrl: json['matrix_to_url'],
    );
  }
}

/// Matrix message
class MatrixMessage {
  final String eventId;
  final String sender;
  final int timestamp;
  final Map<String, dynamic> content;
  final DateTime? formattedTimestamp;

  MatrixMessage({
    required this.eventId,
    required this.sender,
    required this.timestamp,
    required this.content,
    this.formattedTimestamp,
  });

  factory MatrixMessage.fromJson(Map<String, dynamic> json) {
    return MatrixMessage(
      eventId: json['event_id'],
      sender: json['sender'],
      timestamp: json['timestamp'],
      content: json['content'],
      formattedTimestamp: json['formatted_timestamp'] != null
          ? DateTime.parse(json['formatted_timestamp'])
          : null,
    );
  }

  String get messageBody => content['body'] ?? '';
  String get messageType => content['msgtype'] ?? 'm.text';
}

/// Matrix service for UFOBeep integration
class MatrixService {
  static const String _ssoTokenKey = 'matrix_sso_token';
  static const String _matrixUserIdKey = 'matrix_user_id';
  
  final http.Client _httpClient = http.Client();
  
  /// Generate Matrix SSO token for the current user
  Future<MatrixSSOResponse?> generateSSOToken({
    required String userId,
    String? displayName,
  }) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/v1/matrix/sso');
      
      final response = await _httpClient.post(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'user_id': userId,
          if (displayName != null) 'display_name': displayName,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final ssoResponse = MatrixSSOResponse.fromJson(data);
          
          // Cache the SSO token
          await _cacheSSOToken(ssoResponse);
          
          return ssoResponse;
        }
      }
      
      print('Failed to generate Matrix SSO token: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error generating Matrix SSO token: $e');
      return null;
    }
  }

  /// Get cached SSO token if still valid
  Future<MatrixSSOResponse?> getCachedSSOToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tokenJson = prefs.getString(_ssoTokenKey);
      
      if (tokenJson != null) {
        final tokenData = jsonDecode(tokenJson);
        final ssoResponse = MatrixSSOResponse.fromJson(tokenData);
        
        // Check if token is still valid
        if (ssoResponse.expiresAt.isAfter(DateTime.now())) {
          return ssoResponse;
        } else {
          // Token expired, remove from cache
          await _clearSSOToken();
        }
      }
      
      return null;
    } catch (e) {
      print('Error getting cached SSO token: $e');
      return null;
    }
  }

  /// Get Matrix room information
  Future<MatrixRoomInfo?> getRoomInfo(String roomId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/v1/matrix/room/$roomId/info');
      
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return MatrixRoomInfo.fromJson(data);
      }
      
      print('Failed to get Matrix room info: ${response.statusCode}');
      return null;
    } catch (e) {
      print('Error getting Matrix room info: $e');
      return null;
    }
  }

  /// Get room transcript (messages)
  Future<List<MatrixMessage>> getRoomTranscript(String roomId, {int limit = 50}) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/v1/matrix/room/$roomId/messages?limit=$limit');
      
      final response = await _httpClient.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data['success'] == true) {
          final messagesJson = data['messages'] as List;
          return messagesJson.map((msg) => MatrixMessage.fromJson(msg)).toList();
        }
      }
      
      print('Failed to get Matrix room transcript: ${response.statusCode}');
      return [];
    } catch (e) {
      print('Error getting Matrix room transcript: $e');
      return [];
    }
  }

  /// Join a Matrix room
  Future<bool> joinRoom(String roomId) async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/v1/matrix/room/$roomId/join');
      
      final response = await _httpClient.post(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['success'] == true;
      }
      
      print('Failed to join Matrix room: ${response.statusCode}');
      return false;
    } catch (e) {
      print('Error joining Matrix room: $e');
      return false;
    }
  }

  /// Open Matrix room in external client
  Future<void> openRoomInMatrixClient(String matrixToUrl) async {
    try {
      // This would typically use url_launcher to open the Matrix URL
      // For now, we'll just log the URL
      print('Opening Matrix room: $matrixToUrl');
      
      // In a real implementation:
      // await launchUrl(Uri.parse(matrixToUrl));
    } catch (e) {
      print('Error opening Matrix room: $e');
    }
  }

  /// Check Matrix service health
  Future<bool> checkHealth() async {
    try {
      final url = Uri.parse('${Environment.apiBaseUrl}/v1/matrix/health');
      
      final response = await _httpClient.get(url);
      
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['status'] == 'healthy';
      }
      
      return false;
    } catch (e) {
      print('Error checking Matrix health: $e');
      return false;
    }
  }

  /// Cache SSO token locally
  Future<void> _cacheSSOToken(MatrixSSOResponse ssoResponse) async {
    final prefs = await SharedPreferences.getInstance();
    final tokenJson = jsonEncode({
      'sso_token': ssoResponse.ssoToken,
      'matrix_user_id': ssoResponse.matrixUserId,
      'server_name': ssoResponse.serverName,
      'login_url': ssoResponse.loginUrl,
      'expires_at': ssoResponse.expiresAt.toIso8601String(),
    });
    
    await prefs.setString(_ssoTokenKey, tokenJson);
    await prefs.setString(_matrixUserIdKey, ssoResponse.matrixUserId);
  }

  /// Clear cached SSO token
  Future<void> _clearSSOToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_ssoTokenKey);
    await prefs.remove(_matrixUserIdKey);
  }

  /// Get user's Matrix ID from cache
  Future<String?> getCachedMatrixUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_matrixUserIdKey);
  }

  /// Dispose of resources
  void dispose() {
    _httpClient.close();
  }
}

// Global Matrix service instance
final matrixService = MatrixService();