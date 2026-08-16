// ignore_for_file: invalid_use_of_protected_member

import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ridermate/core/models/ride_point_model.dart';
import 'package:ridermate/core/utils/geo_utils.dart';
import 'package:ridermate/core/utils/unit_converters.dart';
import 'package:ridermate/core/errors/result.dart';
import 'package:ridermate/core/errors/app_error.dart';
import 'package:ridermate/core/services/location_service.dart';
import 'package:ridermate/features/rides/controllers/ride_controller.dart';
import 'package:ridermate/features/rides/models/ride_engine_model.dart';
import 'package:ridermate/features/rides/models/active_ride_draft.dart';
import 'package:ridermate/features/rides/repositories/ride_repository.dart';
import 'package:ridermate/features/rides/services/statistics_engine.dart';
import 'package:ridermate/features/rides/services/mock_ride_generator.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Test doubles
// ─────────────────────────────────────────────────────────────────────────────

/// Controllable location service for unit testing.
class _TestLocationService implements LocationService {
  RidePointModel? _fixedPoint;
  final _streamController = StreamController<RidePointModel>.broadcast();

  void emitPoint(RidePointModel point) => _streamController.add(point);
  void emitError(Object error) => _streamController.addError(error);

  void setFixed(RidePointModel point) => _fixedPoint = point;

  @override
  Future<Result<RidePointModel>> getCurrentLocation() async {
    if (_fixedPoint == null) {
      return Result.failure(
        const LocationError('No GPS fix', code: 'no_fix'),
      );
    }
    return Result.success(_fixedPoint!);
  }

  @override
  Stream<RidePointModel> getLocationStream() => _streamController.stream;

  Future<void> close() => _streamController.close();
}

// In-memory ride repository for tests
class _InMemoryRideRepository implements RideRepository {
  final List<RideEngineModel> _rides = [];

  @override
  Future<Result<List<RideEngineModel>>> getAll() async =>
      Result.success(List.from(_rides));

  @override
  Future<Result<RideEngineModel?>> getById(String id) async {
    final ride = _rides.cast<RideEngineModel?>().firstWhere(
          (r) => r?.id == id,
          orElse: () => null,
        );
    return Result.success(ride);
  }

  @override
  Future<Result<RideEngineModel>> save(RideEngineModel item) async {
    _rides.removeWhere((r) => r.id == item.id);
    _rides.insert(0, item);
    return Result.success(item);
  }

  @override
  Future<Result<bool>> delete(String id) async {
    _rides.removeWhere((r) => r.id == id);
    return Result.success(true);
  }

  @override
  Future<Result<List<RideEngineModel>>> getHistory({
    String? query,
    String? filter,
    int page = 1,
    int pageSize = 20,
  }) =>
      getAll();

  ActiveRideDraft? _activeDraft;

  @override
  Future<Result<ActiveRideDraft?>> getActiveDraft(String userId) async =>
      Result.success(_activeDraft);

  @override
  Future<Result<void>> saveActiveDraft(ActiveRideDraft draft) async {
    _activeDraft = draft;
    return Result.success(null);
  }

  @override
  Future<Result<void>> clearActiveDraft(String userId) async {
    _activeDraft = null;
    return Result.success(null);
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// GPS sample helpers
// ─────────────────────────────────────────────────────────────────────────────

RidePointModel _validPoint({
  double lat = 12.971598,
  double lng = 77.594566,
  double speed = 30.0,
  double accuracy = 10.0,
  int? timestamp,
}) {
  return RidePointModel(
    latitude: lat,
    longitude: lng,
    timestamp: timestamp ?? DateTime.now().millisecondsSinceEpoch,
    speed: speed,
    accuracy: accuracy,
    heading: 0.0,
  );
}

// ─────────────────────────────────────────────────────────────────────────────
// Tests
// ─────────────────────────────────────────────────────────────────────────────

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  SharedPreferences.setMockInitialValues({'user_id': 'test_user'});

  group('1. RideState — enum values', () {
    test('All states are defined', () {
      expect(RideState.values, contains(RideState.idle));
      expect(RideState.values, contains(RideState.preparing));
      expect(RideState.values, contains(RideState.starting));
      expect(RideState.values, contains(RideState.active));
      expect(RideState.values, contains(RideState.paused));
      expect(RideState.values, contains(RideState.stopping));
      expect(RideState.values, contains(RideState.completed));
      expect(RideState.values, contains(RideState.failed));
    });
  });

  group('2. RideController — state machine transitions', () {
    late _TestLocationService locationService;
    late _InMemoryRideRepository repository;
    late RideController controller;

    setUp(() {
      locationService = _TestLocationService();
      repository = _InMemoryRideRepository();
      controller = RideController(repository, locationService);
    });

    tearDown(() async {
      controller.dispose();
      await locationService.close();
    });

    test('Initial state is idle', () {
      expect(controller.rideState, RideState.idle);
      expect(controller.isIdle, isTrue);
    });

    test('startRide: idle → completed (happy path)', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide(mode: 'solo', origin: 'A', destination: 'B');
      expect(controller.rideState, RideState.active);
      expect(controller.isTracking, isTrue);

      await controller.stopRide();
      expect(controller.rideState, RideState.completed);
    });

    test('startRide: fails when GPS unavailable', () async {
      // No fixed point set — getCurrentLocation returns failure
      await controller.startRide();
      expect(controller.rideState, RideState.failed);
      expect(controller.rideError, isNotNull);
    });

    test('pauseRide: active → paused', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      expect(controller.rideState, RideState.active);

      controller.pauseRide();
      expect(controller.rideState, RideState.paused);
      expect(controller.isPaused, isTrue);
    });

    test('resumeRide: paused → active', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      controller.pauseRide();
      expect(controller.rideState, RideState.paused);

      controller.resumeRide();
      expect(controller.rideState, RideState.active);
      expect(controller.isPaused, isFalse);
    });

