import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SafetyHistoryScreen extends StatelessWidget {
  const SafetyHistoryScreen({super.key});

  static const _events = [
    _SafetyEvent('SOS Triggered', 'Jul 14, 2026', 'Manual activation cancelled after 3s', Icons.warning_rounded, Color(0xFFFF4444)),
    _SafetyEvent('Crash Detection', 'Jun 28, 2026', 'False alarm — rough road detected', Icons.warning_amber_rounded, Color(0xFFFF8C00)),
    _SafetyEvent('Location Shared', 'Jun 12, 2026', '2h 30m session shared with Ramesh', Icons.shield_rounded, Color(0xFF4CAF50)),
    _SafetyEvent('Speed Alert', 'May 20, 2026', 'Exceeded 60 km/h in city zone', Icons.speed_rounded, Color(0xFFFFD700)),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.7, -0.4), radius: 1.2,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text('Safety History', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            ..._events.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Container(width: 44, height: 44,
                    decoration: BoxDecoration(color: e.value.color.withValues(alpha: 0.15), shape: BoxShape.circle),
                    child: Icon(e.value.icon, color: e.value.color, size: 20)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text(e.value.title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                      Text(e.value.date, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                    ]),
                    const SizedBox(height: 4),
                    Text(e.value.description, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                  ])),
                ])).animate().fadeIn(delay: Duration(milliseconds: e.key * 80)),
            )),
          ]),
        )),
      ]),
    );
  }
}

class _SafetyEvent {
  const _SafetyEvent(this.title, this.date, this.description, this.icon, this.color);
  final String title, date, description;
  final IconData icon;
  final Color color;
}
