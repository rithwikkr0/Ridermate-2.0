import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class AchievementsHubScreen extends StatelessWidget {
  const AchievementsHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.4),
                radius: 1.2,
                colors: [Color(0x0DFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Achievements', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            decoration: BoxDecoration(
                              color: AppColors.circuitOrange.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.circuitOrange),
                            ),
                            child: Text('ELITE RIDER', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                          ).animate().fadeIn().scale(),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Total XP', style: AppTextStyles.bodyMd()),
                              Text('8450 / 10000', style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: LinearProgressIndicator(
                              value: 0.845,
                              backgroundColor: AppColors.surfaceContainerHigh,
                              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.circuitOrange),
                              minHeight: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', true),
                        _buildFilterChip('Unlocked', false),
                        _buildFilterChip('Locked', false),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 0.85,
                    children: [
                      _buildAchievementMock('Century Rider', '🏅', 1.0, true),
                      _buildAchievementMock('Dawn Patrol', '🌅', 1.0, true),
                      _buildAchievementMock('Mountain Goat', '⛰️', 0.68, false),
                      _buildAchievementMock('Speed Demon', '⚡', 0.82, false),
                      _buildAchievementMock('Iron Week', '🔥', 1.0, true),
                      _buildAchievementMock('Social Butterfly', '🦋', 0.33, false),
                    ].animate(interval: 50.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      margin: const EdgeInsets.only(right: AppSpacing.sm),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder),
      ),
      child: Text(
        label,
        style: AppTextStyles.labelCaps(color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
      ),
    );
  }

  Widget _buildAchievementMock(String title, String emoji, double progress, bool unlocked) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 40)),
            const SizedBox(height: AppSpacing.sm),
            Text(
              title,
              style: AppTextStyles.labelCaps(),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            if (unlocked)
              Text('Unlocked', style: AppTextStyles.labelCapsSm(color: Colors.greenAccent))
            else ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: progress,
                  backgroundColor: AppColors.surfaceContainerLowest,
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.circuitOrange),
                  minHeight: 6,
                ),
              ),
              const SizedBox(height: 4),
              Text('${(progress * 100).toInt()}%', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
            ],
          ],
        ),
      ),
    );
  }
}
