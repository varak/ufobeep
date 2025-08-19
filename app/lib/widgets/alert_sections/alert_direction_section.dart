import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/alerts_provider.dart';
import '../../theme/app_theme.dart';
import '../../services/permission_service.dart';

class AlertDirectionSection extends StatelessWidget {
  const AlertDirectionSection({
    super.key,
    required this.alert,
    this.onNavigate,
  });

  final Alert alert;
  final Function(double bearing, double distance)? onNavigate;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
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
                Icons.explore,
                color: AppColors.brandPrimary,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Direction & Distance',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          _buildCompassSection(),
        ],
      ),
    );
  }

  Widget _buildCompassSection() {
    return FutureBuilder<Position?>(
      future: permissionService.getCurrentLocation(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Row(
            children: [
              Icon(Icons.explore, color: AppColors.textTertiary, size: 20),
              SizedBox(width: 12),
              Text(
                'Getting your location...',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ],
          );
        }

        final userLocation = snapshot.data!;
        final bearing = _calculateBearing(
          userLocation.latitude,
          userLocation.longitude,
          alert.latitude,
          alert.longitude,
        );
        final distance = alert.distance ?? _calculateDistance(
          userLocation.latitude,
          userLocation.longitude,
          alert.latitude,
          alert.longitude,
        );

        return Row(
          children: [
            // Mini compass indicator
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.darkBorder, width: 2),
                color: AppColors.darkBackground,
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Compass face with N/S/E/W markers
                  CustomPaint(
                    size: const Size(60, 60),
                    painter: _CompassFacePainter(),
                  ),
                  // Direction arrow pointing to sighting
                  Transform.rotate(
                    angle: bearing * math.pi / 180,
                    child: const Icon(
                      Icons.navigation,
                      color: AppColors.brandPrimary,
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            // Direction info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${_getCardinalDirection(bearing)} (${bearing.toStringAsFixed(0)}°)',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${distance.toStringAsFixed(1)} km away',
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            // Navigate button (if callback provided)
            if (onNavigate != null)
              OutlinedButton.icon(
                onPressed: () => onNavigate!(bearing, distance),
                icon: const Icon(Icons.explore, size: 16),
                label: const Text('Orient'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppColors.brandPrimary,
                  side: const BorderSide(color: AppColors.brandPrimary),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                ),
              ),
          ],
        );
      },
    );
  }

  double _calculateBearing(double lat1, double lon1, double lat2, double lon2) {
    final dLon = (lon2 - lon1) * math.pi / 180;
    final lat1Rad = lat1 * math.pi / 180;
    final lat2Rad = lat2 * math.pi / 180;

    final y = math.sin(dLon) * math.cos(lat2Rad);
    final x = math.cos(lat1Rad) * math.sin(lat2Rad) - 
              math.sin(lat1Rad) * math.cos(lat2Rad) * math.cos(dLon);

    final bearing = math.atan2(y, x) * 180 / math.pi;
    return (bearing + 360) % 360;
  }

  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // Earth's radius in kilometers
    final dLat = (lat2 - lat1) * math.pi / 180;
    final dLon = (lon2 - lon1) * math.pi / 180;

    final a = math.sin(dLat / 2) * math.sin(dLat / 2) +
              math.cos(lat1 * math.pi / 180) * math.cos(lat2 * math.pi / 180) *
              math.sin(dLon / 2) * math.sin(dLon / 2);
    final c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  String _getCardinalDirection(double bearing) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SW', 'W', 'NW'];
    final index = ((bearing + 22.5) / 45).floor() % 8;
    return directions[index];
  }
}

class _CompassFacePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..color = AppColors.textTertiary;

    // Draw compass face circle
    canvas.drawCircle(center, radius, paint);

    // Draw cardinal direction markers
    final textPainter = TextPainter(
      textAlign: TextAlign.center,
      textDirection: TextDirection.ltr,
    );

    // North
    textPainter.text = const TextSpan(
      text: 'N',
      style: TextStyle(
        color: AppColors.textPrimary,
        fontSize: 10,
        fontWeight: FontWeight.w600,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy - radius + 2));

    // South
    textPainter.text = const TextSpan(
      text: 'S',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - textPainter.width / 2, center.dy + radius - textPainter.height - 2));

    // East
    textPainter.text = const TextSpan(
      text: 'E',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx + radius - textPainter.width - 2, center.dy - textPainter.height / 2));

    // West
    textPainter.text = const TextSpan(
      text: 'W',
      style: TextStyle(
        color: AppColors.textSecondary,
        fontSize: 8,
        fontWeight: FontWeight.w400,
      ),
    );
    textPainter.layout();
    textPainter.paint(canvas, Offset(center.dx - radius + 2, center.dy - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}