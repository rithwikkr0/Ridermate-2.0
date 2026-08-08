import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/router/app_router.dart';
import '../../../core/services/database_service.dart';
import '../controllers/auth_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import '../../profile/repositories/sqlite_user_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _initialize();
  }

  Future<void> _initialize() async {
    // Allow the splash animation to begin
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) return;

    // Attempt to restore session from persistent storage
    final authController = context.read<AuthController>();
    await authController.restoreSession();

    if (!mounted) return;

    if (authController.isLoggedIn) {
      // Wire the ProfileController to the real repository for this user
      final userId = authController.currentUser!.id;
      final profileController = context.read<ProfileController>();
      profileController.updateRepository(
        SqliteUserRepository(DatabaseService.instance, userId: userId),
      );
      context.go(AppRoutes.home);
    } else {
      context.go(AppRoutes.onboarding);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Background gradient with subtle orange glow
          Center(
            child: Container(
              width: 300,
              height: 300,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x26FF6B00), Colors.transparent],
                  stops: [0.0, 0.7],
                ),
              ),
            ).animate(onPlay: (controller) => controller.repeat(reverse: true))
             .scale(begin: const Offset(0.95, 0.95), end: const Offset(1.05, 1.05), duration: 2000.ms),
          ),
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'RiderMate',
                  style: AppTextStyles.displayStat().copyWith(color: Colors.white),
                ).animate().fadeIn(duration: 800.ms).scale(begin: const Offset(0.8, 0.8)),
                const SizedBox(height: 8),
                Text(
                  'KINETIC PRECISION',
                  style: AppTextStyles.labelCaps().copyWith(
                    color: AppColors.primary,
                    letterSpacing: 2.0,
                  ),
                ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
                const SizedBox(height: 40),
                // Loading line simulation
                Container(
                  width: 120,
                  height: 2,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(2),
                  ),
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      width: 60,
                      height: 2,
                      decoration: BoxDecoration(
                        color: AppColors.circuitOrange,
                        borderRadius: BorderRadius.circular(2),
                        boxShadow: const [
                          BoxShadow(color: AppColors.circuitOrange, blurRadius: 10),
                        ],
                      ),
                    ).animate(onPlay: (controller) => controller.repeat())
                     .slideX(begin: -1.0, end: 2.0, duration: 1500.ms),
                  ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Text(
              'System Initializing // V.2.4.1',
              textAlign: TextAlign.center,
              style: AppTextStyles.labelCaps().copyWith(
                color: AppColors.onSurfaceVariant.withValues(alpha: 0.4),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
