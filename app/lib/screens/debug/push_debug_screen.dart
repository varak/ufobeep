import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:dio/dio.dart';
import '../../services/device_service.dart';
import '../../services/device_registration_manager.dart';
import '../../services/auth_repository.dart';
import '../../services/api_client.dart';
import 'dart:convert';

class PushDebugScreen extends StatefulWidget {
  const PushDebugScreen({super.key});

  @override
  State<PushDebugScreen> createState() => _PushDebugScreenState();
}

class _PushDebugScreenState extends State<PushDebugScreen> {
  final DeviceService _deviceService = DeviceService();
  final AuthRepository _authRepository = AuthRepository();
  String _statusText = 'Ready to debug...';
  Map<String, dynamic>? _lastResponse;
  bool _isLoading = false;
  late Future<String?> _accessTokenFuture;

  @override
  void initState() {
    super.initState();
    // Use async pattern instead of calling _checkInitialStatus() synchronously
    _accessTokenFuture = _authRepository.getAccessToken();
  }

  Future<void> _checkInitialStatus() async {
    setState(() {
      _statusText = 'Checking initial status...';
    });
    
    final accessToken = await _authRepository.getAccessToken();
    final fcmToken = await _deviceService.getFcmToken();
    final regManager = DeviceRegistrationManager();
    
    setState(() {
      _statusText = '''[DBUG][INIT] Status Check:
├── JWT Auth: ${accessToken != null ? "✓" : "✗"}
├── FCM Token: ${fcmToken != null ? "✓ (...${fcmToken?.substring(fcmToken.length - 6)})" : "✗"}
├── Registration Manager: ${regManager.isRegistered ? "✓ Registered" : "✗ Not registered"}
└── Ready for testing''';
    });
  }

