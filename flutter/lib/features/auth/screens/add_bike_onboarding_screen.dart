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
import '../../../core/vehicle_intelligence/vehicle_intelligence_service.dart';
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
  int _detectedCc = 350;
  String _selectedFuel = 'Petrol';
  bool _isSubmitting = false;
  bool _isLookingUp = false;

  void _autoFillSampleBike() {
    setState(() {
      _regController.text = 'KA04EL274';
      _brandController.text = 'Royal Enfield';
      _modelController.text = 'Classic 350';
      _yearController.text = '2024';
      _detectedCc = 349;
    });
  }

  @override
  void dispose() {
    _brandController.dispose();
    _modelController.dispose();
    _yearController.dispose();
    _regController.dispose();
    super.dispose();
  }

  Future<void> _handleLookupReg() async {
    final cleanReg = _regController.text.trim().toUpperCase();
    if (cleanReg.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a registration plate number.')),
      );
      return;
    }

    setState(() => _isLookingUp = true);

    try {
      final service = VehicleIntelligenceService();
      final data = await service.lookupVehicle(cleanReg);
      if (data != null && mounted) {
        setState(() {
          _brandController.text = data.brand;
          _modelController.text = data.modelName;
          _detectedCc = data.engineCc;
          _selectedFuel = data.fuelType;
          _yearController.text = data.manufactureYear.toString();
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Fetched: ${data.makerModel} (${data.engineCc} cc) • ${data.source}'),
            backgroundColor: Colors.green.shade800,
          ),
        );
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No RTO records found. Enter details manually.')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLookingUp = false);
    }
  }

  Future<void> _handleSaveBike() async {
    final brand = _brandController.text.trim();
    final model = _modelController.text.trim();
    final year = int.tryParse(_yearController.text.trim()) ?? 2024;
    final reg = _regController.text.trim().toUpperCase();

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

      int finalCc = _detectedCc;
      final matchingSpec = VehicleIntelligenceService.catalogue.firstWhere(
        (s) => s.brand.toLowerCase() == brand.toLowerCase() && s.model.toLowerCase() == model.toLowerCase(),
        orElse: () => MotorcycleSpec(brand: brand, model: model, engineCc: _detectedCc),
      );
      finalCc = matchingSpec.engineCc;

      final vehicle = VehicleModel(
        id: 'v_${DateTime.now().millisecondsSinceEpoch}',
        userId: userId,
        brand: brand,
        model: model,
        year: year,
        registrationNumber: reg,
        fuelType: _selectedFuel,
        engineCc: finalCc,
        color: matchingSpec.color,
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
                  const SizedBox(height: AppSpacing.md),
                  // Icon Header
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.circuitOrange.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.4), width: 1.5),
                      ),
                      child: const Icon(Icons.two_wheeler_rounded, size: 40, color: AppColors.circuitOrange),
                    ),
                  ).animate().scale(duration: 400.ms, curve: Curves.easeOutBack),
                  const SizedBox(height: AppSpacing.md),

                  Center(
                    child: Text(
                      'ADD YOUR MOTORCYCLE',
                      style: AppTextStyles.headlineMd(color: AppColors.onSurface).copyWith(letterSpacing: 1.1),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Center(
                    child: Text(
                      'Auto-fetch vehicle details from RTO or pick a model below.',
                      style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Center(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.circuitOrange,
                        side: const BorderSide(color: AppColors.circuitOrange, width: 1.2),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                      icon: const Icon(Icons.bolt, size: 16),
                      label: const Text('AUTO-FILL DEMO BIKE (KA04EL274)', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                      onPressed: _autoFillSampleBike,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // Form Glass Card
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.lg),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Reg Number with Lookup Button
                          Text('REGISTRATION NUMBER', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.xs),
                          Row(
                            children: [
                              Expanded(
                                child: RmTextField(
                                  controller: _regController,
                                  hintText: 'e.g. KA04EL274',
                                  prefixIcon: Icons.badge_outlined,
                                  textInputAction: TextInputAction.next,
                                ),
                              ),
                              const SizedBox(width: 8),
                              ElevatedButton(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.circuitOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                onPressed: _isLookingUp ? null : _handleLookupReg,
                                child: _isLookingUp
                                    ? const SizedBox(
                                        width: 18,
                                        height: 18,
                                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                      )
                                    : const Row(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Icon(Icons.search, size: 16),
                                          SizedBox(width: 4),
                                          Text('FETCH', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                        ],
                                      ),
                              ),
                            ],
                          ),
                          const SizedBox(height: AppSpacing.md),

                          // Popular Brand Selector Chips
                          Text('QUICK SELECT BRAND', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                          const SizedBox(height: AppSpacing.xs),
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: VehicleIntelligenceService.popularBrands.map((brandName) {
                                final isSelected = _brandController.text.toLowerCase() == brandName.toLowerCase();
                                return Padding(
                                  padding: const EdgeInsets.only(right: 6),
                                  child: FilterChip(
                                    selected: isSelected,
                                    label: Text(brandName, style: TextStyle(fontSize: 12, color: isSelected ? Colors.white : Colors.white70)),
                                    backgroundColor: Colors.white10,
                                    selectedColor: AppColors.circuitOrange,
                                    checkmarkColor: Colors.white,
                                    onSelected: (selected) {
                                      setState(() {
                                        _brandController.text = brandName;
                                        final models = VehicleIntelligenceService.getModelsForBrand(brandName);
                                        if (models.isNotEmpty) {
                                          _modelController.text = models.first.model;
                                          _detectedCc = models.first.engineCc;
                                          _selectedFuel = models.first.fuelType;
                                        }
                                      });
                                    },
                                  ),
                                );
                              }).toList(),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.sm),

                          // Matching Models Chips
                          if (_brandController.text.isNotEmpty) ...[
                            Text('SELECT MODEL', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                            const SizedBox(height: AppSpacing.xs),
                            SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: Row(
                                children: VehicleIntelligenceService.getModelsForBrand(_brandController.text).map((spec) {
                                  final isSelected = _modelController.text.toLowerCase() == spec.model.toLowerCase();
                                  return Padding(
                                    padding: const EdgeInsets.only(right: 6),
                                    child: ActionChip(
                                      backgroundColor: isSelected ? AppColors.circuitOrange.withValues(alpha: 0.3) : Colors.white10,
                                      side: BorderSide(color: isSelected ? AppColors.circuitOrange : Colors.white24),
                                      label: Text('${spec.model} (${spec.engineCc} cc)',
                                          style: TextStyle(fontSize: 11, color: isSelected ? AppColors.circuitOrange : Colors.white)),
                                      onPressed: () {
                                        setState(() {
                                          _modelController.text = spec.model;
                                          _detectedCc = spec.engineCc;
                                          _selectedFuel = spec.fuelType;
                                        });
                                      },
                                    ),
                                  );
                                }).toList(),
                              ),
                            ),
                            const SizedBox(height: AppSpacing.md),
                          ],

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
                                      textInputAction: TextInputAction.done,
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text('ENGINE CC', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                                    const SizedBox(height: AppSpacing.xs),
                                    Container(
                                      height: 52,
                                      padding: const EdgeInsets.symmetric(horizontal: 14),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withValues(alpha: 0.05),
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(color: Colors.white12),
                                      ),
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        '$_detectedCc cc',
                                        style: const TextStyle(
                                          color: AppColors.circuitOrange,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                        ),
                                      ),
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
