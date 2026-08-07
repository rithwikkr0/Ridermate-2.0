import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentIndex = 0;

  final List<Map<String, String>> _slides = [
    {
      'title': 'Track Every Watt',
      'subtitle': 'Experience hyper-accurate telemetry and kinetic precision. Your high-performance cockpit awaits.',
      'icon': 'bolt',
    },
    {
      'title': 'AI Coach',
      'subtitle': 'Personalized insights and real-time guidance to push your limits safely.',
      'icon': 'psychology',
    },
    {
      'title': 'Ride Together',
      'subtitle': 'Connect with other riders, form groups, and conquer routes as a team.',
      'icon': 'groups',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background placeholder for image
          Container(
            decoration: const BoxDecoration(
              image: DecorationImage(
                image: NetworkImage('https://images.unsplash.com/photo-1541625602330-2277a4c4618c?q=80&w=1000&auto=format&fit=crop'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.bottomCenter,
                end: Alignment.topCenter,
                colors: [
                  AppColors.background,
                  AppColors.background.withValues(alpha: 0.8),
                  Colors.transparent,
                ],
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppSpacing.marginMobile),
                  child: GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: List.generate(
                              _slides.length,
                              (index) => Container(
                                margin: const EdgeInsets.only(right: 8),
                                height: 4,
                                width: 32,
                                decoration: BoxDecoration(
                                  color: _currentIndex == index
                                      ? AppColors.circuitOrange
                                      : AppColors.surfaceVariant,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          SizedBox(
                            height: 120,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemCount: _slides.length,
                                itemBuilder: (context, index) {
                                  return SingleChildScrollView(
                                    physics: const NeverScrollableScrollPhysics(),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _slides[index]['title']!,
                                          style: AppTextStyles.headlineLg().copyWith(color: AppColors.onSurface),
                                        ),
                                        const SizedBox(height: 8),
                                        Text(
                                          _slides[index]['subtitle']!,
                                          style: AppTextStyles.bodyLg().copyWith(color: AppColors.onSurfaceVariant),
                                        ),
                                      ],
                                    ),
                                  );
                                },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.lg),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () => context.go(AppRoutes.login),
                                child: Text(
                                  'Skip',
                                  style: AppTextStyles.statLabel().copyWith(color: AppColors.onSurfaceVariant),
                                ),
                              ),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.circuitOrange,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(24),
                                  ),
                                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
                                ),
                                onPressed: () {
                                  if (_currentIndex < _slides.length - 1) {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 300),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    context.go(AppRoutes.login);
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentIndex == _slides.length - 1 ? 'Get Started' : 'Next',
                                      style: AppTextStyles.statLabel().copyWith(color: Colors.white),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward, color: Colors.white, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
