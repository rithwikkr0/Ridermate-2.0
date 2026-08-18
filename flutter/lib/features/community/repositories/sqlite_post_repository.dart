import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/services/database_service.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../models/story_model.dart';

abstract class PostRepository {
  Future<Result<PostModel>> createPost(PostModel post);
  Future<Result<List<PostModel>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
    PostType? filterType,
  });
  Future<Result<List<PostModel>>> getUserPosts({
    required String userId,
    required String currentUserId,
  });
  Future<Result<PostModel?>> getPostById(String postId, {required String currentUserId});
  Future<Result<bool>> deletePost(String postId, {required String currentUserId});
  Future<Result<bool>> toggleLike({required String postId, required String userId});
  Future<Result<bool>> toggleSave({required String postId, required String userId});
  Future<Result<List<PostModel>>> getSavedPosts({required String userId});
  Future<Result<CommentModel>> addComment(CommentModel comment);
  Future<Result<bool>> deleteComment(String commentId, {required String currentUserId});
  Future<Result<List<CommentModel>>> getComments(String postId);
  Future<Result<bool>> recordShare(String postId);
  Future<Result<bool>> reportItem({
    required String reporterId,
    required String itemId,
    required String itemType,
    required String reason,
    String details = '',
  });
  Future<Result<StoryModel>> createStory(StoryModel story);
  Future<Result<List<StoryModel>>> getStories({required String currentUserId});
}

/// RiderMate 2.0 — Production-Grade SQLite Post & Social Interactions Repository
class SqlitePostRepository implements PostRepository {
  final DatabaseService _dbService;

  SqlitePostRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<Result<PostModel>> createPost(PostModel post) async {
    try {
      final db = await _db;
      final map = post.toMap();
      await db.insert('social_posts', map, conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(post);
    } catch (e) {
      return Result.failure(StorageError('Failed to create post: $e'));
    }
  }

  @override
  Future<Result<List<PostModel>>> getFeed({
    required String currentUserId,
    int limit = 20,
    int offset = 0,
    PostType? filterType,
  }) async {
    try {
      final db = await _db;

      // 1. Get blocked user IDs (bidirectional)
      final blockedRows = await db.rawQuery('''
        SELECT blocked_user_id AS id FROM blocked_users WHERE user_id = ?
        UNION
        SELECT user_id AS id FROM blocked_users WHERE blocked_user_id = ?
      ''', [currentUserId, currentUserId]);
      final blockedIds = blockedRows.map((r) => r['id'] as String).toSet();

      // 2. Get accepted friend IDs
      final friendRows = await db.query(
        'friendships',
        columns: ['friend_id'],
        where: 'user_id = ? AND status = ?',
        whereArgs: [currentUserId, 'accepted'],
      );
      final friendIds = friendRows.map((r) => r['friend_id'] as String).toSet();

      // 3. Query posts with privacy enforcement at the database layer
      final allActiveRows = await db.query(
        'social_posts',
        where: "status = 'active' OR status IS NULL",
        orderBy: 'created_at DESC',
      );

      final List<PostModel> accessiblePosts = [];
      for (final row in allActiveRows) {
        final authorId = row['user_id'] as String;
        final privacyStr = row['privacy'] as String? ?? 'friends';
        final privacy = PostPrivacy.fromString(privacyStr);
        final postTypeStr = row['type'] as String? ?? 'text';
        final postType = PostType.fromString(postTypeStr);

        // Filter by type if requested
        if (filterType != null && postType != filterType) {
          continue;
        }

        // Privacy rule verification:
        // - Blocked users: NEVER accessible (unless own post)
        if (blockedIds.contains(authorId) && authorId != currentUserId) {
          continue;
        }

        // - Owner: Always accessible
        if (authorId == currentUserId) {
          accessiblePosts.add(await _hydratePost(db, row, currentUserId));
          continue;
        }

        // - Private: ONLY owner can view
        if (privacy == PostPrivacy.private) {
          continue;
        }

        // - Friends: ONLY accepted friends
        if (privacy == PostPrivacy.friends) {
          if (friendIds.contains(authorId)) {
            accessiblePosts.add(await _hydratePost(db, row, currentUserId));
          }
          continue;
        }

        // - Public: Accessible to all non-blocked users
        if (privacy == PostPrivacy.public) {
          accessiblePosts.add(await _hydratePost(db, row, currentUserId));
        }
      }

      // 4. Apply pagination safely
      final startIndex = offset;
      if (startIndex >= accessiblePosts.length) {
        return Result.success([]);
      }
      final endIndex = (startIndex + limit) < accessiblePosts.length
          ? (startIndex + limit)
          : accessiblePosts.length;

      return Result.success(accessiblePosts.sublist(startIndex, endIndex));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch feed: $e'));
    }
  }

  @override
  Future<Result<List<PostModel>>> getUserPosts({
    required String userId,
    required String currentUserId,
  }) async {
    try {
      final db = await _db;
      final isSelf = (userId == currentUserId);

      // Check if blocked
      final blocked = await db.query(
        'blocked_users',
        where: '(user_id = ? AND blocked_user_id = ?) OR (user_id = ? AND blocked_user_id = ?)',
        whereArgs: [currentUserId, userId, userId, currentUserId],
      );
      if (blocked.isNotEmpty && !isSelf) {
        return Result.success([]);
      }

      // Check friend status
      final isFriend = (await db.query(
        'friendships',
        where: 'user_id = ? AND friend_id = ? AND status = ?',
        whereArgs: [currentUserId, userId, 'accepted'],
      )).isNotEmpty;

      final rows = await db.query(
        'social_posts',
        where: "user_id = ? AND (status = 'active' OR status IS NULL)",
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );

      final List<PostModel> result = [];
      for (final row in rows) {
        final privacyStr = row['privacy'] as String? ?? 'friends';
        final privacy = PostPrivacy.fromString(privacyStr);

        if (isSelf) {
          result.add(await _hydratePost(db, row, currentUserId));
        } else if (privacy == PostPrivacy.public) {
          result.add(await _hydratePost(db, row, currentUserId));
        } else if (privacy == PostPrivacy.friends && isFriend) {
          result.add(await _hydratePost(db, row, currentUserId));
        }
      }

      return Result.success(result);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch user posts: $e'));
    }
  }

  @override
  Future<Result<PostModel?>> getPostById(String postId, {required String currentUserId}) async {
    try {
      final db = await _db;
      final rows = await db.query('social_posts', where: 'id = ?', whereArgs: [postId], limit: 1);
      if (rows.isEmpty) return Result.success(null);

      final row = rows.first;
      final authorId = row['user_id'] as String;
      final privacyStr = row['privacy'] as String? ?? 'friends';
      final privacy = PostPrivacy.fromString(privacyStr);

      if (authorId != currentUserId) {
        if (privacy == PostPrivacy.private) return Result.success(null);
        if (privacy == PostPrivacy.friends) {
          final isFriend = (await db.query(
            'friendships',
            where: 'user_id = ? AND friend_id = ? AND status = ?',
            whereArgs: [currentUserId, authorId, 'accepted'],
          )).isNotEmpty;
          if (!isFriend) return Result.success(null);
        }
      }

      final hydrated = await _hydratePost(db, row, currentUserId);
      return Result.success(hydrated);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch post: $e'));
    }
  }

  @override
  Future<Result<bool>> deletePost(String postId, {required String currentUserId}) async {
    try {
      final db = await _db;
      final count = await db.delete(
        'social_posts',
        where: 'id = ? AND user_id = ?',
        whereArgs: [postId, currentUserId],
      );
      if (count > 0) {
        await db.delete('post_likes', where: 'post_id = ?', whereArgs: [postId]);
        await db.delete('comments', where: 'post_id = ?', whereArgs: [postId]);
        await db.delete('saved_posts', where: 'post_id = ?', whereArgs: [postId]);
      }
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete post: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleLike({required String postId, required String userId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        final existing = await txn.query(
          'post_likes',
          where: 'post_id = ? AND user_id = ?',
          whereArgs: [postId, userId],
        );

        bool isLiked;
        if (existing.isNotEmpty) {
          // Unlike
          await txn.delete(
            'post_likes',
            where: 'post_id = ? AND user_id = ?',
            whereArgs: [postId, userId],
          );
          isLiked = false;
        } else {
          // Like
          final likeId = 'like_${DateTime.now().millisecondsSinceEpoch}_$userId';
          await txn.insert('post_likes', {
            'id': likeId,
            'post_id': postId,
            'user_id': userId,
            'created_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          isLiked = true;
        }

        // Recalculate true real count
        final countRes = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM post_likes WHERE post_id = ?',
          [postId],
        )) ?? 0;

        await txn.update(
          'social_posts',
          {'like_count': countRes},
          where: 'id = ?',
          whereArgs: [postId],
        );

        return Result.success(isLiked);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to toggle like: $e'));
    }
  }

  @override
  Future<Result<bool>> toggleSave({required String postId, required String userId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        final existing = await txn.query(
          'saved_posts',
          where: 'user_id = ? AND post_id = ?',
          whereArgs: [userId, postId],
        );

        bool isSaved;
        if (existing.isNotEmpty) {
          await txn.delete(
            'saved_posts',
            where: 'user_id = ? AND post_id = ?',
            whereArgs: [userId, postId],
          );
          isSaved = false;
        } else {
          final saveId = 'save_${DateTime.now().millisecondsSinceEpoch}_$userId';
          await txn.insert('saved_posts', {
            'id': saveId,
            'user_id': userId,
            'post_id': postId,
            'created_at': DateTime.now().toIso8601String(),
          }, conflictAlgorithm: ConflictAlgorithm.replace);
          isSaved = true;
        }

        final countRes = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM saved_posts WHERE post_id = ?',
          [postId],
        )) ?? 0;

        await txn.update(
          'social_posts',
          {'save_count': countRes},
          where: 'id = ?',
          whereArgs: [postId],
        );

        return Result.success(isSaved);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to toggle save: $e'));
    }
  }

  @override
  Future<Result<List<PostModel>>> getSavedPosts({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.rawQuery('''
        SELECT sp.* FROM social_posts sp
        INNER JOIN saved_posts s ON sp.id = s.post_id
        WHERE s.user_id = ? AND (sp.status = 'active' OR sp.status IS NULL)
        ORDER BY s.created_at DESC
      ''', [userId]);

      final List<PostModel> posts = [];
      for (final row in rows) {
        posts.add(await _hydratePost(db, row, userId));
      }
      return Result.success(posts);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch saved posts: $e'));
    }
  }

  @override
  Future<Result<CommentModel>> addComment(CommentModel comment) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        await txn.insert('comments', comment.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);

        final countRes = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM comments WHERE post_id = ?',
          [comment.postId],
        )) ?? 0;

        await txn.update(
          'social_posts',
          {'comment_count': countRes},
          where: 'id = ?',
          whereArgs: [comment.postId],
        );

        return Result.success(comment);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to add comment: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteComment(String commentId, {required String currentUserId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        final commentRows = await txn.query('comments', where: 'id = ?', whereArgs: [commentId], limit: 1);
        if (commentRows.isEmpty) return Result.success(false);

        final comment = commentRows.first;
        final postId = comment['post_id'] as String;
        final authorId = comment['user_id'] as String;

        // Check if post owner or comment author
        final postRows = await txn.query('social_posts', where: 'id = ?', whereArgs: [postId], limit: 1);
        final isPostOwner = postRows.isNotEmpty && postRows.first['user_id'] == currentUserId;

        if (authorId != currentUserId && !isPostOwner) {
          return Result.failure(const PermissionError('Not authorized to delete this comment'));
        }

        await txn.delete('comments', where: 'id = ? OR parent_comment_id = ?', whereArgs: [commentId, commentId]);

        final countRes = Sqflite.firstIntValue(await txn.rawQuery(
          'SELECT COUNT(*) FROM comments WHERE post_id = ?',
          [postId],
        )) ?? 0;

        await txn.update(
          'social_posts',
          {'comment_count': countRes},
          where: 'id = ?',
          whereArgs: [postId],
        );

        return Result.success(true);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to delete comment: $e'));
    }
  }

  @override
  Future<Result<List<CommentModel>>> getComments(String postId) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'comments',
        where: 'post_id = ?',
        whereArgs: [postId],
        orderBy: 'created_at ASC',
      );

      final List<CommentModel> allComments = rows.map((r) => CommentModel.fromMap(r)).toList();

      // Separate top-level comments and nested replies
      final topLevel = allComments.where((c) => c.parentCommentId == null || c.parentCommentId!.isEmpty).toList();
      final List<CommentModel> organized = [];

      for (final parent in topLevel) {
        final replies = allComments.where((c) => c.parentCommentId == parent.id).toList();
        organized.add(parent.copyWith(replies: replies));
      }

      return Result.success(organized);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch comments: $e'));
    }
  }

  @override
  Future<Result<bool>> recordShare(String postId) async {
    try {
      final db = await _db;
      await db.rawUpdate('UPDATE social_posts SET share_count = share_count + 1 WHERE id = ?', [postId]);
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to record share: $e'));
    }
  }

  @override
  Future<Result<bool>> reportItem({
    required String reporterId,
    required String itemId,
    required String itemType,
    required String reason,
    String details = '',
  }) async {
    try {
      final db = await _db;
      final reportId = 'rep_${DateTime.now().millisecondsSinceEpoch}_$reporterId';
      await db.insert('reports', {
        'id': reportId,
        'reporter_id': reporterId,
        'reported_item_id': itemId,
        'reported_item_type': itemType,
        'reason': reason,
        'details': details,
        'status': 'pending',
        'created_at': DateTime.now().toIso8601String(),
      });

      // Update item status if it's a post
      if (itemType == 'post') {
        await db.update(
          'social_posts',
          {'status': 'reported'},
          where: 'id = ?',
          whereArgs: [itemId],
        );
      }

      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to submit report: $e'));
    }
  }

  @override
  Future<Result<StoryModel>> createStory(StoryModel story) async {
    try {
      final db = await _db;
      await db.insert('stories', story.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(story);
    } catch (e) {
      return Result.failure(StorageError('Failed to create story: $e'));
    }
  }

  @override
  Future<Result<List<StoryModel>>> getStories({required String currentUserId}) async {
    try {
      final db = await _db;
      final nowStr = DateTime.now().toIso8601String();

      // Fetch non-expired stories
      final rows = await db.query(
        'stories',
        where: 'expires_at > ?',
        whereArgs: [nowStr],
        orderBy: 'created_at DESC',
      );

      final friendRows = await db.query(
        'friendships',
        columns: ['friend_id'],
        where: 'user_id = ? AND status = ?',
        whereArgs: [currentUserId, 'accepted'],
      );
      final friendIds = friendRows.map((r) => r['friend_id'] as String).toSet();

      final List<StoryModel> visibleStories = [];
      for (final r in rows) {
        final authorId = r['user_id'] as String;
        final privacy = r['privacy'] as String? ?? 'friends';

        if (authorId == currentUserId) {
          visibleStories.add(StoryModel.fromMap(r));
        } else if (privacy == 'public' || (privacy == 'friends' && friendIds.contains(authorId))) {
          visibleStories.add(StoryModel.fromMap(r));
        }
      }

      return Result.success(visibleStories);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch stories: $e'));
    }
  }

  // ── Helper Hydration ──────────────────────────────────────
  Future<PostModel> _hydratePost(Database db, Map<String, dynamic> row, String currentUserId) async {
    final postId = row['id'] as String;
    final rideId = row['ride_id'] as String?;

    // Check isLiked
    final isLiked = (await db.query(
      'post_likes',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, currentUserId],
      limit: 1,
    )).isNotEmpty;

    // Check isSaved
    final isSaved = (await db.query(
      'saved_posts',
      where: 'post_id = ? AND user_id = ?',
      whereArgs: [postId, currentUserId],
      limit: 1,
    )).isNotEmpty;

    // If post references a ride, hydrate ride stats
    Map<String, dynamic>? rideStats;
    if (rideId != null && rideId.isNotEmpty) {
      final rideRows = await db.query('rides', where: 'id = ?', whereArgs: [rideId], limit: 1);
      if (rideRows.isNotEmpty) {
        final r = rideRows.first;
        rideStats = {
          'title': r['title'],
          'distance_km': r['distance_km'],
          'average_speed': r['average_speed'],
          'duration_seconds': r['duration_seconds'],
          'max_speed': r['max_speed'],
          'ride_score': r['ride_score'],
        };
      }
    }

    return PostModel.fromMap(
      row,
      isLiked: isLiked,
      isSaved: isSaved,
      rideStats: rideStats,
    );
  }
}
