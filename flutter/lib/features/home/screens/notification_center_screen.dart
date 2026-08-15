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
                    // ── Category Filter Chips ──────────────────────────────
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: [
                          _buildFilterChip(
                            context, 'All',
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
                          // All 8 category chips
                          for (final type in NotificationType.values) ...[
                            _buildTypeChip(context, type, controller),
                            const SizedBox(width: AppSpacing.sm),
                          ],
                        ],
                      ),
                    ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.md),

                    // ── Notification List ──────────────────────────────────
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
                        separatorBuilder: (_, index) => const SizedBox(height: AppSpacing.sm),
                        itemBuilder: (context, index) {
                          final notif = notifications[index];
                          return NotificationTile(
                            appNotification: notif,
                            onTap: () {
                              controller.markAsRead(notif.id);
                              _navigateFromNotification(context, notif.type, notif.route, notif.entityId);
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

  /// Navigates to the correct screen based on notification type and route.
  /// Emergency always goes to safety tracking. Falls back to dashboard if route is unknown.
  void _navigateFromNotification(
    BuildContext context,
    NotificationType type,
    String? route,
    String? entityId,
  ) {
    try {
      // Emergency — always safety tracking regardless of stored route
      if (type == NotificationType.emergency) {
        context.push('/safety/tracking');
        return;
      }

      // Memory type — navigate to memory detail with entity ID
      if (type == NotificationType.ride && route == '/memories/detail' && entityId != null) {
        context.push('/memories/detail', extra: entityId);
        return;
      }

      // Use stored route if valid
      if (route != null && route.isNotEmpty && route.startsWith('/')) {
        context.push(route);
        return;
      }

      // Fallback — no route or malformed route
      context.go('/');
    } catch (_) {
      // Navigation error — silently fall back to dashboard
      try {
        context.go('/');
      } catch (_) {}
    }
  }

  Widget _buildTypeChip(
    BuildContext context,
    NotificationType type,
    NotificationController controller,
  ) {
    final isSelected = controller.selectedFilter == type;
    return _buildFilterChip(
      context,
      type.displayName,
      isSelected,
      () => controller.setFilter(isSelected ? null : type),
      accentColor: type.color,
    );
  }

  Widget _buildFilterChip(
    BuildContext context,
    String label,
    bool isSelected,
    VoidCallback onTap, {
    Color? accentColor,
  }) {
    final color = accentColor ?? AppColors.circuitOrange;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? color.withValues(alpha: 0.2) : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? color : AppColors.glassBorder,
          ),
        ),
        child: Text(
          label,
          style: AppTextStyles.statLabel(
            color: isSelected ? color : AppColors.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
