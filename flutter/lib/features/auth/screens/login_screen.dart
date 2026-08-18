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
import '../controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/repositories/sqlite_user_repository.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _obscurePassword = true;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() => _errorMessage = null);

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.isEmpty) {
      setState(() => _errorMessage = 'Please enter your password.');
      return;
    }

    final authController = context.read<AuthController>();
    final result = await authController.login(email, password);

    if (!mounted) return;

    if (result.isSuccess && result.dataOrNull != null) {
      final user = result.dataOrNull!;
      final profileController = context.read<ProfileController>();
      profileController.updateRepository(
        SqliteUserRepository(DatabaseService.instance, userId: user.id),
      );
      context.go(AppRoutes.home);
    } else {
      setState(() {
        _errorMessage = result.errorOrNull?.message ?? 'Incorrect email or password.';
      });
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
          // Background ambient gradient
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
                child: Form(
                  key: _formKey,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // App Title & Tagline
                      Text(
                        'RiderMate',
                        style: AppTextStyles.headlineLg().copyWith(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.1),
                      const SizedBox(height: AppSpacing.xs),
                      Text(
                        'KINETIC PRECISION & RIDER SAFETY',
                        style: AppTextStyles.labelCaps().copyWith(
                          color: AppColors.circuitOrange,
                          letterSpacing: 1.5,
                        ),
                      ).animate().fadeIn(delay: 200.ms, duration: 500.ms),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Access your high-performance cockpit.',
                        style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ).animate().fadeIn(delay: 300.ms, duration: 500.ms),
                      const SizedBox(height: AppSpacing.xl),

                      // Glass Login Card
                      GlassCard(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'EMAIL ADDRESS',
                                style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant),
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              RmTextField(
                                controller: _emailController,
                                hintText: 'rider@example.com',
                                prefixIcon: Icons.mail_outline,
                                keyboardType: TextInputType.emailAddress,
                                textInputAction: TextInputAction.next,
                              ),
                              const SizedBox(height: AppSpacing.md),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'PASSWORD',
                                    style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant),
                                  ),
                                  GestureDetector(
                                    onTap: () => context.push(AppRoutes.resetPassword),
                                    child: Text(
                                      'Forgot Password?',
                                      style: AppTextStyles.labelCaps().copyWith(
                                        color: AppColors.circuitOrange,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppSpacing.xs),
                              RmTextField(
                                controller: _passwordController,
                                hintText: '••••••••',
                                prefixIcon: Icons.lock_outline,
                                obscureText: _obscurePassword,
                                textInputAction: TextInputAction.done,
                                onSubmitted: (_) => _handleLogin(),
                                suffixIcon: IconButton(
                                  icon: Icon(
                                    _obscurePassword ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                    color: AppColors.onSurfaceVariant,
                                    size: 20,
                                  ),
                                  onPressed: () {
                                    setState(() {
                                      _obscurePassword = !_obscurePassword;
                                    });
                                  },
                                ),
                              ),

                              // Error Alert Message
                              if (_errorMessage != null) ...[
                                const SizedBox(height: AppSpacing.md),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                  decoration: BoxDecoration(
                                    color: Colors.red.withValues(alpha: 0.12),
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                  ),
                                  child: Row(
                                    children: [
                                      const Icon(Icons.error_outline, color: Colors.redAccent, size: 18),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          _errorMessage!,
                                          style: AppTextStyles.bodySm().copyWith(color: Colors.redAccent),
                                        ),
                                      ),
                                    ],
                                  ),
                                ).animate().fadeIn(duration: 200.ms),
                              ],

                              const SizedBox(height: AppSpacing.lg),
                              PrimaryButton(
                                text: isLoading ? 'AUTHENTICATING...' : 'ENTER COCKPIT',
                                onPressed: isLoading ? null : _handleLogin,
                                isFullWidth: true,
                              ),
                              const SizedBox(height: AppSpacing.md),

                              // Navigation to Register
                              Center(
                                child: Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      "Don't have an account? ",
                                      style: AppTextStyles.bodySm().copyWith(color: AppColors.onSurfaceVariant),
                                    ),
                                    GestureDetector(
                                      onTap: () => context.push(AppRoutes.register),
                                      child: Text(
                                        'Register Here',
                                        style: AppTextStyles.bodySm().copyWith(
                                          color: AppColors.circuitOrange,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
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
          ),
        ],
      ),
    );
  }
}
