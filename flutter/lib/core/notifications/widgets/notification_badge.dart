import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../controllers/notification_controller.dart';

/// RiderMate 2.0 — Reusable Reactive Notification Bell & Unread Badge Widget
class NotificationBadge extends StatelessWidget {
  final VoidCallback? onTap;
  final bool showBadgeCount;

  const NotificationBadge({
    super.key,
    this.onTap,
    this.showBadgeCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    final unreadCount = controller.unreadCount;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.glassBorder),
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.notifications_outlined,
              color: AppColors.onSurface,
              size: 20,
            ),
            if (unreadCount > 0)
              Positioned(
                top: 4,
                right: 4,
                child: Container(
                  padding: const EdgeInsets.all(3),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  decoration: const BoxDecoration(
                    color: AppColors.circuitOrange,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      unreadCount > 99 ? '99+' : unreadCount.toString(),
                      style: AppTextStyles.caption(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ).copyWith(fontSize: 9),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
