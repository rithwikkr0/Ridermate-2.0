import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

class LeaderboardScreen extends StatelessWidget {
  const LeaderboardScreen({super.key});

  static const leaderboard = [
    {'rank': 1, 'name': 'Arjun K.', 'score': '284 km', 'img': '1'},
    {'rank': 2, 'name': 'Priya S.', 'score': '256 km', 'img': '12'},
    {'rank': 3, 'name': 'John Rider', 'score': '248 km', 'img': '13', 'highlight': true},
    {'rank': 4, 'name': 'Rahul M.', 'score': '210 km', 'img': '5'},
    {'rank': 5, 'name': 'Divya R.', 'score': '195 km', 'img': '8'},
    {'rank': 6, 'name': 'Kiran P.', 'score': '180 km', 'img': '9'},
  ];

  @override
  Widget build(BuildContext context) {
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                children: [
                  const SizedBox(height: AppSpacing.sm),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    child: Row(
                      children: ['Distance', 'Elevation', 'Speed', 'Rides'].map((filter) {
                        final isSelected = filter == 'Distance';
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: Chip(
                            label: Text(
                              filter,
                              style: AppTextStyles.labelCapsSm(
                                color: isSelected ? Colors.white : AppColors.onSurface,
                              ),
                            ),
                            backgroundColor: isSelected ? AppColors.circuitOrange : AppColors.surfaceContainerHigh,
                            side: BorderSide(color: isSelected ? Colors.transparent : AppColors.glassBorder),
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // Podium
                  SizedBox(
                    height: 250,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        buildPodium(2, 'Priya S.', '256 km', '12', 100, false).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
                        const SizedBox(width: AppSpacing.sm),
                        buildPodium(1, 'Arjun K.', '284 km', '11', 140, true).animate().fadeIn(delay: 100.ms).slideY(begin: 0.2),
                        const SizedBox(width: AppSpacing.sm),
                        buildPodium(3, 'John Rider', '248 km', '13', 80, false).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2),
                      ],
                    ),
                  ),
                  
                  const SizedBox(height: AppSpacing.xl),
                  
                  // List
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                    itemCount: leaderboard.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
                    itemBuilder: (context, index) {
                      final item = leaderboard[index];
                      final isHighlighted = item['highlight'] == true;
                      
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
                                child: Text('#${item['rank']}', style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              CircleAvatar(
                                radius: 20,
                                backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=${item['img']}'),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Text(item['name'] as String, style: AppTextStyles.bodyLg(color: AppColors.onSurface)),
                              ),
                              Text(item['score'] as String, style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
                            ],
                          ),
                        ),
                      ).animate().fadeIn(delay: Duration(milliseconds: 400 + (index * 50))).slideX(begin: 0.1);
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

  Widget buildPodium(int rank, String name, String score, String imgIndex, double height, bool isFirst) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isFirst) const Icon(Icons.emoji_events, color: Color(0xFFFFD700), size: 28),
        CircleAvatar(
          radius: isFirst ? 28 : 22,
          backgroundImage: NetworkImage('https://i.pravatar.cc/150?img=$imgIndex'),
        ),
        const SizedBox(height: 4),
        Text(name, style: AppTextStyles.labelCapsSm(color: AppColors.onSurface)),
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
