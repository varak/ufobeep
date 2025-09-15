import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';
import '../utils/unit_conversion.dart';
import '../providers/user_preferences_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/ui_feedback.dart';
import '../utils/alert_title_utils.dart';
import 'glass_card.dart';

class AlertCard extends ConsumerWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.onTap,
    this.showDistance = true,
  });

  final Alert alert;
  final VoidCallback? onTap;
  final bool showDistance;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final l10n = AppLocalizations.of(context)!;
    final units = userPrefs?.units ?? 'metric';
    
    return GlassCard(
      padding: const EdgeInsets.all(12),
      onTap: onTap ?? () async {
        await UiFeedback.click();
        if (context.mounted) {
          context.go('/alert/${alert.id}');
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context, l10n, units, userPrefs),
          const SizedBox(height: 12),
          if (alert.mediaFiles.isNotEmpty) ...[
            _buildMediaThumbnails(context),
            const SizedBox(height: 12),
          ],
          if (_getPreviewDescription()?.isNotEmpty == true) ...[
            _buildDescription(),
            const SizedBox(height: 12),
          ],
          _buildFooterRow(l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, AppLocalizations l10n, String units, dynamic userPrefs) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUfoIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTitleAndMetadata(context, l10n, units),
        ),
        _buildTimestampAndDistance(context, units, userPrefs),
      ],
    );
  }

  Widget _buildUfoIcon() {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Text(
        '🛸',
        style: TextStyle(fontSize: 16),
      ),
    );
  }

  Widget _buildTitleAndMetadata(BuildContext context, AppLocalizations l10n, String units) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AlertTitleUtils.getDynamicTitle(l10n, alert),
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        if (_getLocationName(alert).isNotEmpty) ...[
          const SizedBox(height: 4),
          Row(
            children: [
              Flexible(
                child: Text(
                  _getLocationName(alert),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 15,
                  ),
                ),
              ),
              if (alert.distance != null && alert.distance! > 0 && showDistance) ...[
                const SizedBox(width: 8),
                Text(
                  UnitConversion.formatDistance(alert.distance! * 1000, units),
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 13,
                  ),
                ),
              ],
            ],
          ),
        ],
        _buildVerificationBadge(l10n),
      ],
    );
  }

  Widget _buildVerificationBadge(AppLocalizations l10n) {
    if (alert.isVerified && alert.source != 'mufon') {
      return Column(
        children: [
          const SizedBox(height: 4),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: AppColors.brandPrimary.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.verified,
                  color: AppColors.brandPrimary,
                  size: 10,
                ),
                const SizedBox(width: 2),
                Text(
                  l10n.verified,
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      );
    }
    return const SizedBox.shrink();
  }

  Widget _buildTimestampAndDistance(BuildContext context, String units, dynamic userPrefs) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        if (alert.reporterUsername != null && alert.source != 'mufon') ...[
          Text(
            alert.reporterUsername!,
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
        ],
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Text(
              alert.source == 'mufon'
                  ? _getMufonReportDate(context, alert)
                  : _formatActualDateTime(context, alert.createdAt, use24Hour: userPrefs?.use24HourTime),
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              alert.source == 'mufon'
                  ? _formatDateTime(context, alert.occurredAt ?? alert.createdAt) // Show T+ time from occurrence for MUFON
                  : _formatDateTime(context, alert.createdAt),
              style: const TextStyle(
                color: AppColors.textTertiary,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDescription() {
    final previewText = _getPreviewDescription();
    if (previewText == null || previewText.isEmpty) {
      return const SizedBox.shrink();
    }

    return Text(
      previewText,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 14,
        height: 1.4,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }

  /// Smart description selection for preview cards - matches web logic
  String? _getPreviewDescription() {
    // MUFON alerts have short_description - check enrichment data from API
    if (alert.source == 'mufon' && alert.enrichment != null) {
      final enrichment = alert.enrichment!;
      if (enrichment.containsKey('short_description')) {
        final shortDesc = enrichment['short_description']?.toString().trim();
        if (shortDesc != null && shortDesc.isNotEmpty) {
          return shortDesc;
        }
      }
    }

    // For MUFON alerts without short_description, clean up the long description
    if (alert.source == 'mufon' && alert.description != null) {
      // Remove the appended metadata section (everything after the separator line)
      final cleanDescription = alert.description!.split('━━━━━━━━━━━━━━━━━━━━━━━━')[0].trim();
      final truncated = cleanDescription.length > 150
          ? cleanDescription.substring(0, 150)
          : cleanDescription;
      return truncated + (cleanDescription.length > 150 ? '...' : '');
    }

    // Regular alerts use truncated main description
    if (alert.description != null && alert.description!.isNotEmpty) {
      final truncated = alert.description!.length > 150
          ? alert.description!.substring(0, 150)
          : alert.description!;
      return truncated + (alert.description!.length > 150 ? '...' : '');
    }

    return null;
  }

  Widget _buildFooterRow(AppLocalizations l10n) {
    return Row(
      children: [
        if (alert.commentCount > 0)
          _buildCommentsIndicator(),
        _buildContentTypeIndicator(l10n),
        if (alert.witnessCount > 1)
          _buildWitnessIndicator(),
        const Spacer(),
        const Icon(
          Icons.arrow_forward_ios,
          size: 12,
          color: AppColors.textTertiary,
        ),
      ],
    );
  }

  Widget _buildDistanceBadge(String units) {
    if (alert.distance == null) return const SizedBox.shrink();
    
    final distance = alert.distance!;
    Color badgeColor;
    
    if (distance < 1.0) {
      badgeColor = AppColors.semanticError;
    } else if (distance < 5.0) {
      badgeColor = AppColors.semanticWarning;
    } else if (distance < 15.0) {
      badgeColor = AppColors.brandPrimary;
    } else {
      badgeColor = AppColors.textTertiary;
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        UnitConversion.formatDistance(distance * 1000, units),
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  Widget _buildContentTypeIndicator(AppLocalizations l10n) {
    final hasMedia = alert.mediaFiles.isNotEmpty;
    final hasDescription = _getPreviewDescription()?.trim().isNotEmpty ?? false;
    
    if (!hasMedia && !hasDescription) {
      return _buildBadge(l10n.beepOnly, Icons.location_on, AppColors.textTertiary);
    }
    
    if (!hasMedia && hasDescription) {
      return _buildBadge(l10n.reportOnly, Icons.visibility, AppColors.textTertiary);
    }
    
    if (hasMedia && !hasDescription) {
      // Check if all media files are the same type
      final videoCount = alert.mediaFiles.where((media) => media['type'] == 'video').length;
      final imageCount = alert.mediaFiles.length - videoCount;

      if (videoCount > 0 && imageCount > 0) {
        // Mixed media - show "Media Only"
        return _buildBadge(l10n.mediaOnly, Icons.perm_media, AppColors.textTertiary);
      } else if (videoCount > 0) {
        // Only videos
        return _buildBadge(l10n.videoOnly, Icons.videocam, AppColors.textTertiary);
      } else {
        // Only images
        return _buildBadge(l10n.imageOnly, Icons.photo, AppColors.textTertiary);
      }
    }

    // If has both media and description, show no badge
    if (hasMedia && hasDescription) {
      return const SizedBox.shrink();
    }
    
    return const SizedBox.shrink();
  }

  Widget _buildBadge(String text, IconData icon, Color color) {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 4),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWitnessIndicator() {
    return Container(
      margin: const EdgeInsets.only(right: 8),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.semanticSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.visibility,
            size: 12,
            color: AppColors.semanticSuccess,
          ),
          const SizedBox(width: 4),
          Text(
            '${alert.witnessCount}',
            style: const TextStyle(
              color: AppColors.semanticSuccess,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommentsIndicator() {
    return Consumer(
      builder: (context, ref, _) {
        return GestureDetector(
          onTap: () async {
            await UiFeedback.click();
            if (context.mounted) {
              context.go('/alert/${alert.id}/comments');
            }
          },
          child: Container(
            margin: const EdgeInsets.only(right: 8),
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.comment,
                  size: 12,
                  color: AppColors.brandPrimary,
                ),
                const SizedBox(width: 4),
                Text(
                  '${alert.commentCount}',
                  style: const TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMediaThumbnails(BuildContext context) {
    if (alert.mediaFiles.isEmpty) return const SizedBox.shrink();
    
    final mediaToShow = alert.mediaFiles.take(3).toList();
    
    return SizedBox(
      height: 64,
      child: Row(
        children: [
          ...mediaToShow.asMap().entries.map((entry) {
            final index = entry.key;
            final media = entry.value;
            final isVideo = (media['type'] ?? 'image') == 'video';
            final thumbnailUrl = media['thumbnail_url'] ?? media['url'];
            
            return GestureDetector(
              onTap: () async {
                await UiFeedback.click();
                if (context.mounted) {
                  context.go('/alert/${alert.id}?openImage=$index');
                }
              },
              child: Container(
                width: 64,
                height: 64,
                margin: EdgeInsets.only(right: index < mediaToShow.length - 1 ? 4 : 0),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.brandPrimary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(3.5),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      if (thumbnailUrl != null)
                        Image.network(
                          thumbnailUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: AppColors.darkSurface,
                              child: Icon(
                                isVideo ? Icons.videocam : Icons.photo,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                          loadingBuilder: (context, child, loadingProgress) {
                            if (loadingProgress == null) return child;
                            return Container(
                              color: AppColors.darkSurface,
                              child: Icon(
                                isVideo ? Icons.videocam : Icons.photo,
                                size: 32,
                                color: AppColors.textTertiary,
                              ),
                            );
                          },
                        )
                      else
                        Container(
                          color: AppColors.darkSurface,
                          child: Icon(
                            isVideo ? Icons.videocam : Icons.photo,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                        ),
                      if (isVideo)
                        Positioned(
                          bottom: 1,
                          right: 1,
                          child: Container(
                            padding: const EdgeInsets.all(1),
                            decoration: BoxDecoration(
                              color: Colors.black.withOpacity(0.6),
                              borderRadius: BorderRadius.circular(2),
                            ),
                            child: const Icon(
                              Icons.play_arrow,
                              size: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            );
          }),
          if (alert.mediaFiles.length > 3)
            GestureDetector(
              onTap: () async {
                await UiFeedback.click();
                if (context.mounted) {
                  context.go('/alert/${alert.id}?openImage=0');
                }
              },
              child: Container(
                width: 64,
                height: 64,
                margin: const EdgeInsets.only(left: 4),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: AppColors.brandPrimary.withOpacity(0.3),
                    width: 0.5,
                  ),
                ),
                child: Center(
                  child: Text(
                    '+${alert.mediaFiles.length - 3}',
                    style: const TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 8,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  String? _getMufonClassificationLabel(AppLocalizations l10n) {
    if (alert.source != 'mufon') return null;
    final c = alert.enrichment?['classification']?.toString().toLowerCase().trim() 
        ?? alert.enrichment?['ufo_type']?.toString().toLowerCase().trim();
    if (c == null || c.isEmpty) return null;
    switch (c) {
      case 'sphere':
        return l10n.ufoTypeSphere;
      case 'triangle':
        return l10n.ufoTypeTriangle;
      case 'disk':
      case 'disc':
        return l10n.ufoTypeDisk;
      case 'light':
        return l10n.ufoTypeLight;
      case 'fireball':
        return l10n.ufoTypeFireball;
      case 'cylinder':
        return l10n.ufoTypeCylinder;
      case 'cigar':
        return l10n.ufoTypeCigar;
      case 'rectangle':
      case 'box':
        return l10n.ufoTypeRectangle;
      case 'formation':
      case 'fleet':
        return l10n.ufoTypeFormation;
      case 'boomerang':
        return l10n.ufoTypeBoomerang;
      case 'diamond':
        return l10n.ufoTypeDiamond;
      case 'oval':
        return l10n.ufoTypeOval;
      case 'cone':
        return l10n.ufoTypeCone;
      case 'cross':
        return l10n.ufoTypeCross;
      case 'dumbbell':
        return l10n.ufoTypeDumbbell;
      case 'teardrop':
        return l10n.ufoTypeTeardrop;
      case 'tic tac':
      case 'tic-tac':
      case 'tictac':
        return l10n.ufoTypeTicTac;
      case 'bullet':
        return l10n.ufoTypeBullet;
      case 'saturn':
      case 'saturn-like':
      case 'saturn like':
        return l10n.ufoTypeSaturn;
      case 'star-like':
      case 'star like':
      case 'starlike':
        return l10n.ufoTypeStarLike;
      case 'blimp':
        return l10n.ufoTypeBlimp;
      default:
        return l10n.ufoTypeUnknown;
    }
  }

  String _getLocationName(Alert alert) {
    if (alert.source == 'mufon') {
      final enrichment = alert.enrichment;
      if (enrichment != null && enrichment.containsKey('location_raw')) {
        final locationRaw = enrichment['location_raw']?.toString();
        if (locationRaw != null && locationRaw.isNotEmpty) {
          return locationRaw;
        }
      }
    }
    
    if (alert.locationName != null && 
        alert.locationName!.isNotEmpty && 
        alert.locationName != 'Unknown Location') {
      return alert.locationName!;
    }
    return '';
  }

  String _getMufonReportDate(BuildContext context, Alert alert) {
    final enrichment = alert.enrichment;
    if (enrichment != null) {
      // Try report_date first (new format)
      if (enrichment.containsKey('report_date')) {
        final reportDate = enrichment['report_date']?.toString();
        if (reportDate != null && reportDate.isNotEmpty) {
          return reportDate;
        }
      }
      // Fallback to database_when (old format)
      if (enrichment.containsKey('database_when')) {
        final reportDate = enrichment['database_when']?.toString();
        if (reportDate != null && reportDate.isNotEmpty) {
          return reportDate;
        }
      }
      if (enrichment.containsKey('mufon_case_number')) {
        final caseNumber = enrichment['mufon_case_number']?.toString();
        if (caseNumber != null && caseNumber.isNotEmpty) {
          return 'Case #$caseNumber';
        }
      }
    }
    // Use createdAt as fallback but format as date only for MUFON consistency
    final dateOnly = alert.createdAt.toLocal();
    return '${dateOnly.year}-${dateOnly.month.toString().padLeft(2, '0')}-${dateOnly.day.toString().padLeft(2, '0')}';
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

    // T+ format - universal aerospace/military time elapsed notation
    if (difference.inDays > 0) {
      final days = difference.inDays;
      final hours = difference.inHours.remainder(24);
      return 'T+${days}d${hours}h';
    } else if (difference.inHours > 0) {
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      return 'T+${hours}h${minutes}m';
    } else if (difference.inMinutes > 0) {
      final minutes = difference.inMinutes;
      return 'T+${minutes}m';
    } else {
      return 'T+0m';
    }
  }

  String _formatActualDateTime(BuildContext context, DateTime dateTime, {bool? use24Hour}) {
    final localDateTime = dateTime.toLocal();
    final now = DateTime.now();
    final is24Hour = use24Hour ?? true; // Default to 24-hour if not specified

    // ISO format (YYYY-MM-DD) for international consistency
    final isoDate = "${localDateTime.year.toString().padLeft(4, '0')}-"
        "${localDateTime.month.toString().padLeft(2, '0')}-"
        "${localDateTime.day.toString().padLeft(2, '0')}";

    // Check if it's today
    final isToday = localDateTime.day == now.day &&
        localDateTime.month == now.month &&
        localDateTime.year == now.year;

    if (isToday) {
      // Show date and time for today's sightings
      String formatTime(DateTime dt) {
        if (is24Hour) {
          return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
        } else {
          final hour12 = dt.hour > 12 ? dt.hour - 12 : (dt.hour == 0 ? 12 : dt.hour);
          final ampm = dt.hour >= 12 ? 'PM' : 'AM';
          return "$hour12:${dt.minute.toString().padLeft(2, '0')} $ampm";
        }
      }

      return "$isoDate • ${formatTime(localDateTime)}";
    } else {
      // Show just the ISO date for older sightings
      return isoDate;
    }
  }
}

