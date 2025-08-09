// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chat_message.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ChatMessage _$ChatMessageFromJson(Map<String, dynamic> json) => ChatMessage(
  id: json['id'] as String,
  alertId: json['alertId'] as String,
  senderId: json['senderId'] as String,
  senderDisplayName: json['senderDisplayName'] as String,
  senderAvatar: json['senderAvatar'] as String?,
  content: json['content'] as String,
  type:
      $enumDecodeNullable(_$MessageTypeEnumMap, json['type']) ??
      MessageType.text,
  createdAt: DateTime.parse(json['createdAt'] as String),
  editedAt: json['editedAt'] == null
      ? null
      : DateTime.parse(json['editedAt'] as String),
  isDeleted: json['isDeleted'] as bool? ?? false,
  reactions:
      (json['reactions'] as List<dynamic>?)
          ?.map((e) => MessageReaction.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  replyToId: json['replyToId'] as String?,
  status:
      $enumDecodeNullable(_$MessageStatusEnumMap, json['status']) ??
      MessageStatus.sent,
);

Map<String, dynamic> _$ChatMessageToJson(ChatMessage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'alertId': instance.alertId,
      'senderId': instance.senderId,
      'senderDisplayName': instance.senderDisplayName,
      'senderAvatar': instance.senderAvatar,
      'content': instance.content,
      'type': _$MessageTypeEnumMap[instance.type]!,
      'createdAt': instance.createdAt.toIso8601String(),
      'editedAt': instance.editedAt?.toIso8601String(),
      'isDeleted': instance.isDeleted,
      'reactions': instance.reactions,
      'replyToId': instance.replyToId,
      'status': _$MessageStatusEnumMap[instance.status]!,
    };

const _$MessageTypeEnumMap = {
  MessageType.text: 'text',
  MessageType.image: 'image',
  MessageType.system: 'system',
  MessageType.join: 'join',
  MessageType.leave: 'leave',
};

const _$MessageStatusEnumMap = {
  MessageStatus.sending: 'sending',
  MessageStatus.sent: 'sent',
  MessageStatus.delivered: 'delivered',
  MessageStatus.failed: 'failed',
};

MessageReaction _$MessageReactionFromJson(Map<String, dynamic> json) =>
    MessageReaction(
      emoji: json['emoji'] as String,
      userId: json['userId'] as String,
      userDisplayName: json['userDisplayName'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );

Map<String, dynamic> _$MessageReactionToJson(MessageReaction instance) =>
    <String, dynamic>{
      'emoji': instance.emoji,
      'userId': instance.userId,
      'userDisplayName': instance.userDisplayName,
      'createdAt': instance.createdAt.toIso8601String(),
    };

ChatRoom _$ChatRoomFromJson(Map<String, dynamic> json) => ChatRoom(
  id: json['id'] as String,
  alertId: json['alertId'] as String,
  title: json['title'] as String,
  participantIds: (json['participantIds'] as List<dynamic>)
      .map((e) => e as String)
      .toList(),
  participantNames: Map<String, String>.from(json['participantNames'] as Map),
  createdAt: DateTime.parse(json['createdAt'] as String),
  lastMessageId: json['lastMessageId'] as String?,
  lastActivityAt: json['lastActivityAt'] == null
      ? null
      : DateTime.parse(json['lastActivityAt'] as String),
  messageCount: (json['messageCount'] as num?)?.toInt() ?? 0,
  isActive: json['isActive'] as bool? ?? true,
);

Map<String, dynamic> _$ChatRoomToJson(ChatRoom instance) => <String, dynamic>{
  'id': instance.id,
  'alertId': instance.alertId,
  'title': instance.title,
  'participantIds': instance.participantIds,
  'participantNames': instance.participantNames,
  'createdAt': instance.createdAt.toIso8601String(),
  'lastMessageId': instance.lastMessageId,
  'lastActivityAt': instance.lastActivityAt?.toIso8601String(),
  'messageCount': instance.messageCount,
  'isActive': instance.isActive,
};
