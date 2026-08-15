import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_text_styles.dart';
import '../../theme/app_spacing.dart';
import '../../widgets/glass_card.dart';
import '../controllers/notification_controller.dart';
import '../models/notification_preferences.dart';
import '../models/notification_type.dart';

/// RiderMate 2.0 — Notification Quiet / Category Settings Screen
class NotificationSettingsScreen extends StatelessWidget {
  const NotificationSettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = context.watch<NotificationController>();
    final prefs = controller.preferences ?? NotificationPreferences(userId: controller.currentUserId);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Notification Settings', style: AppTextStyles.headlineMd()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.marginMobile,
          AppSpacing.md,
          AppSpacing.marginMobile,
          100,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildSectionHeader('CATEGORY QUIET SETTINGS'),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: NotificationType.emergency.icon,
                    iconColor: NotificationType.emergency.color,
                    title: 'Emergency Alerts',
                    subtitle: 'SOS, crash detection, critical distress alerts (Locked ON for safety)',
                    value: true,
                    onChanged: null, // Disabled toggle - emergency cannot be turned off
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.safety.icon,
                    iconColor: NotificationType.safety.color,
                    title: 'Safety Warnings',
                    subtitle: 'Overspeed, high lean angle, hazard warnings',
                    value: prefs.safetyEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(safetyEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.ride.icon,
                    iconColor: NotificationType.ride.color,
                    title: 'Ride Telemetry',
                    subtitle: 'Ride start, auto-pause, completion & summaries',
                    value: prefs.rideEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(rideEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.social.icon,
                    iconColor: NotificationType.social.color,
                    title: 'Social & Squads',
                    subtitle: 'Friend requests, squad ride invites, group alerts',
                    value: prefs.socialEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(socialEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.ai.icon,
                    iconColor: NotificationType.ai.color,
                    title: 'AI Co-Pilot',
                    subtitle: 'Weekly insights, pre-ride briefings, coach suggestions',
                    value: prefs.aiEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(aiEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.maintenance.icon,
                    iconColor: NotificationType.maintenance.color,
                    title: 'Maintenance',
                    subtitle: 'Service due, PUC, insurance, tire pressure reminders',
                    value: prefs.maintenanceEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(maintenanceEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.achievement.icon,
                    iconColor: NotificationType.achievement.color,
                    title: 'Achievements',
                    subtitle: 'Badges unlocked, distance milestones, level ups',
                    value: prefs.achievementEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(achievementEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: NotificationType.system.icon,
                    iconColor: NotificationType.system.color,
                    title: 'System Updates',
                    subtitle: 'App updates, sync notifications, security alerts',
                    value: prefs.systemEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(systemEnabled: v)),
                  ),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            _buildSectionHeader('ALERT FEEDBACK'),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(
              child: Column(
                children: [
                  _buildToggleTile(
                    icon: Icons.volume_up_rounded,
                    iconColor: AppColors.circuitOrange,
                    title: 'Notification Sound',
                    subtitle: 'Play audio chime for notifications',
                    value: prefs.soundEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(soundEnabled: v)),
                  ),
                  const Divider(color: AppColors.glassBorder, height: 1),
                  _buildToggleTile(
                    icon: Icons.vibration_rounded,
                    iconColor: AppColors.circuitOrange,
                    title: 'Vibration',
                    subtitle: 'Vibrate device on alert delivery',
                    value: prefs.vibrationEnabled,
                    onChanged: (v) => controller.updatePreferences(prefs.copyWith(vibrationEnabled: v)),
                  ),
                ],
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

  Widget _buildToggleTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool>? onChanged,
  }) {
    return SwitchListTile(
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.circuitOrange,
      activeTrackColor: AppColors.circuitOrange.withValues(alpha: 0.4),
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(title, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
      subtitle: Text(subtitle, style: AppTextStyles.caption(color: AppColors.onSurfaceVariant)),
    );
  }
}