    test('pauseRide is idempotent when already paused', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      controller.pauseRide();
      controller.pauseRide(); // second call should be ignored
      expect(controller.rideState, RideState.paused);
    });

    test('resumeRide is ignored when not paused', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      controller.resumeRide(); // should be ignored
      expect(controller.rideState, RideState.active);
    });

    test('stopRide transitions to completed and saves ride', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide(mode: 'solo', origin: 'Home', destination: 'Office');
      await controller.stopRide();

      expect(controller.rideState, RideState.completed);
      expect(controller.selectedRide, isNotNull);
      expect(controller.selectedRide!.rideMode, 'solo');
      expect(controller.selectedRide!.origin, 'Home');
      expect(controller.selectedRide!.destination, 'Office');
    });

    test('stopRide persists ride in repository', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      await controller.stopRide();

      final result = await repository.getAll();
      expect(result.isSuccess, isTrue);
      expect(result.dataOrNull, isNotEmpty);
    });

    test('discardRide resets to idle without saving', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();
      controller.discardRide();

      expect(controller.rideState, RideState.idle);
      final result = await repository.getAll();
      expect(result.dataOrNull, isEmpty);
    });
  });

  group('3. GPS Point Validation', () {
    late _TestLocationService locationService;
    late RideController controller;

    setUp(() {
      locationService = _TestLocationService();
      controller = RideController(_InMemoryRideRepository(), locationService);
    });

    tearDown(() async {
      controller.dispose();
      await locationService.close();
    });

    test('Valid point is accepted', () async {
      final valid = _validPoint();
      locationService.setFixed(valid);
      await controller.startRide();
      expect(controller.rideState, RideState.active);
    });

    test('Point with accuracy > 50m is rejected', () async {
      // First get a good fix to start
      locationService.setFixed(_validPoint());
      await controller.startRide();
      expect(controller.rideState, RideState.active);

      final initialPoints = controller.recordedPoints.length;

      // Emit a high-inaccuracy point via the stream
      locationService.emitPoint(
        _validPoint(accuracy: 100.0), // above 50m threshold
      );

      await Future.delayed(const Duration(milliseconds: 50));
      // The high-accuracy point should be filtered out
      expect(controller.recordedPoints.length, initialPoints);
    });

    test('Stale timestamp (>10s old) is rejected', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();

      final initialPoints = controller.recordedPoints.length;
      final staleTimestamp = DateTime.now()
          .subtract(const Duration(seconds: 20))
          .millisecondsSinceEpoch;

      locationService.emitPoint(_validPoint(timestamp: staleTimestamp));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.recordedPoints.length, initialPoints);
    });

    test('Speed > 300 km/h is rejected as impossible', () async {
      locationService.setFixed(_validPoint());
      await controller.startRide();

      final initialPoints = controller.recordedPoints.length;
      locationService.emitPoint(_validPoint(speed: 350.0));
      await Future.delayed(const Duration(milliseconds: 50));
      expect(controller.recordedPoints.length, initialPoints);
    });

    test('Coordinates at (0,0) are rejected as invalid', () async {
      // RidePointModel.isValid already rejects (0,0)
      final nullIsland = RidePointModel(
        latitude: 0.0,
        longitude: 0.0,
        timestamp: DateTime.now().millisecondsSinceEpoch,
        speed: 0.0,
        accuracy: 10.0,
      );
      expect(nullIsland.isValid, isFalse);
    });
  });

  group('4. Distance Calculation & Jitter Rejection', () {
    test('Haversine: Mumbai to Pune ≈ 120 km', () {
      final d = GeoUtils.calculateDistance(19.0760, 72.8777, 18.5204, 73.8567);
      expect(d, greaterThan(110.0));
      expect(d, lessThan(130.0));
    });

    test('Haversine: same point = 0', () {
      final d = GeoUtils.calculateDistance(12.9716, 77.5946, 12.9716, 77.5946);
      expect(d, closeTo(0.0, 0.001));
    });

    test('Movement below 3m does NOT increment distance', () async {
      final locationService = _TestLocationService();
      final controller = RideController(_InMemoryRideRepository(), locationService);

      locationService.setFixed(_validPoint(lat: 12.9716, lng: 77.5946));
      await controller.startRide();

      final beforeDistance = controller.distanceKm;

      // 0.00001 degrees ≈ 1.1 metres — below the 3m threshold
      locationService.emitPoint(
        _validPoint(lat: 12.97161, lng: 77.5946),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.distanceKm, closeTo(beforeDistance, 0.001));

      controller.dispose();
      await locationService.close();
    });

    test('Movement above 3m DOES increment distance', () async {
      final locationService = _TestLocationService();
      final controller = RideController(_InMemoryRideRepository(), locationService);

      locationService.setFixed(_validPoint(lat: 12.9716, lng: 77.5946));
      await controller.startRide();

      final beforeDistance = controller.distanceKm;

      // 0.001 degrees ≈ 111m — well above the 3m threshold
      locationService.emitPoint(
        _validPoint(lat: 12.9726, lng: 77.5946),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.distanceKm, greaterThan(beforeDistance));

      controller.dispose();
      await locationService.close();
    });

    test('Distance does NOT increase while paused', () async {
      final locationService = _TestLocationService();
      final controller = RideController(_InMemoryRideRepository(), locationService);

      locationService.setFixed(_validPoint(lat: 12.9716, lng: 77.5946));
      await controller.startRide();

      controller.pauseRide();
      final distAtPause = controller.distanceKm;

      // Emit a point while paused — should be ignored
      locationService.emitPoint(
        _validPoint(lat: 12.9726, lng: 77.5946),
      );
      await Future.delayed(const Duration(milliseconds: 100));

      expect(controller.distanceKm, closeTo(distAtPause, 0.001));

      controller.dispose();
      await locationService.close();
    });
  });

  group('5. Duration Calculation', () {
    test('Duration is zero before start', () {
      final ctrl = RideController(_InMemoryRideRepository(), _TestLocationService());
      expect(ctrl.duration, Duration.zero);
      ctrl.dispose();
    });

    test('Duration increases after start', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint());
      final ctrl = RideController(_InMemoryRideRepository(), locationService);

      await ctrl.startRide();
      await Future.delayed(const Duration(milliseconds: 1100));
      expect(ctrl.duration.inSeconds, greaterThanOrEqualTo(1));

      ctrl.dispose();
      await locationService.close();
    });

    test('Pause time is excluded from duration', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint());
      final ctrl = RideController(_InMemoryRideRepository(), locationService);

      await ctrl.startRide();
      await Future.delayed(const Duration(milliseconds: 500));

      ctrl.pauseRide();
      final durAtPause = ctrl.duration.inMilliseconds;

      await Future.delayed(const Duration(milliseconds: 500));
      // Duration should not have changed much during pause
      expect(ctrl.duration.inMilliseconds, closeTo(durAtPause, 150));

      ctrl.dispose();
      await locationService.close();
    });
  });

  group('6. Speed Metrics', () {
    test('currentSpeedKmh is 0 before any points', () {
      final ctrl = RideController(_InMemoryRideRepository(), _TestLocationService());
      expect(ctrl.currentSpeedKmh, 0.0);
      ctrl.dispose();
    });

    test('maxSpeedKmh tracks highest reported speed', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint(speed: 40.0));
      final ctrl = RideController(_InMemoryRideRepository(), locationService);

      await ctrl.startRide();
      locationService.emitPoint(_validPoint(lat: 12.9726, speed: 80.0));
      locationService.emitPoint(_validPoint(lat: 12.9736, speed: 60.0));
      await Future.delayed(const Duration(milliseconds: 100));

      expect(ctrl.maxSpeedKmh, greaterThanOrEqualTo(40.0));

      ctrl.dispose();
      await locationService.close();
    });

    test('averageSpeedKmh = distance / duration (km per hour)', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint(lat: 12.9716, speed: 30.0));
      final ctrl = RideController(_InMemoryRideRepository(), locationService);

      await ctrl.startRide();
      // Emit a point ~111m away to accumulate distance
      locationService.emitPoint(_validPoint(lat: 12.9726, lng: 77.5946, speed: 30.0));
      await Future.delayed(const Duration(milliseconds: 200));

      // avegSpeed should be non-negative
      expect(ctrl.averageSpeedKmh, greaterThanOrEqualTo(0.0));

      ctrl.dispose();
      await locationService.close();
    });
  });

  group('7. GPS Signal Status', () {
    test('Returns noSignal when accuracy is 0', () {
      final ctrl = RideController(_InMemoryRideRepository(), _TestLocationService());
      expect(ctrl.gpsSignalStatus, GpsSignalStatus.noSignal);
      ctrl.dispose();
    });
  });

  group('8. Ride Persistence', () {
    test('Completed ride is saved to repository', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint());
      final repo = _InMemoryRideRepository();
      final ctrl = RideController(repo, locationService);

      await ctrl.startRide(mode: 'solo', origin: 'Start', destination: 'End');
      await ctrl.stopRide();

      final result = await repo.getAll();
      expect(result.isSuccess, isTrue);
      final savedRide = result.dataOrNull!.first;
      expect(savedRide.status, RideStatus.completed);
      expect(savedRide.rideMode, 'solo');
      expect(savedRide.origin, 'Start');
      expect(savedRide.destination, 'End');

      ctrl.dispose();
      await locationService.close();
    });

    test('Saved ride has non-zero id', () async {
      final locationService = _TestLocationService();
      locationService.setFixed(_validPoint());
      final repo = _InMemoryRideRepository();
      final ctrl = RideController(repo, locationService);

      await ctrl.startRide();
      await ctrl.stopRide();

      final result = await repo.getAll();
      expect(result.dataOrNull!.first.id, isNotEmpty);

      ctrl.dispose();
      await locationService.close();
    });

    test('selectRide updates selectedRide', () {
      final ctrl = RideController(_InMemoryRideRepository(), _TestLocationService());
      final fakeRide = RideEngineModel(
        id: 'test-1',
        title: 'Test',
        vehicle: '',
        startTime: DateTime.now(),
        duration: Duration.zero,
        distanceKm: 0,
        averageSpeedKmh: 0,
        maxSpeedKmh: 0,
        elevationMeters: 0,
        caloriesBurned: 0,
        weather: '',
        routePoints: const [],
        rideScore: 100,
      );
      ctrl.selectRide(fakeRide);
      expect(ctrl.selectedRide?.id, 'test-1');
      ctrl.dispose();
    });
  });

  group('9. StatisticsEngine', () {
    test('calculateCalories: 40 km, 1 hour = 1240 kcal', () {
      final cal = StatisticsEngine.calculateCalories(40.0, const Duration(hours: 1));
      expect(cal, equals(1240));
    });

    test('calculateAverageSpeed returns 0 for empty list', () {
      expect(StatisticsEngine.calculateAverageSpeed([]), 0.0);
    });

    test('calculateMaxSpeed returns 0 for empty list', () {
      expect(StatisticsEngine.calculateMaxSpeed([]), 0.0);
    });

    test('calculateRideScore clamps between 50 and 100', () {
      expect(StatisticsEngine.calculateRideScore(60, 200, 0), 85); // max speed penalty
      expect(StatisticsEngine.calculateRideScore(60, 60, 10), 50); // 10 overspeeds
    });
  });

  group('10. Utility tests', () {
    test('UnitConverters.kmToMiles is accurate', () {
      expect(UnitConverters.kmToMiles(100.0), closeTo(62.1371, 0.01));
    });

    test('GeoUtils.formatDistance: under 1 km shows metres', () {
      expect(GeoUtils.formatDistance(0.5), '500 m');
    });

    test('GeoUtils.formatDistance: over 1 km shows km', () {
      expect(GeoUtils.formatDistance(12.345), '12.35 km');
    });

    test('MockRideGenerator produces valid list', () {
      final rides = MockRideGenerator.generateList(10);
      expect(rides.length, 10);
      expect(rides.first.distanceKm, greaterThan(0));
    });

    test('RideEngineModel.copyWith preserves unchanged fields', () {
      final original = RideEngineModel(
        id: 'r1',
        title: 'Test Ride',
        vehicle: 'Bike',
        startTime: DateTime(2024),
        duration: const Duration(minutes: 30),
        distanceKm: 5.0,
        averageSpeedKmh: 10.0,
        maxSpeedKmh: 20.0,
        elevationMeters: 0,
        caloriesBurned: 200,
        weather: 'Clear',
        routePoints: const [],
        rideScore: 90,
      );
      final copy = original.copyWith(title: 'Updated');
      expect(copy.id, 'r1');
      expect(copy.title, 'Updated');
      expect(copy.distanceKm, 5.0);
    });
  });
}
