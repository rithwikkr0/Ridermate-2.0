import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/services/database_service.dart';
import '../models/friend_model.dart';

abstract class FriendRepository {
  Future<Result<List<FriendModel>>> getFriends({required String userId});
  Future<Result<List<FriendRequestModel>>> getPendingRequests({required String userId});
  Future<Result<List<FriendRequestModel>>> getSentRequests({required String userId});
  Future<Result<bool>> sendFriendRequest({required String senderId, required String receiverId});
  Future<Result<bool>> acceptFriendRequest({required String requestId, required String userId});
  Future<Result<bool>> rejectFriendRequest({required String requestId});
  Future<Result<bool>> cancelFriendRequest({required String requestId, required String senderId});
  Future<Result<bool>> removeFriend({required String userId, required String friendId});
  Future<Result<bool>> blockUser({required String userId, required String targetId});
  Future<Result<bool>> unblockUser({required String userId, required String targetId});
  Future<Result<List<FriendModel>>> getBlockedUsers({required String userId});
  Future<Result<FriendshipStatus>> getRelationshipStatus({required String currentUserId, required String targetUserId});
  Future<Result<List<Map<String, dynamic>>>> searchUsers({required String query, required String currentUserId});
}

/// RiderMate 2.0 — Production Sqlite Friend Repository
class SqliteFriendRepository implements FriendRepository {
  final DatabaseService _dbService;

  SqliteFriendRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<Result<List<FriendModel>>> getFriends({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'friendships',
        where: 'user_id = ? AND status = ?',
        whereArgs: [userId, 'accepted'],
        orderBy: 'created_at DESC',
      );

      final List<FriendModel> friends = [];
      for (final row in rows) {
        final friendId = row['friend_id'] as String;
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [friendId], limit: 1);
        final userMap = uRows.isNotEmpty ? uRows.first : null;
        friends.add(FriendModel.fromMap(row, userMap: userMap));
      }

