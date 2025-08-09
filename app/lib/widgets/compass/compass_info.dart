import 'package:flutter/material.dart';
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';

class CompassInfo extends StatelessWidget {
  const CompassInfo({
    super.key,
    required this.compassData,
    this.target,
  });

  final CompassData compassData;
  final CompassTarget? target;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Heading Information
          _buildHeadingCard(),
          
          const SizedBox(height: 16),
          
          // Target Information (if available)
          if (target != null) _buildTargetCard(),
          
          const SizedBox(height: 16),
          
          // Status Information
          _buildStatusCard(),
        ],
      ),
    );
  }

  Widget _buildHeadingCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.explore,
                  color: AppColors.brandPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Heading Information',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'True Heading',
                    compassData.formattedHeading,
                    compassData.cardinalDirection,
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Magnetic',
                    compassData.formattedMagneticHeading,
                    'Magnetic North',
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTargetCard() {
    if (target == null || compassData.location == null) {
      return const SizedBox.shrink();
    }

    final relativeBearing = compassData.relativeBearing(target!.location);
    final targetBearing = compassData.bearingToTarget(target!.location);
    
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _getTargetIcon(target!.type),
                  color: _getTargetColor(target!.type),
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    target!.name,
                    style: TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                if (target!.status == CompassTargetStatus.active)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.brandPrimary.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
                    ),
                    child: Text(
                      'ACTIVE',
                      style: TextStyle(
                        color: AppColors.brandPrimary,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
              ],
            ),
            
            if (target!.description != null) ...[
              const SizedBox(height: 8),
              Text(
                target!.description!,
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
            
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Bearing',
                    '${targetBearing.toStringAsFixed(0)}°',
                    _getBearingDescription(relativeBearing),
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Distance',
                    target!.formattedDistance,
                    target!.formattedETA ?? 'No ETA',
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: 12),
            
            // Direction indicator
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.darkBackground,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getDirectionIcon(relativeBearing),
                    color: AppColors.brandPrimary,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    _getDirectionText(relativeBearing),
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusCard() {
    return Card(
      color: AppColors.darkSurface,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  Icons.info_outline,
                  color: AppColors.textSecondary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'Status',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            
            Row(
              children: [
                Expanded(
                  child: _buildInfoItem(
                    'Accuracy',
                    compassData.accuracyDescription,
                    '±${compassData.accuracy.toStringAsFixed(0)}°',
                  ),
                ),
                Expanded(
                  child: _buildInfoItem(
                    'Calibration',
                    compassData.calibration.displayName,
                    compassData.needsCalibration ? 'Wave device' : 'Good',
                  ),
                ),
              ],
            ),
            
            if (compassData.location != null) ...[
              const SizedBox(height: 16),
              _buildInfoItem(
                'Location',
                compassData.location!.formattedCoordinates,
                '±${compassData.location!.accuracy.toStringAsFixed(0)}m',
              ),
            ],
            
            if (compassData.needsCalibration) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.semanticWarning.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.semanticWarning.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.warning,
                      color: AppColors.semanticWarning,
                      size: 16,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Compass needs calibration. Wave device in figure-8 pattern.',
                        style: TextStyle(
                          color: AppColors.semanticWarning,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value, String subtitle) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          subtitle,
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  IconData _getTargetIcon(TargetType type) {
    switch (type) {
      case TargetType.alert:
        return Icons.warning;
      case TargetType.emergency:
        return Icons.emergency;
      case TargetType.waypoint:
        return Icons.place;
      case TargetType.landmark:
        return Icons.location_city;
    }
  }

  Color _getTargetColor(TargetType type) {
    switch (type) {
      case TargetType.alert:
        return AppColors.brandPrimary;
      case TargetType.emergency:
        return AppColors.semanticError;
      case TargetType.waypoint:
        return AppColors.semanticInfo;
      case TargetType.landmark:
        return AppColors.semanticWarning;
    }
  }

  String _getBearingDescription(double relativeBearing) {
    final abs = relativeBearing.abs();
    if (abs < 15) return 'Straight ahead';
    if (abs < 45) return relativeBearing > 0 ? 'Slight right' : 'Slight left';
    if (abs < 90) return relativeBearing > 0 ? 'Right' : 'Left';
    if (abs < 135) return relativeBearing > 0 ? 'Sharp right' : 'Sharp left';
    return 'Behind';
  }

  IconData _getDirectionIcon(double relativeBearing) {
    final abs = relativeBearing.abs();
    if (abs < 15) return Icons.keyboard_arrow_up;
    if (abs < 90) return relativeBearing > 0 ? Icons.keyboard_arrow_right : Icons.keyboard_arrow_left;
    return Icons.keyboard_arrow_down;
  }

  String _getDirectionText(double relativeBearing) {
    final abs = relativeBearing.abs();
    if (abs < 15) return 'Go straight';
    if (abs < 45) return relativeBearing > 0 ? 'Bear right' : 'Bear left';
    if (abs < 90) return relativeBearing > 0 ? 'Turn right' : 'Turn left';
    if (abs < 135) return relativeBearing > 0 ? 'Sharp right' : 'Sharp left';
    return 'Turn around';
  }
}