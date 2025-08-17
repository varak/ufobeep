import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/push_notification_service.dart';
import '../../services/permission_service.dart';
import '../../services/sound_service.dart';
import '../../services/api_client.dart';
import '../../theme/app_theme.dart';
import 'dart:convert';
import 'dart:math' as math;

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
  List<Map<String, dynamic>> _recentAlerts = [];
  Map<String, dynamic>? _selectedAlertAggregation;
  
  // Rate limiting state
  bool _rateLimitEnabled = true;
  int _rateLimitThreshold = 3;
  String _rateLimitMessage = '';
  
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
      
      // Load recent alerts for witness aggregation analysis
      await _loadRecentAlerts();
      
      // Load rate limiting status
      await _loadRateLimitStatus();
      
      setState(() => _statusMessage = 'Admin mode ready');
    } catch (e) {
      setState(() => _statusMessage = 'Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _loadRecentAlerts() async {
    try {
      final apiClient = ApiClient.instance;
      
      // Get recent alerts within 50km if location available
      if (_currentPosition != null) {
        final response = await apiClient.getNearbyAlerts(
          latitude: _currentPosition!.latitude,
          longitude: _currentPosition!.longitude,
          radiusKm: 50.0,
          limit: 10,
        );
        
        setState(() {
          _recentAlerts = response['data']['alerts'] ?? [];
        });
      }
    } catch (e) {
      print('Failed to load recent alerts: $e');
    }
  }

  Future<void> _loadRateLimitStatus() async {
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.get('/admin/ratelimit/status');
      
      setState(() {
        _rateLimitEnabled = response['enabled'] ?? true;
        _rateLimitThreshold = response['threshold'] ?? 3;
        _rateLimitMessage = 'Loaded current status';
      });
    } catch (e) {
      print('Failed to load rate limit status: $e');
      setState(() {
        _rateLimitMessage = 'Error loading status';
      });
    }
  }

  Future<void> _loadAlertAggregation(String alertId) async {
    setState(() => _isLoading = true);
    
    try {
      final apiClient = ApiClient.instance;
      
      // Get witness aggregation data for the selected alert
      final response = await apiClient.getWitnessAggregation(alertId);
      
      setState(() {
        _selectedAlertAggregation = response['data'];
        _statusMessage = 'Loaded aggregation data for alert $alertId';
      });
      
    } catch (e) {
      setState(() => _statusMessage = 'Failed to load aggregation: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _escalateAlert(String alertId) async {
    setState(() => _isLoading = true);
    
    try {
      final apiClient = ApiClient.instance;
      
      // Escalate the alert
      final response = await apiClient.escalateAlert(alertId);
      
      setState(() => _statusMessage = 'Alert $alertId escalated: ${response['message']}');
      
      // Reload alerts to show updated data
      await _loadRecentAlerts();
      
    } catch (e) {
      setState(() => _statusMessage = 'Failed to escalate alert: $e');
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
    // Admin screen is now available in all builds - access controlled by 5-tap activation

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
            
            // Rate Limiting Controls Section
            _buildRateLimitingCard(),
            const SizedBox(height: 16),
            
            // Engagement Analytics Section
            _buildEngagementAnalyticsCard(),
            const SizedBox(height: 16),
            
            // Witness Aggregation Section (Task 7)
            _buildWitnessAggregationCard(),
            const SizedBox(height: 16),
            
            // Recent Alerts for Analysis
            if (_recentAlerts.isNotEmpty) _buildRecentAlertsCard(),
            const SizedBox(height: 16),
            
            // Aggregation Analysis Result
            if (_selectedAlertAggregation != null) _buildAggregationResultCard(),
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

  Widget _buildWitnessAggregationCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Witness Aggregation (Task 7)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Triangulation, heat maps, and auto-escalation for multiple witness reports',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Refresh Alerts Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: _isLoading ? null : _loadRecentAlerts,
                icon: const Icon(Icons.refresh),
                label: Text('Load Recent Alerts (${_recentAlerts.length})'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimaryLight,
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

  Widget _buildRecentAlertsCard() {
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
                  '🎯 Recent Alerts for Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPrimary,
                  ),
                ),
                Text(
                  '${_recentAlerts.length} alerts',
                  style: const TextStyle(color: AppColors.textSecondary),
                ),
              ],
            ),
            const SizedBox(height: 12),
            
            // Alert list
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: math.min(_recentAlerts.length, 5), // Show max 5
              separatorBuilder: (context, index) => const Divider(color: AppColors.darkBorder),
              itemBuilder: (context, index) {
                final alert = _recentAlerts[index];
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(
                    _getAlertIcon(alert['category'] ?? 'unknown'),
                    color: _getAlertLevelColor(alert['alert_level'] ?? 'low'),
                    size: 20,
                  ),
                  title: Text(
                    alert['title'] ?? 'Unknown Alert',
                    style: const TextStyle(color: AppColors.textPrimary, fontSize: 14),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${alert['witness_count'] ?? 1} witnesses • ${alert['distance_km']?.toStringAsFixed(1) ?? '?'}km',
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    onPressed: _isLoading ? null : () => _loadAlertAggregation(alert['id']),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                      foregroundColor: AppColors.darkBackground,
                      minimumSize: const Size(60, 32),
                    ),
                    child: const Text('Analyze', style: TextStyle(fontSize: 11)),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAggregationResultCard() {
    final aggregation = _selectedAlertAggregation!;
    final triangulation = aggregation['triangulation'] ?? {};
    final summary = aggregation['summary'] ?? {};
    final witnessPoints = aggregation['witness_points'] ?? [];
    
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
                  '🔬 Triangulation Analysis',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.brandPrimary,
                  ),
                ),
                if (summary['should_escalate'] == true)
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : () => _escalateAlert(aggregation['sighting_id']),
                    icon: const Icon(Icons.warning, size: 16),
                    label: const Text('Escalate'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      minimumSize: const Size(80, 32),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Triangulation Results
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildAnalysisRow('Object Location:', 
                    triangulation['object_latitude'] != null
                        ? '${triangulation['object_latitude'].toStringAsFixed(6)}, ${triangulation['object_longitude'].toStringAsFixed(6)}'
                        : 'Unable to triangulate'),
                  _buildAnalysisRow('Confidence Score:', 
                    '${(triangulation['confidence_score'] * 100).toStringAsFixed(1)}%'),
                  _buildAnalysisRow('Consensus Quality:', triangulation['consensus_quality'] ?? 'unknown'),
                  _buildAnalysisRow('Total Witnesses:', '${summary['total_witnesses'] ?? 0}'),
                  _buildAnalysisRow('Agreement:', '${summary['agreement_percentage']?.toStringAsFixed(1) ?? 0}%'),
                  if (triangulation['estimated_radius_meters'] != null)
                    _buildAnalysisRow('Uncertainty Radius:', 
                      '${(triangulation['estimated_radius_meters'] / 1000).toStringAsFixed(2)}km'),
                ],
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Auto-escalation status
            Row(
              children: [
                Icon(
                  summary['should_escalate'] == true ? Icons.trending_up : Icons.trending_flat,
                  color: summary['should_escalate'] == true ? AppColors.error : AppColors.success,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  summary['should_escalate'] == true 
                      ? 'Recommended for auto-escalation'
                      : 'Does not meet escalation criteria',
                  style: TextStyle(
                    color: summary['should_escalate'] == true ? AppColors.error : AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
            
            // Heat map placeholder (simplified visualization)
            if (witnessPoints.isNotEmpty) ...[
              const SizedBox(height: 16),
              const Text(
                'Witness Heat Map:',
                style: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w500),
              ),
              const SizedBox(height: 8),
              Container(
                height: 120,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: AppColors.darkBackground,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Stack(
                  children: [
                    const Center(
                      child: Text(
                        'Heat Map Visualization\n(Simplified for Admin)',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
                      ),
                    ),
                    // Simple witness point visualization
                    ...witnessPoints.asMap().entries.map((entry) {
                      final index = entry.key;
                      final point = entry.value;
                      return Positioned(
                        left: 20.0 + (index * 30.0) % 200,
                        top: 20.0 + (index * 20.0) % 80,
                        child: Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary.withOpacity(0.8),
                            shape: BoxShape.circle,
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(color: Colors.white, fontSize: 8),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAnalysisRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: AppColors.textPrimary, fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  IconData _getAlertIcon(String category) {
    switch (category.toLowerCase()) {
      case 'ufo': return Icons.circle;
      case 'aircraft': return Icons.airplanemode_active;
      case 'satellite': return Icons.satellite;
      case 'weather': return Icons.cloud;
      default: return Icons.help_outline;
    }
  }

  Color _getAlertLevelColor(String level) {
    switch (level.toLowerCase()) {
      case 'critical': return AppColors.error;
      case 'high': return AppColors.warning;
      case 'medium': return AppColors.brandPrimary;
      case 'low': return AppColors.success;
      default: return AppColors.textSecondary;
    }
  }

  Widget _buildRateLimitingCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '⚡ Rate Limiting Controls',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Manage rate limiting for alert notifications to prevent spam',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 14),
            ),
            const SizedBox(height: 16),
            
            // Current status
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkBackground.withOpacity(0.5),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        _rateLimitEnabled ? Icons.shield : Icons.shield_outlined,
                        size: 16,
                        color: _rateLimitEnabled ? AppColors.success : AppColors.warning,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Status: ${_rateLimitEnabled ? "Enabled" : "Disabled"}',
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    'Threshold: $_rateLimitThreshold alerts per 15 minutes',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                  if (_rateLimitMessage.isNotEmpty) ...[ 
                    const SizedBox(height: 4),
                    Text(
                      _rateLimitMessage,
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 10,
                      ),
                    ),
                  ],
                ],
              ),
            ),
            
            const SizedBox(height: 16),
            
            // Control buttons
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                // Enable/Disable toggle
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _toggleRateLimit,
                    icon: Icon(_rateLimitEnabled ? Icons.toggle_on : Icons.toggle_off),
                    label: Text(_rateLimitEnabled ? 'Disable Rate Limiting' : 'Enable Rate Limiting'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _rateLimitEnabled ? AppColors.warning : AppColors.success,
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                
                // Threshold controls
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _setRateThreshold(1),
                        icon: const Icon(Icons.looks_one),
                        label: const Text('Set: 1'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimaryLight,
                          foregroundColor: AppColors.darkBackground,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _setRateThreshold(3),
                        icon: const Icon(Icons.looks_3),
                        label: const Text('Set: 3'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimary,
                          foregroundColor: AppColors.darkBackground,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: _isLoading ? null : () => _setRateThreshold(10),
                        icon: const Icon(Icons.filter_9_plus),
                        label: const Text('Set: 10'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.brandPrimaryLight,
                          foregroundColor: AppColors.darkBackground,
                          padding: const EdgeInsets.symmetric(vertical: 8),
                        ),
                      ),
                    ),
                  ],
                ),
                
                // Clear history
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _clearRateHistory,
                    icon: const Icon(Icons.clear_all),
                    label: const Text('Clear Rate Limit History'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.error,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
                
                // Refresh status
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _isLoading ? null : _refreshRateStatus,
                    icon: const Icon(Icons.refresh),
                    label: const Text('Refresh Status'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandPrimary.withOpacity(0.7),
                      foregroundColor: AppColors.darkBackground,
                      padding: const EdgeInsets.symmetric(vertical: 8),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleRateLimit() async {
    setState(() {
      _isLoading = true;
      _statusMessage = _rateLimitEnabled ? 'Disabling rate limiting...' : 'Enabling rate limiting...';
    });
    
    try {
      final apiClient = ApiClient.instance;
      final endpoint = _rateLimitEnabled ? '/admin/ratelimit/off' : '/admin/ratelimit/on';
      
      final response = await apiClient.get(endpoint);
      
      setState(() {
        _rateLimitEnabled = !_rateLimitEnabled;
        _rateLimitMessage = response['message'] ?? 'Rate limiting ${_rateLimitEnabled ? "enabled" : "disabled"}';
        _statusMessage = 'Rate limiting ${_rateLimitEnabled ? "enabled" : "disabled"} successfully';
      });
      
      await SoundService.I.play(AlertSound.test);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to toggle rate limiting: $e';
        _rateLimitMessage = 'Error occurred';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _setRateThreshold(int threshold) async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Setting rate threshold to $threshold...';
    });
    
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.get('/admin/ratelimit/set?$threshold');
      
      setState(() {
        _rateLimitThreshold = threshold;
        _rateLimitMessage = response['message'] ?? 'Threshold set to $threshold';
        _statusMessage = 'Rate threshold set to $threshold successfully';
      });
      
      await SoundService.I.play(AlertSound.test);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to set threshold: $e';
        _rateLimitMessage = 'Error setting threshold';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _clearRateHistory() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Clearing rate limit history...';
    });
    
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.get('/admin/ratelimit/clear');
      
      setState(() {
        _rateLimitMessage = response['message'] ?? 'Rate limit history cleared';
        _statusMessage = 'Rate limit history cleared successfully';
      });
      
      await SoundService.I.play(AlertSound.test);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to clear history: $e';
        _rateLimitMessage = 'Error clearing history';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _refreshRateStatus() async {
    setState(() {
      _isLoading = true;
      _statusMessage = 'Refreshing rate limit status...';
    });
    
    try {
      final apiClient = ApiClient.instance;
      final response = await apiClient.get('/admin/ratelimit/status');
      
      setState(() {
        _rateLimitEnabled = response['enabled'] ?? true;
        _rateLimitThreshold = response['threshold'] ?? 3;
        _rateLimitMessage = 'Status refreshed at ${DateTime.now().toString().substring(11, 19)}';
        _statusMessage = 'Rate limit status refreshed';
      });
      
      await SoundService.I.play(AlertSound.gpsOk);
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to refresh status: $e';
        _rateLimitMessage = 'Error refreshing status';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Widget _buildEngagementAnalyticsCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '📊 Engagement Analytics',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.brandPrimary,
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Real-time user engagement and alert delivery metrics',
              style: TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 16),
            
            // Metrics Summary (placeholder - could be real-time data)
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Quick Actions',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'See metrics online',
                          style: TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.darkBackground.withOpacity(0.5),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                    ),
                    child: const Column(
                      children: [
                        Text(
                          'Delivery Rate',
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          'Live tracking',
                          style: TextStyle(
                            color: AppColors.brandPrimary,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            // Web Analytics Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openEngagementAnalytics(),
                icon: const Icon(Icons.analytics),
                label: const Text('Open Web Analytics Dashboard'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimary,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 8),
            
            // Quick Metrics Summary Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _openEngagementSummary(),
                icon: const Icon(Icons.dashboard),
                label: const Text('Quick Metrics Summary'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.brandPrimaryLight,
                  foregroundColor: AppColors.darkBackground,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
              ),
            ),
            const SizedBox(height: 12),
            
            const Text(
              'Track user engagement with quick action buttons, alert delivery success rates, and system performance metrics.',
              style: TextStyle(
                color: AppColors.textTertiary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openEngagementAnalytics() async {
    // Open the full engagement analytics page in browser
    try {
      const url = 'https://api.ufobeep.com/admin/engagement/metrics';
      // For mobile app, we'll show a message and copy URL to clipboard
      setState(() {
        _statusMessage = 'Opening engagement analytics dashboard...';
      });
      
      await SoundService.I.play(AlertSound.test);
      
      // In a real implementation, you would use url_launcher package
      // For now, we'll show a dialog with instructions
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: const Text(
              '📊 Engagement Analytics',
              style: TextStyle(color: AppColors.brandPrimary),
            ),
            content: const Text(
              'Open your browser and go to:\n\nhttps://api.ufobeep.com/admin/engagement/metrics\n\nUse admin credentials to view detailed engagement analytics, delivery metrics, and user funnel analysis.',
              style: TextStyle(color: AppColors.textPrimary),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Got it',
                  style: TextStyle(color: AppColors.brandPrimary),
                ),
              ),
            ],
          ),
        );
      }
      
      setState(() {
        _statusMessage = 'Analytics dashboard URL provided';
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to open analytics: $e';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    }
  }

  void _openEngagementSummary() async {
    // Show a quick summary of engagement metrics
    setState(() {
      _statusMessage = 'Loading engagement summary...';
      _isLoading = true;
    });
    
    try {
      // In a real implementation, you would fetch this data from the API
      await Future.delayed(const Duration(seconds: 1)); // Simulate API call
      
      await SoundService.I.play(AlertSound.gpsOk);
      
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            backgroundColor: AppColors.darkSurface,
            title: const Text(
              '📈 Quick Metrics Summary',
              style: TextStyle(color: AppColors.brandPrimary),
            ),
            content: const Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Last 24 Hours:',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 8),
                Text('• Alerts sent: Live tracking enabled', style: TextStyle(color: AppColors.textPrimary)),
                Text('• Quick actions: See web dashboard', style: TextStyle(color: AppColors.textPrimary)),
                Text('• Delivery rate: Real-time monitoring', style: TextStyle(color: AppColors.textPrimary)),
                Text('• Engagement rate: Calculated live', style: TextStyle(color: AppColors.textPrimary)),
                SizedBox(height: 12),
                Text(
                  'For detailed metrics and analytics, use the web dashboard at api.ufobeep.com/admin',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text(
                  'Close',
                  style: TextStyle(color: AppColors.brandPrimary),
                ),
              ),
            ],
          ),
        );
      }
      
      setState(() {
        _statusMessage = 'Engagement summary displayed';
      });
      
    } catch (e) {
      setState(() {
        _statusMessage = 'Failed to load summary: $e';
      });
      await SoundService.I.play(AlertSound.gpsFail);
    } finally {
      setState(() => _isLoading = false);
    }
  }
}