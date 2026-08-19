import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:provider/provider.dart';
import '../controllers/ride_controller.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideHistoryScreen extends StatelessWidget {
  const RideHistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<RideController>();
    final rides = controller.rides;
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
            onPressed: () {
              showModalBottomSheet<void>(
                context: context,
                backgroundColor: AppColors.surfaceContainerHigh,
                shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
                builder: (ctx) => Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Filter Rides', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                      const SizedBox(height: AppSpacing.md),
                      ListTile(
                        leading: const Icon(Icons.all_inclusive, color: AppColors.circuitOrange),
                        title: Text('All Rides', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.history, color: AppColors.circuitOrange),
                        title: Text('Last 30 Days', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                      ListTile(
                        leading: const Icon(Icons.stars, color: AppColors.circuitOrange),
                        title: Text('High Safety Score (>90)', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                        onTap: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                ),
              );
            },
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
                            Text('${rides.fold<double>(0, (sum, ride) => sum + ride.distanceKm).toStringAsFixed(1)} km', style: AppTextStyles.headlineMd(color: AppColors.circuitOrange)),
                          ],
                        ),
                        Container(width: 1, height: 40, color: AppColors.glassBorder),
                        Column(
                          children: [
                            Text('RIDES', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            Text('${rides.length}', style: AppTextStyles.headlineMd(color: AppColors.circuitOrange)),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // List
                  if (rides.isEmpty) Padding(padding: const EdgeInsets.all(AppSpacing.xl), child: Center(child: Text('No saved rides yet. Start a ride to build your history.', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)))) else ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: rides.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final ride = rides[index];
                      return GestureDetector(
                        onTap: () { controller.selectRide(ride); context.go(AppRoutes.rideSummary); },
                        child: GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(ride.title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                  Text('${ride.startTime.day}/${ride.startTime.month}/${ride.startTime.year}', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
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
                                        Text(GeoUtils.formatDistance(ride.distanceKm), style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('AVG', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                        Text('${ride.averageSpeedKmh.toStringAsFixed(1)} KM/H', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('TIME', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                        Text(GeoUtils.formatDuration(ride.duration.inMilliseconds), style: AppTextStyles.statLabel(color: AppColors.onSurface)),
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
