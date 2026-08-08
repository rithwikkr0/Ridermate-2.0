import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/ride_card.dart';
import '../../../core/constants/mock_data.dart' hide UserModel;

import '../../auth/models/user_model.dart';

import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../../garage/controllers/garage_controller.dart';


class MyProfileScreen extends StatelessWidget {
  const MyProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final garageController = context.watch<GarageController>();
    final user = profileController.userOrDefault;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.8, -0.6),
                radius: 1.2,
                colors: [Color(0x1AFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 100),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeader(context, user),
                  Padding(
                    padding: const EdgeInsets.all(AppSpacing.marginMobile),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildStatsRow(user),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Recent Rides', style: AppTextStyles.headlineSm()),
                        const SizedBox(height: AppSpacing.md),
                        SizedBox(
                          height: 200,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: 3,
                            itemBuilder: (context, index) {
                              return Padding(
                                padding: const EdgeInsets.only(right: AppSpacing.md),
                                child: SizedBox(
                                  width: 280,
                                  child: RideCard(ride: MockData.recentRides[index % MockData.recentRides.length]),
                                ),
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text('Achievements', style: AppTextStyles.headlineSm()),
                        const SizedBox(height: AppSpacing.md),
                        Row(
                          children: user.achievements
                              .take(3)
                              .map((a) => Padding(
                                    padding: const EdgeInsets.only(right: AppSpacing.sm),
                                    child: _buildAchievementBadge(a.split(' ')[0]),
                                  ))
                              .toList(),
                        ),
                        const SizedBox(height: AppSpacing.xl),
                        Text('My Vehicle', style: AppTextStyles.headlineSm()),
                        const SizedBox(height: AppSpacing.md),
                        GlassCard(
                          child: Padding(
                            padding: const EdgeInsets.all(AppSpacing.md),
                            child: Row(
                              children: [
                                const Icon(Icons.two_wheeler_rounded, size: 40, color: AppColors.onSurface),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.vehicles.isNotEmpty
                                            ? '${user.vehicles[0].brand} ${user.vehicles[0].model}'
                                            : 'No vehicle added',
                                        style: AppTextStyles.headlineSm(),
                                      ),
                                      Text(
                                        'Odometer: ${garageController.totalServiceCost > 0 ? "12,450 km" : "12,450 km"}',
                                        style: AppTextStyles.labelCapsSm(color: Colors.greenAccent),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, UserModel user) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
        child: Container(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.lg, AppSpacing.marginMobile, AppSpacing.lg),
          color: AppColors.surfaceDark.withValues(alpha: 0.6),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundImage: user.profilePhotoUrl.isNotEmpty
                        ? NetworkImage(user.profilePhotoUrl) as ImageProvider
                        : null,
                    backgroundColor: AppColors.surfaceContainerHigh,
                    child: user.profilePhotoUrl.isEmpty
                        ? const Icon(Icons.person, size: 36, color: AppColors.onSurfaceVariant)
                        : null,
                  ),

                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: AppTextStyles.headlineMd()),
                        Text('@${user.username}', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.circuitOrange,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(user.riderLevel.toUpperCase(), style: AppTextStyles.labelCapsSm(color: Colors.white)),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit, color: AppColors.onSurface),
                    onPressed: () => context.push('/edit_profile'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings, color: AppColors.onSurface),
                    onPressed: () => context.push('/settings'),
                  ),
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.redAccent),
                    onPressed: () async {
                      final authController = context.read<AuthController>();
                      await authController.logout();
                      if (context.mounted) {
                        context.go('/login');
                      }
                    },
                  ),

                ],
              ),
              const SizedBox(height: AppSpacing.lg),
              LinearProgressIndicator(
                value: user.xp / 10000,
                backgroundColor: AppColors.surfaceContainerHigh,
                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.circuitOrange),
              ),
              const SizedBox(height: 4),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('XP Progress', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                  Text('${user.xp} / 10000 XP', style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatsRow(UserModel user) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildStatItem('${user.totalDistanceKm.toStringAsFixed(0)} KM', 'Distance'),
        _buildStatItem('${user.totalRides}', 'Rides'),
        _buildStatItem('68h 30m', 'Time'),
      ],
    );
  }

  Widget _buildStatItem(String value, String label) {
    return Column(
      children: [
        Text(value, style: AppTextStyles.headlineMd()),
        Text(label, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      ],
    );
  }

  Widget _buildAchievementBadge(String emoji) {
    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        shape: BoxShape.circle,
      ),
      child: Center(
        child: Text(emoji, style: const TextStyle(fontSize: 24)),
      ),
    );
  }
}
