import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';

class CompassDisplay extends StatelessWidget {
  const CompassDisplay({
    super.key,
    required this.compassData,
    this.target,
    this.size = 280.0,
  });

  final CompassData compassData;
  final CompassTarget? target;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Compass Rose Background
          _buildCompassRose(),
          
          // Direction Labels
          _buildDirectionLabels(),
          
          // Compass Needle
          _buildCompassNeedle(),
          
          // Target Arrow (if target is set)
          if (target != null) _buildTargetArrow(),
          
          // Center Info
          _buildCenterInfo(),
        ],
      ),
    );
  }

  Widget _buildCompassRose() {
    return CustomPaint(
      size: Size(size, size),
      painter: CompassRosePainter(
        heading: compassData.trueHeading,
      ),
    );
  }

  Widget _buildDirectionLabels() {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        children: [
          // Cardinal directions
          _buildDirectionLabel('N', 0),
          _buildDirectionLabel('E', 90),
          _buildDirectionLabel('S', 180),
          _buildDirectionLabel('W', 270),
          
          // Intermediate directions
          _buildDirectionLabel('NE', 45, isSecondary: true),
          _buildDirectionLabel('SE', 135, isSecondary: true),
          _buildDirectionLabel('SW', 225, isSecondary: true),
          _buildDirectionLabel('NW', 315, isSecondary: true),
        ],
      ),
    );
  }

  Widget _buildDirectionLabel(String label, double angle, {bool isSecondary = false}) {
    final radians = (angle - compassData.trueHeading) * math.pi / 180;
    final radius = size / 2 - 30;
    final x = radius * math.sin(radians);
    final y = -radius * math.cos(radians);

    return Positioned(
      left: size / 2 + x - 15,
      top: size / 2 + y - 15,
      child: Container(
        width: 30,
        height: 30,
        alignment: Alignment.center,
        child: Text(
          label,
          style: TextStyle(
            color: isSecondary ? AppColors.textTertiary : AppColors.textPrimary,
            fontSize: isSecondary ? 12 : 16,
            fontWeight: isSecondary ? FontWeight.normal : FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildCompassNeedle() {
    return Transform.rotate(
      angle: 0, // Needle points north, compass rose rotates
      child: CustomPaint(
        size: Size(size * 0.6, size * 0.6),
        painter: CompassNeedlePainter(),
      ),
    );
  }

  Widget _buildTargetArrow() {
    if (target == null || compassData.location == null) {
      return const SizedBox.shrink();
    }

    final relativeBearing = compassData.relativeBearing(target!.location);
    
    return Transform.rotate(
      angle: relativeBearing * math.pi / 180,
      child: CustomPaint(
        size: Size(size * 0.8, size * 0.8),
        painter: TargetArrowPainter(
          color: _getTargetColor(target!.type),
        ),
      ),
    );
  }

  Widget _buildCenterInfo() {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.9),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '${compassData.trueHeading.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            compassData.cardinalDirection,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
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
}

class CompassRosePainter extends CustomPainter {
  final double heading;

  CompassRosePainter({required this.heading});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer circle
    paint.color = AppColors.darkBorder;
    canvas.drawCircle(center, radius - 10, paint);

    // Inner circle
    paint.strokeWidth = 1;
    canvas.drawCircle(center, radius - 40, paint);

    // Degree markings
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - heading) * math.pi / 180;
      final isMainMark = i % 30 == 0;
      final markLength = isMainMark ? 20.0 : 10.0;
      
      paint.color = isMainMark ? AppColors.textSecondary : AppColors.textTertiary;
      paint.strokeWidth = isMainMark ? 2 : 1;
      
      final startRadius = radius - 10;
      final endRadius = startRadius - markLength;
      
      final start = Offset(
        center.dx + startRadius * math.sin(angle),
        center.dy - startRadius * math.cos(angle),
      );
      
      final end = Offset(
        center.dx + endRadius * math.sin(angle),
        center.dy - endRadius * math.cos(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(CompassRosePainter oldDelegate) {
    return heading != oldDelegate.heading;
  }
}

class CompassNeedlePainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final needleLength = size.height / 2 - 20;
    
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // North needle (red)
    paint.color = AppColors.semanticError;
    final northPath = Path();
    northPath.moveTo(center.dx, center.dy - needleLength);
    northPath.lineTo(center.dx - 8, center.dy - 10);
    northPath.lineTo(center.dx + 8, center.dy - 10);
    northPath.close();
    canvas.drawPath(northPath, paint);

    // South needle (white)
    paint.color = AppColors.textPrimary;
    final southPath = Path();
    southPath.moveTo(center.dx, center.dy + needleLength);
    southPath.lineTo(center.dx - 8, center.dy + 10);
    southPath.lineTo(center.dx + 8, center.dy + 10);
    southPath.close();
    canvas.drawPath(southPath, paint);

    // Center circle
    paint.color = AppColors.brandPrimary;
    canvas.drawCircle(center, 6, paint);
    
    paint.color = AppColors.darkBackground;
    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;
    canvas.drawCircle(center, 6, paint);
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}

class TargetArrowPainter extends CustomPainter {
  final Color color;

  TargetArrowPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final arrowLength = size.height / 2 - 60;
    
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;

    // Arrow shaft
    canvas.drawLine(
      Offset(center.dx, center.dy - 50),
      Offset(center.dx, center.dy - arrowLength),
      paint,
    );

    // Arrow head
    final arrowPath = Path();
    arrowPath.moveTo(center.dx, center.dy - arrowLength);
    arrowPath.lineTo(center.dx - 10, center.dy - arrowLength + 15);
    arrowPath.lineTo(center.dx + 10, center.dy - arrowLength + 15);
    arrowPath.close();
    canvas.drawPath(arrowPath, paint);
  }

  @override
  bool shouldRepaint(TargetArrowPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}