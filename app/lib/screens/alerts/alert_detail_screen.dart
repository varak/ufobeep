import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';

class AlertDetailScreen extends ConsumerWidget {
  const AlertDetailScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final alert = ref.watch(alertByIdProvider(alertId));

    if (alert == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Alert')),
        body: const Center(
          child: Text('Alert not found'),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(alert.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.chat),
            onPressed: () {
              context.go('/alert/$alertId/chat');
            },
          ),
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () {
              // TODO: Share alert
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Media placeholder
            Container(
              width: double.infinity,
              height: 200,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.image, size: 48, color: AppColors.textTertiary),
                    SizedBox(height: 8),
                    Text('Media preview', style: TextStyle(color: AppColors.textTertiary)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Category & Verification
            Row(
              children: [
                Chip(
                  label: Text(alert.category.replaceAll('_', ' ').toUpperCase()),
                ),
                const SizedBox(width: 8),
                if (alert.isVerified)
                  Chip(
                    label: const Text('VERIFIED'),
                    backgroundColor: AppColors.brandPrimary.withOpacity(0.2),
                  ),
              ],
            ),
            const SizedBox(height: 16),

            // Title
            Text(
              alert.title,
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 12),

            // Description
            Text(
              alert.description,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),

            // Location & Time Info
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Details',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 12),
                    _DetailRow(
                      icon: Icons.access_time,
                      label: 'Time',
                      value: _formatDateTime(alert.createdAt),
                    ),
                    if (alert.distance != null)
                      _DetailRow(
                        icon: Icons.location_on,
                        label: 'Distance',
                        value: '${alert.distance!.toStringAsFixed(1)} km',
                      ),
                    if (alert.bearing != null)
                      _DetailRow(
                        icon: Icons.explore,
                        label: 'Direction',
                        value: '${alert.bearing!.toStringAsFixed(0)}°',
                      ),
                    _DetailRow(
                      icon: Icons.place,
                      label: 'Coordinates',
                      value: '${alert.latitude.toStringAsFixed(4)}, ${alert.longitude.toStringAsFixed(4)}',
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Action Buttons
            Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      context.go('/alert/$alertId/chat');
                    },
                    icon: const Icon(Icons.chat),
                    label: const Text('Join Chat'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      // TODO: Navigate to alert location
                    },
                    icon: const Icon(Icons.directions),
                    label: const Text('Navigate'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 20, color: AppColors.textTertiary),
          const SizedBox(width: 12),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.textTertiary,
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}