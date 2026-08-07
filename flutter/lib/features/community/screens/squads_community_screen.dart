import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/group_tile.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class SquadsCommunityScreen extends StatelessWidget {
  const SquadsCommunityScreen({super.key});

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
        title: Text('Squads & Communities', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.circuitOrange,
        onPressed: () {},
        icon: const Icon(Icons.add, color: Colors.white),
        label: Text('Create Squad', style: AppTextStyles.buttonSm(color: Colors.white)),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('MY SQUADS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  GroupTile(
                    name: 'Mumbai Riders',
                    memberCount: 128,
                    totalDistance: '24,500 km',
                    emoji: '🏙️',
                    isJoined: true,
                    onTap: () => context.push(AppRoutes.squadDetails),
                  ).animate().fadeIn(duration: 300.ms, delay: 100.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text('DISCOVER SQUADS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms, delay: 200.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  GroupTile(
                    name: 'Western Ghats Crew',
                    memberCount: 56,
                    totalDistance: '18,200 km',
                    emoji: '⛰️',
                    onTap: () => context.push(AppRoutes.squadDetails),
                  ).animate().fadeIn(duration: 300.ms, delay: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.sm),
                  GroupTile(
                    name: 'Dawn Patrol',
                    memberCount: 34,
                    totalDistance: '9,800 km',
                    emoji: '🌅',
                    onTap: () => context.push(AppRoutes.squadDetails),
                  ).animate().fadeIn(duration: 300.ms, delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
