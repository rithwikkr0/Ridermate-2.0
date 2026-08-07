import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';

class SafetySettingsScreen extends StatefulWidget {
  const SafetySettingsScreen({super.key});
  @override
  State<SafetySettingsScreen> createState() => _SafetySettingsScreenState();
}

class _SafetySettingsScreenState extends State<SafetySettingsScreen> {
  bool _crashDetection = true;
  bool _autoSos = true;
  bool _locationSharing = true;
  bool _speedAlerts = false;
  bool _nightMode = true;
  double _sensitivity = 0.6;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(-0.5, -0.3), radius: 1.0,
              colors: [Color(0x0DFF6B00), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text('Safety Settings', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(),
            const SizedBox(height: AppSpacing.lg),
            Text('Detection & Response', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(padding: EdgeInsets.zero, child: Column(children: [
              _ToggleTile('Crash Detection', 'Detects sudden impacts', Icons.car_crash_rounded,
                _crashDetection, (v) => setState(() => _crashDetection = v)),
              _divider(),
              _ToggleTile('Auto-SOS Activation', '5 second countdown after crash', Icons.sos_rounded,
                _autoSos, (v) => setState(() => _autoSos = v)),
              _divider(),
              _ToggleTile('Location Sharing', 'Share with contacts on SOS', Icons.location_on_rounded,
                _locationSharing, (v) => setState(() => _locationSharing = v)),
            ])).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: AppSpacing.md),
            Text('Alerts', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(padding: EdgeInsets.zero, child: Column(children: [
              _ToggleTile('Speed Alerts', 'Alert when over city speed limit', Icons.speed_rounded,
                _speedAlerts, (v) => setState(() => _speedAlerts = v)),
              _divider(),
              _ToggleTile('Night Mode Safety', 'Extra vigilance after sunset', Icons.nights_stay_rounded,
                _nightMode, (v) => setState(() => _nightMode = v)),
            ])).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),
            Text('Crash Detection Sensitivity', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(padding: const EdgeInsets.all(AppSpacing.md), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('Sensitivity', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                Text('${(_sensitivity * 100).round()}%', style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
              ]),
              const SizedBox(height: AppSpacing.sm),
              SliderTheme(
                data: SliderThemeData(
                  activeTrackColor: AppColors.circuitOrange,
                  inactiveTrackColor: AppColors.surfaceContainerHigh,
                  thumbColor: AppColors.circuitOrange,
                  overlayColor: AppColors.circuitOrange.withValues(alpha: 0.2)),
                child: Slider(value: _sensitivity, onChanged: (v) => setState(() => _sensitivity = v))),
              Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                Text('LOW', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                Text('HIGH', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
              ]),
            ])).animate().fadeIn(delay: 300.ms),
          ]),
        )),
      ]),
    );
  }

  Widget _divider() => const Divider(height: 1, color: Color(0x1AFFFFFF));
}

class _ToggleTile extends StatelessWidget {
  const _ToggleTile(this.title, this.subtitle, this.icon, this.value, this.onChanged);
  final String title, subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
    child: Row(children: [
      Container(width: 40, height: 40,
        decoration: BoxDecoration(color: AppColors.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(10)),
        child: Icon(icon, color: AppColors.circuitOrange, size: 18)),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
        Text(subtitle, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
      ])),
      Switch(value: value, onChanged: onChanged, activeThumbColor: AppColors.circuitOrange),
    ]),
  );
}
