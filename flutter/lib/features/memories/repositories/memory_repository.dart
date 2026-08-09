import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/database_service.dart';
import '../models/memory_model.dart';

abstract class MemoryRepository {
  Future<Result<MemoryModel>> createMemory(MemoryModel memory);
  Future<Result<List<MemoryModel>>> getMemories({required String userId});
  Future<Result<MemoryModel?>> getMemoryById(String id, {required String userId});
  Future<Result<MemoryModel>> updateMemory(MemoryModel memory);
  Future<Result<bool>> deleteMemory(String id, {required String userId});
  Future<Result<List<MemoryModel>>> getMemoriesForRide(String rideId, {required String userId});
  Future<Result<List<MemoryModel>>> getMemoriesWithLocation({required String userId});
  Future<Result<List<MemoryModel>>> searchMemories(String query, {required String userId});
}

class SqliteMemoryRepository implements MemoryRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  /// Copies an image file to app document directory (`memories/memory_<id>.<ext>`)
  Future<String> saveImageToLocalStorage(String sourcePath, String memoryId) async {
    final file = File(sourcePath);
    if (!await file.exists()) {
      return sourcePath; // fallback to given path if not a local file
    }
    final appDir = await getApplicationDocumentsDirectory();
    final memoriesDir = Directory(p.join(appDir.path, 'memories'));
    if (!await memoriesDir.exists()) {
      await memoriesDir.create(recursive: true);
    }
    final ext = p.extension(sourcePath).isEmpty ? '.jpg' : p.extension(sourcePath);
    final targetPath = p.join(memoriesDir.path, 'memory_$memoryId$ext');
    final copiedFile = await file.copy(targetPath);
    return copiedFile.path;
  }

  /// Deletes persistent image file if it exists in local app storage
  Future<void> deleteImageFromLocalStorage(String path) async {
    try {
      final file = File(path);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (_) {}
  }

  @override
  Future<Result<MemoryModel>> createMemory(MemoryModel memory) async {
    try {
      final db = await _db;

      // Copy image to persistent app storage
      String persistentImagePath = memory.imagePath;
      if (!memory.imagePath.startsWith('assets/')) {
        persistentImagePath = await saveImageToLocalStorage(memory.imagePath, memory.id);
      }

      final savedMemory = memory.copyWith(imagePath: persistentImagePath);

      await db.insert(
        'memories',
        savedMemory.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(savedMemory);
    } catch (e) {
      return Result.failure(StorageError('Failed to create memory: $e'));
    }
  }

  @override
  Future<Result<List<MemoryModel>>> getMemories({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'memories',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      final memories = rows.map((r) => MemoryModel.fromMap(r)).toList();
      return Result.success(memories);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch memories: $e'));
    }
  }

  @override
  Future<Result<MemoryModel?>> getMemoryById(String id, {required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'memories',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      if (rows.isEmpty) return Result.success(null);
      return Result.success(MemoryModel.fromMap(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch memory: $e'));
    }
  }

  @override
  Future<Result<MemoryModel>> updateMemory(MemoryModel memory) async {
    try {
      final db = await _db;
      final updatedMemory = memory.copyWith(updatedAt: DateTime.now());
      await db.update(
        'memories',
        updatedMemory.toMap(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [memory.id, memory.userId],
      );
      return Result.success(updatedMemory);
    } catch (e) {
      return Result.failure(StorageError('Failed to update memory: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteMemory(String id, {required String userId}) async {
    try {
      final db = await _db;
      // Get existing record to find local image path for cleanup
      final rows = await db.query(
        'memories',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      if (rows.isNotEmpty) {
        final memory = MemoryModel.fromMap(rows.first);
        await deleteImageFromLocalStorage(memory.imagePath);
        if (memory.thumbnailPath != null) {
          await deleteImageFromLocalStorage(memory.thumbnailPath!);
        }
      }

      final count = await db.delete(
        'memories',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete memory: $e'));
    }
  }

  @override
  Future<Result<List<MemoryModel>>> getMemoriesForRide(String rideId, {required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'memories',
        where: 'ride_id = ? AND user_id = ?',
        whereArgs: [rideId, userId],
        orderBy: 'created_at DESC',
      );
      final memories = rows.map((r) => MemoryModel.fromMap(r)).toList();
      return Result.success(memories);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch memories for ride: $e'));
    }
  }

  @override
  Future<Result<List<MemoryModel>>> getMemoriesWithLocation({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'memories',
        where: 'user_id = ? AND latitude IS NOT NULL AND longitude IS NOT NULL',
        whereArgs: [userId],
        orderBy: 'created_at DESC',
      );
      final memories = rows.map((r) => MemoryModel.fromMap(r)).toList();
      return Result.success(memories);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch geo-tagged memories: $e'));
    }
  }

  @override
  Future<Result<List<MemoryModel>>> searchMemories(String query, {required String userId}) async {
    try {
      final db = await _db;
      final pattern = '%${query.toLowerCase()}%';
      final rows = await db.query(
        'memories',
        where: 'user_id = ? AND (LOWER(caption) LIKE ? OR LOWER(location_name) LIKE ?)',
        whereArgs: [userId, pattern, pattern],
        orderBy: 'created_at DESC',
      );
      final memories = rows.map((r) => MemoryModel.fromMap(r)).toList();
      return Result.success(memories);
    } catch (e) {
      return Result.failure(StorageError('Failed to search memories: $e'));
    }
  }
}
