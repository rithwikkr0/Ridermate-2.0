import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_text_field.dart';
import 'package:go_router/go_router.dart';

class HelpSupportScreen extends StatelessWidget {
  const HelpSupportScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
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
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Help & Support', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  RmTextField(
                    label: 'Search FAQ',
                    onChanged: (v) {},
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  GlassCard(
                    child: Column(
                      children: [
                        _buildFaq('How do I start a ride?'),
                        _buildFaq('How does crash detection work?'),
                        _buildFaq('Can I use RiderMate offline?'),
                        _buildFaq('How do I connect with friends?'),
                        _buildFaq('How do I export ride data?'),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),
                  SizedBox(
                    width: double.infinity,
                    height: 56,
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppColors.circuitOrange),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: () {},
                      child: Text('Contact Support', style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(icon: const Icon(Icons.language, color: AppColors.onSurfaceVariant), onPressed: () {}),
                      IconButton(icon: const Icon(Icons.mail, color: AppColors.onSurfaceVariant), onPressed: () {}),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  Center(
                    child: Text('RiderMate 2.0.0 (build 1)', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFaq(String question) {
    return Theme(
      data: ThemeData(dividerColor: Colors.transparent),
      child: ExpansionTile(
        title: Text(question, style: AppTextStyles.bodyMd()),
        iconColor: AppColors.circuitOrange,
        collapsedIconColor: AppColors.onSurfaceVariant,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              'Detailed explanation for "$question" goes here. This is a placeholder for the actual FAQ content.',
              style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
            ),
          )
        ],
      ),
    );
  }
}
