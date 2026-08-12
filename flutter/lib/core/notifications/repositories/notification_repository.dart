import 'package:sqflite/sqflite.dart';
import '../../errors/app_error.dart';
import '../../errors/result.dart';
import '../../services/database_service.dart';
import '../models/app_notification.dart';
import '../models/notification_preferences.dart';
import '../models/notification_type.dart';

abstract class NotificationRepository {
  Future<Result<AppNotification>> saveNotification(AppNotification notification);
  Future<Result<List<AppNotification>>> getNotifications({
    required String userId,
    NotificationType? filterType,
    bool unreadOnly = false,
    int limit = 50,
  });
  Future<Result<int>> getUnreadCount({required String userId});
  Future<Result<bool>> markAsRead({required String id, required String userId});
  Future<Result<bool>> markAllAsRead({required String userId});
  Future<Result<bool>> deleteNotification({required String id, required String userId});
  Future<Result<bool>> clearAllNotifications({required String userId});
  Future<Result<NotificationPreferences>> getPreferences({required String userId});
  Future<Result<NotificationPreferences>> savePreferences(NotificationPreferences preferences);
}

class SqliteNotificationRepository implements NotificationRepository {
  final DatabaseService _dbService;

  SqliteNotificationRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<Result<AppNotification>> saveNotification(AppNotification notification) async {
    try {
      final db = await _db;
      await db.insert(
        'notifications',
        notification.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(notification);
    } catch (e) {
      return Result.failure(StorageError('Failed to save notification: $e'));
    }
  }

  @override
  Future<Result<List<AppNotification>>> getNotifications({
    required String userId,
    NotificationType? filterType,
    bool unreadOnly = false,
    int limit = 50,
  }) async {
    try {
      final db = await _db;
      final whereClauses = ['user_id = ?'];
      final whereArgs = <dynamic>[userId];

      if (filterType != null) {
        whereClauses.add('type = ?');
        whereArgs.add(filterType.name);
      }

      if (unreadOnly) {
        whereClauses.add('read_at IS NULL');
      }

      final rows = await db.query(
        'notifications',
        where: whereClauses.join(' AND '),
        whereArgs: whereArgs,
        orderBy: 'created_at DESC',
        limit: limit,
      );

      final list = rows.map((map) => AppNotification.fromMap(map)).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(StorageError('Failed to query notifications: $e'));
    }
  }

  @override
  Future<Result<int>> getUnreadCount({required String userId}) async {
    try {
      final db = await _db;
      final result = await db.rawQuery(
        'SELECT COUNT(*) as count FROM notifications WHERE user_id = ? AND read_at IS NULL',
        [userId],
      );
      final count = Sqflite.firstIntValue(result) ?? 0;
      return Result.success(count);
    } catch (e) {
      return Result.failure(StorageError('Failed to get unread count: $e'));
    }
  }

  @override
  Future<Result<bool>> markAsRead({required String id, required String userId}) async {
    try {
      final db = await _db;
      final count = await db.update(
        'notifications',
        {'read_at': DateTime.now().toIso8601String()},
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to mark notification read: $e'));
    }
  }

  @override
  Future<Result<bool>> markAllAsRead({required String userId}) async {
    try {
      final db = await _db;
      await db.update(
        'notifications',
        {'read_at': DateTime.now().toIso8601String()},
        where: 'user_id = ? AND read_at IS NULL',
        whereArgs: [userId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to mark all notifications read: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteNotification({required String id, required String userId}) async {
    try {
      final db = await _db;
      final count = await db.delete(
        'notifications',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete notification: $e'));
    }
  }

  @override
  Future<Result<bool>> clearAllNotifications({required String userId}) async {
    try {
      final db = await _db;
      await db.delete(
        'notifications',
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to clear notifications: $e'));
    }
  }

  @override
  Future<Result<NotificationPreferences>> getPreferences({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'notification_preferences',
        where: 'user_id = ?',
        whereArgs: [userId],
        limit: 1,
      );

      if (rows.isEmpty) {
        final prefs = NotificationPreferences(userId: userId);
        await savePreferences(prefs);
        return Result.success(prefs);
      }

      return Result.success(NotificationPreferences.fromMap(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch notification preferences: $e'));
    }
  }

  @override
  Future<Result<NotificationPreferences>> savePreferences(NotificationPreferences preferences) async {
    try {
      final db = await _db;
      await db.insert(
        'notification_preferences',
        preferences.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(preferences);
    } catch (e) {
      return Result.failure(StorageError('Failed to save notification preferences: $e'));
    }
  }
}
