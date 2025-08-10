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
  final ModerationState moderation;

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
    this.moderation = const ModerationState(),
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
    ModerationState? moderation,
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
      moderation: moderation ?? this.moderation,
    );
  }

  bool get isFromCurrentUser => senderId == 'current_user'; // TODO: Replace with actual user ID
  bool get hasReactions => reactions.isNotEmpty;
  bool get isReply => replyToId != null;
  bool get isEdited => editedAt != null;
  bool get isModerated => moderation.isModerated;
  bool get isSoftHidden => moderation.isSoftHidden;
  bool get isRedacted => moderation.isRedacted;
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

@JsonSerializable()
class ModerationState {
  final ModerationAction action;
  final String? reason;
  final String? moderatorId;
  final String? moderatorName;
  final DateTime? moderatedAt;
  final List<String> flags;
  final bool canShowOriginal; // Allow users to reveal original content

  const ModerationState({
    this.action = ModerationAction.none,
    this.reason,
    this.moderatorId,
    this.moderatorName,
    this.moderatedAt,
    this.flags = const [],
    this.canShowOriginal = false,
  });

  factory ModerationState.fromJson(Map<String, dynamic> json) =>
      _$ModerationStateFromJson(json);

  Map<String, dynamic> toJson() => _$ModerationStateToJson(this);

  bool get isModerated => action != ModerationAction.none;
  bool get isSoftHidden => action == ModerationAction.softHide;
  bool get isRedacted => action == ModerationAction.redact;
  bool get isHardDeleted => action == ModerationAction.delete;
  bool get isWarned => action == ModerationAction.warn;

  String get actionText {
    switch (action) {
      case ModerationAction.none:
        return '';
      case ModerationAction.warn:
        return 'Content flagged';
      case ModerationAction.softHide:
        return 'Content hidden';
      case ModerationAction.redact:
        return 'Content redacted';
      case ModerationAction.delete:
        return 'Content removed';
    }
  }

  ModerationState copyWith({
    ModerationAction? action,
    String? reason,
    String? moderatorId,
    String? moderatorName,
    DateTime? moderatedAt,
    List<String>? flags,
    bool? canShowOriginal,
  }) {
    return ModerationState(
      action: action ?? this.action,
      reason: reason ?? this.reason,
      moderatorId: moderatorId ?? this.moderatorId,
      moderatorName: moderatorName ?? this.moderatorName,
      moderatedAt: moderatedAt ?? this.moderatedAt,
      flags: flags ?? this.flags,
      canShowOriginal: canShowOriginal ?? this.canShowOriginal,
    );
  }
}

enum ModerationAction {
  none,
  warn,      // Show warning badge but keep content visible
  softHide,  // Hide content with option to show
  redact,    // Replace content with placeholder
  delete,    // Remove content entirely (hard delete)
}

enum ModerationFlag {
  spam,
  harassment,
  inappropriate,
  offtopic,
  misinformation,
  violence,
  copyright,
  other,
}

extension ModerationFlagExtension on ModerationFlag {
  String get displayName {
    switch (this) {
      case ModerationFlag.spam:
        return 'Spam';
      case ModerationFlag.harassment:
        return 'Harassment';
      case ModerationFlag.inappropriate:
        return 'Inappropriate Content';
      case ModerationFlag.offtopic:
        return 'Off Topic';
      case ModerationFlag.misinformation:
        return 'Misinformation';
      case ModerationFlag.violence:
        return 'Violence/Threats';
      case ModerationFlag.copyright:
        return 'Copyright';
      case ModerationFlag.other:
        return 'Other';
    }
  }

  String get description {
    switch (this) {
      case ModerationFlag.spam:
        return 'Repetitive or unwanted content';
      case ModerationFlag.harassment:
        return 'Targeting or bullying behavior';
      case ModerationFlag.inappropriate:
        return 'Content not suitable for platform';
      case ModerationFlag.offtopic:
        return 'Not relevant to the discussion';
      case ModerationFlag.misinformation:
        return 'False or misleading information';
      case ModerationFlag.violence:
        return 'Violent or threatening language';
      case ModerationFlag.copyright:
        return 'Unauthorized copyrighted content';
      case ModerationFlag.other:
        return 'Other policy violation';
    }
  }
}