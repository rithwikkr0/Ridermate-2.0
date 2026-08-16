import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/stats_card.dart';
import '../../../core/widgets/rm_scroll_body.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/analytics_controller.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class AnalyticsDashboardScreen extends StatefulWidget {
  const AnalyticsDashboardScreen({super.key});

  @override
  State<AnalyticsDashboardScreen> createState() => _AnalyticsDashboardScreenState();
}

class _AnalyticsDashboardScreenState extends State<AnalyticsDashboardScreen> {
  int _selectedPeriod = 0;
  late AnalyticsController _controller;

  @override
  void initState() {
    super.initState();
    final userId = context.read<AuthController>().currentUser?.id ?? '';
    _controller = AnalyticsController(userId);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _controller,
      child: Scaffold(
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
                child: Consumer<AnalyticsController>(
                  builder: (context, controller, _) {
                    if (controller.isLoading) {
                      return const Center(child: CircularProgressIndicator(color: AppColors.circuitOrange));
                    }
                    return SingleChildScrollView(
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
                              GestureDetector(
                                onTap: () => context.push(AppRoutes.analyticsHub),
                                child: Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: AppColors.surfaceContainerHigh,
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: AppColors.glassBorder),
                                  ),
                                  child: const Icon(Icons.bar_chart_rounded, color: AppColors.circuitOrange, size: 20),
                                ),
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
                              StatsCard(label: 'Distance', value: controller.totalDistance.toStringAsFixed(1), unit: 'KM', icon: Icons.route_rounded, trend: ''),
                              StatsCard(label: 'Avg Speed', value: controller.avgSpeed.toStringAsFixed(1), unit: 'KM/H', icon: Icons.speed_rounded, trend: ''),
                              StatsCard(label: 'Elevation', value: controller.totalElevation.toStringAsFixed(0), unit: 'M', icon: Icons.terrain_rounded, trend: ''),
                              StatsCard(label: 'Calories', value: controller.totalCalories.toString(), unit: 'KCAL', icon: Icons.local_fire_department_rounded),
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
                                      Text('${controller.totalDistance.toStringAsFixed(1)} km total', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                                    ],
                                  ),
                                ),
                                Container(
                                  height: 160,
                                  padding: const EdgeInsets.all(AppSpacing.md),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: controller.weeklyDistances.map((val) {
                                      final maxDist = controller.weeklyDistances.isEmpty ? 1.0 : controller.weeklyDistances.reduce((a, b) => a > b ? a : b);
                                      final divisor = maxDist > 0 ? maxDist : 1.0;
                                      return Column(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Container(
                                            width: 24,
                                            height: (val / divisor) * 100,
                                            decoration: BoxDecoration(
                                              color: val > 0 ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
                                              borderRadius: BorderRadius.circular(6),
                                            ),
                                          ),
                                          const SizedBox(height: 8),
                                          Text(val.toStringAsFixed(0), style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
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
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

