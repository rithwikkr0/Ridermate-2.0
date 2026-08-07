import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Primary CTA button widget matching Kinetic Precision design
class PrimaryButton extends StatelessWidget {
  const PrimaryButton({
    super.key,
    this.label,
    this.text,
    this.onPressed,
    this.onTap,
    this.icon,
    this.isFullWidth = true,
    this.width,
    this.height = 52,
    this.enabled = true,
    this.gradient,
    this.color,
  });

  final String? label;
  final String? text;
  final VoidCallback? onPressed;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isFullWidth;
  final double? width;
  final double height;
  final bool enabled;
  final Gradient? gradient;
  final Color? color;

  String get displayLabel => label ?? text ?? '';
  VoidCallback? get effectiveTap => onPressed ?? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveGradient = gradient ?? AppColors.orangeGradient;
    final isInteractive = enabled && effectiveTap != null;

    final childWidget = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (icon != null) ...[
          Icon(icon, color: Colors.white, size: AppSpacing.iconSm),
          const SizedBox(width: AppSpacing.sm),
        ],
        Text(
          displayLabel,
          style: AppTextStyles.button(color: Colors.white),
        ),
      ],
    );

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isInteractive ? 1.0 : 0.40,
      child: Container(
        width: isFullWidth ? (width ?? double.infinity) : width,
        height: height,
        decoration: BoxDecoration(
          color: color,
          gradient: color == null ? effectiveGradient : null,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          boxShadow: isInteractive
              ? [
                  BoxShadow(
                    color: AppColors.circuitOrange.withValues(alpha: 0.35),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isInteractive ? effectiveTap : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: childWidget,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
