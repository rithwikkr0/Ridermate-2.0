import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text('Privacy Policy', style: AppTextStyles.headlineMd()),
      ),
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: GlassCard(
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.lg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('1. Data Collection', style: AppTextStyles.headlineMd()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'We collect information to provide better services to all our users. This includes location data for tracking rides, device info, and user account details.',
                        style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('2. Data Usage', style: AppTextStyles.headlineMd()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Your data is used to improve our crash detection models, offer personalized AI coaching, and facilitate group rides.',
                        style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: 100),
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
