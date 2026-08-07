import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: double.infinity,
              height: double.infinity,
              color: AppColors.surfaceContainerHigh,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.directions_bike, size: 80, color: AppColors.circuitOrange),
                  const SizedBox(height: AppSpacing.md),
                  Text('Photo Placeholder', style: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () => context.pop(),
                  ),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.share, color: Colors.white),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete_outline, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Coastal Highway Ride', style: AppTextStyles.bodyLg(color: Colors.white)),
                            Text('Aug 12, 2026 · Mumbai', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                        Text('42.5 km', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2).fadeIn(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
