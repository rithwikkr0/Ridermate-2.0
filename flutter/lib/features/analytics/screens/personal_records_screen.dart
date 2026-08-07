import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class PersonalRecordsScreen extends StatelessWidget {
  const PersonalRecordsScreen({super.key});

  static const _records = [
    ('Fastest 5 km', '14:32', 'min', Icons.timer_rounded, 'Jun 12, 2026'),
    ('Longest Ride', '89.2', 'km', Icons.route_rounded, 'Aug 2, 2026'),
    ('Most Elevation', '820', 'm', Icons.terrain_rounded, 'Aug 2, 2026'),
    ('Fastest Avg Speed', '31.4', 'km/h', Icons.speed_rounded, 'Jul 28, 2026'),
    ('Max Top Speed', '62', 'km/h', Icons.bolt_rounded, 'Aug 2, 2026'),
    ('Most Calories', '1,760', 'kcal', Icons.local_fire_department_rounded, 'Aug 2, 2026'),
    ('Longest Streak', '7', 'days', Icons.whatshot_rounded, 'Jul 14, 2026'),
    ('Best Climb Rate', '18.5', 'm/min', Icons.trending_up_rounded, 'Jun 28, 2026'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.5, 0.3), radius: 1.1,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface)),
              const SizedBox(width: AppSpacing.sm),
              Text('Personal Records', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(),
            const SizedBox(height: AppSpacing.md),
            GlassCard(elevated: true, padding: const EdgeInsets.all(AppSpacing.md),
              child: Row(children: [
                const Icon(Icons.emoji_events_rounded, color: Color(0xFFFFD700), size: 32),
                const SizedBox(width: AppSpacing.md),
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text('8 Personal Records', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                  Text('KEEP PUSHING YOUR LIMITS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                ]),
              ])).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.lg),
            ..._records.asMap().entries.map((e) {
              final r = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(children: [
                    Container(width: 48, height: 48,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(colors: [Color(0xFFFFD700), Color(0xFFFF8C00)],
                          begin: Alignment.topLeft, end: Alignment.bottomRight),
                        borderRadius: BorderRadius.circular(12)),
                      child: Icon(r.$4, color: Colors.white, size: 22)),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(r.$1, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                      Text(r.$5, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                    ])),
                    RichText(text: TextSpan(
                      text: r.$2, style: AppTextStyles.displayStatSm(color: AppColors.circuitOrange),
                      children: [TextSpan(text: ' ${r.$3}', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant))],
                    )),
                  ])).animate().fadeIn(delay: Duration(milliseconds: 150 + e.key * 50)),
              );
            }),
          ]),
        )),
      ]),
    );
  }
}
