import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class UFOLogo extends StatefulWidget {
  final double size;
  final bool animate;
  final Color? primaryColor;

  const UFOLogo({
    super.key,
    this.size = 120,
    this.animate = true,
    this.primaryColor,
  });

  @override
  State<UFOLogo> createState() => _UFOLogoState();
}

class _UFOLogoState extends State<UFOLogo>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _lightsController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _lightsAnimation;

  @override
  void initState() {
    super.initState();
    
    if (widget.animate) {
      _pulseController = AnimationController(
        duration: const Duration(seconds: 2),
        vsync: this,
      );
      
      _lightsController = AnimationController(
        duration: const Duration(milliseconds: 1500),
        vsync: this,
      );

      _pulseAnimation = Tween<double>(
        begin: 0.9,
        end: 1.1,
      ).animate(CurvedAnimation(
        parent: _pulseController,
        curve: Curves.easeInOut,
      ));

      _lightsAnimation = Tween<double>(
        begin: 0.3,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: _lightsController,
        curve: Curves.easeInOut,
      ));

      _pulseController.repeat(reverse: true);
      _lightsController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    if (widget.animate) {
      _pulseController.dispose();
      _lightsController.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = widget.primaryColor ?? AppColors.brandPrimary;
    
    if (!widget.animate) {
      return _buildUFO(1.0, primaryColor, 0.8);
    }

    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return AnimatedBuilder(
          animation: _lightsAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: _buildUFO(_pulseAnimation.value, primaryColor, _lightsAnimation.value),
            );
          },
        );
      },
    );
  }

  Widget _buildUFO(double scale, Color primaryColor, double lightsOpacity) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: CustomPaint(
        painter: UFOPainter(
          primaryColor: primaryColor,
          lightsOpacity: lightsOpacity,
        ),
      ),
    );
  }
}

class UFOPainter extends CustomPainter {
  final Color primaryColor;
  final double lightsOpacity;

  UFOPainter({
    required this.primaryColor,
    required this.lightsOpacity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final bodyCenter = Offset(size.width / 2, size.height * 0.45);
    final domeCenter = Offset(size.width / 2, size.height * 0.35);

    // Light beam
    final beamPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          primaryColor.withOpacity(0.6),
          primaryColor.withOpacity(0.3),
          primaryColor.withOpacity(0.1),
        ],
      ).createShader(Rect.fromLTWH(
        size.width * 0.25,
        size.height * 0.55,
        size.width * 0.5,
        size.height * 0.35,
      ));

    final beamPath = Path()
      ..moveTo(size.width * 0.35, size.height * 0.55)
      ..lineTo(size.width * 0.25, size.height * 0.9)
      ..lineTo(size.width * 0.75, size.height * 0.9)
      ..lineTo(size.width * 0.65, size.height * 0.55)
      ..close();

    canvas.drawPath(beamPath, beamPaint);

    // UFO Body (main disc)
    final bodyPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          const Color(0xFF4A5568).withOpacity(0.9),
          const Color(0xFF2D3748).withOpacity(0.95),
          const Color(0xFF1A202C),
        ],
      ).createShader(Rect.fromCenter(
        center: bodyCenter,
        width: size.width * 0.75,
        height: size.height * 0.25,
      ))
      ..style = PaintingStyle.fill;

    final bodyBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;

    canvas.drawOval(
      Rect.fromCenter(
        center: bodyCenter,
        width: size.width * 0.75,
        height: size.height * 0.25,
      ),
      bodyPaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: bodyCenter,
        width: size.width * 0.75,
        height: size.height * 0.25,
      ),
      bodyBorderPaint,
    );

    // UFO Dome
    final domePaint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(0, -0.3),
        radius: 0.7,
        colors: [
          primaryColor.withOpacity(0.3),
          const Color(0xFF2D3748).withOpacity(0.6),
          const Color(0xFF1A202C).withOpacity(0.8),
        ],
      ).createShader(Rect.fromCenter(
        center: domeCenter,
        width: size.width * 0.42,
        height: size.height * 0.25,
      ))
      ..style = PaintingStyle.fill;

    final domeBorderPaint = Paint()
      ..color = primaryColor.withOpacity(0.8)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;

    canvas.drawOval(
      Rect.fromCenter(
        center: domeCenter,
        width: size.width * 0.42,
        height: size.height * 0.25,
      ),
      domePaint,
    );

    canvas.drawOval(
      Rect.fromCenter(
        center: domeCenter,
        width: size.width * 0.42,
        height: size.height * 0.25,
      ),
      domeBorderPaint,
    );

    // UFO Lights
    final lightPaint = Paint()
      ..color = primaryColor.withOpacity(lightsOpacity * 0.8);

    final lightPositions = [
      Offset(size.width * 0.3, bodyCenter.dy),
      Offset(size.width * 0.42, bodyCenter.dy - size.height * 0.02),
      Offset(size.width * 0.58, bodyCenter.dy - size.height * 0.02),
      Offset(size.width * 0.7, bodyCenter.dy),
    ];

    final lightSizes = [3.0, 2.5, 2.5, 3.0];

    for (int i = 0; i < lightPositions.length; i++) {
      canvas.drawCircle(lightPositions[i], lightSizes[i], lightPaint);
    }

    // Center light
    final centerLightPaint = Paint()
      ..color = primaryColor.withOpacity(lightsOpacity * 0.9);

    canvas.drawCircle(
      Offset(size.width / 2, bodyCenter.dy + size.height * 0.08),
      4,
      centerLightPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}