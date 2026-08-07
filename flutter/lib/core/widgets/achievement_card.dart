import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

/// Achievement/badge card
class AchievementCard extends StatelessWidget {
  const AchievementCard({
    super.key,
    required this.title,
    required this.description,
    required this.emoji,
    required this.unlocked,
    this.progress = 1.0,
    this.category,
    this.onTap,
  });

  final String title;
  final String description;
  final String emoji;
  final bool unlocked;
  final double progress; // 0.0 to 1.0
  final String? category;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Row(
        children: [
          // Emoji badge
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: unlocked
                  ? AppColors.circuitOrange.withValues(alpha: 0.15)
                  : AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(
                color: unlocked ? AppColors.circuitOrange.withValues(alpha: 0.4) : AppColors.glassBorder,
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: AppTextStyles.statLabel(color: AppColors.onSurface),
                      ),
                    ),
                    if (unlocked)
                      const Icon(Icons.check_circle_rounded,
                          color: AppColors.circuitOrange, size: 18),
                  ],
                ),
                const SizedBox(height: 2),
                Text(description, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                if (!unlocked) ...[
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: AppColors.surfaceContainerHigh,
                      valueColor: const AlwaysStoppedAnimation(AppColors.circuitOrange),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${(progress * 100).toInt()}% complete',
                    style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
