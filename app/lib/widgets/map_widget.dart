import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_map_marker_cluster/flutter_map_marker_cluster.dart';
import 'package:latlong2/latlong.dart';

import '../providers/alerts_provider.dart';
import '../theme/app_theme.dart';

class MapWidget extends StatefulWidget {
  final List<Alert> alerts;
  final Alert? targetAlert;
  final double? height;
  final LatLng? center;
  final double? zoom;
  final Function(Alert)? onAlertTap;
  final bool showControls;

  const MapWidget({
    super.key,
    required this.alerts,
    this.targetAlert,
    this.height,
    this.center,
    this.zoom = 5.5,
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
    // If there's a target alert, center on it
    if (widget.targetAlert != null) {
      return LatLng(widget.targetAlert!.latitude, widget.targetAlert!.longitude);
    }

    // Use provided center
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

  IconData _getUfoIcon(Alert alert) {
    // Check if this is a MUFON classified sighting
    if (alert.source == 'mufon' || alert.username == 'MUFON_Database') {
      // Try to get UFO classification from enrichment data
      final enrichmentData = alert.enrichmentData;
      if (enrichmentData != null && enrichmentData.containsKey('ufo_classification')) {
        final classification = enrichmentData['ufo_classification'];
        if (classification is Map && classification.containsKey('type')) {
          final ufoType = classification['type'].toString().toLowerCase();
          
          // Return appropriate icons for each UFO type
          switch (ufoType) {
            case 'triangle':
              return Icons.change_history; // Triangle icon
            case 'disc':
            case 'saucer':
              return Icons.lens; // Disc/circle icon
            case 'sphere':
              return Icons.circle; // Sphere icon
            case 'cigar':
              return Icons.horizontal_rule; // Horizontal line for cigar
            case 'light':
              return Icons.wb_sunny; // Sun/light icon
            case 'formation':
              return Icons.scatter_plot; // Multiple dots for formation
            case 'boomerang':
              return Icons.keyboard_arrow_left; // Angular shape
            case 'rectangle':
              return Icons.crop_square; // Rectangle icon
            case 'diamond':
              return Icons.crop_free; // Diamond-like icon
            default:
              return Icons.help_outline; // Unknown UFO type
          }
        }
      }
      // Default MUFON icon if no classification
      return Icons.help_outline;
    }
    
    // Regular UFO beep sightings keep the standard location pin with existing fading behavior
    return Icons.location_on;
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
    // No age filtering - show all alerts like web version
    return alerts;
  }

  List<Alert> _filterAlertsByZoom(List<Alert> alerts) {
    // Default zoom level if map controller is not ready yet
    double currentZoom = widget.zoom ?? 5.5;

    // Try to get current zoom from map controller, but handle safely
    try {
      if (_mapController.camera != null) {
        currentZoom = _mapController.camera.zoom;
      }
    } catch (e) {
      // Map controller not ready yet, use default zoom
      currentZoom = widget.zoom ?? 5.5;
    }

    // Show all alerts like web version - no artificial limits
    int maxAlerts = alerts.length; // Show all available alerts
    
    // Sort by most recent and take only the limit
    final sortedAlerts = List<Alert>.from(alerts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedAlerts.take(maxAlerts).toList();
  }

  List<Marker> _buildClusteredMarkers() {
    // Filter alerts by age first, then by zoom level
    final ageFilteredAlerts = _filterReportsByAge(widget.alerts);
    final filteredAlerts = _filterAlertsByZoom(ageFilteredAlerts);

    // Exclude target alert from clustering - it will be shown separately
    final alertsToCluster = widget.targetAlert != null
        ? filteredAlerts.where((alert) => alert.id != widget.targetAlert!.id).toList()
        : filteredAlerts;

    return alertsToCluster.map((alert) => _buildAlertMarker(alert)).toList();
  }

  Marker _buildAlertMarker(Alert alert) {
    final isTargetAlert = widget.targetAlert?.id == alert.id;
    final isUfoBeep = _isUfoBeepAlert(alert);

    // Add jitter for red target and UFO markers to avoid exact overlap
    LatLng markerPosition = LatLng(alert.latitude, alert.longitude);

    if (isTargetAlert || isUfoBeep) {
      // Add small random offset to important markers so they stand out
      final jitterAmount = 0.001; // Small offset in degrees
      final hash = alert.id.hashCode;
      final offsetLat = ((hash % 1000) / 1000.0 - 0.5) * jitterAmount;
      final offsetLng = (((hash ~/ 1000) % 1000) / 1000.0 - 0.5) * jitterAmount;

      markerPosition = LatLng(
        alert.latitude + offsetLat,
        alert.longitude + offsetLng,
      );
    }

    // Determine marker style based on alert type and target status
    Widget markerChild;
    if (isTargetAlert) {
      // Target alert: bright red circle (highly visible)
      markerChild = Container(
        width: 30,
        height: 30,
        decoration: BoxDecoration(
          color: Colors.red,
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 3),
          boxShadow: [
            BoxShadow(
              color: Colors.red.withOpacity(0.6),
              blurRadius: 15,
              spreadRadius: 3,
            ),
          ],
        ),
        child: const Icon(
          Icons.location_on,
          color: Colors.white,
          size: 18,
        ),
      );
    } else if (isUfoBeep) {
      // UFOBeep alerts: bright cyan circle with UFO emoji
      markerChild = Container(
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: const Color(0xFF00E5FF), // Bright cyan
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Center(
          child: Text(
            '🛸',
            style: TextStyle(fontSize: 14),
          ),
        ),
      );
    } else {
      // MUFON/Other alerts: green circles with white border
      markerChild = Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: const Color(0xFF39FF14), // Bright green
          shape: BoxShape.circle,
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.4),
              blurRadius: 6,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    return Marker(
      point: markerPosition,
      child: GestureDetector(
        onTap: () {
          setState(() {
            _selectedAlert = alert;
          });
          if (widget.onAlertTap != null) {
            widget.onAlertTap!(alert);
          }
        },
        child: markerChild,
      ),
      width: isTargetAlert ? 30 : (isUfoBeep ? 26 : 20),
      height: isTargetAlert ? 30 : (isUfoBeep ? 26 : 20),
    );
  }

  bool _isUfoBeepAlert(Alert alert) {
    // Check if this is a UFOBeep alert (not MUFON or other databases)
    return alert.source != 'mufon' &&
           alert.username != 'MUFON_Database' &&
           alert.source != 'nuforc';
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
                initialZoom: widget.zoom ?? 5.5,
                minZoom: 2.0,
                maxZoom: 18.0,
                backgroundColor: AppColors.darkBackground,
                onTap: (tapPosition, point) {
                  setState(() {
                    _selectedAlert = null;
                  });
                },
                onMapEvent: (MapEvent mapEvent) {
                  // Rebuild markers when zoom changes to apply zoom-based filtering
                  if (mapEvent is MapEventMoveEnd) {
                    setState(() {
                      // This will trigger _buildMarkers() to be called again
                    });
                  }
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

                // Clustered alert markers
                MarkerClusterLayerWidget(
                  options: MarkerClusterLayerOptions(
                    maxClusterRadius: 25, // Much smaller radius for earlier breakup
                    size: const Size(40, 40),
                    markers: _buildClusteredMarkers(),
                    onClusterTap: (cluster) {
                      // Auto-zoom on cluster tap to reveal individual markers
                      try {
                        final currentZoom = _mapController.camera.zoom;
                        final newZoom = (currentZoom + 2).clamp(2.0, 18.0);
                        _mapController.move(
                          LatLng(cluster.latitude, cluster.longitude),
                          newZoom,
                        );
                      } catch (e) {
                        // Map controller not ready, ignore
                      }
                    },
                    builder: (context, markers) {
                      return Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(20),
                          color: AppColors.brandPrimary.withOpacity(0.8),
                          border: Border.all(color: Colors.white, width: 2),
                        ),
                        child: Center(
                          child: Text(
                            markers.length.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),

                // Target alert marker (always visible, not clustered)
                if (widget.targetAlert != null)
                  MarkerLayer(
                    markers: [_buildAlertMarker(widget.targetAlert!)],
                  ),
              ],
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
                        try {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom + 1,
                          );
                        } catch (e) {
                          // Map controller not ready yet, ignore
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: Icons.remove,
                      onTap: () {
                        try {
                          _mapController.move(
                            _mapController.camera.center,
                            _mapController.camera.zoom - 1,
                          );
                        } catch (e) {
                          // Map controller not ready yet, ignore
                        }
                      },
                    ),
                    const SizedBox(height: 8),
                    _buildControlButton(
                      icon: Icons.my_location,
                      onTap: () {
                        try {
                          _mapController.move(_defaultCenter, widget.zoom ?? 10.0);
                        } catch (e) {
                          // Map controller not ready yet, ignore
                        }
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

}