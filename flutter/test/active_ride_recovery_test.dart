import 'package:flutter_test/flutter_test.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:ridermate/core/services/database_service.dart';
import 'package:ridermate/core/services/location_service.dart';
import 'package:ridermate/features/rides/repositories/sqlite_ride_repository.dart';
import 'package:ridermate/features/rides/controllers/ride_controller.dart';
import 'package:ridermate/features/rides/models/active_ride_draft.dart';
import 'package:ridermate/features/rides/models/route_model.dart';

void main() {
  setUpAll(() {
    sqfliteFfiInit();
    databaseFactory = databaseFactoryFfi;
  });

  group('Active Ride Recovery & Persistence Tests', () {
    late SqliteRideRepository repository;
    late LocationService locationService;
    const testUserId = 'test_user_recovery';

    setUp(() async {
      final db = await DatabaseService.instance.database;
      await db.execute('''
        CREATE TABLE IF NOT EXISTS active_ride_draft (
          id              TEXT PRIMARY KEY,
          user_id         TEXT NOT NULL,
          ride_mode       TEXT NOT NULL DEFAULT 'solo',
          origin          TEXT NOT NULL DEFAULT '',
          destination     TEXT NOT NULL DEFAULT '',
          start_time      INTEGER NOT NULL,
          paused_total_ms INTEGER NOT NULL DEFAULT 0,
          is_paused       INTEGER NOT NULL DEFAULT 0,
          paused_at       INTEGER,
          distance_km     REAL NOT NULL DEFAULT 0.0,
          max_speed       REAL NOT NULL DEFAULT 0.0,
          updated_at      INTEGER NOT NULL
        )
      ''');
      await db.execute('''
        CREATE TABLE IF NOT EXISTS active_ride_points (
          draft_id    TEXT NOT NULL,
          point_index INTEGER NOT NULL,
          latitude    REAL NOT NULL,
          longitude   REAL NOT NULL,
          speed       REAL NOT NULL DEFAULT 0.0,
          timestamp   INTEGER NOT NULL,
          elevation   REAL NOT NULL DEFAULT 0.0,
          heading     REAL NOT NULL DEFAULT 0.0,
          accuracy    REAL NOT NULL DEFAULT 0.0,
          PRIMARY KEY (draft_id, point_index)
        )
      ''');
      await db.delete('active_ride_points');
      await db.delete('active_ride_draft');
      repository = SqliteRideRepository();
      locationService = MockLocationService();
    });

    test('saveActiveDraft and getActiveDraft persist ongoing ride state', () async {
      final startTime = DateTime.now().subtract(const Duration(minutes: 10));
      final points = [
        RoutePoint(
          latitude: 19.0760,
          longitude: 72.8777,
          speedKmh: 45.0,
          timestamp: startTime.millisecondsSinceEpoch,
          elevationMeters: 10,
          headingDegrees: 180,
          accuracyMeters: 4.5,
        ),
        RoutePoint(
          latitude: 19.0770,
          longitude: 72.8787,
          speedKmh: 48.0,
          timestamp: startTime.millisecondsSinceEpoch + 5000,
          elevationMeters: 12,
          headingDegrees: 185,
          accuracyMeters: 3.5,
        ),
      ];

      final draft = ActiveRideDraft(
        id: 'draft_123',
        userId: testUserId,
        rideMode: 'solo',
        origin: 'Mumbai Central',
        destination: 'Bandra West',
        startTime: startTime,
        pausedTotal: const Duration(seconds: 30),
        isPaused: false,
        distanceKm: 2.5,
        maxSpeedKmh: 52.0,
        points: points,
      );

      final saveResult = await repository.saveActiveDraft(draft);
      expect(saveResult.isSuccess, isTrue);

      final getResult = await repository.getActiveDraft(testUserId);
      expect(getResult.isSuccess, isTrue);
      final restored = getResult.dataOrNull;
      expect(restored, isNotNull);
      expect(restored!.id, equals('draft_123'));
      expect(restored.userId, equals(testUserId));
      expect(restored.distanceKm, equals(2.5));
      expect(restored.points.length, equals(2));
      expect(restored.points.first.latitude, equals(19.0760));
    });

    test('clearActiveDraft removes persisted active draft', () async {
      final draft = ActiveRideDraft(
        id: 'draft_to_clear',
        userId: testUserId,
        rideMode: 'solo',
        origin: '',
        destination: '',
        startTime: DateTime.now(),
        pausedTotal: Duration.zero,
        isPaused: false,
        distanceKm: 1.0,
        maxSpeedKmh: 30.0,
        points: [
          RoutePoint(
            latitude: 19.0,
            longitude: 72.0,
            speedKmh: 30.0,
            timestamp: DateTime.now().millisecondsSinceEpoch,
            elevationMeters: 0,
            headingDegrees: 0,
            accuracyMeters: 5,
          ),
        ],
      );

      await repository.saveActiveDraft(draft);
      await repository.clearActiveDraft(testUserId);

      final getResult = await repository.getActiveDraft(testUserId);
      expect(getResult.isSuccess, isTrue);
      expect(getResult.dataOrNull, isNull);
    });

    test('RideController restores active tracking state on cold start', () async {
      final controller1 = RideController(repository, locationService);
      controller1.setUserId(testUserId);

      // Start ride and record points
      await controller1.startRide(mode: 'group', origin: 'Point A', destination: 'Point B');
      expect(controller1.isTracking, isTrue);

      // Simulate app process killed (create new RideController instance)
      final controller2 = RideController(repository, locationService);
      controller2.setUserId(testUserId);

      final restored = await controller2.restoreActiveRideIfAny();
      expect(restored, isTrue);
      expect(controller2.isTracking, isTrue);
      expect(controller2.recordedPoints.isNotEmpty, isTrue);

      // Stop ride and verify active draft is cleared
      await controller2.stopRide();
      expect(controller2.isTracking, isFalse);

      final draftResult = await repository.getActiveDraft(testUserId);
      expect(draftResult.dataOrNull, isNull);
    });
  });
}
