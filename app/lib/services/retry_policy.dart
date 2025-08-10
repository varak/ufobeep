import 'dart:math';
import 'package:dio/dio.dart';

/// Retry policy configuration for API calls with exponential backoff
class RetryPolicy {
  final int maxRetries;
  final Duration baseDelay;
  final Duration maxDelay;
  final double backoffMultiplier;
  final double jitter;
  final List<int> retryableStatusCodes;
  final List<DioExceptionType> retryableExceptionTypes;

  const RetryPolicy({
    this.maxRetries = 3,
    this.baseDelay = const Duration(milliseconds: 500),
    this.maxDelay = const Duration(seconds: 30),
    this.backoffMultiplier = 2.0,
    this.jitter = 0.1,
    this.retryableStatusCodes = const [408, 429, 500, 502, 503, 504],
    this.retryableExceptionTypes = const [
      DioExceptionType.connectionTimeout,
      DioExceptionType.sendTimeout,
      DioExceptionType.receiveTimeout,
      DioExceptionType.connectionError,
    ],
  });

  /// Default retry policy for general API calls
  static const RetryPolicy defaultPolicy = RetryPolicy();

  /// Conservative retry policy for critical operations
  static const RetryPolicy conservativePolicy = RetryPolicy(
    maxRetries = 2,
    baseDelay = Duration(seconds: 1),
    backoffMultiplier = 1.5,
  );

  /// Aggressive retry policy for background sync operations
  static const RetryPolicy aggressivePolicy = RetryPolicy(
    maxRetries = 5,
    baseDelay = Duration(milliseconds: 250),
    maxDelay = Duration(minutes: 2),
    backoffMultiplier = 2.5,
  );

  /// Quick retry policy for real-time operations
  static const RetryPolicy quickPolicy = RetryPolicy(
    maxRetries = 2,
    baseDelay = Duration(milliseconds: 100),
    maxDelay = Duration(seconds: 5),
    backoffMultiplier = 1.8,
  );

  /// Calculate delay for a specific retry attempt
  Duration calculateDelay(int attemptNumber) {
    if (attemptNumber <= 0) return Duration.zero;
    
    // Calculate exponential backoff
    final delayMs = baseDelay.inMilliseconds * pow(backoffMultiplier, attemptNumber - 1);
    var delay = Duration(milliseconds: delayMs.round());
    
    // Apply maximum delay cap
    if (delay > maxDelay) {
      delay = maxDelay;
    }
    
    // Add jitter to prevent thundering herd
    if (jitter > 0) {
      final random = Random();
      final jitterMs = (delay.inMilliseconds * jitter * random.nextDouble()).round();
      delay = Duration(milliseconds: delay.inMilliseconds + jitterMs);
    }
    
    return delay;
  }

  /// Check if an error should be retried
  bool shouldRetry(DioException error, int attemptNumber) {
    if (attemptNumber >= maxRetries) return false;
    
    // Check for retryable status codes
    if (error.response?.statusCode != null) {
      return retryableStatusCodes.contains(error.response!.statusCode);
    }
    
    // Check for retryable exception types
    return retryableExceptionTypes.contains(error.type);
  }

  /// Create a copy with modified parameters
  RetryPolicy copyWith({
    int? maxRetries,
    Duration? baseDelay,
    Duration? maxDelay,
    double? backoffMultiplier,
    double? jitter,
    List<int>? retryableStatusCodes,
    List<DioExceptionType>? retryableExceptionTypes,
  }) {
    return RetryPolicy(
      maxRetries: maxRetries ?? this.maxRetries,
      baseDelay: baseDelay ?? this.baseDelay,
      maxDelay: maxDelay ?? this.maxDelay,
      backoffMultiplier: backoffMultiplier ?? this.backoffMultiplier,
      jitter: jitter ?? this.jitter,
      retryableStatusCodes: retryableStatusCodes ?? this.retryableStatusCodes,
      retryableExceptionTypes: retryableExceptionTypes ?? this.retryableExceptionTypes,
    );
  }
}

/// Retry interceptor for Dio HTTP client
class RetryInterceptor extends Interceptor {
  final RetryPolicy policy;
  final void Function(DioException error, int attemptNumber)? onRetry;

