import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compass_data.dart';
import '../../models/pilot_data.dart';
import '../../services/compass_service.dart';
import '../../theme/app_theme.dart';
import '../../l10n/generated/app_localizations.dart';
import '../../widgets/compass/compass_display.dart';
import '../../widgets/compass/compass_info.dart';
import '../../widgets/compass/pilot_compass_display.dart';
import '../../widgets/compass/pilot_info.dart';
import '../../widgets/compass/ar_overlay.dart';

enum CompassMode {
  standard,
  pilot,
}

enum CompassView {
  compass,
  ar,
}

class CompassScreen extends ConsumerStatefulWidget {
  const CompassScreen({super.key});

  @override
  ConsumerState<CompassScreen> createState() => _CompassScreenState();
}

class _CompassScreenState extends ConsumerState<CompassScreen> {
  CompassMode _mode = CompassMode.standard;
  CompassView _view = CompassView.compass;
  CompassTarget? _currentTarget;
  bool _isServiceStarted = false;

  @override
  void initState() {
    super.initState();
    _initializeCompass();
  }

  @override
  void dispose() {
    // Only try to stop the service if we're still mounted and the provider is still available
    try {
      if (mounted) {
        final service = ref.read(compassServiceProvider);
        service.stopListening();
      }
    } catch (e) {
      // Ignore errors during disposal - provider may already be disposed
      debugPrint('Error stopping compass service during disposal: $e');
    }
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    try {
      if (!mounted) return; // Early exit if widget is disposed
      
      final service = ref.read(compassServiceProvider);
      await service.startListening();
      
      if (mounted) { // Check mount status before setState
        setState(() {
          _isServiceStarted = true;
          _currentTarget = service.getMockTarget(); // Demo target
        });
      }
    } catch (e) {
      debugPrint('Failed to start compass service: $e');
      // Show error to user
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to access sensors: $e'),
            backgroundColor: AppColors.semanticError,
          ),
        );
      }
    }
  }

  void _showModeSettings() {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              l10n.compassMode,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 20),
            
            ListTile(
              leading: Icon(
                Icons.explore,
                color: _mode == CompassMode.standard 
                    ? AppColors.brandPrimary 
                    : AppColors.textTertiary,
              ),
              title: Text(
                l10n.compassStandardMode,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                l10n.compassStandardDescription,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              trailing: _mode == CompassMode.standard
                  ? Icon(Icons.check, color: AppColors.brandPrimary)
                  : null,
              onTap: () {
                setState(() {
                  _mode = CompassMode.standard;
                });
                Navigator.pop(context);
              },
            ),
            
            ListTile(
              leading: Icon(
                Icons.flight,
                color: _mode == CompassMode.pilot 
                    ? AppColors.brandPrimary 
                    : AppColors.textTertiary,
              ),
              title: Text(
                l10n.compassPilotMode,
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: Text(
                l10n.compassPilotDescription,
                style: TextStyle(color: AppColors.textSecondary),
              ),
              trailing: _mode == CompassMode.pilot
                  ? Icon(Icons.check, color: AppColors.brandPrimary)
                  : null,
              onTap: () {
                setState(() {
                  _mode = CompassMode.pilot;
                });
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final compassDataAsync = ref.watch(compassDataProvider);
    final l10n = AppLocalizations.of(context);
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('${l10n.compassTitle} - ${_mode == CompassMode.standard ? l10n.compassStandardMode : l10n.compassPilotMode}'),
        actions: [
          // Toggle between compass and AR view
          IconButton(
            icon: Icon(_view == CompassView.compass ? Icons.view_in_ar : Icons.explore),
            onPressed: () {
              setState(() {
                _view = _view == CompassView.compass 
                    ? CompassView.ar 
                    : CompassView.compass;
              });
            },
            tooltip: _view == CompassView.compass ? l10n.compassArView : l10n.compassCompassView,
          ),
          
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showModeSettings,
            tooltip: l10n.compassSettings,
          ),
        ],
      ),
      body: compassDataAsync.when(
        data: (compassData) => _buildCompassContent(compassData),
        loading: () => _buildLoadingState(),
        error: (error, stack) => _buildErrorState(error),
      ),
    );
  }

  Widget _buildCompassContent(CompassData compassData) {
    if (_mode == CompassMode.pilot) {
      return _buildPilotModeContent(compassData);
    }

    if (_view == CompassView.ar) {
      return SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              AROverlay(
                compassData: compassData,
                target: _currentTarget,
                isEnabled: false, // AR functionality not implemented yet
              ),
              const SizedBox(height: 16),
              CompassInfo(
                compassData: compassData,
                target: _currentTarget,
              ),
            ],
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Main Compass Display
            CompassDisplay(
              compassData: compassData,
              target: _currentTarget,
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.my_location,
                  label: 'Center',
                  onTap: () {
                    // TODO: Center on current location
                  },
                ),
                _buildQuickAction(
                  icon: Icons.navigation,
                  label: 'Navigate',
                  onTap: _currentTarget != null ? () {
                    // TODO: Start navigation to target
                  } : null,
                ),
                _buildQuickAction(
                  icon: Icons.refresh,
                  label: 'Calibrate',
                  onTap: () {
                    _showCalibrationDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Compass Information
            CompassInfo(
              compassData: compassData,
              target: _currentTarget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPilotModeContent(CompassData compassData) {
    final service = ref.read(compassServiceProvider);
    final pilotData = service.getMockPilotData();
    
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Pilot Compass Display
            PilotCompassDisplay(
              pilotData: pilotData,
              target: _currentTarget,
            ),
            
            const SizedBox(height: 24),
            
            // Quick Actions (pilot specific)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildQuickAction(
                  icon: Icons.gps_fixed,
                  label: 'Direct',
                  onTap: _currentTarget != null ? () {
                    // TODO: Set direct course to target
                  } : null,
                ),
                _buildQuickAction(
                  icon: Icons.trending_up,
                  label: 'Vector',
                  onTap: _currentTarget != null ? () {
                    // TODO: Calculate intercept vector
                  } : null,
                ),
                _buildQuickAction(
                  icon: Icons.air,
                  label: 'Wind',
                  onTap: () {
                    _showWindDialog();
                  },
                ),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Pilot Information
            PilotInfo(
              pilotData: pilotData,
              target: _currentTarget,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: onTap != null ? AppColors.brandPrimary : AppColors.textTertiary,
              size: 24,
            ),
            const SizedBox(height: 8),
            Text(
              label,
              style: TextStyle(
                color: onTap != null ? AppColors.textPrimary : AppColors.textTertiary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    final service = ref.read(compassServiceProvider);
    final mockData = service.getMockCompassData();
    
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  CompassDisplay(
                    compassData: mockData,
                    target: _currentTarget,
                  ),
                  const SizedBox(height: 24),
                  Card(
                    color: AppColors.darkSurface,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          CircularProgressIndicator(
                            color: AppColors.brandPrimary,
                            strokeWidth: 2,
                          ),
                          const SizedBox(width: 16),
                          const Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Initializing Compass...',
                                  style: TextStyle(
                                    color: AppColors.textPrimary,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Accessing magnetometer and GPS sensors',
                                  style: TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
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

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.semanticError,
            ),
            const SizedBox(height: 16),
            const Text(
              'Compass Unavailable',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to access compass sensors: ${error.toString()}',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _initializeCompass,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  void _showCalibrationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Calibrate Compass',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.rotate_right,
              size: 48,
              color: AppColors.brandPrimary,
            ),
            const SizedBox(height: 16),
            const Text(
              'To improve compass accuracy:\n\n'
              '1. Hold device away from metal objects\n'
              '2. Move device in figure-8 pattern\n'
              '3. Rotate in all directions\n'
              '4. Complete 3-4 full rotations',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  void _showWindDialog() {
    final service = ref.read(compassServiceProvider);
    final pilotData = service.getMockPilotData();
    final wind = pilotData.wind;
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Wind Information',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.air,
              size: 48,
              color: AppColors.semanticInfo,
            ),
            const SizedBox(height: 16),
            
            if (wind != null) ...[
              Text(
                'Current Wind:',
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                wind.formattedWind,
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Component for current heading:',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              Text(
                wind.getWindComponent(pilotData.compass.trueHeading),
                style: TextStyle(
                  color: AppColors.semanticInfo,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Source: ${wind.accuracy.displayName}',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 12,
                ),
              ),
            ] else ...[
              const Text(
                'No wind data available',
                style: TextStyle(color: AppColors.textSecondary),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}