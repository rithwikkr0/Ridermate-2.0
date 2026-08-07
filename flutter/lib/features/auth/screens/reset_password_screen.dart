import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';


class ResetPasswordScreen extends StatelessWidget {
  const ResetPasswordScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
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
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.lock_reset, size: 48, color: AppColors.circuitOrange)
                        .animate().scale(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: AppSpacing.lg),
                    Text(
                      'Reset Password',
                      style: AppTextStyles.headlineLg().copyWith(color: Colors.white),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Enter your email to receive a reset link.',
                      style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMAIL ADDRESS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              text: 'SEND RESET LINK',
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Reset link sent!')),
                                );
                                context.pop();
                              },
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
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
