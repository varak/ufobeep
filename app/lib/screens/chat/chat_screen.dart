import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';
import '../../widgets/chat/chat_timeline.dart';
import '../../widgets/chat/message_composer.dart';

class ChatScreen extends ConsumerStatefulWidget {
  const ChatScreen({super.key, required this.alertId});

  final String alertId;

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen> {
  final List<ChatMessage> _messages = [];
  final ScrollController _scrollController = ScrollController();
  bool _isLoading = false;
  bool _hasMore = true;

  @override
  void initState() {
    super.initState();
    _loadMockMessages();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _loadMockMessages() {
    // Mock messages for demonstration
    final mockMessages = [
      ChatMessage(
        id: '1',
        alertId: widget.alertId,
        senderId: 'user1',
        senderDisplayName: 'Sarah Chen',
        content: 'I saw something similar in this area yesterday around 8 PM. Bright light moving in a zigzag pattern.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 45)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: '2',
        alertId: widget.alertId,
        senderId: 'current_user',
        senderDisplayName: 'You',
        content: 'Really? That\'s interesting. Did it make any sound?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 44)),
        type: MessageType.text,
        status: MessageStatus.delivered,
      ),
      ChatMessage(
        id: '3',
        alertId: widget.alertId,
        senderId: 'user2',
        senderDisplayName: 'Mike Rodriguez',
        content: 'I\'m about 2 miles away. Can anyone else see it right now?',
        createdAt: DateTime.now().subtract(const Duration(minutes: 40)),
        type: MessageType.text,
        reactions: [
          MessageReaction(
            emoji: '👀',
            userId: 'user1',
            userDisplayName: 'Sarah Chen',
            createdAt: DateTime.now().subtract(const Duration(minutes: 39)),
          ),
          MessageReaction(
            emoji: '👍',
            userId: 'current_user',
            userDisplayName: 'You',
            createdAt: DateTime.now().subtract(const Duration(minutes: 38)),
          ),
        ],
      ),
      ChatMessage(
        id: '4',
        alertId: widget.alertId,
        senderId: 'system',
        senderDisplayName: 'System',
        content: 'Alex Johnson joined the chat',
        createdAt: DateTime.now().subtract(const Duration(minutes: 35)),
        type: MessageType.system,
      ),
      ChatMessage(
        id: '5',
        alertId: widget.alertId,
        senderId: 'user3',
        senderDisplayName: 'Alex Johnson',
        content: 'Hi everyone! Just arrived at the location. I don\'t see anything right now but I\'ll keep watching.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 34)),
        type: MessageType.text,
      ),
      ChatMessage(
        id: '6',
        alertId: widget.alertId,
        senderId: 'user1',
        senderDisplayName: 'Sarah Chen',
        content: 'Check the photos I took yesterday - might be related',
        createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
        type: MessageType.image,
      ),
      ChatMessage(
        id: '7',
        alertId: widget.alertId,
        senderId: 'current_user',
        senderDisplayName: 'You',
        content: 'Anyone have a telescope or binoculars? Hard to make out details with naked eye.',
        createdAt: DateTime.now().subtract(const Duration(minutes: 25)),
        type: MessageType.text,
        status: MessageStatus.delivered,
      ),
    ];

    setState(() {
      _messages.addAll(mockMessages);
    });
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      alertId: widget.alertId,
      senderId: 'current_user',
      senderDisplayName: 'You',
      content: content.trim(),
      createdAt: DateTime.now(),
      type: MessageType.text,
      status: MessageStatus.sending,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Simulate message being sent
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          final index = _messages.indexWhere((m) => m.id == newMessage.id);
          if (index != -1) {
            _messages[index] = newMessage.copyWith(status: MessageStatus.delivered);
          }
        });
      }
    });

    // Scroll to bottom
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleAttachment() {
    // Show attachment options
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Attachment Options',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt,
                  label: 'Camera',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open camera
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library,
                  label: 'Gallery',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Open gallery
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.location_on,
                  label: 'Location',
                  onTap: () {
                    Navigator.pop(context);
                    // TODO: Share location
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
            ),
            child: Icon(
              icon,
              color: AppColors.brandPrimary,
              size: 28,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _handleMessageTap(ChatMessage message) {
    // TODO: Show message options (reply, edit, delete, etc.)
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Message Options',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          'Options for message from ${message.senderDisplayName}',
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Reply'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _handleReactionTap(ChatMessage message, String emoji) {
    // TODO: Toggle reaction
    print('Toggle $emoji on message ${message.id}');
  }

  void _loadMoreMessages() {
    if (_isLoading) return;
    
    setState(() {
      _isLoading = true;
    });

    // Simulate loading more messages
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _hasMore = false; // No more messages for demo
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Alert Chat'),
            Text(
              '${_getUniqueParticipantCount()} participants',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
                fontWeight: FontWeight.normal,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show chat info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ChatTimeline(
              messages: _messages,
              onMessageTap: _handleMessageTap,
              onReactionTap: _handleReactionTap,
              isLoading: _isLoading,
              hasMore: _hasMore,
              onLoadMore: _loadMoreMessages,
            ),
          ),
          MessageComposer(
            onSendMessage: _sendMessage,
            onAttachFile: _handleAttachment,
            placeholder: 'Share your observations...',
          ),
        ],
      ),
    );
  }

  int _getUniqueParticipantCount() {
    final participants = _messages
        .where((m) => m.type != MessageType.system)
        .map((m) => m.senderId)
        .toSet();
    return participants.length;
  }
}