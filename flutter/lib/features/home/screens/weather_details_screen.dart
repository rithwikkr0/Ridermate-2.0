import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../weather/controllers/weather_controller.dart';

class WeatherDetailsScreen extends StatelessWidget {
  const WeatherDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final weatherController = context.watch<WeatherController>();
    final weather = weatherController.weather;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: Text('WEATHER METRICS', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Main Weather Banner
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('CURRENT LOCATION', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                          Text('Mumbai, MH', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                        ],
                      ),
                      const Icon(Icons.light_mode, color: AppColors.circuitOrange, size: 48),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '${weather.temperatureC.toStringAsFixed(0)}°C',
                        style: AppTextStyles.displayStat(color: AppColors.circuitOrange).copyWith(fontSize: 56),
                      ),
                      Text(
                        weather.condition.toUpperCase(),
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                      ),
                    ],
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: AppSpacing.lg),

            // Ride Suitability Score Card
            GlassCard(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Row(
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      gradient: AppColors.orangeGradient,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        '${weather.suitabilityScore}%',
                        style: AppTextStyles.headlineMd(color: Colors.white),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('RIDE SUITABILITY SCORE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                        Text(
                          weather.suitabilityScore > 75 ? 'Optimal Riding Conditions' : 'Moderate Weather Alert',
                          style: AppTextStyles.statLabel(color: AppColors.onSurface),
                        ),
                        Text(
                          'Wind speed ${weather.windSpeedKmh} km/h with comfortable humidity.',
                          style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: AppSpacing.lg),

            // Grid of Metrics
            Row(
              children: [
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.air, color: AppColors.circuitOrange),
                        const SizedBox(height: 8),
                        Text('WIND SPEED', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                        Text('${weather.windSpeedKmh} km/h', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(Icons.water_drop_outlined, color: AppColors.circuitOrange),
                        const SizedBox(height: 8),
                        Text('HUMIDITY', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                        Text('${weather.humidity}%', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ),
              ],
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
            const SizedBox(height: AppSpacing.lg),

            // Hourly Forecast
            Text('HOURLY FORECAST', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.sm),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: weather.hourlyForecast.length,
                separatorBuilder: (_, _) => const SizedBox(width: AppSpacing.sm),
                itemBuilder: (context, index) {
                  final hour = weather.hourlyForecast[index];
                  return GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(hour.time, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        const Icon(Icons.wb_sunny, color: AppColors.softOrange, size: 24),
                        const SizedBox(height: 8),
                        Text('${hour.tempC.toStringAsFixed(0)}°', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                      ],
                    ),
                  );
                },
              ),
            ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
          ],
        ),
      ),
    );
  }
}
