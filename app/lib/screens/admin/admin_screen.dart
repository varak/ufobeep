import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/permission_service.dart';
import '../../services/sound_service.dart';
import '../../theme/app_theme.dart';
import 'dart:convert';

class AdminScreen extends ConsumerStatefulWidget {
  const AdminScreen({Key? key}) : super(key: key);

  @override
  ConsumerState<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends ConsumerState<AdminScreen> {
  String _statusMessage = 'Ready';
  bool _isLoading = false;
  Map<String, dynamic>? _lastTestResult;
  String? _deviceId;
  String? _fcmToken;
  Position? _currentPosition;
  
  @override
  void initState() {
    super.initState();
    _initializeAdminData();
  }

  Future<void> _initializeAdminData() async {
    setState(() => _isLoading = true);
    
    try {
      // Get device info
      _deviceId = await anonymousBeepService.getOrCreateDeviceId();
      _fcmToken = await pushNotificationService.getCachedToken();
      
      // Get current location
      if (permissionService.locationGranted) {
        _currentPosition = await permissionService.getCurrentLocation();
      }
      
      setState(() => _statusMessage = 'Admin mode ready');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testProximityAlert() async {
    if (_currentPosition == null) {
      setState(() => _statusMessage = 'No location available');
      return;
    }
    
    setState(() {
      _isLoading = true;
      _statusMessage = 'Sending test proximity alert...';
    });
    
    try {
      final result = await anonymousBeepService.sendBeep(
        latitude: _currentPosition!.latitude,
        longitude: _currentPosition!.longitude,
        description: 'Admin test proximity alert',
      );
      
      setState(() {
        _lastTestResult = result;
        _statusMessage = 'Test alert sent successfully';
      });
      
      // Play success sound
      await SoundService.I.play(AlertSound.test);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Test failed: $e';
        _lastTestResult = null;
      });
      
      // Play error sound
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testPushNotification() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Testing push notification...';
    });
    
    try {
      final success = await pushNotificationService.testPushNotification();
      
      setState(() {
        _statusMessage = success ? 'Push test sent successfully' : 'Push test failed';
      });
      
      await SoundService.I.play(success ? AlertSound.test : AlertSound.gpsFail);
      
    } catch (e) {
      setState(() => _statusMessage = 'Push test error: $e');
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshLocation() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Getting current location...';
    });
    
    try {
      await permissionService.refreshPermissions();
      if (permissionService.locationGranted) {
        _currentPosition = await permissionService.getCurrentLocation();
        setState(() => _statusMessage = 'Location updated');
        await SoundService.I.play(AlertSound.gpsOk);
      } else {
        setState(() => _statusMessage = 'Location permission denied');
        await SoundService.I.play(AlertSound.gpsFail);
      }
    } catch (e) {
      setState(() => _statusMessage = 'Location error: $e');
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _testSoundSystem() async {
    setState(() => _statusMessage = 'Testing sound system...');
    
    // Test all alert sounds in sequence
    await SoundService.I.play(AlertSound.normal);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await SoundService.I.play(AlertSound.urgent);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await SoundService.I.play(AlertSound.emergency, haptic: true);
    await Future.delayed(const Duration(milliseconds: 500));
    
    await SoundService.I.play(AlertSound.pushPing);
    
    setState(() => _statusMessage = 'Sound test complete');
  }

  @override
  Widget build(BuildContext context) {
    // Only show admin screen in debug mode
    if (kReleaseMode) {
      return Scaffold(
        backgroundColor: AppColors.darkBackground,
        appBar: AppBar(
          title: const Text('Access Denied'),
          backgroundColor: AppColors.darkSurface,
        ),
        body: const Center(
          child: Text(
            'Admin features only available in debug builds',
            style: TextStyle(color: AppColors.textSecondary),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: const Text('🛡️ Admin Panel'),
        backgroundColor: AppColors.darkSurface,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _initializeAdminData,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status Section
            _buildStatusCard(),
            const SizedBox(height: 16),
            
            // Device Info Section  
            _buildDeviceInfoCard(),
            const SizedBox(height: 16),
            
            // Location Section
            _buildLocationCard(),
            const SizedBox(height: 16),
            
            // Test Controls Section
            _buildTestControlsCard(),
            const SizedBox(height: 16),
            
            // Last Test Result
            if (_lastTestResult != null) _buildTestResultCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 System Status',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  _isLoading ? Icons.hourglass_empty : Icons.check_circle,
                  color: _isLoading ? AppColors.warning : AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _statusMessage,
                    style: const TextStyle(color: AppColors.textPrimary),
                  ),
                ),
              ],
            ),
            if (_isLoading) ...[
              const SizedBox(height: 12),
              const LinearProgressIndicator(
                backgroundColor: AppColors.darkBackground,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildDeviceInfoCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📱 Device Information',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Device ID', _deviceId ?? 'Loading...'),
            _buildInfoRow('FCM Token', _fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : 'Not available'),
            _buildInfoRow('Push Permission', pushNotificationService.isPermissionGranted().toString()),
            _buildInfoRow('Location Permission', permissionService.locationGranted.toString()),
          ],
        ),
      ),
    );
  }

  Widget _buildLocationCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  '📍 Location Status',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPrimary,
                  ),
                ),
                ElevatedButton(
                  onPressed: _isLoading ? null : _refreshLocation,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandPrimaryLight,
                    foregroundColor: AppColors.darkBackground,
                  ),
                  child: const Text('Refresh'),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (_currentPosition != null) ...[
              _buildInfoRow('Latitude', _currentPosition!.latitude.toStringAsFixed(6)),
              _buildInfoRow('Longitude', _currentPosition!.longitude.toStringAsFixed(6)),
              _buildInfoRow('Accuracy', '${_currentPosition!.accuracy.toStringAsFixed(1)}m'),
              _buildInfoRow('Timestamp', DateTime.fromMillisecondsSinceEpoch(_currentPosition!.timestamp!.millisecondsSinceEpoch).toString()),
            ] else ...[
              const Text(
                'No location data available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTestControlsCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '🧪 Test Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 16),
            
            // Test Proximity Alert
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testProximityAlert,
                icon: const Icon(Icons.radar),
                label: const Text('Test Proximity Alert'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Test Push Notification
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testPushNotification,
                icon: const Icon(Icons.notifications),
                label: const Text('Test Push Notification'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimaryLight,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            // Test Sound System
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _testSoundSystem,
                icon: const Icon(Icons.volume_up),
                label: const Text('Test Sound System'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.warning,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestResultCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📋 Last Test Result',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Text(
                _formatTestResult(_lastTestResult!),
                style: const TextStyle(
                  color: AppColors.textPrimary,
                  fontFamily: 'monospace',
                  fontSize: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTestResult(Map<String, dynamic> result) {
    const encoder = JsonEncoder.withIndent('  ');
    return encoder.convert(result);
  }
}