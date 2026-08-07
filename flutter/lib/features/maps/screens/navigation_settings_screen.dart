import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class NavigationSettingsScreen extends StatefulWidget {
  const NavigationSettingsScreen({super.key});

  @override
  State<NavigationSettingsScreen> createState() => _NavigationSettingsScreenState();
}

class _NavigationSettingsScreenState extends State<NavigationSettingsScreen> {
  bool voiceGuidance = true;
  bool autoReroute = true;
  bool offlineMaps = false;
  bool speedAlerts = true;

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
        title: Text('Navigation Settings', style: AppTextStyles.headlineMd()),
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
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    child: Column(
                      children: [
                        _buildSwitchTile('Voice Guidance', voiceGuidance, (v) => setState(() => voiceGuidance = v)),
                        const Divider(color: Colors.white10, height: 1),
                        _buildSwitchTile('Auto-reroute', autoReroute, (v) => setState(() => autoReroute = v)),
                        const Divider(color: Colors.white10, height: 1),
                        _buildSwitchTile('Offline Maps', offlineMaps, (v) => setState(() => offlineMaps = v)),
                        const Divider(color: Colors.white10, height: 1),
                        _buildSwitchTile('Speed Alerts', speedAlerts, (v) => setState(() => speedAlerts = v)),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  
                  const SizedBox(height: AppSpacing.xl),
                  Text('PREFERENCES', style: AppTextStyles.labelCaps()).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.md),
                  
                  GlassCard(
                    child: Column(
                      children: [
                        _buildListTile('Map Style', 'Dark Mode'),
                        const Divider(color: Colors.white10, height: 1),
                        _buildListTile('Voice Language', 'English (US)'),
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSwitchTile(String title, bool value, Function(bool) onChanged) {
    return SwitchListTile(
      title: Text(title, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppColors.circuitOrange,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
    );
  }

  Widget _buildListTile(String title, String trailingText) {
    return ListTile(
      title: Text(title, style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurface)),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(trailingText, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant)),
          const SizedBox(width: AppSpacing.sm),
          const Icon(Icons.chevron_right, color: AppColors.onSurfaceVariant),
        ],
      ),
    );
  }
}
