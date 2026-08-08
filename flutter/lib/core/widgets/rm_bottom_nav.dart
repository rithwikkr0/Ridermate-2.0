import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';

/// Floating capsule bottom navigation bar with animated scroll-aware hide/show
/// Matches Stitch design: backdrop-blur-30px, rounded-full, border white/10, shadow orange glow
class RmBottomNav extends StatelessWidget {
  const RmBottomNav({
    super.key,
    required this.currentIndex,
    required this.onTap,
    this.visible = true,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final bool visible;

  static const _items = [
    _NavItem(icon: Icons.home_outlined,       activeIcon: Icons.home_rounded,          label: 'Home'),
    _NavItem(icon: Icons.explore_outlined,    activeIcon: Icons.explore_rounded,       label: 'Nav'),
    _NavItem(icon: Icons.psychology_outlined, activeIcon: Icons.psychology_rounded,    label: 'Coach'),
    _NavItem(icon: Icons.insights_outlined,   activeIcon: Icons.insights_rounded,      label: 'Stats'),
    _NavItem(icon: Icons.person_outline,      activeIcon: Icons.person_rounded,        label: 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return AnimatedPositioned(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      bottom: visible ? AppSpacing.bottomNavBottom : -100,
      left: AppSpacing.marginMobile,
      right: AppSpacing.marginMobile,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 30, sigmaY: 30),
          child: Container(
            height: AppSpacing.bottomNavHeight,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainer.withValues(alpha: 0.60),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(color: AppColors.glassBorder, width: 1),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FF6B00),
                  blurRadius: 32,
                  offset: Offset(0, 12),
                ),
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,

              children: List.generate(_items.length, (i) {
                final active = i == currentIndex;
                final item = _items[i];
                return GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: active
                          ? AppColors.circuitOrange.withValues(alpha: 0.10)
                          : Colors.transparent,
                      borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          active ? item.activeIcon : item.icon,
                          color: active ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                          size: AppSpacing.iconMd,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTextStyles.labelCaps(
                            color: active ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
  });
  final IconData icon;
  final IconData activeIcon;
  final String label;
}
