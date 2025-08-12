import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../theme/app_theme.dart';
import '../providers/alerts_provider.dart';
import '../models/alerts_filter.dart';

class AlertCard extends StatelessWidget {
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
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 2,
      color: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: _getCategoryColor(alert.category).withOpacity(0.2),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap ?? () => context.go('/alert/${alert.id}'),
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
                      color: _getCategoryColor(alert.category).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: _getCategoryIcon(alert.category),
                  ),
                  
                  const SizedBox(width: 12),
                  
                  // Title and category name
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          alert.title,
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
                              _getCategoryDisplayName(alert.category),
                              style: TextStyle(
                                color: _getCategoryColor(alert.category),
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            if (alert.isVerified) ...[
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
                        _getTimeAgo(alert.createdAt),
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                      if (alert.distance != null && showDistance) ...[
                        const SizedBox(height: 4),
                        _buildDistanceBadge(),
                      ],
                    ],
                  ),
                ],
              ),
              
              const SizedBox(height: 12),
              
              // Description
              Text(
                alert.description,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                  height: 1.4,
                ),
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
              
              const SizedBox(height: 12),
              
              // Footer with location info and bearing
              Row(
                children: [
                  // Location name and distance info
                  if (alert.locationName != null) ...[
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppColors.textTertiary,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        alert.locationName!,
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (alert.distance != null && showDistance) ...[
                      const SizedBox(width: 8),
                      Text(
                        '• ${_getDistanceText()}',
                        style: const TextStyle(
                          color: AppColors.textTertiary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ] else if (alert.distance != null && showDistance) ...[
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
                    
                    // Bearing indicator
                    if (alert.bearing != null) ...[
                      const SizedBox(width: 12),
                      _buildBearingIndicator(),
                    ],
                    
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
    if (alert.distance == null) return const SizedBox.shrink();
    
    final distance = alert.distance!;
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

  Widget _buildBearingIndicator() {
    if (alert.bearing == null) return const SizedBox.shrink();
    
    final bearing = alert.bearing!;
    
    return Container(
      width: 24,
      height: 24,
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Transform.rotate(
        angle: (bearing - 90) * (math.pi / 180), // Adjust so 0° points up
        child: const Icon(
          Icons.navigation,
          size: 14,
          color: AppColors.brandPrimary,
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
    if (alert.distance == null) return '';
    
    final distance = alert.distance!;
    
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
                child: AlertCard(alert: alert, showDistance: false)._getCategoryIcon(alert.category),
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
                          AlertCard(alert: alert, showDistance: false)._getTimeAgo(alert.createdAt),
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

  Color _getCategoryColor(String category) {
    return AlertCard(alert: alert, showDistance: false)._getCategoryColor(category);
  }
}