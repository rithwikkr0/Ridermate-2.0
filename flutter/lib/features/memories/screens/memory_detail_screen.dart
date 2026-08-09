import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_model.dart';

class MemoryDetailScreen extends StatelessWidget {
  final MemoryModel memory;

  const MemoryDetailScreen({super.key, required this.memory});

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final authCtrl = context.watch<AuthController>();
    final userId = authCtrl.currentUser?.id ?? 'default_user';

    final dateStr = _formatDate(memory.createdAt);
    final isAsset = memory.imagePath.startsWith('assets/');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Large Photo Background / Viewer ──────────────────────────────
          Positioned.fill(
            child: isAsset
                ? Image.asset(memory.imagePath, fit: BoxFit.contain)
                : Image.file(
                    File(memory.imagePath),
                    fit: BoxFit.contain,
                    errorBuilder: (_, __, ___) => Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.broken_image, size: 64, color: AppColors.onSurfaceVariant),
                          const SizedBox(height: 8),
                          Text('Image not found', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                        ],
                      ),
                    ),
                  ),
          ),

          // ── Top Navigation Bar ───────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  Row(
                    children: [
                      if (memory.latitude != null && memory.longitude != null)
                        CircleAvatar(
                          backgroundColor: Colors.black.withValues(alpha: 0.6),
                          child: IconButton(
                            icon: const Icon(Icons.map, color: AppColors.circuitOrange),
                            onPressed: () {
                              context.push(AppRoutes.memoryMap);
                            },
                          ),
                        ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white),
                          onPressed: () {
                            memoryCtrl.initEditDraft(memory);
                            context.push(AppRoutes.createMemory);
                          },
                        ),
                      ),
                      const SizedBox(width: 8),
                      CircleAvatar(
                        backgroundColor: Colors.black.withValues(alpha: 0.6),
                        child: IconButton(
                          icon: const Icon(Icons.delete_outline, color: AppColors.error),
                          onPressed: () => _confirmDelete(context, memoryCtrl, userId),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Glass Detail Card ─────────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Privacy pill + Date
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _buildPrivacyPill(memory.privacy),
                            Text(dateStr, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                          ],
                        ),

                        if (memory.caption.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Text(
                            memory.caption,
                            style: AppTextStyles.bodyLg(color: Colors.white),
                          ),
                        ],

                        if (memory.locationName != null && memory.locationName!.isNotEmpty) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.place, size: 16, color: AppColors.circuitOrange),
                              const SizedBox(width: 4),
                              Expanded(
                                child: Text(
                                  memory.locationName!,
                                  style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ],

                        if (memory.rideDistance != null || memory.rideDuration != null) ...[
                          const SizedBox(height: 12),
                          const Divider(color: AppColors.glassBorder),
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              const Icon(Icons.directions_bike, size: 16, color: AppColors.circuitOrange),
                              const SizedBox(width: 6),
                              Text(
                                memory.rideDistance != null
                                    ? GeoUtils.formatDistance(memory.rideDistance!)
                                    : 'Associated Ride',
                                style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                              ),
                              if (memory.rideDuration != null) ...[
                                const SizedBox(width: 12),
                                const Icon(Icons.timer_outlined, size: 16, color: AppColors.onSurfaceVariant),
                                const SizedBox(width: 4),
                                Text(
                                  _formatDuration(memory.rideDuration!),
                                  style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ).animate().slideY(begin: 0.2).fadeIn(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPrivacyPill(MemoryPrivacy privacy) {
    final String label;
    final IconData icon;
    switch (privacy) {
      case MemoryPrivacy.private:
        label = 'PRIVATE';
        icon = Icons.lock_outline;
      case MemoryPrivacy.friends:
        label = 'FRIENDS';
        icon = Icons.people_outline;
      case MemoryPrivacy.public:
        label = 'PUBLIC';
        icon = Icons.public;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.circuitOrange.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.5)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: AppColors.circuitOrange),
          const SizedBox(width: 4),
          Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
        ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final local = dt.toLocal();
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return '${months[local.month - 1]} ${local.day}, ${local.year} · ${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MemoryController memoryCtrl,
    String userId,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Memory?', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
        content: Text(
          'This memory and its photo file will be permanently deleted.',
          style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text('Cancel', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final success = await memoryCtrl.deleteMemory(memory.id, userId);
      if (success && context.mounted) {
        context.pop();
      }
    }
  }
}
