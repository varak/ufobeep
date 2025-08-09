import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.alertId});

  final String alertId;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alert Chat'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat,
              size: 80,
              color: AppColors.brandPrimary,
            ),
            SizedBox(height: 24),
            Text(
              'Chat Screen',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 12),
            Text(
              'Matrix chat integration\ncoming soon',
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