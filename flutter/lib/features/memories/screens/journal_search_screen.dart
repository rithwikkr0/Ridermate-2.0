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
import '../../../core/router/app_router.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../features/auth/controllers/auth_controller.dart';
import '../controllers/memory_controller.dart';

class JournalSearchScreen extends StatefulWidget {
  const JournalSearchScreen({super.key});

  @override
  State<JournalSearchScreen> createState() => _JournalSearchScreenState();
}

class _JournalSearchScreenState extends State<JournalSearchScreen> {
  final _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearch(String val) {
    setState(() {
      _query = val;
    });
    final authCtrl = context.read<AuthController>();
    final userId = authCtrl.currentUser?.id ?? 'default_user';
    context.read<MemoryController>().searchMemories(val, userId);
  }

  @override
  Widget build(BuildContext context) {
    final memoryCtrl = context.watch<MemoryController>();
    final memories = memoryCtrl.memories;

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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: AppSpacing.md),
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
                        onPressed: () => context.pop(),
                      ),
                      Expanded(
                        child: RmTextField(
                          controller: _searchController,
                          hintText: 'Search memories caption or location...',
                          prefixIcon: Icons.search,
                          onChanged: _onSearch,
                        ),
                      ),
                    ],
                  ).animate().fadeIn(),
                  const SizedBox(height: AppSpacing.lg),
                  Text(
                    _query.isEmpty ? 'ALL MEMORIES (${memories.length})' : 'SEARCH RESULTS (${memories.length})',
                    style: AppTextStyles.labelCaps(color: AppColors.onSurfaceVariant),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Expanded(
                    child: memories.isEmpty
                        ? Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                const Icon(Icons.search_off, size: 48, color: AppColors.onSurfaceVariant),
                                const SizedBox(height: 12),
                                Text(
                                  _query.isEmpty ? 'No memories found' : 'No memories match "$_query"',
                                  style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                ),
                              ],
                            ),
                          )
                        : ListView.builder(
                            itemCount: memories.length,
                            itemBuilder: (context, index) {
                              final memory = memories[index];
                              final isAsset = memory.imagePath.startsWith('assets/');

                              return Padding(
                                padding: const EdgeInsets.only(bottom: AppSpacing.md),
                                child: GlassCard(
                                  onPressed: () {
                                    memoryCtrl.selectMemory(memory);
                                    context.push(AppRoutes.memoryDetail);
                                  },
                                  child: Padding(
                                    padding: const EdgeInsets.all(AppSpacing.md),
                                    child: Row(
                                      children: [
                                        ClipRRect(
                                          borderRadius: BorderRadius.circular(12),
                                          child: SizedBox(
                                            width: 64,
                                            height: 64,
                                            child: isAsset
                                                ? Image.asset(memory.imagePath, fit: BoxFit.cover)
                                                : Image.file(
                                                    File(memory.imagePath),
                                                    fit: BoxFit.cover,
                                                    errorBuilder: (context, error, stackTrace) => const Icon(
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
                                            children: [
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                children: [
                                                  Text(
                                                    _formatDate(memory.createdAt),
                                                    style: AppTextStyles.labelCaps(color: AppColors.circuitOrange),
                                                  ),
                                                  if (memory.rideDistance != null)
                                                    Text(
                                                      GeoUtils.formatDistance(memory.rideDistance!),
                                                      style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                                                    ),
                                                ],
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                memory.caption.isNotEmpty ? memory.caption : 'Memory',
                                                style: AppTextStyles.bodyLg(color: AppColors.onSurface),
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                              if (memory.locationName != null && memory.locationName!.isNotEmpty) ...[
                                                const SizedBox(height: 2),
                                                Text(
                                                  memory.locationName!,
                                                  style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant),
                                                  maxLines: 1,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                              ],
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ).animate().fadeIn(delay: Duration(milliseconds: 50 * index));
                            },
                          ),
                  ),
                ],
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
    return '${months[local.month - 1]} ${local.day}';
  }
}
