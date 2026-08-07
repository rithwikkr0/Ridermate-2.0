import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class SocialFeedScreen extends StatelessWidget {
  const SocialFeedScreen({super.key});

  static const _stories = [
    ('You', 'https://i.pravatar.cc/60?img=33', true),
    ('Arjun', 'https://i.pravatar.cc/60?img=1', false),
    ('Priya', 'https://i.pravatar.cc/60?img=5', false),
    ('Rahul', 'https://i.pravatar.cc/60?img=12', false),
    ('Divya', 'https://i.pravatar.cc/60?img=9', false),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0.7, -0.5), radius: 1.0,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: Column(children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 0),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Feed', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
              Row(children: [
                GestureDetector(onTap: () => context.push(AppRoutes.friends),
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.glassBorder)),
                    child: const Icon(Icons.people_rounded, color: AppColors.onSurface, size: 20))),
                const SizedBox(width: 8),
                GestureDetector(onTap: () => context.push(AppRoutes.squads),
                  child: Container(padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
                      borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.glassBorder)),
                    child: const Icon(Icons.group_rounded, color: AppColors.onSurface, size: 20))),
              ]),
            ]).animate().fadeIn()),
          const SizedBox(height: AppSpacing.md),
          // Stories
          SizedBox(height: 90, child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
            itemCount: _stories.length,
            itemBuilder: (ctx, i) {
              final s = _stories[i];
              return Padding(padding: const EdgeInsets.only(right: 12),
                child: Column(children: [
                  Container(width: 56, height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: s.$1 == 'You' ? AppColors.surfaceContainerHigh : AppColors.circuitOrange,
                        width: s.$1 == 'You' ? 2 : 2.5)),
                    child: ClipOval(child: Image.network(s.$2, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(color: AppColors.surfaceContainerHigh,
                        child: Icon(Icons.person_rounded, color: AppColors.onSurface))))),
                  const SizedBox(height: 4),
                  Text(s.$1, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                ]));
            })).animate().fadeIn(delay: 100.ms),
          Expanded(child: ListView.builder(
            padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 20),
            itemCount: 4,
            itemBuilder: (ctx, i) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.md),
              child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Row(children: [
                    ClipOval(child: Image.network('https://i.pravatar.cc/40?img=${i+1}', width: 36, height: 36, fit: BoxFit.cover,
                      errorBuilder: (_, _, _) => Container(width: 36, height: 36, color: AppColors.surfaceContainerHigh))),
                    const SizedBox(width: AppSpacing.sm),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(['Arjun K.','Priya S.','Rahul M.','Divya R.'][i],
                        style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                      Text('${2 + i}h ago', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                    ])),
                    const Icon(Icons.more_horiz_rounded, color: AppColors.onSurfaceVariant),
                  ]),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Just crushed ${[42,67,28,55][i]} km on the ${['mountain','coastal','city','highland'][i]} route! 🔥',
                    style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.sm),
                  Container(height: 120, decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder)),
                    child: Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                      _FeedStat('DIST', '${[42,67,28,55][i]} KM'),
                      _FeedStat('AVG', '${[28.2,31.4,22.4,29.8][i]} KM/H'),
                      _FeedStat('TIME', ['1h45m','2h20m','42m','2h10m'][i]),
                    ])),
                  const SizedBox(height: AppSpacing.sm),
                  Row(children: [
                    _ActionBtn(Icons.favorite_border_rounded, '${24 + i * 7}'),
                    const SizedBox(width: AppSpacing.md),
                    _ActionBtn(Icons.chat_bubble_outline_rounded, '${3 + i}'),
                    const SizedBox(width: AppSpacing.md),
                    _ActionBtn(Icons.share_rounded, ''),
                    const Spacer(),
                    Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(color: AppColors.circuitOrange.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(999),
                        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.3))),
                      child: Text(['Mountain','Coastal','City','Highland'][i],
                        style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange))),
                  ]),
                ])).animate().fadeIn(delay: Duration(milliseconds: i * 80)),
            ))),
        ])),
      ]),
    );
  }
}

class _FeedStat extends StatelessWidget {
  const _FeedStat(this.label, this.value);
  final String label, value;
  @override
  Widget build(BuildContext context) => Column(mainAxisSize: MainAxisSize.min, children: [
    Text(label, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
    const SizedBox(height: 4),
    Text(value, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
  ]);
}

class _ActionBtn extends StatelessWidget {
  const _ActionBtn(this.icon, this.label);
  final IconData icon;
  final String label;
  @override
  Widget build(BuildContext context) => Row(mainAxisSize: MainAxisSize.min, children: [
    Icon(icon, color: AppColors.onSurfaceVariant, size: 18),
    if (label.isNotEmpty) ...[const SizedBox(width: 4),
      Text(label, style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant))],
  ]);
}
