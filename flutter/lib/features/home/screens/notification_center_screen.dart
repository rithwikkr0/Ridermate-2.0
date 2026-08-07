import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

import '../../../core/widgets/notification_tile.dart';
import '../../../core/constants/mock_data.dart';

import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.surfaceDark.withValues(alpha: 0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text('Notifications', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        actions: [
          TextButton(
            onPressed: () {},
            child: Text('Mark all read', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
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
                100, // bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        _buildFilterChip('All', true),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Unread', false),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('Achievements', false),
                        const SizedBox(width: AppSpacing.sm),
                        _buildFilterChip('AI', false),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: MockData.notifications.length,
                    separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final notif = MockData.notifications[index];
                      return NotificationTile(notification: notif)
                          .animate()
                          .fadeIn(duration: 300.ms, delay: (100 * index).ms)
                          .slideY(begin: 0.1);
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String label, bool isSelected) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: isSelected ? AppColors.circuitOrange.withValues(alpha: 0.2) : Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder,
        ),
      ),
      child: Text(
        label,
        style: AppTextStyles.statLabel(
          color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
        ),
      ),
    );
  }
}
