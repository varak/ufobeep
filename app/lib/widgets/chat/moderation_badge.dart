import 'package:flutter/material.dart';
import '../../models/chat_message.dart';
import '../../theme/app_theme.dart';

/// Badge widget that displays moderation status on chat messages
class ModerationBadge extends StatelessWidget {
  const ModerationBadge({
    super.key,
    required this.moderation,
    this.onTap,
    this.compact = false,
  });

  final ModerationState moderation;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!moderation.isModerated) {
      return const SizedBox.shrink();
    }

    final badge = _buildBadge();
    
    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: badge,
      );
    }
    
    return badge;
  }

  Widget _buildBadge() {
    final colors = _getBadgeColors();
    final icon = _getBadgeIcon();
    
    if (compact) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: colors.background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: colors.border),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 12, color: colors.text),
            const SizedBox(width: 3),
            Text(
              _getCompactText(),
              style: TextStyle(
                color: colors.text,
                fontSize: 10,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: colors.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: colors.text),
          const SizedBox(width: 6),
          Text(
            moderation.actionText,
            style: TextStyle(
              color: colors.text,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (moderation.reason?.isNotEmpty == true) ...[
            const SizedBox(width: 4),
            Icon(Icons.info_outline, size: 12, color: colors.text.withOpacity(0.7)),
          ],
        ],
      ),
    );
  }

  String _getCompactText() {
    switch (moderation.action) {
      case ModerationAction.warn:
        return 'WARN';
      case ModerationAction.softHide:
        return 'HIDE';
      case ModerationAction.redact:
        return 'REDACT';
      case ModerationAction.delete:
        return 'DEL';
      case ModerationAction.none:
        return '';
    }
  }

  IconData _getBadgeIcon() {
    switch (moderation.action) {
      case ModerationAction.warn:
        return Icons.warning_outlined;
      case ModerationAction.softHide:
        return Icons.visibility_off_outlined;
      case ModerationAction.redact:
        return Icons.block_outlined;
      case ModerationAction.delete:
        return Icons.delete_outlined;
      case ModerationAction.none:
        return Icons.info_outlined;
    }
  }

  _BadgeColors _getBadgeColors() {
    switch (moderation.action) {
      case ModerationAction.warn:
        return _BadgeColors(
          background: AppColors.semanticWarning.withOpacity(0.1),
          border: AppColors.semanticWarning.withOpacity(0.3),
          text: AppColors.semanticWarning,
        );
      case ModerationAction.softHide:
        return _BadgeColors(
          background: AppColors.semanticInfo.withOpacity(0.1),
          border: AppColors.semanticInfo.withOpacity(0.3),
          text: AppColors.semanticInfo,
        );
      case ModerationAction.redact:
        return _BadgeColors(
          background: AppColors.semanticError.withOpacity(0.1),
          border: AppColors.semanticError.withOpacity(0.3),
          text: AppColors.semanticError,
        );
      case ModerationAction.delete:
        return _BadgeColors(
          background: AppColors.textTertiary.withOpacity(0.1),
          border: AppColors.textTertiary.withOpacity(0.3),
          text: AppColors.textTertiary,
        );
      case ModerationAction.none:
        return _BadgeColors(
          background: AppColors.darkSurface,
          border: AppColors.darkBorder,
          text: AppColors.textSecondary,
        );
    }
  }
}

class _BadgeColors {
  final Color background;
  final Color border;
  final Color text;

  const _BadgeColors({
    required this.background,
    required this.border,
    required this.text,
  });
}

/// Widget that shows detailed moderation information when expanded
class ModerationDetails extends StatelessWidget {
  const ModerationDetails({
    super.key,
    required this.moderation,
    this.onClose,
  });

  final ModerationState moderation;
  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.gavel,
                size: 16,
                color: AppColors.semanticWarning,
              ),
              const SizedBox(width: 8),
              Text(
                'Moderation Action',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Spacer(),
              if (onClose != null)
                GestureDetector(
                  onTap: onClose,
                  child: Icon(
                    Icons.close,
                    size: 16,
                    color: AppColors.textTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 8),
          
          _buildDetailRow('Action', moderation.actionText),
          
          if (moderation.reason?.isNotEmpty == true)
            _buildDetailRow('Reason', moderation.reason!),
          
          if (moderation.moderatorName?.isNotEmpty == true)
            _buildDetailRow('Moderator', moderation.moderatorName!),
          
          if (moderation.moderatedAt != null)
            _buildDetailRow('Date', _formatDateTime(moderation.moderatedAt!)),
          
          if (moderation.flags.isNotEmpty)
            _buildDetailRow('Flags', moderation.flags.join(', ')),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              '$label:',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 11,
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }
}

/// Button to reveal original content for soft-hidden/redacted messages
class RevealContentButton extends StatelessWidget {
  const RevealContentButton({
    super.key,
    required this.onTap,
    required this.isRevealed,
  });

  final VoidCallback onTap;
  final bool isRevealed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.brandPrimary.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              isRevealed ? Icons.visibility_off : Icons.visibility,
              size: 14,
              color: AppColors.brandPrimary,
            ),
            const SizedBox(width: 6),
            Text(
              isRevealed ? 'Hide original' : 'Show original',
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Placeholder for redacted message content
class RedactedContentPlaceholder extends StatelessWidget {
  const RedactedContentPlaceholder({
    super.key,
    this.reason,
  });

  final String? reason;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.semanticError.withOpacity(0.3),
          style: BorderStyle.solid,
        ),
      ),
      child: Column(
        children: [
          Icon(
            Icons.block,
            size: 24,
            color: AppColors.semanticError.withOpacity(0.7),
          ),
          const SizedBox(height: 8),
          Text(
            'Content Redacted',
            style: TextStyle(
              color: AppColors.semanticError,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (reason?.isNotEmpty == true) ...[
            const SizedBox(height: 4),
            Text(
              reason!,
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 10,
                fontStyle: FontStyle.italic,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}