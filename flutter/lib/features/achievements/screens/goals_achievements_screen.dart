import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/stats_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class GoalsAchievementsScreen extends StatelessWidget {
  const GoalsAchievementsScreen({super.key});

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
                      Text('My Goals', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...[
                    _buildGoalCard('Ride 500km this month', 120, 500, 'km', 'Aug 31'),
                    const SizedBox(height: AppSpacing.md),
                    _buildGoalCard('Climb 5000m', 1240, 5000, 'm', 'Aug 31'),
                    const SizedBox(height: AppSpacing.md),
                    _buildGoalCard('Complete 10 rides', 5, 10, 'rides', 'Aug 31'),
                  ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  PrimaryButton(label: '+ Add Goal',
                    onPressed: () {},
                  ).animate().fadeIn(delay: 400.ms),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Weekly Targets', style: AppTextStyles.headlineSm()),
                  const SizedBox(height: AppSpacing.md),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    mainAxisSpacing: AppSpacing.md,
                    crossAxisSpacing: AppSpacing.md,
                    childAspectRatio: 1.2,
                    children: [
                      StatsCard(title: 'Distance', value: '45/100', unit: 'km'),
                      StatsCard(title: 'Elevation', value: '300/1000', unit: 'm'),
                      StatsCard(title: 'Time', value: '2/5', unit: 'hrs'),
                      StatsCard(title: 'Rides', value: '1/3', unit: ''),
                    ].animate(interval: 50.ms).fadeIn().scale(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalCard(String title, double current, double total, String unit, String deadline) {
    double progress = current / total;
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(child: Text(title, style: AppTextStyles.headlineSm())),
                Text('Deadline: $deadline', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.circuitOrange),
                minHeight: 10,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('${(progress * 100).toInt()}%', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                Text('${current.toInt()}/${total.toInt()} $unit', style: AppTextStyles.labelCaps()),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
