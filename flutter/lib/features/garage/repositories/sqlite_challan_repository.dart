import 'package:ridermate/core/errors/result.dart';
import 'package:ridermate/core/errors/app_error.dart';
import 'package:ridermate/core/services/database_service.dart';
import '../models/challan_model.dart';
import 'challan_repository.dart';

class SqliteChallanRepository implements ChallanRepository {
  final DatabaseService _dbService;

  SqliteChallanRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<Result<void, AppError>> addChallan(ChallanModel challan) async {
    try {
      final db = await _dbService.database;
      await db.insert('challans', challan.toMap());
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppError(
        message: 'Failed to add challan',
        code: AppErrorCode.databaseError,
        details: e,
      ));
    }
  }

  @override
  Future<Result<List<ChallanModel>, AppError>> getChallansByVehicle(String vehicleId) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'challans',
        where: 'vehicle_id = ?',
        whereArgs: [vehicleId],
        orderBy: 'date DESC',
      );
      return Result.success(maps.map((e) => ChallanModel.fromMap(e)).toList());
    } catch (e) {
      return Result.failure(AppError(
        message: 'Failed to load challans',
        code: AppErrorCode.databaseError,
        details: e,
      ));
    }
  }

  @override
  Future<Result<List<ChallanModel>, AppError>> getChallansByUser(String userId) async {
    try {
      final db = await _dbService.database;
      final maps = await db.query(
        'challans',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'date DESC',
      );
      return Result.success(maps.map((e) => ChallanModel.fromMap(e)).toList());
    } catch (e) {
      return Result.failure(AppError(
        message: 'Failed to load challans',
        code: AppErrorCode.databaseError,
        details: e,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> updateChallanStatus(String id, String status) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'challans',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppError(
        message: 'Failed to update challan status',
        code: AppErrorCode.databaseError,
        details: e,
      ));
    }
  }

  @override
  Future<Result<void, AppError>> deleteChallan(String id) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'challans',
        where: 'id = ?',
        whereArgs: [id],
      );
      return const Result.success(null);
    } catch (e) {
      return Result.failure(AppError(
        message: 'Failed to delete challan',
        code: AppErrorCode.databaseError,
        details: e,
      ));
    }
  }
}
