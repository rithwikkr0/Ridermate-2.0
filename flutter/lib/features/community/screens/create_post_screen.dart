import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../auth/controllers/auth_controller.dart';
import '../../rides/controllers/ride_controller.dart';
import '../../rides/models/ride_engine_model.dart';
import '../../memories/controllers/memory_controller.dart';
import '../../memories/models/memory_model.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  final RideEngineModel? attachedRide;
  final MemoryModel? attachedMemory;

  const CreatePostScreen({
    super.key,
    this.attachedRide,
    this.attachedMemory,
  });

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final _captionController = TextEditingController();
  final _mediaUrlController = TextEditingController();
  PostType _selectedType = PostType.text;
  PostPrivacy _selectedPrivacy = PostPrivacy.friends;
  RideEngineModel? _selectedRide;
  MemoryModel? _selectedMemory;
  bool _isPublishing = false;

  @override
  void initState() {
    super.initState();
    if (widget.attachedRide != null) {
      _selectedRide = widget.attachedRide;
      _selectedType = PostType.ride;
      _captionController.text = 'Completed a ${_selectedRide!.distanceKm.toStringAsFixed(1)} km ride! 🏍️⚡';
    } else if (widget.attachedMemory != null) {
      _selectedMemory = widget.attachedMemory;
      _selectedType = PostType.memory;
      _captionController.text = _selectedMemory!.caption;
      if (_selectedMemory!.imagePath.isNotEmpty) {
        _mediaUrlController.text = _selectedMemory!.imagePath;
      }
    }
  }

  @override
  void dispose() {
    _captionController.dispose();
    _mediaUrlController.dispose();
    super.dispose();
  }

  Future<void> _publish() async {
    final caption = _captionController.text.trim();
    if (caption.isEmpty && _selectedRide == null && _selectedMemory == null && _mediaUrlController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please write something or attach content'), backgroundColor: Colors.redAccent),
      );
      return;
    }

    setState(() => _isPublishing = true);

    final community = context.read<CommunityController>();
    final res = await community.createPost(
      caption: caption,
      type: _selectedType,
      privacy: _selectedPrivacy,
      mediaUrl: _mediaUrlController.text.trim(),
      rideId: _selectedRide?.id,
      memoryId: _selectedMemory?.id,
    );

    if (mounted) {
      setState(() => _isPublishing = false);
      if (res.isSuccess) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post published to Community! 🚀'), backgroundColor: AppColors.circuitOrange),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed: ${res.error?.message}'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final user = auth.currentUser;
    final rideController = context.watch<RideController>();
    final memoryController = context.watch<MemoryController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Create Post', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: AppSpacing.md),
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.circuitOrange,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              ),
              onPressed: _isPublishing ? null : _publish,
              child: _isPublishing
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                  : Text('PUBLISH', style: AppTextStyles.button(color: Colors.white).copyWith(fontSize: 13)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.marginMobile),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // User Header & Privacy Selector
            Row(
              children: [
                CircleAvatar(
                  radius: 22,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: (user?.photoUrl != null && user!.photoUrl.isNotEmpty)
                      ? NetworkImage(user.photoUrl)
                      : null,
                  child: (user?.photoUrl == null || user!.photoUrl.isEmpty)
                      ? const Icon(Icons.person, color: AppColors.onSurface)
                      : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.fullName ?? user?.username ?? 'Rider', style: AppTextStyles.headlineXs()),
                    const SizedBox(height: 4),
                    // Privacy Dropdown Pill
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<PostPrivacy>(
                          value: _selectedPrivacy,
                          isDense: true,
                          dropdownColor: AppColors.surfaceContainerHigh,
                          style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange),
                          items: const [
                            DropdownMenuItem(value: PostPrivacy.friends, child: Text('👥 Friends Only')),
                            DropdownMenuItem(value: PostPrivacy.public, child: Text('🌍 Public')),
                            DropdownMenuItem(value: PostPrivacy.private, child: Text('🔒 Only Me')),
                          ],
                          onChanged: (val) {
                            if (val != null) setState(() => _selectedPrivacy = val);
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.md),

            // Post Type Chips
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  _typeChip(PostType.text, '📝 Text', Icons.text_fields),
                  _typeChip(PostType.photo, '📷 Photo', Icons.photo_camera),
                  _typeChip(PostType.ride, '🏍 Ride Stats', Icons.two_wheeler),
                  _typeChip(PostType.memory, '📸 Memory', Icons.auto_awesome),
                  _typeChip(PostType.achievement, '🏆 Milestone', Icons.emoji_events),
                ],
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Caption Text Area
            TextField(
              controller: _captionController,
              maxLines: 6,
              style: AppTextStyles.bodyLg(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Share what happened on the road...',
                hintStyle: AppTextStyles.bodyLg(color: AppColors.onSurfaceVariant),
                border: InputBorder.none,
              ),
            ),

            // Photo Input (if photo mode)
            if (_selectedType == PostType.photo) ...[
              const SizedBox(height: AppSpacing.sm),
              TextField(
                controller: _mediaUrlController,
                style: AppTextStyles.bodySm(color: AppColors.onSurface),
                decoration: InputDecoration(
                  labelText: 'Image / Media URL',
                  labelStyle: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                  prefixIcon: const Icon(Icons.link, color: AppColors.circuitOrange),
                  filled: true,
                  fillColor: AppColors.surfaceContainerHigh,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                ),
                onChanged: (_) => setState(() {}),
              ),
              if (_mediaUrlController.text.isNotEmpty) ...[
                const SizedBox(height: AppSpacing.sm),
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    _mediaUrlController.text.trim(),
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      height: 100,
                      color: AppColors.surfaceContainerHigh,
                      child: const Center(child: Text('Invalid image preview URL')),
                    ),
                  ),
                ),
              ],
            ],

            // Ride Attachment Preview / Selector
            if (_selectedType == PostType.ride) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Attach Ride:', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 6),
              if (rideController.rides.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                  child: Text('No completed rides recorded yet. Track a ride first!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedRide?.id ?? rideController.rides.first.id,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: rideController.rides.map((r) {
                    return DropdownMenuItem(
                      value: r.id,
                      child: Text('${r.title} (${r.distanceKm.toStringAsFixed(1)} km)', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    final found = rideController.rides.firstWhere((r) => r.id == val);
                    setState(() {
                      _selectedRide = found;
                      _captionController.text = 'Completed a ${found.distanceKm.toStringAsFixed(1)} km ride! 🏍️⚡';
                    });
                  },
                ),
            ],

            // Memory Attachment Preview / Selector
            if (_selectedType == PostType.memory) ...[
              const SizedBox(height: AppSpacing.sm),
              Text('Attach Memory:', style: AppTextStyles.statLabel(color: AppColors.onSurfaceVariant)),
              const SizedBox(height: 6),
              if (memoryController.memories.isEmpty)
                Container(
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(color: AppColors.surfaceContainerHigh, borderRadius: BorderRadius.circular(12)),
                  child: Text('No saved memories yet. Create one from the Journal tab!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                )
              else
                DropdownButtonFormField<String>(
                  value: _selectedMemory?.id ?? memoryController.memories.first.id,
                  dropdownColor: AppColors.surfaceContainerHigh,
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.surfaceContainerHigh,
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                  ),
                  items: memoryController.memories.map((m) {
                    return DropdownMenuItem(
                      value: m.id,
                      child: Text(m.caption.isNotEmpty ? m.caption : 'Memory ${m.id}', style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
                    );
                  }).toList(),
                  onChanged: (val) {
                    final found = memoryController.memories.firstWhere((m) => m.id == val);
                    setState(() {
                      _selectedMemory = found;
                      _captionController.text = found.caption;
                      if (found.imagePath.isNotEmpty) {
                        _mediaUrlController.text = found.imagePath;
                      }
                    });
                  },
                ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _typeChip(PostType type, String label, IconData icon) {
    final isSelected = _selectedType == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        avatar: Icon(icon, size: 16, color: isSelected ? Colors.white : AppColors.onSurfaceVariant),
        label: Text(label, style: TextStyle(color: isSelected ? Colors.white : AppColors.onSurface, fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
        selected: isSelected,
        selectedColor: AppColors.circuitOrange,
        backgroundColor: AppColors.surfaceContainerHigh,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onSelected: (_) {
          setState(() {
            _selectedType = type;
            if (type == PostType.photo && _mediaUrlController.text.isEmpty) {
              _mediaUrlController.text = 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=800';
            }
          });
        },
      ),
    );
  }
}
