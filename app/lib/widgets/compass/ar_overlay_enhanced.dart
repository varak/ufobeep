import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';
import '../../services/compass_math.dart';

/// Enhanced AR overlay with realistic visualization
class AROverlayEnhanced extends StatefulWidget {
  const AROverlayEnhanced({
    super.key,
    required this.compassData,
    this.targets = const [],
    this.showGrid = true,
    this.showHorizon = true,
    this.fieldOfView = 60.0,
  });

  final CompassData compassData;
  final List<CompassTarget> targets;
  final bool showGrid;
  final bool showHorizon;
  final double fieldOfView;

  @override
  State<AROverlayEnhanced> createState() => _AROverlayEnhancedState();
}

class _AROverlayEnhancedState extends State<AROverlayEnhanced>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..repeat(reverse: true);
    
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return Container(
          width: constraints.maxWidth,
          height: constraints.maxHeight,
          child: Stack(
            children: [
              // Camera view or placeholder
              _buildCameraView(),
              
              // AR grid overlay
              if (widget.showGrid) _buildARGrid(constraints),
              
              // Horizon line
              if (widget.showHorizon) _buildHorizonLine(constraints),
              
              // Compass ribbon at top
              _buildCompassRibbon(constraints),
              
              // Target indicators
              ..._buildTargetIndicators(constraints),
              
              // HUD information
              _buildHUD(constraints),
              
              // Calibration warning if needed
              if (widget.compassData.needsCalibration)
                _buildCalibrationWarning(constraints),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCameraView() {
    // In production, this would be the actual camera feed
    // For now, we'll use a gradient to simulate sky view
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Color(0xFF001a33), // Deep night sky
            Color(0xFF003366), // Horizon blue
            Color(0xFF004080), // Ground
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
      ),
      child: CustomPaint(
        painter: StarfieldPainter(
          heading: widget.compassData.trueHeading,
        ),
      ),
    );
  }

  Widget _buildARGrid(BoxConstraints constraints) {
    return CustomPaint(
      size: Size(constraints.maxWidth, constraints.maxHeight),
      painter: ARGridPainter(
        heading: widget.compassData.trueHeading,
        fieldOfView: widget.fieldOfView,
      ),
    );
  }

  Widget _buildHorizonLine(BoxConstraints constraints) {
    return Positioned(
      top: constraints.maxHeight / 2,
      left: 0,
      right: 0,
      child: Container(
        height: 2,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.transparent,
              AppColors.brandPrimary.withOpacity(0.5),
              AppColors.brandPrimary.withOpacity(0.5),
              Colors.transparent,
            ],
            stops: const [0.0, 0.2, 0.8, 1.0],
          ),
        ),
      ),
    );
  }

  Widget _buildCompassRibbon(BoxConstraints constraints) {
    return Positioned(
      top: 40,
      left: 0,
      right: 0,
      height: 60,
      child: CustomPaint(
        painter: CompassRibbonPainter(
          heading: widget.compassData.trueHeading,
          fieldOfView: widget.fieldOfView,
        ),
      ),
    );
  }

  List<Widget> _buildTargetIndicators(BoxConstraints constraints) {
    final indicators = <Widget>[];
    
    for (final target in widget.targets) {
      if (widget.compassData.location == null) continue;
      
      final bearing = widget.compassData.bearingToTarget(target.location);
      final relativeBearing = CompassMath.relativeBearing(
        widget.compassData.trueHeading,
        bearing,
      );
      
      // Check if target is within field of view
      if (relativeBearing.abs() <= widget.fieldOfView / 2) {
        final xPosition = constraints.maxWidth / 2 + 
            (relativeBearing / (widget.fieldOfView / 2)) * (constraints.maxWidth / 2);
        
        indicators.add(
          _buildTargetIndicator(
            target: target,
            xPosition: xPosition,
            yPosition: constraints.maxHeight / 2,
            constraints: constraints,
          ),
        );
      }
    }
    
    return indicators;
  }

  Widget _buildTargetIndicator({
    required CompassTarget target,
    required double xPosition,
    required double yPosition,
    required BoxConstraints constraints,
  }) {
    return Positioned(
      left: xPosition - 30,
      top: yPosition - 30,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: target.type == TargetType.alert ? _pulseAnimation.value : 1.0,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _getTargetColor(target.type).withOpacity(0.2),
                border: Border.all(
                  color: _getTargetColor(target.type),
                  width: 2,
                ),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _getTargetIcon(target.type),
                    color: _getTargetColor(target.type),
                    size: 24,
                  ),
                  const SizedBox(height: 2),
                  Text(
                    target.formattedDistance,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHUD(BoxConstraints constraints) {
    return Positioned(
      bottom: 20,
      left: 20,
      right: 20,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.brandPrimary.withOpacity(0.3),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Heading info
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'HEADING',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${widget.compassData.formattedHeading} ${widget.compassData.cardinalDirection}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            
            // Location info
            if (widget.compassData.location != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'LOCATION',
                    style: TextStyle(
                      color: AppColors.brandPrimary,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    '${widget.compassData.location!.latitude.toStringAsFixed(4)}, '
                    '${widget.compassData.location!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            
            // Accuracy indicator
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'ACCURACY',
                  style: TextStyle(
                    color: AppColors.brandPrimary,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '±${widget.compassData.accuracy.toStringAsFixed(0)}°',
                  style: TextStyle(
                    color: widget.compassData.isAccurate 
                        ? Colors.green 
                        : Colors.orange,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalibrationWarning(BoxConstraints constraints) {
    return Positioned(
      top: 120,
      left: 20,
      right: 20,
      child: AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Opacity(
            opacity: 0.5 + (_pulseAnimation.value - 1.0) * 2.5,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.semanticWarning.withOpacity(0.9),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 16,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Compass needs calibration',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
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

  IconData _getTargetIcon(TargetType type) {
    switch (type) {
      case TargetType.alert:
        return Icons.warning_amber;
      case TargetType.emergency:
        return Icons.emergency;
      case TargetType.waypoint:
        return Icons.location_on;
      case TargetType.landmark:
        return Icons.landscape;
    }
  }
}

/// Painter for the AR grid overlay
class ARGridPainter extends CustomPainter {
  final double heading;
  final double fieldOfView;

  ARGridPainter({
    required this.heading,
    required this.fieldOfView,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.brandPrimary.withOpacity(0.1)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    // Draw vertical lines
    const verticalSpacing = 30.0;
    for (double x = 0; x < size.width; x += verticalSpacing) {
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        paint,
      );
    }

    // Draw horizontal lines with perspective
    final horizonY = size.height / 2;
    const horizontalLines = 10;
    
    for (int i = 0; i < horizontalLines; i++) {
      final progress = i / horizontalLines;
      final y = horizonY + (size.height - horizonY) * progress;
      
      // Create perspective effect
      final perspectiveFactor = math.pow(progress, 1.5);
      final lineOpacity = 0.1 * (1 - perspectiveFactor);
      
      paint.color = AppColors.brandPrimary.withOpacity(lineOpacity);
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(ARGridPainter oldDelegate) {
    return heading != oldDelegate.heading;
  }
}

/// Painter for the compass ribbon at the top
class CompassRibbonPainter extends CustomPainter {
  final double heading;
  final double fieldOfView;

  CompassRibbonPainter({
    required this.heading,
    required this.fieldOfView,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    // Background
    paint.color = Colors.black.withOpacity(0.5);
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);

    // Draw compass markings
    final center = size.width / 2;
    final degreesPerPixel = fieldOfView / size.width;

    paint.style = PaintingStyle.stroke;
    paint.strokeWidth = 2;

    // Draw degree markings
    for (int degree = 0; degree < 360; degree += 10) {
      final relativeDegree = CompassMath.relativeBearing(heading, degree.toDouble());
      
      if (relativeDegree.abs() <= fieldOfView / 2) {
        final x = center + (relativeDegree / degreesPerPixel);
        
        final isCardinal = degree % 90 == 0;
        final isMajor = degree % 30 == 0;
        
        paint.color = isCardinal 
            ? AppColors.brandPrimary 
            : isMajor 
                ? AppColors.textSecondary 
                : AppColors.textTertiary;
        
        final height = isCardinal ? 20.0 : isMajor ? 15.0 : 10.0;
        
        canvas.drawLine(
          Offset(x, size.height - height),
          Offset(x, size.height),
          paint,
        );
        
        // Draw labels for major marks
        if (isMajor) {
          final label = CompassMath.degreesToCardinal(degree.toDouble(), useIntercardinals: false);
          final textPainter = TextPainter(
            text: TextSpan(
              text: label,
              style: TextStyle(
                color: isCardinal ? AppColors.brandPrimary : AppColors.textSecondary,
                fontSize: isCardinal ? 14 : 12,
                fontWeight: isCardinal ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            textDirection: TextDirection.ltr,
          );
          
          textPainter.layout();
          textPainter.paint(
            canvas,
            Offset(x - textPainter.width / 2, 10),
          );
        }
      }
    }

    // Center indicator
    paint.color = AppColors.brandPrimary;
    paint.style = PaintingStyle.fill;
    final centerPath = Path();
    centerPath.moveTo(center - 8, 0);
    centerPath.lineTo(center + 8, 0);
    centerPath.lineTo(center, 10);
    centerPath.close();
    canvas.drawPath(centerPath, paint);
  }

  @override
  bool shouldRepaint(CompassRibbonPainter oldDelegate) {
    return heading != oldDelegate.heading;
  }
}

/// Painter for starfield background
class StarfieldPainter extends CustomPainter {
  final double heading;
  final List<Star> stars;

  StarfieldPainter({required this.heading}) 
      : stars = _generateStars(100);

  static List<Star> _generateStars(int count) {
    final random = math.Random(42); // Fixed seed for consistent stars
    return List.generate(count, (index) {
      return Star(
        x: random.nextDouble(),
        y: random.nextDouble() * 0.5, // Only in upper half
        brightness: random.nextDouble(),
        size: random.nextDouble() * 2 + 0.5,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.fill;

    for (final star in stars) {
      // Offset stars based on heading for parallax effect
      final x = (star.x * size.width + heading * 2) % size.width;
      final y = star.y * size.height;
      
      paint.color = Colors.white.withOpacity(star.brightness * 0.8);
      canvas.drawCircle(Offset(x, y), star.size, paint);
    }
  }

  @override
  bool shouldRepaint(StarfieldPainter oldDelegate) {
    return heading != oldDelegate.heading;
  }
}

class Star {
  final double x;
  final double y;
  final double brightness;
  final double size;

  Star({
    required this.x,
    required this.y,
    required this.brightness,
    required this.size,
  });
}