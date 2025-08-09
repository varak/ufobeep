import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../services/initialization_service.dart';

class LoadingAnimation extends StatefulWidget {
  final double progress;
  final String message;
  final bool isError;

  const LoadingAnimation({
    super.key,
    required this.progress,
    required this.message,
    this.isError = false,
  });

  @override
  State<LoadingAnimation> createState() => _LoadingAnimationState();
}

class _LoadingAnimationState extends State<LoadingAnimation>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotationController;
  late Animation<double> _pulseAnimation;
  late Animation<double> _rotationAnimation;

  @override
  void initState() {
    super.initState();
    
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    
    _rotationController = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _rotationAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _rotationController,
      curve: Curves.linear,
    ));

    _pulseController.repeat(reverse: true);
    _rotationController.repeat();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Animated UFO Icon
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _pulseAnimation.value,
              child: AnimatedBuilder(
                animation: _rotationAnimation,
                builder: (context, child) {
                  return Transform.rotate(
                    angle: _rotationAnimation.value * 0.1, // Subtle rotation
                    child: Container(
                      width: 120,
                      height: 120,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: widget.isError
                              ? [
                                  AppColors.semanticError.withOpacity(0.3),
                                  AppColors.semanticError.withOpacity(0.1),
                                  Colors.transparent,
                                ]
                              : [
                                  AppColors.brandPrimary.withOpacity(0.3),
                                  AppColors.brandPrimary.withOpacity(0.1),
                                  Colors.transparent,
                                ],
                        ),
                      ),
                      child: Center(
                        child: Text(
                          widget.isError ? '⚠️' : '👽',
                          style: const TextStyle(fontSize: 60),
                        ),
                      ),
                    ),
                  );
                },
              ),
            );
          },
        ),
        
        const SizedBox(height: 32),
        
        // Progress Bar
        Container(
          width: 200,
          height: 6,
          decoration: BoxDecoration(
            color: AppColors.darkBorder,
            borderRadius: BorderRadius.circular(3),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 200 * widget.progress,
              height: 6,
              decoration: BoxDecoration(
                color: widget.isError 
                    ? AppColors.semanticError 
                    : AppColors.brandPrimary,
                borderRadius: BorderRadius.circular(3),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Progress Percentage
        Text(
          '${(widget.progress * 100).toInt()}%',
          style: TextStyle(
            color: widget.isError 
                ? AppColors.semanticError 
                : AppColors.brandPrimary,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        
        const SizedBox(height: 24),
        
        // Loading Message
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 300),
          child: Text(
            widget.message,
            key: ValueKey(widget.message),
            style: TextStyle(
              color: widget.isError 
                  ? AppColors.semanticError 
                  : AppColors.textSecondary,
              fontSize: 16,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        
        const SizedBox(height: 16),
        
        // Loading dots animation
        if (!widget.isError) _buildLoadingDots(),
      ],
    );
  }

  Widget _buildLoadingDots() {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(3, (index) {
            final delay = index * 0.2;
            final animationValue = (_pulseController.value + delay) % 1.0;
            final opacity = (animationValue < 0.5) 
                ? animationValue * 2 
                : (1.0 - animationValue) * 2;
            
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.brandPrimary.withOpacity(opacity.clamp(0.2, 1.0)),
              ),
            );
          }),
        );
      },
    );
  }
}

class InitializationStepIndicator extends StatelessWidget {
  final InitializationStep currentStep;
  final bool hasError;

  const InitializationStepIndicator({
    super.key,
    required this.currentStep,
    this.hasError = false,
  });

  @override
  Widget build(BuildContext context) {
    final steps = InitializationStep.values.where((step) => step != InitializationStep.complete).toList();
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      child: Column(
        children: [
          Text(
            'Initialization Steps',
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: steps.map((step) => _buildStepChip(step)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildStepChip(InitializationStep step) {
    final isActive = step.index <= currentStep.index;
    final isCompleted = step.index < currentStep.index;
    final isCurrent = step == currentStep;
    final showError = hasError && isCurrent;

    Color backgroundColor = AppColors.darkBackground;
    Color borderColor = AppColors.darkBorder;
    Color textColor = AppColors.textTertiary;
    Widget? icon;

    if (showError) {
      backgroundColor = AppColors.semanticError.withOpacity(0.1);
      borderColor = AppColors.semanticError;
      textColor = AppColors.semanticError;
      icon = const Icon(Icons.error, size: 14, color: AppColors.semanticError);
    } else if (isCompleted) {
      backgroundColor = AppColors.brandPrimary.withOpacity(0.1);
      borderColor = AppColors.brandPrimary;
      textColor = AppColors.brandPrimary;
      icon = const Icon(Icons.check, size: 14, color: AppColors.brandPrimary);
    } else if (isCurrent) {
      backgroundColor = AppColors.brandPrimary.withOpacity(0.1);
      borderColor = AppColors.brandPrimary;
      textColor = AppColors.brandPrimary;
      icon = const SizedBox(
        width: 14,
        height: 14,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(AppColors.brandPrimary),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            icon,
            const SizedBox(width: 4),
          ],
          Text(
            _getStepName(step),
            style: TextStyle(
              color: textColor,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  String _getStepName(InitializationStep step) {
    switch (step) {
      case InitializationStep.environment:
        return 'Environment';
      case InitializationStep.permissions:
        return 'Permissions';
      case InitializationStep.userPreferences:
        return 'Preferences';
      case InitializationStep.localization:
        return 'Localization';
      case InitializationStep.networkCheck:
        return 'Network';
      case InitializationStep.deviceInfo:
        return 'Device Info';
      case InitializationStep.complete:
        return 'Complete';
    }
  }
}