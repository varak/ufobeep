import 'package:sentry_flutter/sentry_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../config/environment.dart';

// Provider for the Sentry service
final sentryServiceProvider = Provider<SentryService>((ref) {
  return SentryService();
});

class SentryService {
  static bool _initialized = false;

  static Future<void> initialize() async {
    if (_initialized) return;

    final config = EnvironmentConfig.instance;
    final sentryDsn = config.sentryDsn;

    if (sentryDsn == null || sentryDsn.isEmpty) {
      if (kDebugMode) {
        print('Sentry DSN not configured, skipping initialization');
      }
      return;
    }

    await SentryFlutter.init(
      (options) {
        options.dsn = sentryDsn;
        options.environment = config.environment.name;
        options.release = config.appVersion;
        options.tracesSampleRate = config.isProduction ? 0.1 : 1.0;
        options.attachStacktrace = true;
        options.enableAutoSessionTracking = true;
        options.beforeSend = (event, hint) {
          // Don't send events in debug mode
          if (kDebugMode) return null;
          return event;
        };
      },
    );

    _initialized = true;

    if (kDebugMode) {
      print('Sentry initialized successfully');
    }
  }

  // Capture exceptions
  static Future<void> captureException(
    dynamic exception, {
    dynamic stackTrace,
    Map<String, dynamic>? extra,
    String? tag,
  }) async {
    if (!_initialized) return;

    await Sentry.captureException(
      exception,
      stackTrace: stackTrace,
      withScope: (scope) {
        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setExtra(entry.key, entry.value);
          }
        }
        if (tag != null) {
          scope.setTag('custom', tag);
        }
      },
    );
  }

  // Capture messages
  static Future<void> captureMessage(
    String message, {
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? extra,
  }) async {
    if (!_initialized) return;

    await Sentry.captureMessage(
      message,
      level: level,
      withScope: (scope) {
        if (extra != null) {
          for (final entry in extra.entries) {
            scope.setExtra(entry.key, entry.value);
          }
        }
      },
    );
  }

  // Set user context
  static Future<void> setUser({
    String? id,
    String? email,
    String? username,
    Map<String, dynamic>? extras,
  }) async {
    if (!_initialized) return;

    await Sentry.configureScope((scope) {
      scope.setUser(SentryUser(
        id: id,
        email: email,
        username: username,
        extras: extras,
      ));
    });
  }

  // Add breadcrumb
  static void addBreadcrumb({
    required String message,
    String? category,
    SentryLevel level = SentryLevel.info,
    Map<String, dynamic>? data,
  }) {
    if (!_initialized) return;

    Sentry.addBreadcrumb(Breadcrumb(
      message: message,
      category: category,
      level: level,
      data: data,
    ));
  }

  // Performance monitoring
  static ISentrySpan startTransaction({
    required String name,
    required String operation,
    Map<String, dynamic>? data,
  }) {
    return Sentry.startTransaction(
      name,
      operation,
      bindToScope: true,
    );
  }
}