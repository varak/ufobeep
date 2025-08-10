import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../models/compass_data.dart';
import '../../theme/app_theme.dart';

/// Interactive compass calibration dialog with visual guidance
class CompassCalibrationDialog extends StatefulWidget {
  const CompassCalibrationDialog({
    super.key,
    required this.currentCalibration,
  });

  final CompassCalibrationLevel currentCalibration;

  @override
  State<CompassCalibrationDialog> createState() => _CompassCalibrationDialogState();
}

class _CompassCalibrationDialogState extends State<CompassCalibrationDialog>
    with TickerProviderStateMixin {
  late AnimationController _rotationController;
  late AnimationController _progressController;
  late Animation<double> _rotationAnimation;
  late Animation<double> _progressAnimation;
  
  int _calibrationStep = 0;
  bool _isCalibrating = false;
  double _calibrationProgress = 0.0;

  @override
  void initState() {
    super.initState();
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..repeat();
    
    _progressController = AnimationController(
      duration: const Duration(seconds: 10),
      vsync: this,
    );
    
    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));
    
    _progressAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    ));
    
    _progressAnimation.addListener(() {
      setState(() {
        _calibrationProgress = _progressAnimation.value;
        
        // Update step based on progress
        if (_calibrationProgress < 0.33) {
          _calibrationStep = 0;
        } else if (_calibrationProgress < 0.66) {
          _calibrationStep = 1;
        } else if (_calibrationProgress < 0.99) {
          _calibrationStep = 2;
        } else {
          _calibrationStep = 3;
          _isCalibrating = false;
        }
      });
    });
  }

  @override
  void dispose() {
    _rotationController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  void _startCalibration() {
    setState(() {
      _isCalibrating = true;
      _calibrationProgress = 0.0;
      _calibrationStep = 0;
    });
    
    _progressController.forward(from: 0);
    
    // Simulate calibration completion
    Future.delayed(const Duration(seconds: 10), () {
      if (mounted) {
        Navigator.of(context).pop(true);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: AppColors.darkSurface,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHeader(),
            const SizedBox(height: 24),
            _buildCalibrationVisual(),
            const SizedBox(height: 24),
            _buildInstructions(),
            const SizedBox(height: 20),
            _buildProgressIndicator(),
            const SizedBox(height: 24),
            _buildActions(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      children: [
        Icon(
          Icons.explore,
          size: 48,
          color: AppColors.brandPrimary,
        ),
        const SizedBox(height: 12),
        Text(
          'Compass Calibration',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: _getCalibrationColor(widget.currentCalibration).withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getCalibrationColor(widget.currentCalibration),
            ),
          ),
          child: Text(
            'Current: ${widget.currentCalibration.displayName}',
            style: TextStyle(
              color: _getCalibrationColor(widget.currentCalibration),
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCalibrationVisual() {
    return Container(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle
          Container(
            width: 180,
            height: 180,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: AppColors.darkBorder,
                width: 2,
              ),
            ),
          ),
          
          // Animated rotation indicator
          if (_isCalibrating)
            AnimatedBuilder(
              animation: _rotationAnimation,
              builder: (context, child) {
                return Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: CustomPaint(
                    size: const Size(160, 160),
                    painter: CalibrationPatternPainter(
                      progress: _calibrationProgress,
                      step: _calibrationStep,
                    ),
                  ),
                );
              },
            ),
          
          // Center device icon
          Container(
            width: 60,
            height: 100,
            decoration: BoxDecoration(
              color: AppColors.darkBackground,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: _isCalibrating 
                    ? AppColors.brandPrimary 
                    : AppColors.darkBorder,
                width: 2,
              ),
            ),
            child: Icon(
              Icons.phone_android,
              color: _isCalibrating 
                  ? AppColors.brandPrimary 
                  : AppColors.textSecondary,
              size: 32,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInstructions() {
    final instructions = [
      'Hold device away from metal objects',
      'Rotate device in figure-8 pattern',
      'Complete 3-4 full rotations',
      'Calibration complete!',
    ];
    
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        children: [
          Text(
            _isCalibrating 
                ? instructions[_calibrationStep]
                : 'Follow these steps to calibrate:',
            style: TextStyle(
              color: AppColors.textPrimary,
              fontSize: 14,
              fontWeight: _isCalibrating ? FontWeight.bold : FontWeight.normal,
            ),
            textAlign: TextAlign.center,
          ),
          if (!_isCalibrating) ...[
            const SizedBox(height: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: instructions.take(3).map((instruction) {
                final index = instructions.indexOf(instruction);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: [
                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.brandPrimary.withOpacity(0.2),
                          border: Border.all(color: AppColors.brandPrimary),
                        ),
                        child: Center(
                          child: Text(
                            '${index + 1}',
                            style: TextStyle(
                              color: AppColors.brandPrimary,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          instruction,
                          style: TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: _calibrationProgress,
            minHeight: 8,
            backgroundColor: AppColors.darkBorder,
            valueColor: AlwaysStoppedAnimation<Color>(
              _calibrationProgress < 0.33 
                  ? Colors.orange
                  : _calibrationProgress < 0.66
                      ? Colors.yellow
                      : Colors.green,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _isCalibrating 
              ? '${(_calibrationProgress * 100).toInt()}% Complete'
              : 'Ready to calibrate',
          style: TextStyle(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildActions() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton(
          onPressed: _isCalibrating ? null : () => Navigator.of(context).pop(false),
          child: Text(
            'Cancel',
            style: TextStyle(
              color: _isCalibrating 
                  ? AppColors.textTertiary 
                  : AppColors.textSecondary,
            ),
          ),
        ),
        ElevatedButton.icon(
          onPressed: _isCalibrating ? null : _startCalibration,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.brandPrimary,
            foregroundColor: Colors.black,
            disabledBackgroundColor: AppColors.brandPrimary.withOpacity(0.3),
          ),
          icon: Icon(
            _isCalibrating ? Icons.autorenew : Icons.play_arrow,
            size: 20,
          ),
          label: Text(
            _isCalibrating ? 'Calibrating...' : 'Start Calibration',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Color _getCalibrationColor(CompassCalibrationLevel level) {
    switch (level) {
      case CompassCalibrationLevel.high:
        return Colors.green;
      case CompassCalibrationLevel.medium:
        return Colors.orange;
      case CompassCalibrationLevel.low:
        return Colors.red;
      case CompassCalibrationLevel.unknown:
        return AppColors.textTertiary;
    }
  }
}

class CalibrationPatternPainter extends CustomPainter {
  final double progress;
  final int step;

  CalibrationPatternPainter({
    required this.progress,
    required this.step,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;
    
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;

    // Draw figure-8 pattern
    if (step >= 0) {
      paint.color = AppColors.brandPrimary.withOpacity(0.3 + progress * 0.7);
      
      // Top loop of figure-8
      final topCenter = Offset(center.dx, center.dy - radius / 3);
      canvas.drawArc(
        Rect.fromCircle(center: topCenter, radius: radius / 3),
        -math.pi / 2,
        math.pi * 2 * progress,
        false,
        paint,
      );
      
      // Bottom loop of figure-8
      if (progress > 0.5) {
        final bottomCenter = Offset(center.dx, center.dy + radius / 3);
        canvas.drawArc(
          Rect.fromCircle(center: bottomCenter, radius: radius / 3),
          math.pi / 2,
          math.pi * 2 * (progress - 0.5),
          false,
          paint,
        );
      }
    }

    // Draw progress dots
    const dotCount = 8;
    for (int i = 0; i < dotCount; i++) {
      final angle = (i / dotCount) * 2 * math.pi - math.pi / 2;
      final dotProgress = (progress * dotCount - i).clamp(0.0, 1.0);
      
      if (dotProgress > 0) {
        final dotX = center.dx + radius * 0.8 * math.cos(angle);
        final dotY = center.dy + radius * 0.8 * math.sin(angle);
        
        paint.style = PaintingStyle.fill;
        paint.color = AppColors.brandPrimary.withOpacity(dotProgress);
        canvas.drawCircle(Offset(dotX, dotY), 4, paint);
      }
    }
  }

  @override
  bool shouldRepaint(CalibrationPatternPainter oldDelegate) {
    return progress != oldDelegate.progress || step != oldDelegate.step;
  }
}