import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/glass_card.dart';
import '../controllers/community_controller.dart';
import 'community_user_profile_screen.dart';
import '../widgets/report_dialog.dart';

class FriendsHomeScreen extends StatefulWidget {
  const FriendsHomeScreen({super.key});

  @override
  State<FriendsHomeScreen> createState() => _FriendsHomeScreenState();
}

class _FriendsHomeScreenState extends State<FriendsHomeScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _searchResults = [];
  bool _isSearching = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CommunityController>().loadFriends();
      context.read<CommunityController>().loadSuggestedUsers();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _performSearch(String query) async {
    if (query.trim().isEmpty) {
      setState(() {
        _searchResults = [];
        _isSearching = false;
      });
      return;
    }

    setState(() => _isSearching = true);
    final community = context.read<CommunityController>();
    final results = await community.searchUsers(query);
    if (mounted) {
      setState(() {
        _searchResults = results;
      });
    }
  }

  void _openUserProfile(String userId, String username, String fullName, String photoUrl) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => CommunityUserProfileScreen(
          userId: userId,
          username: username,
          fullName: fullName,
          photoUrl: photoUrl,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final community = context.watch<CommunityController>();
    final pendingCount = community.pendingRequests.length;

    return Scaffold(
      backgroundColor: AppColors.surfaceContainerLowest,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.onSurface),
          onPressed: () => context.pop(),
        ),
        title: Text('Friends Hub', style: AppTextStyles.headlineSm(color: AppColors.onSurface)),
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabAlignment: TabAlignment.start,
          indicatorColor: AppColors.circuitOrange,
          labelColor: AppColors.circuitOrange,
          unselectedLabelColor: AppColors.onSurfaceVariant,
          labelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
          tabs: [
            Tab(text: 'Friends (${community.friends.length})'),
            Tab(
              child: Row(
                children: [
                  const Text('Requests'),
                  if (pendingCount > 0) ...[
                    const SizedBox(width: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.redAccent, borderRadius: BorderRadius.circular(10)),
                      child: Text('$pendingCount', style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ],
              ),
            ),
            Tab(text: 'Sent (${community.sentRequests.length})'),
            Tab(text: 'Find Riders (${community.suggestedUsers.length})'),
            Tab(text: 'Blocked (${community.blockedUsers.length})'),
          ],
        ),
      ),
      body: Column(
        children: [
          // Search Input Bar
          Padding(
            padding: const EdgeInsets.all(AppSpacing.marginMobile),
            child: TextField(
              controller: _searchController,
              onChanged: _performSearch,
              style: AppTextStyles.bodyMd(color: AppColors.onSurface),
              decoration: InputDecoration(
                hintText: 'Search riders by name or username...',
                hintStyle: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant),
                prefixIcon: const Icon(Icons.search, color: AppColors.circuitOrange),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear, size: 18, color: AppColors.onSurfaceVariant),
                        onPressed: () {
                          _searchController.clear();
                          _performSearch('');
                        },
                      )
                    : null,
                filled: true,
                fillColor: AppColors.surfaceContainerHigh,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              ),
            ),
          ),

          // Search Results Overlay or Tabs View
          Expanded(
            child: _isSearching && _searchController.text.isNotEmpty
                ? _buildSearchResults(community)
                : TabBarView(
                    controller: _tabController,
                    children: [
                      _buildFriendsTab(community),
                      _buildRequestsTab(community),
                      _buildSentTab(community),
                      _buildFindRidersTab(community),
                      _buildBlockedTab(community),
                    ],
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(CommunityController community) {
    if (_searchResults.isEmpty) {
      return Center(
        child: Text('No riders found for "${_searchController.text}"', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: _searchResults.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final u = _searchResults[i];
        final uid = u['id'] as String;
        final name = u['full_name'] as String? ?? u['username'] as String? ?? 'Rider';
        final username = u['username'] as String? ?? 'rider';
        final photo = u['photo_url'] as String? ?? '';

        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
            ),
            title: Text(name, style: AppTextStyles.headlineXs()),
            subtitle: Text('@$username', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.circuitOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.person_add, size: 16),
              label: const Text('Add', style: TextStyle(fontSize: 12)),
              onPressed: () async {
                final res = await community.sendFriendRequest(uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'Friend request sent to $name!' : 'Failed: ${res.error?.message}'),
                      backgroundColor: res.isSuccess ? AppColors.circuitOrange : Colors.red,
                    ),
                  );
                }
              },
            ),
            onTap: () => _openUserProfile(uid, username, name, photo),
          ),
        );
      },
    );
  }

  Widget _buildFriendsTab(CommunityController community) {
    if (community.friends.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.people_outline, size: 56, color: AppColors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text('No Friends Yet', style: AppTextStyles.headlineSm()),
            const SizedBox(height: 4),
            Text('Search or discover riders in the "Find Riders" tab!', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: community.friends.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final f = community.friends[i];
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: f.photoUrl.isNotEmpty ? NetworkImage(f.photoUrl) : null,
              child: f.photoUrl.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
            ),
            title: Text(f.fullName, style: AppTextStyles.headlineXs()),
            subtitle: Text('@${f.username} • ${f.distanceKm.toStringAsFixed(0)} km', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            trailing: PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AppColors.onSurfaceVariant),
              color: AppColors.surfaceContainerHigh,
              onSelected: (val) async {
                if (val == 'remove') {
                  final ok = await showDialog<bool>(
                    context: context,
                    builder: (c) => AlertDialog(
                      backgroundColor: AppColors.surfaceContainerHigh,
                      title: Text('Remove ${f.fullName}?', style: AppTextStyles.headlineSm()),
                      content: const Text('Are you sure you want to remove this friend?'),
                      actions: [
                        TextButton(onPressed: () => Navigator.of(c).pop(false), child: const Text('CANCEL')),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
                          onPressed: () => Navigator.of(c).pop(true),
                          child: const Text('REMOVE', style: TextStyle(color: Colors.white)),
                        ),
                      ],
                    ),
                  );
                  if (ok == true) community.removeFriend(f.friendId);
                } else if (val == 'block') {
                  community.blockUser(f.friendId);
                } else if (val == 'report') {
                  showDialog(
                    context: context,
                    builder: (c) => ReportDialog(
                      itemId: f.friendId,
                      itemType: 'user',
                      onReport: (reason, details) => community.reportContent(itemId: f.friendId, itemType: 'user', reason: reason, details: details),
                    ),
                  );
                }
              },
              itemBuilder: (c) => [
                const PopupMenuItem(value: 'remove', child: Text('Remove Friend', style: TextStyle(color: Colors.redAccent))),
                const PopupMenuItem(value: 'block', child: Text('Block Rider')),
                const PopupMenuItem(value: 'report', child: Text('Report Rider')),
              ],
            ),
            onTap: () => _openUserProfile(f.friendId, f.username, f.fullName, f.photoUrl),
          ),
        );
      },
    );
  }

  Widget _buildRequestsTab(CommunityController community) {
    if (community.pendingRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.mark_email_read_outlined, size: 56, color: AppColors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text('No Pending Requests', style: AppTextStyles.headlineSm()),
            const SizedBox(height: 4),
            Text('When someone sends you a friend request, it will appear here.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: community.pendingRequests.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final req = community.pendingRequests[i];
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: req.senderPhotoUrl.isNotEmpty ? NetworkImage(req.senderPhotoUrl) : null,
              child: req.senderPhotoUrl.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
            ),
            title: Text(req.senderName, style: AppTextStyles.headlineXs()),
            subtitle: const Text('Sent you a friend request', style: TextStyle(fontSize: 11, color: AppColors.circuitOrange)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                IconButton(
                  icon: const Icon(Icons.close, color: Colors.redAccent),
                  onPressed: () => community.rejectFriendRequest(req.id),
                ),
                IconButton.filled(
                  style: IconButton.styleFrom(backgroundColor: Colors.green),
                  icon: const Icon(Icons.check, color: Colors.white),
                  onPressed: () => community.acceptFriendRequest(req.id),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSentTab(CommunityController community) {
    if (community.sentRequests.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.send_outlined, size: 56, color: AppColors.onSurfaceVariant),
            const SizedBox(height: AppSpacing.sm),
            Text('No Sent Requests', style: AppTextStyles.headlineSm()),
            const SizedBox(height: 4),
            Text('Requests you have sent to other riders will appear here.', style: AppTextStyles.bodySm(color: AppColors.onSurfaceVariant)),
          ],
        ),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: community.sentRequests.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final req = community.sentRequests[i];
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: req.senderPhotoUrl.isNotEmpty ? NetworkImage(req.senderPhotoUrl) : null,
              child: req.senderPhotoUrl.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
            ),
            title: Text(req.senderName, style: AppTextStyles.headlineXs()),
            subtitle: const Text('Waiting for response...', style: TextStyle(fontSize: 11, color: AppColors.onSurfaceVariant)),
            trailing: TextButton(
              onPressed: () => community.cancelFriendRequest(req.id),
              child: const Text('CANCEL', style: TextStyle(color: Colors.redAccent, fontSize: 12)),
            ),
          ),
        );
      },
    );
  }

  Widget _buildFindRidersTab(CommunityController community) {
    if (community.suggestedUsers.isEmpty) {
      return const Center(child: Text('No suggested riders right now.'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: community.suggestedUsers.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final u = community.suggestedUsers[i];
        final uid = u['id'] as String;
        final name = u['full_name'] as String? ?? u['username'] as String? ?? 'Rider';
        final username = u['username'] as String? ?? 'rider';
        final photo = u['photo_url'] as String? ?? '';
        final level = u['rider_level'] as String? ?? 'Rider';

        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              backgroundImage: photo.isNotEmpty ? NetworkImage(photo) : null,
              child: photo.isEmpty ? const Icon(Icons.person, color: AppColors.onSurface) : null,
            ),
            title: Text(name, style: AppTextStyles.headlineXs()),
            subtitle: Text('@$username • $level', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            trailing: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.circuitOrange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.person_add, size: 14),
              label: const Text('Add', style: TextStyle(fontSize: 12)),
              onPressed: () async {
                final res = await community.sendFriendRequest(uid);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(res.isSuccess ? 'Friend request sent!' : 'Failed: ${res.error?.message}'),
                      backgroundColor: res.isSuccess ? AppColors.circuitOrange : Colors.red,
                    ),
                  );
                }
              },
            ),
            onTap: () => _openUserProfile(uid, username, name, photo),
          ),
        );
      },
    );
  }

  Widget _buildBlockedTab(CommunityController community) {
    if (community.blockedUsers.isEmpty) {
      return Center(
        child: Text('No blocked users.', style: AppTextStyles.bodyMd(color: AppColors.onSurfaceVariant)),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.marginMobile),
      itemCount: community.blockedUsers.length,
      separatorBuilder: (context, _) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (ctx, i) {
        final b = community.blockedUsers[i];
        return GlassCard(
          padding: const EdgeInsets.all(AppSpacing.sm),
          child: ListTile(
            leading: CircleAvatar(
              backgroundColor: AppColors.surfaceContainerHighest,
              child: const Icon(Icons.block, color: Colors.redAccent),
            ),
            title: Text(b.fullName, style: AppTextStyles.headlineXs()),
            subtitle: Text('@${b.username}', style: AppTextStyles.bodyXs(color: AppColors.onSurfaceVariant)),
            trailing: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: AppColors.glassBorder),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () => community.unblockUser(b.friendId),
              child: const Text('UNBLOCK', style: TextStyle(fontSize: 11)),
            ),
          ),
        );
      },
    );
  }
}
