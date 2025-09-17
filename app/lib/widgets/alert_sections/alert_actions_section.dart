import 'dart:convert';
import 'package:flutter/material.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../glass_card.dart';
import '../../services/permission_service.dart';
import '../../services/api_client.dart';
import '../../services/beep_service.dart';
import '../../services/sound_service.dart';
import '../../l10n/app_localizations.dart';

// Helper function to safely convert dynamic values to Map for bracket access
Map<String, dynamic> _asJsonMap(dynamic v) {
  if (v == null) return {};
  if (v is Map<String, dynamic>) return v;
  if (v is Map) return v.map((k, val) => MapEntry(k.toString(), val));
  if (v is List) {
    // Turn list into a map with numeric keys, so any ['x'] access will visibly fail early.
    return {
      "_type": "List",
      "length": v.length,
      "0": v.isNotEmpty ? v[0] : null,
    };
  }
  if (v is String && v.trim().startsWith('{')) {
    try { 
      return Map<String, dynamic>.from(jsonDecode(v)); 
    } catch (_) {}
  }
  return {"_type": v.runtimeType.toString(), "value": v.toString()};
}

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
    return GlassCard(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(
                Icons.touch_app,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
            ],
          ),
          Text(
            AppLocalizations.of(context)!.actionsTitle,
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
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
                label: Text(AppLocalizations.of(context)!.addPhotosAndVideos),
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
                label: Text(AppLocalizations.of(context)!.howToReportToMufon),
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
          child: OutlinedButton.icon(
            onPressed: _isConfirming ? null : _confirmWitness,
            icon: _isConfirming 
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                    ),
                  )
                : const Icon(Icons.visibility, size: 18),
            label: Text(_isConfirming 
                ? AppLocalizations.of(context)!.processing 
                : AppLocalizations.of(context)!.iSeeItToo),
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
        if (witnessCount > 1) ...[
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.witnessesHaveConfirmed(witnessCount),
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
                Text(
                  '✅ ${AppLocalizations.of(context)!.confirmedWitness}',
                  style: const TextStyle(
                    color: AppColors.semanticSuccess,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (witnessCount > 1)
                  Text(
                    AppLocalizations.of(context)!.witnessesHaveConfirmed(witnessCount),
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
      final deviceId = await beepService.getOrCreateDeviceId();

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
        // SAFE ACCESS: Use defensive helper to prevent List-as-Map errors
        final resultMap = _asJsonMap(result);
        final dataMap = _asJsonMap(resultMap['data']);
        
        // Check if result was a List instead of expected Map
        if (resultMap["_type"] == "List") {
          throw StateError("Witness API returned a List in result; expected JSON object");
        }
        
        final newWitnessCount = dataMap['witness_count'] as int? ?? _witnessCount + 1;
        setState(() {
          _hasConfirmed = true;
          _witnessCount = newWitnessCount;
        });

        // Notify parent
        widget.onWitnessConfirmed?.call(newWitnessCount);

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ ${AppLocalizations.of(context)!.confirmedWitness} (${AppLocalizations.of(context)!.witnessesHaveConfirmed(newWitnessCount)})'),
            backgroundColor: AppColors.semanticSuccess,
            duration: const Duration(seconds: 2),
          ),
        );

        // Play success sound
        await SoundService.I.play(AlertSound.tap);

        // If escalation was triggered, play appropriate sound
        final escalationTriggered = dataMap['escalation_triggered'] as bool? ?? false;
        if (escalationTriggered == true) {
          final witnessCount = dataMap['witness_count'] as int? ?? 0;
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
        title: Text(
          AppLocalizations.of(context)!.locationPermissionTitle,
          style: const TextStyle(color: AppColors.textPrimary),
        ),
        content: Text(
          AppLocalizations.of(context)!.locationPermissionBody,
          style: const TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(color: AppColors.textTertiary),
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
            child: Text(AppLocalizations.of(context)!.openSettings),
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
    debugPrint('DEBUG: _isOriginalCreator check');
    debugPrint('DEBUG: currentUserDeviceId: "${widget.currentUserDeviceId}"');
    debugPrint('DEBUG: alert.reporterId: "${widget.alert.reporterId}"');

    if (widget.currentUserDeviceId == null ||
        widget.alert.reporterId == null ||
        widget.alert.reporterId!.isEmpty) {
      debugPrint('DEBUG: One of the IDs is null/empty, returning false');
      return false;
    }
    
    final isCreator = widget.currentUserDeviceId == widget.alert.reporterId;
    debugPrint('DEBUG: isCreator result: $isCreator');
    return isCreator;
  }
}
