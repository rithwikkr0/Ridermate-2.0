import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:sqflite/sqflite.dart';
import '../errors/result.dart';
import '../errors/app_error.dart';
import '../network/azure_api_client.dart';
import '../services/database_service.dart';

/// RiderMate 2.0 — Production Offline Sync Engine
/// Queues outgoing mutations (posts, likes, comments, squad joins, ride summaries)
/// in local SQLite `offline_sync_queue` and dispatches them with server-side idempotency keys.
class OfflineSyncEngine extends ChangeNotifier {
  static final OfflineSyncEngine instance = OfflineSyncEngine._internal();

  factory OfflineSyncEngine({AzureApiClient? apiClient, DatabaseService? dbService}) {
    if (apiClient != null || dbService != null) {
      return OfflineSyncEngine._internal(
        apiClient: apiClient,
        dbService: dbService,
      );
    }
    return instance;
  }

  OfflineSyncEngine._internal({AzureApiClient? apiClient, DatabaseService? dbService})
      : _apiClient = apiClient ?? AzureApiClient(),
        _dbService = dbService ?? DatabaseService.instance;

  final AzureApiClient _apiClient;
  final DatabaseService _dbService;

  bool _isSyncing = false;
  int _pendingCount = 0;

  bool get isSyncing => _isSyncing;
  int get pendingCount => _pendingCount;

  /// Ensures sync table contains all required telemetry columns.
  Future<void> _ensureSchema(Database db) async {
    try {
      await db.execute(
        "ALTER TABLE offline_sync_queue ADD COLUMN idempotency_key TEXT NOT NULL DEFAULT ''",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE offline_sync_queue ADD COLUMN retry_count INTEGER NOT NULL DEFAULT 0",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE offline_sync_queue ADD COLUMN last_attempt_at TEXT NOT NULL DEFAULT ''",
      );
    } catch (_) {}
    try {
      await db.execute(
        "ALTER TABLE offline_sync_queue ADD COLUMN error_message TEXT NOT NULL DEFAULT ''",
      );
    } catch (_) {}
  }

  /// Enqueues an offline mutation action into SQLite with an idempotency key.
  Future<Result<String>> queueAction({
    required String userId,
    required String actionType,
    required Map<String, dynamic> payload,
    String? idempotencyKey,
  }) async {
    try {
      final db = await _dbService.database;
      await _ensureSchema(db);

      final nowMillis = DateTime.now().millisecondsSinceEpoch;
      final id = 'sync_${nowMillis}_${actionType.hashCode & 0xFFFF}';
      final idemKey = idempotencyKey ?? 'idem_${userId}_${actionType}_$nowMillis';
      final now = DateTime.now().toIso8601String();

      await db.insert('offline_sync_queue', {
        'id': id,
        'user_id': userId,
        'action_type': actionType,
        'payload_json': jsonEncode(payload),
        'status': 'pending',
        'created_at': now,
        'idempotency_key': idemKey,
        'retry_count': 0,
        'last_attempt_at': '',
        'error_message': '',
      }, conflictAlgorithm: ConflictAlgorithm.replace);

      await refreshPendingCount();
      return Result.success(id);
    } catch (e) {
      return Result.failure(StorageError('Failed to queue offline sync action: $e'));
    }
  }

  /// Refreshes the count of pending and failed items in the sync queue.
  Future<int> refreshPendingCount() async {
    try {
      final db = await _dbService.database;
      await _ensureSchema(db);
      final count = Sqflite.firstIntValue(await db.rawQuery(
        "SELECT COUNT(*) FROM offline_sync_queue WHERE status = 'pending' OR status = 'failed'",
      )) ?? 0;
      _pendingCount = count;
      notifyListeners();
      return count;
    } catch (_) {
      return 0;
    }
  }

