import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/gamification/gamification_controller.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/widgets/glass_card.dart';
import 'leaderboard_widget.dart';

class AchievementsScreen extends StatefulWidget {
  const AchievementsScreen({super.key});

  @override
  State<AchievementsScreen> createState() => _AchievementsScreenState();
}

class _AchievementsScreenState extends State<AchievementsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<GamificationController>().loadUserStats();
    });
  }

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationController>();
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text('Achievements', style: AppTextStyles.h2),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
      ),
      body: gamification.isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.circuitOrange))
          : RefreshIndicator(
              onRefresh: () => gamification.loadUserStats(),
              color: AppColors.circuitOrange,
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildLevelCard(gamification),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Active Challenges'),
                  const SizedBox(height: 12),
                  _buildChallenges(gamification),
                  const SizedBox(height: 24),
                  _buildSectionTitle('My Achievements'),
                  const SizedBox(height: 12),
                  _buildAchievementsList(gamification),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Leaderboard'),
                  const SizedBox(height: 12),
                  const LeaderboardWidget(),
                ],
              ),
            ),
    );
  }

  Widget _buildLevelCard(GamificationController gamification) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(Icons.stars, color: AppColors.circuitOrange, size: 48),
            const SizedBox(height: 12),
            Text(gamification.level, style: AppTextStyles.h1),
            const SizedBox(height: 4),
            Text('\${gamification.xp} XP', style: AppTextStyles.bodyText.copyWith(color: AppColors.circuitOrange)),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(title, style: AppTextStyles.h3);
  }

  Widget _buildChallenges(GamificationController gamification) {
    if (gamification.activeChallenges.isEmpty) {
      return const Text('No active challenges right now.', style: AppTextStyles.bodyText);
    }
    return Column(
      children: gamification.activeChallenges.map((c) {
        final double progress = c['current_progress'] ?? 0.0;
        final double target = c['target_value'] ?? 1.0;
        final double percent = (progress / target).clamp(0.0, 1.0);
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: GlassCard(
            child: ListTile(
              title: Text(c['title'], style: AppTextStyles.h4),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text(c['description'], style: AppTextStyles.caption),
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: percent,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    color: AppColors.circuitOrange,
                  ),
                  const SizedBox(height: 4),
                  Text('\${progress.toStringAsFixed(0)} / \${target.toStringAsFixed(0)}', style: AppTextStyles.caption),
                ],
              ),
              trailing: Text('+\${c['xp_reward']} XP', style: AppTextStyles.bodyText.copyWith(color: AppColors.circuitOrange)),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAchievementsList(GamificationController gamification) {
    if (gamification.achievements.isEmpty) {
      return const Text('Complete activities to unlock achievements!', style: AppTextStyles.bodyText);
    }
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.85,
      ),
      itemCount: gamification.achievements.length,
      itemBuilder: (context, index) {
        final a = gamification.achievements[index];
        return GlassCard(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.emoji_events, color: AppColors.circuitOrange, size: 40),
                const SizedBox(height: 8),
                Text(
                  a['title'], 
                  style: AppTextStyles.bodyText,
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  '+\${a['xp_reward']} XP',
                  style: AppTextStyles.caption.copyWith(color: AppColors.circuitOrange),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
