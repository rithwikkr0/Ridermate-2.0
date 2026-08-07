import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';
import '../../../core/router/app_router.dart';

class RegisterScreen extends StatelessWidget {
  const RegisterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1571210862729-78a52d3779a2?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.2,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.9),
                  Colors.transparent,
                ],
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
                    Text(
                      'Join RiderMate',
                      style: AppTextStyles.headlineLg().copyWith(color: Colors.white),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Create your high-performance account.',
                      style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.xl),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FULL NAME', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              hintText: 'John Doe',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('EMAIL ADDRESS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('CONFIRM PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              text: 'CREATE ACCOUNT',
                              onPressed: () => context.go(AppRoutes.otp),
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.lg),
                    GestureDetector(
                      onTap: () => context.go(AppRoutes.terms),
                      child: Text(
                        'By registering, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.xl),
                    GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already a pilot? ',
                          style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: AppTextStyles.bodyMd().copyWith(color: Colors.white, fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
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