  RetryInterceptor({
    this.policy = RetryPolicy.defaultPolicy,
    this.onRetry,
  });

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) async {
    final request = err.requestOptions;
    
    // Check if request has retry metadata
    final attemptNumber = (request.extra['retry_attempt'] as int? ?? 0) + 1;
    
    if (policy.shouldRetry(err, attemptNumber)) {
      // Calculate delay for this retry attempt
      final delay = policy.calculateDelay(attemptNumber);
      
      // Notify retry callback
      onRetry?.call(err, attemptNumber);
      
      // Wait for the calculated delay
      await Future.delayed(delay);
      
      try {
        // Create new request options with updated retry count
        final newOptions = request.copyWith(
          extra: {
            ...request.extra,
            'retry_attempt': attemptNumber,
          },
        );
        
        // Retry the request
        final response = await Dio().request(
          newOptions.path,
          data: newOptions.data,
          queryParameters: newOptions.queryParameters,
          options: Options(
            method: newOptions.method,
            headers: newOptions.headers,
            contentType: newOptions.contentType,
            responseType: newOptions.responseType,
            receiveTimeout: newOptions.receiveTimeout,
            sendTimeout: newOptions.sendTimeout,
            extra: newOptions.extra,
            followRedirects: newOptions.followRedirects,
            maxRedirects: newOptions.maxRedirects,
            validateStatus: newOptions.validateStatus,
            receiveDataWhenStatusError: newOptions.receiveDataWhenStatusError,
            listFormat: newOptions.listFormat,
          ),
        );
        
        handler.resolve(response);
        return;
      } catch (retryError) {
        // If retry also fails, continue with original error handling
        if (retryError is DioException) {
          // Recurse to potentially retry again
          onError(retryError, handler);
          return;
        }
      }
    }
    
    // No more retries, pass through the error
    handler.next(err);
  }
}

/// Circuit breaker for API endpoints to prevent cascading failures
class CircuitBreaker {
  final String name;
  final int failureThreshold;
  final Duration timeout;
  final Duration resetTimeout;

  int _failureCount = 0;
  DateTime? _lastFailureTime;
  CircuitBreakerState _state = CircuitBreakerState.closed;

  CircuitBreaker({
    required this.name,
    this.failureThreshold = 5,
    this.timeout = const Duration(seconds: 60),
    this.resetTimeout = const Duration(minutes: 5),
  });

  CircuitBreakerState get state => _state;
  int get failureCount => _failureCount;

  /// Execute a function with circuit breaker protection
  Future<T> execute<T>(Future<T> Function() operation) async {
    if (_state == CircuitBreakerState.open) {
      if (DateTime.now().difference(_lastFailureTime ?? DateTime.now()) > resetTimeout) {
        _state = CircuitBreakerState.halfOpen;
        _failureCount = 0;
      } else {
        throw CircuitBreakerException('Circuit breaker is OPEN for $name');
      }
    }

    try {
      final result = await operation().timeout(timeout);
      _onSuccess();
      return result;
    } catch (error) {
      _onFailure();
      rethrow;
    }
  }

  void _onSuccess() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _lastFailureTime = null;
  }

  void _onFailure() {
    _failureCount++;
    _lastFailureTime = DateTime.now();
    
    if (_failureCount >= failureThreshold) {
      _state = CircuitBreakerState.open;
    }
  }

  /// Reset the circuit breaker manually
  void reset() {
    _failureCount = 0;
    _state = CircuitBreakerState.closed;
    _lastFailureTime = null;
  }

  /// Get circuit breaker status
  Map<String, dynamic> getStatus() {
    return {
      'name': name,
      'state': _state.toString(),
      'failureCount': _failureCount,
      'lastFailureTime': _lastFailureTime?.toIso8601String(),
      'failureThreshold': failureThreshold,
    };
  }
}

enum CircuitBreakerState {
  closed,   // Normal operation
  open,     // Failing, blocking requests
  halfOpen, // Testing if service recovered
}

class CircuitBreakerException implements Exception {
  final String message;
  CircuitBreakerException(this.message);

