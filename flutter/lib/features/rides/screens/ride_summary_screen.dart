import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:latlong2/latlong.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../controllers/ride_controller.dart';
import '../../../core/utils/geo_utils.dart';

class RideSummaryScreen extends StatelessWidget {
  const RideSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ride = context.watch<RideController>().selectedRide;
    if (ride == null) return Scaffold(appBar: AppBar(title: const Text('Ride Summary')), body: const Center(child: Text('Select a saved ride from history.')));
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
        title: Text('Ride Summary', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.share, color: AppColors.circuitOrange),
            onPressed: () => context.go(AppRoutes.exportShare),
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
                  // Route Map — real FlutterMap with recorded GPS polyline
                  Builder(builder: (context) {
                    final polylinePoints = ride.routePoints
                        .map((p) => LatLng(p.latitude, p.longitude))
                        .toList();
                    return ClipRRect(
                      borderRadius: BorderRadius.circular(24),
                      child: SizedBox(
                        height: 250,
                        child: ride.routePoints.isEmpty
                            ? Container(
                                decoration: BoxDecoration(
                                  color: AppColors.surfaceContainerHigh,
                                  borderRadius: BorderRadius.circular(24),
                                  border: Border.all(color: AppColors.glassBorder),
                                ),
                                child: Center(
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.map_rounded,
                                          color: AppColors.circuitOrange, size: 48),
                                      const SizedBox(height: 8),
                                      Text('No GPS points recorded',
                                          style: AppTextStyles.statLabel(
                                              color: AppColors.onSurfaceVariant)),
                                    ],
                                  ),
                                ),
                              )
                            : RealMapView(
                                initialZoom: 14.0,
                                showControls: false,
                                followUserLocation: false,
                                polylinePoints: polylinePoints,
                              ),
                      ),
                    );
                  }), // end Builder
                  const SizedBox(height: AppSpacing.sm),
                  // Origin / Destination info
                  if (ride.origin.isNotEmpty || ride.destination.isNotEmpty) ...[
                    GlassCard(
                      padding: const EdgeInsets.all(AppSpacing.sm),
                      child: Row(
                        children: [
                          Column(
                            children: [
                              const Icon(Icons.my_location,
                                  color: AppColors.circuitOrange, size: 16),
                              Container(
                                  width: 1, height: 20, color: AppColors.glassBorder),
                              const Icon(Icons.place, color: Colors.redAccent, size: 16),
                            ],
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  ride.origin.isEmpty ? 'Unknown origin' : ride.origin,
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  ride.destination.isEmpty
                                      ? 'Unknown destination'
                                      : ride.destination,
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms, delay: 50.ms),
                    const SizedBox(height: AppSpacing.md),
                  ],
                  // Hero stats
                  Row(
                    children: [
                      Expanded(child: _buildStat('DISTANCE', ride.distanceKm.toStringAsFixed(2), 'KM')),
                      Expanded(child: _buildStat('AVG SPEED', ride.averageSpeedKmh.toStringAsFixed(1), 'KM/H')),
                      Expanded(child: _buildStat('DURATION', GeoUtils.formatDuration(ride.duration.inMilliseconds), '')),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Secondary stats
                  Row(
                    children: [
                      Expanded(child: _buildStat('MAX SPEED', ride.maxSpeedKmh.toStringAsFixed(1), 'KM/H')),
                      Expanded(child: _buildStat('ELEVATION', ride.elevationMeters.toStringAsFixed(0), 'M')),
                      Expanded(child: _buildStat('CALORIES', '${ride.caloriesBurned}', 'KCAL')),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // AI Insights Panel
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Icon(Icons.psychology, color: AppColors.circuitOrange),
                            const SizedBox(width: 8),
                            Text('AI Analysis', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Great performance! You maintained a higher average speed than your last 5 rides on this route.',
                          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            side: const BorderSide(color: AppColors.circuitOrange),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(vertical: 14),
                          ),
                          icon: const Icon(Icons.share, color: AppColors.circuitOrange, size: 18),
                          label: const Text('COMMUNITY', style: TextStyle(color: AppColors.circuitOrange, fontWeight: FontWeight.bold)),
                          onPressed: () {
                            context.push(AppRoutes.createPost, extra: ride);
                          },
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: PrimaryButton(
                          text: 'Save Ride',
                          onPressed: () => context.go(AppRoutes.successRide),
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildStat(String label, String value, String unit) {
    return GlassCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      child: Column(
        children: [
          Text(label, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant), textAlign: TextAlign.center),
          const SizedBox(height: 4),
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text(value, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
              if (unit.isNotEmpty) ...[
                const SizedBox(width: 2),
                Text(unit, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
              ],
            ],
          ),
        ],
      ),
    );
  }
}


