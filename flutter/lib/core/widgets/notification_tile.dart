import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import '../constants/mock_data.dart';

/// Notification list tile
class NotificationTile extends StatelessWidget {
  const NotificationTile({
    super.key,
    this.title,
    this.body,
    this.time,
    this.type,
    this.notification,
    this.read = false,
    this.onTap,
  });

  final String? title;
  final String? body;
  final String? time;
  final String? type;
  final NotificationModel? notification;
  final bool read;
  final VoidCallback? onTap;

  String get displayTitle => title ?? notification?.title ?? '';
  String get displayBody => body ?? notification?.body ?? '';
  String get displayTime => time ?? notification?.time ?? '';
  String get displayType => type ?? notification?.type ?? '';
  bool get isRead => notification != null ? notification!.read : read;

  IconData get _icon {
    return switch (displayType) {
      'achievement' => Icons.emoji_events_rounded,
      'ai'          => Icons.psychology_rounded,
      'social'      => Icons.group_rounded,
      'summary'     => Icons.bar_chart_rounded,
      'route'       => Icons.route_rounded,
      _             => Icons.notifications_rounded,
    };
  }

  Color get _iconColor {
    return switch (displayType) {
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isRead
              ? AppColors.surfaceContainer.withValues(alpha: 0.40)
              : AppColors.surfaceContainerHigh,
          border: Border(
            bottom: BorderSide(color: AppColors.glassBorder, width: 1),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
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
                          ),
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
                  Text(displayBody, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(
                    displayTime,
                    style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