  Future<void> _registerDevice() async {
    setState(() {
      _isLoading = true;
      _statusText = '[DBUG][REG] Starting device registration...';
    });
    
    try {
      debugPrint('[DBUG][REG] Triggering device registration');
      await DeviceRegistrationManager().ensureRegisteredSoon();
      
      // Give it a moment to process
      await Future.delayed(const Duration(seconds: 2));
      
      setState(() {
        _statusText = '[DBUG][REG] ✅ Registration triggered - check logs for results';
      });
    } catch (e) {
      debugPrint('[DBUG][REG] ❌ Registration error: $e');
      setState(() {
        _statusText = '[DBUG][REG] ❌ Registration failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkServerStatus() async {
    setState(() {
      _isLoading = true;
      _statusText = '[DBUG][STATUS] Checking server status...';
    });
    
    try {
      // Ensure we have a valid auth token
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        setState(() {
          _statusText = '[DBUG][STATUS] ❌ No access token available - please log in first';
        });
        return;
      }
      
      debugPrint('[DBUG][STATUS] Calling /devices/status with auth token');
      
      // Make authenticated request
      final response = await ApiClient.dio.get(
        '/devices/status',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final data = response.data;
      setState(() {
        _lastResponse = data;
        _statusText = '''[DBUG][STATUS] ✅ Server Response:
├── Registered: ${data['is_registered'] ?? false}
├── Device ID: ${data['device_id'] ?? 'N/A'}
├── Platform: ${data['platform'] ?? 'N/A'}
├── Push Enabled: ${data['push_enabled'] ?? false}
├── FCM Token: ${data['fcm_token_present'] ?? false ? "✓" : "✗"}
├── Token Hash: ${data['fcm_token_hash'] ?? 'N/A'}
├── Last Seen: ${data['last_seen_at'] ?? 'N/A'}
└── User ID: ${data['user_id'] ?? 'N/A'}''';
      });
    } catch (e) {
      debugPrint('[DBUG][STATUS] ❌ Status check error: $e');
      setState(() {
        _statusText = '[DBUG][STATUS] ❌ Failed to check status: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendTestPush() async {
    setState(() {
      _isLoading = true;
      _statusText = '[DBUG][PUSH] Sending test push...';
    });
    
    try {
      // Ensure we have a valid auth token
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        setState(() {
          _statusText = '[DBUG][PUSH] ❌ No access token available - please log in first';
        });
        return;
      }
      
      debugPrint('[DBUG][PUSH] Calling /devices/debug/test-push');
      final response = await ApiClient.dio.post(
        '/devices/debug/test-push',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final data = response.data;
      setState(() {
        _lastResponse = data;
        _statusText = '''[DBUG][PUSH] ${data['success'] ? '✅' : '❌'} Test Push Result:
├── Success: ${data['success']}
├── Message: ${data['message'] ?? data['error'] ?? 'N/A'}
├── Target Device: ${data['target_device'] ?? 'N/A'}
├── Platform: ${data['platform'] ?? 'N/A'}
├── FCM Hash: ${data['fcm_token_hash'] ?? 'N/A'}
├── FCM Message ID: ${data['fcm_message_id'] ?? 'N/A'}
└── Firebase Response: ${data['firebase_response'] ?? 'N/A'}''';
      });
    } catch (e) {
      debugPrint('[DBUG][PUSH] ❌ Test push error: $e');
      setState(() {
        _statusText = '[DBUG][PUSH] ❌ Test push failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _checkJWT() async {
    setState(() {
      _isLoading = true;
      _statusText = '[DBUG][JWT] Validating JWT token...';
    });
    
    try {
      // Get the current access token
      final accessToken = await _authRepository.getAccessToken();
      if (accessToken == null) {
        setState(() {
          _statusText = '[DBUG][JWT] ❌ No access token available - please log in first';
        });
        return;
      }
      
      debugPrint('[DBUG][JWT] Calling /devices/debug/jwt');
      final response = await ApiClient.dio.get(
        '/devices/debug/jwt',
        options: Options(
          headers: {
            'Authorization': 'Bearer $accessToken',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      final data = response.data;
      setState(() {
        _lastResponse = data;
        _statusText = '''[DBUG][JWT] ${data['valid'] ? '✅' : '❌'} JWT Validation:
├── Valid: ${data['valid']}
├── User ID: ${data['user_id'] ?? 'N/A'}
├── Token Type: ${data['token_type'] ?? 'N/A'}
├── Token Length: ${data['token_length'] ?? 'N/A'}
├── Token Preview: ${data['token_preview'] ?? 'N/A'}
├── Expires: ${data['exp'] != null ? DateTime.fromMillisecondsSinceEpoch(data['exp'] * 1000) : 'N/A'}
└── Error: ${data['error'] ?? 'None'}''';
      });
    } catch (e) {
      debugPrint('[DBUG][JWT] ❌ JWT validation error: $e');
      setState(() {
        _statusText = '[DBUG][JWT] ❌ JWT validation failed: $e';
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _copyResponseToClipboard() async {
    if (_lastResponse != null) {
      final jsonString = const JsonEncoder.withIndent('  ').convert(_lastResponse);
      await Clipboard.setData(ClipboardData(text: jsonString));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Response copied to clipboard'))
        );
      }
    }
  }

  Widget _buildDebugButton(String title, VoidCallback onPressed, {Color? color}) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ElevatedButton(
        onPressed: _isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: color ?? Colors.blue,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 12),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: const Text('🔔 Push Debug', style: TextStyle(fontFamily: 'monospace')),
        backgroundColor: Colors.grey[900],
        actions: [
          if (_lastResponse != null)
            IconButton(
              icon: const Icon(Icons.copy),
              onPressed: _copyResponseToClipboard,
              tooltip: 'Copy Response',
            ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {
                _accessTokenFuture = _authRepository.getAccessToken();
              });
            },
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: FutureBuilder<String?>(
        future: _accessTokenFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingUi();
          }
          
          final accessToken = snapshot.data;
          if (accessToken == null || accessToken.isEmpty) {
            return _buildErrorUi('Please log in first — no access token available.');
          }
          
          return _buildDebugUi(accessToken);
        },
      ),
    );
  }
  
  Widget _buildLoadingUi() {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Loading authentication status...',
                    style: TextStyle(
                      color: Colors.white70,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildErrorUi(String message) {
    return Column(
      children: [
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    color: Colors.red,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    message,
                    style: const TextStyle(
                      color: Colors.red,
                      fontFamily: 'monospace',
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _accessTokenFuture = _authRepository.getAccessToken();
                      });
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
  
  Widget _buildDebugUi(String accessToken) {
    // Initialize status on first load with token info
    if (_statusText == 'Ready to debug...') {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _checkInitialStatus();
      });
    }
    
    return Column(
      children: [
        // Control Panel
        Container(
          padding: const EdgeInsets.all(16),
          color: Colors.grey[900],
          child: Column(
            children: [
              _buildDebugButton('🔐 Register Device Now', _registerDevice),
              _buildDebugButton('📊 Check Server Status', _checkServerStatus),
              _buildDebugButton('🔔 Send Test Push', _sendTestPush),
              _buildDebugButton('🎫 Validate JWT Token', _checkJWT),
            ],
          ),
        ),
        
        // Status Display
        Expanded(
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: SingleChildScrollView(
              child: SelectableText(
                _statusText,
                style: const TextStyle(
                  fontFamily: 'monospace',
                  fontSize: 13,
                  color: Colors.white,
                  height: 1.4,
                ),
              ),
            ),
          ),
        ),
        
        // Loading Indicator
        if (_isLoading)
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[900],
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                SizedBox(width: 12),
                Text(
                  'Processing...',
                  style: TextStyle(
                    color: Colors.white70,
                    fontFamily: 'monospace',
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}