import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';

class TermsScreen extends StatelessWidget {
  const TermsScreen({super.key});

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
        title: Text('Terms of Service', style: AppTextStyles.headlineMd()),
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
                      Text('1. Agreement to Terms', style: AppTextStyles.headlineMd()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'By accessing our application, you agree to be bound by these terms of service and agree that you are responsible for compliance with any applicable local laws.',
                        style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                      Text('2. Use License', style: AppTextStyles.headlineMd()),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Permission is granted to temporarily download one copy of the materials (information or software) on RiderMate\'s application for personal, non-commercial transitory viewing only.',
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
