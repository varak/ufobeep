import 'package:flutter/material.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const UFOBeepApp());
}

class UFOBeepApp extends StatelessWidget {
  const UFOBeepApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UFOBeep',
      theme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      debugShowCheckedModeBanner: false,
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('UFOBeep'),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              '👽',
              style: TextStyle(fontSize: 64),
            ),
            SizedBox(height: 16),
            Text(
              'UFOBeep',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Real-time sighting alerts',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
