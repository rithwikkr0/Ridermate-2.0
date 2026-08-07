import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';

class AiListeningScreen extends StatelessWidget {
  const AiListeningScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0, 0),
                radius: 1.5,
                colors: [Color(0x1AFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      _buildPulseRing(240, 0),
                      _buildPulseRing(180, 400),
                      _buildPulseRing(120, 800),
                      Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.circuitOrange,
                          boxShadow: [
                            BoxShadow(color: AppColors.circuitOrange.withValues(alpha: 0.5), blurRadius: 30, spreadRadius: 5),
                          ],
                        ),
                        child: const Icon(Icons.mic, color: Colors.white, size: 40),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xl * 2),
                  Text('Listening...', style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface))
                      .animate(onPlay: (controller) => controller.repeat(reverse: true))
                      .fade(begin: 0.5, end: 1.0, duration: 1.seconds),
                  const SizedBox(height: AppSpacing.lg),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: 8,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.circuitOrange,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ).animate(onPlay: (controller) => controller.repeat(reverse: true))
                       .scaleY(begin: 0.3, end: 1.5, duration: (300 + index * 100).ms, curve: Curves.easeInOut);
                    }),
                  ),
                ],
              ),
            ),
          ),
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.xl * 2),
              child: GestureDetector(
                onTap: () => context.pop(),
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: Colors.redAccent.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.redAccent, width: 2),
                  ),
                  child: const Icon(Icons.stop_rounded, color: Colors.redAccent, size: 36),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPulseRing(double size, int delayMs) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.3), width: 2),
      ),
    ).animate(onPlay: (controller) => controller.repeat())
     .scale(begin: const Offset(0.5, 0.5), end: const Offset(1.5, 1.5), duration: 2.seconds, delay: delayMs.ms)
     .fade(begin: 1.0, end: 0.0, duration: 2.seconds, delay: delayMs.ms);
  }
}
