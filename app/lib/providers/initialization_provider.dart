import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../services/initialization_service.dart';

// Initialization service provider
final initializationServiceProvider = Provider<InitializationService>((ref) {
  return InitializationService();
});

// Initialization state provider
class InitializationNotifier extends StateNotifier<InitializationResult?> {
  InitializationNotifier(this._service) : super(null);

  final InitializationService _service;

  Future<void> initialize() async {
    final result = await _service.initialize();
    state = result;
  }

  void reset() {
    state = null;
  }
}

final initializationProvider = StateNotifierProvider<InitializationNotifier, InitializationResult?>((ref) {
  final service = ref.watch(initializationServiceProvider);
  return InitializationNotifier(service);
});

// Stream providers for real-time updates
final initializationStepProvider = StreamProvider<InitializationStep>((ref) {
  final service = ref.watch(initializationServiceProvider);
  return service.stepStream;
});

final initializationProgressProvider = StreamProvider<double>((ref) {
  final service = ref.watch(initializationServiceProvider);
  return service.progressStream;
});

final initializationMessageProvider = StreamProvider<String>((ref) {
  final service = ref.watch(initializationServiceProvider);
  return service.messageStream;
});

// Convenience providers
final isInitializedProvider = Provider<bool>((ref) {
  final result = ref.watch(initializationProvider);
  return result?.success == true && result?.lastStep == InitializationStep.complete;
});

final initializationErrorProvider = Provider<String?>((ref) {
  final result = ref.watch(initializationProvider);
  return result?.error;
});

final hasInitializationErrorProvider = Provider<bool>((ref) {
  final result = ref.watch(initializationProvider);
  return result?.success == false;
});