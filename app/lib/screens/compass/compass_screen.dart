import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

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
  const CompassScreen({
    super.key,
    this.targetLat,
    this.targetLon,
    this.targetName,
    this.targetBearing,
    this.targetDistance,
    this.alertId,
  });

  final double? targetLat;
  final double? targetLon;
  final String? targetName;
  final double? targetBearing;
  final double? targetDistance;
  final String? alertId;

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
          // Only use target if provided - no mock data
          if (widget.targetLat != null && widget.targetLon != null) {
            _currentTarget = CompassTarget(
              id: widget.alertId ?? 'sighting_target',
              name: widget.targetName ?? 'UFO Sighting',
              location: LocationData(
                latitude: widget.targetLat!,
                longitude: widget.targetLon!,
                accuracy: 10.0, // Default accuracy for sighting location
                timestamp: DateTime.now(),
              ),
              distance: widget.targetDistance != null ? widget.targetDistance! * 1000 : null, // Convert km to meters
            );
          } else {
            _currentTarget = null; // No fake data
          }
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
        title: Text('Orient - ${_mode == CompassMode.standard ? 'Standard' : 'Pilot Mode'}'),
        leading: widget.targetLat != null ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ) : null,
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
            // Show explanation if no target, otherwise show compass
            if (_currentTarget == null)
              _buildCompassExplanation()
            else ...[
              // Main Compass Display
              CompassDisplay(
                compassData: compassData,
                target: _currentTarget,
              ),
              
              const SizedBox(height: 24),
              
              // Clear user instructions
              if (_currentTarget != null && (widget.targetLat != null && widget.targetLon != null))
                _buildClearInstructions(),
              
              const SizedBox(height: 16),
              
              // Compass Information
              CompassInfo(
                compassData: compassData,
                target: _currentTarget,
              ),
            ],
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
            
            // Clear pilot instructions  
            if (_currentTarget != null && (widget.targetLat != null && widget.targetLon != null))
              _buildClearPilotInstructions(pilotData),
            
            const SizedBox(height: 16),
            
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


  Widget _buildCompassExplanation() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Compass icon
          Container(
            width: 120,
            height: 120,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  AppColors.brandPrimary.withOpacity(0.2),
                  AppColors.brandPrimary.withOpacity(0.05),
                  Colors.transparent,
                ],
              ),
            ),
            child: const Icon(
              Icons.explore,
              size: 60,
              color: AppColors.brandPrimary,
            ),
          ),
          
          const SizedBox(height: 32),
          
          const Text(
            'Sighting Direction Compass',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 16),
          
          const Text(
            'When you get an alert, this compass shows you exactly where to look in the sky. Go outside and line up the red and blue arrows.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 16,
              height: 1.5,
            ),
          ),
          
          const SizedBox(height: 24),
          
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
            ),
            child: const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'How it works:',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 12),
                Text(
                  '1. Go outside and hold your phone flat\n'
                  '2. Line up the red and blue arrows on the compass\n'
                  '3. Look around the whole sky in that direction\n'
                  '4. This shows where the witness was relative to you',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Tap "Navigate" on any alert to use the compass',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 14,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
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
                                  'Accessing sensors (some tablets may not support compass)',
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



  Widget _buildClearInstructions() {
    final target = _currentTarget;
    if (target == null) return const SizedBox();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.navigation, color: AppColors.brandPrimary, size: 24),
              SizedBox(width: 12),
              Text(
                'How to Look',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          const Text(
            '1. Go outside and line up the red and blue arrows',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '2. You\'ll be looking in the direction of the sighting',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            '3. Be sure to look around the whole sky',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (target.distance != null) ...[
                  Text(
                    'Distance: ${target.formattedDistance}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                const Text(
                  'This shows where the witness was when they saw something, relative to your location.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildClearPilotInstructions(PilotNavigationData pilotData) {
    final target = _currentTarget;
    if (target == null) return const SizedBox();

    final bearingToTarget = widget.targetBearing ?? 0.0;
    final currentHeading = pilotData.compass.trueHeading;
    final headingChange = ((bearingToTarget - currentHeading + 360) % 360);
    
    String turnDirection = headingChange <= 180 ? 'right' : 'left';
    double turnDegrees = headingChange <= 180 ? headingChange : 360 - headingChange;
    
    String direction = 'North';
    if (bearingToTarget >= 337.5 || bearingToTarget < 22.5) direction = 'N';
    else if (bearingToTarget < 67.5) direction = 'NE';
    else if (bearingToTarget < 112.5) direction = 'E';
    else if (bearingToTarget < 157.5) direction = 'SE';
    else if (bearingToTarget < 202.5) direction = 'S';
    else if (bearingToTarget < 247.5) direction = 'SW';
    else if (bearingToTarget < 292.5) direction = 'W';
    else direction = 'NW';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.semanticInfo.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.semanticInfo.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.flight, color: AppColors.semanticInfo, size: 24),
              SizedBox(width: 12),
              Text(
                'Pilot Navigation',
                style: TextStyle(
                  color: AppColors.semanticInfo,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          Text(
            'Fly heading ${bearingToTarget.toStringAsFixed(0)}° $direction',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Turn $turnDirection ${turnDegrees.toStringAsFixed(0)}° to intercept',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          
          const SizedBox(height: 16),
          
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.darkBackground.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (target.distance != null) ...[
                  Text(
                    'Distance: ${target.formattedDistance}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                if (pilotData.wind != null) ...[
                  Text(
                    'Wind: ${pilotData.wind!.formattedWind}',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                const Text(
                  'This heading leads to the witness location where the sighting was reported.',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.3,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

}