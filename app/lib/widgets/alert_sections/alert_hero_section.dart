import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/alert_title_utils.dart';
import '../better_player_widget.dart';
import '../glass_card.dart';
import '../media_grid.dart';
import '../../models/view_media.dart';

class AlertHeroSection extends StatelessWidget {
  const AlertHeroSection({
    super.key,
    required this.alert,
    this.compact = false,
    this.onMediaTap,
  });

  final Alert alert;
  final bool compact;
  final Function(int)? onMediaTap;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompactHero();
    }
    return _buildFullHero();
  }

  Widget _buildFullHero() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with UFO icon and title
          Padding(
            padding: const EdgeInsets.all(20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // UFO icon
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Text(
                    '🛸',
                    style: TextStyle(fontSize: 24),
                  ),
                ),
                
                const SizedBox(width: 16),
                
                // Title and metadata
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Builder(
                        builder: (context) {
                          final l10n = AppLocalizations.of(context)!;

                          // Use same title logic as alerts tab
                          final title = AlertTitleUtils.getDynamicTitle(l10n, alert);

                          return Text(
                            title,
                            style: const TextStyle(
                              color: AppColors.textPrimary,
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 8),
                      
                      // Show type badge based on content
                      if (!alert.hasMedia) ...[
                        // Text-only beep: show "report only" if has description, "beep only" if no description
                        if (alert.description?.trim().isNotEmpty ?? false) ...[
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.textTertiary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: AppColors.textTertiary.withOpacity(0.3),
                              ),
                            ),
                            child: Builder(
                              builder: (context) => Text(
                                AppLocalizations.of(context)!.reportOnly,
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                        ] else ...[
                          // No description, no media = "beep only"
                          Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: AppColors.textTertiary.withOpacity(0.3),
                            ),
                          ),
                          child: Builder(
                            builder: (context) => Text(
                              AppLocalizations.of(context)!.beepOnly,
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        ],
                      ],

                      // Only show verification badge if verified, no redundant "UFO Sighting" text
                      if (alert.isVerified) ...[ 
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.brandPrimary.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: AppColors.brandPrimary.withOpacity(0.3),
                                ),
                              ),
                              child: Builder(
                                builder: (context) => Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    const Icon(
                                      Icons.verified,
                                      color: AppColors.brandPrimary,
                                      size: 14,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      AppLocalizations.of(context)!.verified,
                                      style: const TextStyle(
                                        color: AppColors.brandPrimary,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
          
          // Media display (if available)
          if (alert.hasMedia)
            _buildMediaDisplay(),
        ],
      ),
    );
  }

  Widget _buildCompactHero() {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Compact UFO icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text(
              '🛸',
              style: TextStyle(fontSize: 16),
            ),
          ),
          
          const SizedBox(width: 12),
          
          // Compact title and time
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Builder(
                  builder: (context) {
                    final l10n = AppLocalizations.of(context)!;

                    // Use same title logic as alerts tab
                    final title = AlertTitleUtils.getDynamicTitle(l10n, alert);

                    return Text(
                      title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    );
                  },
                ),
                const SizedBox(height: 4),
                Builder(
                  builder: (ctx) => Text(
                    _formatDateTime(ctx, alert.createdAt),
                    style: const TextStyle(
                      color: AppColors.textTertiary,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Compact media indicator
          if (alert.hasMedia)
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Icon(
                Icons.photo,
                color: AppColors.brandPrimary,
                size: 16,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildMediaDisplay() {
    if (alert.mediaFiles.isEmpty) {
      return const SizedBox.shrink();
    }

    // Convert alert media files to ViewMedia format
    final viewMedia = alert.mediaFiles.map<ViewMedia>((media) {
      final mediaUrl = media['web_url'] as String? ?? media['url'] as String? ?? '';
      final apiType = media['type'] as String? ?? 'image';
      final id = media['id'] as String? ?? '${alert.id}_${alert.mediaFiles.indexOf(media)}';

      return ViewMedia(
        id: id,
        type: apiType == 'video' ? 'video' : 'image',
        url: apiType == 'video' ? (media['url'] as String? ?? '') : mediaUrl,
        thumbUrl: apiType == 'video' ? mediaUrl : null,
        caption: media['caption'] as String?,
      );
    }).toList();

    final title = 'Media'; // Simple title for now

    // Use direct media grid - no callbacks
    return Container(
      decoration: const BoxDecoration(
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(16),
          bottomRight: Radius.circular(16),
        ),
        child: MediaGrid(
          items: viewMedia,
          title: title,
        ),
      ),
    );
  }


  String _formatDateTime(BuildContext context, DateTime dateTime) {
    // Ensure both times are in the same timezone (local)
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

    final l10n = AppLocalizations.of(context)!;
    if (difference.inDays > 0) {
      return l10n.timeDaysAgo(difference.inDays);
    } else if (difference.inHours > 0) {
      return l10n.timeHoursAgo(difference.inHours);
    } else if (difference.inMinutes > 0) {
      return l10n.timeMinutesAgo(difference.inMinutes);
    } else {
      return l10n.timeJustNow;
    }
  }
}
