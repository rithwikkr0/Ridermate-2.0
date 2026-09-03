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
      'badge': 'KINETIC TELEMETRY',
      'title': 'Track Every Watt',
      'subtitle':
          'Experience hyper-accurate telemetry, live lean angle gauges, dynamic G-force, and speed tracking in your high-performance cockpit.',
      'image': 'assets/images/onboard_telemetry.jpg',
      'icon': 'speed',
    },
    {
      'badge': 'NEURAL AI COPILOT',
      'title': 'AI Safety Vision',
      'subtitle':
          'Optimal apex trajectory projection, real-time hazard detection, predictive cornering advice, and voice-guided safety coaching.',
      'image': 'assets/images/onboard_ai_coach.jpg',
      'icon': 'psychology',
    },
    {
      'badge': 'SQUAD FORMATION',
      'title': 'Ride Together',
      'subtitle':
          'Live squad radar, dynamic convoy beacon distance tracking, group crash detection, and instant offline SOS coordinates dispatch.',
      'image': 'assets/images/onboard_squad.jpg',
      'icon': 'groups',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final currentSlide = _slides[_currentIndex];

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // ── Background Cross-Fading Cinematic Images ───────────────────────
          Positioned.fill(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 600),
              child: Container(
                key: ValueKey<int>(_currentIndex),
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(currentSlide['image']!),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
          ),

          // ── Deep Vignette & Gradient Overlays ──────────────────────────────
          Positioned.fill(
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.45),
                    Colors.transparent,
                    AppColors.background.withValues(alpha: 0.75),
                    AppColors.background,
                  ],
                  stops: const [0.0, 0.35, 0.70, 1.0],
                ),
              ),
            ),
          ),

          // ── Top Brand Header ──────────────────────────────────────────────
          SafeArea(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(color: AppColors.circuitOrange, width: 1.5),
                            image: const DecorationImage(
                              image: AssetImage('assets/images/ridermate_icon.png'),
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'RIDERMATE 2.0',
                          style: AppTextStyles.labelCaps(color: Colors.white).copyWith(
                            letterSpacing: 1.8,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ],
                    ),
                    TextButton(
                      style: TextButton.styleFrom(
                        foregroundColor: Colors.white70,
                        backgroundColor: Colors.black26,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      ),
                      onPressed: () => context.go(AppRoutes.register),
                      child: const Text('Fill Details', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Bottom Glass Carousel Card ────────────────────────────────────
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
                          // Top Indicator Pills
                          Row(
                            children: List.generate(
                              _slides.length,
                              (index) => Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(right: index == _slides.length - 1 ? 0 : 6),
                                  height: 4,
                                  decoration: BoxDecoration(
                                    color: _currentIndex == index
                                        ? AppColors.circuitOrange
                                        : Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                    boxShadow: _currentIndex == index
                                        ? [
                                            BoxShadow(
                                              color: AppColors.circuitOrange.withValues(alpha: 0.6),
                                              blurRadius: 8,
                                            ),
                                          ]
                                        : null,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Swipeable Text PageView
                          SizedBox(
                            height: 140,
                            child: PageView.builder(
                              controller: _pageController,
                              onPageChanged: (index) {
                                setState(() {
                                  _currentIndex = index;
                                });
                              },
                              itemCount: _slides.length,
                              itemBuilder: (context, index) {
                                final slide = _slides[index];
                                return Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    // Badge
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                      decoration: BoxDecoration(
                                        color: AppColors.circuitOrange.withValues(alpha: 0.2),
                                        borderRadius: BorderRadius.circular(6),
                                        border: Border.all(
                                          color: AppColors.circuitOrange.withValues(alpha: 0.4),
                                        ),
                                      ),
                                      child: Text(
                                        slide['badge']!,
                                        style: const TextStyle(
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.circuitOrange,
                                          letterSpacing: 1.2,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),

                                    // Title
                                    Text(
                                      slide['title']!,
                                      style: AppTextStyles.headlineLg().copyWith(
                                        color: AppColors.onSurface,
                                        fontWeight: FontWeight.w800,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Subtitle
                                    Text(
                                      slide['subtitle']!,
                                      maxLines: 3,
                                      overflow: TextOverflow.ellipsis,
                                      style: AppTextStyles.bodyMd().copyWith(
                                        color: AppColors.onSurfaceVariant,
                                        height: 1.35,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Controls Row
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              // Previous or Step count
                              Text(
                                '${_currentIndex + 1} / ${_slides.length}',
                                style: AppTextStyles.statLabel().copyWith(
                                  color: AppColors.onSurfaceVariant,
                                  fontFamily: 'monospace',
                                ),
                              ),

                              // Next / Get Started Action Button
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.circuitOrange,
                                  foregroundColor: Colors.white,
                                  elevation: 6,
                                  shadowColor: AppColors.circuitOrange.withValues(alpha: 0.5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(16),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 24,
                                    vertical: 12,
                                  ),
                                ),
                                onPressed: () {
                                  if (_currentIndex < _slides.length - 1) {
                                    _pageController.nextPage(
                                      duration: const Duration(milliseconds: 350),
                                      curve: Curves.easeInOut,
                                    );
                                  } else {
                                    context.go(AppRoutes.register);
                                  }
                                },
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Text(
                                      _currentIndex == _slides.length - 1 ? 'FILL DETAILS & START' : 'NEXT',
                                      style: const TextStyle(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w800,
                                        letterSpacing: 1.2,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    const Icon(Icons.arrow_forward_rounded, size: 18),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go(AppRoutes.login),
                              child: const Text.rich(
                                TextSpan(
                                  text: 'Already have an account? ',
                                  style: TextStyle(color: Colors.white60, fontSize: 12),
                                  children: [
                                    TextSpan(
                                      text: 'Log In',
                                      style: TextStyle(color: AppColors.circuitOrange, fontWeight: FontWeight.bold),
                                    ),
                                  ],
                                ),
                              ),
                            ),
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
