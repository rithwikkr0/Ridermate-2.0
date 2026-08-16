import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/database_service.dart';
import '../models/challan_model.dart';
import 'challan_repository.dart';

class SqliteChallanRepository implements ChallanRepository {
  final DatabaseService _dbService;

  SqliteChallanRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  @override
  Future<Result<void>> addChallan(ChallanModel challan) async {
    try {
      final db = await _dbService.database;
      await db.insert('challans', challan.toMap());
      return Result.success(null);
    } catch (e) {
      return Result.failure(StorageError('Failed to add challan'));
    }
  }

  @override
  Future<Result<List<ChallanModel>>> getChallansByVehicle(String vehicleId) async {
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
      return Result.failure(StorageError('Failed to load challans'));
    }
  }

  @override
  Future<Result<List<ChallanModel>>> getChallansByUser(String userId) async {
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
      return Result.failure(StorageError('Failed to load challans'));
    }
  }

  @override
  Future<Result<void>> updateChallanStatus(String id, String status) async {
    try {
      final db = await _dbService.database;
      await db.update(
        'challans',
        {'status': status},
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(StorageError('Failed to update challan status'));
    }
  }

  @override
  Future<Result<void>> deleteChallan(String id) async {
    try {
      final db = await _dbService.database;
      await db.delete(
        'challans',
        where: 'id = ?',
        whereArgs: [id],
      );
      return Result.success(null);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete challan'));
    }
  }
}
