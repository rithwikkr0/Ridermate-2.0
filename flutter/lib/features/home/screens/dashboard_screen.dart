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
import '../../../core/widgets/rm_scroll_body.dart';
import '../../../core/constants/mock_data.dart';
import '../../../core/router/app_router.dart';

import '../../profile/controllers/profile_controller.dart';
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
          RmScrollBody(
            child: CustomScrollView(
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
                                Expanded(
                                  child: Row(
                                    children: [
                                      GestureDetector(
                                        onTap: () => context.push(AppRoutes.profile),
                                        child: CircleAvatar(
                                          radius: 18,
                                          backgroundImage: user.profilePhotoUrl.isNotEmpty
                                              ? NetworkImage(user.profilePhotoUrl) as ImageProvider
                                              : null,
                                          backgroundColor: AppColors.surfaceContainerHigh,
                                          child: user.profilePhotoUrl.isEmpty
                                              ? const Icon(Icons.person, color: AppColors.onSurfaceVariant, size: 18)
                                              : null,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Flexible(
                                        child: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('RiderMate 2.0', style: AppTextStyles.headlineLg(color: AppColors.circuitOrange)),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
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
                      130, // Bottom clearance for bottom nav & FABs
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // ── Dynamic Greeting & Status Pills ──────────────────
                        Wrap(
                          alignment: WrapAlignment.spaceBetween,
                          crossAxisAlignment: WrapCrossAlignment.end,
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_getGreeting(), style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                Text('Hello, $userName', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                              ],
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                GestureDetector(
                                  onTap: () => context.push(AppRoutes.weather),
                                  child: GlassCard(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.light_mode, color: AppColors.softOrange, size: 14),
                                        const SizedBox(width: 4),
                                        Text('${weather.temperatureC.toStringAsFixed(0)}°',
                                            style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                                      ],
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.cloud_done, color: Colors.greenAccent, size: 14),
                                      const SizedBox(width: 4),
                                      Text('SYNCED', style: AppTextStyles.statLabel(color: Colors.greenAccent)),
                                    ],
                                  ),
                                ),
                                const SizedBox(width: 6),
                                GlassCard(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.gps_fixed, color: AppColors.circuitOrange, size: 14),
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

                        // ── RiderMate AI Copilot Feature Banner ───────────────
                        GestureDetector(
                          onTap: () => context.push(AppRoutes.coach),
                          child: Container(
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0x33FF6B00), Color(0x1A1C1B1F)],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.4), width: 1.5),
                              boxShadow: const [
                                BoxShadow(
                                  color: Color(0x33FF6B00),
                                  blurRadius: 16,
                                  offset: Offset(0, 4),
                                ),
                              ],
                            ),
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      child: Row(
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.all(8),
                                            decoration: const BoxDecoration(
                                              color: AppColors.circuitOrange,
                                              shape: BoxShape.circle,
                                            ),
                                            child: const Icon(Icons.psychology, color: Colors.white, size: 22),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  'RiderMate AI Copilot',
                                                  style: AppTextStyles.headlineSm(color: Colors.white),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                                Text(
                                                  'Smart trip planning & riding telemetry',
                                                  style: AppTextStyles.caption(color: AppColors.onSurfaceVariant),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: AppColors.circuitOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: AppColors.circuitOrange),
                                      ),
                                      child: Text(
                                        '${aiController.readinessScore}% READY',
                                        style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: AppSpacing.sm),
                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton.icon(
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.circuitOrange,
                                          foregroundColor: Colors.white,
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                          padding: const EdgeInsets.symmetric(vertical: 10),
                                        ),
                                        icon: const Icon(Icons.chat_bubble_outline, size: 16),
                                        label: Text('OPEN RIDERMATE AI', style: AppTextStyles.labelCapsSm()),
                                        onPressed: () => context.push(AppRoutes.coach),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.mic, color: AppColors.circuitOrange),
                                      tooltip: 'Voice Copilot',
                                      onPressed: () => context.push(AppRoutes.aiListening),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                        const SizedBox(height: AppSpacing.md),

                        // ── Quick Ride Entry (Solo vs Group) ────────────────
                        GlassCard(
                          padding: EdgeInsets.zero,
                          child: Column(
                            children: [
                              SizedBox(
                                height: 160,
                                child: Stack(
                                  children: [
                                    const RealMapView(
                                      showControls: false,
                                      showRecenterButton: false,
                                    ),
                                    Positioned(
                                      left: 12,
                                      right: 12,
                                      bottom: 8,
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text('START A RIDE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                            Text('Select Navigation Mode', style: AppTextStyles.headlineMd(color: Colors.white)),
                                          ],
                                        ),
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
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        icon: const Icon(Icons.navigation_rounded, size: 18),
                                        label: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('SOLO RIDE', style: AppTextStyles.labelCaps()),
                                        ),
                                        onPressed: () => context.push(AppRoutes.routePlanning),
                                      ),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    Expanded(
                                      child: OutlinedButton.icon(
                                        style: OutlinedButton.styleFrom(
                                          foregroundColor: Colors.white,
                                          side: const BorderSide(color: AppColors.circuitOrange, width: 1.5),
                                          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
                                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                                        ),
                                        icon: const Icon(Icons.groups_rounded, color: AppColors.circuitOrange, size: 18),
                                        label: FittedBox(
                                          fit: BoxFit.scaleDown,
                                          child: Text('GROUP RIDE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                                        ),
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

                        // ── Core Navigation Pillars Grid ───────────────────
                        GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('RIDERMATE HUBS', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
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
                                    icon: Icons.build_outlined,
                                    label: 'Garage',
                                    route: AppRoutes.garage,
                                  ),
                                  _buildNavTile(
                                    context: context,
                                    icon: Icons.emoji_events_outlined,
                                    label: 'Trophies',
                                    route: AppRoutes.achievements,
                                  ),
                                  _buildNavTile(
                                    context: context,
                                    icon: Icons.history_rounded,
                                    label: 'History',
                                    route: AppRoutes.rideHistory,
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
                          childAspectRatio: 1.15,
                          children: const [
                            StatsCard(label: 'Total Distance', value: '128.4', unit: 'KM', icon: Icons.map_outlined),
                            StatsCard(label: 'Total Rides', value: '5', unit: 'RIDES', icon: Icons.two_wheeler),
                            StatsCard(label: 'Ride Time', value: '4h 12m', unit: 'TIME', icon: Icons.timer_outlined),
                            StatsCard(label: 'Avg Speed', value: '31.2', unit: 'KM/H', icon: Icons.speed),
                          ],
                        ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),

                        // Bottom clearance for floating nav bar and FABs
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Dual Floating Action Buttons: RiderMate AI & SOS Emergency ──────
          Positioned(
            right: AppSpacing.marginMobile,
            bottom: 95,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FloatingActionButton.small(
                  heroTag: 'ai_assistant_fab',
                  backgroundColor: AppColors.surfaceContainerHigh,
                  elevation: 6,
                  onPressed: () => context.push(AppRoutes.coach),
                  child: const Icon(Icons.psychology, color: AppColors.circuitOrange, size: 24),
                ),
                const SizedBox(height: 10),
                FloatingActionButton(
                  heroTag: 'sos_fab',
                  backgroundColor: AppColors.error,
                  elevation: 6,
                  onPressed: () => context.push(AppRoutes.sos),
                  child: const Icon(Icons.sos, color: Colors.white, size: 28),
                ),
              ],
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
