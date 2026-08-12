import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_scroll_body.dart';
import '../../../core/router/app_router.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_model.dart';

class JournalDashboardScreen extends StatefulWidget {
  const JournalDashboardScreen({super.key});

  @override
  State<JournalDashboardScreen> createState() => _JournalDashboardScreenState();
}

class _JournalDashboardScreenState extends State<JournalDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authCtrl = context.read<AuthController>();
      final userId = authCtrl.currentUser?.id ?? 'default_user';
      context.read<MemoryController>().loadMemories(userId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final authCtrl = context.watch<AuthController>();
    final userId = authCtrl.currentUser?.id ?? 'default_user';
    final memories = memoryCtrl.memories;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.circuitOrange,
        onPressed: () {
          memoryCtrl.resetDraft();
          context.push(AppRoutes.createMemory);
        },
        child: const Icon(Icons.add_a_photo, color: Colors.white),
      ),
      body: Stack(
        children: [
          // Background radial gradient
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
            child: RefreshIndicator(
              color: AppColors.circuitOrange,
              backgroundColor: AppColors.surfaceDark,
              onRefresh: () => memoryCtrl.loadMemories(userId),
              child: RmScrollBody(
                child: SingleChildScrollView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.marginMobile,
                    AppSpacing.md,
                    AppSpacing.marginMobile,
                    120, // bottom nav clearance
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Ride Journal',
                            style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                          ),
                          Row(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.photo_library_outlined, color: AppColors.onSurface),
                                onPressed: () => context.push(AppRoutes.mediaGallery),
                              ),
                              IconButton(
                                icon: const Icon(Icons.map_outlined, color: AppColors.circuitOrange),
                                onPressed: () => context.push(AppRoutes.memoryMap),
                              ),
                              IconButton(
                                icon: const Icon(Icons.search, color: AppColors.onSurface),
                                onPressed: () => context.push(AppRoutes.journalSearch),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(),

                      const SizedBox(height: AppSpacing.lg),

                      Text(
                        'RECENT MEMORIES',
                        style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                      ),
                      const SizedBox(height: AppSpacing.sm),

                      if (memoryCtrl.memoryState == MemoryState.loading && memories.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(40),
                          child: Center(
                            child: CircularProgressIndicator(color: AppColors.circuitOrange),
                          ),
                        )
                      else if (memories.isEmpty)
                        _buildEmptyState()
                      else
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: memories.length,
                          itemBuilder: (context, index) {
                            final memory = memories[index];
                            return _buildMemoryCard(context, memory, memoryCtrl, index);
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 48, horizontal: 24),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.glassBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.photo_library_outlined,
            size: 64,
            color: AppColors.circuitOrange,
          ),
          const SizedBox(height: 16),
          Text(
            'No memories yet',
            style: AppTextStyles.headlineSm(color: AppColors.onSurface),
          ),
          const SizedBox(height: 8),
          Text(
            'Capture your first ride memory.',
            style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildMemoryCard(
    BuildContext context,
    MemoryModel memory,
    MemoryController memoryCtrl,
    int index,
  ) {
    final isAsset = memory.imagePath.startsWith('assets/');
    final dateStr = _formatDate(memory.createdAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        onPressed: () {
          memoryCtrl.selectMemory(memory);
          context.push(AppRoutes.memoryDetail);
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image header
            ClipRRect(
              borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
              child: SizedBox(
                height: 180,
                width: double.infinity,
                child: isAsset
                    ? Image.asset(memory.imagePath, fit: BoxFit.cover)
                    : Image.file(
                        File(memory.imagePath),
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(
                            child: Icon(
                              Icons.directions_bike,
                              size: 48,
                              color: AppColors.circuitOrange,
                            ),
                          ),
                        ),
                      ),
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(dateStr, style: AppTextStyles.labelCaps(color: AppColors.circuitOrange)),
                      _buildPrivacyBadge(memory.privacy),
                    ],
                  ),
                  if (memory.caption.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Text(
                      memory.caption,
                      style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (memory.locationName != null && memory.locationName!.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(Icons.place_outlined, size: 14, color: AppColors.onSurfaceVariant),
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
                  if (memory.rideDistance != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Row(
                      children: [
                        const Icon(Icons.directions_bike, size: 16, color: AppColors.circuitOrange),
                        const SizedBox(width: 4),
                        Text(
                          GeoUtils.formatDistance(memory.rideDistance!),
                          style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                        ),
                        if (memory.rideDuration != null) ...[
                          const SizedBox(width: AppSpacing.md),
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
          ],
        ),
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 50 * index)).slideY(begin: 0.1);
  }

  Widget _buildPrivacyBadge(MemoryPrivacy privacy) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        privacy.name.toUpperCase(),
        style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = [
      'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    final local = dt.toLocal();
    return '${months[local.month - 1]} ${local.day}, ${local.year}';
  }

  String _formatDuration(int seconds) {
    final d = Duration(seconds: seconds);
    final h = d.inHours;
    final m = d.inMinutes.remainder(60);
    if (h > 0) return '${h}h ${m}m';
    return '${m}m';
  }
}
