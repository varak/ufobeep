import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/compass_data.dart';
import '../../services/compass_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/compass/compass_display.dart';
import '../../widgets/compass/compass_info.dart';
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
    final service = ref.read(compassServiceProvider);
    service.stopListening();
    super.dispose();
  }

  Future<void> _initializeCompass() async {
    try {
      final service = ref.read(compassServiceProvider);
      await service.startListening();
      setState(() {
        _isServiceStarted = true;
        _currentTarget = service.getMockTarget(); // Demo target
      });
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
            const Text(
              'Compass Mode',
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
              title: const Text(
                'Standard Mode',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Basic heading and navigation',
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
              title: const Text(
                'Pilot Mode',
                style: TextStyle(color: AppColors.textPrimary),
              ),
              subtitle: const Text(
                'Advanced navigation features (Task 14)',
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Pilot Mode will be available in Task 14'),
                  ),
                );
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
    
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        title: Text('Compass - ${_mode == CompassMode.standard ? 'Standard' : 'Pilot'} Mode'),
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
            tooltip: _view == CompassView.compass ? 'AR View' : 'Compass View',
          ),
          
          // Settings
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: _showModeSettings,
            tooltip: 'Compass Settings',
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
}