import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class RouteComparisonScreen extends StatelessWidget {
  const RouteComparisonScreen({super.key});

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
        title: Text('Compare Routes', style: AppTextStyles.headlineMd()),
        centerTitle: true,
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
                children: [
                  _buildComparisonCard('Fastest Route', '22 km', '35 min', '300m', 'Low', true).animate().fadeIn(delay: 100.ms).slideX(),
                  const SizedBox(height: AppSpacing.md),
                  _buildComparisonCard('Scenic Route', '25 km', '45 min', '500m', 'Medium', false).animate().fadeIn(delay: 200.ms).slideX(),
                  const SizedBox(height: AppSpacing.md),
                  _buildComparisonCard('Mountain Route', '24 km', '55 min', '800m', 'High', false).animate().fadeIn(delay: 300.ms).slideX(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildComparisonCard(String title, String dist, String time, String elev, String diff, bool isRecommended) {
    return GlassCard(
      child: Container(
        decoration: isRecommended
            ? BoxDecoration(
                border: Border.all(color: AppColors.circuitOrange),
                borderRadius: BorderRadius.circular(24),
              )
            : null,
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(title, style: AppTextStyles.headlineMd().copyWith(color: isRecommended ? AppColors.circuitOrange : AppColors.onSurface)),
                if (isRecommended)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.circuitOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text('RECOMMENDED', style: AppTextStyles.labelCaps().copyWith(color: AppColors.circuitOrange)),
                  ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildStatColumn('DISTANCE', dist),
                _buildStatColumn('TIME', time),
                _buildStatColumn('ELEVATION', elev),
                _buildStatColumn('DIFFICULTY', diff),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 4),
        Text(value, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
      ],
    );
  }
}
