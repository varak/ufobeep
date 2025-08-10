import 'dart:async';
import 'dart:io';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:http/http.dart' as http;

/// Network connectivity monitoring service
class NetworkConnectivityService {
  static final NetworkConnectivityService _instance = NetworkConnectivityService._internal();
  factory NetworkConnectivityService() => _instance;
  NetworkConnectivityService._internal();

  final Connectivity _connectivity = Connectivity();
  
  // Stream controllers
  final StreamController<NetworkStatus> _networkStatusController = 
      StreamController<NetworkStatus>.broadcast();
  final StreamController<List<ConnectivityResult>> _connectivityController = 
      StreamController<List<ConnectivityResult>>.broadcast();

  // Current state
  NetworkStatus _currentStatus = NetworkStatus.unknown;
  List<ConnectivityResult> _currentConnectivity = [];
  Timer? _connectivityCheckTimer;
  Timer? _reachabilityTimer;
  
  // Configuration
  static const Duration _connectivityCheckInterval = Duration(seconds: 30);
  static const Duration _reachabilityCheckInterval = Duration(minutes: 2);
  static const Duration _reachabilityTimeout = Duration(seconds: 5);
  static const String _reachabilityTestUrl = 'https://www.google.com';
  
  bool _initialized = false;
  bool _disposed = false;

  /// Initialize the connectivity service
  Future<void> initialize() async {
    if (_initialized || _disposed) return;
    
    try {
      // Get initial connectivity state
      _currentConnectivity = await _connectivity.checkConnectivity();
      
      // Start listening to connectivity changes
      _connectivity.onConnectivityChanged.listen(_onConnectivityChanged);
      
      // Perform initial reachability check
      await _checkReachability();
      
      // Start periodic checks
      _startPeriodicChecks();
      
      _initialized = true;
    } catch (e) {
      print('Failed to initialize network connectivity service: $e');
      rethrow;
    }
  }

  /// Get current network status stream
  Stream<NetworkStatus> get networkStatusStream => _networkStatusController.stream;
  
  /// Get current connectivity stream
  Stream<List<ConnectivityResult>> get connectivityStream => _connectivityController.stream;
  
  /// Get current network status
  NetworkStatus get currentStatus => _currentStatus;
  
  /// Get current connectivity results
  List<ConnectivityResult> get currentConnectivity => _currentConnectivity;
  
  /// Check if device has internet connection
  bool get hasConnection => _currentStatus == NetworkStatus.connected;
  
  /// Check if device is on mobile data
  bool get isMobileData => _currentConnectivity.contains(ConnectivityResult.mobile);
  
  /// Check if device is on WiFi
  bool get isWiFi => _currentConnectivity.contains(ConnectivityResult.wifi);
  
  /// Check if device is on ethernet
  bool get isEthernet => _currentConnectivity.contains(ConnectivityResult.ethernet);

  /// Handle connectivity state changes
  void _onConnectivityChanged(List<ConnectivityResult> results) {
    _currentConnectivity = results;
    _connectivityController.add(results);
    
    // Update network status based on connectivity
    if (results.contains(ConnectivityResult.none)) {
      _updateNetworkStatus(NetworkStatus.disconnected);
    } else {
      // We have some form of connectivity, but need to verify internet reachability
      _checkReachability();
    }
  }

  /// Check internet reachability
  Future<void> _checkReachability() async {
    try {
      // If no connectivity at all, mark as disconnected
      if (_currentConnectivity.contains(ConnectivityResult.none)) {
        _updateNetworkStatus(NetworkStatus.disconnected);
        return;
      }
      
      // Test actual internet connectivity
      final response = await http.head(
        Uri.parse(_reachabilityTestUrl),
      ).timeout(_reachabilityTimeout);
      
      if (response.statusCode == 200) {
        _updateNetworkStatus(NetworkStatus.connected);
      } else {
        _updateNetworkStatus(NetworkStatus.limited);
      }
    } on SocketException {
      _updateNetworkStatus(NetworkStatus.limited);
    } on TimeoutException {
      _updateNetworkStatus(NetworkStatus.limited);
    } catch (e) {
      print('Reachability check failed: $e');
      _updateNetworkStatus(NetworkStatus.limited);
    }
  }

