import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:geolocator/geolocator.dart';
import '../../theme/app_theme.dart';
import '../../services/beep_service.dart';
import '../../services/api_client.dart';
import '../../services/permission_service.dart';
import '../../services/push_notification_service.dart';
import '../../providers/user_preferences_provider.dart';
import '../../widgets/glass_card.dart';

class FieldDiagnosticScreen extends ConsumerStatefulWidget {
  const FieldDiagnosticScreen({super.key});

  @override
  ConsumerState<FieldDiagnosticScreen> createState() => _FieldDiagnosticScreenState();
}

class _FieldDiagnosticScreenState extends ConsumerState<FieldDiagnosticScreen> {
  String _deviceId = 'Loading...';
  String _appVersion = 'Loading...';
  bool _isOnline = false;
  bool _apiConnected = false;
  Position? _currentLocation;
  bool _locationPermission = false;
  bool _notificationPermission = false;
  String? _fcmToken;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadDiagnostics();
  }

  Future<void> _loadDiagnostics() async {
    setState(() => _isLoading = true);

    try {
      // Device info
      final deviceId = await beepService.getOrCreateDeviceId();
      final packageInfo = await PackageInfo.fromPlatform();

      // Connection tests
      final apiConnected = await _testApiConnection();

      // Location diagnostics
      final locationPermission = await permissionService.locationGranted;
      Position? location;
      if (locationPermission) {
        try {
          location = await permissionService.getCurrentLocation();
        } catch (e) {
          debugPrint('Location error: $e');
        }
      }

      // Notification diagnostics
      final notificationPermission = await pushNotificationService.isPermissionGranted();
      final fcmToken = await pushNotificationService.getCachedToken();

      setState(() {
        _deviceId = deviceId;
        _appVersion = '${packageInfo.version}+${packageInfo.buildNumber}';
        _apiConnected = apiConnected;
        _currentLocation = location;
        _locationPermission = locationPermission;
        _notificationPermission = notificationPermission;
        _fcmToken = fcmToken;
        _isLoading = false;
      });

    } catch (e) {
      debugPrint('Diagnostic loading error: $e');
      setState(() => _isLoading = false);
    }
  }

  Future<bool> _testApiConnection() async {
    try {
      final apiClient = ApiClient.instance;
      final healthy = await apiClient.checkHealth();
      setState(() => _isOnline = healthy);
      return healthy;
    } catch (e) {
      setState(() => _isOnline = false);
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final userPrefs = ref.watch(userPreferencesProvider);

    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Navigator.of(context).pop(),
          ),
          title: const Text(
            'Field Diagnostics',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh, color: Colors.white),
              onPressed: _loadDiagnostics,
            ),
          ],
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.brandPrimary))
            : _buildDiagnosticsList(userPrefs),
      ),
    );
  }

  Widget _buildDiagnosticsList(dynamic userPrefs) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDeviceSection(),
          const SizedBox(height: 16),
          _buildLocationSection(),
          const SizedBox(height: 16),
          _buildNotificationSection(),
          const SizedBox(height: 16),
          _buildSettingsSection(userPrefs),
          const SizedBox(height: 16),
          _buildQuickTestsSection(),
        ],
      ),
    );
  }

  Widget _buildDeviceSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Device & Connection', Icons.phone_android),
          const SizedBox(height: 12),
          _buildDiagnosticItem('Device ID', _deviceId),
          _buildDiagnosticItem('App Version', _appVersion),
          _buildDiagnosticItem('Internet', _isOnline ? '✅ Connected' : '❌ Offline',
              isGood: _isOnline),
          _buildDiagnosticItem('API Server', _apiConnected ? '✅ Reachable' : '❌ API timeout',
              isGood: _apiConnected),
        ],
      ),
    );
  }

  Widget _buildLocationSection() {
    final locationText = _currentLocation != null
        ? '✅ ${_currentLocation!.latitude.toStringAsFixed(3)}, ${_currentLocation!.longitude.toStringAsFixed(3)}'
        : '❌ No GPS fix';
    final accuracyText = _currentLocation?.accuracy != null
        ? '±${_currentLocation!.accuracy.toStringAsFixed(0)}m'
        : '';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Location & Permissions', Icons.location_on),
          const SizedBox(height: 12),
          _buildDiagnosticItem('GPS Status', '$locationText $accuracyText',
              isGood: _currentLocation != null),
          _buildDiagnosticItem('Location Permission',
              _locationPermission ? '✅ Granted' : '❌ Denied',
              isGood: _locationPermission),
          if (_currentLocation != null)
            _buildDiagnosticItem('Last Update', 'Just now'),
        ],
      ),
    );
  }

  Widget _buildNotificationSection() {
    final tokenStatus = _fcmToken != null ? '✅ Valid FCM token' : '❌ No token';
    final tokenPreview = _fcmToken != null ? '${_fcmToken!.substring(0, 20)}...' : 'None';

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Notifications', Icons.notifications),
          const SizedBox(height: 12),
          _buildDiagnosticItem('Push Permission',
              _notificationPermission ? '✅ Granted' : '❌ Denied',
              isGood: _notificationPermission),
          _buildDiagnosticItem('Push Token', tokenStatus, isGood: _fcmToken != null),
          _buildDiagnosticItem('Token Preview', tokenPreview),
        ],
      ),
    );
  }

  Widget _buildSettingsSection(dynamic userPrefs) {
    final language = userPrefs?.language ?? 'en';
    final units = userPrefs?.units ?? 'metric';
    final dndActive = userPrefs?.dndUntil?.isAfter(DateTime.now()) ?? false;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Current Settings', Icons.settings),
          const SizedBox(height: 12),
          _buildDiagnosticItem('Language', language.toUpperCase()),
          _buildDiagnosticItem('Units', units == 'metric' ? 'Metric (km)' : 'Imperial (mi)'),
          _buildDiagnosticItem('DND Status', dndActive ? '⏰ Active' : '✅ Off', isGood: !dndActive),
          _buildDiagnosticItem('Quiet Hours', userPrefs?.quietHoursEnabled == true ?
              '🌙 ${userPrefs.quietHoursStart}:00 - ${userPrefs.quietHoursEnd}:00' : '✅ Disabled'),
        ],
      ),
    );
  }

  Widget _buildQuickTestsSection() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildSectionHeader('Quick Tests', Icons.science),
          const SizedBox(height: 12),
          _buildTestButton('Test Push Notification', Icons.notifications, _testPushNotification),
          const SizedBox(height: 8),
          _buildTestButton('Test GPS Location', Icons.gps_fixed, _testGpsLocation),
          const SizedBox(height: 8),
          _buildTestButton('Test API Connection', Icons.cloud, _testApiConnection),
          const SizedBox(height: 8),
          _buildTestButton('Export Diagnostics', Icons.download, _exportDiagnostics),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, IconData icon) {
    return Row(
      children: [
        Icon(icon, color: AppColors.brandPrimary, size: 20),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDiagnosticItem(String label, String value, {bool? isGood}) {
    final valueColor = isGood == null
        ? AppColors.textSecondary
        : (isGood ? AppColors.success : AppColors.error);

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: AppColors.textTertiary, fontSize: 13),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(color: valueColor, fontSize: 13, fontFamily: 'monospace'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTestButton(String label, IconData icon, VoidCallback onPressed) {
    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: Icon(icon, size: 16),
        label: Text(label),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.brandPrimary,
          side: const BorderSide(color: AppColors.brandPrimary),
        ),
      ),
    );
  }

  void _testPushNotification() async {
    try {
      final success = await pushNotificationService.testPushNotification();
      _showTestResult('Push Notification', success ? 'Test notification sent successfully' : 'Failed to send test notification');
    } catch (e) {
      _showTestResult('Push Notification', 'Error: $e');
    }
  }

  void _testGpsLocation() async {
    try {
      final location = await permissionService.getCurrentLocation();
      if (location != null) {
        _showTestResult('GPS Location',
            'Location: ${location.latitude.toStringAsFixed(6)}, ${location.longitude.toStringAsFixed(6)}\n'
            'Accuracy: ±${location.accuracy.toStringAsFixed(0)}m');
        setState(() => _currentLocation = location);
      } else {
        _showTestResult('GPS Location', 'Failed to get location');
      }
    } catch (e) {
      _showTestResult('GPS Location', 'Error: $e');
    }
  }

  void _exportDiagnostics() {
    final diagnostics = '''
UFOBeep Field Diagnostics Report
Generated: ${DateTime.now().toIso8601String()}

Device Information:
- Device ID: $_deviceId
- App Version: $_appVersion
- Platform: Android

Connectivity:
- Internet: ${_isOnline ? 'Connected' : 'Offline'}
- API Server: ${_apiConnected ? 'Reachable' : 'Timeout'}

Location:
- GPS: ${_currentLocation != null ? '${_currentLocation!.latitude}, ${_currentLocation!.longitude}' : 'No fix'}
- Accuracy: ${_currentLocation?.accuracy?.toStringAsFixed(0) ?? 'N/A'}m
- Permission: ${_locationPermission ? 'Granted' : 'Denied'}

Notifications:
- Permission: ${_notificationPermission ? 'Granted' : 'Denied'}
- FCM Token: ${_fcmToken != null ? 'Valid' : 'Missing'}
- Token Preview: ${_fcmToken?.substring(0, 20) ?? 'None'}...

Settings:
- Language: ${ref.read(userPreferencesProvider)?.language ?? 'en'}
- Units: ${ref.read(userPreferencesProvider)?.units ?? 'metric'}
- DND: ${ref.read(userPreferencesProvider)?.dndUntil?.isAfter(DateTime.now()) == true ? 'Active' : 'Off'}
''';

    _showTestResult('Diagnostics Export', diagnostics);
  }

  void _showTestResult(String testName, String result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          '$testName Result',
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: SingleChildScrollView(
          child: Text(
            result,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontFamily: 'monospace',
              fontSize: 12,
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close', style: TextStyle(color: AppColors.brandPrimary)),
          ),
        ],
      ),
    );
  }
}