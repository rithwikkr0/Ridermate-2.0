import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SuccessRideSavedScreen extends StatelessWidget {
  const SuccessRideSavedScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 1.5,
                colors: [Color(0x33FF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Spacer(),
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppColors.circuitOrange.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.circuitOrange, width: 2),
                    ),
                    child: const Icon(Icons.check_rounded, color: AppColors.circuitOrange, size: 64),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Ride Saved!', style: AppTextStyles.displayStat(color: AppColors.onSurface)).animate().fadeIn(delay: 200.ms).slideY(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Your activity has been synced successfully.', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)).animate().fadeIn(delay: 300.ms),
                  const SizedBox(height: AppSpacing.xl),
                  
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('42.5 km', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: AppColors.glassBorder),
                        Column(
                          children: [
                            Text('TIME', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: 4),
                            Text('1h 45m', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(),
                  const Spacer(),
                  
                  Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        child: PrimaryButton(
                          text: 'View Summary',
                          onPressed: () => context.go(AppRoutes.rideSummary),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: SecondaryButton(
                          text: 'Share Story',
                          onPressed: () => context.go(AppRoutes.rideStory),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => context.go(AppRoutes.home),
                        child: Text('Back to Home', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
                      ),
                    ],
                  ).animate().fadeIn(delay: 500.ms).slideY(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
