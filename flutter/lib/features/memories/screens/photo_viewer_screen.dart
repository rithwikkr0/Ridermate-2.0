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

class PhotoViewerScreen extends StatelessWidget {
  const PhotoViewerScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final memory = memoryCtrl.selectedMemory;

    if (memory == null) {
      return Scaffold(
        backgroundColor: Colors.black,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => context.pop(),
          ),
        ),
        body: const Center(
          child: Text('No photo selected', style: TextStyle(color: Colors.white)),
        ),
      );
    }

    final authCtrl = context.watch<AuthController>();
    final userId = authCtrl.currentUser?.id ?? 'default_user';
    final isAsset = memory.imagePath.startsWith('assets/');

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Photo Content ──────────────────────────────────────────────
          Center(
            child: InteractiveViewer(
              child: isAsset
                  ? Image.asset(memory.imagePath, fit: BoxFit.contain)
                  : Image.file(
                      File(memory.imagePath),
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.broken_image, size: 64, color: AppColors.onSurfaceVariant),
                            const SizedBox(height: 8),
                            Text('Image unavailable', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    ),
            ),
          ),

          // ── Top Controls ────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
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
                            onPressed: () => context.push(AppRoutes.memoryMap),
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
                          onPressed: () => _confirmDelete(context, memoryCtrl, memory, userId),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom Information Overlay ─────────────────────────────────
          Align(
            alignment: Alignment.bottomCenter,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.marginMobile),
                child: GlassCard(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                memory.caption.isNotEmpty ? memory.caption : 'Ride Memory',
                                style: AppTextStyles.bodyLg(color: Colors.white),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                '${_formatDate(memory.createdAt)}${memory.locationName != null ? ' · ${memory.locationName}' : ''}',
                                style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        if (memory.rideDistance != null)
                          Text(
                            GeoUtils.formatDistance(memory.rideDistance!),
                            style: AppTextStyles.statLabel(color: AppColors.circuitOrange),
                          ),
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

  String _formatDate(DateTime dt) {
    final months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    final local = dt.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  Future<void> _confirmDelete(
    BuildContext context,
    MemoryController memoryCtrl,
    MemoryModel memory,
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
