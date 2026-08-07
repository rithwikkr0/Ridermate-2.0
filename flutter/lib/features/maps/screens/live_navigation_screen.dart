import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class LiveNavigationScreen extends StatelessWidget {
  const LiveNavigationScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Map Placeholder
          Container(
            color: const Color(0xFF1E2020),
            width: double.infinity,
            height: double.infinity,
            child: Stack(
              children: [
                CustomPaint(
                  painter: _MapGridPainter(),
                  size: Size.infinite,
                ),
                Center(
                  child: Icon(Icons.navigation_rounded, color: AppColors.circuitOrange, size: 64)
                      .animate(onPlay: (controller) => controller.repeat())
                      .shimmer(duration: 2.seconds),
                ),
              ],
            ),
          ),
          
          // Floating turn card at top
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      const Icon(Icons.turn_left_rounded, color: AppColors.circuitOrange, size: 48),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text('200m', style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface)),
                            Text('Turn left onto Coastal Rd', style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ).animate().slideY(begin: -1.0, duration: 400.ms).fadeIn(),
          ),
          
          // Speed indicator pill floating right
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: AppSpacing.marginMobile),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.sm),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text('32', style: AppTextStyles.headlineLg().copyWith(color: AppColors.circuitOrange)),
                      Text('km/h', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                    ],
                  ),
                ),
              ),
            ).animate().slideX(begin: 1.0, duration: 400.ms).fadeIn(),
          ),

          // Bottom sheet details
          Align(
            alignment: Alignment.bottomCenter,
            child: ClipRRect(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark.withValues(alpha: 0.8),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
                    border: Border(top: BorderSide(color: AppColors.glassBorder)),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Coastal Cliffs', style: AppTextStyles.headlineLg()),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildStat('ETA', '35', 'min'),
                            _buildStat('DIST', '22', 'km'),
                            _buildStat('ARRIVE', '14:30', ''),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.lg),
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.redAccent.withValues(alpha: 0.2),
                              foregroundColor: Colors.redAccent,
                              padding: const EdgeInsets.symmetric(vertical: 16),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              elevation: 0,
                            ),
                            onPressed: () => context.pop(),
                            child: Text('End Navigation', style: AppTextStyles.headlineMd()),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ).animate().slideY(begin: 1.0, duration: 400.ms).fadeIn(),
          ),
        ],
      ),
    );
  }

  Widget _buildStat(String label, String val, String unit) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(val, style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface)),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
            ],
          ],
        ),
      ],
    );
  }
}

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final step = 40.0;
    
    for (double i = 0; i < size.width; i += step) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += step) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    // Draw a subtle route line
    final routePaint = Paint()
      ..color = AppColors.circuitOrange.withValues(alpha: 0.5)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round;
      
    final path = Path();
    path.moveTo(size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.4, size.height * 0.6, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.6, size.height * 0.3, size.width * 0.5, size.height * 0.1);
    
    canvas.drawPath(path, routePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