  @override
  String toString() => 'CircuitBreakerException: $message';
}

/// Enhanced retry handler with circuit breaker and metrics
class EnhancedRetryHandler {
  final Map<String, CircuitBreaker> _circuitBreakers = {};
  final Map<String, RetryMetrics> _metrics = {};

  /// Execute operation with retry logic and circuit breaker
  Future<T> executeWithRetry<T>({
    required String operationName,
    required Future<T> Function() operation,
    RetryPolicy policy = RetryPolicy.defaultPolicy,
    CircuitBreaker? circuitBreaker,
  }) async {
    final cb = circuitBreaker ?? _getOrCreateCircuitBreaker(operationName);
    final metrics = _getOrCreateMetrics(operationName);
    
    return await cb.execute(() async {
      int attemptNumber = 0;
      DioException? lastError;
      
      while (attemptNumber < policy.maxRetries + 1) {
        attemptNumber++;
        metrics.incrementAttempts();
        
        try {
          final result = await operation();
          metrics.recordSuccess();
          return result;
        } catch (error) {
          if (error is DioException && policy.shouldRetry(error, attemptNumber)) {
            lastError = error;
            metrics.incrementRetries();
            
            if (attemptNumber <= policy.maxRetries) {
              final delay = policy.calculateDelay(attemptNumber);
              await Future.delayed(delay);
              continue;
            }
          }
          
          metrics.recordFailure();
          rethrow;
        }
      }
      
      // If we get here, we've exhausted retries
      metrics.recordFailure();
      throw lastError ?? Exception('Operation failed after ${policy.maxRetries} retries');
    });
  }

  CircuitBreaker _getOrCreateCircuitBreaker(String name) {
    return _circuitBreakers.putIfAbsent(
      name, 
      () => CircuitBreaker(name: name),
    );
  }

  RetryMetrics _getOrCreateMetrics(String name) {
    return _metrics.putIfAbsent(
      name, 
      () => RetryMetrics(name),
    );
  }

  /// Get metrics for all operations
  Map<String, Map<String, dynamic>> getAllMetrics() {
    final result = <String, Map<String, dynamic>>{};
    
    for (final entry in _metrics.entries) {
      result[entry.key] = entry.value.toJson();
    }
    
    return result;
  }

  /// Get circuit breaker statuses
  Map<String, Map<String, dynamic>> getAllCircuitBreakerStatuses() {
    final result = <String, Map<String, dynamic>>{};
    
    for (final entry in _circuitBreakers.entries) {
      result[entry.key] = entry.value.getStatus();
    }
    
    return result;
  }

  /// Reset all circuit breakers
  void resetAllCircuitBreakers() {
    for (final cb in _circuitBreakers.values) {
      cb.reset();
    }
  }

  /// Reset specific circuit breaker
  void resetCircuitBreaker(String name) {
    _circuitBreakers[name]?.reset();
  }
}

/// Metrics tracking for retry operations
class RetryMetrics {
  final String operationName;
  int _totalAttempts = 0;
  int _totalRetries = 0;
  int _successCount = 0;
  int _failureCount = 0;
  DateTime? _lastSuccess;
  DateTime? _lastFailure;

  RetryMetrics(this.operationName);

  void incrementAttempts() => _totalAttempts++;
  void incrementRetries() => _totalRetries++;
  
  void recordSuccess() {
    _successCount++;
    _lastSuccess = DateTime.now();
  }
  
  void recordFailure() {
    _failureCount++;
    _lastFailure = DateTime.now();
  }

  double get successRate => 
      _totalAttempts > 0 ? (_successCount / _totalAttempts) : 0.0;

  double get retryRate => 
      _totalAttempts > 0 ? (_totalRetries / _totalAttempts) : 0.0;

  Map<String, dynamic> toJson() {
    return {
      'operationName': operationName,
      'totalAttempts': _totalAttempts,
      'totalRetries': _totalRetries,
      'successCount': _successCount,
      'failureCount': _failureCount,
      'successRate': successRate,
      'retryRate': retryRate,
      'lastSuccess': _lastSuccess?.toIso8601String(),
      'lastFailure': _lastFailure?.toIso8601String(),
    };
  }
}