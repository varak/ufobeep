import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';
import '../utils/unit_conversion.dart';
import '../providers/user_preferences_provider.dart';
import '../l10n/app_localizations.dart';
import '../services/ui_feedback.dart';
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
          _buildHeaderRow(context, l10n, units),
          const SizedBox(height: 12),
          if (alert.mediaFiles.isNotEmpty) ...[
            _buildMediaThumbnails(context),
            const SizedBox(height: 12),
          ],
          if (alert.description?.isNotEmpty == true) ...[
            _buildDescription(),
            const SizedBox(height: 12),
          ],
          _buildFooterRow(l10n),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(BuildContext context, AppLocalizations l10n, String units) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildUfoIcon(),
        const SizedBox(width: 12),
        Expanded(
          child: _buildTitleAndMetadata(context, l10n, units),
        ),
        _buildTimestampAndDistance(context, units),
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
          alert.title == 'UFO Sighting' ? l10n.ufoSighting : alert.title,
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
        const SizedBox(height: 4),
        _buildVerificationBadge(l10n),
      ],
    );
  }

  Widget _buildVerificationBadge(AppLocalizations l10n) {
    if (alert.isVerified && alert.source != 'mufon') {
      return Container(
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
      );
    }
    return const SizedBox(height: 16);
  }

  Widget _buildTimestampAndDistance(BuildContext context, String units) {
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
        Text(
          alert.source == 'mufon' 
              ? _getMufonReportDate(context, alert) 
              : _formatDateTime(context, alert.createdAt),
          style: const TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildDescription() {
    return Text(
      alert.description!,
      style: const TextStyle(
        color: AppColors.textSecondary,
        fontSize: 18,
        height: 1.5,
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
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
    final hasDescription = alert.description?.trim().isNotEmpty ?? false;
    
    if (!hasMedia && !hasDescription) {
      return _buildBadge(l10n.beepOnly, Icons.location_on, AppColors.textTertiary);
    }
    
    if (!hasMedia && hasDescription) {
      return _buildBadge('Report Only', Icons.visibility, AppColors.textTertiary);
    }
    
    if (hasMedia && !hasDescription) {
      final isVideo = alert.mediaFiles.first['type'] == 'video';
      return _buildBadge(
        isVideo ? l10n.videoOnly : l10n.imageOnly, 
        isVideo ? Icons.videocam : Icons.photo, 
        AppColors.brandPrimary
      );
    }
    
    if (hasMedia) {
      final isVideo = alert.mediaFiles.first['type'] == 'video';
      return _buildBadge(
        '${alert.mediaFiles.length}', 
        isVideo ? Icons.videocam : Icons.photo, 
        AppColors.brandPrimary
      );
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
    return _formatDateTime(context, alert.createdAt);
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

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

// Keep CompactAlertCard for backward compatibility
class CompactAlertCard extends ConsumerWidget {
  const CompactAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final Alert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userPrefs = ref.watch(userPreferencesProvider);
    final units = userPrefs?.units ?? 'metric';
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.darkBorder.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () async {
          await UiFeedback.click();
          if (context.mounted) {
            context.go('/alert/${alert.id}');
          }
        },
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Text(
                  '🛸',
                  style: TextStyle(fontSize: 14),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (alert.distance != null && alert.distance! > 0) ...[
                          Text(
                            UnitConversion.formatDistance(alert.distance! * 1000, units),
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        Text(
                          alert.source == 'mufon'
                              ? _getMufonReportDate(context, alert)
                              : _formatDateTime(context, alert.createdAt),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        if (alert.isVerified && alert.source != 'mufon') ...[
                          const SizedBox(width: 4),
                          const Icon(
                            Icons.verified,
                            color: AppColors.brandPrimary,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context)!;
    final now = DateTime.now();
    final localDateTime = dateTime.toLocal();
    final difference = now.difference(localDateTime);

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

  String _getMufonReportDate(BuildContext context, Alert alert) {
    final enrichment = alert.enrichment;
    if (enrichment != null) {
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
    return _formatDateTime(context, alert.createdAt);
  }
}