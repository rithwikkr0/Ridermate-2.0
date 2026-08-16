import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/features/safety/models/traffic_violation_model.dart';
import 'package:ridermate/features/safety/repositories/sqlite_traffic_repository.dart';
import 'package:ridermate/features/safety/services/traffic_points_engine.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
    SharedPreferences.setMockInitialValues({'user_id': 'user_A'});
  });

  group('Traffic Intelligence & Safety Points Engine Tests', () {
    late SqliteTrafficRepository repo;

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('DROP TABLE IF EXISTS traffic_violations');
      await db.execute('DROP TABLE IF EXISTS notifications');
      await db.execute('DROP TABLE IF EXISTS notification_preferences');
      await db.execute('''
        CREATE TABLE traffic_violations (
          id          TEXT PRIMARY KEY,
          user_id     TEXT NOT NULL,
          ride_id     TEXT,
          vehicle_id  TEXT,
          type        TEXT NOT NULL,
          severity    TEXT NOT NULL DEFAULT 'low',
          points      INTEGER NOT NULL DEFAULT 0,
          timestamp   TEXT NOT NULL,
          latitude    REAL,
          longitude   REAL,
          speed       REAL NOT NULL DEFAULT 0.0,
          speed_limit REAL NOT NULL DEFAULT 80.0,
          confidence  REAL NOT NULL DEFAULT 1.0,
          source      TEXT NOT NULL DEFAULT 'telemetry',
          evidence    TEXT NOT NULL DEFAULT '',
          status      TEXT NOT NULL DEFAULT 'active'
        )
      ''');
      await db.execute('''
        CREATE TABLE notifications (
          id         TEXT PRIMARY KEY,
          user_id    TEXT NOT NULL,
          type       TEXT NOT NULL,
          title      TEXT NOT NULL,
          body       TEXT NOT NULL,
          created_at TEXT NOT NULL,
          read_at    TEXT,
          route      TEXT,
          entity_id  TEXT,
          priority   TEXT NOT NULL DEFAULT 'normal',
          payload    TEXT,
          image_url  TEXT,
          expires_at TEXT
        )
      ''');
      await db.execute('''
        CREATE TABLE notification_preferences (
          user_id             TEXT PRIMARY KEY,
          emergency_enabled   INTEGER NOT NULL DEFAULT 1,
          safety_enabled      INTEGER NOT NULL DEFAULT 1,
          ride_enabled        INTEGER NOT NULL DEFAULT 1,
          social_enabled      INTEGER NOT NULL DEFAULT 1,
          ai_enabled          INTEGER NOT NULL DEFAULT 1,
          maintenance_enabled INTEGER NOT NULL DEFAULT 1,
          achievement_enabled INTEGER NOT NULL DEFAULT 1,
          system_enabled      INTEGER NOT NULL DEFAULT 1,
          sound_enabled       INTEGER NOT NULL DEFAULT 1,
          vibration_enabled   INTEGER NOT NULL DEFAULT 1
        )
      ''');
      repo = SqliteTrafficRepository();
    });

    test('1. Initial Safety Score is 100 when no violations exist', () async {
      final scoreRes = await repo.getSafetyScore(userId: 'user_A');
      expect(scoreRes.isSuccess, true);
      expect(scoreRes.dataOrNull, 100);
    });

    test('2. Evaluate overspeed generates TrafficViolation with correct deduction', () async {
      await TrafficPointsEngine.instance.evaluateOverspeed(
        userId: 'user_A',
        rideId: 'ride_101',
        currentSpeedKmh: 92.0, // 81-95 km/h -> -2 pts
      );

      final listRes = await repo.getViolations(userId: 'user_A');
      expect(listRes.isSuccess, true);
      expect(listRes.dataOrNull?.length, 1);
      final v = listRes.dataOrNull!.first;
      expect(v.type, ViolationType.overspeed);
      expect(v.pointsDeducted, 2);

      final scoreRes = await repo.getSafetyScore(userId: 'user_A');
      expect(scoreRes.dataOrNull, 98);
    });

    test('3. Severe overspeed (>110 km/h) deducts 10 points', () async {
      await TrafficPointsEngine.instance.evaluateOverspeed(
        userId: 'user_B',
        rideId: 'ride_202',
        currentSpeedKmh: 125.0, // >110 km/h -> -10 pts
      );

      final scoreRes = await repo.getSafetyScore(userId: 'user_B');
      expect(scoreRes.dataOrNull, 90);
    });

    test('4. Overspeed under threshold (<=80 km/h) generates no violation', () async {
      await TrafficPointsEngine.instance.evaluateOverspeed(
        userId: 'user_C',
        rideId: 'ride_303',
        currentSpeedKmh: 75.0,
      );

      final listRes = await repo.getViolations(userId: 'user_C');
      expect(listRes.dataOrNull?.isEmpty, true);

      final scoreRes = await repo.getSafetyScore(userId: 'user_C');
      expect(scoreRes.dataOrNull, 100);
    });
  });
}
