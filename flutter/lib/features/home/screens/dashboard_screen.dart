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
import '../../../core/widgets/real_map_view.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/router/app_router.dart';

import '../../profile/controllers/profile_controller.dart';
import '../../rides/controllers/ride_controller.dart';
import '../../ai/controllers/ai_controller.dart';
import '../../weather/controllers/weather_controller.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  String _getGreeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'GOOD MORNING';
    if (hour < 17) return 'GOOD AFTERNOON';
    return 'GOOD EVENING';
  }

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

          // Main Scrollable Content
          CustomScrollView(
            slivers: [
              // Top Glass AppBar
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
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.marginMobile,
                            vertical: AppSpacing.sm,
                          ),
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
                              const Spacer(),
                              IconButton(
                                icon: const Icon(Icons.notifications_outlined, color: AppColors.onSurfaceVariant),
                                onPressed: () => context.push(AppRoutes.notifications),
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
                    120, // Bottom clearance for bottom nav & FAB
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // ── Dynamic Greeting & Status Pill ──────────────────
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(_getGreeting(), style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              Text('Hello, $userName', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                            ],
                          ),
                          Row(
                            children: [
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.weather),
                                child: GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.light_mode, color: AppColors.softOrange, size: 16),
                                      const SizedBox(width: 4),
                                      Text('${weather.temperatureC.toStringAsFixed(0)}°',
                                          style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                    ],
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              GlassCard(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                child: Row(
                                  children: [
                                    const Icon(Icons.gps_fixed, color: AppColors.circuitOrange, size: 16),
                                    const SizedBox(width: 4),
                                    Text('GPS ON', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSpacing.md),

                      // ── Quick Ride & Mode Entry Points (Solo vs Group) ──
                      GlassCard(
                        padding: EdgeInsets.zero,
                        child: Column(
                          children: [
                            SizedBox(
                              height: 180,
                              child: Stack(
                                children: [
                                  const RealMapView(
                                    showControls: false,
                                    showRecenterButton: false,
                                  ),
                                  Positioned(
                                    left: 16,
                                    bottom: 12,
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text('START A RIDE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                        Text('Select Navigation Mode', style: AppTextStyles.headlineMd(color: Colors.white)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppColors.circuitOrange,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      icon: const Icon(Icons.navigation_rounded, size: 20),
                                      label: Text('SOLO RIDE', style: AppTextStyles.labelCaps()),
                                      onPressed: () => context.push(AppRoutes.routePlanning),
                                    ),
                                  ),
                                  const SizedBox(width: AppSpacing.md),
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        foregroundColor: Colors.white,
                                        side: const BorderSide(color: AppColors.circuitOrange, width: 1.5),
                                        padding: const EdgeInsets.symmetric(vertical: 14),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                      ),
                                      icon: const Icon(Icons.groups_rounded, color: AppColors.circuitOrange, size: 20),
                                      label: Text('GROUP RIDE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                      onPressed: () => context.push(AppRoutes.liveGroupMap),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSpacing.md),

                      // ── Community & Squad Entry Points ───────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('COMMUNITY & SQUAD', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              children: [
                                _buildNavTile(
                                  context: context,
                                  icon: Icons.people_outline,
                                  label: 'Friends',
                                  route: AppRoutes.friends,
                                ),
                                _buildNavTile(
                                  context: context,
                                  icon: Icons.mail_outline,
                                  label: 'Invitations',
                                  route: AppRoutes.liveGroupMap,
                                ),
                                _buildNavTile(
                                  context: context,
                                  icon: Icons.chat_bubble_outline,
                                  label: 'Messages',
                                  route: AppRoutes.groupChat,
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSpacing.md),

                      // ── AI Readiness Insight ─────────────────────────────
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
                                              Text('${weather.condition} ${weather.windDirection}',
                                                  style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                              Text('${weather.windSpeedKmh.toStringAsFixed(0)} km/h',
                                                  style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
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

                      // ── Recent Rides ─────────────────────────────────────
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
                              onTap: () => context.push(AppRoutes.rideSummary),
                            );
                          },
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                      const SizedBox(height: AppSpacing.lg),

                      // ── Weekly Overview Stats ────────────────────────────
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

          // ── SOS Floating Emergency Button ─────────────────────────────────
          Positioned(
            right: AppSpacing.marginMobile,
            bottom: 90,
            child: FloatingActionButton(
              heroTag: 'sos_fab',
              backgroundColor: AppColors.error,
              elevation: 6,
              onPressed: () => context.push(AppRoutes.sos),
              child: const Icon(Icons.sos, color: Colors.white, size: 28),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavTile({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String route,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => context.push(route),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppColors.circuitOrange, size: 24),
              const SizedBox(height: 4),
              Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurface)),
            ],
          ),
        ),
      ),
    );
  }
}
