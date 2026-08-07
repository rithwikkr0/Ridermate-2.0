import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

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
      vsync: this, duration: const Duration(milliseconds: 1000),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _beaconController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        // Map placeholder
        Container(
          color: const Color(0xFF1E2020),
          child: CustomPaint(painter: _MapGridPainter(), size: Size.infinite)),
        // Pulsing beacon
        Center(child: AnimatedBuilder(
          animation: _beaconController,
          builder: (ctx, child) {
            final scale = 1.0 + _beaconController.value * 0.3;
            return Stack(alignment: Alignment.center, children: [
              Transform.scale(scale: scale,
                child: Container(width: 80, height: 80,
                  decoration: BoxDecoration(shape: BoxShape.circle,
                    color: const Color(0xFFFF3333).withValues(alpha: 0.2)))),
              Container(width: 24, height: 24,
                decoration: const BoxDecoration(color: Color(0xFFFF3333), shape: BoxShape.circle)),
            ]);
          })),
        // Top badge
        SafeArea(child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: Container(padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(color: AppColors.surfaceDark.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder)),
                  child: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 18))),
              const SizedBox(width: AppSpacing.sm),
              Container(padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: const Color(0xFFFF3333),
                  borderRadius: BorderRadius.circular(AppSpacing.radiusFull)),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.circle, color: Colors.white, size: 8),
                  const SizedBox(width: 6),
                  Text('LIVE TRACKING', style: AppTextStyles.labelCaps(color: Colors.white)),
                ])).animate().fadeIn(),
            ]),
          ]))),
        // Bottom panel
        Align(alignment: Alignment.bottomCenter,
          child: Padding(padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: GlassCard(elevated: true, padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text('Sharing location with', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                const SizedBox(height: AppSpacing.sm),
                Row(children: [
                  _ContactChip('Ramesh Rider', 'Father'),
                  const SizedBox(width: AppSpacing.sm),
                  _ContactChip('Meera Rider', 'Mother'),
                ]),
                const SizedBox(height: AppSpacing.md),
                Text('Your location is being updated every 30 seconds',
                  style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                const SizedBox(height: AppSpacing.md),
                SizedBox(width: double.infinity, height: 48,
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Color(0xFFFF3333)),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.radiusMd))),
                    onPressed: () => context.pop(),
                    child: Text('Stop Sharing', style: AppTextStyles.button(color: const Color(0xFFFF3333))))),
              ]))).animate().slideY(begin: 0.3).fadeIn(delay: 200.ms)),
      ]),
    );
  }
}

class _ContactChip extends StatelessWidget {
  const _ContactChip(this.name, this.relation);
  final String name, relation;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
      border: Border.all(color: AppColors.glassBorder)),
    child: Row(mainAxisSize: MainAxisSize.min, children: [
      const Icon(Icons.location_on_rounded, color: AppColors.circuitOrange, size: 12),
      const SizedBox(width: 4),
      Text('$name ($relation)', style: AppTextStyles.labelCapsSm(color: AppColors.onSurface)),
    ]),
  );
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = const Color(0xFF2A2A2A)..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 40) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), paint);
    }
    for (double y = 0; y < size.height; y += 40) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), paint);
    }
  }
  @override bool shouldRepaint(_) => false;
}
