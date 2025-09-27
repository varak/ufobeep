import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../glass_card.dart';
import '../../services/ui_feedback.dart';

class CommentComposer extends StatefulWidget {
  final Function(String comment) onSendComment;
  final bool isEnabled;
  final String placeholder;
  
  const CommentComposer({
    super.key,
    required this.onSendComment,
    this.isEnabled = true,
    this.placeholder = 'Add a comment...',
  });
  
  @override
  State<CommentComposer> createState() => _CommentComposerState();
}

class _CommentComposerState extends State<CommentComposer> {
  final TextEditingController _textController = TextEditingController();
  bool _hasText = false;
  bool _isSending = false;
  
  @override
  void initState() {
    super.initState();
    _textController.addListener(_onTextChanged);
  }
  
  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _textController.dispose();
    super.dispose();
  }
  
  void _onTextChanged() {
    setState(() {
      _hasText = _textController.text.trim().isNotEmpty;
    });
  }
  
  Future<void> _sendComment() async {
    if (!_hasText || _isSending) return;
    
    final comment = _textController.text.trim();
    
    setState(() {
      _isSending = true;
    });
    
    try {
      await widget.onSendComment(comment);
      _textController.clear();
      setState(() {
        _hasText = false;
      });
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(12),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _textController,
              enabled: widget.isEnabled && !_isSending,
              maxLines: null,
              keyboardType: TextInputType.multiline,
              textInputAction: TextInputAction.send,
              onSubmitted: (_) => _sendComment(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
              ),
              decoration: InputDecoration(
                filled: true,
                fillColor: AppColors.info,
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: Colors.white70,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.info),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: Colors.white, width: 2),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.info),
                ),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Send button
          GestureDetector(
            onTapDown: (_hasText && !_isSending) ? (_) async {
              await UiFeedback.click();
            } : null,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: (_hasText && !_isSending)
                    ? AppColors.info
                    : AppColors.darkBorder,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : IconButton(
                      onPressed: (_hasText && !_isSending) ? _sendComment : null,
                      icon: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: (_hasText && !_isSending)
                            ? Colors.white
                            : AppColors.textTertiary,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
