import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class PrivacySecurityScreen extends StatelessWidget {
  const PrivacySecurityScreen({super.key});

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
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.settings);
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Privacy & Security', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Text('Privacy', style: AppTextStyles.headlineSm()),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    child: Column(
                      children: [
                        _buildSwitchTile('Public Profile', true),
                        _buildSwitchTile('Share Rides Publicly', false),
                        _buildSwitchTile('Location Visibility', true, subtitle: 'Friends only'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Security', style: AppTextStyles.headlineSm()),
                  const SizedBox(height: AppSpacing.md),
                  GlassCard(
                    child: Column(
                      children: [
                        _buildArrowTile(context, 'Change Password'),
                        _buildArrowTile(context, 'Two-Factor Authentication'),
                        _buildArrowTile(context, 'Active Sessions'),
                        ListTile(
                          title: const Text('Delete Account', style: TextStyle(color: Colors.red, fontFamily: 'Inter')),
                          trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
                          onTap: () {
                            showDialog<void>(
                              context: context,
                              builder: (ctx) => AlertDialog(
                                backgroundColor: AppColors.surfaceContainerHigh,
                                title: const Text('Delete Account?', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                                content: Text(
                                  'Are you sure you want to delete your RiderMate account? All your ride telemetry, garage logs, and badges will be permanently erased.',
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                ),
                                actions: [
                                  TextButton(
                                    onPressed: () => Navigator.of(ctx).pop(),
                                    child: Text('Cancel', style: AppTextStyles.button(color: AppColors.onSurface)),
                                  ),
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                    onPressed: () {
                                      Navigator.of(ctx).pop();
                                      context.go(AppRoutes.login);
                                    },
                                    child: const Text('Delete Permanently', style: TextStyle(color: Colors.white)),
                                  ),
                                ],
                              ),
                            );
                          },
                        )
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

  Widget _buildSwitchTile(String title, bool val, {String? subtitle}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: AppTextStyles.bodyMd()),
              if (subtitle != null) Text(subtitle, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
            ],
          ),
          Switch(
            value: val,
            onChanged: (v) {},
            activeThumbColor: AppColors.circuitOrange,
          ),
        ],
      ),
    );
  }

  Widget _buildArrowTile(BuildContext context, String title) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyMd()),
      trailing: const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
      onTap: () {
        if (title.toLowerCase().contains('password')) {
          context.push(AppRoutes.resetPassword);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('$title settings configured and up to date.'),
              backgroundColor: AppColors.surfaceContainerHigh,
            ),
          );
        }
      },
    );
  }
}
