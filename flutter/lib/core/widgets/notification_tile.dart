import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../constants/mock_data.dart';
import '../notifications/models/app_notification.dart';

/// RiderMate 2.0 — Enhanced Notification Tile Supporting AppNotification
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    this.title,
    this.body,
    this.time,
    this.type,
    this.notification,
    this.appNotification,
    this.read = false,
    this.onTap,
    this.onDelete,
  });

  final String? title;
  final String? body;
  final String? time;
  final String? type;
  final NotificationModel? notification;
  final AppNotification? appNotification;
  final bool read;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  String get displayTitle =>
      appNotification?.title ?? title ?? notification?.title ?? '';

  String get displayBody =>
      appNotification?.body ?? body ?? notification?.body ?? '';

  String get displayTime {
    if (appNotification != null) {
      final diff = DateTime.now().difference(appNotification!.createdAt);
      if (diff.inMinutes < 1) return 'Just now';
      if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
      if (diff.inHours < 24) return '${diff.inHours}h ago';
      return '${diff.inDays}d ago';
    }
    return time ?? notification?.time ?? '';
  }

  bool get isRead =>
      appNotification?.isRead ?? (notification != null ? notification!.read : read);

  IconData get _icon {
    if (appNotification != null) {
      return appNotification!.type.icon;
    }
    return switch (type ?? notification?.type) {
      'achievement' => Icons.emoji_events_rounded,
      'ai'          => Icons.psychology_rounded,
      'social'      => Icons.group_rounded,
      'summary'     => Icons.bar_chart_rounded,
      'route'       => Icons.route_rounded,
      _             => Icons.notifications_rounded,
    };
  }

  Color get _iconColor {
    if (appNotification != null) {
      return appNotification!.type.color;
    }
    return switch (type ?? notification?.type) {
      'achievement' => const Color(0xFFFFD700),
      'ai'          => AppColors.circuitOrange,
      'social'      => const Color(0xFF4ECDC4),
      'summary'     => const Color(0xFF95E1D3),
      'route'       => const Color(0xFF6C63FF),
      _             => AppColors.softOrange,
    };
  }

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: Key(appNotification?.id ?? displayTitle + displayTime),
      direction: onDelete != null ? DismissDirection.endToStart : DismissDirection.none,
      onDismissed: (_) => onDelete?.call(),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: Colors.redAccent.withValues(alpha: 0.8),
        child: const Icon(Icons.delete_outline, color: Colors.white),
      ),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(AppSpacing.md),
          decoration: BoxDecoration(
            color: isRead
                ? AppColors.surfaceContainer.withValues(alpha: 0.30)
                : AppColors.surfaceContainerHigh,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: isRead ? AppColors.glassBorder : AppColors.circuitOrange.withValues(alpha: 0.4),
              width: isRead ? 1 : 1.5,
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: _iconColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _iconColor.withValues(alpha: 0.3)),
                ),
                child: Icon(_icon, color: _iconColor, size: AppSpacing.iconSm),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            displayTitle,
                            style: AppTextStyles.statLabel(
                              color: isRead ? AppColors.onSurfaceVariant : AppColors.onSurface,
                            ).copyWith(fontWeight: isRead ? FontWeight.normal : FontWeight.bold),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.circuitOrange,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      displayBody,
                      style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        if (appNotification != null)
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: _iconColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              appNotification!.type.displayName,
                              style: AppTextStyles.caption(color: _iconColor).copyWith(fontSize: 10),
                            ),
                          ),
                        Text(
                          displayTime,
                          style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
