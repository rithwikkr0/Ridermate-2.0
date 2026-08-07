import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/secondary_button.dart';

class FriendProfileScreen extends StatelessWidget {
  const FriendProfileScreen({super.key});

  Widget _buildStat(String label, String value, String unit) {
    return Column(
      children: [
        Text('$value$unit', style: AppTextStyles.headlineSm()),
        const SizedBox(height: 4),
        Text(label, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const CircleAvatar(
                    radius: 48,
                    backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=11'),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  Text('Arjun K.', style: AppTextStyles.headlineMd()).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  Text('@arjunk • Mumbai, India', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Stats row
                  GlassCard(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                    child: Row(
                      children: [
                        Expanded(child: _buildStat('DISTANCE', '284', 'KM')),
                        Container(width: 1, height: 40, color: AppColors.glassBorder),
                        Expanded(child: _buildStat('RIDES', '28', '')),
                        Container(width: 1, height: 40, color: AppColors.glassBorder),
                        Expanded(child: _buildStat('SADDLE TIME', '48', 'h')),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.lg),
                  
                  // Action buttons
                  Row(
                    children: [
                      Expanded(
                        child: PrimaryButton(label: 'Follow',
                          onPressed: () {},
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: SecondaryButton(
                          text: 'Message',
                          onPressed: () {},
                        ),
                      ),
                    ],
                  ).animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('RECENT RIDES', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  // Recent rides grid
                  GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: AppSpacing.md,
                      mainAxisSpacing: AppSpacing.md,
                      childAspectRatio: 1.5,
                    ),
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return GlassCard(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.directions_bike_rounded, color: AppColors.circuitOrange),
                            const Spacer(),
                            Text('${(45 - index * 5)} KM', style: AppTextStyles.h4()),
                            Text('1h ${(15 + index * 10)}m', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      );
                    },
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('ACHIEVEMENTS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                  ).animate().fadeIn(duration: 300.ms, delay: 500.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  SizedBox(
                    height: 100,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: 5,
                      separatorBuilder: (context, index) => const SizedBox(width: AppSpacing.md),
                      itemBuilder: (context, index) {
                        return GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.md),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.emoji_events_rounded, color: index == 0 ? Colors.amber : AppColors.circuitOrange, size: 32),
                              const SizedBox(height: 8),
                              Text('Badge ${index + 1}', style: AppTextStyles.labelCaps()),
                            ],
                          ),
                        );
                      },
                    ),
                  ).animate().fadeIn(duration: 300.ms, delay: 600.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
