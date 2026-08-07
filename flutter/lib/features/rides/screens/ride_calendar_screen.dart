import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

class RideCalendarScreen extends StatelessWidget {
  const RideCalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        flexibleSpace: ClipRRect(
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              color: AppColors.surfaceDark.withValues(alpha: 0.6),
            ),
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurfaceVariant),
          onPressed: () => context.pop(),
        ),
        title: Text('Ride Calendar', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
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
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.marginMobile,
                AppSpacing.md,
                AppSpacing.marginMobile,
                100, // bottom nav clearance
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            IconButton(icon: const Icon(Icons.chevron_left, color: AppColors.onSurface), onPressed: (){}),
                            Text('October 2023', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                            IconButton(icon: const Icon(Icons.chevron_right, color: AppColors.onSurface), onPressed: (){}),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),
                        // Weekdays header
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: ['M', 'T', 'W', 'T', 'F', 'S', 'S'].map((day) => 
                            Text(day, style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant))
                          ).toList(),
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        // Days grid mock
                        GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 7,
                            mainAxisSpacing: 8,
                            crossAxisSpacing: 8,
                          ),
                          itemCount: 31,
                          itemBuilder: (context, index) {
                            final day = index + 1;
                            final hasRide = [3, 5, 12, 18, 22, 24].contains(day);
                            final isSelected = day == 24;
                            
                            return Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                color: isSelected ? AppColors.circuitOrange : Colors.transparent,
                              ),
                              alignment: Alignment.center,
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    day.toString(),
                                    style: AppTextStyles.bodyMd(color: isSelected ? Colors.white : AppColors.onSurface),
                                  ),
                                  if (hasRide && !isSelected)
                                    Container(
                                      margin: const EdgeInsets.only(top: 2),
                                      width: 4,
                                      height: 4,
                                      decoration: const BoxDecoration(
                                        color: AppColors.circuitOrange,
                                        shape: BoxShape.circle,
                                      ),
                                    ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                  const SizedBox(height: AppSpacing.xl),
                  Text('Rides on Oct 24', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                  const SizedBox(height: AppSpacing.md),
                  // Mock single ride detail
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Morning Ascent', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                        const SizedBox(height: AppSpacing.sm),
                        Row(
                          children: [
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('DISTANCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                Text('42.5 KM', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                              ],
                            )),
                            Expanded(child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text('AVG SPEED', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                Text('28.2 KM/H', style: AppTextStyles.statLabel(color: AppColors.onSurface)),
                              ],
                            )),
                          ],
                        )
                      ],
                    ),
                  ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
