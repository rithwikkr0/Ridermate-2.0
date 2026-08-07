import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideHudScreen extends StatelessWidget {
  const RideHudScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black, // Dark mode specifically for HUD
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.marginMobile),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Top bar
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.close, color: AppColors.onSurfaceVariant, size: 32),
                    onPressed: () => context.pop(),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.circuitOrange.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text('Performance Mode', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                  ),
                  const SizedBox(width: 48), // Balance for close button
                ],
              ),
              
              // Center Stats
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('42.5', style: const TextStyle(
                    fontFamily: 'Hanken Grotesk',
                    fontSize: 120,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.0,
                  )).animate().fadeIn(duration: 500.ms).scale(begin: const Offset(0.8, 0.8)),
                  Text('KM/H', style: AppTextStyles.headlineMd(color: AppColors.circuitOrange)),
                ],
              ),
              
              // Bottom Stats Row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildBottomStat('DISTANCE', '12.4', 'KM'),
                  Container(width: 1, height: 60, color: AppColors.glassBorder),
                  _buildBottomStat('DURATION', '28:45', ''),
                  Container(width: 1, height: 60, color: AppColors.glassBorder),
                  _buildBottomStat('POWER', '240', 'W'),
                ],
              ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBottomStat(String label, String value, String unit) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 8),
        Row(
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(value, style: AppTextStyles.headlineLg(color: Colors.white)),
            if (unit.isNotEmpty) ...[
              const SizedBox(width: 4),
              Text(unit, style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
            ]
          ],
        ),
      ],
    );
  }
}
