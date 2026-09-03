import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../safety/controllers/sos_controller.dart';
import '../../safety/services/emergency_call_service.dart';

class EmergencyTrackingScreen extends StatefulWidget {
  const EmergencyTrackingScreen({super.key});
  @override
  State<EmergencyTrackingScreen> createState() => _EmergencyTrackingScreenState();
}

class _EmergencyTrackingScreenState extends State<EmergencyTrackingScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _beaconController;

  @override
  void initState() {
    super.initState();
    _beaconController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _beaconController.dispose();
    super.dispose();
  }

  Future<void> _confirmResolve() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text("Mark Emergency Resolved?", style: AppTextStyles.headlineSm()),
        content: Text(
          "Are you safe? This will stop live location tracking and notify your emergency contacts.",
          style: AppTextStyles.bodyMd(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text("NOT SAFE", style: AppTextStyles.button(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text("I'M SAFE", style: AppTextStyles.button(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      await context.read<SosController>().resolveEmergency();
      if (mounted) context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sosController = context.watch<SosController>();
    final currentEvent = sosController.currentSosEvent;
    final primary = sosController.primaryContact;
    final timelineEvents = sosController.timeline.events;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Real OpenStreetMap view with emergency beacon marker
          const RealMapView(
            initialZoom: 15.0,
          ),

          // Pulsing emergency beacon overlay
          Center(
            child: AnimatedBuilder(
              animation: _beaconController,
              builder: (ctx, child) {
                final scale = 1.0 + _beaconController.value * 0.4;
                return Stack(
                  alignment: Alignment.center,
                  children: [
                    Transform.scale(
                      scale: scale,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: const Color(0xFFFF3333).withValues(alpha: 0.3 * _beaconController.value),
                        ),
                      ),
                    ),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: const BoxDecoration(
                        color: Color(0xFFFF3333),
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(color: Colors.redAccent, blurRadius: 10, spreadRadius: 2),
                        ],
                      ),
                      child: const Icon(Icons.sos, color: Colors.white, size: 16),
                    ),
                  ],
                );
              },
            ),
          ),

          // Top Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceDark.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFF3333),
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                      boxShadow: const [BoxShadow(color: Colors.red, blurRadius: 8)],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.circle, color: Colors.white, size: 10),
                        const SizedBox(width: 6),
                        Text(
                          'SOS ACTIVE — LIVE TRACKING',
                          style: AppTextStyles.labelCaps(color: Colors.white).copyWith(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(),
                ],
              ),
            ),
          ),

          // Bottom Emergency Status & Resolution Control Card
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: GlassCard(
                elevated: true,
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Primary Emergency Contact', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
                            Text(
                              primary != null ? '${primary.name} (${primary.relationship})' : 'Not Configured',
                              style: AppTextStyles.headlineSm(),
                            ),
                          ],
                        ),
                        if (primary != null)
                          IconButton.filled(
                            style: IconButton.styleFrom(backgroundColor: Colors.green),
                            icon: const Icon(Icons.phone, color: Colors.white),
                            onPressed: () => const EmergencyCallService().placeCall(primary.phoneNumber),
                          ),
                      ],
                    ),
                    const Divider(color: AppColors.glassBorder, height: 20),
                    // Live Compass & High-Accuracy Coordinates Box
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.3)),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.circuitOrange.withValues(alpha: 0.15),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(Icons.explore, color: AppColors.circuitOrange, size: 22),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  currentEvent?.latitude != null
                                      ? 'LAT: ${currentEvent!.latitude!.toStringAsFixed(5)}°  LNG: ${currentEvent.longitude!.toStringAsFixed(5)}°'
                                      : 'ACQUIRING GPS FIX...',
                                  style: AppTextStyles.labelCapsSm(color: Colors.white).copyWith(
                                    fontFamily: 'monospace',
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Accuracy ±${currentEvent?.accuracy?.toStringAsFixed(0) ?? "15"}m • Offline Compass Active',
                                  style: AppTextStyles.caption(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Live location updates every 15 seconds. Saved locally in SQLite.',
                      style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
                    ),
                    if (timelineEvents.isNotEmpty) ...[
                      const SizedBox(height: AppSpacing.sm),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline, size: 16, color: AppColors.circuitOrange),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                timelineEvents.last.description,
                                style: AppTextStyles.bodyXs(color: AppColors.onSurface),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],

                    // Distress Dispatch Buttons (Always available even without saved contacts)
                    const SizedBox(height: AppSpacing.sm),
                    Row(
                      children: [
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFFCC0000),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.send_rounded, size: 16),
                            label: const Text('SMS Draft', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => sosController.dispatchSmsOnly(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF25D366),
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.chat_bubble_rounded, size: 16),
                            label: const Text('WhatsApp', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => sosController.dispatchWhatsAppOnly(),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.blueAccent,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            ),
                            icon: const Icon(Icons.phone_in_talk, size: 16),
                            label: const Text('Call 112', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                            onPressed: () => sosController.dispatchCallOnly(),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.green,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                          ),
                        ),
                        onPressed: _confirmResolve,
                        child: Text(
                          "I'M SAFE — RESOLVE SOS",
                          style: AppTextStyles.button(color: Colors.white).copyWith(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ).animate().slideY(begin: 0.3).fadeIn(delay: 100.ms),
            ),
          ),
        ],
      ),
    );
  }
}
