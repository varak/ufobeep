import 'package:flutter/material.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/sound_service.dart';

class AlertWitnessSection extends StatefulWidget {
  const AlertWitnessSection({
    super.key,
    required this.alert,
    this.onWitnessConfirmed,
  });

  final Alert alert;
  final Function(int witnessCount)? onWitnessConfirmed;

  @override
  State<AlertWitnessSection> createState() => _AlertWitnessSectionState();
}

class _AlertWitnessSectionState extends State<AlertWitnessSection> {
  bool _isConfirming = false;
  bool? _hasConfirmed;
  int _witnessCount = 0;

  @override
  void initState() {
    super.initState();
    _witnessCount = widget.alert.witnessCount;
    // Skip witness status check for now - it's causing hangs
    // _checkWitnessStatus();
  }

  Future<void> _confirmWitness() async {
    if (_isConfirming || _hasConfirmed == true) return;

    setState(() {
      _isConfirming = true;
    });

    try {
      // Check location permission
      if (!permissionService.locationGranted) {
        await permissionService.refreshPermissions();
        if (!permissionService.locationGranted) {
          _showPermissionDialog();
          return;
        }
      }

      // Get current location
      final position = await permissionService.getCurrentLocation();
      if (position == null) {
        _showLocationError();
        return;
      }

      // Play confirmation sound
      await SoundService.I.play(AlertSound.tap, haptic: true);

      // Get device ID
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();

      // Confirm witness
      final result = await ApiClient.instance.confirmWitness(
        sightingId: widget.alert.id,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        stillVisible: true,
      );

      if (mounted) {
        final newWitnessCount = result['data']['witness_count'] ?? _witnessCount + 1;
        setState(() {
          _hasConfirmed = true;
          _witnessCount = newWitnessCount;
        });

        // Notify parent
        widget.onWitnessConfirmed?.call(newWitnessCount);

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Witness confirmation recorded! ($newWitnessCount total witnesses)'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );

        // Play success sound
        await SoundService.I.play(AlertSound.tap);

        // If escalation was triggered, play appropriate sound
        if (result['data']['escalation_triggered'] == true) {
          final witnessCount = result['data']['witness_count'] ?? 0;
          if (witnessCount >= 10) {
            await SoundService.I.play(AlertSound.emergency, haptic: true);
          } else if (witnessCount >= 3) {
            await SoundService.I.play(AlertSound.urgent);
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to confirm witness: ${e.toString()}'),
            backgroundColor: AppColors.semanticError,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isConfirming = false;
        });
      }
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          'Location Required',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'UFOBeep needs your location to confirm you as a witness. Please grant location permission in Settings.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.textTertiary),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              permissionService.openPermissionSettings();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  void _showLocationError() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Unable to get your location. Please ensure GPS is enabled.'),
        backgroundColor: AppColors.semanticWarning,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final witnessCount = _witnessCount > 0 ? _witnessCount : widget.alert.witnessCount;
    
    if (_hasConfirmed == true) {
      // Already confirmed - show status
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.semanticSuccess.withOpacity(0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
        ),
        child: Row(
          children: [
            const Icon(
              Icons.check_circle,
              size: 24,
              color: AppColors.semanticSuccess,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '✅ You confirmed this sighting',
                    style: TextStyle(
                      color: AppColors.semanticSuccess,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (witnessCount > 1)
                    Text(
                      '$witnessCount people have confirmed this sighting',
                      style: const TextStyle(
                        color: AppColors.semanticSuccess,
                        fontSize: 14,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Show confirmation button with witness count below (if > 1)
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.brandPrimary.withOpacity(0.3),
                blurRadius: 15,
                spreadRadius: 2,
              ),
            ],
          ),
          child: SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _isConfirming ? null : _confirmWitness,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.brandPrimary,
                foregroundColor: Colors.black,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              child: _isConfirming
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                          ),
                        ),
                        SizedBox(width: 12),
                        Text(
                          'Confirming witness...',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    )
                  : const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.visibility,
                          size: 20,
                          color: Colors.black,
                        ),
                        SizedBox(width: 12),
                        Text(
                          'I SEE IT TOO!',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
        if (witnessCount > 1) ...[
          const SizedBox(height: 8),
          Text(
            '$witnessCount people have confirmed this sighting',
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );
  }
}