import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';

/// Glassmorphism container used throughout RiderMate 2.0.
/// Matches: background: rgba(18,20,20,0.6), backdrop-filter: blur(30px),
/// border: 1px solid rgba(255,255,255,0.10)
class GlassCard extends StatelessWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding,
    this.margin,
    this.borderRadius,
    this.blur = AppSpacing.blurGlass,
    this.bgOpacity = 0.60,
    this.elevated = false,
    this.borderColor,
    this.width,
    this.height,
    this.onTap,
    this.onPressed,
    this.glowColor,
    this.gradient,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final EdgeInsetsGeometry? margin;
  final BorderRadiusGeometry? borderRadius;
  final double blur;
  final double bgOpacity;

  /// Elevated variant: stronger blur + orange glow shadow
  final bool elevated;
  final Color? borderColor;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;

  /// Optional orange glow decoration
  final Color? glowColor;
  final Gradient? gradient;

  VoidCallback? get effectiveTap => onTap ?? onPressed;

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? BorderRadius.circular(AppSpacing.radiusXl);
    final border = borderColor ?? (elevated ? AppColors.glassBorderHigh : AppColors.glassBorder);
    final bg = elevated
        ? AppColors.surfaceDark.withValues(alpha: 0.70)
        : AppColors.surfaceDark.withValues(alpha: bgOpacity);

    Widget cardWidget = ClipRRect(
      borderRadius: radius as BorderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
        child: Container(
          width: width,
          height: height,
          padding: padding ?? const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: gradient == null ? bg : null,
            gradient: gradient,
            borderRadius: radius,
            border: Border.all(color: border, width: 1),
            boxShadow: elevated
                ? [
                    BoxShadow(
                      color: glowColor ?? AppColors.orangeGlow10,
                      blurRadius: 32,
                      offset: const Offset(0, 12),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 20,
                      offset: const Offset(0, 4),
                    ),
                  ],
          ),
          child: child,
        ),
      ),
    );

    if (effectiveTap != null) {
      cardWidget = GestureDetector(
        onTap: effectiveTap,
        child: cardWidget,
      );
    }

    if (margin != null) {
      cardWidget = Padding(padding: margin!, child: cardWidget);
    }

    return cardWidget;
  }
}
