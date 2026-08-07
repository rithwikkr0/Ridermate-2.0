import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';


class SearchDestinationScreen extends StatelessWidget {
  const SearchDestinationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Container(
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(22),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: const TextField(
            style: TextStyle(color: AppColors.onSurface),
            decoration: InputDecoration(
              hintText: 'Search destinations...',
              hintStyle: TextStyle(color: AppColors.onSurfaceVariant),
              prefixIcon: Icon(Icons.search, color: AppColors.onSurfaceVariant),
              border: InputBorder.none,
              contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
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
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('RECENT SEARCHES', style: AppTextStyles.labelCaps()).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                  _buildPlaceTile('Coastal Cliffs', '22 km', 'SCENIC').animate().fadeIn(delay: 100.ms),
                  _buildPlaceTile('Downtown Cafe', '5 km', 'CITY').animate().fadeIn(delay: 150.ms),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text('SAVED PLACES', style: AppTextStyles.labelCaps()).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.md),
                  _buildPlaceTile('Home', '0 km', 'HOME').animate().fadeIn(delay: 250.ms),
                  _buildPlaceTile('Work', '12 km', 'WORK').animate().fadeIn(delay: 300.ms),
                  
                  const SizedBox(height: 100), // padding
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceTile(String name, String distance, String type) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: const Icon(Icons.place_outlined, color: AppColors.onSurfaceVariant),
        ),
        title: Text(name, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
        subtitle: Text(distance, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
          ),
          child: Text(type, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
        ),
      ),
    );
  }
}
