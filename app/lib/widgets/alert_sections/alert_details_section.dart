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
import '../../utils/short_url_utils.dart';

class AlertDetailsSection extends StatelessWidget {
  const AlertDetailsSection({
    super.key,
    required this.alert,
    this.showDescription = true,
    this.showLocation = true,
    this.units = 'metric',
    this.use24HourTime = true,
    this.onShareTap,
  });

  final Alert alert;
  final bool showDescription;
  final bool showLocation;
  final String units;
  final bool use24HourTime;
  final VoidCallback? onShareTap;

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
                    ? AppLocalizations.of(context)!.mufonCaseTitle(alert.enrichment!['mufon_case_number'])
                    : AppLocalizations.of(context)!.detailsTitle,
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
            // Debug info - let's see what data we have
            // print('DEBUG MUFON Alert: source=${alert.source}, occurredAt=${alert.occurredAt}, enrichment=${alert.enrichment}');

            // Event date (when sighting actually occurred)
            if (alert.enrichment?['sighting_datetime'] != null)
              _buildDetailRow(
                Icons.event,
                AppLocalizations.of(context)!.eventTime,
                _parseMufonSightingDate(alert.enrichment!['sighting_datetime']),
              ),

            // Date reported to MUFON database
            if (alert.enrichment?['report_date'] != null)
              _buildDetailRow(
                Icons.storage,
                _isMufonAlert(alert) ? 'MUFON Reporting Date' : AppLocalizations.of(context)!.reportedTime,
                _parseAndFormatDateISO(alert.enrichment!['report_date']) ?? alert.enrichment!['report_date'],
              ),

            // Always show UFOBeep import date for MUFON reports
            _buildDetailRow(
              Icons.schedule,
              AppLocalizations.of(context)!.addedToUfobeep,
              _formatDateOnly(alert.createdAt), // Date only, no time
            ),

            // Always show location for MUFON reports
            if (showLocation) ...[
              _buildDetailRow(
                Icons.location_on,
                AppLocalizations.of(context)!.locationLabel,
                _getMufonLocationName(context, alert),
                subtitle: alert.latitude != 0.0 && alert.longitude != 0.0
                    ? '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}'
                    : null,
              ),
              // Always show distance if we have coordinates
              if (alert.latitude != 0.0 && alert.longitude != 0.0)
                _buildDistanceRow(context),
            ],

