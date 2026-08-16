import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/real_map_view.dart';
import '../../../core/router/app_router.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_model.dart';

class MemoryMapScreen extends StatefulWidget {
  const MemoryMapScreen({super.key});

  @override
  State<MemoryMapScreen> createState() => _MemoryMapScreenState();
}

class _MemoryMapScreenState extends State<MemoryMapScreen> {
  MemoryModel? _tappedMemory;

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final geoMemories = memoryCtrl.memories
        .where((m) => m.latitude != null && m.longitude != null)
        .toList();

    final markers = geoMemories.map((mem) {
      final point = LatLng(mem.latitude!, mem.longitude!);
      final isSelected = _tappedMemory?.id == mem.id;

      return Marker(
        point: point,
        width: isSelected ? 56 : 44,
        height: isSelected ? 56 : 44,
        child: GestureDetector(
          onTap: () {
            setState(() {
              _tappedMemory = mem;
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isSelected ? AppColors.circuitOrange : AppColors.surfaceDark,
              border: Border.all(
                color: isSelected ? Colors.white : AppColors.circuitOrange,
                width: 2,
              ),
              boxShadow: const [
                BoxShadow(
                  color: Color(0x66FF6B00),
                  blurRadius: 10,
                  offset: Offset(0, 4),
                ),
              ],
            ),
            child: ClipOval(
              child: mem.imagePath.startsWith('assets/')
                  ? Image.asset(mem.imagePath, fit: BoxFit.cover)
                  : Image.file(
                      File(mem.imagePath),
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const Icon(
                        Icons.photo_camera,
                        color: Colors.white,
                        size: 20,
                      ),
                    ),
            ),
          ),
        ),
      );
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Real OpenStreetMap view with custom memory photo markers
          RealMapView(
            initialZoom: 13.0,
            showControls: true,
            extraMarkers: markers,
          ),

          // Header Bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Row(
                children: [
                  CircleAvatar(
                    backgroundColor: Colors.black.withValues(alpha: 0.6),
                    child: IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () => context.pop(),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceDark.withValues(alpha: 0.8),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: AppColors.glassBorder),
                    ),
                    child: Text(
                      'Memory Map (${geoMemories.length})',
                      style: AppTextStyles.headlineSm(color: AppColors.onSurface),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // Tapped memory popup card
          if (_tappedMemory != null)
            Positioned(
              left: AppSpacing.marginMobile,
              right: AppSpacing.marginMobile,
              bottom: AppSpacing.marginMobile + 16,
              child: GlassCard(
                onPressed: () {
                  memoryCtrl.selectMemory(_tappedMemory!);
                  context.push(AppRoutes.memoryDetail);
                },
                child: Padding(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  child: Row(
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: SizedBox(
                          width: 60,
                          height: 60,
                          child: _tappedMemory!.imagePath.startsWith('assets/')
                              ? Image.asset(_tappedMemory!.imagePath, fit: BoxFit.cover)
                              : Image.file(
                                  File(_tappedMemory!.imagePath),
                                  fit: BoxFit.cover,
                                  errorBuilder: (_, __, ___) => const Icon(
                                    Icons.photo,
                                    color: AppColors.onSurfaceVariant,
                                  ),
                                ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              _tappedMemory!.caption.isNotEmpty
                                  ? _tappedMemory!.caption
                                  : 'Ride Memory',
                              style: AppTextStyles.bodyLg(color: Colors.white),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _tappedMemory!.locationName ?? 'Geo-tagged location',
                              style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_ios,
                            size: 16, color: AppColors.circuitOrange),
                        onPressed: () {
                          memoryCtrl.selectMemory(_tappedMemory!);
                          context.push(AppRoutes.memoryDetail);
                        },
                      ),
                    ],
                  ),
                ),
              ).animate().slideY(begin: 0.3).fadeIn(),
            ),
        ],
      ),
    );
  }
}
