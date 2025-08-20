import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';

class MapWidget extends StatefulWidget {
  final List<Alert> alerts;
  final double? height;
  final LatLng? center;
  final double? zoom;
  final Function(Alert)? onAlertTap;
  final bool showControls;

  const MapWidget({
    super.key,
    required this.alerts,
    this.height,
    this.center,
    this.zoom = 10.0,
    this.onAlertTap,
    this.showControls = true,
  });

  @override
  State<MapWidget> createState() => _MapWidgetState();
}

class _MapWidgetState extends State<MapWidget> {
  late MapController _mapController;
  Alert? _selectedAlert;

  @override
  void initState() {
    super.initState();
    _mapController = MapController();
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }

  LatLng get _defaultCenter {
    if (widget.center != null) return widget.center!;
    
    // If we have alerts, center on them
    if (widget.alerts.isNotEmpty) {
      double totalLat = 0;
      double totalLng = 0;
      
      for (final alert in widget.alerts) {
        totalLat += alert.latitude;
        totalLng += alert.longitude;
      }
      
      return LatLng(
        totalLat / widget.alerts.length,
        totalLng / widget.alerts.length,
      );
    }
    
    // Default to center of US
    return const LatLng(39.8283, -98.5795);
  }

  Color _getAlertColor(Alert alert) {
    final now = DateTime.now();
    final ageInHours = now.difference(alert.createdAt).inHours.abs();
    
    // Base color by alert level
    Color baseColor;
    switch (alert.alertLevel.toLowerCase()) {
      case 'critical':
        baseColor = Colors.red;
        break;
      case 'high':
        baseColor = Colors.orange;
        break;
      case 'medium':
        baseColor = Colors.yellow;
        break;
      case 'low':
        baseColor = Colors.green;
        break;
      default:
        baseColor = AppColors.brandPrimary;
    }
    
    // Apply age-based opacity degradation
    double opacity;
    if (ageInHours <= 1) {
      opacity = 1.0; // Full intensity for reports under 1 hour
    } else if (ageInHours <= 6) {
      opacity = 0.8; // Slight fade for 1-6 hours
    } else if (ageInHours <= 24) {
      opacity = 0.6; // More fade for 6-24 hours  
    } else if (ageInHours <= 72) {
      opacity = 0.4; // Significant fade for 1-3 days
    } else {
      opacity = 0.2; // Very faded for 3+ days
    }
    
    // Ensure opacity is within valid range
    opacity = opacity.clamp(0.0, 1.0);
    
    return baseColor.withOpacity(opacity);
  }
  
  List<Alert> _filterReportsByAge(List<Alert> alerts) {
    final now = DateTime.now();
    const maxAgeInDays = 7; // Hide reports older than 7 days
    
    return alerts.where((alert) {
      final ageInDays = now.difference(alert.createdAt).inDays;
      return ageInDays <= maxAgeInDays;
    }).toList();
  }