            // Share URL section for MUFON reports
            const SizedBox(height: 12),
            _buildShareUrlRow(context, alert),

          ],
          
          // UFOBeep-specific metadata (non-MUFON)
          if (alert.source != 'mufon') ...[
            // Time info
            _buildDetailRow(
              Icons.access_time,
              AppLocalizations.of(context)!.timeLabel,
              _formatFullDateTime(alert.createdAt, use24Hour: use24HourTime),
              subtitle: _formatDateTime(context, alert.createdAt),
            ),

            // Reporter info - same condition as alerts list
            if (alert.username != null && alert.username!.isNotEmpty && alert.source != 'mufon')
              _buildDetailRow(
                Icons.person,
                AppLocalizations.of(context)!.reportedByLabel,
                alert.username!,
                subtitle: null,
              ),
            
            // Witness count (if more than 1)
            if (alert.witnessCount > 1)
              _buildWitnessRow(context),
            
            // Location info (if enabled) - only for non-MUFON reports
            if (showLocation) ...[
              _buildDetailRow(
                Icons.location_on,
                AppLocalizations.of(context)!.locationLabel,
                '${_getLocationDisplayName(alert, context)}',
                subtitle: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
              ),
              // Always show dynamic distance calculation if we have coordinates
              if (alert.latitude != 0.0 && alert.longitude != 0.0)
                _buildDistanceRow(context),
            ],

            // Share URL section for non-MUFON reports (add spacing if location was shown)
            if (showLocation) const SizedBox(height: 12),
            _buildShareUrlRow(context, alert),

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
          AppLocalizations.of(context)!.distanceLabel,
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
                      '${AppLocalizations.of(context)!.witnessesLabel}: ',
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
                  AppLocalizations.of(context)!.witnessesCountMessage(alert.witnessCount),
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
                      label.endsWith(':') ? label : '$label:',
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

  String _formatFullDateTime(DateTime dateTime, {bool use24Hour = true}) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                   'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];

    // Convert to local timezone first
    final localDateTime = dateTime.toLocal();

    final month = months[localDateTime.month - 1];
    final day = localDateTime.day;
    final year = localDateTime.year;
    final minute = localDateTime.minute.toString().padLeft(2, '0');

    if (use24Hour) {
      // 24-hour format (e.g., "Sep 19, 2025 at 14:30")
      final hour = localDateTime.hour.toString().padLeft(2, '0');
      return '$month $day, $year at $hour:$minute';
    } else {
      // 12-hour format with AM/PM (e.g., "Sep 19, 2025 at 2:30 PM")
      final hour = localDateTime.hour == 0 ? 12 : (localDateTime.hour > 12 ? localDateTime.hour - 12 : localDateTime.hour);
      final amPm = localDateTime.hour >= 12 ? 'PM' : 'AM';
      return '$month $day, $year at $hour:$minute $amPm';
    }
  }

  String _formatDateISO(DateTime dateTime) {
    final now = DateTime.now();
    final date = dateTime.toLocal();

    // ISO format (YYYY-MM-DD) for international consistency
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final isoDate = '$year-$month-$day';

    // Check if it's today
    final isToday = date.year == now.year && date.month == now.month && date.day == now.day;

    if (isToday) {
      // Show date and time for today's sightings
      final hour = date.hour.toString().padLeft(2, '0');
      final minute = date.minute.toString().padLeft(2, '0');
      return '$isoDate • $hour:$minute';
    } else {
      // Show just the ISO date for older sightings
      return isoDate;
    }
  }

  String _formatDateOnly(DateTime dateTime) {
    final date = dateTime.toLocal();
    // Always return just the date, never include time
    final year = date.year.toString();
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    return '$year-$month-$day';
  }

  bool _isMufonAlert(Alert alert) {
    return alert.source == 'mufon' || alert.username == 'MUFON_Database';
  }

  String? _parseAndFormatDateISO(String? dateString) {
    if (dateString == null || dateString.isEmpty) return null;
    try {
      final dateTime = DateTime.parse(dateString);
      return _formatDateISO(dateTime);
    } catch (e) {
      return dateString; // Return original if parsing fails
    }
  }

  String _parseMufonSightingDate(String dateString) {
    // MUFON format: "1979-07-21\n12:00AM" or "1979-07-21<br>12:00AM"
    try {
      // Extract just the date part before newline or <br>
      String datePart = dateString.split('\n')[0].split('<br>')[0].trim();

      // Parse and format to ISO
      final dateTime = DateTime.parse(datePart);
      return _formatDateISO(dateTime);
    } catch (e) {
      // If parsing fails, return the original string cleaned up
      return dateString.replaceAll('\n', ' ').replaceAll('<br>', ' ');
    }
  }

  String _getMufonLocationName(BuildContext context, Alert alert) {
    // For MUFON alerts, use enrichment data for better location names
    if (alert.enrichment != null) {
      // Try geocoding display name first - this gives the full address
      final displayName = alert.enrichment!['geocoding']?['display_name'];
      if (displayName != null && displayName.toString().isNotEmpty) {
        return displayName.toString();
      }

      // Try formatted_address field
      final formattedAddress = alert.enrichment!['geocoding']?['formatted_address'];
      if (formattedAddress != null && formattedAddress.toString().isNotEmpty) {
        return formattedAddress.toString();
      }

      // Try location_name field
      final locationName = alert.enrichment!['geocoding']?['location_name'];
      if (locationName != null && locationName.toString().isNotEmpty) {
        return locationName.toString();
      }

      // Try geocoding location field - shorter format like "Manteca, CA"
      final geocodingLocation = alert.enrichment!['geocoding']?['location'];
      if (geocodingLocation != null && geocodingLocation.toString().isNotEmpty) {
        return geocodingLocation.toString();
      }

      // Try location_raw field
      final locationRaw = alert.enrichment!['location_raw'];
      if (locationRaw != null && locationRaw.toString().isNotEmpty) {
        return locationRaw.toString();
      }
    }

    // Fall back to the basic locationName field
    if (alert.locationName != null && alert.locationName!.isNotEmpty && alert.locationName != 'Unknown Location') {
      return alert.locationName!;
    }

    // Last resort - return unknown location
    return AppLocalizations.of(context)!.locationUnknown;
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

  Widget _buildShareUrlRow(BuildContext context, Alert alert) {
    final locale = Localizations.localeOf(context).languageCode;
    final shareUrl = getShortAlertUrl(alert.shortUrl, locale: locale);
    final shareLink = 'ufobeep.com$shareUrl';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.link, size: 20, color: AppColors.brandPrimary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  AppLocalizations.of(context)!.shareLink,
                  style: const TextStyle(
                    color: AppColors.textTertiary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 2),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        shareLink,
                        style: const TextStyle(
                          color: AppColors.brandPrimary,
                          fontSize: 14,
                          fontFamily: 'monospace',
                        ),
                      ),
                    ),
                    IconButton(
                      onPressed: onShareTap ?? () {
                        Clipboard.setData(ClipboardData(text: shareLink));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(AppLocalizations.of(context)!.linkCopied),
                            duration: const Duration(seconds: 2),
                            backgroundColor: AppColors.brandPrimary,
                          ),
                        );
                      },
                      icon: const Icon(
                        Icons.copy,
                        size: 16,
                        color: AppColors.textSecondary,
                      ),
                      style: IconButton.styleFrom(
                        minimumSize: const Size(32, 32),
                        padding: const EdgeInsets.all(4),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getLocationDisplayName(Alert alert, BuildContext context) {
    // First check geocoding enrichment data
    if (alert.enrichment != null) {
      final geocoding = alert.enrichment!['geocoding'];
      if (geocoding != null) {
        // Try formatted_address field
        final formattedAddress = geocoding['formatted_address'];
        if (formattedAddress != null && formattedAddress.toString().isNotEmpty) {
          return formattedAddress.toString();
        }

        // Try location_name field
        final locationName = geocoding['location_name'];
        if (locationName != null && locationName.toString().isNotEmpty) {
          return locationName.toString();
        }

        // Try display_name field
        final displayName = geocoding['display_name'];
        if (displayName != null && displayName.toString().isNotEmpty) {
          return displayName.toString();
        }
      }
    }

    // Fall back to basic locationName field
    if (alert.locationName != null && alert.locationName!.isNotEmpty && alert.locationName != 'Unknown Location') {
      return alert.locationName!;
    }

    // Last resort
    return AppLocalizations.of(context)!.unknownLocation;
  }
}