  /// Update network status and notify listeners
  void _updateNetworkStatus(NetworkStatus status) {
    if (_currentStatus != status) {
      final previousStatus = _currentStatus;
      _currentStatus = status;
      _networkStatusController.add(status);
      
      print('Network status changed: $previousStatus -> $status');
    }
  }

  /// Start periodic connectivity checks
  void _startPeriodicChecks() {
    // Periodic connectivity check
    _connectivityCheckTimer = Timer.periodic(
      _connectivityCheckInterval,
      (_) async {
        try {
          final results = await _connectivity.checkConnectivity();
          if (results != _currentConnectivity) {
            _onConnectivityChanged(results);
          }
        } catch (e) {
          print('Periodic connectivity check failed: $e');
        }
      },
    );
    
    // Periodic reachability check
    _reachabilityTimer = Timer.periodic(
      _reachabilityCheckInterval,
      (_) => _checkReachability(),
    );
  }

  /// Stop periodic checks
  void _stopPeriodicChecks() {
    _connectivityCheckTimer?.cancel();
    _reachabilityTimer?.cancel();
  }

  /// Test connection to specific host
  Future<bool> testConnection(String host, {Duration? timeout}) async {
    try {
      final result = await InternetAddress.lookup(host)
          .timeout(timeout ?? _reachabilityTimeout);
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (e) {
      return false;
    }
  }

  /// Get detailed network information
  Future<NetworkInfo> getNetworkInfo() async {
    final connectivity = await _connectivity.checkConnectivity();
    
    String networkType = 'Unknown';
    String connectionQuality = 'Unknown';
    bool isMetered = false;
    
    if (connectivity.contains(ConnectivityResult.wifi)) {
      networkType = 'WiFi';
      connectionQuality = 'Good'; // WiFi is typically good quality
      isMetered = false;
    } else if (connectivity.contains(ConnectivityResult.mobile)) {
      networkType = 'Mobile Data';
      connectionQuality = 'Variable'; // Mobile quality varies
      isMetered = true;
    } else if (connectivity.contains(ConnectivityResult.ethernet)) {
      networkType = 'Ethernet';
      connectionQuality = 'Excellent';
      isMetered = false;
    } else if (connectivity.contains(ConnectivityResult.none)) {
      networkType = 'No Connection';
      connectionQuality = 'None';
    }
    
    return NetworkInfo(
      networkType: networkType,
      connectionQuality: connectionQuality,
      isMetered: isMetered,
      hasInternetAccess: _currentStatus == NetworkStatus.connected,
      currentStatus: _currentStatus,
      connectivityResults: connectivity,
    );
  }

  /// Wait for network connection
  Future<void> waitForConnection({Duration? timeout}) async {
    if (hasConnection) return;
    
    final completer = Completer<void>();
    late StreamSubscription subscription;
    
    subscription = networkStatusStream.listen((status) {
      if (status == NetworkStatus.connected) {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.complete();
        }
      }
    });
    
    // Set timeout if provided
    if (timeout != null) {
      Timer(timeout, () {
        subscription.cancel();
        if (!completer.isCompleted) {
          completer.completeError(TimeoutException('Network connection timeout', timeout));
        }
      });
    }
    
    return completer.future;
  }

  /// Execute operation when network is available
  Future<T> executeWhenConnected<T>(
    Future<T> Function() operation, {
    Duration? timeout,
    int maxRetries = 3,
  }) async {
    int retries = 0;
    
    while (retries < maxRetries) {
      try {
        await waitForConnection(timeout: timeout);
        return await operation();
      } catch (e) {
        retries++;
        if (retries >= maxRetries) {
          rethrow;
        }
        
        // Wait before retrying
        await Future.delayed(Duration(seconds: retries * 2));
      }
    }
    
    throw Exception('Failed to execute operation after $maxRetries retries');
  }

