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
import '../controllers/auth_controller.dart';

class ResetPasswordScreen extends StatefulWidget {
  const ResetPasswordScreen({super.key});

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  String? _statusMessage;
  bool _isSuccess = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  Future<void> _handleReset() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() {
        _statusMessage = 'Please enter your registered email address.';
        _isSuccess = false;
      });
      return;
    }
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      setState(() {
        _statusMessage = 'Please enter a valid email address.';
        _isSuccess = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _statusMessage = null;
    });

    final authController = context.read<AuthController>();
    final result = await authController.sendPasswordReset(email);

    if (!mounted) return;

    setState(() {
      _isLoading = false;
      if (result.isSuccess) {
        _isSuccess = true;
        _statusMessage = 'Password reset instructions have been dispatched to $email.';
      } else {
        _isSuccess = false;
        _statusMessage = result.errorOrNull?.message ?? 'Account not found with this email.';
      }
    });
  }

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
                    const Icon(Icons.lock_reset_rounded, size: 56, color: AppColors.circuitOrange)
                        .animate().scale(delay: 200.ms, duration: 500.ms),
                    const SizedBox(height: AppSpacing.md),
                    Text(
                      'Reset Password',
                      style: AppTextStyles.headlineLg().copyWith(color: Colors.white, fontSize: 26),
                    ).animate().fadeIn().slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      'Enter your registered email address to recover your account credentials.',
                      textAlign: TextAlign.center,
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
                            const SizedBox(height: AppSpacing.xs),
                            RmTextField(
                              controller: _emailController,
                              hintText: 'rider@example.com',
                              prefixIcon: Icons.mail_outline,
                              keyboardType: TextInputType.emailAddress,
                              textInputAction: TextInputAction.done,
                              onSubmitted: (_) => _handleReset(),
                            ),

                            if (_statusMessage != null) ...[
                              const SizedBox(height: AppSpacing.md),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                                decoration: BoxDecoration(
                                  color: (_isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.12),
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: (_isSuccess ? Colors.green : Colors.red).withValues(alpha: 0.3)),
                                ),
                                child: Row(
                                  children: [
                                    Icon(
                                      _isSuccess ? Icons.check_circle_outline : Icons.error_outline,
                                      color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                                      size: 18,
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        _statusMessage!,
                                        style: AppTextStyles.bodySm().copyWith(
                                          color: _isSuccess ? Colors.greenAccent : Colors.redAccent,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ).animate().fadeIn(duration: 200.ms),
                            ],

                            const SizedBox(height: AppSpacing.lg),
                            PrimaryButton(
                              text: _isLoading ? 'SENDING INSTRUCTIONS...' : 'SEND RECOVERY LINK',
                              onPressed: _isLoading ? null : _handleReset,
                              isFullWidth: true,
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                    const SizedBox(height: AppSpacing.lg),
                    TextButton.icon(
                      icon: const Icon(Icons.arrow_back, color: AppColors.circuitOrange, size: 16),
                      label: Text(
                        'Back to Login',
                        style: AppTextStyles.bodyMd().copyWith(color: AppColors.circuitOrange, fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => context.pop(),
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
