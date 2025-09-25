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
    this.userLat,
    this.userLon,
    this.alertLat,
    this.alertLon,
    this.alertId,
    this.alertName,
    this.calledFromAlert = false,
  });

  final double? userLat;
  final double? userLon;
  final double? alertLat;
  final double? alertLon;
  final String? alertId;
  final String? alertName;
  final bool calledFromAlert;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alertsAsync = ref.watch(alertsListProvider);

    return NightSkyBackground(
      child: Scaffold(
      backgroundColor: Colors.transparent,
      appBar: AppBar(
        title: Text(
          calledFromAlert && alertName != null 
              ? 'Map - ${Uri.decodeComponent(alertName!)}' 
              : 'Live Sightings Map',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: calledFromAlert 
            ? IconButton(
                icon: const Icon(Icons.arrow_back, color: Colors.white),
                onPressed: () {
                  if (alertId != null) {
                    context.go('/alert/$alertId');
                  } else {
                    context.go('/alerts');
                  }
                },
              )
            : null,
      ),
      body: alertsAsync.when(
        data: (alertsData) {
          final alerts = alertsData.alerts;
          return Column(
            children: [
              // Map takes full screen
              Expanded(
                child: MapWidget(
                  alerts: alerts,
                  zoom: 4.0, // Wide view to see geographic context
                  onAlertTap: (alert) {
                    // Navigate to alert detail when tapped
                    context.go('/alert/${alert.id}');
                  },
                ),
              ),
              
              // Bottom info bar
              Padding(
                padding: const EdgeInsets.all(16),
                child: GlassCard(
                  child: Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        color: AppColors.brandPrimary,
                        size: 16,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${alerts.where((alert) => DateTime.now().difference(alert.createdAt).inDays <= 7).length} recent sightings',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 14,
                        ),
                      ),
                      const Spacer(),
                      const Text(
                        'Tap markers for details',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
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