  /// Get network metrics
  NetworkMetrics getNetworkMetrics() {
    // In a real implementation, this would track actual metrics
    // For now, provide basic information
    return NetworkMetrics(
      connectionUptime: _getConnectionUptime(),
      disconnectionCount: _getDisconnectionCount(),
      averageLatency: null, // Would need to track actual latency
      dataUsage: null, // Would need to track actual data usage
      lastConnected: _getLastConnectedTime(),
      networkType: _currentConnectivity.isNotEmpty 
          ? _currentConnectivity.first.toString()
          : 'None',
    );
  }

  // Helper methods for metrics (would be implemented with actual tracking)
  Duration _getConnectionUptime() {
    // Placeholder implementation
    return const Duration(hours: 1);
  }
  
  int _getDisconnectionCount() {
    // Placeholder implementation
    return 0;
  }
  
  DateTime? _getLastConnectedTime() {
    // Placeholder implementation
    return _currentStatus == NetworkStatus.connected ? DateTime.now() : null;
  }

  /// Dispose the service
  Future<void> dispose() async {
    if (_disposed) return;
    
    _disposed = true;
    _stopPeriodicChecks();
    
    await _networkStatusController.close();
    await _connectivityController.close();
  }
}

/// Network status enumeration
enum NetworkStatus {
  unknown,        // Initial/unknown state
  connected,      // Has internet connection
  limited,        // Has connectivity but limited/no internet access
  disconnected,   // No connectivity
}

/// Network information
class NetworkInfo {
  final String networkType;
  final String connectionQuality;
  final bool isMetered;
  final bool hasInternetAccess;
  final NetworkStatus currentStatus;
  final List<ConnectivityResult> connectivityResults;

  const NetworkInfo({
    required this.networkType,
    required this.connectionQuality,
    required this.isMetered,
    required this.hasInternetAccess,
    required this.currentStatus,
    required this.connectivityResults,
  });

  Map<String, dynamic> toJson() {
    return {
      'networkType': networkType,
      'connectionQuality': connectionQuality,
      'isMetered': isMetered,
      'hasInternetAccess': hasInternetAccess,
      'currentStatus': currentStatus.toString(),
      'connectivityResults': connectivityResults.map((r) => r.toString()).toList(),
    };
  }
}

/// Network metrics
class NetworkMetrics {
  final Duration connectionUptime;
  final int disconnectionCount;
  final Duration? averageLatency;
  final int? dataUsage; // in bytes
  final DateTime? lastConnected;
  final String networkType;

  const NetworkMetrics({
    required this.connectionUptime,
    required this.disconnectionCount,
    this.averageLatency,
    this.dataUsage,
    this.lastConnected,
    required this.networkType,
  });

  Map<String, dynamic> toJson() {
    return {
      'connectionUptime': connectionUptime.inSeconds,
      'disconnectionCount': disconnectionCount,
      'averageLatency': averageLatency?.inMilliseconds,
      'dataUsage': dataUsage,
      'lastConnected': lastConnected?.toIso8601String(),
      'networkType': networkType,
    };
  }
}

/// Network connectivity extensions for easy access
extension NetworkConnectivityExtension on NetworkConnectivityService {
  /// Check if network is suitable for heavy operations
  bool get isGoodForHeavyOperations {
    return hasConnection && (isWiFi || isEthernet);
  }
  
  /// Check if should avoid heavy data usage
  bool get shouldAvoidHeavyDataUsage {
    return isMobileData || currentStatus != NetworkStatus.connected;
  }
  
  /// Get user-friendly connection description
  String get connectionDescription {
    switch (currentStatus) {
      case NetworkStatus.connected:
        if (isWiFi) return 'Connected via WiFi';
        if (isMobileData) return 'Connected via Mobile Data';
        if (isEthernet) return 'Connected via Ethernet';
        return 'Connected';
      case NetworkStatus.limited:
        return 'Limited connectivity';
      case NetworkStatus.disconnected:
        return 'No connection';
      case NetworkStatus.unknown:
        return 'Checking connection...';
    }
  }
}