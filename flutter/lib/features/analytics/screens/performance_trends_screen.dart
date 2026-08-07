import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class PerformanceTrendsScreen extends StatelessWidget {
  const PerformanceTrendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0.5, -0.3), radius: 1.2,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface)),
              const SizedBox(width: AppSpacing.sm),
              Text('Performance Trends', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            GlassCard(padding: EdgeInsets.zero, child: Column(children: [
              Padding(padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                  Text('Speed Trend', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                  Text('LAST 8 WEEKS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                ])),
              SizedBox(height: 160, child: CustomPaint(painter: _LineChartPainter(), size: Size.infinite)),
              const SizedBox(height: AppSpacing.sm),
            ])).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
            Text('Performance PRs', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            ...[
              ('Fastest 5km Pace', '14:32 min/km', '3 weeks ago', Icons.timer_rounded),
              ('Longest Single Ride', '89.2 km', 'Last Saturday', Icons.route_rounded),
              ('Best Avg Speed', '31.4 km/h', '2 weeks ago', Icons.speed_rounded),
              ('Max Elevation', '820 m', 'Last Saturday', Icons.terrain_rounded),
            ].asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: AppColors.circuitOrange.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12)),
                    child: Icon(e.value.$4, color: AppColors.circuitOrange, size: 20)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text(e.value.$1, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                    Text(e.value.$3, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  ])),
                  Text(e.value.$2, style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                ])).animate().fadeIn(delay: Duration(milliseconds: 200 + e.key * 60)),
            )),
          ]),
        )),
      ]),
    );
  }
}

class _LineChartPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final vals = [0.5, 0.55, 0.6, 0.58, 0.7, 0.75, 0.72, 0.85];
    final pts = List.generate(vals.length, (i) =>
        Offset(AppSpacing.marginMobile + i * (size.width - AppSpacing.marginMobile * 2) / (vals.length - 1),
            size.height - 20 - vals[i] * (size.height - 40)));
    final linePaint = Paint()..color = AppColors.circuitOrange..strokeWidth = 2.5..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    final path = Path()..moveTo(pts.first.dx, pts.first.dy);
    for (int i = 1; i < pts.length; i++) {
      final cp1 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i-1].dy);
      final cp2 = Offset((pts[i-1].dx + pts[i].dx) / 2, pts[i].dy);
      path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, pts[i].dx, pts[i].dy);
    }
    canvas.drawPath(path, linePaint);
    final fillPath = Path.from(path)..lineTo(pts.last.dx, size.height - 20)..lineTo(pts.first.dx, size.height - 20)..close();
    canvas.drawPath(fillPath, Paint()..shader = LinearGradient(
      begin: Alignment.topCenter, end: Alignment.bottomCenter,
      colors: [AppColors.circuitOrange.withValues(alpha: 0.3), AppColors.circuitOrange.withValues(alpha: 0.0)],
    ).createShader(Rect.fromLTWH(0, 0, size.width, size.height)));
    for (final pt in pts) {
      canvas.drawCircle(pt, 4, Paint()..color = AppColors.circuitOrange);
      canvas.drawCircle(pt, 2.5, Paint()..color = AppColors.surfaceDark);
    }
  }
  @override bool shouldRepaint(_) => false;
}
