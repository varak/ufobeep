import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
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
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: const BoxDecoration(
        color: AppColors.darkSurface,
        border: Border(
          top: BorderSide(color: AppColors.darkBorder, width: 1),
        ),
      ),
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
                color: AppColors.textPrimary,
                fontSize: 14,
              ),
              decoration: InputDecoration(
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 14,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.darkBorder),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20),
                  borderSide: const BorderSide(color: AppColors.brandPrimary),
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
                    ? AppColors.brandPrimary 
                    : AppColors.darkBorder,
              ),
              child: _isSending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.black,
                      ),
                    )
                  : IconButton(
                      onPressed: (_hasText && !_isSending) ? _sendComment : null,
                      icon: Icon(
                        Icons.send_rounded,
                        size: 20,
                        color: (_hasText && !_isSending) 
                            ? Colors.black 
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