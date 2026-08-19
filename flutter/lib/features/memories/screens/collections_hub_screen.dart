import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class CollectionsHubScreen extends StatelessWidget {
  const CollectionsHubScreen({super.key});

  static const _collections = [
    {'title': 'Favorite Routes', 'count': '8 routes saved', 'icon': Icons.star_rounded},
    {'title': 'PR Moments', 'count': '8 records', 'icon': Icons.emoji_events_rounded},
    {'title': 'Group Rides', 'count': '12 rides', 'icon': Icons.people_rounded},
    {'title': 'Milestones', 'count': '5 milestones', 'icon': Icons.flag_rounded},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
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
                      Text('Collections', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: _collections.length,
                    itemBuilder: (context, index) {
                      final item = _collections[index];
                      return GlassCard(
                        onPressed: () => context.push(AppRoutes.mediaGallery),
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(item['icon'] as IconData, color: AppColors.circuitOrange, size: 32),
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(item['title'] as String, style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                                  const SizedBox(height: 4),
                                  Text(item['count'] as String, style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
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
