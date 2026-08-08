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
import '../../../providers/base_controller.dart';
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
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();
  String? _errorMessage;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty) {
      setState(() => _errorMessage = 'All fields are required.');
      return;
    }
    if (password != confirm) {
      setState(() => _errorMessage = 'Passwords do not match.');
      return;
    }
    if (password.length < 6) {
      setState(() => _errorMessage = 'Password must be at least 6 characters.');
      return;
    }

    final authController = context.read<AuthController>();
    await authController.register(name, email, password);

    if (!mounted) return;
    if (authController.state == ViewState.success) {
      // Wire the ProfileController to the real user repository
      final userId = authController.currentUser!.id;
      context.read<ProfileController>().updateRepository(
        SqliteUserRepository(DatabaseService.instance, userId: userId),
      );
      context.go(AppRoutes.home);
    } else {
      setState(() {
        _errorMessage = authController.stateModel.error?.message ?? 'Registration failed.';
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
                              controller: _nameController,
                              hintText: 'Your full name',
                              prefixIcon: Icons.person_outline,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('EMAIL ADDRESS', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              controller: _emailController,
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              controller: _passwordController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            const SizedBox(height: AppSpacing.md),
                            Text('CONFIRM PASSWORD', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.sm),
                            RmTextField(
                              controller: _confirmController,
                              hintText: '••••••••',
                              prefixIcon: Icons.lock_outline,
                              obscureText: true,
                            ),
                            if (_errorMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.all(AppSpacing.sm),
                                decoration: BoxDecoration(
                                  color: Colors.red.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.red.withValues(alpha: 0.3)),
                                ),
                                child: Text(
                                  _errorMessage!,
                                  style: AppTextStyles.bodyMd().copyWith(color: Colors.red),
                                  textAlign: TextAlign.center,
                                ),
                              ),
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
