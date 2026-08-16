import 'package:sqflite/sqflite.dart';
import '../errors/app_error.dart';
import '../errors/result.dart';
import '../services/database_service.dart';
import 'gamification_repository.dart';
import 'xp_config.dart';

class SqliteGamificationRepository implements GamificationRepository {
  final DatabaseService _dbService;

  SqliteGamificationRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<Result<int>> getUserXP(String userId) async {
    try {
      final db = await _dbService.database;
      final result = await db.query(
        'users',
        columns: ['xp'],
        where: 'id = ?',
        whereArgs: [userId],
      );
      if (result.isNotEmpty) {
        return Result.success((result.first['xp'] as num?)?.toInt() ?? 0);
      }
      return Result.success(0);
    } catch (e) {
      return Result.failure(StorageError('Failed to get XP: $e'));
    }
  }

  @override
  Future<Result<String>> getUserLevel(String userId) async {
    final xpResult = await getUserXP(userId);
    if (xpResult.isSuccess) {
      return Result.success(XpConfig.getLevelForXp(xpResult.dataOrNull!));
    }
    return Result.failure(xpResult.errorOrNull!);
  }

  @override
  Future<Result<bool>> awardXP(String userId, String eventType, int xpAmount, String referenceId) async {
    try {
      final db = await _dbService.database;
      bool awarded = false;
      await db.transaction((txn) async {
        // Try inserting into xp_events. UNIQUE constraint prevents duplicates.
        final id = '\${userId}_\${eventType}_\${referenceId}_\${DateTime.now().millisecondsSinceEpoch}';
        int inserted = await txn.rawInsert('''
          INSERT OR IGNORE INTO xp_events (id, user_id, event_type, xp_amount, reference_id, created_at)
          VALUES (?, ?, ?, ?, ?, ?)
        ''', [id, userId, eventType, xpAmount, referenceId, DateTime.now().toIso8601String()]);

        if (inserted > 0) {
          await txn.rawUpdate('''
            UPDATE users SET xp = xp + ? WHERE id = ?
          ''', [xpAmount, userId]);
          awarded = true;
        }
      });
      return Result.success(awarded);
    } catch (e) {
      return Result.failure(StorageError('Failed to award XP: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getUserAchievements(String userId) async {
    try {
      final db = await _dbService.database;
      final result = await db.query(
        'achievements',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'unlocked_at DESC',
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(StorageError('Failed to get achievements: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getActiveChallenges() async {
    try {
      final db = await _dbService.database;
      final result = await db.query(
        'challenges',
        where: 'is_active = 1',
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(StorageError('Failed to get active challenges: $e'));
    }
  }

  @override
  Future<Result<Map<String, dynamic>?>> getUserChallenge(String userId, String challengeId) async {
    try {
      final db = await _dbService.database;
      final result = await db.query(
        'user_challenges',
        where: 'user_id = ? AND challenge_id = ?',
        whereArgs: [userId, challengeId],
      );
      return Result.success(result.isNotEmpty ? result.first : null);
    } catch (e) {
      return Result.failure(StorageError('Failed to get user challenge: $e'));
    }
  }

  @override
  Future<Result<bool>> updateChallengeProgress(String userId, String challengeId, double progress) async {
    try {
      final db = await _dbService.database;
      bool completed = false;
      await db.transaction((txn) async {
        final challengeResult = await txn.query('challenges', where: 'id = ?', whereArgs: [challengeId]);
        if (challengeResult.isEmpty) return;

        final challenge = challengeResult.first;
        final targetValue = (challenge['target_value'] as num).toDouble();
        final isCompleted = progress >= targetValue;
        
        final existing = await txn.query('user_challenges', where: 'user_id = ? AND challenge_id = ?', whereArgs: [userId, challengeId]);
        
        if (existing.isEmpty) {
          final id = '\${userId}_$challengeId';
          await txn.insert('user_challenges', {
            'id': id,
            'user_id': userId,
            'challenge_id': challengeId,
            'progress': progress,
            'status': isCompleted ? 'completed' : 'active',
            'started_at': DateTime.now().toIso8601String(),
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
          });
          completed = isCompleted;
        } else {
          final currentStatus = existing.first['status'] as String;
          if (currentStatus == 'completed') {
            completed = false; // Already completed
            return;
          }

          await txn.update('user_challenges', {
            'progress': progress,
            'status': isCompleted ? 'completed' : 'active',
            'completed_at': isCompleted ? DateTime.now().toIso8601String() : null,
          }, where: 'user_id = ? AND challenge_id = ?', whereArgs: [userId, challengeId]);
          completed = isCompleted;
        }
      });
      return Result.success(completed);
    } catch (e) {
      return Result.failure(StorageError('Failed to update challenge progress: $e'));
    }
  }

  @override
  Future<Result<bool>> unlockAchievement(String userId, String type, String title, String description, int xpReward, String icon) async {
    try {
      final db = await _dbService.database;
      final id = '\${userId}_$type';
      final existing = await db.query('achievements', where: 'id = ?', whereArgs: [id]);
      if (existing.isNotEmpty) return Result.success(false);

      await db.insert('achievements', {
        'id': id,
        'user_id': userId,
        'type': type,
        'title': title,
        'description': description,
        'xp_reward': xpReward,
        'icon': icon,
        'unlocked_at': DateTime.now().toIso8601String(),
      });
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to unlock achievement: $e'));
    }
  }

  @override
  Future<Result<List<Map<String, dynamic>>>> getLeaderboard(int limit) async {
    try {
      final db = await _dbService.database;
      final result = await db.query(
        'users',
        columns: ['id', 'username', 'full_name', 'photo_url', 'xp', 'rider_level'],
        orderBy: 'xp DESC',
        limit: limit,
      );
      return Result.success(result);
    } catch (e) {
      return Result.failure(StorageError('Failed to get leaderboard: $e'));
    }
  }
}
