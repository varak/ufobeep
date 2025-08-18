import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../providers/alerts_provider.dart';
import '../models/alerts_filter.dart';
import '../services/api_client.dart';
import '../services/anonymous_beep_service.dart';
import '../services/permission_service.dart';
import '../services/sound_service.dart';

class AlertCard extends ConsumerStatefulWidget {
  const AlertCard({
    super.key,
    required this.alert,
    this.showDistance = true,
    this.onTap,
  });

  final Alert alert;
  final bool showDistance;
  final VoidCallback? onTap;

  @override
  ConsumerState<AlertCard> createState() => _AlertCardState();
}

class _AlertCardState extends ConsumerState<AlertCard> {
  bool _isConfirming = false;
  bool? _hasConfirmed;
  int _witnessCount = 0;

  @override
  void initState() {
    super.initState();
    _witnessCount = widget.alert.witnessCount;
    _checkWitnessStatus();
  }

  Future<void> _checkWitnessStatus() async {
    try {
      final deviceId = await anonymousBeepService.getOrCreateDeviceId();
      final status = await ApiClient.instance.getWitnessStatus(
        sightingId: widget.alert.id,
        deviceId: deviceId,
      );
      
      if (mounted) {
        setState(() {
          _hasConfirmed = status['has_confirmed'] ?? false;
          _witnessCount = status['witness_count'] ?? widget.alert.witnessCount;
        });
      }
    } catch (e) {
      // Silently fail - will show confirmation button by default
      print('Failed to check witness status: $e');
    }
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
        setState(() {
          _hasConfirmed = true;
          _witnessCount = result['data']['witness_count'] ?? _witnessCount + 1;
        });

        // Show success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Witness confirmation recorded! (${ _witnessCount} total witnesses)'),
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
        title: const Text('Location Required'),
        content: const Text('UFOBeep needs your location to confirm you as a witness. Please grant location permission in Settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              permissionService.openPermissionSettings();
            },
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

  Widget _buildWitnessConfirmationButton() {
    if (_hasConfirmed == true) {
      // Already confirmed - show status
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppColors.semanticSuccess.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.semanticSuccess.withOpacity(0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              size: 16,
              color: AppColors.semanticSuccess,
            ),
            const SizedBox(width: 8),
            Text(
              'You confirmed this (${ _witnessCount} total)',
              style: const TextStyle(
                color: AppColors.semanticSuccess,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    // Show confirmation button
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isConfirming ? null : _confirmWitness,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.brandPrimary,
          foregroundColor: Colors.black,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: _isConfirming
            ? Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
                    ),
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Confirming...',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.visibility,
                    size: 16,
                    color: Colors.black,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'I SEE IT TOO! ($_witnessCount witnesses)',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getCategoryColor(widget.alert.category).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: widget.onTap ?? () => context.go('/alert/${widget.alert.id}'),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with category icon, title, and verification badge
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Category icon with background
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: _getCategoryColor(widget.alert.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getCategoryIcon(widget.alert.category),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and category name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.alert.title,
                          style: const TextStyle(
                            color: AppColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Text(
                              _getCategoryDisplayName(widget.alert.category),
                              style: TextStyle(
                                color: _getCategoryColor(widget.alert.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (widget.alert.isVerified) ...[
                              const SizedBox(width: 8),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                decoration: BoxDecoration(
                                  color: AppColors.brandPrimary.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: AppColors.brandPrimary.withOpacity(0.3),
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      Icons.verified,
                                      color: AppColors.brandPrimary,
                                      size: 12,
                                    ),
                                    const SizedBox(width: 2),
                                    const Text(
                                      'Verified',
                                      style: TextStyle(
                                        color: AppColors.brandPrimary,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ],
                        ),
                      ],
                    ),
                  ),
                  
                  // Time ago
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        _getTimeAgo(widget.alert.createdAt),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      if (widget.alert.distance != null && widget.showDistance) ...[
                        const SizedBox(height: 4),
                        _buildDistanceBadge(),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description - show only if provided
              if (widget.alert.description != null && widget.alert.description!.isNotEmpty)
                Text(
                  widget.alert.description!,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                    height: 1.4,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              
              const SizedBox(height: 12),
              
              // Phase 1: "I SEE IT TOO" witness confirmation button
              _buildWitnessConfirmationButton(),
              
              // Primary media thumbnail (if available)
              if (widget.alert.hasMedia) ...[
                const SizedBox(height: 12),
                _buildMediaThumbnail(),
              ],
              
              const SizedBox(height: 12),
              
              // Footer with location info and bearing
              Row(
                children: [
                  // Location name and distance info
                  if (widget.alert.locationName != null) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        widget.alert.locationName!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (widget.alert.distance != null && widget.showDistance) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${_getDistanceText()}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ] else if (widget.alert.distance != null && widget.showDistance) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      _getDistanceText(),
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 12,
                      ),
                    ),
                    
                    
                    const Spacer(),
                  ] else
                    const Spacer(),
                  
                  // Action hint
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Tap for details',
                        style: TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 12,
                        color: AppColors.textTertiary,
                      ),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDistanceBadge() {
    if (widget.alert.distance == null) return const SizedBox.shrink();
    
    final distance = widget.alert.distance!;
    Color badgeColor;
    
    if (distance < 1.0) {
      badgeColor = AppColors.semanticError; // Very close - red
    } else if (distance < 5.0) {
      badgeColor = AppColors.semanticWarning; // Close - orange
    } else if (distance < 15.0) {
      badgeColor = AppColors.brandPrimary; // Medium - green
    } else {
      badgeColor = AppColors.textTertiary; // Far - gray
    }
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: badgeColor.withOpacity(0.3)),
      ),
      child: Text(
        '${distance.toStringAsFixed(1)}km',
        style: TextStyle(
          color: badgeColor,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }


  Widget _getCategoryIcon(String category) {
    final categoryData = AlertCategory.getByKey(category);
    
    if (categoryData != null) {
      return Text(
        categoryData.icon,
        style: const TextStyle(fontSize: 16),
      );
    }
    
    // Fallback icons
    IconData icon;
    Color color = AppColors.textSecondary;

    switch (category) {
      case 'ufo':
        icon = Icons.blur_circular;
        color = AppColors.brandPrimary;
        break;
      case 'missing_pet':
        icon = Icons.pets;
        color = AppColors.semanticWarning;
        break;
      case 'missing_person':
        icon = Icons.person;
        color = AppColors.semanticError;
        break;
      case 'suspicious':
        icon = Icons.warning;
        color = AppColors.semanticWarning;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Icon(icon, color: color, size: 16);
  }

  Color _getCategoryColor(String category) {
    final categoryData = AlertCategory.getByKey(category);
    if (categoryData != null) {
      switch (categoryData.color) {
        case 'primary':
          return AppColors.brandPrimary;
        case 'warning':
          return AppColors.semanticWarning;
        case 'error':
          return AppColors.semanticError;
        case 'secondary':
        default:
          return AppColors.textSecondary;
      }
    }

    // Fallback colors
    switch (category) {
      case 'ufo':
        return AppColors.brandPrimary;
      case 'missing_pet':
        return AppColors.semanticWarning;
      case 'missing_person':
        return AppColors.semanticError;
      case 'suspicious':
        return AppColors.semanticWarning;
      default:
        return AppColors.textSecondary;
    }
  }

  String _getCategoryDisplayName(String category) {
    final categoryData = AlertCategory.getByKey(category);
    if (categoryData != null) {
      return categoryData.displayName;
    }

    // Fallback names
    switch (category) {
      case 'ufo':
        return 'UFO Sighting';
      case 'missing_pet':
        return 'Missing Pet';
      case 'missing_person':
        return 'Missing Person';
      case 'suspicious':
        return 'Suspicious Activity';
      default:
        return 'Unknown';
    }
  }

  String _getDistanceText() {
    if (widget.alert.distance == null) return '';
    
    final distance = widget.alert.distance!;
    
    if (distance < 0.1) {
      return '${(distance * 1000).toInt()}m away';
    } else if (distance < 1.0) {
      return '${(distance * 1000).toInt()}m away';
    } else {
      return '${distance.toStringAsFixed(1)}km away';
    }
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()}w ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildMediaThumbnail() {
    final thumbnailUrl = widget.alert.primaryThumbnailUrl;
    if (thumbnailUrl.isEmpty) return const SizedBox.shrink();

    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: AppColors.darkSurface.withOpacity(0.5),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Stack(
          children: [
            // Main image
            Image.network(
              thumbnailUrl,
              height: 120,
              width: double.infinity,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, loadingProgress) {
                if (loadingProgress == null) return child;
                return Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.darkSurface.withOpacity(0.5),
                  child: const Center(
                    child: CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
                      strokeWidth: 2,
                    ),
                  ),
                );
              },
              errorBuilder: (context, error, stackTrace) {
                return Container(
                  height: 120,
                  width: double.infinity,
                  color: AppColors.darkSurface.withOpacity(0.5),
                  child: const Icon(
                    Icons.broken_image,
                    color: AppColors.textTertiary,
                    size: 32,
                  ),
                );
              },
            ),
            
            // Media count overlay (if multiple files)
            if (widget.alert.mediaFiles.length > 1)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.7),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.photo_library,
                        size: 14,
                        color: Colors.white,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        '${widget.alert.mediaFiles.length}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
            // Primary media indicator
            Positioned(
              bottom: 8,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.brandPrimary.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'PRIMARY',
                  style: TextStyle(
                    color: Colors.black,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Compact version for lists where space is limited
class CompactAlertCard extends StatelessWidget {
  const CompactAlertCard({
    super.key,
    required this.alert,
    this.onTap,
  });

  final Alert alert;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      elevation: 1,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
        side: BorderSide(
          color: AppColors.darkBorder.withOpacity(0.3),
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.go('/alert/${alert.id}'),
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              // Category icon
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _getCategoryColor(alert.category).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: _getCategoryIcon(alert.category),
              ),
              
              const SizedBox(width: 12),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      alert.title,
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: [
                        if (alert.distance != null) ...[
                          Icon(
                            Icons.location_on,
                            size: 12,
                            color: AppColors.textTertiary,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${alert.distance!.toStringAsFixed(1)}km',
                            style: const TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                          const Text(
                            ' • ',
                            style: TextStyle(
                              color: AppColors.textTertiary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        Text(
                          _getTimeAgo(alert.createdAt),
                          style: const TextStyle(
                            color: AppColors.textTertiary,
                            fontSize: 12,
                          ),
                        ),
                        if (alert.isVerified) ...[
                          const SizedBox(width: 4),
                          Icon(
                            Icons.verified,
                            color: AppColors.brandPrimary,
                            size: 12,
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
              
              // Arrow
              Icon(
                Icons.arrow_forward_ios,
                size: 14,
                color: AppColors.textTertiary,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _getCategoryIcon(String category) {
    final categoryData = AlertCategory.getByKey(category);
    
    if (categoryData != null) {
      return Text(
        categoryData.icon,
        style: const TextStyle(fontSize: 16),
      );
    }
    
    // Fallback icons
    IconData icon;
    Color color = AppColors.textSecondary;

    switch (category) {
      case 'ufo':
        icon = Icons.blur_circular;
        color = AppColors.brandPrimary;
        break;
      case 'missing_pet':
        icon = Icons.pets;
        color = AppColors.semanticWarning;
        break;
      case 'missing_person':
        icon = Icons.person;
        color = AppColors.semanticError;
        break;
      case 'suspicious':
        icon = Icons.warning;
        color = AppColors.semanticWarning;
        break;
      default:
        icon = Icons.help_outline;
    }

    return Icon(icon, color: color, size: 16);
  }

  String _getTimeAgo(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Color _getCategoryColor(String category) {
    final categoryData = AlertCategory.getByKey(category);
    if (categoryData != null) {
      switch (categoryData.color) {
        case 'primary':
          return AppColors.brandPrimary;
        case 'warning':
          return AppColors.semanticWarning;
        case 'error':
          return AppColors.semanticError;
        case 'success':
          return AppColors.semanticSuccess;
        case 'info':
          return AppColors.semanticInfo;
        default:
          return AppColors.brandPrimary;
      }
    }

    switch (category.toLowerCase()) {
      case 'ufo':
        return AppColors.brandPrimary;
      case 'aircraft':
        return Colors.blue;
      case 'atmospheric':
        return Colors.orange;
      case 'astronomical':
        return Colors.purple;
      default:
        return AppColors.brandPrimary;
    }
  }
}