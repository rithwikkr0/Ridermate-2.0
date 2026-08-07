import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

/// Metric stat card — distance, speed, duration etc.
class StatsCard extends StatelessWidget {
  const StatsCard({
    super.key,
    this.label,
    this.title,
    required this.value,
    this.unit = '',
    this.icon = Icons.bar_chart_rounded,
    this.color,
    this.onTap,
    this.trend,
    this.trendPositive = true,
  });

  final String? label;
  final String? title;
  final String value;
  final String unit;
  final IconData icon;
  final Color? color;
  final VoidCallback? onTap;
  final String? trend;
  final bool trendPositive;

  String get displayLabel => label ?? title ?? '';

  @override
  Widget build(BuildContext context) {
    final iconColor = color ?? AppColors.circuitOrange;
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: iconColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                ),
                child: Icon(icon, color: iconColor, size: AppSpacing.iconSm),
              ),
              if (trend != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: (trendPositive ? Colors.green : Colors.red).withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                  ),
                  child: Text(
                    trend!,
                    style: AppTextStyles.labelCapsSm(
                      color: trendPositive ? Colors.green : Colors.red,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            displayLabel.toUpperCase(),
            style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
          ),
          const SizedBox(height: 2),
          RichText(
            text: TextSpan(
              text: value,
              style: AppTextStyles.displayStatSm(color: AppColors.onSurface),
              children: [
                if (unit.isNotEmpty)
                  TextSpan(
                    text: ' $unit',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
