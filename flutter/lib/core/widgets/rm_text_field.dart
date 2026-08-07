import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

typedef RMTextField = RmTextField;

/// Styled glass text input field matching Stitch design
class RmTextField extends StatelessWidget {
  const RmTextField({
    super.key,
    this.controller,
    this.initialValue,
    this.hint,
    this.hintText,
    this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType,
    this.onChanged,
    this.onSubmitted,
    this.textInputAction,
    this.enabled = true,
    this.maxLines = 1,
    this.autofocus = false,
  });

  final TextEditingController? controller;
  final String? initialValue;
  final String? hint;
  final String? hintText;
  final String? label;
  final IconData? prefixIcon;
  final Widget? suffixIcon;
  final bool obscureText;
  final TextInputType? keyboardType;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputAction? textInputAction;
  final bool enabled;
  final int? maxLines;
  final bool autofocus;

  String? get effectiveHint => hint ?? hintText;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (label != null) ...[
          Text(
            label!.toUpperCase(),
            style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: AppSpacing.sm),
        ],
        TextFormField(
          controller: controller,
          initialValue: controller == null ? initialValue : null,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onChanged: onChanged,
          onFieldSubmitted: onSubmitted,
          enabled: enabled,
          maxLines: maxLines,
          autofocus: autofocus,
          style: AppTextStyles.bodyMd(color: AppColors.onSurface),
          decoration: InputDecoration(
            hintText: effectiveHint,
            prefixIcon: prefixIcon != null
                ? Icon(prefixIcon, color: AppColors.onSurfaceVariant, size: AppSpacing.iconMd)
                : null,
            suffixIcon: suffixIcon,
          ),
        ),
      ],
    );
  }
}
