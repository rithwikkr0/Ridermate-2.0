import 'package:sqflite/sqflite.dart';
import '../../../core/errors/app_error.dart';
import '../../../core/errors/result.dart';
import '../../../core/services/database_service.dart';
import '../models/garage_models.dart';
import 'garage_repository.dart';
export 'garage_repository.dart';

/// RiderMate 2.0 — Production Sqlite Garage Repository
class SqliteGarageRepository implements GarageRepository {
  final DatabaseService _dbService;

  SqliteGarageRepository({DatabaseService? dbService})
      : _dbService = dbService ?? DatabaseService.instance;

  Future<Database> get _db async => await _dbService.database;

  @override
  Future<List<FuelRecord>> getFuelLogs() async => [];

  @override
  Future<Result<List<VehicleModel>>> getVehicles({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'vehicles',
        where: 'user_id = ?',
        whereArgs: [userId],
        orderBy: 'is_primary DESC, brand ASC',
      );
      final list = rows.map((map) => VehicleModel.fromMap(map)).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch vehicles: $e'));
    }
  }

  @override
  Future<Result<VehicleModel?>> getPrimaryVehicle({required String userId}) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'vehicles',
        where: 'user_id = ? AND (is_primary = 1 OR is_default = 1)',
        whereArgs: [userId],
        limit: 1,
      );
      if (rows.isEmpty) {
        final all = await db.query(
          'vehicles',
          where: 'user_id = ?',
          whereArgs: [userId],
          limit: 1,
        );
        if (all.isEmpty) return Result.success(null);
        return Result.success(VehicleModel.fromMap(all.first));
      }
      return Result.success(VehicleModel.fromMap(rows.first));
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch primary vehicle: $e'));
    }
  }

  @override
  Future<Result<VehicleModel>> saveVehicle(VehicleModel vehicle) async {
    try {
      final db = await _db;
      if (vehicle.isPrimary) {
        // Clear primary flag on other vehicles
        await db.update(
          'vehicles',
          {'is_primary': 0, 'is_default': 0},
          where: 'user_id = ?',
          whereArgs: [vehicle.userId],
        );
      }

      await db.insert(
        'vehicles',
        vehicle.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return Result.success(vehicle);
    } catch (e) {
      return Result.failure(StorageError('Failed to save vehicle: $e'));
    }
  }

  @override
  Future<Result<bool>> deleteVehicle({required String id, required String userId}) async {
    try {
      final db = await _db;
      final count = await db.delete(
        'vehicles',
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to delete vehicle: $e'));
    }
  }

  @override
  Future<Result<bool>> setPrimaryVehicle({required String id, required String userId}) async {
    try {
      final db = await _db;
      await db.update(
        'vehicles',
        {'is_primary': 0, 'is_default': 0},
        where: 'user_id = ?',
        whereArgs: [userId],
      );
      final count = await db.update(
        'vehicles',
        {'is_primary': 1, 'is_default': 1},
        where: 'id = ? AND user_id = ?',
        whereArgs: [id, userId],
      );
      return Result.success(count > 0);
    } catch (e) {
      return Result.failure(StorageError('Failed to set primary vehicle: $e'));
    }
  }

  @override
  Future<Result<List<MaintenanceRecord>>> getServiceHistory({
    required String vehicleId,
    required String userId,
  }) async {
    try {
      final db = await _db;
      final rows = await db.query(
        'maintenance_records',
        where: 'vehicle_id = ? AND user_id = ?',
        whereArgs: [vehicleId, userId],
        orderBy: 'date DESC',
      );
      final list = rows.map((map) => MaintenanceRecord.fromMap(map)).toList();
      return Result.success(list);
    } catch (e) {
      return Result.failure(StorageError('Failed to fetch maintenance records: $e'));
    }
  }

  @override
  Future<Result<MaintenanceRecord>> addMaintenanceRecord(MaintenanceRecord record) async {
    try {
      final db = await _db;
      await db.insert(
        'maintenance_records',
        record.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      // Update vehicle's last service info and odometer
      final vRes = await db.query('vehicles', where: 'id = ?', whereArgs: [record.vehicleId]);
      if (vRes.isNotEmpty) {
        final vehicle = VehicleModel.fromMap(vRes.first);
        final nextDate = record.date.add(Duration(days: vehicle.serviceIntervalDays));
        final updatedOdo = record.odometer > vehicle.odometerKm ? record.odometer : vehicle.odometerKm;

        await db.update(
          'vehicles',
          {
            'last_service_date': record.date.toIso8601String(),
            'last_service_odometer': record.odometer,
            'next_service_date': nextDate.toIso8601String(),
            'odometer_km': updatedOdo,
          },
          where: 'id = ?',
          whereArgs: [record.vehicleId],
        );
      }

      return Result.success(record);
    } catch (e) {
      return Result.failure(StorageError('Failed to save maintenance record: $e'));
    }
  }

  @override
  Future<Result<List<GarageReminder>>> getReminders({required String userId}) async {
    try {
      final vRes = await getVehicles(userId: userId);
      final vehicles = vRes.dataOrNull ?? [];
      final List<GarageReminder> reminders = [];

      for (final v in vehicles) {
        // Insurance reminder
        if (v.insuranceExpiry != null) {
          final days = v.insuranceDaysRemaining!;
          if (days <= 30) {
            reminders.add(GarageReminder(
              id: 'rem_ins_${v.id}',
              vehicleId: v.id,
              title: days < 0 ? 'Insurance EXPIRED (${v.brand} ${v.model})' : 'Insurance Expiring Soon',
              description: days < 0
                  ? 'Expired ${days.abs()} days ago. Renew now to stay legal.'
                  : 'Expires in $days days. Click to update policy.',
              dueDate: v.insuranceExpiry!,
              isOverdue: days < 0,
              category: 'insurance',
            ));
          }
        }

        // PUC reminder
        if (v.pucExpiry != null) {
          final days = v.pucDaysRemaining!;
          if (days <= 15) {
            reminders.add(GarageReminder(
              id: 'rem_puc_${v.id}',
              vehicleId: v.id,
              title: days < 0 ? 'PUC Certificate EXPIRED (${v.brand} ${v.model})' : 'PUC Certificate Renewal Due',
              description: days < 0
                  ? 'Expired ${days.abs()} days ago. Obtain new PUC test.'
                  : 'Expires in $days days.',
              dueDate: v.pucExpiry!,
              isOverdue: days < 0,
              category: 'puc',
            ));
          }
        }

        // Service reminder
        if (v.isServiceDue) {
          reminders.add(GarageReminder(
            id: 'rem_service_${v.id}',
            vehicleId: v.id,
            title: 'Service Due (${v.brand} ${v.model})',
            description: v.serviceKmRemaining <= 0
                ? 'Scheduled service interval reached (${v.odometerKm.toStringAsFixed(0)} km).'
                : 'Service due on ${v.calculatedNextServiceDate.day}/${v.calculatedNextServiceDate.month}/${v.calculatedNextServiceDate.year}',
            dueDate: v.calculatedNextServiceDate,
            isOverdue: DateTime.now().isAfter(v.calculatedNextServiceDate),
            category: 'service',
          ));
        }
      }

      return Result.success(reminders);
    } catch (e) {
      return Result.failure(StorageError('Failed to calculate garage reminders: $e'));
    }
  }
}
