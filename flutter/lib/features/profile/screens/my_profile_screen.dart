import 'package:flutter/material.dart';
import 'dart:ui';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_scroll_body.dart';
import '../../../core/router/app_router.dart';

import '../../auth/models/user_model.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/profile_controller.dart';
import '../../garage/controllers/garage_controller.dart';
import '../../safety/repositories/sqlite_traffic_repository.dart';
import '../../community/repositories/sqlite_friend_repository.dart';

/// RiderMate 2.0 — Central Personal Profile Dashboard & Command Hub Screen
class MyProfileScreen extends StatefulWidget {
  const MyProfileScreen({super.key});

  @override
  State<MyProfileScreen> createState() => _MyProfileScreenState();
}

class _MyProfileScreenState extends State<MyProfileScreen> {
  final SqliteTrafficRepository _trafficRepository = SqliteTrafficRepository();
  final SqliteFriendRepository _friendRepository = SqliteFriendRepository();

  int _safetyScore = 100;
  int _friendCount = 0;

  @override
  void initState() {
    super.initState();
    _loadProfileMetrics();
  }

  Future<void> _loadProfileMetrics() async {
    final authController = context.read<AuthController>();
    final uid = authController.currentUser?.id ?? 'user_guest';

    final scoreRes = await _trafficRepository.getSafetyScore(userId: uid);
    final friendsRes = await _friendRepository.getFriends(userId: uid);

    if (mounted) {
      setState(() {
        _safetyScore = scoreRes.dataOrNull ?? 100;
        _friendCount = (friendsRes.dataOrNull ?? []).length;
      });
    }
  }

