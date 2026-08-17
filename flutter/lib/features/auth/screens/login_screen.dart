import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/database_service.dart';
import '../../../providers/base_controller.dart';
import '../controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/repositories/sqlite_user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    try {
      final email = _emailController.text.trim().isNotEmpty
          ? _emailController.text.trim()
          : 'demo@ridermate.app';
      final password = _passwordController.text.trim().isNotEmpty
          ? _passwordController.text.trim()
          : 'password123';

      final authController = context.read<AuthController>();
      final profileController = context.read<ProfileController>();
      await authController.login(email, password);
      if (authController.currentUser != null) {
        final userId = authController.currentUser!.id;
        profileController.updateRepository(
          SqliteUserRepository(DatabaseService.instance, userId: userId),
        );
      }
    } catch (_) {}
    if (mounted) {
      context.go(AppRoutes.home);
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = context.watch<AuthController>();
    final isLoading = authController.isLoading;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1571210862729-78a52d3779a2?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
                opacity: 0.3,
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
                  AppColors.background.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          const Positioned(
            top: -100,
            right: -100,
            child: CircleAvatar(
              radius: 150,
              backgroundColor: Color(0x26FF6B00),
            ),
          ).animate().blur(begin: const Offset(60, 60)),
          SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'RiderMate',
                      style: AppTextStyles.headlineLg().copyWith(color: Colors.white),
                    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      'Access your performance cockpit.',
                      style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                    ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: AppSpacing.md),
                    PrimaryButton(
                      text: 'ENTER COCKPIT',
                      onPressed: _handleLogin,
                      isFullWidth: true,
                    ),
                    const SizedBox(height: AppSpacing.md),
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('EMAIL ADDRESS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _emailController,
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                                GestureDetector(
                                  onTap: () => context.go(AppRoutes.resetPassword),
                                  child: Text('Forgot?', style: AppTextStyles.labelCaps().copyWith(color: AppColors.primary)),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _passwordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            PrimaryButton(
                              text: isLoading ? 'AUTHENTICATING...' : 'INITIALIZE LOGIN',
                              onPressed: isLoading ? null : _handleLogin,
                              isFullWidth: true,
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1))),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                                  child: Text('OR CONNECT WITH', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.5))),
                                ),
                                Expanded(child: Container(height: 1, color: Colors.white.withValues(alpha: 0.1))),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.sm),
                            Row(
                              children: [
                                Expanded(
                                  child: GestureDetector(
                                    onTap: _handleLogin,
                                    child: Container(
                                      height: 44,
                                      decoration: BoxDecoration(
                                        color: AppColors.surfaceContainerHigh,
                                        borderRadius: BorderRadius.circular(16),
                                        border: Border.all(color: AppColors.glassBorder),
                                      ),
                                      child: const Center(child: Icon(Icons.g_mobiledata, color: Colors.white, size: 28)),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Wrap(
                              alignment: WrapAlignment.center,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              children: [
                                Text("Don't have an account? ", style: AppTextStyles.bodySm().copyWith(color: AppColors.onSurfaceVariant)),
                                GestureDetector(
                                  onTap: () => context.go(AppRoutes.register),
                                  child: Text('Register', style: AppTextStyles.bodySm().copyWith(color: AppColors.primary, fontWeight: FontWeight.bold)),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.2),
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