      return Result.success(friends);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch friends: $e'));
    }
  }

  @override
  Future<Result<List<FriendRequestModel>>> getPendingRequests({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'friend_requests',
        where: 'receiver_id = ? AND status = ?',
        whereArgs: [userId, 'pending'],
        orderBy: 'created_at DESC',
      );

      final List<FriendRequestModel> requests = [];
      for (final row in rows) {
        final senderId = row['sender_id'] as String;
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [senderId], limit: 1);
        final senderMap = uRows.isNotEmpty ? uRows.first : null;
        requests.add(FriendRequestModel.fromMap(row, senderUserMap: senderMap));
      }

      return Result.success(requests);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch friend requests: $e'));
    }
  }

  @override
  Future<Result<List<FriendRequestModel>>> getSentRequests({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'friend_requests',
        where: 'sender_id = ? AND status = ?',
        whereArgs: [userId, 'pending'],
        orderBy: 'created_at DESC',
      );

      final List<FriendRequestModel> requests = [];
      for (final row in rows) {
        final receiverId = row['receiver_id'] as String;
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [receiverId], limit: 1);
        final receiverMap = uRows.isNotEmpty ? uRows.first : null;
        requests.add(FriendRequestModel.fromMap(row, receiverUserMap: receiverMap));
      }

      return Result.success(requests);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch sent requests: $e'));
    }
  }

  @override
  Future<Result<bool>> sendFriendRequest({
    required String senderId,
    required String receiverId,
  }) async {
    try {
      final db = await _db;

      // Check if already friends or blocked
      final blocked = await db.query(
        'blocked_users',
        where: '(user_id = ? AND blocked_user_id = ?) OR (user_id = ? AND blocked_user_id = ?)',
        whereArgs: [senderId, receiverId, receiverId, senderId],
      );
      if (blocked.isNotEmpty) {
        return Result.failure(ValidationError('Cannot send friend request to blocked user'));
      }

      final reqId = 'freq_${DateTime.now().millisecondsSinceEpoch}_$senderId';
      final req = FriendRequestModel(
        id: reqId,
        senderId: senderId,
        receiverId: receiverId,
        senderName: '',
        createdAt: DateTime.now(),
      );

      await db.insert('friend_requests', req.toMap(), conflictAlgorithm: ConflictAlgorithm.replace);
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to send friend request: $e'));
    }
  }

  @override
  Future<Result<bool>> acceptFriendRequest({
    required String requestId,
    required String userId,
  }) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        final rRows = await txn.query('friend_requests', where: 'id = ?', whereArgs: [requestId], limit: 1);
        if (rRows.isEmpty) return Result.failure(StorageError('Request not found'));

        final reqMap = rRows.first;
        final senderId = reqMap['sender_id'] as String;
        final receiverId = reqMap['receiver_id'] as String;

        // Update request status
        await txn.update('friend_requests', {'status': 'accepted'}, where: 'id = ?', whereArgs: [requestId]);

        // Create bidirectional friendship rows
        final now = DateTime.now().toIso8601String();
        await txn.insert('friendships', {
          'id': 'fr_${senderId}_$receiverId',
          'user_id': senderId,
          'friend_id': receiverId,
          'status': 'accepted',
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        await txn.insert('friendships', {
          'id': 'fr_${receiverId}_$senderId',
          'user_id': receiverId,
          'friend_id': senderId,
          'status': 'accepted',
          'created_at': now,
          'updated_at': now,
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        return Result.success(true);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to accept friend request: $e'));
    }
  }

  @override
  Future<Result<bool>> rejectFriendRequest({required String requestId}) async {
    try {
      final db = await _db;
      await db.update('friend_requests', {'status': 'rejected'}, where: 'id = ?', whereArgs: [requestId]);
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to reject friend request: $e'));
    }
  }

  @override
  Future<Result<bool>> cancelFriendRequest({required String requestId, required String senderId}) async {
    try {
      final db = await _db;
      await db.delete(
        'friend_requests',
        where: 'id = ? AND sender_id = ?',
        whereArgs: [requestId, senderId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to cancel friend request: $e'));
    }
  }

  @override
  Future<Result<bool>> removeFriend({required String userId, required String friendId}) async {
    try {
      final db = await _db;
      await db.delete(
        'friendships',
        where: '(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)',
        whereArgs: [userId, friendId, friendId, userId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to remove friend: $e'));
    }
  }

  @override
  Future<Result<bool>> blockUser({required String userId, required String targetId}) async {
    try {
      final db = await _db;
      return await db.transaction((txn) async {
        // Remove active friendships
        await txn.delete(
          'friendships',
          where: '(user_id = ? AND friend_id = ?) OR (user_id = ? AND friend_id = ?)',
          whereArgs: [userId, targetId, targetId, userId],
        );

        // Delete pending requests
        await txn.delete(
          'friend_requests',
          where: '(sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)',
          whereArgs: [userId, targetId, targetId, userId],
        );

        final blockId = 'block_${userId}_$targetId';
        await txn.insert('blocked_users', {
          'id': blockId,
          'user_id': userId,
          'blocked_user_id': targetId,
          'created_at': DateTime.now().toIso8601String(),
        }, conflictAlgorithm: ConflictAlgorithm.replace);

        return Result.success(true);
      });
    } catch (e) {
      return Result.failure(StorageError('Failed to block user: $e'));
    }
  }

  @override
  Future<Result<bool>> unblockUser({required String userId, required String targetId}) async {
    try {
      final db = await _db;
      await db.delete(
        'blocked_users',
        where: 'user_id = ? AND blocked_user_id = ?',
        whereArgs: [userId, targetId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to unblock user: $e'));
    }
  }

  @override
  Future<Result<List<FriendModel>>> getBlockedUsers({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'blocked_users',
        where: 'user_id = ?',
        whereArgs: [userId],
      );

      final List<FriendModel> blockedList = [];
      for (final r in rows) {
        final targetId = r['blocked_user_id'] as String;
        final uRows = await db.query('users', where: 'id = ?', whereArgs: [targetId], limit: 1);
        final userMap = uRows.isNotEmpty ? uRows.first : null;
        blockedList.add(FriendModel(
          id: r['id'] as String,
          userId: userId,
          friendId: targetId,
          username: userMap?['username'] as String? ?? 'User',
          fullName: userMap?['full_name'] as String? ?? 'Blocked User',
          photoUrl: userMap?['photo_url'] as String? ?? '',
          status: 'blocked',
          createdAt: DateTime.now(),
        ));
      }
      return Result.success(blockedList);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch blocked users: $e'));
    }
  }

  @override
  Future<Result<FriendshipStatus>> getRelationshipStatus({
    required String currentUserId,
    required String targetUserId,
  }) async {
    try {
      if (currentUserId == targetUserId) return Result.success(FriendshipStatus.none);

      final db = await _db;

      // 1. Check blocked
      final blocked = await db.query(
        'blocked_users',
        where: '(user_id = ? AND blocked_user_id = ?) OR (user_id = ? AND blocked_user_id = ?)',
        whereArgs: [currentUserId, targetUserId, targetUserId, currentUserId],
      );
      if (blocked.isNotEmpty) return Result.success(FriendshipStatus.blocked);

      // 2. Check friends
      final friends = await db.query(
        'friendships',
        where: 'user_id = ? AND friend_id = ? AND status = ?',
        whereArgs: [currentUserId, targetUserId, 'accepted'],
      );
      if (friends.isNotEmpty) return Result.success(FriendshipStatus.friends);

      // 3. Check requests sent by current user
      final sent = await db.query(
        'friend_requests',
        where: 'sender_id = ? AND receiver_id = ? AND status = ?',
        whereArgs: [currentUserId, targetUserId, 'pending'],
      );
      if (sent.isNotEmpty) return Result.success(FriendshipStatus.requestSent);

      // 4. Check requests received by current user
      final received = await db.query(
        'friend_requests',
        where: 'sender_id = ? AND receiver_id = ? AND status = ?',
        whereArgs: [targetUserId, currentUserId, 'pending'],
      );
      if (received.isNotEmpty) return Result.success(FriendshipStatus.requestReceived);

      return Result.success(FriendshipStatus.none);
    } catch (e) {
      return Result.failure(StorageError('Failed to get relationship status: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> searchUsers({
    required String query,
    required String currentUserId,
  }) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'users',
        where: '(username LIKE ? OR full_name LIKE ?) AND id != ?',
        whereArgs: ['%$query%', '%$query%', currentUserId],
        limit: 20,
      );
      return Result.success(rows);
    } catch (e) {
      return Result.failure(StorageError('Failed to search users: $e'));
    }
  }
}
