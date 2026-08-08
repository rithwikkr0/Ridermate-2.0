import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/rm_scroll_body.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  int _selectedPeriod = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
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
          RmScrollBody(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.marginMobile,
                  AppSpacing.md,
                  AppSpacing.marginMobile,
                  100,
                ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Analytics', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceContainerHigh,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppColors.glassBorder),
                        ),
                        child: const Icon(Icons.bar_chart_rounded, color: AppColors.circuitOrange, size: 20),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: const EdgeInsets.all(4),
                    child: Row(
                      children: ['Week', 'Month', 'Year'].asMap().entries.map((e) {
                        final isSelected = _selectedPeriod == e.key;
                        return Expanded(
                          child: GestureDetector(
                            onTap: () => setState(() => _selectedPeriod = e.key),
                            child: Container(
                              height: 36,
                              decoration: BoxDecoration(
                                color: isSelected ? AppColors.circuitOrange : Colors.transparent,
                                borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                              ),
                              child: Center(
                                child: Text(
                                  e.value,
                                  style: AppTextStyles.statLabel(
                                    color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),
                  GridView.count(
                    crossAxisCount: 2,
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    crossAxisSpacing: AppSpacing.sm,
                    mainAxisSpacing: AppSpacing.sm,
                    childAspectRatio: 1.4,
                    children: [
                      StatsCard(label: 'Distance', value: '120', unit: 'KM', icon: Icons.route_rounded, trend: '+12%'),
                      StatsCard(label: 'Avg Speed', value: '27.6', unit: 'KM/H', icon: Icons.speed_rounded, trend: '+4%'),
                      StatsCard(label: 'Elevation', value: '1,240', unit: 'M', icon: Icons.terrain_rounded, trend: '+8%'),
                      StatsCard(label: 'Calories', value: '3,200', unit: 'KCAL', icon: Icons.local_fire_department_rounded),
                    ],
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Distance Chart', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    padding: EdgeInsets.zero,
                    child: Column(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('WEEKLY PROGRESS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                              Text('120 km total', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                            ],
                          ),
                        ),
                        Container(
                          height: 160,
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [18, 25, 12, 32, 28, 0, 0].map((val) {
                              return Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Container(
                                    width: 24,
                                    height: (val / 32) * 100,
                                    decoration: BoxDecoration(
                                      color: val > 0 ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text('$val', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                ],
                              );
                            }).toList(),
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ),
        ],
      ),
    );
  }
}
