import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class BeepButton extends StatefulWidget {
  final VoidCallback onPressed;
  final bool isLoading;
  final double size;
  final String text;
  
  const BeepButton({
    super.key,
    required this.onPressed,
    this.isLoading = false,
    this.size = 200,
    this.text = 'BEEP',
  });
  
  @override
  State<BeepButton> createState() => _BeepButtonState();
}

class _BeepButtonState extends State<BeepButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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
  
  void _handleTapDown(TapDownDetails details) {
    _animationController.forward();
  }
  
  void _handleTapUp(TapUpDetails details) {
    _animationController.reverse();
    widget.onPressed();
  }
  
  void _handleTapCancel() {
    _animationController.reverse();
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: widget.isLoading ? null : _handleTapDown,
      onTapUp: widget.isLoading ? null : _handleTapUp,
      onTapCancel: _handleTapCancel,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              width: widget.size,
              height: widget.size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    widget.isLoading 
                        ? AppColors.semanticWarning
                        : AppColors.brandPrimary,
                    widget.isLoading
                        ? AppColors.semanticWarning.withOpacity(0.3)
                        : AppColors.brandPrimary.withOpacity(0.1),
                  ],
                  stops: const [0.6, 1.0],
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.isLoading 
                        ? AppColors.semanticWarning
                        : AppColors.brandPrimary).withOpacity(0.4),
                    blurRadius: 30,
                    spreadRadius: 10,
                  ),
                ],
                border: Border.all(
                  color: Colors.white.withOpacity(0.2),
                  width: 2,
                ),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(widget.size / 2),
                  splashColor: Colors.white.withOpacity(0.3),
                  highlightColor: Colors.transparent,
                  onTap: widget.isLoading ? null : widget.onPressed,
                  child: Center(
                    child: widget.isLoading
                        ? const CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 3,
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.touch_app,
                                size: 60,
                                color: Colors.white,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                widget.text,
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                  letterSpacing: 3,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}