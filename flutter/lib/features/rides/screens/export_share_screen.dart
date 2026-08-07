import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/router/app_router.dart';

class ExportShareScreen extends StatelessWidget {
  const ExportShareScreen({super.key});

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
        title: Text('Export & Share', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
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
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Preview Card
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Preview', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: AppSpacing.sm),
                        Container(
                          height: 200,
                          width: double.infinity,
                          decoration: BoxDecoration(
                            color: AppColors.surfaceContainerHigh,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Stack(
                            children: [
                              CustomPaint(painter: _MapGridPainter(), size: Size.infinite),
                              Center(
                                child: Text('Morning Ascent', style: AppTextStyles.headlineMd(color: Colors.white)),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(
                              children: [
                                Text('42.5 KM', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                                Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                            Column(
                              children: [
                                Text('1H 45M', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                                Text('TIME', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text('Export Options', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildExportOption(
                    context,
                    icon: Icons.picture_as_pdf,
                    title: 'Export as PDF',
                    subtitle: 'Full ride report with charts',
                  ).animate().fadeIn(delay: 100.ms).slideY(),
                  
                  _buildExportOption(
                    context,
                    icon: Icons.map,
                    title: 'Export GPX Route',
                    subtitle: 'For navigation devices',
                  ).animate().fadeIn(delay: 200.ms).slideY(),
                  
                  _buildExportOption(
                    context,
                    icon: Icons.auto_stories,
                    title: 'Share as Story',
                    subtitle: 'Instagram, Snapchat, etc.',
                    onPressed: () => context.go(AppRoutes.rideStory),
                  ).animate().fadeIn(delay: 300.ms).slideY(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildExportOption(BuildContext context, {required IconData icon, required String title, required String subtitle, VoidCallback? onTap, VoidCallback? onPressed}) {
    final callback = onTap ?? onPressed ?? () {};
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: InkWell(
        onTap: callback,
        borderRadius: BorderRadius.circular(16),
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.surfaceContainerHigh,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icon, color: AppColors.circuitOrange),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                    Text(subtitle, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
            ],
          ),
        ),
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
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
