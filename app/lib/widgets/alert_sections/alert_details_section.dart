import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../glass_card.dart';
import '../../l10n/app_localizations.dart';
import '../../utils/unit_conversion.dart';
import '../../services/permission_service.dart';

class AlertDetailsSection extends StatelessWidget {
  const AlertDetailsSection({
    super.key,
    required this.alert,
    this.showDescription = true,
    this.showLocation = true,
    this.units = 'metric',
  });

  final Alert alert;
  final bool showDescription;
  final bool showLocation;
  final String units;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Section header
          Row(
            children: [
              const Icon(
                Icons.info_outline,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                alert.source == 'mufon' && alert.enrichment?['mufon_case_number'] != null
                    ? AppLocalizations.of(context).mufonCaseTitle(alert.enrichment!['mufon_case_number'])
                    : AppLocalizations.of(context).detailsTitle,
                style: const TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Description (if available and enabled)
          if (showDescription && alert.description != null && alert.description!.isNotEmpty) ...[
            Text(
              alert.description!,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 18,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
          ],
          
          // MUFON-specific metadata
          if (alert.source == 'mufon') ...[
            // MUFON case number now shown in header instead
            
            // Sighting date
            if (alert.enrichment?['reported_when'] != null)
              _buildDetailRow(
                Icons.event,
                AppLocalizations.of(context).sightingDate,
                alert.enrichment!['reported_when'],
              ),
            
            // Date entered into MUFON database
            if (alert.enrichment?['database_when'] != null)
              _buildDetailRow(
                Icons.storage,
                AppLocalizations.of(context).mufonDatabaseEntryDate,
                alert.enrichment!['database_when'],
              ),
            
            // Location - only show for MUFON if we have a proper city/state name (not unknown)
            if (showLocation && 
                alert.locationName != null && 
                alert.locationName!.isNotEmpty && 
                alert.locationName != 'Unknown Location') ...[
              _buildDetailRow(
                Icons.location_on,
                AppLocalizations.of(context).locationLabel,
                alert.locationName!,
              ),
              // Always show distance if we have coordinates
              if (alert.latitude != 0.0 && alert.longitude != 0.0)
                _buildDistanceRow(context),
            ],
            
          ],
          
          // UFOBeep-specific metadata (non-MUFON)
          if (alert.source != 'mufon') ...[
            // Time info
            _buildDetailRow(
              Icons.access_time,
              AppLocalizations.of(context).timeLabel,
              _formatDateTime(context, alert.createdAt),
              subtitle: _formatFullDateTime(alert.createdAt),
            ),
            
            // Reporter info
            if (alert.reporterUsername != null) 
              _buildDetailRow(
                Icons.person,
                AppLocalizations.of(context).reportedByLabel,
                alert.reporterUsername!,
                subtitle: null,
              ),
            
            // Witness count (if more than 1)
            if (alert.witnessCount > 1)
              _buildWitnessRow(context),
            
            // Location info (if enabled) - only for non-MUFON reports
            if (showLocation) ...[
              _buildDetailRow(
                Icons.location_on,
                AppLocalizations.of(context).locationLabel,
                '${alert.locationName ?? AppLocalizations.of(context).unknownLocation}',
                subtitle: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
              ),
              // Always show dynamic distance calculation if we have coordinates
              if (alert.latitude != 0.0 && alert.longitude != 0.0)
                _buildDistanceRow(context),
            ],
            
          ],
          // UFO type classification removed for MUFON reports
        ],
      ),
    );
  }


  Widget _buildDistanceRow(BuildContext context) {
    return FutureBuilder<Position?>(
      future: permissionService.getCurrentLocation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final userLocation = snapshot.data!;
        final distance = _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          alert.latitude,
          alert.longitude,
        );

        return _buildDetailRow(
          Icons.straighten,
          AppLocalizations.of(context).distanceLabel,
          UnitConversion.formatDistance(distance * 1000, units),
        );
      },
    );
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
              math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  Widget _buildWitnessRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.visibility, size: 20, color: AppColors.semanticSuccess),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '${AppLocalizations.of(context).witnessesLabel}: ',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.semanticSuccess.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(
                            Icons.visibility,
                            size: 16,
                            color: AppColors.semanticSuccess,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${alert.witnessCount}',
                            style: const TextStyle(
                              color: AppColors.semanticSuccess,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 2),
                Text(
                  AppLocalizations.of(context).witnessesCountMessage(alert.witnessCount),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: AppColors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '$label:',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                      ),
                    ),
                  ],
                ),
                if (subtitle != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
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

  String _formatDateTime(BuildContext context, DateTime dateTime) {
    final l10n = AppLocalizations.of(context);
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

  String _formatFullDateTime(DateTime dateTime) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    
    // Convert to local timezone first
    final localDateTime = dateTime.toLocal();
    
    final month = months[localDateTime.month - 1];
    final day = localDateTime.day;
    final year = localDateTime.year;
    final hour = localDateTime.hour == 0 ? 12 : (localDateTime.hour > 12 ? localDateTime.hour - 12 : localDateTime.hour);
    final minute = localDateTime.minute.toString().padLeft(2, '0');
    final amPm = localDateTime.hour >= 12 ? 'PM' : 'AM';
    
    return '$month $day, $year at $hour:$minute $amPm';
  }

  String _getMufonLocationName(BuildContext context, Alert alert) {
    // For MUFON alerts, use the locationName field which contains the city, state format
    if (alert.locationName != null && alert.locationName!.isNotEmpty && alert.locationName != 'Unknown Location') {
      return alert.locationName!;
    }
    
    // For MUFON reports, never show lat/lng coordinates - just return unknown
    return AppLocalizations.of(context).locationUnknown;
  }



  String _classificationLabel(AppLocalizations l10n) {
    final c = alert.enrichment?['classification']?.toString().toLowerCase().trim() 
        ?? alert.enrichment?['ufo_type']?.toString().toLowerCase().trim();
    
    // Return null for empty/null classifications to hide the section
    if (c == null || c.isEmpty) {
      return '';
    }
    
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
}
