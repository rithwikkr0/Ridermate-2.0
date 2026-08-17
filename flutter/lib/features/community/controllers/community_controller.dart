import 'package:flutter/foundation.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/notifications/services/notification_service.dart';
import '../../../core/services/database_service.dart';
import '../../rides/models/ride_engine_model.dart';
import '../../memories/models/memory_model.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/squad_model.dart';
import '../models/story_model.dart';
import '../models/community_models.dart';
import '../repositories/sqlite_post_repository.dart';
import '../repositories/sqlite_friend_repository.dart';
import '../repositories/sqlite_squad_repository.dart';

/// RiderMate 2.0 — Production Community Controller
class CommunityController extends ChangeNotifier {
  final PostRepository _postRepo;
  final FriendRepository _friendRepo;
  final SquadRepository _squadRepo;
  final DatabaseService _dbService;

  String _currentUserId = '';
  String _currentUserName = 'Rider';
  String _currentUserAvatar = '';

  List<PostModel> _feedPosts = [];
  List<StoryModel> _stories = [];
  List<FriendModel> _friends = [];
  List<FriendRequestModel> _pendingRequests = [];
  List<FriendRequestModel> _sentRequests = [];
  List<FriendModel> _blockedUsers = [];
  List<PostModel> _savedPosts = [];
  List<SquadModel> _squads = [];
  List<GroupRideModel> _groupRides = [];
  List<Map<String, dynamic>> _suggestedUsers = [];
  List<LeaderboardRankModel> _leaderboard = [];

  bool _isLoading = false;
  bool _isLoadingFeed = false;
  bool _isLoadingFriends = false;
  bool _isLoadingSquads = false;
  String? _errorMessage;
  PostType? _activeFilter;

  CommunityController({
    PostRepository? postRepo,
    FriendRepository? friendRepo,
    SquadRepository? squadRepo,
    DatabaseService? dbService,
  })  : _postRepo = postRepo ?? SqlitePostRepository(),
        _friendRepo = friendRepo ?? SqliteFriendRepository(),
        _squadRepo = squadRepo ?? SqliteSquadRepository(),
        _dbService = dbService ?? DatabaseService.instance;

  // Getters
  String get currentUserId => _currentUserId;
  List<PostModel> get feedPosts => _feedPosts;
  List<StoryModel> get stories => _stories;
  List<FriendModel> get friends => _friends;
  List<FriendRequestModel> get pendingRequests => _pendingRequests;
  List<FriendRequestModel> get sentRequests => _sentRequests;
  List<FriendModel> get blockedUsers => _blockedUsers;
  List<PostModel> get savedPosts => _savedPosts;
  List<SquadModel> get squads => _squads;
  List<GroupRideModel> get groupRides => _groupRides;
  List<Map<String, dynamic>> get suggestedUsers => _suggestedUsers;
  List<LeaderboardRankModel> get leaderboard => _leaderboard;
  bool get isLoading => _isLoading;
  bool get isLoadingFeed => _isLoadingFeed;
  bool get isLoadingFriends => _isLoadingFriends;
  bool get isLoadingSquads => _isLoadingSquads;
  String? get errorMessage => _errorMessage;
  PostType? get activeFilter => _activeFilter;

  /// User switch / login synchronization
  Future<void> refreshForUser(String userId, {String? userName, String? userAvatar}) async {
    _currentUserId = userId;
    _currentUserName = userName ?? _currentUserName;
    _currentUserAvatar = userAvatar ?? _currentUserAvatar;

    // Reset user-scoped cache to guarantee strict user isolation
    _feedPosts = [];
    _stories = [];
    _friends = [];
    _pendingRequests = [];
    _sentRequests = [];
    _blockedUsers = [];
    _savedPosts = [];
    _squads = [];
    _groupRides = [];
    _suggestedUsers = [];
    _leaderboard = [];
    _errorMessage = null;

    if (_currentUserId.isNotEmpty) {
      await loadCommunityOverview();
    } else {
      notifyListeners();
    }
  }

