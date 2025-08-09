// Basic Flutter widget test for UFOBeep app

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:ufobeep/main.dart';

void main() {
  testWidgets('UFOBeep app loads without error', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: UFOBeepApp(),
      ),
    );

    // Verify that the app loads without throwing errors
    // This is a basic smoke test
    await tester.pump();
    
    // App should render successfully
    expect(tester.takeException(), isNull);
  });
}
