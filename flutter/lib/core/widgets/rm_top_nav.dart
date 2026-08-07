import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Frosted glass top app bar matching Stitch TopAppBar design.
/// background: surface/60, backdrop-filter: blur(30px), border-b white/10
class RmTopNav extends StatelessWidget implements PreferredSizeWidget {
  const RmTopNav({
    super.key,
    this.title = 'RiderMate',
    this.showAvatar = true,
    this.avatarUrl,
    this.onAvatarTap,
    this.onTap,
    this.onLeadingTap,
    this.onPressed,
    this.trailing,
    this.showNotification = true,
    this.onNotificationTap,
    this.leadingWidget,
    this.showBack = false,
  });

  final String title;
  final bool showAvatar;
  final String? avatarUrl;
  final VoidCallback? onAvatarTap;
  final VoidCallback? onTap;
  final VoidCallback? onLeadingTap;
  final VoidCallback? onPressed;
  final Widget? trailing;
  final bool showNotification;
  final VoidCallback? onNotificationTap;
  final Widget? leadingWidget;
  final bool showBack;

  VoidCallback? get effectiveLeadingTap => onLeadingTap ?? onTap ?? onPressed;

  @override
  Size get preferredSize => const Size.fromHeight(72);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          height: preferredSize.height + MediaQuery.of(context).padding.top,
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark.withValues(alpha: 0.60),
            border: const Border(
              bottom: BorderSide(color: AppColors.glassBorder, width: 1),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppSpacing.marginMobile,
              vertical: AppSpacing.md,
            ),
            child: Row(
              children: [
                // Leading
                if (showBack)
                  GestureDetector(
                    onTap: effectiveLeadingTap ?? () => Navigator.of(context).pop(),
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: const Icon(Icons.arrow_back_ios_new_rounded,
                          color: AppColors.onSurface, size: 18),
                    ),
                  )
                else if (showAvatar)
                  GestureDetector(
                    onTap: onAvatarTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                        child: avatarUrl != null
                            ? Image.network(avatarUrl!, fit: BoxFit.cover)
                            : const Icon(Icons.person_rounded, color: AppColors.onSurface),
                      ),
                    ),
                  )
                else if (leadingWidget case final leading?) leading,

                const SizedBox(width: AppSpacing.sm),

                // Title
                Expanded(
                  child: Text(
                    title,
                    style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

                // Trailing actions
                if (trailing != null)
                  trailing!
                else if (showNotification)
                  GestureDetector(
                    onTap: onNotificationTap,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          const Icon(Icons.notifications_outlined,
                              color: AppColors.onSurface, size: AppSpacing.iconSm),
                          Positioned(
                            top: 8,
                            right: 8,
                            child: Container(
                              width: 8,
                              height: 8,
                              decoration: const BoxDecoration(
                                color: AppColors.circuitOrange,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
