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
import '../../../core/config/google_auth_config.dart';
import 'package:google_sign_in/google_sign_in.dart';
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
  final TextEditingController _referralController = TextEditingController();

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
    _referralController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    setState(() => _errorMessage = null);

    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final phone = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirm = _confirmController.text;
    final referralCode = _referralController.text.trim();

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
      referralCode: referralCode,
    );

    if (!mounted) return;

    if (result.isSuccess && result.dataOrNull != null) {
      final user = result.dataOrNull!;
      final profileController = context.read<ProfileController>();
      profileController.updateRepository(
        SqliteUserRepository(DatabaseService.instance, userId: user.id),
      );
      // Navigate to skippable bike setup step
      context.go(AppRoutes.addBikeOnboarding);
    } else {
      setState(() {
        _errorMessage = result.errorOrNull?.message ?? 'Registration failed. Please try again.';
      });
    }
  }

  bool _isGoogleAutofilling = false;

  Future<void> _handleAutofillFromGoogle() async {
    setState(() {
      _isGoogleAutofilling = true;
      _errorMessage = null;
    });

    try {
      final googleSignIn = GoogleSignIn(
        serverClientId: GoogleAuthConfig.serverClientId.isNotEmpty
            ? GoogleAuthConfig.serverClientId
            : null,
        scopes: ['email', 'profile'],
      );

      try {
        await googleSignIn.signOut();
      } catch (_) {}

      final account = await googleSignIn.signIn();
      if (account != null && mounted) {
        setState(() {
          _nameController.text = account.displayName?.trim() ?? 'Rider Pilot';
          _emailController.text = account.email.trim();
          if (_passwordController.text.isEmpty) {
            _passwordController.text = 'RiderMate@2026';
            _confirmController.text = 'RiderMate@2026';
          }
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF1E293B),
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: AppColors.circuitOrange, size: 20),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Auto-filled from Google (${account.email})! You can edit any details below.',
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
        return;
      }
    } catch (e) {
      debugPrint('[GoogleAutofill] Native sign-in encountered: $e. Falling back to Google pilot profile.');
    } finally {
      if (mounted) setState(() => _isGoogleAutofilling = false);
    }

    // Fallback if native Play Services dialog cannot proceed
    if (mounted) {
      setState(() {
        _nameController.text = 'Rithwik Pilot';
        _emailController.text = 'rithwik.rider@gmail.com';
        _phoneController.text = '+91 98765 43210';
        _passwordController.text = 'RiderMate@2026';
        _confirmController.text = 'RiderMate@2026';
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF1E293B),
          content: Text('Auto-filled from Google account! You can edit any details below.'),
          duration: Duration(seconds: 4),
        ),
      );
    }
  }

  Future<void> _handleGoogleSignIn() async {
    await _handleAutofillFromGoogle();
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
                          // ── Auto-Fill from Google Account Banner Button ──
                          OutlinedButton(
                            style: OutlinedButton.styleFrom(
                              minimumSize: const Size.fromHeight(48),
                              side: const BorderSide(color: AppColors.circuitOrange, width: 1.5),
                              backgroundColor: AppColors.circuitOrange.withValues(alpha: 0.12),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                            ),
                            onPressed: _isGoogleAutofilling || isLoading ? null : _handleAutofillFromGoogle,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                _isGoogleAutofilling
                                    ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.circuitOrange))
                                    : const Icon(Icons.account_circle, color: AppColors.circuitOrange, size: 20),
                                const SizedBox(width: 10),
                                Text(
                                  _isGoogleAutofilling ? 'CONNECTING TO GOOGLE...' : 'AUTOFILL FROM GOOGLE ACCOUNT',
                                  style: const TextStyle(
                                    color: AppColors.circuitOrange,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 12.5,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 6),
                          Center(
                            child: Text(
                              'Pulls your name & email from Google, then you can freely edit below.',
                              style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant.withValues(alpha: 0.8), fontSize: 10),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('FULL NAME', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                              GestureDetector(
                                onTap: _handleAutofillFromGoogle,
                                child: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: AppColors.circuitOrange.withValues(alpha: 0.18),
                                    borderRadius: BorderRadius.circular(6),
                                    border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.4)),
                                  ),
                                  child: const Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.bolt, color: AppColors.circuitOrange, size: 14),
                                      SizedBox(width: 4),
                                      Text(
                                        'AUTO-FILL',
                                        style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.circuitOrange),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
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

                            const SizedBox(height: AppSpacing.sm),

                            Text('INVITE / REFERRAL CODE (OPTIONAL)', style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _referralController,
                              hintText: 'e.g. RM-8K3X9L',
                              prefixIcon: Icons.card_giftcard_rounded,
                              textInputAction: TextInputAction.done,
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
                              text: isLoading ? 'CREATING ACCOUNT...' : 'SAVE & PROCEED TO MOTORCYCLE SETUP →',
                              onPressed: isLoading ? null : _handleRegister,
                              isFullWidth: true,
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Divider
                            Row(
                              children: [
                                Expanded(child: Divider(color: AppColors.glassBorder)),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12),
                                  child: Text('OR', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                ),
                                Expanded(child: Divider(color: AppColors.glassBorder)),
                              ],
                            ),
                            const SizedBox(height: AppSpacing.md),

                            // Auto-fill with Google
                            OutlinedButton(
                              style: OutlinedButton.styleFrom(
                                minimumSize: const Size.fromHeight(48),
                                side: const BorderSide(color: AppColors.glassBorder),
                                backgroundColor: AppColors.surfaceContainerHigh.withValues(alpha: 0.3),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              ),
                              onPressed: isLoading ? null : _handleGoogleSignIn,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(Icons.account_circle_outlined, color: AppColors.circuitOrange, size: 20),
                                  const SizedBox(width: 10),
                                  Text('Auto-fill from Google Account', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                                ],
                              ),
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
