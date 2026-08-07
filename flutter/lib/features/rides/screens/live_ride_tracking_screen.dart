import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/app_router.dart';
import '../controllers/ride_controller.dart';

class LiveRideTrackingScreen extends StatefulWidget {
  const LiveRideTrackingScreen({super.key});

  @override
  State<LiveRideTrackingScreen> createState() => _LiveRideTrackingScreenState();
}

class _LiveRideTrackingScreenState extends State<LiveRideTrackingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<RideController>().startRide();
    });
  }

  @override
  Widget build(BuildContext context) {
    final rideController = context.watch<RideController>();
    final liveState = rideController.currentLiveState;

    final currentSpeed = liveState?.currentSpeedKmh.toStringAsFixed(0) ?? '42';
    final currentDistance = liveState != null
        ? '${liveState.distanceKm.toStringAsFixed(1)} km'
        : '12.4 km';
    final currentDuration = liveState != null
        ? '${liveState.duration.inMinutes}m ${liveState.duration.inSeconds % 60}s'
        : '28 min';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Full-screen map placeholder
          Container(
            width: double.infinity,
            height: double.infinity,
            decoration: const BoxDecoration(
              color: AppColors.surfaceDim,
            ),
            child: Stack(
              children: [
                CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                const Center(
                  child: Icon(Icons.location_on, color: AppColors.circuitOrange, size: 48),
                ),
              ],
            ),
          ),

          // Top bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: AppSpacing.sm),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        color: AppColors.surfaceDark.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
                          onPressed: () => context.pop(),
                        ),
                      ),
                    ),
                  ),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        color: AppColors.surfaceDark.withValues(alpha: 0.6),
                        child: Text('LIVE TELEMETRY', style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Bottom HUD Overlay
          Positioned(
            left: AppSpacing.marginMobile,
            right: AppSpacing.marginMobile,
            bottom: 30,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Giant speed stat
                      Text(
                        currentSpeed,
                        style: AppTextStyles.displayStat(color: AppColors.onSurface).copyWith(fontSize: 72, height: 1),
                      ),
                      Text('KM/H', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                      const SizedBox(height: AppSpacing.lg),

                      // Smaller stats
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Column(
                            children: [
                              Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(currentDistance, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            ],
                          ),
                          Container(width: 1, height: 40, color: AppColors.glassBorder),
                          Column(
                            children: [
                              Text('DURATION', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              const SizedBox(height: 4),
                              Text(currentDuration, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      // Controls
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Stop
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.error.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.error.withValues(alpha: 0.5)),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.stop_rounded, color: AppColors.error, size: 32),
                              onPressed: () {
                                context.read<RideController>().stopRide();
                                context.go(AppRoutes.successRide);
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),

                          // Pause / Resume
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: IconButton(
                              icon: Icon(
                                rideController.isPaused ? Icons.play_arrow_rounded : Icons.pause_rounded,
                                color: AppColors.onSurface,
                                size: 32,
                              ),
                              onPressed: () {
                                if (rideController.isPaused) {
                                  context.read<RideController>().resumeRide();
                                } else {
                                  context.read<RideController>().pauseRide();
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.lg),

                          // HUD Mode
                          Container(
                            width: 64,
                            height: 64,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              shape: BoxShape.circle,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: IconButton(
                              icon: const Icon(Icons.speed, color: AppColors.onSurface, size: 32),
                              onPressed: () => context.go(AppRoutes.rideHud),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.2),
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
    const step = 40.0;
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
