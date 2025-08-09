import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/sensor_data.dart';

class PlaneBadge extends StatelessWidget {
  final PlaneMatchResponse planeMatch;
  final VoidCallback? onReclassify;
  final bool showDetails;

  const PlaneBadge({
    super.key,
    required this.planeMatch,
    this.onReclassify,
    this.showDetails = true,
  });

  @override
  Widget build(BuildContext context) {
    if (!planeMatch.isPlane) {
      return const SizedBox.shrink();
    }

    final matchInfo = planeMatch.matchedFlight;
    final confidence = planeMatch.confidence;

    // Determine badge color based on confidence
    Color badgeColor;
    Color textColor;
    String confidenceText;

    if (confidence >= 0.8) {
      badgeColor = AppColors.brandPrimary;
      textColor = Colors.black;
      confidenceText = 'High confidence';
    } else if (confidence >= 0.6) {
      badgeColor = AppColors.semanticWarning;
      textColor = Colors.black;
      confidenceText = 'Medium confidence';
    } else {
      badgeColor = AppColors.semanticError;
      textColor = Colors.white;
      confidenceText = 'Low confidence';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: badgeColor, width: 1.5),
      ),
      child: Column(
        children: [
          // Main badge content
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                // Plane icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.airplanemode_active,
                    color: textColor,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // Plane information
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            'Likely Plane: ',
                            style: TextStyle(
                              color: badgeColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Expanded(
                            child: Text(
                              matchInfo?.displayName ?? 'Unknown Aircraft',
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      
                      if (showDetails) ...[
                        const SizedBox(height: 4),
                        Text(
                          '$confidenceText • ${(confidence * 100).toInt()}% match',
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                        
                        if (matchInfo?.displayRoute.isNotEmpty == true) ...[
                          const SizedBox(height: 2),
                          Text(
                            matchInfo!.displayRoute,
                            style: const TextStyle(
                              color: AppColors.textSecondary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ],
                    ],
                  ),
                ),
                
                // Confidence indicator
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${(confidence * 100).toInt()}%',
                    style: TextStyle(
                      color: textColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          
          // Expandable details
          if (showDetails && matchInfo != null) ...[
            Container(
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(12),
                  bottomRight: Radius.circular(12),
                ),
              ),
              child: ExpansionTile(
                title: const Text(
                  'Flight Details',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                backgroundColor: Colors.transparent,
                collapsedBackgroundColor: Colors.transparent,
                iconColor: AppColors.textSecondary,
                collapsedIconColor: AppColors.textSecondary,
                children: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
                    child: Column(
                      children: [
                        if (matchInfo.callsign?.isNotEmpty == true)
                          _buildDetailRow('Callsign', matchInfo.callsign!),
                        
                        if (matchInfo.icao24?.isNotEmpty == true)
                          _buildDetailRow('ICAO24', matchInfo.icao24!.toUpperCase()),
                        
                        if (matchInfo.altitude != null)
                          _buildDetailRow(
                            'Altitude', 
                            '${(matchInfo.altitude! * 3.28084).toInt()}\' (${matchInfo.altitude!.toInt()}m)'
                          ),
                        
                        if (matchInfo.velocity != null)
                          _buildDetailRow(
                            'Speed', 
                            '${(matchInfo.velocity! * 1.944).toInt()} kts (${matchInfo.velocity!.toInt()} m/s)'
                          ),
                        
                        _buildDetailRow(
                          'Angular Error', 
                          '${matchInfo.angularError.toStringAsFixed(1)}°'
                        ),
                        
                        const SizedBox(height: 8),
                        
                        // Reclassification button
                        if (onReclassify != null)
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: onReclassify,
                              icon: const Icon(Icons.flag, size: 16),
                              label: const Text('Mark as UFO Instead'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.semanticWarning,
                                side: const BorderSide(color: AppColors.semanticWarning),
                                padding: const EdgeInsets.symmetric(vertical: 8),
                              ),
                            ),
                          ),
                      ],
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

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 13,
            ),
          ),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

class PlaneMatchLoadingBadge extends StatelessWidget {
  const PlaneMatchLoadingBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.brandPrimary.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.brandPrimary, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.brandPrimary,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.black),
              ),
            ),
          ),
          
          const SizedBox(width: 12),
          
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Analyzing sky object...',
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                SizedBox(height: 2),
                Text(
                  'Checking aircraft database',
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
    );
  }
}

class PlaneMatchErrorBadge extends StatelessWidget {
  final String errorMessage;
  final VoidCallback? onRetry;

  const PlaneMatchErrorBadge({
    super.key,
    required this.errorMessage,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: AppColors.semanticError.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.semanticError, width: 1.5),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.semanticError,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    Icons.error,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                
                const SizedBox(width: 12),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Plane Analysis Failed',
                        style: TextStyle(
                          color: AppColors.semanticError,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        errorMessage,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            
            if (onRetry != null) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Retry Analysis'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.semanticError,
                    side: const BorderSide(color: AppColors.semanticError),
                    padding: const EdgeInsets.symmetric(vertical: 8),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}