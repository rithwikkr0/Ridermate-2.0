import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/real_map_view.dart';

class RoutePlanningScreen extends StatelessWidget {
  const RoutePlanningScreen({super.key});

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
      ),
      body: Stack(
        children: [
          // Real Map Top View
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: MediaQuery.of(context).size.height * 0.6,
            child: const RealMapView(
              initialZoom: 15.0,
              showControls: false,
              followUserLocation: true,
            ),
          ),
          
          // Planning Panel
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  height: MediaQuery.of(context).size.height * 0.5,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Input fields
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: Column(
                            children: [
                              _buildLocationInput('From', 'Current GPS Location'),
                              const Divider(color: Colors.white10, height: 1),
                              _buildLocationInput('To', 'Select Destination'),
                            ],
                          ),
                        ),
                      ).animate().slideY(begin: 0.1, duration: 300.ms).fadeIn(),
                      
                      const SizedBox(height: AppSpacing.lg),
                      Text('ROUTE OPTIONS', style: AppTextStyles.labelCaps()).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: AppSpacing.md),
                      
                      Expanded(
                        child: ListView(
                          padding: EdgeInsets.zero,
                          children: [
                            _buildRouteOption('Direct Route', 'Calculated via GPS', '-- km', isSelected: true).animate().fadeIn(delay: 200.ms),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationInput(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 40,
            child: Text(label, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
          ),
          Expanded(
            child: Text(value, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
          ),
        ],
      ),
    );
  }

  Widget _buildRouteOption(String title, String time, String dist, {bool isSelected = false}) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange.withValues(alpha: 0.1) : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder),
      ),
      child: ListTile(
        title: Text(title, style: AppTextStyles.headlineMd().copyWith(color: isSelected ? AppColors.circuitOrange : AppColors.onSurface)),
        subtitle: Text('$dist • $time', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
        trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.circuitOrange) : null,
      ),
    );
  }
}
