import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class AiPostRideAnalysisScreen extends StatelessWidget {
  const AiPostRideAnalysisScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Post-Ride Analysis', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      extendBodyBehindAppBar: true,
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
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('EFFORT SCORE', style: AppTextStyles.labelCaps()),
                              Text('HARD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.circuitOrange)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('85/100', style: AppTextStyles.displayStat()),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Great job pushing on the climbs. Your average power was 15% higher than your baseline.', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  
                  Text('PERFORMANCE VS HISTORICAL', style: AppTextStyles.labelCaps()),
                  const SizedBox(height: AppSpacing.md),
                  Container(
                    height: 160,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Stack(
                      children: [
                        CustomPaint(
                          painter: _AreaChartPainter(),
                          size: Size.infinite,
                        ),
                        Positioned(
                          top: AppSpacing.md,
                          left: AppSpacing.md,
                          child: Text('+15% Power', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('RECOVERY RECOMMENDATION', style: AppTextStyles.labelCaps()),
                          const SizedBox(height: AppSpacing.sm),
                          Row(
                            children: [
                              const Icon(Icons.timer_outlined, color: AppColors.circuitOrange),
                              const SizedBox(width: AppSpacing.sm),
                              Text('24-36 Hours', style: AppTextStyles.headlineMd().copyWith(color: AppColors.onSurface)),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.sm),
                          Text('Hydrate well and consider a light active recovery ride tomorrow.', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AreaChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.circuitOrange
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;

    final fillPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          AppColors.circuitOrange.withValues(alpha: 0.3),
          Colors.transparent,
        ],
      ).createShader(Rect.fromLTRB(0, 0, size.width, size.height));

    final path = Path();
    path.moveTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.25, size.height * 0.9, size.width * 0.5, size.height * 0.5);
    path.quadraticBezierTo(size.width * 0.75, size.height * 0.1, size.width, size.height * 0.3);

    canvas.drawPath(path, paint);

    final fillPath = Path.from(path);
    fillPath.lineTo(size.width, size.height);
    fillPath.lineTo(0, size.height);
    fillPath.close();

    canvas.drawPath(fillPath, fillPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