  /// Initial load of all community components
  Future<void> loadCommunityOverview() async {
    if (_currentUserId.isEmpty) return;
    _isLoading = true;
    notifyListeners();

    try {
      await Future.wait([
        loadFeed(refresh: true),
        loadStories(),
        loadFriends(),
        loadSquads(),
        loadSuggestedUsers(),
        loadLeaderboard(),
      ]);
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // ── Feed & Posts ──────────────────────────────────────────
  Future<void> loadFeed({bool refresh = false, PostType? filter}) async {
    if (_currentUserId.isEmpty) return;
    _isLoadingFeed = true;
    _activeFilter = filter;
    if (refresh) notifyListeners();

    final result = await _postRepo.getFeed(
      currentUserId: _currentUserId,
      filterType: _activeFilter,
    );

    if (result.isSuccess) {
      _feedPosts = result.dataOrNull ?? [];
    } else {
      _errorMessage = result.error?.message;
    }

    _isLoadingFeed = false;
    notifyListeners();
  }

  Future<Result<PostModel>> createPost({
    required String caption,
    PostType type = PostType.text,
    PostPrivacy privacy = PostPrivacy.friends,
    String mediaUrl = '',
    String? rideId,
    String? memoryId,
  }) async {
    if (_currentUserId.isEmpty) {
      return Result.failure(const StorageError('User not authenticated'));
    }

    final post = PostModel(
      id: 'post_${DateTime.now().millisecondsSinceEpoch}_$_currentUserId',
      userId: _currentUserId,
      authorName: _currentUserName,
      authorAvatar: _currentUserAvatar,
      type: type,
      caption: caption.trim(),
      mediaUrl: mediaUrl,
      rideId: rideId,
      memoryId: memoryId,
      privacy: privacy,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final res = await _postRepo.createPost(post);
    if (res.isSuccess) {
      _feedPosts.insert(0, post);
      notifyListeners();
    }
    return res;
  }

  Future<Result<bool>> deletePost(String postId) async {
    final res = await _postRepo.deletePost(postId, currentUserId: _currentUserId);
    if (res.isSuccess && (res.dataOrNull ?? false)) {
      _feedPosts.removeWhere((p) => p.id == postId);
      _savedPosts.removeWhere((p) => p.id == postId);
      notifyListeners();
    }
    return res;
  }

  Future<void> toggleLike(String postId) async {
    // Optimistic UI update
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    bool wasLiked = false;
    if (index != -1) {
      final p = _feedPosts[index];
      wasLiked = p.isLikedByMe;
      final newLiked = !p.isLikedByMe;
      final newCount = newLiked ? p.likeCount + 1 : (p.likeCount > 0 ? p.likeCount - 1 : 0);
      _feedPosts[index] = p.copyWith(isLikedByMe: newLiked, likeCount: newCount);
      notifyListeners();
    }

    final res = await _postRepo.toggleLike(postId: postId, userId: _currentUserId);
    if (!res.isSuccess) {
      await loadFeed();
    } else if (!wasLiked) {
      // Only notify on new likes, not unlikes
      NotificationService.instance.notifySocial(
        title: '❤️ New Like',
        body: 'Someone liked your post!',
        entityId: 'like_${postId}_$_currentUserId',
        userId: _currentUserId,
        cooldown: const Duration(minutes: 5),
      );
    }
  }

  Future<void> toggleSave(String postId) async {
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final p = _feedPosts[index];
      final newSaved = !p.isSavedByMe;
      _feedPosts[index] = p.copyWith(isSavedByMe: newSaved);
      notifyListeners();
    }

    final res = await _postRepo.toggleSave(postId: postId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadSavedPosts();
    } else {
      await loadFeed();
    }
  }

  Future<void> loadSavedPosts() async {
    if (_currentUserId.isEmpty) return;
    final res = await _postRepo.getSavedPosts(userId: _currentUserId);
    if (res.isSuccess) {
      _savedPosts = res.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<Result<CommentModel>> addComment(String postId, String text, {String? parentCommentId}) async {
    if (text.trim().isEmpty) {
      return Result.failure(const StorageError('Comment cannot be empty'));
    }

    final comment = CommentModel(
      id: 'cm_${DateTime.now().millisecondsSinceEpoch}_$_currentUserId',
      postId: postId,
      userId: _currentUserId,
      authorName: _currentUserName,
      authorAvatar: _currentUserAvatar,
      text: text.trim(),
      parentCommentId: parentCommentId,
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );

    final res = await _postRepo.addComment(comment);
    if (res.isSuccess) {
      final index = _feedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final p = _feedPosts[index];
        _feedPosts[index] = p.copyWith(commentCount: p.commentCount + 1);
        notifyListeners();
      }

      // Notify about new comment
      NotificationService.instance.notifySocial(
        title: '💬 New Comment',
        body: '$_currentUserName commented on a post.',
        entityId: comment.id,
        userId: _currentUserId,
        cooldown: const Duration(minutes: 2),
      );
    }
    return res;
  }

  Future<Result<bool>> deleteComment(String commentId, String postId) async {
    final res = await _postRepo.deleteComment(commentId, currentUserId: _currentUserId);
    if (res.isSuccess && (res.dataOrNull ?? false)) {
      final index = _feedPosts.indexWhere((p) => p.id == postId);
      if (index != -1) {
        final p = _feedPosts[index];
        _feedPosts[index] = p.copyWith(commentCount: p.commentCount > 0 ? p.commentCount - 1 : 0);
        notifyListeners();
      }
    }
    return res;
  }

  Future<Result<List<CommentModel>>> getComments(String postId) async {
    return await _postRepo.getComments(postId);
  }

  Future<void> recordShare(String postId) async {
    await _postRepo.recordShare(postId);
    final index = _feedPosts.indexWhere((p) => p.id == postId);
    if (index != -1) {
      final p = _feedPosts[index];
      _feedPosts[index] = p.copyWith(shareCount: p.shareCount + 1);
      notifyListeners();
    }
  }

  Future<Result<bool>> reportContent({
    required String itemId,
    required String itemType,
    required String reason,
    String details = '',
  }) async {
    final res = await _postRepo.reportItem(
      reporterId: _currentUserId,
      itemId: itemId,
      itemType: itemType,
      reason: reason,
      details: details,
    );
    if (res.isSuccess && itemType == 'post') {
      _feedPosts.removeWhere((p) => p.id == itemId);
      notifyListeners();
    }
    return res;
  }

  // ── Stories / Moments ─────────────────────────────────────
  Future<void> loadStories() async {
    if (_currentUserId.isEmpty) return;
    final res = await _postRepo.getStories(currentUserId: _currentUserId);
    if (res.isSuccess) {
      _stories = res.dataOrNull ?? [];
      notifyListeners();
    }
  }

  Future<Result<StoryModel>> createStory({
    required String mediaUrl,
    String caption = '',
    String privacy = 'friends',
  }) async {
    final story = StoryModel(
      id: 'story_${DateTime.now().millisecondsSinceEpoch}_$_currentUserId',
      userId: _currentUserId,
      authorName: _currentUserName,
      authorAvatar: _currentUserAvatar,
      mediaUrl: mediaUrl,
      caption: caption,
      createdAt: DateTime.now(),
      expiresAt: DateTime.now().add(const Duration(hours: 24)),
      privacy: privacy,
    );

    final res = await _postRepo.createStory(story);
    if (res.isSuccess) {
      _stories.insert(0, story);
      notifyListeners();
    }
    return res;
  }

  // ── Friends & Requests ────────────────────────────────────
  Future<void> loadFriends() async {
    if (_currentUserId.isEmpty) return;
    _isLoadingFriends = true;

    final fRes = await _friendRepo.getFriends(userId: _currentUserId);
    final pRes = await _friendRepo.getPendingRequests(userId: _currentUserId);
    final sRes = await _friendRepo.getSentRequests(userId: _currentUserId);
    final bRes = await _friendRepo.getBlockedUsers(userId: _currentUserId);

    if (fRes.isSuccess) _friends = fRes.dataOrNull ?? [];
    if (pRes.isSuccess) _pendingRequests = pRes.dataOrNull ?? [];
    if (sRes.isSuccess) _sentRequests = sRes.dataOrNull ?? [];
    if (bRes.isSuccess) _blockedUsers = bRes.dataOrNull ?? [];

    _isLoadingFriends = false;
    notifyListeners();
  }

  Future<Result<bool>> sendFriendRequest(String receiverId) async {
    final res = await _friendRepo.sendFriendRequest(senderId: _currentUserId, receiverId: receiverId);
    if (res.isSuccess) {
      await loadFriends();
    }
    return res;
  }

  Future<Result<bool>> acceptFriendRequest(String requestId) async {
    final res = await _friendRepo.acceptFriendRequest(requestId: requestId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadFriends();
      await loadFeed();

      // Notify the current user that the friend request was accepted
      NotificationService.instance.notifySocial(
        title: '🤝 Friend Request Accepted',
        body: 'You are now friends!',
        entityId: requestId,
        userId: _currentUserId,
      );
    }
    return res;
  }

  Future<Result<bool>> rejectFriendRequest(String requestId) async {
    final res = await _friendRepo.rejectFriendRequest(requestId: requestId);
    if (res.isSuccess) {
      _pendingRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    }
    return res;
  }

  Future<Result<bool>> cancelFriendRequest(String requestId) async {
    final res = await _friendRepo.cancelFriendRequest(requestId: requestId, senderId: _currentUserId);
    if (res.isSuccess) {
      _sentRequests.removeWhere((r) => r.id == requestId);
      notifyListeners();
    }
    return res;
  }

  Future<Result<bool>> removeFriend(String friendId) async {
    final res = await _friendRepo.removeFriend(userId: _currentUserId, friendId: friendId);
    if (res.isSuccess) {
      _friends.removeWhere((FriendModel f) => f.friendId == friendId);
      notifyListeners();
      await loadFeed();
    }
    return res;
  }

  Future<Result<bool>> blockUser(String targetId) async {
    final res = await _friendRepo.blockUser(userId: _currentUserId, targetId: targetId);
    if (res.isSuccess) {
      _friends.removeWhere((FriendModel f) => f.friendId == targetId);
      _feedPosts.removeWhere((PostModel p) => p.userId == targetId);
      notifyListeners();
      await loadFriends();
    }
    return res;
  }

  Future<Result<bool>> unblockUser(String targetId) async {
    final res = await _friendRepo.unblockUser(userId: _currentUserId, targetId: targetId);
    if (res.isSuccess) {
      _blockedUsers.removeWhere((FriendModel b) => b.friendId == targetId);
      notifyListeners();
      await loadFeed();
    }
    return res;
  }

  Future<Result<FriendshipStatus>> getRelationshipStatus(String targetUserId) async {
    return await _friendRepo.getRelationshipStatus(currentUserId: _currentUserId, targetUserId: targetUserId);
  }

  Future<List<Map<String, dynamic>>> searchUsers(String query) async {
    if (query.trim().isEmpty) return [];
    final res = await _friendRepo.searchUsers(query: query.trim(), currentUserId: _currentUserId);
    return res.dataOrNull ?? [];
  }

  Future<void> loadSuggestedUsers() async {
    if (_currentUserId.isEmpty) return;
    try {
      final db = await _dbService.database;
      final rows = await db.query(
        'users',
        where: 'id != ?',
        whereArgs: [_currentUserId],
        limit: 10,
      );
      _suggestedUsers = rows;
      notifyListeners();
    } catch (_) {}
  }

  // ── Squads & Group Rides ──────────────────────────────────
  Future<void> loadSquads() async {
    if (_currentUserId.isEmpty) return;
    _isLoadingSquads = true;

    final sRes = await _squadRepo.getSquads(currentUserId: _currentUserId);
    final rRes = await _squadRepo.getGroupRides(currentUserId: _currentUserId);

    if (sRes.isSuccess) _squads = sRes.dataOrNull ?? [];
    if (rRes.isSuccess) _groupRides = rRes.dataOrNull ?? [];

    _isLoadingSquads = false;
    notifyListeners();
  }

  Future<Result<SquadModel>> createSquad({
    required String name,
    String description = '',
    bool isPrivate = false,
  }) async {
    final squad = SquadModel(
      id: 'squad_${DateTime.now().millisecondsSinceEpoch}_$_currentUserId',
      creatorId: _currentUserId,
      name: name.trim(),
      description: description.trim(),
      isPrivate: isPrivate,
      inviteCode: 'RM-${name.replaceAll(' ', '').toUpperCase().padRight(4, 'X').substring(0, 4)}-${DateTime.now().millisecondsSinceEpoch % 10000}',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
      isMember: true,
      role: 'owner',
    );

    final res = await _squadRepo.createSquad(squad, creatorId: _currentUserId);
    if (res.isSuccess) {
      _squads.insert(0, squad);
      notifyListeners();
    }
    return res;
  }

  Future<Result<bool>> joinSquad(String squadId, {String? inviteCode}) async {
    final res = await _squadRepo.joinSquad(squadId: squadId, userId: _currentUserId, inviteCode: inviteCode);
    if (res.isSuccess) {
      await loadSquads();
    }
    return res;
  }

  Future<Result<bool>> leaveSquad(String squadId) async {
    final res = await _squadRepo.leaveSquad(squadId: squadId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadSquads();
    }
    return res;
  }

  Future<Result<GroupRideModel>> createGroupRide({
    String? squadId,
    required String title,
    String description = '',
    required DateTime startTime,
    String startLocation = '',
    String destination = '',
  }) async {
    final ride = GroupRideModel(
      id: 'gride_${DateTime.now().millisecondsSinceEpoch}_$_currentUserId',
      squadId: squadId,
      creatorId: _currentUserId,
      creatorName: _currentUserName,
      title: title.trim(),
      description: description.trim(),
      startTime: startTime,
      startLocation: startLocation.trim(),
      destination: destination.trim(),
      createdAt: DateTime.now(),
      isJoined: true,
      isSharingLocation: true,
    );

    final res = await _squadRepo.createGroupRide(ride);
    if (res.isSuccess) {
      _groupRides.insert(0, ride);
      notifyListeners();
    }
    return res;
  }

  Future<Result<bool>> joinGroupRide(String groupRideId) async {
    final res = await _squadRepo.joinGroupRide(groupRideId: groupRideId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadSquads();
    }
    return res;
  }

  Future<Result<bool>> leaveGroupRide(String groupRideId) async {
    final res = await _squadRepo.leaveGroupRide(groupRideId: groupRideId, userId: _currentUserId);
    if (res.isSuccess) {
      await loadSquads();
    }
    return res;
  }

  Future<void> toggleGroupRideLocation(String groupRideId, double lat, double lng, bool share) async {
    await _squadRepo.updateGroupRideLocation(
      groupRideId: groupRideId,
      userId: _currentUserId,
      lat: lat,
      lng: lng,
      isSharing: share,
    );
    await loadSquads();
  }

  // ── Leaderboard ───────────────────────────────────────────
  Future<void> loadLeaderboard() async {
    try {
      final db = await _dbService.database;
      final rows = await db.query(
        'users',
        columns: ['id', 'full_name', 'username', 'photo_url', 'distance_km'],
        orderBy: 'distance_km DESC',
        limit: 50,
      );

      final List<LeaderboardRankModel> list = [];
      int rank = 1;
      for (final r in rows) {
        final uid = r['id'] as String;
        final name = (r['full_name'] as String? ?? '').isNotEmpty
            ? r['full_name'] as String
            : (r['username'] as String? ?? 'Rider');
        final distance = (r['distance_km'] as num? ?? 0.0).toDouble();

        list.add(LeaderboardRankModel(
          rank: rank++,
          name: name,
          avatarUrl: r['photo_url'] as String? ?? '',
          distanceKm: distance,
          isCurrentUser: (uid == _currentUserId),
        ));
      }

      _leaderboard = list;
      notifyListeners();
    } catch (_) {}
  }

  // ── Cross-Feature Sharing (Ride / Memory) ─────────────────
  Future<Result<PostModel>> shareRideToCommunity(
    RideEngineModel ride, {
    String caption = '',
    PostPrivacy privacy = PostPrivacy.friends,
  }) async {
    final defaultCaption = caption.isNotEmpty
        ? caption
        : 'Completed a ${ride.distanceKm.toStringAsFixed(1)} km ride on ${ride.vehicle.isNotEmpty ? ride.vehicle : "bike"}! 🏍️⚡';

    return await createPost(
      caption: defaultCaption,
      type: PostType.ride,
      privacy: privacy,
      rideId: ride.id,
    );
  }

  Future<Result<PostModel>> shareMemoryToCommunity(
    MemoryModel memory, {
    String caption = '',
    PostPrivacy? privacy,
  }) async {
    final defaultCaption = caption.isNotEmpty ? caption : memory.caption;
    final targetPrivacy = privacy ??
        (memory.privacy == MemoryPrivacy.public
            ? PostPrivacy.public
            : (memory.privacy == MemoryPrivacy.friends ? PostPrivacy.friends : PostPrivacy.private));

    return await createPost(
      caption: defaultCaption,
      type: PostType.memory,
      privacy: targetPrivacy,
      mediaUrl: memory.imagePath,
      memoryId: memory.id,
      rideId: memory.rideId,
    );
  }
}
