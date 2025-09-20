import 'package:flutter/material.dart';
import '../../models/comment.dart';
import '../../theme/app_theme.dart';

class CommentItem extends StatelessWidget {
  final Comment comment;

  const CommentItem({
    super.key,
    required this.comment,
  });

  String _formatTPlus(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    final minutes = diff.inMinutes;

    if (minutes < 60) {
      return 'T+${minutes}m';
    }
    final hours = diff.inHours;
    if (hours < 24) {
      final remainingMinutes = minutes % 60;
      return 'T+${hours}h${remainingMinutes}m';
    }
    final days = diff.inDays;
    final remainingHours = hours % 24;
    return 'T+${days}d${remainingHours}h';
  }
  
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // User avatar placeholder
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.brandPrimary.withOpacity(0.2),
            ),
            child: Icon(
              Icons.person,
              size: 18,
              color: AppColors.brandPrimary,
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Comment content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Username and timestamp
                Row(
                  children: [
                    Text(
                      comment.username,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      _formatTPlus(comment.createdAt),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 4),
                
                // Comment body
                Text(
                  comment.body,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                
                // Media if present
                if (comment.mediaUrl != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    height: 120,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: AppColors.darkBorder,
                    ),
                    child: const Center(
                      child: Icon(Icons.image, color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
  
}