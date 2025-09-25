import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_widget.dart';
import '../../widgets/glass_card.dart';

class MapScreen extends ConsumerWidget {
  const MapScreen({
    super.key,
    this.targetAlertId,
    this.alertId,
  });

  final String? targetAlertId;
  final String? alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsListProvider);

    return NightSkyBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          targetAlertId != null
              ? 'Sighting Location'
              : 'Live Sightings Map',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: (alertId ?? targetAlertId) != null
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  final backAlertId = alertId ?? targetAlertId;
                  context.go('/alert/$backAlertId?scrollTo=direction');
                },
              )
            : null,
      ),
      body: alertsAsync.when(
        data: (alertsData) {
          final alerts = alertsData.alerts;

          // Find the target alert if specified
          Alert? targetAlert;
          if (targetAlertId != null) {
            try {
              targetAlert = alerts.firstWhere((alert) => alert.id == targetAlertId);
            } catch (e) {
              // Target alert not found in current data
            }
          }

          return Column(
            children: [
              // Map takes full screen
              Expanded(
                child: MapWidget(
                  alerts: alerts,
                  targetAlert: targetAlert,
                  zoom: 5.5, // Match web zoom for better context
                  onAlertTap: (alert) {
                    // Navigate to alert detail when tapped
                    context.go('/alert/${alert.id}');
                  },
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
        error: (error, stack) => Center(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: GlassCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: AppColors.semanticError,
                    size: 64,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Failed to load map',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(alertsListProvider),
                    child: const Text('Try Again'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
      ),
    );
  }
}