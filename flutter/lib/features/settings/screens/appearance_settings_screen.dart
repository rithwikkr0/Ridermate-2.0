import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import 'package:go_router/go_router.dart';
import '../../../core/router/app_router.dart';

class AppearanceSettingsScreen extends StatefulWidget {
  const AppearanceSettingsScreen({super.key});

  @override
  State<AppearanceSettingsScreen> createState() => _AppearanceSettingsScreenState();
}

class _AppearanceSettingsScreenState extends State<AppearanceSettingsScreen> {
  int _selectedTheme = 0;
  int _selectedMapStyle = 0;
  bool _useKm = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
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
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () {
                          if (context.canPop()) {
                            context.pop();
                          } else {
                            context.go(AppRoutes.settings);
                          }
                        },
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Appearance', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  Text('THEME PREFERENCE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  Row(
                    children: ['Dark', 'Light', 'System'].asMap().entries.map((e) {
                      final isSelected = _selectedTheme == e.key;
                      return Expanded(
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          child: GlassCard(
                            onTap: () => setState(() => _selectedTheme = e.key),
                            borderColor: isSelected ? AppColors.circuitOrange : null,
                            child: Padding(
                              padding: const EdgeInsets.all(AppSpacing.md),
                              child: Column(
                                children: [
                                  Icon(
                                    e.key == 0 ? Icons.dark_mode : (e.key == 1 ? Icons.light_mode : Icons.settings_suggest),
                                    color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(e.value, style: AppTextStyles.bodySm(color: isSelected ? AppColors.circuitOrange : AppColors.onSurface)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Text('MAP STYLE', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Column(
                      children: ['Standard Dark', 'Satellite', 'Terrain'].asMap().entries.map((e) {
                    final isSelected = _selectedMapStyle == e.key;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedMapStyle = e.key),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: AppSpacing.md),
                        child: Row(
                          children: [
                            Icon(
                              isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
                              color: isSelected ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                              size: 20,
                            ),
                            const SizedBox(width: AppSpacing.md),
                            Expanded(
                              child: Text(
                                e.value,
                                style: AppTextStyles.bodyMd(
                                  color: isSelected ? AppColors.circuitOrange : AppColors.onSurface,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                    ),
                  ).animate().fadeIn(delay: 200.ms),
                  const SizedBox(height: AppSpacing.lg),
                  Text('UNITS', style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant)),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Distance Unit', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                              Text(_useKm ? 'Kilometers (km, km/h)' : 'Miles (mi, mph)', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          Switch(
                            value: _useKm,
                            activeThumbColor: AppColors.circuitOrange,
                            onChanged: (val) => setState(() => _useKm = val),
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 300.ms),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
