import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class MessageComposer extends StatefulWidget {
  const MessageComposer({
    super.key,
    required this.onSendMessage,
    this.onAttachFile,
    this.isEnabled = true,
    this.placeholder = 'Type a message...',
  });

  final Function(String message) onSendMessage;
  final VoidCallback? onAttachFile;
  final bool isEnabled;
  final String placeholder;

  @override
  State<MessageComposer> createState() => _MessageComposerState();
}

class _MessageComposerState extends State<MessageComposer> {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _textController.text.trim().isNotEmpty;
    if (hasText != _hasText) {
      setState(() {
        _hasText = hasText;
      });
    }
  }

  void _sendMessage() {
    final message = _textController.text.trim();
    if (message.isNotEmpty) {
      widget.onSendMessage(message);
      _textController.clear();
      _focusNode.requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Attachment button
              if (widget.onAttachFile != null)
                _buildAttachButton(),
              
              const SizedBox(width: 12),
              
              // Text input
              Expanded(
                child: _buildTextInput(),
              ),
              
              const SizedBox(width: 12),
              
              // Send button
              _buildSendButton(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttachButton() {
    return GestureDetector(
      onTap: widget.isEnabled ? widget.onAttachFile : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkBackground,
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Icon(
          Icons.add,
          color: widget.isEnabled 
              ? AppColors.brandPrimary 
              : AppColors.textTertiary,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildTextInput() {
    return Container(
      constraints: const BoxConstraints(
        minHeight: 40,
        maxHeight: 120,
      ),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: _focusNode.hasFocus 
              ? AppColors.brandPrimary.withOpacity(0.5)
              : AppColors.darkBorder,
        ),
      ),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        enabled: widget.isEnabled,
        maxLines: null,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 16,
        ),
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 16,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 10,
          ),
        ),
        onSubmitted: widget.isEnabled && _hasText ? (_) => _sendMessage() : null,
      ),
    );
  }

  Widget _buildSendButton() {
    final isActive = widget.isEnabled && _hasText;
    
    return GestureDetector(
      onTap: isActive ? _sendMessage : null,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isActive 
              ? AppColors.brandPrimary 
              : AppColors.darkBackground,
          shape: BoxShape.circle,
          border: Border.all(
            color: isActive 
                ? AppColors.brandPrimary 
                : AppColors.darkBorder,
          ),
        ),
        child: Icon(
          Icons.send,
          color: isActive 
              ? AppColors.darkBackground 
              : AppColors.textTertiary,
          size: 20,
        ),
      ),
    );
  }
}

class MessageComposerActions extends StatelessWidget {
  const MessageComposerActions({
    super.key,
    this.onImageTap,
    this.onCameraTap,
    this.onLocationTap,
    this.onEmojiTap,
  });

  final VoidCallback? onImageTap;
  final VoidCallback? onCameraTap;
  final VoidCallback? onLocationTap;
  final VoidCallback? onEmojiTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 60,
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder),
        ),
      ),
      child: Row(
        children: [
          _buildActionButton(
            icon: Icons.image,
            label: 'Photo',
            onTap: onImageTap,
          ),
          _buildActionButton(
            icon: Icons.camera_alt,
            label: 'Camera',
            onTap: onCameraTap,
          ),
          _buildActionButton(
            icon: Icons.location_on,
            label: 'Location',
            onTap: onLocationTap,
          ),
          _buildActionButton(
            icon: Icons.emoji_emotions,
            label: 'Emoji',
            onTap: onEmojiTap,
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          height: double.infinity,
          decoration: BoxDecoration(
            color: Colors.transparent,
            border: Border(
              right: BorderSide(color: AppColors.darkBorder),
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: onTap != null 
                    ? AppColors.brandPrimary 
                    : AppColors.textTertiary,
                size: 24,
              ),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(
                  color: onTap != null 
                      ? AppColors.brandPrimary 
                      : AppColors.textTertiary,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}