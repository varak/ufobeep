import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class BeepScreen extends StatelessWidget {
  const BeepScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Report Sighting'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.add_a_photo,
              size: 80,
              color: AppColors.brandPrimary,
            ),
            SizedBox(height: 24),
            Text(
              'Beep Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Camera & Upload functionality\ncoming soon',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}