  /// Flushes all pending items to the Azure Cloud backend using real HTTP action handlers.
  Future<Result<int>> flushQueue({String? authToken}) async {
    if (_isSyncing) {
      return Result.success(0);
    }

    _isSyncing = true;
    notifyListeners();

    int syncedCount = 0;

    try {
      final db = await _dbService.database;
      await _ensureSchema(db);

      final pendingRows = await db.query(
        'offline_sync_queue',
        where: "status = 'pending' OR status = 'failed'",
        orderBy: 'created_at ASC',
        limit: 50,
      );

      for (final row in pendingRows) {
        final id = row['id'] as String;
        final actionType = row['action_type'] as String;
        final payload = jsonDecode(row['payload_json'] as String) as Map<String, dynamic>;
        final idempotencyKey = (row['idempotency_key'] as String?) ?? '';
        final currentRetries = (row['retry_count'] as int?) ?? 0;

        // Mark as syncing
        await db.update(
          'offline_sync_queue',
          {'status': 'syncing', 'last_attempt_at': DateTime.now().toIso8601String()},
          where: 'id = ?',
          whereArgs: [id],
        );

        bool success = false;
        String errorMessage = '';

        try {
          switch (actionType) {
            case 'create_post':
              final res = await _apiClient.createPost(
                type: payload['type'] ?? 'text',
                caption: payload['caption'] ?? '',
                mediaUrl: payload['media_url'] ?? '',
                rideId: payload['ride_id'],
                memoryId: payload['memory_id'],
                privacy: payload['privacy'] ?? 'public',
                authToken: authToken,
                idempotencyKey: idempotencyKey,
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Create post failed';
              break;

            case 'like_post':
              final res = await _apiClient.likePost(
                postId: payload['post_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Like post failed';
              break;

            case 'unlike_post':
              final res = await _apiClient.unlikePost(
                postId: payload['post_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Unlike post failed';
              break;

            case 'create_comment':
              final res = await _apiClient.addComment(
                postId: payload['post_id'] ?? '',
                text: payload['text'] ?? '',
                parentCommentId: payload['parent_comment_id'],
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Add comment failed';
              break;

            case 'save_post':
              final res = await _apiClient.savePost(
                postId: payload['post_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Save post failed';
              break;

            case 'unsave_post':
              final res = await _apiClient.unsavePost(
                postId: payload['post_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Unsave post failed';
              break;

            case 'friend_request':
              final res = await _apiClient.sendFriendRequest(
                receiverId: payload['receiver_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Friend request failed';
              break;

            case 'friend_accept':
              final res = await _apiClient.acceptFriendRequest(
                requestId: payload['request_id'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Friend accept failed';
              break;

            case 'squad_join':
              final res = await _apiClient.joinSquad(
                squadId: payload['squad_id'] ?? '',
                inviteCode: payload['invite_code'] ?? '',
                authToken: authToken ?? '',
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Squad join failed';
              break;

            case 'ride_sync':
              final res = await _apiClient.syncRide(
                rideData: payload,
                authToken: authToken ?? '',
                idempotencyKey: idempotencyKey,
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Ride sync failed';
              break;

            case 'safety_analyze':
              final res = await _apiClient.analyzeSafety(
                rideId: payload['ride_id']?.toString() ?? '',
                distanceKm: (payload['distance_km'] as num?)?.toDouble() ?? 0.0,
                durationMinutes: (payload['duration_minutes'] as num?)?.toInt() ?? 0,
                maxSpeedKmh: (payload['max_speed_kmh'] as num?)?.toDouble() ?? 0.0,
                averageSpeedKmh: (payload['avg_speed_kmh'] as num?)?.toDouble() ?? 0.0,
                authToken: authToken,
              );
              success = res.isSuccess;
              if (!success) errorMessage = res.error?.message ?? 'Safety analysis failed';
              break;

            default:
              final health = await _apiClient.checkHealth();
              success = health.isSuccess;
              if (!success) errorMessage = health.error?.message ?? 'Health check failed';
              break;
          }
        } catch (e) {
          success = false;
          errorMessage = e.toString();
        }

        if (success) {
          await db.update(
            'offline_sync_queue',
            {
              'status': 'synced',
              'error_message': '',
            },
            where: 'id = ?',
            whereArgs: [id],
          );
          syncedCount++;
        } else {
          await db.update(
            'offline_sync_queue',
            {
              'status': 'failed',
              'retry_count': currentRetries + 1,
              'error_message': errorMessage,
            },
            where: 'id = ?',
            whereArgs: [id],
          );
        }
      }

      await refreshPendingCount();
      return Result.success(syncedCount);
    } catch (e) {
      return Result.failure(NetworkError('Failed to flush offline sync queue: $e'));
    } finally {
      _isSyncing = false;
      notifyListeners();
    }
  }
}