  List<Marker> _buildMarkers() {
    // Filter alerts by age first
    final filteredAlerts = _filterReportsByAge(widget.alerts);
    
    return filteredAlerts.map((alert) {
      final color = _getAlertColor(alert);
      final now = DateTime.now();
      final ageInHours = now.difference(alert.createdAt).inHours;
      
      // Adjust marker size based on age (newer = larger)
      double markerSize;
      if (ageInHours <= 1) {
        markerSize = 28; // Large for very recent
      } else if (ageInHours <= 6) {
        markerSize = 24; // Medium for recent
      } else {
        markerSize = 20; // Small for older
      }
      
      return Marker(
        point: LatLng(alert.latitude, alert.longitude),
        child: GestureDetector(
          onTap: () {
            setState(() {
              _selectedAlert = alert;
            });
            if (widget.onAlertTap != null) {
              widget.onAlertTap!(alert);
            }
          },
          child: Container(
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity((color.alpha / 255.0).clamp(0.0, 1.0)), 
                width: 2
              ),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.4),
                  blurRadius: ageInHours <= 1 ? 15 : 8,
                  spreadRadius: ageInHours <= 1 ? 3 : 1,
                ),
              ],
            ),
            child: Icon(
              Icons.location_on,
              color: Colors.white.withOpacity(((color.alpha / 255.0) + 0.2).clamp(0.0, 1.0)),
              size: markerSize * 0.6,
            ),
          ),
        ),
        width: markerSize,
        height: markerSize,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: widget.height ?? 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Stack(
          children: [
            FlutterMap(
              mapController: _mapController,
              options: MapOptions(
                initialCenter: _defaultCenter,
                initialZoom: widget.zoom ?? 10.0,
                minZoom: 2.0,
                maxZoom: 18.0,
                backgroundColor: AppColors.darkBackground,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedAlert = null;
                  });
                },
              ),
              children: [
                // OpenStreetMap tiles
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.ufobeep.app',
                  maxZoom: 18,
                  tileBuilder: (context, tileWidget, tile) {
                    // Apply dark theme filter to map tiles
                    return ColorFiltered(
                      colorFilter: const ColorFilter.matrix([
                        0.2, 0, 0, 0, 20,
                        0, 0.2, 0, 0, 20, 
                        0, 0, 0.2, 0, 20,
                        0, 0, 0, 1, 0,
                      ]),
                      child: tileWidget,
                    );
                  },
                ),
                
                // Alert markers
                MarkerLayer(markers: _buildMarkers()),
              ],
            ),

            // Map overlay with stats
            Positioned(
              top: 16,
              left: 16,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: AppColors.brandPrimary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        const Text(
                          'Live Sightings',
                          style: TextStyle(
                            color: AppColors.brandPrimary,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_filterReportsByAge(widget.alerts).length} recent reports',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '(${widget.alerts.length} total)',
                      style: const TextStyle(
                        color: AppColors.textTertiary,
                        fontSize: 9,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // Map controls
            if (widget.showControls)
              Positioned(
                top: 16,
                right: 16,
                child: Column(
                  children: [
                    _buildControlButton(
                      icon: Icons.add,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom + 1,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: Icons.remove,
                      onTap: () {
                        _mapController.move(
                          _mapController.camera.center,
                          _mapController.camera.zoom - 1,
                        );
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: Icons.my_location,
                      onTap: () {
                        _mapController.move(_defaultCenter, widget.zoom ?? 10.0);
                      },
                    ),
                  ],
                ),
              ),

            // Selected alert popup
            if (_selectedAlert != null)
              Positioned(
                bottom: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.darkBorder),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              _selectedAlert!.title,
                              style: const TextStyle(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.w600,
                                fontSize: 16,
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _selectedAlert = null),
                            child: const Icon(
                              Icons.close,
                              color: AppColors.textSecondary,
                              size: 20,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _selectedAlert!.description,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 14,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(
                            Icons.location_on,
                            color: AppColors.textTertiary,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              _selectedAlert!.locationName ?? 'Unknown location',
                              style: const TextStyle(
                                color: AppColors.textTertiary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: _getAlertColor(_selectedAlert!),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              _selectedAlert!.alertLevel.toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            // Legend
            Positioned(
              bottom: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.darkSurface.withOpacity(0.9),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorder),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Age',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildAgeLegendItem('< 1h', 1.0, 28),
                    _buildAgeLegendItem('< 6h', 0.8, 24),
                    _buildAgeLegendItem('< 24h', 0.6, 24),
                    _buildAgeLegendItem('< 3d', 0.4, 20),
                    const SizedBox(height: 6),
                    const Text(
                      'Level',
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 9,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 4),
                    _buildLegendItem('Critical', Colors.red),
                    _buildLegendItem('High', Colors.orange),
                    _buildLegendItem('Medium', Colors.yellow),
                    _buildLegendItem('Low', Colors.green),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Icon(
          icon,
          color: AppColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAgeLegendItem(String label, double opacity, double size) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 1),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: size / 3,
            height: size / 3,
            decoration: BoxDecoration(
              color: AppColors.brandPrimary.withOpacity(opacity),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(opacity),
                width: 1,
              ),
            ),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 9,
            ),
          ),
        ],
      ),
    );
  }
}