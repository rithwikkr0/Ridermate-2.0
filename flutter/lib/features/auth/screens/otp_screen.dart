import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/router/app_router.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());

  @override
  void dispose() {
    for (var c in _controllers) { c.dispose(); }
    for (var f in _focusNodes) { f.dispose(); }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.topRight,
                radius: 1.5,
                colors: [Color(0x26FF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.electric_bolt, size: 48, color: AppColors.circuitOrange)
                        .animate().scale(delay: 200.ms, duration: 500.ms, curve: Curves.elasticOut),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Verification',
                      style: AppTextStyles.headlineLg().copyWith(color: AppColors.onBackground),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'We\'ve sent a 6-digit code to your device.',
                      style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: List.generate(6, (index) {
                                return SizedBox(
                                  width: 44,
                                  height: 56,
                                  child: TextField(
                                    controller: _controllers[index],
                                    focusNode: _focusNodes[index],
                                    textAlign: TextAlign.center,
                                    keyboardType: TextInputType.number,
                                    maxLength: 1,
                                    style: AppTextStyles.displayStat().copyWith(fontSize: 24, color: AppColors.onSurface),
                                    decoration: InputDecoration(
                                      counterText: '',
                                      filled: true,
                                      fillColor: AppColors.surfaceVariant.withValues(alpha: 0.5),
                                      enabledBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: BorderSide(color: Colors.white.withValues(alpha: 0.1)),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(8),
                                        borderSide: const BorderSide(color: AppColors.circuitOrange),
                                      ),
                                    ),
                                    onChanged: (val) => _onChanged(val, index),
                                  ),
                                );
                              }),
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const Icon(Icons.timer_outlined, size: 16, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text('00:59', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              text: 'Verify',
                              onPressed: () => context.go(AppRoutes.home),
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.xl),
                    TextButton(
                      onPressed: () => context.pop(),
                      child: Text(
                        'CHANGE PHONE NUMBER',
                        style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant),
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
}
