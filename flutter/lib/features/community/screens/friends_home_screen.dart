import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_text_field.dart';


class FriendsHomeScreen extends StatelessWidget {
  const FriendsHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final friends = [
      {'name': 'Arjun K.', 'status': 'online', 'time': ''},
      {'name': 'Priya S.', 'status': 'offline', 'time': '2h ago'},
      {'name': 'Rahul M.', 'status': 'offline', 'time': 'Yesterday'},
      {'name': 'Divya R.', 'status': 'offline', 'time': '3h ago'},
      {'name': 'Kiran P.', 'status': 'offline', 'time': '1d ago'},
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
        title: Text('Friends', style: AppTextStyles.headlineSm()),
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
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RMTextField(
                    hintText: 'Search friends...',
                    prefixIcon: Icons.search,
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  Text('MY FRIENDS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: friends.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final friend = friends[index];
                      final isOnline = friend['status'] == 'online';
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Row(
                          children: [
                            Stack(
                              children: [
                                CircleAvatar(
                                  radius: 24,
                                  backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${index + 10}'),
                                ),
                                if (isOnline)
                                  Positioned(
                                    bottom: 0,
                                    right: 0,
                                    child: Container(
                                      width: 12,
                                      height: 12,
                                      decoration: BoxDecoration(
                                        color: Colors.greenAccent,
                                        shape: BoxShape.circle,
                                        border: Border.all(color: AppColors.surfaceContainerHigh, width: 2),
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(friend['name']!, style: AppTextStyles.h4()),
                                  Text(
                                    isOnline ? 'Online' : 'Last seen ${friend['time']}',
                                    style: AppTextStyles.bodyMd().copyWith(
                                      color: isOnline ? Colors.greenAccent : AppColors.onSurfaceVariant,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.message_rounded, color: AppColors.circuitOrange),
                              onPressed: () {},
                            ),
                          ],
                        ),
                      ).animate().fadeIn(duration: 300.ms, delay: Duration(milliseconds: 150 + (50 * index))).slideY(begin: 0.1);
                    },
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('FIND RIDERS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      children: [
                        const CircleAvatar(
                          radius: 24,
                          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=32'),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Sam D.', style: AppTextStyles.h4()),
                              Text('Rides in Mumbai', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text('Add', style: AppTextStyles.bodyMd().copyWith(color: AppColors.circuitOrange)),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
