import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/gamification/gamification_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';

class LeaderboardWidget extends StatelessWidget {
  const LeaderboardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationController>();

    if (gamification.leaderboard.isEmpty) {
      return Text(
        'No leaderboard data yet.',
        style: AppTextStyles.bodyText(color: AppColors.onSurfaceVariant),
      );
    }

    return GlassCard(
      child: ListView.builder(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: gamification.leaderboard.length,
        itemBuilder: (context, index) {
          final user = gamification.leaderboard[index];
          final bool isTop3 = index < 3;

          return ListTile(
            leading: CircleAvatar(
              backgroundColor: isTop3
                  ? AppColors.circuitOrange
                  : AppColors.surfaceContainerHigh,
              child: Text(
                '${index + 1}',
                style: AppTextStyles.h4(
                  color: isTop3
                      ? AppColors.onSurfaceLight
                      : AppColors.onSurface,
                ),
              ),
            ),
            title: Text(
              user['username']?.toString() ?? 'Rider',
              style: AppTextStyles.bodyText(),
            ),
            subtitle: Text(
              user['rider_level']?.toString() ?? 'Novice',
              style: AppTextStyles.caption(color: AppColors.onSurfaceVariant),
            ),
            trailing: Text(
              '${user['xp']} XP',
              style: AppTextStyles.h4(color: AppColors.circuitOrange),
            ),
          );
        },
      ),
    );
  }
}
