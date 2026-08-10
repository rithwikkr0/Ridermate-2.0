import 'package:sqflite/sqflite.dart';
import '../../../core/errors/result.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/services/database_service.dart';
import '../models/emergency_contact_model.dart';
import '../models/sos_event_model.dart';

abstract class EmergencyRepository {
  Future<Result<List<EmergencyContact>>> getContacts({required String userId});
  Future<Result<EmergencyContact?>> getPrimaryContact({required String userId});
  Future<Result<EmergencyContact>> saveContact(EmergencyContact contact);
  Future<Result<bool>> deleteContact(String id, {required String userId});
  Future<Result<bool>> setPrimaryContact(String id, {required String userId});

  Future<Result<SosEventModel>> saveSosEvent(SosEventModel event);
  Future<Result<List<SosEventModel>>> getSosEvents({required String userId});
  Future<Result<SosEventModel?>> getActiveSosEvent({required String userId});
  Future<Result<SosEventModel>> updateSosEvent(SosEventModel event);
}

class SqliteEmergencyRepository implements EmergencyRepository {
  Future<Database> get _db async => DatabaseService.instance.database;

  @override
  Future<Result<List<EmergencyContact>>> getContacts({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'emergency_contacts',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'is_primary DESC, name ASC',
      );
      final contacts = rows.map((r) => EmergencyContact.fromMap(r)).toList();
      return Result.success(contacts);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch emergency contacts: $e'));
    }
  }

  @override
  Future<Result<EmergencyContact?>> getPrimaryContact({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'emergency_contacts',
        where: 'user_id = ? AND is_primary = 1',
        whereArgs: [userId],
        limit: 1,
      );
      if (rows.isEmpty) {
        // Fallback to first contact if no primary explicitly set
        final fallbackRows = await db.query(
          'emergency_contacts',
          where: 'user_id = ?',
          whereArgs: [userId],
          limit: 1,
        );
        if (fallbackRows.isEmpty) return Result.success(null);
        return Result.success(EmergencyContact.fromMap(fallbackRows.first));
      }
      return Result.success(EmergencyContact.fromMap(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch primary contact: $e'));
    }
  }

  @override
  Future<Result<EmergencyContact>> saveContact(EmergencyContact contact) async {
    try {
      final db = await _db;

      // If contact is marked primary or it's the first contact, clear previous primary flags
      if (contact.isPrimary) {
        await db.update(
          'emergency_contacts',
          {'is_primary': 0},
          where: 'user_id = ?',
          whereArgs: [contact.userId],
        );
      }

      await db.insert(
        'emergency_contacts',
        contact.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return Result.success(contact);
    } catch (e) {
      return Result.failure(StorageError('Failed to save emergency contact: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteContact(String id, {required String userId}) async {
    try {
      final db = await _db;
      final count = await db.delete(
        'emergency_contacts',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete emergency contact: $e'));
    }
  }

  @override
  Future<Result<bool>> setPrimaryContact(String id, {required String userId}) async {
    try {
      final db = await _db;
      await db.transaction((txn) async {
        await txn.update(
          'emergency_contacts',
          {'is_primary': 0},
          where: 'user_id = ?',
          whereArgs: [userId],
        );
        await txn.update(
          'emergency_contacts',
          {'is_primary': 1},
          where: 'id = ? AND user_id = ?',
          whereArgs: [id, userId],
        );
      });
      return Result.success(true);
    } catch (e) {
      return Result.failure(StorageError('Failed to set primary contact: $e'));
    }
  }

  @override
  Future<Result<SosEventModel>> saveSosEvent(SosEventModel event) async {
    try {
      final db = await _db;
      await db.insert(
        'sos_events',
        event.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(event);
    } catch (e) {
      return Result.failure(StorageError('Failed to save SOS event: $e'));
    }
  }

  @override
  Future<Result<List<SosEventModel>>> getSosEvents({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'sos_events',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'started_at DESC',
      );
      final events = rows.map((r) => SosEventModel.fromMap(r)).toList();
      return Result.success(events);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch SOS events: $e'));
    }
  }

  @override
  Future<Result<SosEventModel?>> getActiveSosEvent({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'sos_events',
        where: "user_id = ? AND status IN ('initiated', 'countdown', 'active')",
        whereArgs: [userId],
        orderBy: 'started_at DESC',
        limit: 1,
      );
      if (rows.isEmpty) return Result.success(null);
      return Result.success(SosEventModel.fromMap(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch active SOS event: $e'));
    }
  }

  @override
  Future<Result<SosEventModel>> updateSosEvent(SosEventModel event) async {
    try {
      final db = await _db;
      await db.update(
        'sos_events',
        event.toMap(),
        where: 'id = ? AND user_id = ?',
        whereArgs: [event.id, event.userId],
      );
      return Result.success(event);
    } catch (e) {
      return Result.failure(StorageError('Failed to update SOS event: $e'));
    }
  }
}
