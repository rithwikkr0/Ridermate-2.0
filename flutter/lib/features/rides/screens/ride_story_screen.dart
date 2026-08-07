import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/primary_button.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideStoryScreen extends StatelessWidget {
  const RideStoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Background Image / Gradient Placeholder
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF282A2B), Color(0xFF121414)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          CustomPaint(painter: _StoryDecorationPainter(), size: Size.infinite),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.close, color: Colors.white),
                        onPressed: () => context.pop(),
                      ),
                      Text('RiderMate', style: AppTextStyles.labelCaps(color: Colors.white.withValues(alpha: 0.5))),
                    ],
                  ),
                  const Spacer(),
                  Text('Morning Ascent', style: AppTextStyles.headlineLg(color: Colors.white)).animate().fadeIn().slideX(),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Oct 24, 2023', style: AppTextStyles.bodyMd(color: Colors.white.withValues(alpha: 0.7))).animate().fadeIn(delay: 100.ms).slideX(),
                  const SizedBox(height: AppSpacing.xl),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                          Text('42.5 km', style: AppTextStyles.displayStat(color: Colors.white).copyWith(fontSize: 40)),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text('AVG SPEED', style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                          Text('28.2 km/h', style: AppTextStyles.displayStat(color: Colors.white).copyWith(fontSize: 40)),
                        ],
                      ),
                    ],
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                  const Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: PrimaryButton(
                      text: 'Share to Instagram',
                      onPressed: () {},
                    ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StoryDecorationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.circuitOrange.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;
      
    canvas.drawCircle(Offset(size.width * 0.8, size.height * 0.2), 150, paint);
    canvas.drawCircle(Offset(size.width * 0.2, size.height * 0.8), 200, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
