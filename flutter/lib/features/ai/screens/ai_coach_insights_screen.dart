import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class AiCoachInsightsScreen extends StatelessWidget {
  const AiCoachInsightsScreen({super.key});

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
        title: Text('Coach Insights', style: AppTextStyles.headlineMd()),
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
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text('READINESS SCORE', style: AppTextStyles.labelCaps()).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: AppSpacing.md),
                  Text('92', style: AppTextStyles.displayStat().copyWith(fontSize: 72, color: AppColors.circuitOrange)).animate().fadeIn(delay: 100.ms).scale(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Prime condition for a hard effort today.', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('WEEKLY TRAINING LOAD', style: AppTextStyles.labelCaps()),
                  ).animate().fadeIn(delay: 300.ms),
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
                          painter: _BarChartPainter(),
                          size: Size.infinite,
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('INSIGHTS', style: AppTextStyles.labelCaps()),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildInsightCard(
                    icon: Icons.flash_on,
                    title: 'Sprint Power Increase',
                    description: 'Your peak power is up 5% this week.',
                  ).animate().fadeIn(delay: 600.ms).slideX(begin: 0.1),
                  const SizedBox(height: AppSpacing.sm),
                  
                  _buildInsightCard(
                    icon: Icons.favorite_border,
                    title: 'Heart Rate Variability',
                    description: 'HRV is stable, indicating good recovery.',
                  ).animate().fadeIn(delay: 700.ms).slideX(begin: 0.1),
                  const SizedBox(height: AppSpacing.sm),
                  
                  _buildInsightCard(
                    icon: Icons.directions_bike,
                    title: 'Cadence Optimization',
                    description: 'Try maintaining 90 RPM on climbs for better efficiency.',
                  ).animate().fadeIn(delay: 800.ms).slideX(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({required IconData icon, required String title, required String description}) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: AppColors.circuitOrange, size: 28),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.headlineMd().copyWith(fontSize: 18)),
                  const SizedBox(height: 4),
                  Text(description, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BarChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.circuitOrange
      ..style = PaintingStyle.fill
      ..strokeCap = StrokeCap.round;

    final barWidth = 16.0;
    final spacing = (size.width - (7 * barWidth)) / 8;
    final heights = [0.4, 0.6, 0.3, 0.8, 0.5, 0.9, 0.7];

    for (int i = 0; i < 7; i++) {
      final x = spacing + (i * (barWidth + spacing));
      final barHeight = size.height * heights[i] * 0.8;
      final y = size.height - barHeight - 16;
      
      final rect = RRect.fromRectAndRadius(
        Rect.fromLTWH(x, y, barWidth, barHeight),
        const Radius.circular(8),
      );
      
      canvas.drawRRect(rect, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
