import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';


class SettingsHomeScreen extends StatelessWidget {
  const SettingsHomeScreen({super.key});

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
                    _buildTile(Icons.person_outline, 'Edit Profile', () => context.push('/edit_profile')),
                    _buildTile(Icons.security, 'Privacy & Security', () => context.push('/privacy_security')),
                    _buildTile(Icons.link, 'Connected Accounts', () {}),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('PREFERENCES', [
                    _buildTile(Icons.notifications_outlined, 'Notification Settings', () => context.push('/settings/notifications')),
                    _buildTile(Icons.palette_outlined, 'Appearance', () => context.push('/appearance_settings')),
                    _buildTile(Icons.navigation_outlined, 'Navigation Settings', () {}),
                    _buildTile(Icons.straighten, 'Units', () {}),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SAFETY', [
                    _buildTile(Icons.health_and_safety_outlined, 'Safety Settings', () => context.push('/safety_settings')),
                    _buildTile(Icons.contact_phone_outlined, 'Emergency Contacts', () => context.push('/emergency_contacts')),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SUPPORT', [
                    _buildTile(Icons.help_outline, 'Help & Support', () => context.push('/help_support')),
                    _buildTile(Icons.description_outlined, 'Terms of Service', () {}),
                    _buildTile(Icons.privacy_tip_outlined, 'Privacy Policy', () {}),
                    _buildTile(Icons.info_outline, 'About', () {}),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('HARDWARE & TELEMETRY', [
                    _buildTile(Icons.gps_fixed, 'GPS Verification & Debug', () => context.push('/gps-debug')),
                  ]),
                  const SizedBox(height: AppSpacing.lg),
                  _buildSection('SESSION', [

                    ListTile(
                      leading: const Icon(Icons.logout, color: Colors.redAccent),
                      title: Text('Log Out', style: AppTextStyles.bodyMd(color: Colors.redAccent)),
                      onTap: () async {
                        final authController = context.read<AuthController>();
                        await authController.logout();
                        if (context.mounted) {
                          context.go('/login');
                        }
                      },
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
