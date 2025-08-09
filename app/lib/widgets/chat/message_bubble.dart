import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

class MessageBubble extends StatelessWidget {
  const MessageBubble({
    super.key,
    required this.message,
    this.onTap,
    this.onReactionTap,
  });

  final ChatMessage message;
  final VoidCallback? onTap;
  final Function(String emoji)? onReactionTap;

  @override
  Widget build(BuildContext context) {
    if (message.type == MessageType.system) {
      return _buildSystemMessage();
    }

    final isFromCurrentUser = message.isFromCurrentUser;
    
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isFromCurrentUser) ...[
            _buildAvatar(),
            const SizedBox(width: 8),
          ],
          Expanded(
            child: Column(
              crossAxisAlignment: isFromCurrentUser 
                  ? CrossAxisAlignment.end 
                  : CrossAxisAlignment.start,
              children: [
                if (!isFromCurrentUser) _buildSenderInfo(),
                _buildMessageBubble(isFromCurrentUser),
                if (message.hasReactions) _buildReactions(),
                _buildMessageStatus(),
              ],
            ),
          ),
          if (isFromCurrentUser) ...[
            const SizedBox(width: 8),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
      ),
      child: message.senderAvatar?.isNotEmpty == true
          ? ClipOval(
              child: Image.network(
                message.senderAvatar!,
                width: 32,
                height: 32,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => _buildDefaultAvatar(),
              ),
            )
          : _buildDefaultAvatar(),
    );
  }

  Widget _buildDefaultAvatar() {
    return Icon(
      Icons.person,
      size: 20,
      color: AppColors.brandPrimary,
    );
  }

  Widget _buildSenderInfo() {
    return Padding(
      padding: const EdgeInsets.only(left: 12, bottom: 4),
      child: Row(
        children: [
          Text(
            message.senderDisplayName,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          if (message.isEdited) ...[
            const SizedBox(width: 4),
            Text(
              '(edited)',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageBubble(bool isFromCurrentUser) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: isFromCurrentUser 
              ? AppColors.brandPrimary.withOpacity(0.1)
              : AppColors.darkSurface,
          borderRadius: BorderRadius.circular(18).copyWith(
            bottomLeft: isFromCurrentUser 
                ? const Radius.circular(18)
                : const Radius.circular(4),
            bottomRight: isFromCurrentUser 
                ? const Radius.circular(4)
                : const Radius.circular(18),
          ),
          border: Border.all(
            color: isFromCurrentUser 
                ? AppColors.brandPrimary.withOpacity(0.2)
                : AppColors.darkBorder,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (message.isReply) _buildReplyPreview(),
            _buildMessageContent(),
          ],
        ),
      ),
    );
  }

  Widget _buildReplyPreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppColors.brandPrimary,
            width: 3,
          ),
        ),
      ),
      child: Text(
        '↳ Replying to message...', // TODO: Load actual reply content
        style: TextStyle(
          color: AppColors.textTertiary,
          fontSize: 12,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (message.type) {
      case MessageType.text:
        return Text(
          message.content,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            height: 1.4,
          ),
        );
      
      case MessageType.image:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 200,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(
                child: Icon(
                  Icons.image,
                  size: 48,
                  color: AppColors.textTertiary,
                ),
              ),
            ),
            if (message.content.isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                message.content,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                ),
              ),
            ],
          ],
        );
      
      default:
        return Text(
          message.content,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
          ),
        );
    }
  }

  Widget _buildReactions() {
    final reactionGroups = <String, List<MessageReaction>>{};
    
    for (final reaction in message.reactions) {
      reactionGroups.putIfAbsent(reaction.emoji, () => []).add(reaction);
    }
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactionGroups.entries.map((entry) {
          final emoji = entry.key;
          final reactions = entry.value;
          
          return GestureDetector(
            onTap: onReactionTap != null ? () => onReactionTap!(emoji) : null,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    emoji,
                    style: const TextStyle(fontSize: 14),
                  ),
                  if (reactions.length > 1) ...[
                    const SizedBox(width: 4),
                    Text(
                      reactions.length.toString(),
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMessageStatus() {
    if (!message.isFromCurrentUser) return const SizedBox.shrink();
    
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            _formatTime(message.createdAt),
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          const SizedBox(width: 4),
          Icon(
            _getStatusIcon(),
            size: 12,
            color: _getStatusColor(),
          ),
          if (message.isEdited) ...[
            const SizedBox(width: 4),
            Text(
              'edited',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.darkSurface.withOpacity(0.5),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            message.content,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ),
      ),
    );
  }

  IconData _getStatusIcon() {
    switch (message.status) {
      case MessageStatus.sending:
        return Icons.access_time;
      case MessageStatus.sent:
        return Icons.check;
      case MessageStatus.delivered:
        return Icons.done_all;
      case MessageStatus.failed:
        return Icons.error_outline;
    }
  }

  Color _getStatusColor() {
    switch (message.status) {
      case MessageStatus.sending:
        return AppColors.textTertiary;
      case MessageStatus.sent:
        return AppColors.textTertiary;
      case MessageStatus.delivered:
        return AppColors.brandPrimary;
      case MessageStatus.failed:
        return AppColors.semanticError;
    }
  }

  String _formatTime(DateTime dateTime) {
    final hour = dateTime.hour;
    final minute = dateTime.minute;
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour == 0 ? 12 : (hour > 12 ? hour - 12 : hour);
    
    return '$displayHour:${minute.toString().padLeft(2, '0')} $period';
  }
}