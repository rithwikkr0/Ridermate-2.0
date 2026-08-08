import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ride_card.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/router/app_router.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../rides/controllers/ride_controller.dart';
import '../../ai/controllers/ai_controller.dart';
import '../../weather/controllers/weather_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final rideController = context.watch<RideController>();
    final aiController = context.watch<AiController>();
    final weatherController = context.watch<WeatherController>();

    final user = profileController.userOrDefault;
    final userName = user.fullName.isNotEmpty ? user.fullName.split(' ')[0] : 'Rider';
    final weather = weatherController.weather;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background gradient
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(-0.7, -0.4),
                radius: 1.2,
                colors: [Color(0x0DFF6B00), Colors.transparent],
              ),
            ),
          ),
          // Main content
          CustomScrollView(
            slivers: [
              SliverAppBar(
                pinned: true,
                backgroundColor: Colors.transparent,
                flexibleSpace: ClipRRect(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                    child: Container(
                      color: AppColors.surfaceDark.withValues(alpha: 0.6),
                      child: SafeArea(
                        bottom: false,
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  CircleAvatar(
                                    radius: 20,
                                    backgroundImage: user.profilePhotoUrl.isNotEmpty
                                        ? NetworkImage(user.profilePhotoUrl) as ImageProvider
                                        : null,
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                    child: user.profilePhotoUrl.isEmpty
                                        ? const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 20)
                                        : null,
                                  ),
                                  const SizedBox(width: AppSpacing.sm),
                                  Text('RiderMate 2.0', style: AppTextStyles.headlineLg(color: AppColors.circuitOrange)),
                                ],
                              ),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
                                onPressed: () => context.go(AppRoutes.notifications),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.md,
                    AppSpacing.marginMobile,
                    100, // bottom nav clearance
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Greeting & Status
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('GOOD MORNING', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              Text('Hello, $userName', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.go(AppRoutes.weather),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.light_mode, color: AppColors.softOrange, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${weather.temperatureC.toStringAsFixed(0)}°', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.battery_charging_full, color: AppColors.onSurface, size: 16),
                                    const SizedBox(width: 4),
                                    Text('88%', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: AppSpacing.md),

                      // Quick Ride card
                      GestureDetector(
                        onTap: () {
                          rideController.startRide();
                          context.go(AppRoutes.liveRide);
                        },
                        child: Container(
                          width: double.infinity,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.glassBorder),
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(24),
                            child: Stack(
                              children: [
                                Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xFF1E2020), Color(0xFF121414)],
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                    ),
                                  ),
                                ),
                                CustomPaint(painter: _MapGridPainter()),
                                Positioned(
                                  left: 16,
                                  bottom: 16,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('READY TO ROLL', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                      Text('Start Quick Ride', style: AppTextStyles.headlineMd(color: Colors.white)),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  right: 16,
                                  bottom: 16,
                                  child: Container(
                                    width: 56,
                                    height: 56,
                                    decoration: const BoxDecoration(
                                      gradient: AppColors.orangeGradient,
                                      shape: BoxShape.circle,
                                    ),
                                    child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 32),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: AppSpacing.md),

                      // AI Coach Insights
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.psychology, color: AppColors.circuitOrange),
                                const SizedBox(width: 8),
                                Text('AI Coach Insights', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('READINESS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                      Row(
                                        crossAxisAlignment: CrossAxisAlignment.baseline,
                                        textBaseline: TextBaseline.alphabetic,
                                        children: [
                                          Text('${aiController.readinessScore}', style: AppTextStyles.displayStat(color: AppColors.circuitOrange)),
                                          Text('%', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('CONDITIONS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                      const SizedBox(height: 4),
                                      Row(
                                        children: [
                                          Container(
                                            width: 32,
                                            height: 32,
                                            decoration: const BoxDecoration(
                                              color: AppColors.surfaceContainerHighest,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.air, size: 18, color: AppColors.onSurface),
                                          ),
                                          const SizedBox(width: 8),
                                          Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              Text('${weather.condition} ${weather.windDirection}', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                              Text('${weather.windSpeedKmh.toStringAsFixed(0)} km/h', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: AppSpacing.lg),

                      // Recent Rides
                      Text('RECENT RIDES', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      SizedBox(
                        height: 180,
                        child: ListView.separated(
                          scrollDirection: Axis.horizontal,
                          itemCount: MockData.recentRides.length,
                          separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final ride = MockData.recentRides[index];
                            return RideCard(
                              ride: ride,
                              onTap: () => context.go(AppRoutes.rideSummary),
                            );
                          },
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                      const SizedBox(height: AppSpacing.lg),

                      // Weekly Stats
                      Text('WEEKLY OVERVIEW', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.sm),
                      GridView.count(
                        crossAxisCount: 2,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: AppSpacing.sm,
                        crossAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.5,
                        children: const [
                          StatsCard(label: 'Total Distance', value: '128.4', unit: 'KM', icon: Icons.map_outlined),
                          StatsCard(label: 'Total Rides', value: '5', unit: 'RIDES', icon: Icons.two_wheeler),
                          StatsCard(label: 'Ride Time', value: '4h 12m', unit: 'TIME', icon: Icons.timer_outlined),
                          StatsCard(label: 'Avg Speed', value: '31.2', unit: 'KM/H', icon: Icons.speed),
                        ],
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // SOS Floating Button
          Positioned(
            right: AppSpacing.marginMobile,
            bottom: 30,
            child: FloatingActionButton(
              heroTag: 'sos_fab',
              backgroundColor: AppColors.error,
              onPressed: () => context.go(AppRoutes.sos),
              child: const Icon(Icons.sos, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1.0;
    const step = 30.0;
    for (double x = 0; x < size.width; x += step) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += step) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
