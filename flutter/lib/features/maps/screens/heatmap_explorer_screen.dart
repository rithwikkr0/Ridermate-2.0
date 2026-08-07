import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class HeatmapExplorerScreen extends StatelessWidget {
  const HeatmapExplorerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Heatmap', style: AppTextStyles.headlineMd()),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Map + Heatmap Overlay
          Container(
            color: const Color(0xFF1E2020),
            child: Stack(
              children: [
                CustomPaint(
                  painter: _MapGridPainter(),
                  size: Size.infinite,
                ),
                CustomPaint(
                  painter: _HeatmapPainter(),
                  size: Size.infinite,
                ),
              ],
            ),
          ),
          
          // Filter Chips
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: AppSpacing.sm),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                child: Row(
                  children: [
                    _buildFilterChip('All', true),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('MTB', false),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('Road', false),
                    const SizedBox(width: AppSpacing.sm),
                    _buildFilterChip('City', false),
                  ],
                ),
              ),
            ).animate().slideY(begin: -0.5).fadeIn(),
          ),
          
          // Legend
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
                decoration: BoxDecoration(
                  color: AppColors.surfaceDark.withValues(alpha: 0.8),
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(color: AppColors.glassBorder),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Cold', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                    const SizedBox(width: AppSpacing.sm),
                    Container(
                      width: 100,
                      height: 8,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        gradient: const LinearGradient(
                          colors: [Colors.blue, Colors.green, Colors.yellow, Colors.red],
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Hot', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ).animate().slideY(begin: 1.0).fadeIn(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder),
      ),
      child: Text(label, style: AppTextStyles.bodyMd().copyWith(color: isSelected ? Colors.white : AppColors.onSurface)),
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
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class _HeatmapPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final points = [
      Offset(size.width * 0.5, size.height * 0.5),
      Offset(size.width * 0.4, size.height * 0.6),
      Offset(size.width * 0.6, size.height * 0.4),
      Offset(size.width * 0.55, size.height * 0.45),
    ];

    for (var point in points) {
      final paint = Paint()
        ..shader = RadialGradient(
          colors: [
            Colors.red.withValues(alpha: 0.5),
            Colors.yellow.withValues(alpha: 0.3),
            Colors.transparent
          ],
        ).createShader(Rect.fromCircle(center: point, radius: 100));
        
      canvas.drawCircle(point, 100, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
