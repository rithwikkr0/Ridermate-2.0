import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/garage/models/garage_models.dart';
import 'package:ridermate/features/garage/repositories/sqlite_garage_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({});
  });

  group('Garage & Vehicle Management System Tests', () {
    late SqliteGarageRepository repo;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE IF EXISTS vehicles');
      await db.execute('DROP TABLE IF EXISTS maintenance_records');
      await db.execute('''
        CREATE TABLE vehicles (
          id                   TEXT PRIMARY KEY,
          user_id              TEXT NOT NULL,
          brand                TEXT NOT NULL,
          model                TEXT NOT NULL,
          variant              TEXT NOT NULL DEFAULT '',
          year                 INTEGER NOT NULL,
          registration_number  TEXT NOT NULL DEFAULT '',
          fuel_type            TEXT NOT NULL DEFAULT 'Petrol',
          engine_cc            INTEGER NOT NULL DEFAULT 0,
          color                TEXT NOT NULL DEFAULT '',
          odometer_km          REAL NOT NULL DEFAULT 0.0,
          purchase_date        TEXT,
          insurance_expiry     TEXT,
          puc_expiry           TEXT,
          last_service_date    TEXT,
          next_service_date    TEXT,
          last_service_odometer REAL NOT NULL DEFAULT 0.0,
          service_interval_km  REAL NOT NULL DEFAULT 5000.0,
          service_interval_days INTEGER NOT NULL DEFAULT 180,
          is_default           INTEGER NOT NULL DEFAULT 0,
          is_primary           INTEGER NOT NULL DEFAULT 0
        )
      ''');
      await db.execute('''
        CREATE TABLE maintenance_records (
          id                  TEXT PRIMARY KEY,
          vehicle_id          TEXT NOT NULL,
          user_id             TEXT NOT NULL,
          service_type        TEXT NOT NULL,
          date                TEXT NOT NULL,
          odometer            REAL NOT NULL DEFAULT 0.0,
          cost                REAL NOT NULL DEFAULT 0.0,
          workshop            TEXT NOT NULL DEFAULT '',
          notes               TEXT NOT NULL DEFAULT '',
          parts_replaced_json TEXT NOT NULL DEFAULT '[]',
          created_at          TEXT NOT NULL
        )
      ''');
      repo = SqliteGarageRepository();
    });

    test('1. Save and fetch vehicle with registration masking', () async {
      const v = VehicleModel(
        id: 'v1',
        userId: 'user_A',
        brand: 'Royal Enfield',
        model: 'Classic 350',
        year: 2023,
        registrationNumber: 'KA01AB1234',
        odometerKm: 12000.0,
        isPrimary: true,
      );

      final saveRes = await repo.saveVehicle(v);
      expect(saveRes.isSuccess, true);

      final listRes = await repo.getVehicles(userId: 'user_A');
      expect(listRes.isSuccess, true);
      expect(listRes.dataOrNull?.length, 1);
      final fetched = listRes.dataOrNull!.first;
      expect(fetched.brand, 'Royal Enfield');
      expect(fetched.maskedRegistrationNumber, 'KA01****34');
      expect(fetched.isPrimary, true);
    });

    test('2. Primary vehicle switching clears primary on old vehicles', () async {
      const v1 = VehicleModel(id: 'v1', userId: 'user_A', brand: 'Honda', model: 'CB350', year: 2022, registrationNumber: 'KA02XY1111', isPrimary: true);
      const v2 = VehicleModel(id: 'v2', userId: 'user_A', brand: 'KTM', model: 'Duke 390', year: 2024, registrationNumber: 'KA02XY2222', isPrimary: false);

      await repo.saveVehicle(v1);
      await repo.saveVehicle(v2);

      await repo.setPrimaryVehicle(id: 'v2', userId: 'user_A');

      final list = (await repo.getVehicles(userId: 'user_A')).dataOrNull!;
      final p1 = list.firstWhere((x) => x.id == 'v1');
      final p2 = list.firstWhere((x) => x.id == 'v2');

      expect(p1.isPrimary, false);
      expect(p2.isPrimary, true);
    });

    test('3. Add maintenance record updates vehicle odometer and service due info', () async {
      const v = VehicleModel(
        id: 'v1',
        userId: 'user_A',
        brand: 'Yamaha',
        model: 'R15',
        year: 2023,
        registrationNumber: 'KA03ZZ9999',
        odometerKm: 10000.0,
        lastServiceOdometer: 5000.0,
        serviceIntervalKm: 5000.0,
      );
      await repo.saveVehicle(v);

      final rec = MaintenanceRecord(
        id: 'm1',
        vehicleId: 'v1',
        userId: 'user_A',
        serviceType: 'Full Service',
        date: DateTime(2026, 8, 1),
        odometer: 11500.0,
        cost: 3200.0,
        createdAt: DateTime.now(),
      );

      final addRes = await repo.addMaintenanceRecord(rec);
      expect(addRes.isSuccess, true);

      final history = (await repo.getServiceHistory(vehicleId: 'v1', userId: 'user_A')).dataOrNull!;
      expect(history.length, 1);
      expect(history.first.cost, 3200.0);

      final updatedV = (await repo.getPrimaryVehicle(userId: 'user_A')).dataOrNull!;
      expect(updatedV.odometerKm, 11500.0);
      expect(updatedV.lastServiceOdometer, 11500.0);
    });

    test('4. Reminders engine flags expiring insurance, PUC, and due service', () async {
      final now = DateTime.now();
      final v = VehicleModel(
        id: 'v_rem',
        userId: 'user_A',
        brand: 'BMW',
        model: 'G310GS',
        year: 2023,
        registrationNumber: 'KA05MH1000',
        odometerKm: 15000.0,
        lastServiceOdometer: 9000.0,
        serviceIntervalKm: 5000.0, // 9000 + 5000 = 14000 (15000 is due!)
        insuranceExpiry: now.add(const Duration(days: 10)), // expiring soon
        pucExpiry: now.subtract(const Duration(days: 2)), // expired
      );
      await repo.saveVehicle(v);

      final reminders = (await repo.getReminders(userId: 'user_A')).dataOrNull!;
      expect(reminders.length, 3);

      final insRem = reminders.firstWhere((r) => r.category == 'insurance');
      final pucRem = reminders.firstWhere((r) => r.category == 'puc');
      final servRem = reminders.firstWhere((r) => r.category == 'service');

      expect(insRem.isOverdue, false);
      expect(pucRem.isOverdue, true);
      expect(servRem.title.contains('Service Due'), true);
    });
  });
}
