import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/primary_button.dart';
import '../../../core/widgets/rm_text_field.dart';
import '../../../core/router/app_router.dart';
import '../controllers/auth_controller.dart';
import '../../garage/controllers/garage_controller.dart';
import '../../garage/models/vehicle_model.dart';

class AddBikeOnboardingScreen extends StatefulWidget {
  const AddBikeOnboardingScreen({super.key});

  @override
  State<AddBikeOnboardingScreen> createState() => _AddBikeOnboardingScreenState();
}

class _AddBikeOnboardingScreenState extends State<AddBikeOnboardingScreen> {
  final _brandController = TextEditingController();
  final _modelController = TextEditingController();
  final _yearController = TextEditingController(text: '2024');
  final _regController = TextEditingController();
  final String _selectedFuel = 'Petrol';
  bool _isSubmitting = false;

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    super.dispose();
  }

  Future<void> _handleSaveBike() async {
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 2024;
    final reg = _regController.text.trim();

    if (brand.isEmpty || model.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter bike brand and model, or tap Skip')),
      );
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final auth = context.read<AuthController>();
      final userId = auth.currentUser?.id ?? 'user_guest';
      final garage = context.read<GarageController>();

      final vehicle = VehicleModel(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        brand: brand,
        model: model,
        year: year,
        registrationNumber: reg,
        fuelType: _selectedFuel,
        engineCc: 350,
        color: 'Circuit Orange',
        isDefault: true,
        isPrimary: true,
      );

      await garage.saveVehicle(vehicle);

      if (mounted) {
        context.go(AppRoutes.home);
      }
    } catch (_) {
      if (mounted) {
        context.go(AppRoutes.home);
      }
    } finally {
      if (mounted) setState(() => _isSubmitting = false);
    }
  }

  void _handleSkip() {
    context.go(AppRoutes.home);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, -0.3),
                radius: 1.2,
                colors: [Color(0x26FF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.lg),
                  // Icon Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: AppColors.circuitOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: const Icon(Icons.two_wheeler_rounded, size: 48, color: AppColors.circuitOrange),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: Text(
                      'ADD YOUR MOTORCYCLE',
                      style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Center(
                    child: Text(
                      'Track maintenance, fuel telemetry & service reminders.',
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // Form Glass Card
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('BRAND / MAKE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.xs),
                          RmTextField(
                            controller: _brandController,
                            hintText: 'e.g. KTM, Yamaha, Royal Enfield',
                            prefixIcon: Icons.motorcycle_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Text('MODEL NAME', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.xs),
                          RmTextField(
                            controller: _modelController,
                            hintText: 'e.g. Duke 390, MT-15, Himalayan',
                            prefixIcon: Icons.speed_rounded,
                            textInputAction: TextInputAction.next,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('YEAR', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                    const SizedBox(height: AppSpacing.xs),
                                    RmTextField(
                                      controller: _yearController,
                                      hintText: '2024',
                                      keyboardType: TextInputType.number,
                                      prefixIcon: Icons.calendar_today_rounded,
                                      textInputAction: TextInputAction.next,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('REG NUMBER', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                    const SizedBox(height: AppSpacing.xs),
                                    RmTextField(
                                      controller: _regController,
                                      hintText: 'KA-01-AB-1234',
                                      prefixIcon: Icons.badge_outlined,
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.xl),

                          PrimaryButton(
                            text: _isSubmitting ? 'SAVING VEHICLE...' : 'SAVE & ENTER COCKPIT',
                            onPressed: _isSubmitting ? null : _handleSaveBike,
                            isFullWidth: true,
                          ),
                          const SizedBox(height: AppSpacing.md),

                          Center(
                            child: TextButton(
                              onPressed: _handleSkip,
                              child: Text(
                                'Skip for now — you can add this anytime from Garage',
                                style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms, duration: 400.ms).slideY(begin: 0.1),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
