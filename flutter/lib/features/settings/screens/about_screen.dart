import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/config/build_info.dart';

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('About RiderMate', style: AppTextStyles.headlineSm()),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: AppSpacing.lg),

            // App logo / icon
            Container(
              width: 96,
              height: 96,
              decoration: BoxDecoration(
                color: AppColors.circuitOrange.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(
                    color: AppColors.circuitOrange.withValues(alpha: 0.4),
                    width: 1.5),
              ),
              child: const Icon(Icons.two_wheeler_rounded,
                  size: 52, color: AppColors.circuitOrange),
            ),
            const SizedBox(height: AppSpacing.md),
            Text('RiderMate 2.0',
                style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
            const SizedBox(height: 4),
            Text('Premium Motorcycle Companion',
                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
            const SizedBox(height: AppSpacing.xl),

            // ── Build identifier card ─────────────────────────────────────
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('BUILD INFO',
                        style: AppTextStyles.labelCaps(
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.sm),
                    _InfoRow(label: 'Version', value: BuildInfo.version),
                    _InfoRow(
                        label: 'Build Number', value: BuildInfo.buildNumber),
                    _InfoRow(label: 'Git Commit', value: BuildInfo.commit),
                    const Divider(color: AppColors.glassBorder, height: 20),
                    Center(
                      child: SelectableText(
                        BuildInfo.label,
                        style: AppTextStyles.bodyXs(
                            color: AppColors.onSurfaceVariant),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.sm),
                    Center(
                      child: OutlinedButton.icon(
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.glassBorder),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8)),
                        ),
                        icon: const Icon(Icons.copy,
                            size: 14, color: AppColors.circuitOrange),
                        label: Text('Copy Build Info',
                            style: AppTextStyles.bodyXs(
                                color: AppColors.onSurface)),
                        onPressed: () {
                          Clipboard.setData(
                              ClipboardData(text: BuildInfo.label));
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                                content: Text('Build info copied to clipboard')),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Legal
            GlassCard(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('LEGAL',
                        style: AppTextStyles.labelCaps(
                            color: AppColors.onSurfaceVariant)),
                    const SizedBox(height: AppSpacing.sm),
                    Text(
                      '© 2025 RiderMate. All rights reserved.\nMade for riders, by riders.\n\nMap tiles © CartoDB. OpenStreetMap contributors.',
                      style: AppTextStyles.bodySm(
                          color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({required this.label, required this.value});
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style:
                  AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
          Text(value,
              style: AppTextStyles.bodySm(color: AppColors.onSurface)
                  .copyWith(fontFamily: 'monospace')),
        ],
      ),
    );
  }
}
