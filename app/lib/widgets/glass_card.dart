import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GlassCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final double borderRadius;
  final bool showBorder;

  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.onTap,
    this.borderRadius = 18,
    this.showBorder = true,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: AppColors.glassCardBg,
      borderRadius: BorderRadius.circular(borderRadius),
      child: InkWell(
        borderRadius: BorderRadius.circular(borderRadius),
        onTap: onTap,
        child: Container(
          padding: padding,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: showBorder ? Border.all(
              color: AppColors.glassCardBorder,
              width: 1,
            ) : null,
            boxShadow: const [
              BoxShadow(
                blurRadius: 18,
                offset: Offset(0, 6),
                color: Colors.black26,
              )
            ],
          ),
          child: child,
        ),
      ),
    );
  }
}

class GlowingButton extends StatelessWidget {
  final String text;
  final bool enabled;
  final VoidCallback? onTap;
  final bool isLoading;

  const GlowingButton({
    super.key,
    required this.text,
    required this.enabled,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final base = AppColors.brandPrimary;
    
    return GestureDetector(
      onTap: enabled && !isLoading ? onTap : null,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: enabled ? 1 : 0.5,
        child: Container(
          height: 56,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              colors: [base.withOpacity(0.95), base.withOpacity(0.75)],
            ),
            boxShadow: [
              BoxShadow(
                color: base.withOpacity(0.45),
                blurRadius: 20,
                spreadRadius: 1,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: isLoading
              ? const SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2,
                  ),
                )
              : Text(
                  text,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
        ),
      ),
    );
  }
}

class NightSkyBackground extends StatelessWidget {
  final Widget child;

  const NightSkyBackground({
    super.key,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppColors.nightSkyTop,
            AppColors.nightSkyMiddle,
            AppColors.nightSkyBottom,
          ],
        ),
      ),
      child: child,
    );
  }
}