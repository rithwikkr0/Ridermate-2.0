import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';

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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty) {
      setState(() => _errorMessage = 'Please enter your full name.');
      return;
    }
    if (email.isEmpty) {
      setState(() => _errorMessage = 'Please enter your email address.');
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() => _errorMessage = 'Please enter a valid email address.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }

    final authController = context.read<AuthController>();
    final result = await authController.register(
      name,
      email,
      password,
      phone: phone,
    );

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
        _errorMessage = result.errorOrNull?.message ?? 'Registration failed. Please try again.';
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
                      style: AppTextStyles.headlineLg().copyWith(
                        color: Colors.white,
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Create your high-performance riding profile.',
                      style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                    ).animate().fadeIn(delay: 200.ms),
                    const SizedBox(height: AppSpacing.lg),

                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.lg),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('FULL NAME', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _nameController,
                              hintText: 'John Rider',
                              prefixIcon: Icons.person_outline,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            Text('EMAIL ADDRESS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _emailController,
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            Text('PHONE NUMBER (OPTIONAL)', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _phoneController,
                              hintText: '+91 98765 43210',
                              prefixIcon: Icons.phone_outlined,
                              keyboardType: TextInputType.phone,
                              textInputAction: TextInputAction.next,
                            ),
                            const SizedBox(height: AppSpacing.sm),

                            Text('PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _passwordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscurePassword,
                              textInputAction: TextInputAction.next,
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
                            const SizedBox(height: AppSpacing.sm),

                            Text('CONFIRM PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _confirmController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: _obscureConfirm,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleRegister(),
                              suffixIcon: IconButton(
                                icon: Icon(
                                  _obscureConfirm ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                                  color: AppColors.onSurfaceVariant,
                                  size: 20,
                                ),
                                onPressed: () {
                                  setState(() {
                                    _obscureConfirm = !_obscureConfirm;
                                  });
                                },
                              ),
                            ),

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
                              text: isLoading ? 'CREATING ACCOUNT...' : 'CREATE ACCOUNT',
                              onPressed: isLoading ? null : _handleRegister,
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 300.ms, duration: 500.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.md),

                    GestureDetector(
                      onTap: () => context.push(AppRoutes.terms),
                      child: Text(
                        'By registering, you agree to our Terms & Privacy Policy.',
                        textAlign: TextAlign.center,
                        style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                      ),
                    ),
                    const SizedBox(height: AppSpacing.lg),

                    GestureDetector(
                      onTap: () => context.pop(),
                      child: RichText(
                        text: TextSpan(
                          text: 'Already a pilot? ',
                          style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.7)),
                          children: [
                            TextSpan(
                              text: 'Sign In',
                              style: AppTextStyles.bodyMd().copyWith(color: AppColors.circuitOrange, fontWeight: FontWeight.bold),
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
