import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../theme/app_theme.dart';
import '../../providers/user_preferences_provider.dart';
import '../../utils/unit_conversion.dart';
import '../../l10n/app_localizations.dart';
import '../glass_card.dart';

class AircraftExpandableCard extends StatefulWidget {
  final Map<String, dynamic> data;

  const AircraftExpandableCard({super.key, required this.data});

  @override
  State<AircraftExpandableCard> createState() => _AircraftExpandableCardState();
}

class _AircraftExpandableCardState extends State<AircraftExpandableCard> {
  bool isExpanded = false;

  @override
  Widget build(BuildContext context) {
    final aircraft = widget.data['aircraft'] as List? ?? [];
    final total = widget.data['total'] as int? ?? 0;
    final summary = widget.data['summary'] as String? ?? 'No aircraft detected';

    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text('✈️', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 8),
                Text(
                  AppLocalizations.of(context)!.aircraftTrackingTitle,
                  style: const TextStyle(color: AppColors.textPrimary, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.brandPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.brandPrimary),
                  ),
                  child: Text('$total', style: TextStyle(color: AppColors.brandPrimary, fontSize: 12, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(summary, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
            if (aircraft.isNotEmpty) ...[
              const SizedBox(height: 12),
              // If expanded and have many aircraft, use a constrained scrollable container
              if (isExpanded && aircraft.length > 5)
                Container(
                  constraints: BoxConstraints(
                    maxHeight: 300, // Limit height to prevent UI overflow
                  ),
                  child: ListView.builder(
                    shrinkWrap: true,
                    physics: const ClampingScrollPhysics(),
                    itemCount: aircraft.length,
                    itemBuilder: (context, index) {
                      final a = aircraft[index];
                      final callsign = a['callsign'] ?? '';
                      final distance = a['distance_km']?.toDouble() ?? 0.0;
                      final altitude = a['altitude_ft'];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 6),
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurface,
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: AppColors.darkBorder),
                        ),
                        child: Consumer(
                          builder: (context, ref, child) {
                            final userPrefs = ref.watch(userPreferencesProvider);
                            final units = userPrefs?.units ?? 'metric';
                            final aircraftName = callsign.isEmpty ? AppLocalizations.of(context)!.unknownAircraft : callsign;

                            return Row(
                              children: [
                                Text(
                                  aircraftName,
                                  style: const TextStyle(
                                    color: AppColors.textPrimary,
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    '${UnitConversion.formatDistance(distance * 1000, units)} away${altitude != null ? ' • ${altitude}ft' : ''}',
                                    style: const TextStyle(
                                      color: AppColors.textTertiary,
                                      fontSize: 12
                                    ),
                                    textAlign: TextAlign.right,
                                  ),
                                ),
                              ],
                            );
                          },
                        ),
                      );
                    },
                  ),
                )
              else
                // For collapsed view or small lists, use the original Column approach
                ...aircraft.take(isExpanded ? aircraft.length : 4).map((a) {
                  final callsign = a['callsign'] ?? '';
                  final distance = a['distance_km']?.toDouble() ?? 0.0;
                  final altitude = a['altitude_ft'];

                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurface,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.darkBorder),
                    ),
                    child: Consumer(
                      builder: (context, ref, child) {
                        final userPrefs = ref.watch(userPreferencesProvider);
                        final units = userPrefs?.units ?? 'metric';
                        final aircraftName = callsign.isEmpty ? AppLocalizations.of(context)!.unknownAircraft : callsign;

                        return Row(
                          children: [
                            Text(
                              aircraftName,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                '${UnitConversion.formatDistance(distance * 1000, units)} away${altitude != null ? ' • ${altitude}ft' : ''}',
                                style: const TextStyle(
                                  color: AppColors.textTertiary,
                                  fontSize: 12
                                ),
                                textAlign: TextAlign.right,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  );
                }),
              if (aircraft.length > 4)
                GestureDetector(
                  onTap: () {
                    setState(() {
                      isExpanded = !isExpanded;
                    });
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 8, bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isExpanded ? Icons.expand_less : Icons.expand_more,
                          color: AppColors.brandPrimary,
                          size: 16,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          isExpanded
                            ? AppLocalizations.of(context)!.showLess
                            : '+${aircraft.length - 4} ${AppLocalizations.of(context)!.moreAircraft}',
                          style: const TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}