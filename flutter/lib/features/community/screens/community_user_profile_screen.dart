import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../../../core/services/database_service.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../models/friend_model.dart';
import '../models/post_model.dart';
import '../repositories/sqlite_post_repository.dart';
import 'post_detail_screen.dart';
import '../widgets/report_dialog.dart';

class CommunityUserProfileScreen extends StatefulWidget {
  final String userId;
  final String username;
  final String fullName;
  final String photoUrl;

  const CommunityUserProfileScreen({
    super.key,
    required this.userId,
    required this.username,
    required this.fullName,
    required this.photoUrl,
  });

  @override
  State<CommunityUserProfileScreen> createState() => _CommunityUserProfileScreenState();
}

class _CommunityUserProfileScreenState extends State<CommunityUserProfileScreen> {
  Map<String, dynamic>? _userData;
  List<PostModel> _userPosts = [];
  FriendshipStatus _relationStatus = FriendshipStatus.none;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    final auth = context.read<AuthController>();
    final currentUserId = auth.currentUser?.id ?? '';
    final community = context.read<CommunityController>();

    final db = await DatabaseService.instance.database;
    final uRows = await db.query('users', where: 'id = ?', whereArgs: [widget.userId], limit: 1);

    final statusRes = await community.getRelationshipStatus(widget.userId);
    final postRepo = SqlitePostRepository();
    final postsRes = await postRepo.getUserPosts(userId: widget.userId, currentUserId: currentUserId);

    if (mounted) {
      setState(() {
        _userData = uRows.isNotEmpty ? uRows.first : null;
        _relationStatus = statusRes.dataOrNull ?? FriendshipStatus.none;
        _userPosts = postsRes.dataOrNull ?? [];
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isSelf = (widget.userId == currentUserId);
    final community = context.watch<CommunityController>();

    final name = _userData?['full_name'] as String? ?? widget.fullName;
    final username = _userData?['username'] as String? ?? widget.username;
    final photo = _userData?['photo_url'] as String? ?? widget.photoUrl;
    final bio = _userData?['bio'] as String? ?? 'Passionate rider on RiderMate 2.0';
    final level = _userData?['rider_level'] as String? ?? 'Novice';
    final distance = (_userData?['distance_km'] as num? ?? 0.0).toDouble();
    final rides = (_userData?['total_rides'] as num? ?? 0).toInt();

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text(name, style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
        actions: [
          if (!isSelf)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
              color: AppColors.surfaceContainerHigh,
              onSelected: (val) async {
                if (val == 'block') {
                  await community.blockUser(widget.userId);
                  await _loadProfileData();
                } else if (val == 'report') {
                  showDialog(
                    context: context,
                    builder: (c) => ReportDialog(
                      itemId: widget.userId,
                      itemType: 'user',
                      onReport: (reason, details) => community.reportContent(
                        itemId: widget.userId,
                        itemType: 'user',
                        reason: reason,
                        details: details,
                      ),
                    ),
                  );
                }
              },
              itemBuilder: (ctx) => [
                PopupMenuItem(value: 'block', child: Text(_relationStatus == FriendshipStatus.blocked ? 'Unblock Rider' : 'Block Rider')),
                const PopupMenuItem(value: 'report', child: Text('Report Profile')),
              ],
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.circuitOrange))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                children: [
                  // Profile Avatar & Bio Card
                  GlassCard(
                    padding: const EdgeInsets.all(AppSpacing.md),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 42,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
                          child: photo.isEmpty ? const Icon(Icons.person, size: 42, color: AppColors.onSurface) : null,
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        Text(name, style: AppTextStyles.headlineMd()),
                        Text('@$username', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppColors.circuitOrange.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.circuitOrange.withValues(alpha: 0.4)),
                          ),
                          child: Text(level, style: AppTextStyles.labelCapsSm(color: AppColors.circuitOrange)),
                        ),
                        if (bio.isNotEmpty) ...[
                          const SizedBox(height: AppSpacing.sm),
                          Text(bio, style: AppTextStyles.bodyMd(color: AppColors.onSurface), textAlign: TextAlign.center),
                        ],
                        const Divider(color: AppColors.glassBorder, height: 24),

                        // Stats Summary Row
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _statItem('DISTANCE', '${distance.toStringAsFixed(1)} KM'),
                            _statItem('TOTAL RIDES', '$rides'),
                            _statItem('SAFETY', '98/100'),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.md),

                        // Relationship Action Button
                        if (!isSelf) _buildRelationActionButton(community),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // User's Shared Posts Header
                  Align(
                    alignment: Alignment.centerLeft,
                    child: Text('Posts (${_userPosts.length})', style: AppTextStyles.headlineSm()),
                  ),
                  const SizedBox(height: AppSpacing.sm),

                  if (_userPosts.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 32),
                      child: Text('No posts visible from this rider.', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _userPosts.length,
                      separatorBuilder: (_, __) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, i) {
                        final post = _userPosts[i];
                        return GlassCard(
                          padding: const EdgeInsets.all(AppSpacing.sm),
                          child: ListTile(
                            title: Text(post.caption.isNotEmpty ? post.caption : 'Shared a ride moment', style: AppTextStyles.bodyMd()),
                            subtitle: Text('${post.type.name.toUpperCase()} • ${post.likeCount} likes', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
                            trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: AppColors.onSurfaceVariant),
                            onTap: () => Navigator.of(context).push(
                              MaterialPageRoute(builder: (_) => PostDetailScreen(post: post)),
                            ),
                          ),
                        );
                      },
                    ),
                ],
              ),
            ),
    );
  }

  Widget _buildRelationActionButton(CommunityController community) {
    switch (_relationStatus) {
      case FriendshipStatus.friends:
        return Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.green),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check, color: Colors.green, size: 16),
                label: const Text('FRIENDS', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                onPressed: () {},
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              style: IconButton.styleFrom(backgroundColor: AppColors.surfaceContainerHigh),
              icon: const Icon(Icons.person_remove, color: Colors.redAccent, size: 18),
              onPressed: () async {
                await community.removeFriend(widget.userId);
                await _loadProfileData();
              },
            ),
          ],
        );

      case FriendshipStatus.requestSent:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.circuitOrange),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.schedule, color: AppColors.circuitOrange, size: 16),
            label: const Text('REQUEST SENT', style: TextStyle(color: AppColors.circuitOrange)),
            onPressed: () {},
          ),
        );

      case FriendshipStatus.requestReceived:
        return Row(
          children: [
            Expanded(
              child: ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.check, size: 16),
                label: const Text('ACCEPT REQUEST'),
                onPressed: () async {
                  final req = community.pendingRequests.firstWhere((r) => r.senderId == widget.userId);
                  await community.acceptFriendRequest(req.id);
                  await _loadProfileData();
                },
              ),
            ),
          ],
        );

      case FriendshipStatus.blocked:
        return SizedBox(
          width: double.infinity,
          child: OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Colors.redAccent),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              await community.unblockUser(widget.userId);
              await _loadProfileData();
            },
            child: const Text('UNBLOCK RIDER', style: TextStyle(color: Colors.redAccent)),
          ),
        );

      case FriendshipStatus.none:
      default:
        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.circuitOrange,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            icon: const Icon(Icons.person_add, size: 16),
            label: const Text('ADD FRIEND'),
            onPressed: () async {
              await community.sendFriendRequest(widget.userId);
              await _loadProfileData();
            },
          ),
        );
    }
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.headlineSm(color: AppColors.circuitOrange)),
      ],
    );
  }
}