  Future<void> _showLogoutDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Log Out of RiderMate?', style: AppTextStyles.headlineSm(color: Colors.white)),
        content: Text(
          'Your local telemetry and recorded rides remain safely stored on this device.',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final authController = context.read<AuthController>();
      await authController.logout();
      if (mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileController = context.watch<ProfileController>();
    final garageController = context.watch<GarageController>();
    final user = profileController.userOrDefault;
    final primaryVehicle = garageController.primaryVehicle;

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
          RmScrollBody(
            child: SafeArea(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 120),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(context, user),
                    Padding(
                      padding: const EdgeInsets.all(AppSpacing.marginMobile),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Quick Overview Stats Bar
                          _buildStatsRow(user),
                          const SizedBox(height: AppSpacing.xl),

                          // 1. MY RIDING SECTION
                          _buildSectionHeader('MY RIDING'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                _buildNavTile(
                                  icon: Icons.directions_bike_rounded,
                                  iconColor: AppColors.circuitOrange,
                                  title: 'Ride History & Telemetry',
                                  subtitle: '${user.totalRides} total rides • ${user.totalDistanceKm.toStringAsFixed(1)} km recorded',
                                  onTap: () => context.push(AppRoutes.rideHistory),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.bar_chart_rounded,
                                  iconColor: Colors.cyanAccent,
                                  title: 'Rider Analytics & Performance',
                                  subtitle: 'Speed trends, elevation profiles & records',
                                  onTap: () => context.push(AppRoutes.stats),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.emoji_events_rounded,
                                  iconColor: Colors.amber,
                                  title: 'Achievements & Milestones',
                                  subtitle: '${user.achievements.length} badges unlocked',
                                  onTap: () => context.push(AppRoutes.achievements),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 2. MY VEHICLES & GARAGE SECTION
                          _buildSectionHeader('MY VEHICLES & GARAGE'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                ListTile(
                                  leading: Container(
                                    padding: const EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: AppColors.circuitOrange.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: const Icon(Icons.two_wheeler_rounded, color: AppColors.circuitOrange, size: 24),
                                  ),
                                  title: Text(
                                    primaryVehicle != null
                                        ? '${primaryVehicle.brand} ${primaryVehicle.model}'
                                        : (user.vehicles.isNotEmpty
                                            ? '${user.vehicles[0].brand} ${user.vehicles[0].model}'
                                            : 'No Vehicle Registered'),
                                    style: AppTextStyles.headlineSm(),
                                  ),
                                  subtitle: Text(
                                    primaryVehicle != null
                                        ? 'Odometer: ${primaryVehicle.odometerKm.toStringAsFixed(0)} km • ${primaryVehicle.maskedRegistrationNumber}'
                                        : 'Tap to add your motorcycle or scooter',
                                    style: AppTextStyles.caption(color: AppColors.onSurfaceVariant),
                                  ),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.onSurfaceVariant, size: 16),
                                    onPressed: () => context.push(AppRoutes.garage),
                                  ),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.build_rounded,
                                  iconColor: Colors.lightBlueAccent,
                                  title: 'Garage & Maintenance Hub',
                                  subtitle: 'Service due in ${primaryVehicle?.serviceKmRemaining.toStringAsFixed(0) ?? "5,000"} km • Insurance & PUC status',
                                  onTap: () => context.push(AppRoutes.garage),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 3. FRIENDS SECTION
                          _buildSectionHeader('FRIENDS & SQUAD'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                _buildNavTile(
                                  icon: Icons.people_rounded,
                                  iconColor: Colors.greenAccent,
                                  title: 'Friends & Community Hub',
                                  subtitle: '$_friendCount friends connected • Social stories & squads',
                                  onTap: () => context.push(AppRoutes.friends),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.bookmark_rounded,
                                  iconColor: AppColors.circuitOrange,
                                  title: 'Saved Community Posts',
                                  subtitle: 'View your bookmarked rides and social moments',
                                  onTap: () => context.push(AppRoutes.savedPosts),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 4. MEMORIES SECTION
                          _buildSectionHeader('MEMORIES & JOURNAL'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                _buildNavTile(
                                  icon: Icons.photo_library_rounded,
                                  iconColor: Colors.purpleAccent,
                                  title: 'Rider Memories & Journal',
                                  subtitle: 'Photo journal, geotags & ride stories',
                                  onTap: () => context.push(AppRoutes.memories),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.map_rounded,
                                  iconColor: Colors.orangeAccent,
                                  title: 'Geotagged Memory Map',
                                  subtitle: 'Explore ride photos on interactive map',
                                  onTap: () => context.push(AppRoutes.memoryMap),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 5. SAFETY & TRAFFIC POINTS SECTION
                          _buildSectionHeader('SAFETY & TRAFFIC POINTS'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                _buildNavTile(
                                  icon: Icons.security_rounded,
                                  iconColor: _safetyScore >= 90 ? Colors.greenAccent : Colors.orangeAccent,
                                  title: 'Traffic Points & Safety Score',
                                  subtitle: 'Safety Score: $_safetyScore / 100 • View overspeed & telemetry log',
                                  onTap: () => context.push(AppRoutes.safetyPoints),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.contact_phone_rounded,
                                  iconColor: Colors.redAccent,
                                  title: 'Emergency Contacts & SOS',
                                  subtitle: 'Manage SOS contacts & crash detection settings',
                                  onTap: () => context.push(AppRoutes.emergencyContacts),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 6. SETTINGS & APP PREFERENCES SECTION
                          _buildSectionHeader('APP SETTINGS & PRIVACY'),
                          const SizedBox(height: AppSpacing.sm),
                          GlassCard(
                            child: Column(
                              children: [
                                _buildNavTile(
                                  icon: Icons.settings_outlined,
                                  iconColor: AppColors.onSurface,
                                  title: 'Settings & Configurations',
                                  subtitle: 'Preferences, appearance, privacy & hardware',
                                  onTap: () => context.push(AppRoutes.settings),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.notifications_active_rounded,
                                  iconColor: AppColors.circuitOrange,
                                  title: 'Notification Preferences',
                                  subtitle: 'Quiet settings for safety, ride, and maintenance alerts',
                                  onTap: () => context.push(AppRoutes.notificationSettings),
                                ),
                                const Divider(color: AppColors.glassBorder, height: 1),
                                _buildNavTile(
                                  icon: Icons.lock_outline_rounded,
                                  iconColor: AppColors.onSurfaceVariant,
                                  title: 'Privacy & Security Controls',
                                  subtitle: 'Location permissions, friend visibility & memory sharing',
                                  onTap: () => context.push(AppRoutes.privacySecurity),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          // 7. LOG OUT BUTTON
                          GlassCard(
                            child: ListTile(
                              leading: Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.redAccent.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Icon(Icons.logout_rounded, color: Colors.redAccent, size: 22),
                              ),
                              title: Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.redAccent)),
                              subtitle: Text('Sign out of your account on this device',
                                  style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
                              trailing: const Icon(Icons.arrow_forward_ios_rounded, color: Colors.redAccent, size: 16),
                              onTap: _showLogoutDialog,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
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
                    backgroundColor: AppColors.circuitOrange,
                    backgroundImage: user.profilePhotoUrl.isNotEmpty ? NetworkImage(user.profilePhotoUrl) : null,
                    child: user.profilePhotoUrl.isEmpty
                        ? Text(
                            user.fullName.isNotEmpty ? user.fullName.substring(0, 1) : 'R',
                            style: AppTextStyles.headlineLg(color: Colors.white),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(user.fullName, style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                        Text('@${user.username}', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 6),
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: AppColors.circuitOrange.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: AppColors.circuitOrange),
                              ),
                              child: Text(
                                user.riderLevel,
                                style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text('${user.xp} XP', style: AppTextStyles.statLabel(color: Colors.amber)),
                          ],
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.edit_outlined, color: AppColors.onSurfaceVariant),
                    onPressed: () => context.push(AppRoutes.editProfile),
                  ),
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
      children: [
        Expanded(child: _buildStatItem('Rides', '${user.totalRides}')),
        const SizedBox(width: 6),
        Expanded(child: _buildStatItem('Distance', '${user.totalDistanceKm.toStringAsFixed(0)} km')),
        const SizedBox(width: 6),
        Expanded(child: _buildStatItem('Safety', '$_safetyScore/100')),
        const SizedBox(width: 6),
        Expanded(child: _buildStatItem('Friends', '$_friendCount')),
      ],
    );
  }

  Widget _buildStatItem(String label, String value) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 4),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                value,
                maxLines: 1,
                style: AppTextStyles.headlineSm(color: AppColors.circuitOrange),
              ),
            ),
            const SizedBox(height: 2),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                style: AppTextStyles.caption(color: AppColors.onSurfaceVariant),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(title, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
    );
  }

  Widget _buildNavTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      onTap: onTap,
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
      subtitle: Text(subtitle, style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, color: AppColors.onSurfaceVariant, size: 16),
    );
  }
}
