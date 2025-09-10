import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class DevMenuButton extends StatelessWidget {
  const DevMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    if (!kDebugMode) return const SizedBox.shrink(); // Only show in debug builds
    return PopupMenuButton<String>(
      icon: const Icon(Icons.build),
      onSelected: (value) {
        if (value == 'camera_diag') {
          context.push('/diag/camera');
        }
      },
      itemBuilder: (context) => const [
        PopupMenuItem(
          value: 'camera_diag',
          child: Text('Camera Diagnostic'),
        ),
      ],
    );
  }
}