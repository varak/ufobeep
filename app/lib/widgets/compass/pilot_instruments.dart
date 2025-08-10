import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/pilot_data.dart';
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';
import '../../services/compass_math.dart';

/// Aviation-style instrument panel for pilot mode
class PilotInstrumentPanel extends StatefulWidget {
  const PilotInstrumentPanel({
    super.key,
    required this.pilotData,
    this.showAllInstruments = true,
  });

  final PilotNavigationData pilotData;
  final bool showAllInstruments;

  @override
  State<PilotInstrumentPanel> createState() => _PilotInstrumentPanelState();
}

class _PilotInstrumentPanelState extends State<PilotInstrumentPanel>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _needleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _needleAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Main instruments row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Heading Indicator (HSI)
              _buildHeadingIndicator(),
              
              // Attitude Indicator
              _buildAttitudeIndicator(),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // Secondary instruments row
          if (widget.showAllInstruments)
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Airspeed Indicator
                _buildAirspeedIndicator(),
                
                // Altimeter
                _buildAltimeter(),
                
                // Vertical Speed Indicator
                _buildVerticalSpeedIndicator(),
              ],
            ),
          
          const SizedBox(height: 16),
          
          // Navigation data strip
          _buildNavigationDataStrip(),
        ],
      ),
    );
  }

  Widget _buildHeadingIndicator() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.darkBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: CustomPaint(
        painter: HeadingIndicatorPainter(
          heading: widget.pilotData.compass.trueHeading,
          magneticHeading: widget.pilotData.compass.magneticHeading,
          solution: widget.pilotData.solution,
          wind: widget.pilotData.wind,
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'HDG',
                style: TextStyle(
                  color: AppColors.textTertiary,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                '${widget.pilotData.compass.trueHeading.toStringAsFixed(0)}°',
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (widget.pilotData.solution != null)
                Text(
                  'CRS ${widget.pilotData.solution!.bearing.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 10,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAttitudeIndicator() {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.darkSurface,
        border: Border.all(color: AppColors.darkBorder, width: 2),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipOval(
        child: CustomPaint(
          painter: AttitudeIndicatorPainter(
            bankAngle: widget.pilotData.bankAngle ?? 0,
            pitchAngle: widget.pilotData.pitchAngle ?? 0,
          ),
          child: Center(
            child: Container(
              width: 60,
              height: 2,
              color: AppColors.semanticWarning,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAirspeedIndicator() {
    final airspeed = widget.pilotData.trueAirspeed ?? 0;
    final knots = airspeed * 1.94384;
    
    return _buildGaugeInstrument(
      label: 'IAS',
      value: knots,
      unit: 'kt',
      minValue: 0,
      maxValue: 200,
      dangerZone: knots < 40 || knots > 180,
      warningZone: knots < 50 || knots > 160,
    );
  }

  Widget _buildAltimeter() {
    final altitude = widget.pilotData.altitude ?? 0;
    final feet = altitude * 3.28084;
    
    return _buildGaugeInstrument(
      label: 'ALT',
      value: feet,
      unit: 'ft',
      minValue: 0,
      maxValue: 10000,
      displayFormat: (v) => v.toStringAsFixed(0),
    );
  }

  Widget _buildVerticalSpeedIndicator() {
    final vs = widget.pilotData.verticalSpeed ?? 0;
    final fpm = vs * 196.85;
    
    return _buildGaugeInstrument(
      label: 'VS',
      value: fpm,
      unit: 'fpm',
      minValue: -2000,
      maxValue: 2000,
      centerZero: true,
      displayFormat: (v) => '${v >= 0 ? '+' : ''}${v.toStringAsFixed(0)}',
    );
  }

  Widget _buildGaugeInstrument({
    required String label,
    required double value,
    required String unit,
    required double minValue,
    required double maxValue,
    bool dangerZone = false,
    bool warningZone = false,
    bool centerZero = false,
    String Function(double)? displayFormat,
  }) {
    Color valueColor = AppColors.textPrimary;
    if (dangerZone) {
      valueColor = AppColors.semanticError;
    } else if (warningZone) {
      valueColor = AppColors.semanticWarning;
    }
    
    return Container(
      width: 80,
      height: 100,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            label,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          AnimatedBuilder(
            animation: _needleAnimation,
            builder: (context, child) {
              return Text(
                displayFormat != null 
                    ? displayFormat(value * _needleAnimation.value)
                    : value.toStringAsFixed(0),
                style: TextStyle(
                  color: valueColor,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              );
            },
          ),
          Text(
            unit,
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 10,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationDataStrip() {
    if (widget.pilotData.solution == null) {
      return Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface.withOpacity(0.5),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Center(
          child: Text(
            'No target selected',
            style: TextStyle(
              color: AppColors.textTertiary,
              fontSize: 12,
            ),
          ),
        ),
      );
    }
    
    final solution = widget.pilotData.solution!;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.darkSurface.withOpacity(0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.brandPrimary.withOpacity(0.3)),
      ),
      child: Column(
        children: [
          // Target info
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                solution.target.name,
                style: TextStyle(
                  color: AppColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                solution.distanceFormatted,
                style: TextStyle(
                  color: AppColors.brandPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 8),
          
          // Navigation data
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildNavDataItem('BRG', solution.bearingFormatted),
              _buildNavDataItem('MAG', solution.magneticBearingFormatted),
              _buildNavDataItem('REL', solution.relativeBearingFormatted),
              if (solution.estimatedTimeEnrouteFormatted != null)
                _buildNavDataItem('ETE', solution.estimatedTimeEnrouteFormatted!),
            ],
          ),
          
          // Wind component if available
          if (widget.pilotData.wind != null) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.air,
                  color: AppColors.semanticInfo,
                  size: 14,
                ),
                const SizedBox(width: 4),
                Text(
                  'Wind: ${widget.pilotData.wind!.getWindComponent(widget.pilotData.compass.trueHeading)}',
                  style: TextStyle(
                    color: AppColors.semanticInfo,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
          
          // Guidance
          const SizedBox(height: 8),
          Text(
            solution.navigationGuidance,
            style: TextStyle(
              color: AppColors.textSecondary,
              fontSize: 12,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavDataItem(String label, String value) {
    return Column(
      children: [
        Text(
          label,
          style: TextStyle(
            color: AppColors.textTertiary,
            fontSize: 10,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}

/// Painter for the heading indicator (HSI)
class HeadingIndicatorPainter extends CustomPainter {
  final double heading;
  final double magneticHeading;
  final NavigationSolution? solution;
  final WindData? wind;

  HeadingIndicatorPainter({
    required this.heading,
    required this.magneticHeading,
    this.solution,
    this.wind,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Save canvas state
    canvas.save();
    canvas.translate(center.dx, center.dy);
    
    // Rotate for heading
    canvas.rotate(-heading * math.pi / 180);
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    
    // Draw compass rose
    for (int i = 0; i < 360; i += 10) {
      final angle = i * math.pi / 180;
      final isCardinal = i % 90 == 0;
      final isMajor = i % 30 == 0;
      
      paint.color = isCardinal 
          ? AppColors.brandPrimary
          : isMajor 
              ? AppColors.textSecondary
              : AppColors.textTertiary;
      
      final startRadius = radius - 5;
      final endRadius = startRadius - (isCardinal ? 12 : isMajor ? 8 : 4);
      
      final start = Offset(
        startRadius * math.sin(angle),
        -startRadius * math.cos(angle),
      );
      final end = Offset(
        endRadius * math.sin(angle),
        -endRadius * math.cos(angle),
      );
      
      canvas.drawLine(start, end, paint);
    }
    
    // Draw course deviation indicator if solution available
    if (solution != null) {
      canvas.save();
      canvas.rotate(solution.relativeBearing * math.pi / 180);
      
      // Draw course line
      paint.color = AppColors.brandPrimary;
      paint.strokeWidth = 3;
      canvas.drawLine(
        Offset(0, -radius + 20),
        Offset(0, -radius + 40),
        paint,
      );
      
      // Draw target indicator
      final targetPath = Path();
      targetPath.moveTo(0, -radius + 25);
      targetPath.lineTo(-5, -radius + 35);
      targetPath.lineTo(5, -radius + 35);
      targetPath.close();
      
      paint.style = PaintingStyle.fill;
      canvas.drawPath(targetPath, paint);
      
      canvas.restore();
    }
    
    // Draw wind arrow if available
    if (wind != null) {
      canvas.save();
      canvas.rotate((wind.direction - heading) * math.pi / 180);
      
      paint.color = AppColors.semanticInfo;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      
      final windLength = math.min(wind.speed * 2, radius * 0.3);
      canvas.drawLine(
        Offset(0, 0),
        Offset(0, -windLength),
        paint,
      );
      
      // Wind arrow head
      canvas.drawLine(
        Offset(0, -windLength),
        Offset(-3, -windLength + 5),
        paint,
      );
      canvas.drawLine(
        Offset(0, -windLength),
        Offset(3, -windLength + 5),
        paint,
      );
      
      canvas.restore();
    }
    
    canvas.restore();
    
    // Draw fixed aircraft symbol in center
    paint.color = AppColors.semanticWarning;
    paint.style = PaintingStyle.fill;
    paint.strokeWidth = 2;
    
    // Aircraft body
    canvas.drawLine(
      Offset(center.dx, center.dy - 15),
      Offset(center.dx, center.dy + 10),
      paint,
    );
    
    // Wings
    canvas.drawLine(
      Offset(center.dx - 15, center.dy),
      Offset(center.dx + 15, center.dy),
      paint,
    );
    
    // Tail
    canvas.drawLine(
      Offset(center.dx - 5, center.dy + 8),
      Offset(center.dx + 5, center.dy + 8),
      paint,
    );
  }

  @override
  bool shouldRepaint(HeadingIndicatorPainter oldDelegate) {
    return heading != oldDelegate.heading ||
           magneticHeading != oldDelegate.magneticHeading ||
           solution != oldDelegate.solution;
  }
}

/// Painter for the attitude indicator
class AttitudeIndicatorPainter extends CustomPainter {
  final double bankAngle;
  final double pitchAngle;

  AttitudeIndicatorPainter({
    required this.bankAngle,
    required this.pitchAngle,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    // Save and clip to circle
    canvas.save();
    canvas.clipPath(Path()..addOval(Rect.fromCircle(center: center, radius: radius)));
    
    // Apply bank rotation
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-bankAngle * math.pi / 180);
    canvas.translate(-center.dx, -center.dy);
    
    // Calculate pitch offset
    final pitchOffset = pitchAngle * 2; // Scale pitch for visibility
    
    // Draw sky (blue)
    final skyPaint = Paint()
      ..color = const Color(0xFF4A90E2)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, -size.height + center.dy + pitchOffset, size.width, size.height),
      skyPaint,
    );
    
    // Draw ground (brown)
    final groundPaint = Paint()
      ..color = const Color(0xFF8B4513)
      ..style = PaintingStyle.fill;
    
    canvas.drawRect(
      Rect.fromLTWH(0, center.dy + pitchOffset, size.width, size.height),
      groundPaint,
    );
    
    // Draw horizon line
    final horizonPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    canvas.drawLine(
      Offset(0, center.dy + pitchOffset),
      Offset(size.width, center.dy + pitchOffset),
      horizonPaint,
    );
    
    // Draw pitch ladder
    final ladderPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
    
    for (int pitch = -30; pitch <= 30; pitch += 10) {
      if (pitch == 0) continue; // Skip horizon line
      
      final y = center.dy + pitchOffset - (pitch * 2);
      final lineWidth = pitch % 20 == 0 ? 30.0 : 20.0;
      
      canvas.drawLine(
        Offset(center.dx - lineWidth, y),
        Offset(center.dx + lineWidth, y),
        ladderPaint,
      );
      
      // Draw pitch angle text
      if (pitch % 20 == 0) {
        final textPainter = TextPainter(
          text: TextSpan(
            text: pitch.abs().toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 10,
            ),
          ),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(center.dx + lineWidth + 5, y - 5),
        );
      }
    }
    
    canvas.restore();
    
    // Draw bank angle indicator (fixed)
    final bankPaint = Paint()
      ..color = Colors.white
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    // Bank scale arc
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius - 10),
      -120 * math.pi / 180,
      60 * math.pi / 180,
      false,
      bankPaint,
    );
    
    // Bank angle marks
    for (int angle in [-60, -45, -30, -20, -10, 0, 10, 20, 30, 45, 60]) {
      final markAngle = (angle - 90) * math.pi / 180;
      final startRadius = radius - 10;
      final endRadius = startRadius - (angle % 30 == 0 ? 8 : 4);
      
      canvas.drawLine(
        Offset(
          center.dx + startRadius * math.cos(markAngle),
          center.dy + startRadius * math.sin(markAngle),
        ),
        Offset(
          center.dx + endRadius * math.cos(markAngle),
          center.dy + endRadius * math.sin(markAngle),
        ),
        bankPaint,
      );
    }
    
    // Bank angle pointer
    final pointerAngle = (bankAngle - 90) * math.pi / 180;
    final pointerPaint = Paint()
      ..color = AppColors.semanticWarning
      ..style = PaintingStyle.fill;
    
    final pointerPath = Path();
    final pointerRadius = radius - 15;
    pointerPath.moveTo(
      center.dx + pointerRadius * math.cos(pointerAngle),
      center.dy + pointerRadius * math.sin(pointerAngle),
    );
    pointerPath.lineTo(
      center.dx + (pointerRadius - 10) * math.cos(pointerAngle - 0.1),
      center.dy + (pointerRadius - 10) * math.sin(pointerAngle - 0.1),
    );
    pointerPath.lineTo(
      center.dx + (pointerRadius - 10) * math.cos(pointerAngle + 0.1),
      center.dy + (pointerRadius - 10) * math.sin(pointerAngle + 0.1),
    );
    pointerPath.close();
    
    canvas.drawPath(pointerPath, pointerPaint);
  }

  @override
  bool shouldRepaint(AttitudeIndicatorPainter oldDelegate) {
    return bankAngle != oldDelegate.bankAngle ||
           pitchAngle != oldDelegate.pitchAngle;
  }
}