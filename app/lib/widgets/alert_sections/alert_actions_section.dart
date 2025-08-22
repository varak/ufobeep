import 'package:flutter/material.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/anonymous_beep_service.dart';
import '../../services/sound_service.dart';

class AlertActionsSection extends StatefulWidget {
  const AlertActionsSection({
    super.key,
    required this.alert,
    this.onAddPhotos,
    this.onReportToMufon,
    this.onWitnessConfirmed,
    this.showAllActions = true,
    this.currentUserDeviceId,
  });

  final Alert alert;
  final VoidCallback? onAddPhotos;
  final VoidCallback? onReportToMufon;
  final Function(int witnessCount)? onWitnessConfirmed;
  final bool showAllActions;
  final String? currentUserDeviceId;

  @override
  State<AlertActionsSection> createState() => _AlertActionsSectionState();
}

class _AlertActionsSectionState extends State<AlertActionsSection> {
  bool _isConfirming = false;
  bool? _hasConfirmed;
  int _witnessCount = 0;

  @override
  void initState() {
    super.initState();
    _witnessCount = widget.alert.witnessCount;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.darkBorder.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.touch_app,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Actions',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          
          // Witness confirmation button (primary action if not confirmed and not creator)
          if (_hasConfirmed != true && !_isOriginalCreator()) ...[
            _buildWitnessButton(),
            const SizedBox(height: 12),
          ] else if (_hasConfirmed == true) ...[
            _buildConfirmedStatus(),
            const SizedBox(height: 12),
          ],
          
          if (widget.showAllActions) ...[
            const SizedBox(height: 12),
            
            // Add Photos button (tertiary action)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onAddPhotos,
                icon: const Icon(Icons.add_photo_alternate, size: 18),
                label: const Text('Add Photos & Videos'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            
            const SizedBox(height: 12),
            
            // Report to MUFON button (quaternary action)
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: widget.onReportToMufon,
                icon: const Icon(Icons.report_outlined, size: 18),
                label: const Text('Report to MUFON'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildWitnessButton() {
    final witnessCount = _witnessCount > 0 ? _witnessCount : widget.alert.witnessCount;
    
    return Column(
      children: [
        SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed: _isConfirming ? null : _confirmWitness,
            icon: _isConfirming 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  )
                : const Icon(Icons.visibility, size: 18, color: Colors.black),
            label: Text(_isConfirming ? 'Confirming...' : 'I SEE IT TOO!'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.black,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              textStyle: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
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

  Widget _buildConfirmedStatus() {
    final witnessCount = _witnessCount > 0 ? _witnessCount : widget.alert.witnessCount;
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.semanticSuccess.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(
            Icons.check_circle,
            size: 20,
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (witnessCount > 1)
                  Text(
                    '$witnessCount people have confirmed this sighting',
                    style: const TextStyle(
                      color: AppColors.semanticSuccess,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
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

  /// Check if current user is the original creator of this alert
  bool _isOriginalCreator() {
    print('DEBUG: _isOriginalCreator check');
    print('DEBUG: currentUserDeviceId: "${widget.currentUserDeviceId}"');
    print('DEBUG: alert.reporterId: "${widget.alert.reporterId}"');
    
    if (widget.currentUserDeviceId == null || widget.alert.reporterId == null) {
      print('DEBUG: One of the IDs is null, returning false');
      return false;
    }
    
    final isCreator = widget.currentUserDeviceId == widget.alert.reporterId;
    print('DEBUG: isCreator result: $isCreator');
    return isCreator;
  }
}