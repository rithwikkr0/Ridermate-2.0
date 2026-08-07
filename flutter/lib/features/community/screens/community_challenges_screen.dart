import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class CommunityChallengesScreen extends StatelessWidget {
  const CommunityChallengesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final challenges = [
      {
        'title': 'Monthly 500km',
        'progressStr': '120 / 500 km',
        'progress': 0.24,
        'ends': 'Ends Aug 31',
        'participants': '1,240 participants',
      },
      {
        'title': 'Elevation King',
        'progressStr': '1,240 / 5,000 m',
        'progress': 0.25,
        'ends': 'Ends Aug 15',
        'participants': '850 participants',
      },
      {
        'title': 'Speed Demon',
        'progressStr': '48 / 70 km/h',
        'progress': 0.69,
        'ends': 'Ends Aug 20',
        'participants': '2,100 participants',
      },
    ];

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
        title: Text('Challenges', style: AppTextStyles.headlineSm()),
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
            child: ListView.separated(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              itemCount: challenges.length,
              separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
              itemBuilder: (context, index) {
                final challenge = challenges[index];
                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(challenge['title'] as String, style: AppTextStyles.headlineSm()),
                          Text(challenge['ends'] as String, style: AppTextStyles.labelCaps().copyWith(color: AppColors.circuitOrange)),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(challenge['participants'] as String, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Progress', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                          Text(challenge['progressStr'] as String, style: AppTextStyles.h4()),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      LinearProgressIndicator(
                        value: challenge['progress'] as double,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        color: AppColors.circuitOrange,
                        minHeight: 8,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Row(
                        children: [
                          SizedBox(
                            width: 80,
                            height: 32,
                            child: Stack(
                              children: List.generate(3, (i) {
                                return Positioned(
                                  left: i * 20.0,
                                  child: CircleAvatar(
                                    radius: 16,
                                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${i + index * 5}'),
                                    backgroundColor: AppColors.surfaceContainerHigh,
                                  ),
                                );
                              }),
                            ),
                          ),
                          const Spacer(),
                          TextButton(
                            onPressed: () {},
                            child: Text('Join Challenge', style: AppTextStyles.bodyMd().copyWith(color: AppColors.circuitOrange)),
                          ),
                        ],
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 100 * index)).slideY(begin: 0.1);
              },
            ),
          ),
        ],
      ),
    );
  }
}
