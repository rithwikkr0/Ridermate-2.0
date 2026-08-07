import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Secondary glass button with border
class SecondaryButton extends StatelessWidget {
  const SecondaryButton({
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

  String get displayLabel => label ?? text ?? '';
  VoidCallback? get effectiveTap => onPressed ?? onTap;

  @override
  Widget build(BuildContext context) {
    final isInteractive = enabled && effectiveTap != null;

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: isInteractive ? 1.0 : 0.40,
      child: Container(
        width: isFullWidth ? (width ?? double.infinity) : width,
        height: height,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
          border: Border.all(color: AppColors.glassBorderHigh),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: isInteractive ? effectiveTap : null,
            borderRadius: BorderRadius.circular(AppSpacing.radiusLg),
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (icon != null) ...[
                      Icon(icon, color: AppColors.onSurface, size: AppSpacing.iconSm),
                      const SizedBox(width: AppSpacing.sm),
                    ],
                    Text(
                      displayLabel,
                      style: AppTextStyles.button(color: AppColors.onSurface),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
