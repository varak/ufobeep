import 'package:json_annotation/json_annotation.dart';

part 'chat_message.g.dart';

@JsonSerializable()
class ChatMessage {
  final String id;
  final String alertId;
  final String senderId;
  final String senderDisplayName;
  final String? senderAvatar;
  final String content;
  final MessageType type;
  final DateTime createdAt;
  final DateTime? editedAt;
  final bool isDeleted;
  final List<MessageReaction> reactions;
  final String? replyToId;
  final MessageStatus status;

  const ChatMessage({
    required this.id,
    required this.alertId,
    required this.senderId,
    required this.senderDisplayName,
    this.senderAvatar,
    required this.content,
    this.type = MessageType.text,
    required this.createdAt,
    this.editedAt,
    this.isDeleted = false,
    this.reactions = const [],
    this.replyToId,
    this.status = MessageStatus.sent,
  });

  factory ChatMessage.fromJson(Map<String, dynamic> json) =>
      _$ChatMessageFromJson(json);

  Map<String, dynamic> toJson() => _$ChatMessageToJson(this);

  ChatMessage copyWith({
    String? id,
    String? alertId,
    String? senderId,
    String? senderDisplayName,
    String? senderAvatar,
    String? content,
    MessageType? type,
    DateTime? createdAt,
    DateTime? editedAt,
    bool? isDeleted,
    List<MessageReaction>? reactions,
    String? replyToId,
    MessageStatus? status,
  }) {
    return ChatMessage(
      id: id ?? this.id,
      alertId: alertId ?? this.alertId,
      senderId: senderId ?? this.senderId,
      senderDisplayName: senderDisplayName ?? this.senderDisplayName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      content: content ?? this.content,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      editedAt: editedAt ?? this.editedAt,
      isDeleted: isDeleted ?? this.isDeleted,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      status: status ?? this.status,
    );
  }

  bool get isFromCurrentUser => senderId == 'current_user'; // TODO: Replace with actual user ID
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyToId != null;
  bool get isEdited => editedAt != null;
}

enum MessageType {
  text,
  image,
  system,
  join,
  leave,
}

enum MessageStatus {
  sending,
  sent,
  delivered,
  failed,
}

@JsonSerializable()
class MessageReaction {
  final String emoji;
  final String userId;
  final String userDisplayName;
  final DateTime createdAt;

  const MessageReaction({
    required this.emoji,
    required this.userId,
    required this.userDisplayName,
    required this.createdAt,
  });

  factory MessageReaction.fromJson(Map<String, dynamic> json) =>
      _$MessageReactionFromJson(json);

  Map<String, dynamic> toJson() => _$MessageReactionToJson(this);
}

@JsonSerializable()
class ChatRoom {
  final String id;
  final String alertId;
  final String title;
  final List<String> participantIds;
  final Map<String, String> participantNames;
  final DateTime createdAt;
  final String? lastMessageId;
  final DateTime? lastActivityAt;
  final int messageCount;
  final bool isActive;

  const ChatRoom({
    required this.id,
    required this.alertId,
    required this.title,
    required this.participantIds,
    required this.participantNames,
    required this.createdAt,
    this.lastMessageId,
    this.lastActivityAt,
    this.messageCount = 0,
    this.isActive = true,
  });

  factory ChatRoom.fromJson(Map<String, dynamic> json) =>
      _$ChatRoomFromJson(json);

  Map<String, dynamic> toJson() => _$ChatRoomToJson(this);

  int get participantCount => participantIds.length;
  bool get hasActivity => lastActivityAt != null;
}