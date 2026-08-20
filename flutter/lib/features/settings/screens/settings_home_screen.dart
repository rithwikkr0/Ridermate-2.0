import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import '../../auth/controllers/auth_controller.dart';

class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

  Future<void> _showLogoutDialog(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Log Out of RiderMate?', style: AppTextStyles.headlineSm(color: Colors.white)),
        content: Text(
          'Your local telemetry, recorded rides, and offline cache will be securely preserved.',
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

    if (confirmed == true && context.mounted) {
      final authController = context.read<AuthController>();
      await authController.logout();
      if (context.mounted) {
        context.go(AppRoutes.login);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Settings', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('ACCOUNT', [
                    _buildTile(Icons.person_outline, 'Edit Profile', () => context.push(AppRoutes.editProfile)),
                    _buildTile(Icons.security, 'Privacy & Security', () => context.push(AppRoutes.privacySecurity)),
                    _buildTile(Icons.link, 'Connected Cloud Status', () => context.push(AppRoutes.profile)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('PREFERENCES', [
                    _buildTile(Icons.notifications_outlined, 'Notification Settings', () => context.push(AppRoutes.notificationSettings)),
                    _buildTile(Icons.palette_outlined, 'Appearance', () => context.push(AppRoutes.appearance)),
                    _buildTile(Icons.navigation_outlined, 'Navigation Settings', () => context.push(AppRoutes.navSettings)),
                    _buildTile(Icons.straighten, 'Units & Measurement', () => context.push(AppRoutes.appearance)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SAFETY & EMERGENCY', [
                    _buildTile(Icons.health_and_safety_outlined, 'Safety & Crash Detection', () => context.push(AppRoutes.safetySettings)),
                    _buildTile(Icons.contact_phone_outlined, 'Emergency SOS Contacts', () => context.push(AppRoutes.emergencyContacts)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SUPPORT & LEGAL', [
                    _buildTile(Icons.help_outline, 'Help & Support', () => context.push(AppRoutes.helpSupport)),
                    _buildTile(Icons.description_outlined, 'Terms of Service', () => context.push(AppRoutes.terms)),
                    _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy', () => context.push(AppRoutes.privacyPolicy)),
                    _buildTile(Icons.info_outline, 'About RiderMate 2.0', () => context.push(AppRoutes.about)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('HARDWARE & TELEMETRY', [
                    _buildTile(Icons.gps_fixed, 'GPS Verification & Diagnostics', () => context.push(AppRoutes.gpsDebug)),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SESSION', [
                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.redAccent)),
                      subtitle: Text('Sign out of your pilot account', style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
                      trailing: const Icon(Icons.chevron_right, color: Colors.redAccent),
                      onTap: () => _showLogoutDialog(context),
                    ),
                  ]),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 8, bottom: 8),
          child: Text(title, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        ),
        GlassCard(
          child: Column(
            children: children,
          ),
        ),
      ],
    );
  }

  Widget _buildTile(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.onSurface),
      title: Text(title, style: AppTextStyles.bodyMd()),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: onTap,
    );
  }
}
