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
    final now = DateTime.now();
    const maxAgeInDays = 7; // Hide reports older than 7 days
    
    return alerts.where((alert) {
      final ageInDays = now.difference(alert.createdAt).inDays;
      return ageInDays <= maxAgeInDays;
    }).toList();
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

    // Match web map performance - show many more alerts
    int maxAlerts;
    if (currentZoom >= 12) {
      maxAlerts = 10000; // Zoomed in - show ALL local alerts
    } else if (currentZoom >= 8) {
      maxAlerts = 500; // Medium zoom - show many regional alerts
    } else if (currentZoom >= 5) {
      maxAlerts = 200; // Zoomed out - show 200 alerts
    } else {
      maxAlerts = 100; // Very zoomed out - show 100 most recent alerts
    }
    
    // Sort by most recent and take only the limit
    final sortedAlerts = List<Alert>.from(alerts)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    
    return sortedAlerts.take(maxAlerts).toList();
  }

  List<Marker> _buildClusteredMarkers() {
    // Filter alerts by age first, then by zoom level
    final ageFilteredAlerts = _filterReportsByAge(widget.alerts);
    final filteredAlerts = _filterAlertsByZoom(ageFilteredAlerts);

    return filteredAlerts.map((alert) => _buildAlertMarker(alert)).toList();
  }

  Marker _buildAlertMarker(Alert alert) {
    final isTargetAlert = widget.targetAlert?.id == alert.id;
    final isUfoBeep = _isUfoBeepAlert(alert);

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
                    maxClusterRadius: 50,
                    size: const Size(40, 40),
                    anchor: AnchorPos.align(AnchorAlign.center),
                    fitBoundsOptions: const FitBoundsOptions(
                      padding: EdgeInsets.all(50),
                      maxZoom: 15,
                    ),
                    markers: _buildClusteredMarkers(),
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
                      'Zoom in to see details',
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 10,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      'Tap markers to view',
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