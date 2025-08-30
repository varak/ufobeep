class Comment {
  final int id;
  final String userId;
  final String username;
  final String body;
  final String? mediaUrl;
  final DateTime createdAt;
  
  const Comment({
    required this.id,
    required this.userId,
    required this.username,
    required this.body,
    this.mediaUrl,
    required this.createdAt,
  });
  
  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      userId: json['user_id'] as String,
      username: json['username'] as String,
      body: json['body'] as String,
      mediaUrl: json['media_url'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }
  
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'username': username,
      'body': body,
      'media_url': mediaUrl,
      'created_at': createdAt.toIso8601String(),
    };
  }
}