import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../widgets/map_widget.dart';

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

    return Scaffold(
      appBar: AppBar(
        title: Text(calledFromAlert && alertName != null 
            ? 'Map - ${Uri.decodeComponent(alertName!)}' 
            : 'Live Sightings Map'),
        backgroundColor: AppColors.darkSurface,
        leading: calledFromAlert 
            ? IconButton(
                icon: const Icon(Icons.arrow_back),
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
      backgroundColor: AppColors.darkBackground,
      body: alertsAsync.when(
        data: (alerts) {
          return Column(
            children: [
              // Map takes full screen
              Expanded(
                child: MapWidget(
                  alerts: alerts,
                  onAlertTap: (alert) {
                    // Navigate to alert detail when tapped
                    context.go('/alert/${alert.id}');
                  },
                ),
              ),
              
              // Bottom info bar
              Container(
                padding: const EdgeInsets.all(16),
                decoration: const BoxDecoration(
                  color: AppColors.darkSurface,
                  border: Border(
                    top: BorderSide(color: AppColors.darkBorder),
                  ),
                ),
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
                        color: AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'Tap markers for details',
                      style: TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.brandPrimary),
        ),
        error: (error, stack) => Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.error_outline,
                color: AppColors.semanticError,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Failed to load map',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                error.toString(),
                style: const TextStyle(color: AppColors.textSecondary),
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
    );
  }
}