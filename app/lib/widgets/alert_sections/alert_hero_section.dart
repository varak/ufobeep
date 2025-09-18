import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../utils/alert_title_utils.dart';
import '../chewie_video_widget.dart';
import '../glass_card.dart';

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

    // If there's only one media file, show it as before
    if (alert.mediaFiles.length == 1) {
      return _buildSingleMediaDisplay(alert.mediaFiles.first);
    }

    // If there are multiple files, show a horizontal gallery
    return _buildMediaGallery();
  }

  Widget _buildSingleMediaDisplay(Map<String, dynamic> media) {
    // Use web-optimized URL for detail view
    String mediaUrl = media['web_url'] as String? ?? media['url'] as String? ?? '';
    
    // For videos, use original URL
    final apiType = media['type'] as String? ?? 'image';
    if (apiType == 'video') {
      mediaUrl = media['url'] as String? ?? '';
    }
    
    if (mediaUrl.isEmpty) {
      return Container(
        width: double.infinity,
        height: 200,
        decoration: const BoxDecoration(
          color: AppColors.darkBackground,
          borderRadius: BorderRadius.only(
            bottomLeft: Radius.circular(16),
            bottomRight: Radius.circular(16),
          ),
        ),
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text('Media unavailable', style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    return GestureDetector(
      onTap: () => onMediaTap?.call(0),
      child: Container(
        width: double.infinity,
        constraints: const BoxConstraints(
          maxHeight: 300,
          minHeight: 200,
        ),
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
          child: _buildMediaImage(mediaUrl, apiType),
        ),
      ),
    );
  }

  Widget _buildMediaGallery() {
    return Container(
      height: 200,
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
        child: Stack(
          children: [
            // Horizontal scrollable gallery
            ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: alert.mediaFiles.length,
              itemBuilder: (context, index) {
                final media = alert.mediaFiles[index];
                String mediaUrl = media['web_url'] as String? ?? media['url'] as String? ?? '';
                final apiType = media['type'] as String? ?? 'image';
                
                if (apiType == 'video') {
                  mediaUrl = media['url'] as String? ?? '';
                }

                return GestureDetector(
                  onTap: () => onMediaTap?.call(index),
                  child: Container(
                    width: 200,
                    margin: EdgeInsets.only(right: index < alert.mediaFiles.length - 1 ? 8 : 0),
                    child: _buildMediaImage(mediaUrl, apiType),
                  ),
                );
              },
            ),
            // Media count indicator
            Positioned(
              top: 12,
              right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.7),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(
                      Icons.photo_library,
                      size: 14,
                      color: Colors.white,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${alert.mediaFiles.length}',
                      style: const TextStyle(
                        color: Colors.white,
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
      ),
    );
  }

  Widget _buildMediaImage(String mediaUrl, String apiType) {
    if (mediaUrl.isEmpty) {
      return Container(
        color: AppColors.darkBackground,
        child: const Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.broken_image, size: 48, color: AppColors.textTertiary),
              SizedBox(height: 8),
              Text('Media unavailable', style: TextStyle(color: AppColors.textTertiary)),
            ],
          ),
        ),
      );
    }

    // For videos, use the ChewieVideoWidget with enhanced streaming
    if (apiType == 'video') {
      return ChewieVideoWidget(
        videoUrl: mediaUrl,
        width: double.infinity,
        height: double.infinity,
        autoPlay: false,
        showControls: true,
      );
    }

    // For images, use Image.network
    return Image.network(
      mediaUrl,
      fit: BoxFit.cover,
      width: double.infinity,
      height: double.infinity,
      loadingBuilder: (context, child, loadingProgress) {
        if (loadingProgress == null) return child;
        return const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        );
      },
      errorBuilder: (context, error, stackTrace) {
        return Container(
          color: AppColors.darkBackground,
          child: const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.error, size: 48, color: AppColors.semanticError),
                SizedBox(height: 8),
                Text('Failed to load image', style: TextStyle(color: AppColors.textSecondary)),
              ],
            ),
          ),
        );
      },
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
