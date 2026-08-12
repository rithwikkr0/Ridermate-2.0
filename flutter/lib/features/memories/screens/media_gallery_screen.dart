import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/router/app_router.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../controllers/memory_controller.dart';

class MediaGalleryScreen extends StatefulWidget {
  const MediaGalleryScreen({super.key});

  @override
  State<MediaGalleryScreen> createState() => _MediaGalleryScreenState();
}

class _MediaGalleryScreenState extends State<MediaGalleryScreen> {
  String _activeFilter = 'All';

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
    final allMemories = memoryCtrl.memories;

    final filteredMemories = allMemories.where((m) {
      if (_activeFilter == 'Rides') return m.rideId != null;
      if (_activeFilter == 'Location') return m.latitude != null && m.longitude != null;
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppColors.circuitOrange,
        onPressed: () {
          memoryCtrl.resetDraft();
          context.push(AppRoutes.createMemory);
        },
        child: const Icon(Icons.camera_alt, color: Colors.white),
      ),
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
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Text('Media Gallery', style: AppTextStyles.headlineMd(color: AppColors.onSurface)),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.md),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: ['All', 'Rides', 'Location'].map((filter) {
                        final isSelected = filter == _activeFilter;
                        return Padding(
                          padding: const EdgeInsets.only(right: AppSpacing.sm),
                          child: ChoiceChip(
                            label: Text(
                              filter,
                              style: AppTextStyles.labelCapsSm(
                                color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                              ),
                            ),
                            selected: isSelected,
                            selectedColor: AppColors.circuitOrange,
                            backgroundColor: AppColors.surfaceContainerHigh,
                            side: BorderSide(
                              color: isSelected ? AppColors.circuitOrange : AppColors.glassBorder,
                            ),
                            onSelected: (_) {
                              setState(() {
                                _activeFilter = filter;
                              });
                            },
                          ),
                        );
                      }).toList(),
                    ),
                  ).animate().fadeIn(delay: 100.ms),
                  const SizedBox(height: AppSpacing.lg),
                  if (filteredMemories.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(40),
                        child: Column(
                          children: [
                            const Icon(Icons.photo_library_outlined, size: 48, color: AppColors.onSurfaceVariant),
                            const SizedBox(height: 12),
                            Text('No photos in gallery', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                          ],
                        ),
                      ),
                    )
                  else
                    GridView.builder(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: AppSpacing.sm,
                        mainAxisSpacing: AppSpacing.sm,
                        childAspectRatio: 1.0,
                      ),
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredMemories.length,
                      itemBuilder: (context, index) {
                        final memory = filteredMemories[index];
                        final isAsset = memory.imagePath.startsWith('assets/');

                        return GestureDetector(
                          onTap: () {
                            memoryCtrl.selectMemory(memory);
                            context.push(AppRoutes.memoryDetail);
                          },
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(12),
                            child: Container(
                              decoration: BoxDecoration(
                                color: AppColors.surfaceContainerHigh,
                                border: Border.all(color: AppColors.glassBorder),
                              ),
                              child: isAsset
                                  ? Image.asset(memory.imagePath, fit: BoxFit.cover)
                                  : Image.file(
                                      File(memory.imagePath),
                                      fit: BoxFit.cover,
                                      errorBuilder: (_, __, ___) => const Center(
                                        child: Icon(
                                          Icons.broken_image,
                                          color: AppColors.onSurfaceVariant,
                                        ),
                                      ),
                                    ),
                            ),
                          ),
                        ).animate().fadeIn(duration: 200.ms, delay: Duration(milliseconds: 30 * index));
                      },
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
