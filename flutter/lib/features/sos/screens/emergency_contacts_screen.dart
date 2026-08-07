import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class EmergencyContactsScreen extends StatelessWidget {
  const EmergencyContactsScreen({super.key});

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
                      Text('Emergency Contacts', style: AppTextStyles.headlineMd()),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  ...[
                    _buildContactCard('Ramesh Rider', 'Father', '+91 98765 43210'),
                    const SizedBox(height: AppSpacing.md),
                    _buildContactCard('Meera Rider', 'Mother', '+91 98765 43211'),
                    const SizedBox(height: AppSpacing.md),
                    _buildContactCard('Amit Kumar', 'Friend', '+91 98765 43212'),
                  ].animate(interval: 100.ms).fadeIn(duration: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: AppColors.circuitOrange,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildContactCard(String name, String relation, String phone) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: AppColors.surfaceContainerHigh,
              child: Text(name[0], style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(name, style: AppTextStyles.headlineSm()),
                  const SizedBox(height: 4),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.circuitOrange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.5)),
                    ),
                    child: Text(relation, style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
                  ),
                  const SizedBox(height: 4),
                  Text(phone, style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.phone, color: Colors.greenAccent, size: 28),
              onPressed: () {},
            ),
          ],
        ),
      ),
    );
  }
}
