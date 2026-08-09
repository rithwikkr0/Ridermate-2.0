import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../../core/router/app_router.dart';
import '../controllers/ride_controller.dart';
import '../../../core/utils/geo_utils.dart';

class LiveRideTrackingScreen extends StatefulWidget {
  final String rideMode;
  final String origin;
  final String destination;

  const LiveRideTrackingScreen({
    super.key,
    this.rideMode = 'solo',
    this.origin = '',
    this.destination = '',
  });

  @override
  State<LiveRideTrackingScreen> createState() => _LiveRideTrackingScreenState();
}

class _LiveRideTrackingScreenState extends State<LiveRideTrackingScreen> {
  bool _startCalled = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!_startCalled) {
        _startCalled = true;
        final ctrl = context.read<RideController>();
        // Only start if idle/failed — don't double-start if already active
        if (ctrl.isIdle || ctrl.rideState == RideState.failed) {
          ctrl.startRide(
            mode: widget.rideMode,
            origin: widget.origin,
            destination: widget.destination,
          );
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<RideController>();
    final rideState = ctrl.rideState;

    return PopScope(
      canPop: !ctrl.isTracking,
      onPopInvokedWithResult: (didPop, _) async {
        if (!didPop && ctrl.isTracking) {
          final confirmed = await _showExitConfirmation(context);
          if (confirmed == true && context.mounted) {
            ctrl.discardRide();
            if (context.mounted) Navigator.of(context).pop();
          }
        }
      },
      child: Scaffold(
        backgroundColor: AppColors.surfaceContainerLowest,
        body: Stack(
          children: [
            // ── Real OpenStreetMap + rider GPS marker ──────────────────
            const RealMapView(
              initialZoom: 16.0,
              showControls: true,
              followUserLocation: true,
            ),

            // ── State overlay: Preparing / Starting ───────────────────
            if (rideState == RideState.preparing || rideState == RideState.starting)
              _buildStateOverlay(rideState),

            // ── Error overlay ─────────────────────────────────────────
            if (rideState == RideState.failed) _buildErrorOverlay(ctrl, context),

            // ── GPS signal pill (top-left) ─────────────────────────────
            if (rideState == RideState.active || rideState == RideState.paused)
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: Row(
                    children: [
                      _buildGpsSignalPill(ctrl),
                      const Spacer(),
                      _buildRideModePill(widget.rideMode),
                    ],
                  ),
                ).animate().fadeIn(duration: 400.ms),
              ),

            // ── Bottom HUD ────────────────────────────────────────────
            if (rideState == RideState.active || rideState == RideState.paused)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                child: _buildHud(ctrl, context),
              ),
          ],
        ),
      ),
    );
  }

  // ── Preparing / Starting overlay ────────────────────────────────────────
  Widget _buildStateOverlay(RideState state) {
    final label = state == RideState.preparing ? 'Preparing...' : 'Acquiring GPS...';
    return Container(
      color: Colors.black.withValues(alpha: 0.6),
      child: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(color: AppColors.circuitOrange),
            const SizedBox(height: 20),
            Text(label, style: AppTextStyles.headlineMd(color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              'Please wait…',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
          ],
        ),
      ),
    );
  }

  // ── Error overlay ────────────────────────────────────────────────────────
  Widget _buildErrorOverlay(RideController ctrl, BuildContext context) {
    return Container(
      color: Colors.black.withValues(alpha: 0.75),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.gps_off, color: AppColors.error, size: 56),
              const SizedBox(height: 16),
              Text(
                'GPS Error',
                style: AppTextStyles.headlineMd(color: AppColors.error),
              ),
              const SizedBox(height: 8),
              Text(
                ctrl.rideError ?? 'Unknown error',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.circuitOrange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                onPressed: () {
                  ctrl.startRide(
                    mode: widget.rideMode,
                    origin: widget.origin,
                    destination: widget.destination,
                  );
                },
                child: const Text('Retry'),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  ctrl.discardRide();
                  context.pop();
                },
                child: Text('Cancel', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── GPS signal pill ──────────────────────────────────────────────────────
  Widget _buildGpsSignalPill(RideController ctrl) {
    final status = ctrl.gpsSignalStatus;
    final label = ctrl.gpsSignalLabel;
    final Color color;
    switch (status) {
      case GpsSignalStatus.good:
        color = const Color(0xFF4CAF50);
      case GpsSignalStatus.fair:
        color = const Color(0xFFFF9800);
      case GpsSignalStatus.poor:
        color = const Color(0xFFF44336);
      case GpsSignalStatus.noSignal:
        color = AppColors.onSurfaceVariant;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: color.withValues(alpha: 0.5)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.gps_fixed, color: color, size: 14),
              const SizedBox(width: 6),
              Text(
                'GPS: $label',
                style: AppTextStyles.labelCapsSm(color: color),
              ),
              if (ctrl.gpsAccuracyMeters > 0) ...[
                const SizedBox(width: 6),
                Text(
                  '±${ctrl.gpsAccuracyMeters.toStringAsFixed(0)}m',
                  style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ── Ride mode pill ────────────────────────────────────────────────────────
  Widget _buildRideModePill(String mode) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                mode == 'group' ? Icons.groups_rounded : Icons.person,
                color: AppColors.circuitOrange,
                size: 14,
              ),
              const SizedBox(width: 6),
              Text(
                mode == 'group' ? 'GROUP' : 'SOLO',
                style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ── Bottom HUD panel ─────────────────────────────────────────────────────
  Widget _buildHud(RideController ctrl, BuildContext context) {
    final isPaused = ctrl.isPaused;
    final speed = ctrl.currentSpeedKmh.toStringAsFixed(0);
    final distStr = GeoUtils.formatDistance(ctrl.distanceKm);
    final dur = ctrl.duration;
    final durationStr = _formatDuration(dur);
    final avgSpeed = ctrl.averageSpeedKmh.toStringAsFixed(1);
    final maxSpeed = ctrl.maxSpeedKmh.toStringAsFixed(1);

    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.88),
            borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
            border: Border(top: BorderSide(color: AppColors.glassBorder)),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                20,
                AppSpacing.marginMobile,
                16,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Handle bar
                  Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(
                      color: AppColors.glassBorder,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),

                  // Paused banner
                  if (isPaused)
                    Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                      decoration: BoxDecoration(
                        color: Colors.amber.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.amber.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.pause_circle_filled, color: Colors.amber, size: 18),
                          const SizedBox(width: 8),
                          Text('RIDE PAUSED', style: AppTextStyles.labelCaps(color: Colors.amber)),
                        ],
                      ),
                    ),

                  // Giant speed
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        speed,
                        style: AppTextStyles.displayStat(color: AppColors.onSurface).copyWith(
                          fontSize: 72,
                          height: 1,
                          color: isPaused ? AppColors.onSurfaceVariant : AppColors.onSurface,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'KM/H',
                        style: AppTextStyles.labelCaps(color: AppColors.circuitOrange),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Stats row: Distance | Duration | Avg
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCell('DISTANCE', distStr),
                      _vertDivider(),
                      _statCell('DURATION', durationStr),
                      _vertDivider(),
                      _statCell('AVG', '$avgSpeed km/h'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _statCell('MAX', '$maxSpeed km/h'),
                      _vertDivider(),
                      _statCell('POINTS', '${ctrl.recordedPoints.length}'),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Control buttons
                  Row(
                    children: [
                      // Pause / Resume
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: isPaused
                                ? AppColors.circuitOrange.withValues(alpha: 0.15)
                                : AppColors.surfaceContainerHigh,
                            foregroundColor: isPaused
                                ? AppColors.circuitOrange
                                : AppColors.onSurface,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: isPaused
                                    ? AppColors.circuitOrange.withValues(alpha: 0.6)
                                    : AppColors.glassBorder,
                              ),
                            ),
                            elevation: 0,
                          ),
                          icon: Icon(isPaused
                              ? Icons.play_arrow_rounded
                              : Icons.pause_rounded),
                          label: Text(isPaused ? 'RESUME' : 'PAUSE'),
                          onPressed: () {
                            if (isPaused) {
                              ctrl.resumeRide();
                            } else {
                              ctrl.pauseRide();
                            }
                          },
                        ),
                      ),
                      const SizedBox(width: 12),

                      // End Ride
                      Expanded(
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.error.withValues(alpha: 0.15),
                            foregroundColor: AppColors.error,
                            padding: const EdgeInsets.symmetric(vertical: 14),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                              side: BorderSide(
                                color: AppColors.error.withValues(alpha: 0.5),
                              ),
                            ),
                            elevation: 0,
                          ),
                          icon: const Icon(Icons.stop_rounded),
                          label: const Text('END RIDE'),
                          onPressed: () => _confirmEndRide(ctrl, context),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ).animate().slideY(begin: 1.0, duration: 400.ms).fadeIn();
  }

  Widget _statCell(String label, String value) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
      ],
    );
  }

  Widget _vertDivider() {
    return Container(width: 1, height: 32, color: AppColors.glassBorder);
  }

  String _formatDuration(Duration d) {
    final h = d.inHours;
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    if (h > 0) return '$h:$m:$s';
    return '$m:$s';
  }

  Future<void> _confirmEndRide(RideController ctrl, BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('End Ride?', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Your ride will be saved.',
              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            ),
            const SizedBox(height: 8),
            Text(
              'Distance: ${GeoUtils.formatDistance(ctrl.distanceKm)}\n'
              'Duration: ${_formatDuration(ctrl.duration)}',
              style: AppTextStyles.bodyMd(color: AppColors.onSurface),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('End Ride'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      await ctrl.stopRide();
      if (context.mounted && ctrl.rideState == RideState.completed) {
        context.go(AppRoutes.rideSummary);
      }
    }
  }

  Future<bool?> _showExitConfirmation(BuildContext context) async {
    return showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Discard Ride?', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        content: Text(
          'Your current ride data will be lost.',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Stay', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Discard'),
          ),
        ],
      ),
    );
  }
}
