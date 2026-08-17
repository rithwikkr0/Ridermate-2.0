import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/router/app_router.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';
import '../models/story_model.dart';
import 'create_post_screen.dart';
import 'post_detail_screen.dart';
import '../widgets/report_dialog.dart';

class SocialFeedScreen extends StatefulWidget {
  const SocialFeedScreen({super.key});

  @override
  State<SocialFeedScreen> createState() => _SocialFeedScreenState();
}

class _SocialFeedScreenState extends State<SocialFeedScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final auth = context.read<AuthController>();
      final community = context.read<CommunityController>();
      if (auth.currentUser != null) {
        community.refreshForUser(
          auth.currentUser!.id,
          userName: auth.currentUser!.fullName.isNotEmpty ? auth.currentUser!.fullName : auth.currentUser!.username,
          userAvatar: auth.currentUser!.photoUrl,
        );
      }
    });
  }

  void _openCreatePost() {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => const CreatePostScreen()),
    );
  }

  void _openAddStory() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Add Ride Moment (24h)', style: AppTextStyles.headlineSm()),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              style: AppTextStyles.bodyMd(),
              decoration: InputDecoration(
                hintText: 'Moment caption or thought...',
                filled: true,
                fillColor: AppColors.surfaceContainerHighest,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10), borderSide: BorderSide.none),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.circuitOrange),
            onPressed: () async {
              if (controller.text.trim().isNotEmpty) {
                final community = context.read<CommunityController>();
                await community.createStory(
                  mediaUrl: 'https://images.unsplash.com/photo-1558981403-c5f9899a28bc?w=800',
                  caption: controller.text.trim(),
                );
                if (ctx.mounted) Navigator.of(ctx).pop();
              }
            },
            child: const Text('POST MOMENT', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final auth = context.watch<AuthController>();
    final currentUserId = auth.currentUser?.id ?? '';
    final pendingCount = community.pendingRequests.length;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppColors.circuitOrange,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.edit_note, size: 22),
        label: const Text('POST', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1)),
        onPressed: _openCreatePost,
      ),
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: RadialGradient(
                center: Alignment(0.7, -0.5),
                radius: 1.0,
                colors: [Color(0x0DFF6B00), Colors.transparent],
              ),
            ),
          ),
          SafeArea(
            child: RefreshIndicator(
              color: AppColors.circuitOrange,
              onRefresh: () => community.loadFeed(refresh: true),
              child: CustomScrollView(
                slivers: [
                  // Community App Bar & Quick Actions
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.md, AppSpacing.marginMobile, 0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text('Community', style: AppTextStyles.headlineLg(color: AppColors.onSurface)),
                              Text('Connect & ride together', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                            ],
                          ),
                          Row(
                            children: [
                              // Friends Hub Icon with Badge
                              Stack(
                                children: [
                                  IconButton(
                                    style: IconButton.styleFrom(
                                      backgroundColor: AppColors.surfaceContainerHigh,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        side: const BorderSide(color: AppColors.glassBorder),
                                      ),
                                    ),
                                    icon: const Icon(Icons.people_alt_outlined, color: AppColors.onSurface, size: 20),
                                    onPressed: () => context.push(AppRoutes.friends),
                                  ),
                                  if (pendingCount > 0)
                                    Positioned(
                                      right: 4,
                                      top: 4,
                                      child: Container(
                                        padding: const EdgeInsets.all(4),
                                        decoration: const BoxDecoration(color: Colors.redAccent, shape: BoxShape.circle),
                                        child: Text(
                                          '$pendingCount',
                                          style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold),
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              const SizedBox(width: 8),
                              // Squads Icon
                              IconButton(
                                style: IconButton.styleFrom(
                                  backgroundColor: AppColors.surfaceContainerHigh,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: AppColors.glassBorder),
                                  ),
                                ),
                                icon: const Icon(Icons.groups_outlined, color: AppColors.onSurface, size: 20),
                                onPressed: () => context.push(AppRoutes.squads),
                              ),
                            ],
                          ),
                        ],
                      ).animate().fadeIn(),
                    ),
                  ),

                  // Stories / Ride Moments Rail
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.md),
                      child: SizedBox(
                        height: 96,
                        child: ListView(
                          scrollDirection: Axis.horizontal,
                          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.marginMobile),
                          children: [
                            // "Add Story" Action Item
                            GestureDetector(
                              onTap: _openAddStory,
                              child: Padding(
                                padding: const EdgeInsets.only(right: 12),
                                child: Column(
                                  children: [
                                    Container(
                                      width: 58,
                                      height: 58,
                                      decoration: BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: AppColors.surfaceContainerHigh,
                                        border: Border.all(color: AppColors.circuitOrange, width: 2, style: BorderStyle.solid),
                                      ),
                                      child: const Icon(Icons.add, color: AppColors.circuitOrange, size: 26),
                                    ),
                                    const SizedBox(height: 4),
                                    Text('My Moment', style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
                                  ],
                                ),
                              ),
                            ),
                            // Real Story Items
                            ...community.stories.map((story) => _storyItem(story)),
                          ],
                        ),
                      ).animate().fadeIn(delay: 100.ms),
                    ),
                  ),

                  // Filter Chips (All, Rides, Memories, Photos, Milestones)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, AppSpacing.sm, AppSpacing.marginMobile, AppSpacing.sm),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: [
                            _filterChip('All Feed', null, community),
                            _filterChip('🏍 Rides', PostType.ride, community),
                            _filterChip('📸 Memories', PostType.memory, community),
                            _filterChip('📷 Photos', PostType.photo, community),
                            _filterChip('🏆 Milestones', PostType.achievement, community),
                          ],
                        ),
                      ),
                    ),
                  ),

                  // Feed Posts or Empty Placeholder
                  if (community.isLoadingFeed && community.feedPosts.isEmpty)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator(color: AppColors.circuitOrange)),
                    )
                  else if (community.feedPosts.isEmpty)
                    SliverFillRemaining(
                      hasScrollBody: false,
                      child: Center(
                        child: Padding(
                          padding: const EdgeInsets.all(AppSpacing.xl),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(Icons.dynamic_feed_rounded, size: 64, color: AppColors.onSurfaceVariant),
                              const SizedBox(height: AppSpacing.md),
                              Text('No Posts Yet', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
                              const SizedBox(height: AppSpacing.xs),
                              Text(
                                'Be the first rider to share a journey, photo, or ride memory with your friends!',
                                style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                                textAlign: TextAlign.center,
                              ),
                              const SizedBox(height: AppSpacing.lg),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.circuitOrange,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                                ),
                                icon: const Icon(Icons.add),
                                label: const Text('CREATE FIRST POST'),
                                onPressed: _openCreatePost,
                              ),
                            ],
                          ),
                        ),
                      ),
                    )
                  else
                    SliverPadding(
                      padding: const EdgeInsets.fromLTRB(AppSpacing.marginMobile, 0, AppSpacing.marginMobile, 80),
                      sliver: SliverList(
                        delegate: SliverChildBuilderDelegate(
                          (context, index) {
                            final post = community.feedPosts[index];
                            return _postCard(post, currentUserId, community);
                          },
                          childCount: community.feedPosts.length,
                        ),
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

  Widget _filterChip(String label, PostType? type, CommunityController community) {
    final isSelected = community.activeFilter == type;
    return Padding(
      padding: const EdgeInsets.only(right: 8),
      child: FilterChip(
        label: Text(label),
        selected: isSelected,
        selectedColor: AppColors.circuitOrange,
        backgroundColor: AppColors.surfaceContainerHigh,
        labelStyle: TextStyle(
          color: isSelected ? Colors.white : AppColors.onSurfaceVariant,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        onSelected: (_) => community.loadFeed(filter: type),
      ),
    );
  }

  Widget _storyItem(StoryModel story) {
    return Padding(
      padding: const EdgeInsets.only(right: 12),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.circuitOrange, width: 2.5),
            ),
            child: ClipOval(
              child: Image.network(
                story.mediaUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, _) => Container(
                  color: AppColors.surfaceContainerHigh,
                  child: const Icon(Icons.person, color: AppColors.onSurface),
                ),
              ),
            ),
          ),
          const SizedBox(height: 4),
          SizedBox(
            width: 60,
            child: Text(
              story.authorName,
              style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _postCard(PostModel post, String currentUserId, CommunityController community) {
    final isOwner = (post.userId == currentUserId);

    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.md),
      child: GlassCard(
        padding: const EdgeInsets.all(AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Post Author Header
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppColors.surfaceContainerHigh,
                  backgroundImage: post.authorAvatar.isNotEmpty ? NetworkImage(post.authorAvatar) : null,
                  child: post.authorAvatar.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(post.authorName, style: AppTextStyles.headlineXs()),
                          const SizedBox(width: 6),
                          _privacyBadge(post.privacy),
                        ],
                      ),
                      Text(
                        _formatTimeAgo(post.createdAt),
                        style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                      ),
                    ],
                  ),
                ),
                PopupMenuButton<String>(
                  icon: const Icon(Icons.more_horiz, color: AppColors.onSurfaceVariant),
                  color: AppColors.surfaceContainerHigh,
                  onSelected: (val) {
                    if (val == 'delete') community.deletePost(post.id);
                    if (val == 'report') {
                      showDialog(
                        context: context,
                        builder: (ctx) => ReportDialog(
                          itemId: post.id,
                          itemType: 'post',
                          onReport: (reason, details) => community.reportContent(
                            itemId: post.id,
                            itemType: 'post',
                            reason: reason,
                            details: details,
                          ),
                        ),
                      );
                    }
                  },
                  itemBuilder: (ctx) => [
                    if (isOwner)
                      const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete', style: TextStyle(color: Colors.red))]))
                    else
                      const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Report')])),
                  ],
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // Post Caption
            if (post.caption.isNotEmpty)
              GestureDetector(
                onTap: () => _openPostDetail(post),
                child: Text(post.caption, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
              ),

            // Photo Attachment
            if (post.mediaUrl.isNotEmpty) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _openPostDetail(post),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    post.mediaUrl,
                    height: 180,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, _) => Container(
                      height: 120,
                      color: AppColors.surfaceContainerHigh,
                      child: const Center(child: Icon(Icons.image_not_supported, color: AppColors.onSurfaceVariant)),
                    ),
                  ),
                ),
              ),
            ],

            // Ride Stats Card (if ride post)
            if (post.rideStats != null) ...[
              const SizedBox(height: AppSpacing.sm),
              GestureDetector(
                onTap: () => _openPostDetail(post),
                child: Container(
                  padding: const EdgeInsets.all(AppSpacing.sm),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceContainerHigh,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.glassBorder),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _feedStat('DIST', '${(post.rideStats!['distance_km'] as num? ?? 0).toStringAsFixed(1)} KM'),
                      _feedStat('AVG', '${(post.rideStats!['average_speed'] as num? ?? 0).toStringAsFixed(1)} KM/H'),
                      _feedStat('SCORE', '${post.rideStats!['ride_score'] ?? 100} PTS'),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.sm),

            // Social Actions (Like, Comment, Save, Share)
            Row(
              children: [
                // Like Button
                InkWell(
                  onTap: () => community.toggleLike(post.id),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        Icon(
                          post.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                          color: post.isLikedByMe ? Colors.redAccent : AppColors.onSurfaceVariant,
                          size: 18,
                        ),
                        const SizedBox(width: 4),
                        Text('${post.likeCount}', style: AppTextStyles.bodyXs(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Comment Button
                InkWell(
                  onTap: () => _openPostDetail(post),
                  borderRadius: BorderRadius.circular(16),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant, size: 18),
                        const SizedBox(width: 4),
                        Text('${post.commentCount}', style: AppTextStyles.bodyXs(color: AppColors.onSurface)),
                      ],
                    ),
                  ),
                ),
                const Spacer(),
                // Save Button
                IconButton(
                  icon: Icon(
                    post.isSavedByMe ? Icons.bookmark : Icons.bookmark_border,
                    color: post.isSavedByMe ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                    size: 20,
                  ),
                  onPressed: () => community.toggleSave(post.id),
                ),
                // Share Button
                IconButton(
                  icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant, size: 20),
                  onPressed: () {
                    community.recordShare(post.id);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Post link shared! 🚀')),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _openPostDetail(PostModel post) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
    );
  }

  Widget _privacyBadge(PostPrivacy privacy) {
    IconData icon;
    switch (privacy) {
      case PostPrivacy.public:
        icon = Icons.public;
        break;
      case PostPrivacy.friends:
        icon = Icons.people;
        break;
      case PostPrivacy.private:
        icon = Icons.lock;
        break;
    }
    return Icon(icon, size: 12, color: AppColors.onSurfaceVariant);
  }

  Widget _feedStat(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
      ],
    );
  }

  String _formatTimeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
