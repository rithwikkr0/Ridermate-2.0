import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import 'package:go_router/go_router.dart';

class SafetyCenterScreen extends StatefulWidget {
  const SafetyCenterScreen({super.key});
  @override
  State<SafetyCenterScreen> createState() => _SafetyCenterScreenState();
}

class _SafetyCenterScreenState extends State<SafetyCenterScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _crashDetection = true;
  bool _autoSos = true;
  bool _locationSharing = true;
  bool _speedAlerts = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(children: [
        Container(decoration: const BoxDecoration(
          gradient: RadialGradient(center: Alignment(0.0, -0.3), radius: 1.2,
              colors: [Color(0x1AFF0000), Colors.transparent]))),
        SafeArea(child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 100),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              GestureDetector(onTap: () => context.pop(),
                child: const Icon(Icons.arrow_back_ios_new_rounded, color: AppColors.onSurface, size: 20)),
              const SizedBox(width: AppSpacing.sm),
              Text('Safety Center', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            ]).animate().fadeIn(),
            const SizedBox(height: AppSpacing.xl),
            // SOS Button
            Center(child: GestureDetector(
              onTap: () => context.push(AppRoutes.sos),
              child: AnimatedBuilder(
                animation: _pulseController,
                builder: (ctx, child) {
                  final scale = 1.0 + _pulseController.value * 0.06;
                  return Transform.scale(scale: scale, child: child);
                },
                child: Container(width: 140, height: 140,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: const RadialGradient(colors: [Color(0xFFFF3333), Color(0xFFCC0000)]),
                    boxShadow: [BoxShadow(color: const Color(0xFFFF0000).withValues(alpha: 0.5),
                      blurRadius: 40, spreadRadius: 10)]),
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Icon(Icons.sos_rounded, color: Colors.white, size: 44),
                    const SizedBox(height: 4),
                    Text('SOS', style: AppTextStyles.headlineSm(color: Colors.white)),
                  ])),
              ))).animate().fadeIn(delay: 100.ms),
            const SizedBox(height: 8),
            Center(child: Text('Hold for 3 seconds to activate',
              style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant))),
            const SizedBox(height: AppSpacing.xl),
            // Safety Features
            Text('Safety Features', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(padding: EdgeInsets.zero, child: Column(children: [
              _ToggleTile('Crash Detection', 'Automatically detects crashes',
                Icons.car_crash_rounded, _crashDetection, (v) => setState(() => _crashDetection = v)),
              _divider(),
              _ToggleTile('Auto-SOS', 'Activates SOS after crash detection',
                Icons.sos_rounded, _autoSos, (v) => setState(() => _autoSos = v)),
              _divider(),
              _ToggleTile('Location Sharing', 'Share location with contacts',
                Icons.location_on_rounded, _locationSharing, (v) => setState(() => _locationSharing = v)),
              _divider(),
              _ToggleTile('Speed Alerts', 'Alert at city speed limit (60 km/h)',
                Icons.speed_rounded, _speedAlerts, (v) => setState(() => _speedAlerts = v)),
            ])).animate().fadeIn(delay: 200.ms),
            const SizedBox(height: AppSpacing.lg),
            // Emergency Contacts
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Emergency Contacts', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
              GestureDetector(onTap: () => context.push(AppRoutes.emergencyContacts),
                child: Text('View All', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange))),
            ]),
            const SizedBox(height: AppSpacing.sm),
            GlassCard(padding: EdgeInsets.zero, child: Column(children: [
              _ContactTile('Ramesh Rider', 'Father', '+91 98765 43210'),
              _divider(),
              _ContactTile('Meera Rider', 'Mother', '+91 98765 43211'),
              _divider(),
              _ContactTile('Amit Kumar', 'Friend', '+91 98765 43212'),
            ])).animate().fadeIn(delay: 300.ms),
            const SizedBox(height: AppSpacing.lg),
            Row(children: [
              Expanded(child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.push(AppRoutes.safetyHistory),
                child: Column(children: [
                  const Icon(Icons.history_rounded, color: AppColors.circuitOrange, size: 28),
                  const SizedBox(height: 8),
                  Text('Safety History', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                ]))),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: GlassCard(padding: const EdgeInsets.all(AppSpacing.md),
                onTap: () => context.push(AppRoutes.safetySettings),
                child: Column(children: [
                  const Icon(Icons.settings_rounded, color: AppColors.onSurface, size: 28),
                  const SizedBox(height: 8),
                  Text('Safety Settings', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                ]))),
            ]).animate().fadeIn(delay: 400.ms),
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

class _ContactTile extends StatelessWidget {
  const _ContactTile(this.name, this.relation, this.phone);
  final String name, relation, phone;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm + 2),
    child: Row(children: [
      CircleAvatar(radius: 20, backgroundColor: AppColors.surfaceContainerHigh,
        child: Text(name[0], style: AppTextStyles.statLabel(color: AppColors.circuitOrange))),
      const SizedBox(width: AppSpacing.md),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(name, style: AppTextStyles.statLabel(color: AppColors.onSurface)),
        Text('$relation · $phone', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
      ])),
      Container(width: 36, height: 36,
        decoration: const BoxDecoration(color: Color(0x1A4CAF50), shape: BoxShape.circle),
        child: const Icon(Icons.phone_rounded, color: Color(0xFF4CAF50), size: 18)),
    ]),
  );
}
