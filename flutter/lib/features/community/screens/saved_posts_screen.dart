import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/community_controller.dart';
import 'post_detail_screen.dart';

class SavedPostsScreen extends StatefulWidget {
  const SavedPostsScreen({super.key});

  @override
  State<SavedPostsScreen> createState() => _SavedPostsScreenState();
}

class _SavedPostsScreenState extends State<SavedPostsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadSavedPosts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Saved Posts', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
      ),
      body: community.savedPosts.isEmpty
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.bookmark_border, size: 64, color: AppColors.onSurfaceVariant),
                  const SizedBox(height: AppSpacing.sm),
                  Text('No Saved Posts', style: AppTextStyles.headlineSm()),
                  const SizedBox(height: 4),
                  Text('Tap the bookmark icon on any post in the feed to save it here.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                ],
              ),
            )
          : ListView.separated(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              itemCount: community.savedPosts.length,
              separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
              itemBuilder: (ctx, i) {
                final post = community.savedPosts[i];
                return GlassCard(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      backgroundImage: post.authorAvatar.isNotEmpty ? NetworkImage(post.authorAvatar) : null,
                      child: post.authorAvatar.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
                    ),
                    title: Text(post.caption.isNotEmpty ? post.caption : 'Saved Ride Post', style: AppTextStyles.bodyMd()),
                    subtitle: Text('By ${post.authorName} • ${post.likeCount} likes', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                    trailing: IconButton(
                      icon: const Icon(Icons.bookmark_remove, color: AppColors.circuitOrange),
                      onPressed: () => community.toggleSave(post.id),
                    ),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
