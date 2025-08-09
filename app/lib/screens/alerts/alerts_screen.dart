import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/alerts_provider.dart';
import '../home/home_screen.dart';

class AlertsScreen extends ConsumerWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // This is essentially the same as HomeScreen but without bottom nav
    // Used for standalone alerts view
    final alerts = ref.watch(alertsListProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('All Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Show filter dialog
            },
          ),
        ],
      ),
      body: alerts.isEmpty
          ? const Center(
              child: Text('No alerts available'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: alerts.length,
              itemBuilder: (context, index) {
                final alert = alerts[index];
                return HomeScreen(); // Reuse the alert card from home screen
              },
            ),
    );
  }
}