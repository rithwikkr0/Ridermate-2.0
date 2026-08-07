import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

/// Squad/group list tile
class GroupTile extends StatelessWidget {
  const GroupTile({
    super.key,
    required this.name,
    this.description = '',
    this.memberCount,
    this.membersCount,
    this.totalDistance,
    this.totalKm,
    this.emoji = '🏍️',
    this.location,
    this.onTap,
    this.onPressed,
    this.isJoined = false,
  });

  final String name;
  final String description;
  final int? memberCount;
  final int? membersCount;
  final String? totalDistance;
  final String? totalKm;
  final String emoji;
  final String? location;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final bool isJoined;

  int get effectiveMembers => memberCount ?? membersCount ?? 0;
  String get effectiveKm => totalDistance ?? totalKm ?? '0 km';
  VoidCallback? get effectiveTap => onTap ?? onPressed;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      onTap: effectiveTap,
      padding: const EdgeInsets.all(AppSpacing.md),
      margin: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          // Emoji cover
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(AppSpacing.radiusMd),
              border: Border.all(color: AppColors.glassBorder),
            ),
            child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                if (description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    description,
                    style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
                const SizedBox(height: 6),
                Row(
                  children: [
                    const Icon(Icons.people_rounded, color: AppColors.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '$effectiveMembers members',
                      style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    const Icon(Icons.route_rounded, color: AppColors.onSurfaceVariant, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      effectiveKm,
                      style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isJoined
                  ? AppColors.surfaceContainerHigh
                  : AppColors.circuitOrange.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppSpacing.radiusFull),
              border: Border.all(
                color: isJoined ? AppColors.glassBorder : AppColors.circuitOrange.withValues(alpha: 0.4),
              ),
            ),
            child: Text(
              isJoined ? 'JOINED' : 'JOIN',
              style: AppTextStyles.labelCapsSm(
                color: isJoined ? AppColors.onSurfaceVariant : AppColors.circuitOrange,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
