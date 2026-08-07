import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

import 'package:go_router/go_router.dart';

class AnalyticsHubScreen extends StatelessWidget {
  const AnalyticsHubScreen({super.key});

  static const _categories = [
    _Category(icon: Icons.route_rounded, title: 'Distance Trends', subtitle: '120 km this week', color: AppColors.circuitOrange),
    _Category(icon: Icons.speed_rounded, title: 'Speed Analysis', subtitle: 'Avg 27.6 km/h', color: Color(0xFF4ECDC4)),
    _Category(icon: Icons.terrain_rounded, title: 'Elevation Data', subtitle: '1,240m climbed', color: Color(0xFF95E1D3)),
    _Category(icon: Icons.bolt_rounded, title: 'Power Output', subtitle: '280W avg power', color: Color(0xFFFFD700)),
    _Category(icon: Icons.local_fire_department_rounded, title: 'Calories Burned', subtitle: '3,200 kcal/week', color: Color(0xFFFF6B6B)),
    _Category(icon: Icons.favorite_rounded, title: 'Heart Rate', subtitle: 'Avg 142 BPM', color: Color(0xFFE84393)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.8, -0.4), radius: 1.0,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text('Analytics Hub', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(duration: 300.ms),
            const SizedBox(height: AppSpacing.lg),
            GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, crossAxisSpacing: AppSpacing.sm, mainAxisSpacing: AppSpacing.sm, childAspectRatio: 1.1),
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(),
              itemCount: _categories.length,
              itemBuilder: (ctx, i) {
                final cat = _categories[i];
                return GlassCard(
                  onTap: () {},
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                    Container(width: 40, height: 40,
                      decoration: BoxDecoration(color: cat.color.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(12)),
                      child: Icon(cat.icon, color: cat.color, size: 20)),
                    Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(cat.title, style: AppTextStyles.statLabel(color: AppColors.onSurface), maxLines: 2),
                      const SizedBox(height: 4),
                      Text(cat.subtitle, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                    ]),
                  ]),
                ).animate().fadeIn(delay: Duration(milliseconds: i * 60));
              }),
          ]),
        )),
      ]),
    );
  }
}

class _Category {
  const _Category({required this.icon, required this.title, required this.subtitle, required this.color});
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
}
