import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/controllers/auth_controller.dart';
import '../controllers/community_controller.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../widgets/report_dialog.dart';

class PostDetailScreen extends StatefulWidget {
  final PostModel post;

  const PostDetailScreen({
    super.key,
    required this.post,
  });

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  late PostModel _currentPost;
  List<CommentModel> _comments = [];
  bool _isLoadingComments = true;
  final _commentController = TextEditingController();
  CommentModel? _replyingTo;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _currentPost = widget.post;
    _loadComments();
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _loadComments() async {
    final community = context.read<CommunityController>();
    final res = await community.getComments(_currentPost.id);
    if (mounted) {
      setState(() {
        _isLoadingComments = false;
        if (res.isSuccess) {
          _comments = res.dataOrNull ?? [];
        }
      });
    }
  }

  Future<void> _sendComment() async {
    final text = _commentController.text.trim();
    if (text.isEmpty) return;

    setState(() => _isSending = true);
    final community = context.read<CommunityController>();
    final res = await community.addComment(
      _currentPost.id,
      text,
      parentCommentId: _replyingTo?.id,
    );

    if (mounted) {
      setState(() {
        _isSending = false;
        if (res.isSuccess) {
          _commentController.clear();
          _replyingTo = null;
          _currentPost = _currentPost.copyWith(commentCount: _currentPost.commentCount + 1);
        }
      });
      await _loadComments();
    }
  }

