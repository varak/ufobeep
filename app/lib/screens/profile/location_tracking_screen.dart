import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../services/location_tracking_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/glass_card.dart';
import '../../l10n/app_localizations.dart';

class LocationTrackingScreen extends StatefulWidget {
  const LocationTrackingScreen({super.key});

  @override
  State<LocationTrackingScreen> createState() => _LocationTrackingScreenState();
}

class _LocationTrackingScreenState extends State<LocationTrackingScreen> {
  bool _isTrackingEnabled = false;
  bool _isLoading = true;
  Map<String, dynamic>? _trackingStatus;

  @override
  void initState() {
    super.initState();
    _loadTrackingStatus();
  }

  Future<void> _loadTrackingStatus() async {
    try {
      // Force refresh permission status to ensure accuracy
      final currentPermission = await Geolocator.checkPermission();
      print('LocationTracking UI: Current permission status: $currentPermission');

      final enabled = await locationTrackingService.isTrackingEnabled();
      final status = locationTrackingService.getTrackingStatus();

      print('LocationTracking UI: Service reports enabled: $enabled');

      setState(() {
        _isTrackingEnabled = enabled;
        _trackingStatus = status;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading tracking status: $e');
      setState(() {
        _isTrackingEnabled = false;
        _trackingStatus = null;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return NightSkyBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text(
            AppLocalizations.of(context)!.locationTracking,
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
          iconTheme: const IconThemeData(color: Colors.white),
        ),
        body: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Explanation Card
                    _buildExplanationCard(),

                    const SizedBox(height: 24),

                    // Main Toggle
                    _buildMainToggle(),

                    const SizedBox(height: 24),

                    // Status Information
                    if (_isTrackingEnabled) _buildStatusCard(),

                    const SizedBox(height: 24),

                    // Technical Details
                    _buildTechnicalDetailsCard(),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildExplanationCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.location_on,
                  color: AppColors.brandPrimary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  AppLocalizations.of(context)!.locationTrackingTitle,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          Text(
            AppLocalizations.of(context)!.locationTrackingExplanation,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),

          const SizedBox(height: 16),

          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.05),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.battery_saver_outlined,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    AppLocalizations.of(context)!.locationTrackingBattery,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainToggle() {
    return GlassCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: (_isTrackingEnabled ? AppColors.brandPrimary : AppColors.textSecondary).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  _isTrackingEnabled ? Icons.location_on : Icons.location_off,
                  color: _isTrackingEnabled ? AppColors.brandPrimary : AppColors.textSecondary,
                  size: 22,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.backgroundLocationTracking,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      _isTrackingEnabled
                          ? AppLocalizations.of(context)!.locationTrackingActive
                          : AppLocalizations.of(context)!.locationTrackingInactive,
                      style: TextStyle(
                        color: _isTrackingEnabled ? AppColors.brandPrimary : AppColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
              Switch(
                value: _isTrackingEnabled,
                onChanged: _toggleLocationTracking,
                activeColor: AppColors.brandPrimary,
              ),
            ],
          ),

          if (!_isTrackingEnabled) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.semanticWarning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.semanticWarning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(
                    Icons.warning_outlined,
                    color: AppColors.semanticWarning,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(context)!.locationTrackingDisabledWarning,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusCard() {
    if (_trackingStatus == null) return const SizedBox.shrink();

    final status = _trackingStatus!;
    final lastPosition = status['lastKnownPosition'];
    final lastUpdate = status['lastUpdateTime'];
    final isMonitoring = status['isMonitoring'] ?? false;

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.trackingStatus,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _buildStatusRow(
            Icons.radar,
            AppLocalizations.of(context)!.monitoringStatus,
            isMonitoring
                ? AppLocalizations.of(context)!.active
                : AppLocalizations.of(context)!.inactive,
            isMonitoring ? AppColors.brandPrimary : AppColors.textSecondary,
          ),

          if (lastPosition != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow(
              Icons.pin_drop,
              AppLocalizations.of(context)!.lastKnownLocation,
              '${lastPosition['latitude'].toStringAsFixed(4)}, ${lastPosition['longitude'].toStringAsFixed(4)}',
              AppColors.textSecondary,
            ),
          ],

          if (lastUpdate != null) ...[
            const SizedBox(height: 12),
            _buildStatusRow(
              Icons.update,
              AppLocalizations.of(context)!.lastLocationUpdate,
              _formatDateTime(DateTime.parse(lastUpdate)),
              AppColors.textSecondary,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusRow(IconData icon, String label, String value, Color valueColor) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.textSecondary),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: valueColor,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildTechnicalDetailsCard() {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            AppLocalizations.of(context)!.howItWorks,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          _buildDetailRow(Icons.track_changes, AppLocalizations.of(context)!.movementThreshold, '1 km'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.timer, AppLocalizations.of(context)!.updateFrequency, '10 minutes max'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.battery_saver, AppLocalizations.of(context)!.batteryImpact, '<3% drain'),
          const SizedBox(height: 12),
          _buildDetailRow(Icons.shield, AppLocalizations.of(context)!.dataPrivacy, 'Device only'),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.brandPrimary),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: AppColors.textPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Future<void> _toggleLocationTracking(bool enabled) async {
    try {
      if (enabled) {
        // Check current permission status using geolocator consistently
        final currentPermission = await Geolocator.checkPermission();
        print('LocationTracking UI: Current permission: $currentPermission');

        // Always show explanation dialog for background tracking
        final userConsent = await _showPermissionDialog();
        if (!userConsent) {
          await _loadTrackingStatus();
          return;
        }

        // Request background location permission if needed
        if (currentPermission != LocationPermission.always) {
          print('LocationTracking UI: Requesting background permission...');
          final newPermission = await Geolocator.requestPermission();
          print('LocationTracking UI: Permission result: $newPermission');

          if (newPermission != LocationPermission.always) {
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    newPermission == LocationPermission.whileInUse
                        ? 'Background location access is required. Please grant "Allow all the time" in settings.'
                        : AppLocalizations.of(context)!.locationPermissionRequired,
                  ),
                  backgroundColor: AppColors.semanticError,
                  action: SnackBarAction(
                    label: 'Settings',
                    onPressed: () => Geolocator.openAppSettings(),
                    textColor: Colors.white,
                  ),
                ),
              );
            }
            await _loadTrackingStatus();
            return;
          }
        }
      }

      // Clear any cached states and update tracking
      print('LocationTracking UI: Setting tracking to: $enabled');
      await locationTrackingService.setTrackingEnabled(enabled);

      // Give service time to initialize if enabling
      if (enabled) {
        await Future.delayed(const Duration(milliseconds: 500));
      }

      // Force refresh status from service
      await _loadTrackingStatus();

      // Verify the state change took effect
      final actualEnabled = await locationTrackingService.isTrackingEnabled();
      print('LocationTracking UI: Final verification - enabled: $actualEnabled');

      if (actualEnabled != enabled) {
        print('LocationTracking UI: WARNING - State mismatch detected!');
        await _loadTrackingStatus(); // Refresh again
      }

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              enabled
                  ? AppLocalizations.of(context)!.locationTrackingEnabled
                  : AppLocalizations.of(context)!.locationTrackingDisabled,
            ),
            backgroundColor: AppColors.info,
          ),
        );
      }
    } catch (e) {
      print('Error toggling location tracking: $e');
      await _loadTrackingStatus();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Location tracking toggle failed: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  Future<bool> _showPermissionDialog() async {
    return await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: Text(
          'Background Location Permission Required',
          style: const TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'To enable background tracking, you must grant "Allow all the time" location permission.',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.warning.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.warning.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline, color: AppColors.warning, size: 18),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'When Android asks for location permission, select "Allow all the time" not "While using app".',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.brandPrimary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.brandPrimary.withOpacity(0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.check_circle, color: AppColors.brandPrimary, size: 18),
                      const SizedBox(width: 8),
                      Text(
                        AppLocalizations.of(context)!.benefitsTitle,
                        style: const TextStyle(
                          color: AppColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    AppLocalizations.of(context)!.locationTrackingBenefits,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 13,
                      height: 1.3,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: AppColors.darkBackground,
            ),
            child: Text('Request "Allow All The Time"'),
          ),
        ],
      ),
    ) ?? false;
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
      return AppLocalizations.of(context)!.justNow;
    } else if (difference.inHours < 1) {
      return AppLocalizations.of(context)!.minutesAgo(difference.inMinutes);
    } else if (difference.inDays < 1) {
      return AppLocalizations.of(context)!.hoursAgo(difference.inHours);
    } else {
      return AppLocalizations.of(context)!.daysAgo(difference.inDays);
    }
  }
}