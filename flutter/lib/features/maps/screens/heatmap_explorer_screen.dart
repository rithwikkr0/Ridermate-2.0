import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/real_map_view.dart';

class HeatmapExplorerScreen extends StatelessWidget {
  const HeatmapExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Heatmap Explorer', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Real OpenStreetMap Layer
          const RealMapView(
            initialZoom: 14.0,
            showControls: true,
            followUserLocation: true,
          ),
          
          // Filter Chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                child: Row(
                  children: [
                    _buildFilterChip('All Rides', true),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('Cycling', false),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('Motorcycle', false),
                  ],
                ),
              ),
            ).animate().slideY(begin: -0.5).fadeIn(),
          ),
          
          // Legend
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Low Density', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('High Density', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ).animate().slideY(begin: 1.0).fadeIn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder),
      ),
      child: Text(label, style: AppTextStyles.bodyMd().copyWith(color: isSelected ? Colors.white : AppColors.onSurface)),
    );
  }
}
