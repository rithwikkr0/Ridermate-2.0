import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.surfaceDark.withValues(alpha: 0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text('Ride History', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_month, color: AppColors.onSurfaceVariant),
            onPressed: () => context.go(AppRoutes.rideCalendar),
          ),
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.onSurfaceVariant),
            onPressed: () {},
          ),
        ],
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
                100, // bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tab bar
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildTab('Week', false),
                      _buildTab('Month', true),
                      _buildTab('Year', false),
                    ],
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Month/week stats banner
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            Text('120 km', style: AppTextStyles.headlineMd(color: AppColors.circuitOrange)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: AppColors.glassBorder),
                        Column(
                          children: [
                            Text('RIDES', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            Text('5', style: AppTextStyles.headlineMd(color: AppColors.circuitOrange)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: MockData.recentRides.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final ride = MockData.recentRides[index];
                      return GestureDetector(
                        onTap: () => context.go(AppRoutes.rideSummary),
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(ride.title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                  Text(ride.date, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('DIST', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                        Text('\${ride.distance} KM', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('AVG', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                        Text('\${ride.avgSpeed} KM/H', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('TIME', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                        Text(ride.duration, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.sm),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text('Road', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              ),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: (200 + index * 100).ms).slideY(begin: 0.1);
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

  Widget _buildTab(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: AppTextStyles.statLabel(
          color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
