import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class SquadDetailsScreen extends StatelessWidget {
  const SquadDetailsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Mumbai Riders', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.chat_bubble_outline, color: AppColors.onSurface),
            onPressed: () => context.push(AppRoutes.groupChat),
          ),
        ],
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: const Center(child: Text('🏙️', style: TextStyle(fontSize: 36))),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text('Mumbai Riders', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                          const SizedBox(height: 4),
                          Text('Urban & coastal weekend rides', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.md),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              _Stat('MEMBERS', '128'),
                              _Stat('DISTANCE', '24.5k km'),
                              _Stat('RIDES', '142'),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          PrimaryButton(
                            label: 'JOIN SQUAD',
                            onPressed: () {},
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('UPCOMING RIDES', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Coastal Highway Run', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                              Text('THIS SAT', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text('6:00 AM · Bandra Fort Assembly Point', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.val);
  final String label, val;
  @override
  Widget build(BuildContext context) => Column(
    children: [
      Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
      const SizedBox(height: 2),
      Text(val, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
    ],
  );
}
