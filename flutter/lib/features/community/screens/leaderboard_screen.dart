import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/community_controller.dart';

class LeaderboardScreen extends StatefulWidget {
  const LeaderboardScreen({super.key});

  @override
  State<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends State<LeaderboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadLeaderboard();
    });
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final list = community.leaderboard;

    final first = list.isNotEmpty ? list[0] : null;
    final second = list.length > 1 ? list[1] : null;
    final third = list.length > 2 ? list[2] : null;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Leaderboard', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        centerTitle: true,
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
            child: list.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.emoji_events_outlined, size: 56, color: AppColors.onSurfaceVariant),
                        const SizedBox(height: AppSpacing.sm),
                        Text('No Leaderboard Data Yet', style: AppTextStyles.headlineSm()),
                        const SizedBox(height: 4),
                        Text('Ride and track your distance to climb the leaderboard!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                      ],
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.only(bottom: 100),
                    child: Column(
                      children: [
                        const SizedBox(height: AppSpacing.md),
                        // Top Podium
                        SizedBox(
                          height: 250,
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              if (second != null)
                                buildPodium(2, second.name, '${second.distanceKm.toStringAsFixed(1)} km', 100, false)
                                    .animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                              const SizedBox(width: AppSpacing.sm),
                              if (first != null)
                                buildPodium(1, first.name, '${first.distanceKm.toStringAsFixed(1)} km', 140, true)
                                    .animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                              const SizedBox(width: AppSpacing.sm),
                              if (third != null)
                                buildPodium(3, third.name, '${third.distanceKm.toStringAsFixed(1)} km', 80, false)
                                    .animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                            ],
                          ),
                        ),

                        const SizedBox(height: AppSpacing.xl),

                        // List of All Riders
                        ListView.separated(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                          itemCount: list.length,
                          separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                          itemBuilder: (context, index) {
                            final item = list[index];
                            final isHighlighted = item.isCurrentUser;

                            return Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(16),
                                border: isHighlighted ? Border.all(color: AppColors.circuitOrange, width: 2) : null,
                              ),
                              child: GlassCard(
                                padding: const EdgeInsets.all(AppSpacing.md),
                                child: Row(
                                  children: [
                                    SizedBox(
                                      width: 30,
                                      child: Text('#${item.rank}', style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                                    ),
                                    const SizedBox(width: AppSpacing.sm),
                                    CircleAvatar(
                                      radius: 20,
                                      backgroundColor: AppColors.surfaceContainerHighest,
                                      backgroundImage: item.avatarUrl.isNotEmpty ? NetworkImage(item.avatarUrl) : null,
                                      child: item.avatarUrl.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
                                    ),
                                    const SizedBox(width: AppSpacing.md),
                                    Expanded(
                                      child: Text(
                                        item.isCurrentUser ? '${item.name} (You)' : item.name,
                                        style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                                      ),
                                    ),
                                    Text('${item.distanceKm.toStringAsFixed(1)} km', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                                  ],
                                ),
                              ),
                            ).animate().fadeIn(delay: Duration(milliseconds: 200 + (index * 30))).slideX(begin: 0.1);
                          },
                        ),
                      ],
                    ),
                  ),
          ),
        ],
      ),
    );
  }

  Widget buildPodium(int rank, String name, String score, double height, bool isFirst) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
        CircleAvatar(
          radius: isFirst ? 28 : 22,
          backgroundColor: AppColors.surfaceContainerHighest,
          child: const Icon(Icons.person, color: AppColors.onSurface),
        ),
        const SizedBox(height: 4),
        SizedBox(
          width: 80,
          child: Text(name, style: AppTextStyles.labelCapsSm(color: AppColors.onSurface), maxLines: 1, overflow: TextOverflow.ellipsis, textAlign: TextAlign.center),
        ),
        Text(score, style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
        const SizedBox(height: 4),
        Container(
          width: 80,
          height: height,
          decoration: BoxDecoration(
            color: isFirst ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            border: Border.all(color: AppColors.glassBorder),
          ),
          child: Center(
            child: Text('#$rank', style: AppTextStyles.headlineMd(color: isFirst ? Colors.white : AppColors.onSurface)),
          ),
        ),
      ],
    );
  }
}
