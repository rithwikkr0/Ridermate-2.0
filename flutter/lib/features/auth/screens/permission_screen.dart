import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/router/app_router.dart';

class PermissionScreen extends StatelessWidget {
  const PermissionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                color: AppColors.circuitOrange.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .blur(begin: const Offset(100, 100))
             .scale(begin: const Offset(0.9, 0.9), end: const Offset(1.1, 1.1), duration: 2000.ms),
          ),
          SafeArea(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      width: 144,
                      height: 144,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.surfaceContainer.withValues(alpha: 0.4),
                        border: Border.all(color: Colors.white.withValues(alpha: 0.1)),
                        boxShadow: const [
                          BoxShadow(color: Color(0x33FF6B00), blurRadius: 32, offset: Offset(0, 12)),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(72),
                        child: BackdropFilter(
                          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
                          child: const Center(
                            child: Icon(
                              Icons.gpp_maybe,
                              size: 72,
                              color: AppColors.circuitOrange,
                            ),
                          ),
                        ),
                      ),
                    ).animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.easeOutBack),
                    const SizedBox(height: AppSpacing.xl),
                    Text(
                      'Location Access Required',
                      style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'To provide real-time crash detection and SOS tracking, RiderMate needs background location access set to "Always Allow".',
                      style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.xl * 2),
                    PrimaryButton(
                      text: 'OPEN SYSTEM SETTINGS',
                      onPressed: () => context.go(AppRoutes.home),
                      isFullWidth: true,
                    ).animate().fadeIn(delay: 400.ms),
                    const SizedBox(height: AppSpacing.md),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                          ),
                          backgroundColor: Colors.white.withValues(alpha: 0.05),
                        ),
                        onPressed: () {
                          showDialog<void>(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              backgroundColor: AppColors.surfaceContainerHigh,
                              title: Text('Why RiderMate Needs Permissions', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                              content: Text(
                                '• Location: For real-time GPS telemetry, speed tracking, and crash location broadcasting.\n\n'
                                '• Notifications: For immediate emergency SOS alerts and ride milestones.\n\n'
                                '• Activity & Sensors: For high-g crash impact detection heuristics.\n\n'
                                '• Camera / Storage: For vehicle document photos and ride memory gallery.',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.of(ctx).pop(),
                                  child: Text('Understood', style: AppTextStyles.button(color: AppColors.circuitOrange)),
                                ),
                              ],
                            ),
                          );
                        },
                        child: Text(
                          'LEARN MORE',
                          style: AppTextStyles.statLabel().copyWith(color: AppColors.onSurface),
                        ),
                      ),
                    ).animate().fadeIn(delay: 500.ms),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
