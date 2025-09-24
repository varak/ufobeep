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
import 'package:geolocator/geolocator.dart';

// Helper function to safely convert dynamic values to Map for bracket access

int? _safeInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is String) return int.tryParse(value);
  if (value is double) return value.toInt();
  return null;
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
    this.currentUsername,
  });

  final Alert alert;
  final VoidCallback? onAddPhotos;
  final VoidCallback? onReportToMufon;
  final Function(int witnessCount)? onWitnessConfirmed;
  final bool showAllActions;
  final String? currentUserDeviceId;
  final String? currentUsername;

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
          
          // Witness confirmation button (primary action if not confirmed and not creator and within time+proximity window)
          if (_hasConfirmed != true && !_isOriginalCreator() && _isWithinConfirmationWindow() && _isWithinProximity()) ...[
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
      print('DEBUG: Calling confirmWitness API...');
      print('DEBUG: sightingId=${widget.alert.id}, deviceId=$deviceId');
      print('DEBUG: lat=${position.latitude}, lon=${position.longitude}');

      final result = await ApiClient.instance.confirmWitness(
        sightingId: widget.alert.id,
        deviceId: deviceId,
        latitude: position.latitude,
        longitude: position.longitude,
        accuracy: position.accuracy,
        altitude: position.altitude,
        stillVisible: true,
      );

      print('DEBUG: API returned result type: ${result.runtimeType}');
      print('DEBUG: API result: $result');

      if (mounted) {
        // Ensure result is a proper Map
        if (result is! Map<String, dynamic>) {
          throw StateError("Witness API returned unexpected data type: ${result.runtimeType}");
        }

        final resultMap = result as Map<String, dynamic>;

        // Check if we have data field and it's a Map
        final data = resultMap['data'];
        if (data is! Map<String, dynamic>) {
          throw StateError("Witness API data field is not a Map: ${data.runtimeType}");
        }

        final dataMap = data as Map<String, dynamic>;
        final newWitnessCount = _safeInt(dataMap['witness_count']) ?? _witnessCount + 1;
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
          final witnessCount = _safeInt(dataMap['witness_count']) ?? 0;
          if (witnessCount >= 10) {
            await SoundService.I.play(AlertSound.emergency, haptic: true);
          } else if (witnessCount >= 3) {
            await SoundService.I.play(AlertSound.urgent);
          }
        }
      }
    } catch (e, stackTrace) {
      // Log FULL error details
      print('==== WITNESS CONFIRMATION ERROR ====');
      print('Error type: ${e.runtimeType}');
      print('Error message: $e');
      print('Stack trace:');
      print(stackTrace);

      // Try to extract more detail if it's a DioException
      if (e.toString().contains('DioException')) {
        print('DioException details available');
      }

      // Log the actual error details to help debugging
      final errorMessage = e.toString();
      print('Full error string: "$errorMessage"');

      // Check for specific error patterns
      if (errorMessage.contains('type \'String\' is not a subtype')) {
        print('TYPE ERROR DETECTED - String/int mismatch');
        print('This is likely happening in the API response parsing');
      }

      if (mounted) {
        // Extract clean error message from ApiClientException
        String displayMessage = 'Failed to confirm witness';
        if (e.toString().contains('ApiClientException:')) {
          // Extract the actual error message after "ApiClientException: "
          final fullMessage = e.toString();
          final colonIndex = fullMessage.indexOf('ApiClientException: ');
          if (colonIndex != -1) {
            displayMessage = fullMessage.substring(colonIndex + 'ApiClientException: '.length);
          }
        } else {
          displayMessage = e.toString();
        }

        // Check if this is the 60-minute window error and show helpful dialog
        if (displayMessage.toLowerCase().contains('confirmation window has closed') ||
            displayMessage.toLowerCase().contains('60 minutes')) {
          _showTimeExpiredDialog();
        } else {
          // For other errors, show snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(displayMessage),
              backgroundColor: AppColors.semanticError,
              duration: const Duration(seconds: 5),
            ),
          );
        }
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

  void _showTimeExpiredDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.darkSurface,
        title: const Text(
          '⏰ Too Late to Confirm',
          style: TextStyle(color: AppColors.textPrimary),
        ),
        content: const Text(
          'You can only confirm sightings within 60 minutes of when they occurred.\n\nIf you\'re seeing something similar right now, use the beep button to create a new sighting.',
          style: TextStyle(color: AppColors.textSecondary),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandPrimary,
              foregroundColor: Colors.black,
            ),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }

  /// Check if alert is within 60-minute confirmation window
  bool _isWithinConfirmationWindow() {
    final now = DateTime.now();
    final alertTime = widget.alert.createdAt;
    final timeDifference = now.difference(alertTime);
    return timeDifference.inMinutes <= 60;
  }

  /// Check if user is within proximity to witness the sighting (50km radius)
  bool _isWithinProximity() {
    final userLocation = permissionService.cachedLocation;
    if (userLocation == null) return false;

    final distanceInMeters = Geolocator.distanceBetween(
      userLocation.latitude,
      userLocation.longitude,
      widget.alert.latitude,
      widget.alert.longitude,
    );

    final distanceInKm = distanceInMeters / 1000;
    return distanceInKm <= 50; // 50km radius for witness confirmation
  }

  /// Check if current user is the original creator of this alert
  bool _isOriginalCreator() {
    debugPrint('DEBUG: _isOriginalCreator check');
    debugPrint('DEBUG: currentUsername: "${widget.currentUsername}"');
    debugPrint('DEBUG: alert.username: "${widget.alert.username}"');

    // Primary method: Compare usernames (most reliable)
    if (widget.currentUsername != null && widget.alert.username != null) {
      final isCreatorByUsername = widget.currentUsername == widget.alert.username;
      debugPrint('DEBUG: isCreator by username: $isCreatorByUsername');
      return isCreatorByUsername;
    }

    // Fallback method: Compare device/reporter IDs
    debugPrint('DEBUG: Fallback to ID comparison');
    debugPrint('DEBUG: currentUserDeviceId: "${widget.currentUserDeviceId}"');
    debugPrint('DEBUG: alert.reporterId: "${widget.alert.reporterId}"');

    if (widget.currentUserDeviceId == null ||
        widget.alert.reporterId == null ||
        widget.alert.reporterId!.isEmpty) {
      debugPrint('DEBUG: One of the IDs is null/empty, returning false');
      return false;
    }

    final isCreatorById = widget.currentUserDeviceId == widget.alert.reporterId;
    debugPrint('DEBUG: isCreator by ID: $isCreatorById');
    return isCreatorById;
  }
}
