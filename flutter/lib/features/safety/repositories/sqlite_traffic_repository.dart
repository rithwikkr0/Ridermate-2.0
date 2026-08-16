import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/services/database_service.dart';
import '../models/traffic_violation_model.dart';

abstract class TrafficRepository {
  Future<Result<TrafficViolation>> recordViolation(TrafficViolation violation);
  Future<Result<List<TrafficViolation>>> getViolations({required String userId, int limit = 50});
  Future<Result<int>> getSafetyScore({required String userId});
}

/// RiderMate 2.0 — Production Sqlite Traffic Violation Repository
class SqliteTrafficRepository implements TrafficRepository {
  final DatabaseService _dbService;

  SqliteTrafficRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<Result<TrafficViolation>> recordViolation(TrafficViolation violation) async {
    try {
      final db = await _db;
      await db.insert(
        'traffic_violations',
        violation.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(violation);
    } catch (e) {
      return Result.failure(StorageError('Failed to record traffic violation: $e'));
    }
  }

  @override
  Future<Result<List<TrafficViolation>>> getViolations({
    required String userId,
    int limit = 50,
  }) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'traffic_violations',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'timestamp DESC',
        limit: limit,
      );
      final list = rows.map((map) => TrafficViolation.fromMap(map)).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch traffic violations: $e'));
    }
  }

  @override
  Future<Result<int>> getSafetyScore({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'traffic_violations',
        columns: ['points'],
        where: "user_id = ? AND status = 'active'",
        whereArgs: [userId],
      );
      int totalDeducted = 0;
      for (final r in rows) {
        totalDeducted += (r['points'] as num? ?? 0).toInt();
      }
      final score = (100 - totalDeducted).clamp(0, 100);
      return Result.success(score);
    } catch (e) {
      return Result.failure(StorageError('Failed to calculate safety score: $e'));
    }
  }
}
