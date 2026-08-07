import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideSummaryScreen extends StatelessWidget {
  const RideSummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
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
                  // Map placeholder
                  Container(
                    height: 250,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.map_rounded, color: AppColors.circuitOrange, size: 48),
                              const SizedBox(height: 8),
                              Text('Route Map', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Hero stats
                  Row(
                    children: [
                      Expanded(child: _buildStat('DISTANCE', '42.5', 'KM')),
                      Expanded(child: _buildStat('AVG SPEED', '28.2', 'KM/H')),
                      Expanded(child: _buildStat('DURATION', '1h 45m', '')),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Secondary stats
                  Row(
                    children: [
                      Expanded(child: _buildStat('MAX SPEED', '48.5', 'KM/H')),
                      Expanded(child: _buildStat('ELEVATION', '350', 'M')),
                      Expanded(child: _buildStat('CALORIES', '850', 'KCAL')),
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
                        child: SecondaryButton(
                          text: 'Share',
                          onPressed: () => context.go(AppRoutes.rideStory),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
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

class _MapGridPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double i = 0; i < size.width; i += 20) {
      canvas.drawLine(Offset(i, 0), Offset(i, size.height), paint);
    }
    for (double i = 0; i < size.height; i += 20) {
      canvas.drawLine(Offset(0, i), Offset(size.width, i), paint);
    }
    
    final pathPaint = Paint()
      ..color = AppColors.circuitOrange
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;
      
    final path = Path()
      ..moveTo(size.width * 0.2, size.height * 0.8)
      ..quadraticBezierTo(size.width * 0.5, size.height * 0.5, size.width * 0.8, size.height * 0.2);
      
    canvas.drawPath(path, pathPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
