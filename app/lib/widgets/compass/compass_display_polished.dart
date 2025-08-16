import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';
import '../../services/compass_math.dart';

/// Polished compass display with smooth animations and improved visuals
class CompassDisplayPolished extends StatefulWidget {
  const CompassDisplayPolished({
    super.key,
    required this.compassData,
    this.targets = const [],
    this.size = 300.0,
    this.showTargetLines = true,
    this.animationDuration = const Duration(milliseconds: 300),
  });

  final CompassData compassData;
  final List<CompassTarget> targets;
  final double size;
  final bool showTargetLines;
  final Duration animationDuration;

  @override
  State<CompassDisplayPolished> createState() => _CompassDisplayPolishedState();
}

class _CompassDisplayPolishedState extends State<CompassDisplayPolished>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _pulseController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _pulseAnimation;
  
  double _previousHeading = 0.0;
  double _targetHeading = 0.0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: widget.animationDuration,
      vsync: this,
    );
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    _targetHeading = widget.compassData.trueHeading;
    _previousHeading = _targetHeading;
    _rotationAnimation = Tween<double>(
      begin: _previousHeading,
      end: _targetHeading,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.easeInOutCubic,
    ));
  }

  @override
  void didUpdateWidget(CompassDisplayPolished oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (oldWidget.compassData.trueHeading != widget.compassData.trueHeading) {
      _previousHeading = _rotationAnimation.value;
      _targetHeading = widget.compassData.trueHeading;
      
      // Handle wrapping around 360 degrees
      double diff = _targetHeading - _previousHeading;
      if (diff > 180) {
        _targetHeading -= 360;
      } else if (diff < -180) {
        _targetHeading += 360;
      }
      
      // Only animate if the change is significant enough (reduces micro-jitter)
      if (diff.abs() > 0.5) {
        _rotationAnimation = Tween<double>(
          begin: _previousHeading,
          end: _targetHeading,
        ).animate(CurvedAnimation(
          parent: _rotationController,
          curve: Curves.easeInOutCubic,
        ));
        
        _rotationController.forward(from: 0);
      } else {
        // For very small changes, just update immediately without animation
        _targetHeading = _previousHeading;
      }
    }
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_rotationAnimation, _pulseAnimation]),
        builder: (context, child) {
          return CustomPaint(
            painter: CompassPainter(
              heading: _rotationAnimation.value,
              magneticHeading: widget.compassData.magneticHeading,
              accuracy: widget.compassData.accuracy,
              calibration: widget.compassData.calibration,
              targets: widget.targets,
              currentLocation: widget.compassData.location,
              showTargetLines: widget.showTargetLines,
              pulseValue: _pulseAnimation.value,
            ),
            child: _buildCenterDisplay(),
          );
        },
      ),
    );
  }

  Widget _buildCenterDisplay() {
    return Center(
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: RadialGradient(
            colors: [
              AppColors.darkSurface,
              AppColors.darkSurface.withOpacity(0.9),
              AppColors.darkBackground.withOpacity(0.8),
            ],
            stops: const [0.0, 0.7, 1.0],
          ),
          border: Border.all(
            color: AppColors.brandPrimary.withOpacity(0.3),
            width: 2,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.brandPrimary.withOpacity(0.2),
              blurRadius: 20,
              spreadRadius: 2,
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              widget.compassData.cardinalDirection,
              style: TextStyle(
                color: AppColors.brandPrimary,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                shadows: [
                  Shadow(
                    color: AppColors.brandPrimary.withOpacity(0.5),
                    blurRadius: 10,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${widget.compassData.trueHeading.toStringAsFixed(1)}°',
              style: const TextStyle(
                color: AppColors.textPrimary,
                fontSize: 18,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (widget.compassData.accuracy > 15)
              Icon(
                Icons.warning,
                color: AppColors.semanticWarning,
                size: 12,
              ),
          ],
        ),
      ),
    );
  }
}

class CompassPainter extends CustomPainter {
  final double heading;
  final double magneticHeading;
  final double accuracy;
  final CompassCalibrationLevel calibration;
  final List<CompassTarget> targets;
  final LocationData? currentLocation;
  final bool showTargetLines;
  final double pulseValue;

  CompassPainter({
    required this.heading,
    required this.magneticHeading,
    required this.accuracy,
    required this.calibration,
    required this.targets,
    required this.currentLocation,
    required this.showTargetLines,
    required this.pulseValue,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    // Draw outer rings
    _drawOuterRings(canvas, center, radius);
    
    // Draw compass rose
    _drawCompassRose(canvas, center, radius);
    
    // Draw cardinal directions
    _drawCardinalDirections(canvas, center, radius);
    
    // Draw degree markings
    _drawDegreeMarkings(canvas, center, radius);
    
    // Draw targets
    _drawTargets(canvas, center, radius);
    
    // Draw north indicator
    _drawNorthIndicator(canvas, center, radius);
    
    // Draw accuracy arc
    _drawAccuracyArc(canvas, center, radius);
  }

  void _drawOuterRings(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke;

    // Outer ring with gradient effect
    paint.shader = RadialGradient(
      colors: [
        AppColors.brandPrimary.withOpacity(0.3),
        AppColors.brandPrimary.withOpacity(0.1),
      ],
    ).createShader(Rect.fromCircle(center: center, radius: radius));
    paint.strokeWidth = 3;
    canvas.drawCircle(center, radius - 5, paint);

    // Inner ring
    paint.shader = null;
    paint.color = AppColors.darkBorder.withOpacity(0.5);
    paint.strokeWidth = 1;
    canvas.drawCircle(center, radius - 20, paint);
    
    // Pulsing ring for poor calibration
    if (calibration == CompassCalibrationLevel.low) {
      paint.color = AppColors.semanticWarning.withOpacity(0.3 * pulseValue);
      paint.strokeWidth = 2;
      canvas.drawCircle(center, radius - 12, paint);
    }
  }

  void _drawCompassRose(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Draw stylized compass rose
    for (int i = 0; i < 4; i++) {
      canvas.save();
      canvas.rotate(i * math.pi / 2);
      
      // Main cardinal point
      final path = Path();
      path.moveTo(0, -radius + 25);
      path.lineTo(-8, -radius + 45);
      path.lineTo(0, -radius + 35);
      path.lineTo(8, -radius + 45);
      path.close();
      
      paint.color = i == 0 
          ? AppColors.semanticError // North is red
          : AppColors.textSecondary;
      canvas.drawPath(path, paint);
      
      canvas.restore();
    }

    canvas.restore();
  }

  void _drawCardinalDirections(Canvas canvas, Offset center, double radius) {
    final directions = ['N', 'E', 'S', 'W'];
    final textPainter = TextPainter(textDirection: TextDirection.ltr);

    for (int i = 0; i < 4; i++) {
      final angle = (i * 90 - heading) * math.pi / 180;
      final labelRadius = radius - 35;
      final x = center.dx + labelRadius * math.sin(angle);
      final y = center.dy - labelRadius * math.cos(angle);

      textPainter.text = TextSpan(
        text: directions[i],
        style: TextStyle(
          color: i == 0 && (heading < 15 || heading > 345)
              ? AppColors.brandPrimary
              : AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
          shadows: [
            Shadow(
              color: Colors.black.withOpacity(0.5),
              offset: const Offset(1, 1),
              blurRadius: 2,
            ),
          ],
        ),
      );
      
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, y - textPainter.height / 2),
      );
    }
  }

  void _drawDegreeMarkings(Canvas canvas, Offset center, double radius) {
    final paint = Paint()
      ..style = PaintingStyle.stroke;

    for (int degree = 0; degree < 360; degree += 5) {
      final angle = (degree - heading) * math.pi / 180;
      final isMajor = degree % 30 == 0;
      final isMinor = degree % 10 == 0;
      
      if (!isMajor && !isMinor && degree % 5 != 0) continue;
      
      final startRadius = radius - 5;
      final endRadius = startRadius - (isMajor ? 15 : isMinor ? 10 : 5);
      
      paint.color = isMajor 
          ? AppColors.textSecondary 
          : isMinor 
              ? AppColors.textTertiary.withOpacity(0.7)
              : AppColors.textTertiary.withOpacity(0.3);
      paint.strokeWidth = isMajor ? 2 : 1;
      
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

  void _drawTargets(Canvas canvas, Offset center, double radius) {
    if (currentLocation == null) return;

    for (final target in targets) {
      final bearing = CompassMath.calculateBearing(
        currentLocation!.latitude,
        currentLocation!.longitude,
        target.location.latitude,
        target.location.longitude,
      );
      
      final angle = (bearing - heading) * math.pi / 180;
      final targetRadius = radius - 60;
      
      final targetX = center.dx + targetRadius * math.sin(angle);
      final targetY = center.dy - targetRadius * math.cos(angle);
      
      // Draw target line if enabled
      if (showTargetLines) {
        final paint = Paint()
          ..color = _getTargetColor(target.type).withOpacity(0.3)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;
        
        canvas.drawLine(center, Offset(targetX, targetY), paint);
      }
      
      // Draw target indicator
      final paint = Paint()
        ..color = _getTargetColor(target.type);
      
      if (target.type == TargetType.alert) {
        // Pulsing effect for alerts
        paint.color = paint.color.withOpacity(0.5 + 0.5 * pulseValue);
      }
      
      canvas.drawCircle(Offset(targetX, targetY), 8, paint);
      
      // Draw target icon
      paint.color = Colors.white;
      paint.style = PaintingStyle.stroke;
      paint.strokeWidth = 2;
      canvas.drawCircle(Offset(targetX, targetY), 6, paint);
    }
  }

  void _drawNorthIndicator(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-heading * math.pi / 180);

    final paint = Paint()
      ..style = PaintingStyle.fill;

    // North arrow (distinctive design)
    final northPath = Path();
    northPath.moveTo(0, -radius + 50);
    northPath.lineTo(-12, -radius + 80);
    northPath.lineTo(-4, -radius + 75);
    northPath.lineTo(0, -radius + 85);
    northPath.lineTo(4, -radius + 75);
    northPath.lineTo(12, -radius + 80);
    northPath.close();

    // Gradient for north arrow
    paint.shader = LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        AppColors.semanticError,
        AppColors.semanticError.withOpacity(0.6),
      ],
    ).createShader(northPath.getBounds());
    
    canvas.drawPath(northPath, paint);
    
    // Add glow effect
    paint.shader = null;
    paint.color = AppColors.semanticError.withOpacity(0.3);
    paint.maskFilter = const MaskFilter.blur(BlurStyle.normal, 5);
    canvas.drawPath(northPath, paint);

    canvas.restore();
  }

  void _drawAccuracyArc(Canvas canvas, Offset center, double radius) {
    if (accuracy <= 5) return; // Don't show for very accurate readings

    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Color based on accuracy
    if (accuracy <= 15) {
      paint.color = Colors.green.withOpacity(0.5);
    } else if (accuracy <= 30) {
      paint.color = Colors.orange.withOpacity(0.5);
    } else {
      paint.color = Colors.red.withOpacity(0.5);
    }

    final rect = Rect.fromCircle(center: center, radius: radius - 15);
    final sweepAngle = accuracy * math.pi / 180;
    
    canvas.drawArc(
      rect,
      -math.pi / 2 - sweepAngle / 2,
      sweepAngle,
      false,
      paint,
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

  @override
  bool shouldRepaint(CompassPainter oldDelegate) {
    return heading != oldDelegate.heading ||
           accuracy != oldDelegate.accuracy ||
           calibration != oldDelegate.calibration ||
           pulseValue != oldDelegate.pulseValue ||
           targets.length != oldDelegate.targets.length;
  }
}