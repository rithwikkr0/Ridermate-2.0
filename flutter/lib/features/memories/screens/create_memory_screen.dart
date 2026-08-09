import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/widgets/rm_text_field.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../../../features/rides/controllers/ride_controller.dart';
import '../../../features/rides/models/ride_engine_model.dart';
import '../controllers/memory_controller.dart';
import '../models/memory_model.dart';

class CreateMemoryScreen extends StatefulWidget {
  const CreateMemoryScreen({super.key});

  @override
  State<CreateMemoryScreen> createState() => _CreateMemoryScreenState();
}

class _CreateMemoryScreenState extends State<CreateMemoryScreen> {
  late TextEditingController _captionController;
  late TextEditingController _locationNameController;

  @override
  void initState() {
    super.initState();
    final memoryCtrl = context.read<MemoryController>();
    if (memoryCtrl.draftId == null) {
      memoryCtrl.resetDraft();
    }
    _captionController = TextEditingController(text: memoryCtrl.draftCaption);
    _locationNameController =
        TextEditingController(text: memoryCtrl.draftLocationName ?? '');
  }

  @override
  void dispose() {
    _captionController.dispose();
    _locationNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final rideCtrl = context.watch<RideController>();
    final authCtrl = context.watch<AuthController>();
    final userId = authCtrl.currentUser?.id ?? 'default_user';

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      body: Stack(
        children: [
          // Radial background gradient
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
                  // App bar header
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Text(
                        memoryCtrl.draftId == null ? 'Create Memory' : 'Edit Memory',
                        style: AppTextStyles.headlineMd(color: AppColors.onSurface),
                      ),
                    ],
                  ).animate().fadeIn(),

                  const SizedBox(height: AppSpacing.md),

                  // ── PHOTO SECTION ─────────────────────────────────────
                  Text(
                    'PHOTO',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (memoryCtrl.draftImagePath == null)
                    GlassCard(
                      child: Padding(
                        padding: const EdgeInsets.all(24),
                        child: Column(
                          children: [
                            const Icon(
                              Icons.add_a_photo_outlined,
                              size: 48,
                              color: AppColors.circuitOrange,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Add a photo to your memory',
                              style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                            ),
                            const SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton.icon(
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppColors.circuitOrange,
                                    foregroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.camera_alt, size: 18),
                                  label: const Text('Take Photo'),
                                  onPressed: () => memoryCtrl.captureFromCamera(),
                                ),
                                const SizedBox(width: 12),
                                OutlinedButton.icon(
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppColors.onSurface,
                                    side: BorderSide(color: AppColors.glassBorder),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(Icons.photo_library, size: 18),
                                  label: const Text('Gallery'),
                                  onPressed: () => memoryCtrl.pickFromGallery(),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(delay: 50.ms)
                  else
                    ClipRRect(
                      borderRadius: BorderRadius.circular(20),
                      child: Stack(
                        children: [
                          Container(
                            height: 240,
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceContainerHigh,
                              border: Border.all(color: AppColors.glassBorder),
                            ),
                            child: memoryCtrl.draftImagePath!.startsWith('assets/')
                                ? Image.asset(memoryCtrl.draftImagePath!, fit: BoxFit.cover)
                                : Image.file(File(memoryCtrl.draftImagePath!), fit: BoxFit.cover),
                          ),
                          Positioned(
                            top: 12,
                            right: 12,
                            child: CircleAvatar(
                              backgroundColor: Colors.black.withValues(alpha: 0.7),
                              child: IconButton(
                                icon: const Icon(Icons.delete_outline, color: Colors.white),
                                onPressed: () => memoryCtrl.removeSelectedImage(),
                              ),
                            ),
                          ),
                          Positioned(
                            bottom: 12,
                            right: 12,
                            child: Row(
                              children: [
                                CircleAvatar(
                                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                                  child: IconButton(
                                    icon: const Icon(Icons.camera_alt, color: Colors.white, size: 18),
                                    onPressed: () => memoryCtrl.captureFromCamera(),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                CircleAvatar(
                                  backgroundColor: Colors.black.withValues(alpha: 0.7),
                                  child: IconButton(
                                    icon: const Icon(Icons.photo_library, color: Colors.white, size: 18),
                                    onPressed: () => memoryCtrl.pickFromGallery(),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ).animate().fadeIn(delay: 50.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── CAPTION SECTION ───────────────────────────────────
                  Text(
                    'CAPTION',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  RmTextField(
                    controller: _captionController,
                    hintText: 'Write something about this ride...',
                    maxLines: 3,
                    prefixIcon: Icons.edit_note,
                    onChanged: (val) => memoryCtrl.setCaption(val),
                  ).animate().fadeIn(delay: 100.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── LOCATION SECTION ──────────────────────────────────
                  Text(
                    'LOCATION',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      memoryCtrl.draftLocationName ??
                                          (memoryCtrl.draftLatitude != null
                                              ? '${memoryCtrl.draftLatitude!.toStringAsFixed(4)}, ${memoryCtrl.draftLongitude!.toStringAsFixed(4)}'
                                              : 'No location selected'),
                                      style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                                    ),
                                    if (memoryCtrl.draftLatitude != null)
                                      Text(
                                        'GPS: ${memoryCtrl.draftLatitude!.toStringAsFixed(5)}, ${memoryCtrl.draftLongitude!.toStringAsFixed(5)}',
                                        style: AppTextStyles.labelCapsSm(
                                            color: AppColors.circuitOrange),
                                      ),
                                  ],
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  foregroundColor: AppColors.circuitOrange,
                                  elevation: 0,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: BorderSide(color: AppColors.glassBorder),
                                  ),
                                ),
                                icon: memoryCtrl.isLocating
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          strokeWidth: 2,
                                          color: AppColors.circuitOrange,
                                        ),
                                      )
                                    : const Icon(Icons.my_location, size: 16),
                                label: Text(memoryCtrl.isLocating ? 'Locating...' : 'Use Current Location'),
                                onPressed: memoryCtrl.isLocating
                                    ? null
                                    : () async {
                                        await memoryCtrl.fetchCurrentLocation();
                                        if (memoryCtrl.draftLocationName != null) {
                                          _locationNameController.text =
                                              memoryCtrl.draftLocationName!;
                                        }
                                      },
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          RmTextField(
                            controller: _locationNameController,
                            hintText: 'Custom location name (optional)',
                            prefixIcon: Icons.place_outlined,
                            onChanged: (val) {
                              memoryCtrl.setLocation(
                                memoryCtrl.draftLatitude,
                                memoryCtrl.draftLongitude,
                                val.isEmpty ? null : val,
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 150.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── ASSOCIATE RIDE SECTION ─────────────────────────────
                  Text(
                    'ASSOCIATE RIDE',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownButtonFormField<String?>(
                            value: memoryCtrl.draftRideId,
                            decoration: const InputDecoration(
                              labelText: 'Select Ride',
                              prefixIcon: Icon(Icons.directions_bike, color: AppColors.circuitOrange),
                              border: InputBorder.none,
                            ),
                            dropdownColor: AppColors.surfaceContainerHigh,
                            style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                            items: [
                              const DropdownMenuItem<String?>(
                                value: null,
                                child: Text('No Associated Ride'),
                              ),
                              ...rideCtrl.rides.map((ride) {
                                return DropdownMenuItem<String?>(
                                  value: ride.id,
                                  child: Text(
                                    '${ride.title} (${ride.distanceKm.toStringAsFixed(1)} km)',
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                );
                              }),
                            ],
                            onChanged: (String? rideId) {
                              if (rideId == null) {
                                memoryCtrl.setRide(null);
                              } else {
                                final selected = rideCtrl.rides.firstWhere(
                                  (r) => r.id == rideId,
                                  orElse: () => RideEngineModel(
                                    id: rideId,
                                    title: 'Selected Ride',
                                    vehicle: '',
                                    startTime: DateTime.now(),
                                    duration: Duration.zero,
                                    distanceKm: 0,
                                    averageSpeedKmh: 0,
                                    maxSpeedKmh: 0,
                                    elevationMeters: 0,
                                    caloriesBurned: 0,
                                    weather: '',
                                    routePoints: const [],
                                    rideScore: 100,
                                  ),
                                );
                                memoryCtrl.setRide(selected);
                              }
                            },
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(delay: 200.ms),

                  const SizedBox(height: AppSpacing.lg),

                  // ── PRIVACY SECTION ───────────────────────────────────
                  Text(
                    'PRIVACY',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  GlassCard(
                    child: Padding(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: MemoryPrivacy.values.map((privacy) {
                          final isSelected = memoryCtrl.draftPrivacy == privacy;
                          final String label;
                          final IconData icon;
                          switch (privacy) {
                            case MemoryPrivacy.private:
                              label = 'Private';
                              icon = Icons.lock_outline;
                            case MemoryPrivacy.friends:
                              label = 'Friends';
                              icon = Icons.people_outline;
                            case MemoryPrivacy.public:
                              label = 'Public';
                              icon = Icons.public;
                          }
                          return ChoiceChip(
                            avatar: Icon(
                              icon,
                              size: 16,
                              color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
                            ),
                            label: Text(
                              label,
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
                            onSelected: (_) => memoryCtrl.setPrivacy(privacy),
                          );
                        }).toList(),
                      ),
                    ),
                  ).animate().fadeIn(delay: 250.ms),

                  const SizedBox(height: AppSpacing.xl),

                  // ── SAVE BUTTON ───────────────────────────────────────
                  if (memoryCtrl.memoryError != null) ...[
                    Text(
                      memoryCtrl.memoryError!,
                      style: AppTextStyles.bodySm(color: AppColors.error),
                    ),
                    const SizedBox(height: 12),
                  ],

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.circuitOrange,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 4,
                      ),
                      onPressed: (!memoryCtrl.canSaveDraft ||
                              memoryCtrl.memoryState == MemoryState.saving)
                          ? null
                          : () async {
                              final success = await memoryCtrl.saveMemory(userId);
                              if (success && context.mounted) {
                                context.pop();
                              }
                            },
                      child: memoryCtrl.memoryState == MemoryState.saving
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : Text(
                              memoryCtrl.draftId == null ? 'SAVE MEMORY' : 'UPDATE MEMORY',
                              style: AppTextStyles.headlineMd(color: Colors.white),
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
