import 'package:flutter/material.dart';
import '../constants/mock_data.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_spacing.dart';
import 'glass_card.dart';

/// Horizontal scrollable ride card for Dashboard
class RideCard extends StatelessWidget {
  const RideCard({
    super.key,
    required this.ride,
    this.onTap,
    this.onPressed,
    this.width = 240,
  });

  final RideModel ride;
  final VoidCallback? onTap;
  final VoidCallback? onPressed;
  final double width;

  VoidCallback? get effectiveTap => onTap ?? onPressed;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: effectiveTap,
      child: SizedBox(
        width: width,
        child: GlassCard(
          padding: const EdgeInsets.all(AppSpacing.md),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      ride.title,
                      style: AppTextStyles.statLabel(color: AppColors.onSurface),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                  Text(
                    ride.timeAgo.toUpperCase(),
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  Expanded(child: _StatChip(label: 'DIST', value: ride.distance)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _StatChip(label: 'AVG', value: ride.avgSpeed)),
                ],
              ),
              const SizedBox(height: AppSpacing.sm),
              Row(
                children: [
                  Expanded(child: _StatChip(label: 'TIME', value: ride.duration)),
                  const SizedBox(width: AppSpacing.sm),
                  Expanded(child: _StatChip(label: 'ELEV', value: ride.elevation)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
      ],
    );
  }
}