  Future<void> _deletePost() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.surfaceContainerHigh,
        title: Text('Delete Post?', style: AppTextStyles.headlineSm()),
        content: Text('Are you sure you want to delete this post? This cannot be undone.', style: AppTextStyles.bodyMd()),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('CANCEL')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('DELETE', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      final community = context.read<CommunityController>();
      await community.deletePost(_currentPost.id);
      if (mounted) context.pop();
    }
  }

  void _showReport() {
    showDialog(
      context: context,
      builder: (ctx) => ReportDialog(
        itemId: _currentPost.id,
        itemType: 'post',
        onReport: (reason, details) async {
          final community = context.read<CommunityController>();
          await community.reportContent(
            itemId: _currentPost.id,
            itemType: 'post',
            reason: reason,
            details: details,
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthController>();
    final currentUserId = auth.currentUser?.id ?? '';
    final isOwner = (_currentPost.userId == currentUserId);
    final community = context.watch<CommunityController>();

    // Synchronize post from feed if updated
    final feedPost = community.feedPosts.firstWhere((p) => p.id == _currentPost.id, orElse: () => _currentPost);

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Post', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.onSurface),
            color: AppColors.surfaceContainerHigh,
            onSelected: (val) {
              if (val == 'delete') _deletePost();
              if (val == 'report') _showReport();
              if (val == 'share') {
                community.recordShare(_currentPost.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Post link copied to clipboard! 🔗')),
                );
              }
            },
            itemBuilder: (ctx) => [
              const PopupMenuItem(value: 'share', child: Row(children: [Icon(Icons.share, size: 18), SizedBox(width: 8), Text('Share')])),
              if (isOwner)
                const PopupMenuItem(value: 'delete', child: Row(children: [Icon(Icons.delete, color: Colors.red, size: 18), SizedBox(width: 8), Text('Delete Post', style: TextStyle(color: Colors.red))]))
              else
                const PopupMenuItem(value: 'report', child: Row(children: [Icon(Icons.flag, color: Colors.orange, size: 18), SizedBox(width: 8), Text('Report Post')])),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.marginMobile),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Author Header
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 22,
                        backgroundColor: AppColors.surfaceContainerHigh,
                        backgroundImage: _currentPost.authorAvatar.isNotEmpty ? NetworkImage(_currentPost.authorAvatar) : null,
                        child: _currentPost.authorAvatar.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(_currentPost.authorName, style: AppTextStyles.headlineXs()),
                                const SizedBox(width: 6),
                                _privacyBadge(_currentPost.privacy),
                              ],
                            ),
                            Text(
                              DateFormat('MMM d, y • h:mm a').format(_currentPost.createdAt),
                              style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),

                  // Post Caption
                  if (_currentPost.caption.isNotEmpty)
                    Text(_currentPost.caption, style: AppTextStyles.bodyLg(color: AppColors.onSurface)),

                  // Media Attachment
                  if (_currentPost.mediaUrl.isNotEmpty) ...[
                    const SizedBox(height: AppSpacing.md),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.network(
                        _currentPost.mediaUrl,
                        fit: BoxFit.cover,
                        width: double.infinity,
                        errorBuilder: (context, error, _) => Container(
                          height: 160,
                          color: AppColors.surfaceContainerHigh,
                          child: const Center(child: Icon(Icons.image, size: 40, color: AppColors.onSurfaceVariant)),
                        ),
                      ),
                    ),
                  ],

                  // Ride Stats Attachment Card
                  if (_currentPost.rideStats != null) ...[
                    const SizedBox(height: AppSpacing.md),
                    Container(
                      padding: const EdgeInsets.all(AppSpacing.md),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceContainerHigh,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(color: AppColors.glassBorder),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.two_wheeler, color: AppColors.circuitOrange, size: 20),
                              const SizedBox(width: 8),
                              Text(_currentPost.rideStats!['title'] ?? 'Ride Summary', style: AppTextStyles.headlineXs()),
                            ],
                          ),
                          const Divider(color: AppColors.glassBorder, height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              _statItem('DISTANCE', '${(_currentPost.rideStats!['distance_km'] as num? ?? 0).toStringAsFixed(1)} KM'),
                              _statItem('AVG SPEED', '${(_currentPost.rideStats!['average_speed'] as num? ?? 0).toStringAsFixed(1)} KM/H'),
                              _statItem('SCORE', '${_currentPost.rideStats!['ride_score'] ?? 100} PTS'),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: AppSpacing.md),

                  // Social Interactions Action Bar
                  Row(
                    children: [
                      // Like
                      InkWell(
                        onTap: () => community.toggleLike(_currentPost.id),
                        borderRadius: BorderRadius.circular(20),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                feedPost.isLikedByMe ? Icons.favorite : Icons.favorite_border,
                                color: feedPost.isLikedByMe ? Colors.redAccent : AppColors.onSurfaceVariant,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Text('${feedPost.likeCount}', style: AppTextStyles.statLabel()),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      // Comment
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        child: Row(
                          children: [
                            const Icon(Icons.chat_bubble_outline, color: AppColors.onSurfaceVariant, size: 20),
                            const SizedBox(width: 6),
                            Text('${feedPost.commentCount}', style: AppTextStyles.statLabel()),
                          ],
                        ),
                      ),
                      const Spacer(),
                      // Save
                      IconButton(
                        icon: Icon(
                          feedPost.isSavedByMe ? Icons.bookmark : Icons.bookmark_border,
                          color: feedPost.isSavedByMe ? AppColors.circuitOrange : AppColors.onSurfaceVariant,
                        ),
                        onPressed: () => community.toggleSave(_currentPost.id),
                      ),
                      // Share
                      IconButton(
                        icon: const Icon(Icons.share_outlined, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          community.recordShare(_currentPost.id);
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Post link shared! 🚀')),
                          );
                        },
                      ),
                    ],
                  ),
                  const Divider(color: AppColors.glassBorder, height: 24),

                  // Comments Section Header
                  Text('Comments (${_comments.length})', style: AppTextStyles.headlineSm()),
                  const SizedBox(height: AppSpacing.sm),

                  if (_isLoadingComments)
                    const Center(child: Padding(padding: EdgeInsets.all(20), child: CircularProgressIndicator()))
                  else if (_comments.isEmpty)
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: Center(
                        child: Text('No comments yet. Be the first to start the conversation!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
                      ),
                    )
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _comments.length,
                      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
                      itemBuilder: (ctx, i) => _commentTile(_comments[i], currentUserId, isOwner),
                    ),
                ],
              ),
            ),
          ),

          // Bottom Reply Indicator & Comment Input Field
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 8),
            decoration: const BoxDecoration(
              color: AppColors.surfaceContainerHigh,
              border: Border(top: BorderSide(color: AppColors.glassBorder)),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (_replyingTo != null)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text('Replying to @${_replyingTo!.authorName}', style: AppTextStyles.bodyXs(color: AppColors.circuitOrange)),
                          const Spacer(),
                          GestureDetector(
                            onTap: () => setState(() => _replyingTo = null),
                            child: const Icon(Icons.close, size: 16, color: AppColors.onSurfaceVariant),
                          ),
                        ],
                      ),
                    ),
                  Row(
                    children: [
                      Expanded(
                        child: TextField(
                          controller: _commentController,
                          style: AppTextStyles.bodyMd(color: AppColors.onSurface),
                          decoration: InputDecoration(
                            hintText: _replyingTo != null ? 'Write a reply...' : 'Add a comment...',
                            hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                            filled: true,
                            fillColor: AppColors.surfaceContainerHighest,
                            contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(24), borderSide: BorderSide.none),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filled(
                        style: IconButton.styleFrom(backgroundColor: AppColors.circuitOrange),
                        icon: _isSending
                            ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                            : const Icon(Icons.send, color: Colors.white, size: 18),
                        onPressed: _isSending ? null : _sendComment,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _commentTile(CommentModel comment, String currentUserId, bool isPostOwner) {
    final isCommentAuthor = (comment.userId == currentUserId);
    final canDelete = isCommentAuthor || isPostOwner;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.sm),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHigh.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 14,
                backgroundColor: AppColors.surfaceContainerHighest,
                backgroundImage: comment.authorAvatar.isNotEmpty ? NetworkImage(comment.authorAvatar) : null,
                child: comment.authorAvatar.isEmpty ? const Icon(Icons.person, size: 14, color: AppColors.onSurface) : null,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Row(
                  children: [
                    Text(comment.authorName, style: AppTextStyles.statLabel()),
                    const SizedBox(width: 6),
                    Text(
                      DateFormat('h:mm a').format(comment.createdAt),
                      style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant),
                    ),
                  ],
                ),
              ),
              if (canDelete)
                IconButton(
                  icon: const Icon(Icons.delete_outline, size: 16, color: Colors.redAccent),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                  onPressed: () async {
                    final community = context.read<CommunityController>();
                    await community.deleteComment(comment.id, _currentPost.id);
                    await _loadComments();
                  },
                ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 4),
            child: Text(comment.text, style: AppTextStyles.bodyMd(color: AppColors.onSurface)),
          ),
          Padding(
            padding: const EdgeInsets.only(left: 36, top: 4),
            child: GestureDetector(
              onTap: () => setState(() => _replyingTo = comment),
              child: Text('Reply', style: AppTextStyles.bodyXs(color: AppColors.circuitOrange)),
            ),
          ),

          // Nested Replies
          if (comment.replies.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(left: 36, top: 8),
              child: Column(
                children: comment.replies.map((reply) {
                  return Container(
                    margin: const EdgeInsets.only(bottom: 6),
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        CircleAvatar(
                          radius: 10,
                          backgroundColor: AppColors.surfaceContainerHigh,
                          child: const Icon(Icons.person, size: 10, color: AppColors.onSurface),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reply.authorName, style: AppTextStyles.statLabel().copyWith(fontSize: 11)),
                              Text(reply.text, style: AppTextStyles.bodySm()),
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
            ),
        ],
      ),
    );
  }

  Widget _privacyBadge(PostPrivacy privacy) {
    String label;
    IconData icon;
    switch (privacy) {
      case PostPrivacy.public:
        label = 'Public';
        icon = Icons.public;
        break;
      case PostPrivacy.friends:
        label = 'Friends';
        icon = Icons.people;
        break;
      case PostPrivacy.private:
        label = 'Private';
        icon = Icons.lock;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 10, color: AppColors.onSurfaceVariant),
          const SizedBox(width: 3),
          Text(label, style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
        ],
      ),
    );
  }

  Widget _statItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: AppTextStyles.labelCapsSm(color: AppColors.onSurfaceVariant)),
        const SizedBox(height: 2),
        Text(value, style: AppTextStyles.statLabel(color: AppColors.circuitOrange)),
      ],
    );
  }
}
