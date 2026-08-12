import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/notification_tile.dart';
import '../../../core/notifications/controllers/notification_controller.dart';
import '../../../core/notifications/models/notification_type.dart';

class NotificationCenterScreen extends StatelessWidget {
  const NotificationCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    final notifications = controller.notifications;

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
        title: Text('Notification Center', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: AppColors.onSurfaceVariant),
            onPressed: () => context.push('/settings/notifications'),
            tooltip: 'Notification Settings',
          ),
          if (controller.unreadCount > 0)
            TextButton(
              onPressed: () => controller.markAllAsRead(),
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
            child: RefreshIndicator(
              color: AppColors.circuitOrange,
              onRefresh: () => controller.loadNotifications(),
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
                    // Category Filter Chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context,
                            'All',
                            controller.selectedFilter == null && !controller.unreadOnlyFilter,
                            () => controller.setFilter(null),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip(
                            context,
                            'Unread (${controller.unreadCount})',
                            controller.unreadOnlyFilter,
                            () => controller.setUnreadOnlyFilter(!controller.unreadOnlyFilter),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip(
                            context,
                            'Safety',
                            controller.selectedFilter == NotificationType.safety,
                            () => controller.setFilter(
                              controller.selectedFilter == NotificationType.safety ? null : NotificationType.safety,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip(
                            context,
                            'Ride',
                            controller.selectedFilter == NotificationType.ride,
                            () => controller.setFilter(
                              controller.selectedFilter == NotificationType.ride ? null : NotificationType.ride,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip(
                            context,
                            'AI',
                            controller.selectedFilter == NotificationType.ai,
                            () => controller.setFilter(
                              controller.selectedFilter == NotificationType.ai ? null : NotificationType.ai,
                            ),
                          ),
                          const SizedBox(width: AppSpacing.sm),
                          _buildFilterChip(
                            context,
                            'Achievements',
                            controller.selectedFilter == NotificationType.achievement,
                            () => controller.setFilter(
                              controller.selectedFilter == NotificationType.achievement ? null : NotificationType.achievement,
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.md),

                    if (notifications.isEmpty)
                      Container(
                        height: 300,
                        alignment: Alignment.center,
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_off_outlined,
                              size: 64,
                              color: AppColors.onSurfaceVariant,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text(
                              'No Notifications',
                              style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'You are all caught up!',
                              style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      )
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: notifications.length,
                        separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return NotificationTile(
                            appNotification: notif,
                            onTap: () {
                              controller.markAsRead(notif.id);
                              if (notif.route != null && notif.route!.isNotEmpty) {
                                try {
                                  context.push(notif.route!);
                                } catch (_) {}
                              }
                            },
                            onDelete: () => controller.deleteNotification(notif.id),
                          )
                              .animate()
                              .fadeIn(duration: 300.ms, delay: (50 * index).ms)
                              .slideY(begin: 0.05);
                        },
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterChip(BuildContext context, String label, bool isSelected, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
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
      ),
    );
  }
}
