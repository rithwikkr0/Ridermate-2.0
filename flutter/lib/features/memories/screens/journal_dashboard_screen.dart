import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class JournalDashboardScreen extends StatelessWidget {
  const JournalDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.circuitOrange,
        onPressed: () => context.push(AppRoutes.journalSearch),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ride Journal', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      IconButton(
                        icon: const Icon(Icons.search, color: AppColors.onSurface),
                        onPressed: () => context.push(AppRoutes.journalSearch),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                  Text('THIS WEEK', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: List.generate(7, (index) {
                          final days = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                          final active = index == 1 || index == 3 || index == 5;
                          return Column(
                            children: [
                              Text(days[index], style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: AppSpacing.xs),
                              Container(
                                width: 12,
                                height: 12,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: active ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
                                ),
                              ),
                            ],
                          );
                        }),
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Text('RECENT ENTRIES', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  ListView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 3,
                    itemBuilder: (context, index) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: AppSpacing.md),
                        child: GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text('Aug ${15 - index}', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                    const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.xs),
                                Text('Morning Coffee Run', style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                                const SizedBox(height: AppSpacing.xs),
                                Text(
                                  'Felt great today! The new suspension setup is working perfectly on the bumps.',
                                  style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                  maxLines: 2,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: AppSpacing.md),
                                Row(
                                  children: [
                                    const Icon(Icons.directions_bike, size: 16, color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text('24.5 km', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                    const SizedBox(width: AppSpacing.md),
                                    const Icon(Icons.timer, size: 16, color: AppColors.onSurfaceVariant),
                                    const SizedBox(width: 4),
                                    Text('1h 12m', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 150 + index * 50)).slideY(begin: 0.1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
