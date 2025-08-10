import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/compass_data.dart';
import '../../models/pilot_data.dart';
import '../../theme/app_theme.dart';
import '../../services/compass_math.dart';
import '../../services/pilot_navigation_service.dart';

class PilotCompassDisplay extends StatelessWidget {
  const PilotCompassDisplay({
    super.key,
    required this.pilotData,
    this.target,
    this.size = 320.0,
  });

  final PilotNavigationData pilotData;
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
          // Attitude indicator background
          _buildAttitudeBackground(),
          
          // Compass rose (outer ring)
          _buildCompassRose(),
          
          // Bank angle indicator
          _buildBankAngleIndicator(),
          
          // Heading indicator (aircraft symbol)
          _buildAircraftSymbol(),
          
          // Target bearing indicators
          if (target != null && pilotData.solution != null) 
            _buildTargetIndicators(),
          
          // Center instrument cluster
          _buildCenterInstruments(),
          
          // Wind vector
          if (pilotData.wind != null) _buildWindVector(),
        ],
      ),
    );
  }

  Widget _buildAttitudeBackground() {
    return Container(
      width: size * 0.7,
      height: size * 0.7,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: [
            AppColors.darkSurface.withOpacity(0.3),
            AppColors.darkBackground.withOpacity(0.8),
          ],
        ),
        border: Border.all(color: AppColors.darkBorder, width: 2),
      ),
    );
  }

  Widget _buildCompassRose() {
    return CustomPaint(
      size: Size(size, size),
      painter: PilotCompassRosePainter(
        heading: pilotData.compass.trueHeading,
        magneticHeading: pilotData.compass.magneticHeading,
      ),
    );
  }

  Widget _buildBankAngleIndicator() {
    return CustomPaint(
      size: Size(size * 0.9, size * 0.9),
      painter: BankAngleIndicatorPainter(
        bankAngle: pilotData.bankAngle ?? 0.0,
      ),
    );
  }

  Widget _buildAircraftSymbol() {
    return CustomPaint(
      size: Size(size * 0.6, size * 0.6),
      painter: AircraftSymbolPainter(
        pitchAngle: pilotData.pitchAngle ?? 0.0,
      ),
    );
  }

  Widget _buildTargetIndicators() {
    if (pilotData.solution == null) return const SizedBox.shrink();
    
    final solution = pilotData.solution!;
    
    return CustomPaint(
      size: Size(size * 0.85, size * 0.85),
      painter: TargetBearingPainter(
        trueBearing: solution.bearing,
        magneticBearing: solution.magneticBearing,
        relativeBearing: solution.relativeBearing,
        currentHeading: pilotData.compass.trueHeading,
        requiredHeading: solution.requiredHeading,
      ),
    );
  }

  Widget _buildCenterInstruments() {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.95),
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.darkBorder, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // True heading
          Text(
            '${pilotData.compass.trueHeading.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: AppColors.brandPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          // Magnetic heading (smaller)
          Text(
            'M${pilotData.compass.magneticHeading.toStringAsFixed(0)}°',
            style: const TextStyle(
              color: AppColors.textTertiary,
              fontSize: 11,
            ),
          ),
          
          // Ground speed
          if (pilotData.groundSpeed != null)
            Text(
              pilotData.groundSpeedFormatted,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 10,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildWindVector() {
    final wind = pilotData.wind!;
    final windRelative = wind.direction - pilotData.compass.trueHeading;
    
    return Transform.rotate(
      angle: windRelative * math.pi / 180,
      child: CustomPaint(
        size: Size(size * 0.8, size * 0.8),
        painter: WindVectorPainter(
          windSpeed: wind.speed,
          windDirection: wind.direction,
          currentHeading: pilotData.compass.trueHeading,
        ),
      ),
    );
  }
}

class PilotCompassRosePainter extends CustomPainter {
  final double heading;
  final double magneticHeading;

  PilotCompassRosePainter({
    required this.heading,
    required this.magneticHeading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    // Outer ring
    paint.color = AppColors.darkBorder;
    canvas.drawCircle(center, radius - 15, paint);

    // Degree markings (every 10 degrees)
    for (int i = 0; i < 360; i += 10) {
      final angle = (i - heading) * math.pi / 180;
      final isMainMark = i % 30 == 0;
      final isCardinal = i % 90 == 0;
      
      final markLength = isCardinal ? 25.0 : (isMainMark ? 15.0 : 10.0);
      final strokeWidth = isCardinal ? 3.0 : (isMainMark ? 2.0 : 1.0);
      
      paint.color = isCardinal 
          ? AppColors.brandPrimary 
          : (isMainMark ? AppColors.textSecondary : AppColors.textTertiary);
      paint.strokeWidth = strokeWidth;
      
      final startRadius = radius - 15;
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

    // Cardinal direction labels
    _drawCardinalLabels(canvas, center, radius, heading);
    
    // Magnetic variation indicator
    final magVariation = magneticHeading - heading;
    if (magVariation.abs() > 1) {
      _drawMagneticVariation(canvas, center, radius, magVariation);
    }
  }

  void _drawCardinalLabels(Canvas canvas, Offset center, double radius, double heading) {
    const labels = ['N', 'E', 'S', 'W'];
    const angles = [0, 90, 180, 270];
    
    for (int i = 0; i < 4; i++) {
      final angle = (angles[i] - heading) * math.pi / 180;
      final labelRadius = radius - 40;
      
      final x = center.dx + labelRadius * math.sin(angle);
      final y = center.dy - labelRadius * math.cos(angle);
      
      final textPainter = TextPainter(
        text: TextSpan(
          text: labels[i],
          style: const TextStyle(
            color: AppColors.brandPrimary,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        textDirection: TextDirection.ltr,
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawMagneticVariation(Canvas canvas, Offset center, double radius, double variation) {
    final angle = -variation * math.pi / 180;
    final markRadius = radius - 25;
    
    final paint = Paint()
      ..color = AppColors.semanticWarning
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final start = Offset(
      center.dx + markRadius * math.sin(angle),
      center.dy - markRadius * math.cos(angle),
    );
    
    final end = Offset(
      center.dx + (markRadius - 10) * math.sin(angle),
      center.dy - (markRadius - 10) * math.cos(angle),
    );
    
    canvas.drawLine(start, end, paint);
    
    // M for magnetic
    final textPainter = TextPainter(
      text: const TextSpan(
        text: 'M',
        style: TextStyle(
          color: AppColors.semanticWarning,
          fontSize: 10,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(end.dx - textPainter.width / 2, end.dy - textPainter.height / 2),
    );
  }

  @override
  bool shouldRepaint(PilotCompassRosePainter oldDelegate) {
    return heading != oldDelegate.heading || 
           magneticHeading != oldDelegate.magneticHeading;
  }
}

class BankAngleIndicatorPainter extends CustomPainter {
  final double bankAngle;

  BankAngleIndicatorPainter({required this.bankAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    // Bank angle marks
    const bankAngles = [-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60];
    
    for (final angle in bankAngles) {
      final isMainMark = angle % 30 == 0;
      final markLength = isMainMark ? 20.0 : 12.0;
      
      paint.color = angle == 0 
          ? AppColors.brandPrimary 
          : (isMainMark ? AppColors.textSecondary : AppColors.textTertiary);
      
      final angleRad = angle * math.pi / 180;
      final startRadius = radius - 10;
      final endRadius = startRadius - markLength;
      
      final start = Offset(
        center.dx + startRadius * math.sin(angleRad),
        center.dy - startRadius * math.cos(angleRad),
      );
      
      final end = Offset(
        center.dx + endRadius * math.sin(angleRad),
        center.dy - endRadius * math.cos(angleRad),
      );
      
      canvas.drawLine(start, end, paint);
    }

    // Bank angle pointer
    if (bankAngle.abs() > 1) {
      _drawBankPointer(canvas, center, radius, bankAngle);
    }
  }

  void _drawBankPointer(Canvas canvas, Offset center, double radius, double angle) {
    final paint = Paint()
      ..color = AppColors.semanticWarning
      ..style = PaintingStyle.fill;
    
    final angleRad = angle * math.pi / 180;
    final pointerRadius = radius - 15;
    
    final pointerTip = Offset(
      center.dx + pointerRadius * math.sin(angleRad),
      center.dy - pointerRadius * math.cos(angleRad),
    );
    
    // Draw triangle pointer
    final path = Path();
    path.moveTo(pointerTip.dx, pointerTip.dy);
    path.lineTo(
      pointerTip.dx - 8 * math.cos(angleRad),
      pointerTip.dy - 8 * math.sin(angleRad),
    );
    path.lineTo(
      pointerTip.dx + 8 * math.cos(angleRad),
      pointerTip.dy + 8 * math.sin(angleRad),
    );
    path.close();
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(BankAngleIndicatorPainter oldDelegate) {
    return bankAngle != oldDelegate.bankAngle;
  }
}

class AircraftSymbolPainter extends CustomPainter {
  final double pitchAngle;

  AircraftSymbolPainter({required this.pitchAngle});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    
    final paint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round;

    // Aircraft symbol (fixed center)
    // Fuselage
    canvas.drawLine(
      Offset(center.dx - 25, center.dy),
      Offset(center.dx + 25, center.dy),
      paint,
    );
    
    // Wings
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 15),
      paint,
    );
    
    // Center dot
    paint.style = PaintingStyle.fill;
    canvas.drawCircle(center, 3, paint);
  }

  @override
  bool shouldRepaint(AircraftSymbolPainter oldDelegate) {
    return pitchAngle != oldDelegate.pitchAngle;
  }
}

class TargetBearingPainter extends CustomPainter {
  final double trueBearing;
  final double magneticBearing;
  final double relativeBearing;
  final double currentHeading;
  final double? requiredHeading;

  TargetBearingPainter({
    required this.trueBearing,
    required this.magneticBearing,
    required this.relativeBearing,
    required this.currentHeading,
    this.requiredHeading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Target bearing arrow
    _drawTargetArrow(canvas, center, radius, relativeBearing);
    
    // Required heading indicator (if wind correction needed)
    if (requiredHeading != null) {
      final requiredRelative = requiredHeading! - currentHeading;
      _drawRequiredHeading(canvas, center, radius, requiredRelative);
    }
  }

  void _drawTargetArrow(Canvas canvas, Offset center, double radius, double bearing) {
    final paint = Paint()
      ..color = AppColors.brandPrimary
      ..style = PaintingStyle.fill
      ..strokeWidth = 3;
    
    final angleRad = bearing * math.pi / 180;
    final arrowRadius = radius - 60;
    
    final arrowTip = Offset(
      center.dx + arrowRadius * math.sin(angleRad),
      center.dy - arrowRadius * math.cos(angleRad),
    );
    
    // Arrow head
    final path = Path();
    path.moveTo(arrowTip.dx, arrowTip.dy);
    path.lineTo(
      arrowTip.dx - 12 * math.sin(angleRad - 0.5),
      arrowTip.dy + 12 * math.cos(angleRad - 0.5),
    );
    path.lineTo(
      arrowTip.dx - 12 * math.sin(angleRad + 0.5),
      arrowTip.dy + 12 * math.cos(angleRad + 0.5),
    );
    path.close();
    
    canvas.drawPath(path, paint);
    
    // Arrow shaft
    paint.style = PaintingStyle.stroke;
    canvas.drawLine(
      center,
      Offset(
        center.dx + (arrowRadius - 15) * math.sin(angleRad),
        center.dy - (arrowRadius - 15) * math.cos(angleRad),
      ),
      paint,
    );
  }

  void _drawRequiredHeading(Canvas canvas, Offset center, double radius, double bearing) {
    final paint = Paint()
      ..color = AppColors.semanticWarning
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final angleRad = bearing * math.pi / 180;
    final indicatorRadius = radius - 45;
    
    // Dashed line for required heading
    _drawDashedLine(
      canvas,
      center,
      Offset(
        center.dx + indicatorRadius * math.sin(angleRad),
        center.dy - indicatorRadius * math.cos(angleRad),
      ),
      paint,
    );
  }

  void _drawDashedLine(Canvas canvas, Offset start, Offset end, Paint paint) {
    const dashLength = 5.0;
    const dashSpace = 3.0;
    
    final distance = (end - start).distance;
    final dashCount = (distance / (dashLength + dashSpace)).floor();
    
    final stepX = (end.dx - start.dx) / dashCount;
    final stepY = (end.dy - start.dy) / dashCount;
    
    for (int i = 0; i < dashCount; i += 2) {
      final dashStart = Offset(
        start.dx + stepX * i,
        start.dy + stepY * i,
      );
      final dashEnd = Offset(
        start.dx + stepX * (i + 1),
        start.dy + stepY * (i + 1),
      );
      
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  @override
  bool shouldRepaint(TargetBearingPainter oldDelegate) {
    return trueBearing != oldDelegate.trueBearing ||
           relativeBearing != oldDelegate.relativeBearing ||
           requiredHeading != oldDelegate.requiredHeading;
  }
}

class WindVectorPainter extends CustomPainter {
  final double windSpeed;
  final double windDirection;
  final double currentHeading;

  WindVectorPainter({
    required this.windSpeed,
    required this.windDirection,
    required this.currentHeading,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (windSpeed < 1) return; // Don't draw in calm conditions
    
    final center = Offset(size.width / 2, size.height / 2);
    final windRelative = windDirection - currentHeading;
    final angleRad = windRelative * math.pi / 180;
    
    // Wind vector length based on speed (scale to screen)
    final vectorLength = math.min(windSpeed * 3, size.width / 4);
    
    final paint = Paint()
      ..color = AppColors.semanticInfo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    final windEnd = Offset(
      center.dx + vectorLength * math.sin(angleRad),
      center.dy - vectorLength * math.cos(angleRad),
    );
    
    // Wind vector line
    canvas.drawLine(center, windEnd, paint);
    
    // Wind barbs or arrow head
    _drawWindBarbs(canvas, windEnd, angleRad, windSpeed);
  }

  void _drawWindBarbs(Canvas canvas, Offset point, double angle, double speed) {
    final paint = Paint()
      ..color = AppColors.semanticInfo
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Simple arrow head for now
    final barbLength = 10.0;
    final barb1 = Offset(
      point.dx - barbLength * math.sin(angle - 0.5),
      point.dy + barbLength * math.cos(angle - 0.5),
    );
    
    final barb2 = Offset(
      point.dx - barbLength * math.sin(angle + 0.5),
      point.dy + barbLength * math.cos(angle + 0.5),
    );
    
    canvas.drawLine(point, barb1, paint);
    canvas.drawLine(point, barb2, paint);
  }

  @override
  bool shouldRepaint(WindVectorPainter oldDelegate) {
    return windSpeed != oldDelegate.windSpeed ||
           windDirection != oldDelegate.windDirection ||
           currentHeading != oldDelegate.currentHeading;
  }
}