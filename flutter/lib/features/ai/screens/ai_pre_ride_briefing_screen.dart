import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';

class AiPreRideBriefingScreen extends StatelessWidget {
  const AiPreRideBriefingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Pre-Ride Brief', style: AppTextStyles.headlineMd()),
        centerTitle: true,
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
                  Text('Everything looks optimal for your ride today. You have a slight tailwind heading out.', style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurfaceVariant))
                      .animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),
                  
                  Text('CHECKLIST', style: AppTextStyles.labelCaps()),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildChecklistCard(
                    icon: Icons.wb_sunny_outlined,
                    title: 'Weather',
                    subtitle: '24°C • Tailwind 12km/h',
                    statusIcon: Icons.check_circle,
                    statusColor: AppColors.circuitOrange,
                  ).animate().fadeIn(delay: 100.ms).slideX(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildChecklistCard(
                    icon: Icons.health_and_safety_outlined,
                    title: 'Recovery',
                    subtitle: '92% Readiness',
                    statusIcon: Icons.check_circle,
                    statusColor: AppColors.circuitOrange,
                  ).animate().fadeIn(delay: 200.ms).slideX(begin: 0.1),
                  const SizedBox(height: AppSpacing.md),
                  
                  _buildChecklistCard(
                    icon: Icons.map_outlined,
                    title: 'Route',
                    subtitle: 'Coastal Loop Recommended',
                    statusIcon: Icons.check_circle,
                    statusColor: AppColors.circuitOrange,
                  ).animate().fadeIn(delay: 300.ms).slideX(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl * 2),
                  
                  PrimaryButton(label: 'Start Ride',
                    onPressed: () {},
                  ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChecklistCard({required IconData icon, required String title, required String subtitle, required IconData statusIcon, required Color statusColor}) {
    return GlassCard(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppColors.onSurface),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: AppTextStyles.labelCaps().copyWith(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: 4),
                  Text(subtitle, style: AppTextStyles.bodyMd().copyWith(color: AppColors.onSurface)),
                ],
              ),
            ),
            Icon(statusIcon, color: statusColor),
          ],
        ),
      ),
    );
  }
}
