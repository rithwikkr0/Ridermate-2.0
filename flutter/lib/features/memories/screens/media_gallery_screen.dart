import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class MediaGalleryScreen extends StatelessWidget {
  const MediaGalleryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.circuitOrange,
        onPressed: () {},
        child: const Icon(Icons.camera_alt, color: Colors.white),
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
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Media Gallery', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Rides', 'Screenshots', 'Videos'].map((filter) {
                        final isSelected = filter == 'All';
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(filter, style: AppTextStyles.labelCapsSm(color: isSelected ? Colors.white : AppColors.onSurfaceVariant)),
                            selected: isSelected,
                            selectedColor: AppColors.circuitOrange,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            side: BorderSide(color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder),
                            onSelected: (val) {},
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.builder(
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: AppSpacing.sm,
                      mainAxisSpacing: AppSpacing.sm,
                      childAspectRatio: 1.0,
                    ),
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: 12,
                    itemBuilder: (context, index) {
                      return GestureDetector(
                        onTap: () => context.push(AppRoutes.photoViewer),
                        child: Container(
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: Icon(
                            index % 2 == 0 ? Icons.directions_bike : Icons.photo_camera,
                            color: AppColors.circuitOrange.withValues(alpha: 0.5),
                            size: 32,
                          ),
                        ),
                      ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: 30 * index));
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
