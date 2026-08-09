import 'dart:async';
import '../../../core/models/ride_point_model.dart';
import '../../../core/services/location_service.dart';
import '../../../core/utils/geo_utils.dart';
import '../../../providers/base_controller.dart';
import '../models/ride_engine_model.dart';
import '../models/route_model.dart';
import '../repositories/ride_repository.dart';
import '../services/statistics_engine.dart';

// ---------------------------------------------------------------------------
// Ride State Machine
// ---------------------------------------------------------------------------
enum RideState {
  idle,
  preparing,
  starting,
  active,
  paused,
  stopping,
  completed,
  failed,
}

// GPS signal quality categories
enum GpsSignalStatus { good, fair, poor, noSignal }

// ---------------------------------------------------------------------------
// GPS Filter Configuration
// ---------------------------------------------------------------------------
class _GpsFilter {
  // Maximum acceptable horizontal accuracy (metres)
  static const double maxAccuracyMeters = 50.0;
  // Minimum movement before we count a new distance sample (metres)
  static const double minMovementMeters = 3.0;
  // Stale-point cut-off: reject points older than this (seconds)
  static const int maxAgeSeconds = 10;
  // Impossible speed threshold: >300 km/h means a GPS glitch
  static const double maxSpeedKmh = 300.0;
  // Impossible jump: >2 km between consecutive samples is a glitch
  static const double maxJumpKm = 2.0;
}

// ---------------------------------------------------------------------------
// RideController
// ---------------------------------------------------------------------------
class RideController extends BaseController {
  RideController(this.repository, this.locationService) {
    loadHistory();
  }

  final RideRepository repository;
  final LocationService locationService;

  // ── Subscriptions / timers ─────────────────────────────────────────────
  StreamSubscription<RidePointModel>? _locationSub;
  Timer? _clockTimer;

  // ── In-memory ride data ────────────────────────────────────────────────
  final List<RoutePoint> _points = [];
  final List<RideEngineModel> rides = [];

  // ── Ride State (named rideState to avoid conflict with BaseController.state) ──
  bool _isDisposed = false;
  RideState _rideState = RideState.idle;
  RideState get rideState => _rideState;

  // ── Timing ────────────────────────────────────────────────────────────
  DateTime? _startedAt;
  DateTime? _pausedAt;
  Duration _pausedTotal = Duration.zero;

  // ── Metrics ───────────────────────────────────────────────────────────
  double _distanceKm = 0.0;
  double _maxSpeedKmh = 0.0;
  double _lastAccuracyM = 0.0;
  RidePointModel? _lastPoint;

  // ── Ride metadata ─────────────────────────────────────────────────────
  String _rideMode = 'solo';
  String _origin = '';
  String _destination = '';

  // ── Error ─────────────────────────────────────────────────────────────
  String? rideError;

  // ── Selected ride (for summary screen) ─────────────────────────────────
  RideEngineModel? selectedRide;

  // ── Convenience getters ────────────────────────────────────────────────
  bool get isIdle => _rideState == RideState.idle;
  bool get isTracking =>
      _rideState == RideState.active || _rideState == RideState.paused;
  bool get isPaused => _rideState == RideState.paused;
  bool get isCompleted => _rideState == RideState.completed;

  Duration get duration {
    if (_startedAt == null) return Duration.zero;
    final end = isPaused ? _pausedAt! : DateTime.now();
    final raw = end.difference(_startedAt!);
    return raw > _pausedTotal ? raw - _pausedTotal : Duration.zero;
  }

  double get distanceKm => _distanceKm;

  double get currentSpeedKmh =>
      _points.isEmpty ? 0.0 : _points.last.speedKmh;

  double get averageSpeedKmh {
    if (_points.isEmpty || duration.inSeconds == 0) return 0.0;
    return _distanceKm / (duration.inSeconds / 3600.0);
  }

  double get maxSpeedKmh => _maxSpeedKmh;

  double get gpsAccuracyMeters => _lastAccuracyM;

  GpsSignalStatus get gpsSignalStatus {
    if (_lastAccuracyM == 0.0) return GpsSignalStatus.noSignal;
    if (_lastAccuracyM <= 15.0) return GpsSignalStatus.good;
    if (_lastAccuracyM <= 30.0) return GpsSignalStatus.fair;
    if (_lastAccuracyM <= 50.0) return GpsSignalStatus.poor;
    return GpsSignalStatus.noSignal;
  }

  String get gpsSignalLabel {
    switch (gpsSignalStatus) {
      case GpsSignalStatus.good:     return 'GOOD';
      case GpsSignalStatus.fair:     return 'FAIR';
      case GpsSignalStatus.poor:     return 'POOR';
      case GpsSignalStatus.noSignal: return 'NO SIGNAL';
    }
  }

  List<RoutePoint> get recordedPoints => List.unmodifiable(_points);

  // ── History ────────────────────────────────────────────────────────────
  Future<void> loadHistory() async {
    final result = await repository.getAll();
    if (result.isSuccess && !_isDisposed) {
      rides
        ..clear()
        ..addAll(result.dataOrNull!);
      notifyListeners();
    }
  }

  // ── Start ──────────────────────────────────────────────────────────────
  /// [mode] is 'solo' or 'group'.
  /// [origin] and [destination] are display names for the ride record.
  Future<void> startRide({
    String mode = 'solo',
    String origin = '',
    String destination = '',
  }) async {
    if (isTracking) return;

    _rideMode = mode;
    _origin = origin;
    _destination = destination;
    rideError = null;

    // Step 1 — Preparing: tell the UI we are about to acquire GPS
    _transition(RideState.preparing);

    // Step 2 — Get a valid first GPS fix
    _transition(RideState.starting);
    final firstResult = await locationService.getCurrentLocation();

    if (firstResult.isFailure) {
      _fail('GPS unavailable: ${firstResult.errorOrNull!.message}');
      return;
    }

    final firstPoint = firstResult.dataOrNull!;
    if (!_isValidPoint(firstPoint, previous: null)) {
      _fail('Invalid GPS fix: coordinates failed validation.');
      return;
    }

    // Step 3 — Active
    _points.clear();
    _distanceKm = 0.0;
    _maxSpeedKmh = 0.0;
    _pausedTotal = Duration.zero;
    _lastPoint = null;
    _startedAt = DateTime.now();
    _recordPoint(firstPoint);

    _transition(RideState.active);

    // 1-second UI refresh timer
    _clockTimer = Timer.periodic(
      const Duration(seconds: 1),
      (_) => notifyListeners(),
    );

    // Continuous GPS stream
    _locationSub = locationService.getLocationStream().listen(
      _onLocationUpdate,
      onError: (e) => _fail('GPS stream error: $e'),
    );
  }

  // ── Location update handler ────────────────────────────────────────────
  void _onLocationUpdate(RidePointModel point) {
    if (_rideState != RideState.active) return; // ignore while paused/stopping

    _lastAccuracyM = point.accuracy;

    if (!_isValidPoint(point, previous: _lastPoint)) return;

    _recordPoint(point);
    notifyListeners();
  }

  // ── Record an accepted GPS point ───────────────────────────────────────
  void _recordPoint(RidePointModel point) {
    final rp = RoutePoint(
      latitude: point.latitude,
      longitude: point.longitude,
      speedKmh: point.speed,
      timestamp: point.timestamp,
      elevationMeters: 0,
      headingDegrees: point.heading,
      accuracyMeters: point.accuracy,
    );

    if (_lastPoint != null) {
      final gapKm = GeoUtils.calculateDistance(
        _lastPoint!.latitude,
        _lastPoint!.longitude,
        point.latitude,
        point.longitude,
      );

      // Only accumulate if movement exceeds the jitter threshold
      final gapMeters = gapKm * 1000;
      if (gapMeters >= _GpsFilter.minMovementMeters) {
        _distanceKm += gapKm;
      }
    }

    _points.add(rp);
    _lastPoint = point;
    _lastAccuracyM = point.accuracy;

    if (point.speed > _maxSpeedKmh) {
      _maxSpeedKmh = point.speed;
    }
  }

  // ── GPS point validation ───────────────────────────────────────────────
  bool _isValidPoint(RidePointModel point, {required RidePointModel? previous}) {
    // 1. Basic coordinate bounds
    if (!point.isValid) return false;

    // 2. Accuracy threshold (0.0 means not reported — allow through)
    if (point.accuracy > _GpsFilter.maxAccuracyMeters && point.accuracy != 0.0) {
      return false;
    }

    // 3. Speed sanity check
    if (point.speed > _GpsFilter.maxSpeedKmh) return false;

    // 4. Stale timestamp — reject points older than cut-off
    final ageMs = DateTime.now().millisecondsSinceEpoch - point.timestamp;
    if (ageMs > _GpsFilter.maxAgeSeconds * 1000) return false;

    if (previous != null) {
      // 5. Impossible location jump
      final jumpKm = GeoUtils.calculateDistance(
        previous.latitude,
        previous.longitude,
        point.latitude,
        point.longitude,
      );
      if (jumpKm > _GpsFilter.maxJumpKm) return false;

      // 6. Impossible speed jump (was stationary, now supersonic)
      if (previous.speed <= 5.0 && point.speed > 200.0) return false;
    }

    return true;
  }

  // ── Pause ──────────────────────────────────────────────────────────────
  void pauseRide() {
    if (_rideState != RideState.active) return;
    _pausedAt = DateTime.now();
    _transition(RideState.paused);
  }

  // ── Resume ─────────────────────────────────────────────────────────────
  void resumeRide() {
    if (_rideState != RideState.paused) return;
    if (_pausedAt != null) {
      _pausedTotal += DateTime.now().difference(_pausedAt!);
      _pausedAt = null;
    }
    _transition(RideState.active);
  }

  // ── Stop ───────────────────────────────────────────────────────────────
  Future<void> stopRide() async {
    if (!isTracking) return;
    _transition(RideState.stopping);

    await _locationSub?.cancel();
    _locationSub = null;
    _clockTimer?.cancel();
    _clockTimer = null;

    final endTime = DateTime.now();
    final finalDuration = duration;
    final avgSpeed = finalDuration.inSeconds == 0
        ? 0.0
        : _distanceKm / (finalDuration.inSeconds / 3600.0);

    final ride = RideEngineModel(
      id: 'ride-${_startedAt!.millisecondsSinceEpoch}',
      userId: '',
      title:
          '${_rideMode == 'group' ? 'Group' : 'Solo'} Ride — ${_formatDateTime(_startedAt!)}',
      rideMode: _rideMode,
      origin: _origin,
      destination: _destination,
      vehicle: 'Unassigned',
      startTime: _startedAt!,
      endTime: endTime,
      duration: finalDuration,
      distanceKm: _distanceKm,
      averageSpeedKmh: avgSpeed,
      maxSpeedKmh: _maxSpeedKmh,
      elevationMeters: 0,
      caloriesBurned: StatisticsEngine.calculateCalories(
        _distanceKm,
        finalDuration,
      ),
      weather: 'Not recorded',
      routePoints: List.unmodifiable(_points),
      rideScore: StatisticsEngine.calculateRideScore(avgSpeed, _maxSpeedKmh, 0),
      status: RideStatus.completed,
    );

    final result = await repository.save(ride);
    if (result.isFailure) {
      _fail('Failed to save ride: ${result.errorOrNull!.message}');
      return;
    }

    selectedRide = ride;
    rides.insert(0, ride);
    _transition(RideState.completed);
  }

  // ── Discard (cancel without saving) ────────────────────────────────────
  void discardRide() {
    _locationSub?.cancel();
    _locationSub = null;
    _clockTimer?.cancel();
    _clockTimer = null;
    _points.clear();
    _lastPoint = null;
    _rideState = RideState.idle;
    notifyListeners();
  }

  // ── Reset to idle (after viewing summary) ──────────────────────────────
  void resetToIdle() {
    _rideState = RideState.idle;
    rideError = null;
    notifyListeners();
  }

  void selectRide(RideEngineModel ride) {
    selectedRide = ride;
    notifyListeners();
  }

  // ── Internal helpers ───────────────────────────────────────────────────
  void _transition(RideState next) {
    _rideState = next;
    notifyListeners();
  }

  void _fail(String message) {
    rideError = message;
    _locationSub?.cancel();
    _locationSub = null;
    _clockTimer?.cancel();
    _clockTimer = null;
    _transition(RideState.failed);
    setState(ViewState.error);
  }

  String _formatDateTime(DateTime dt) {
    final local = dt.toLocal();
    return '${local.day}/${local.month}/${local.year} '
        '${local.hour.toString().padLeft(2, '0')}:${local.minute.toString().padLeft(2, '0')}';
  }

  @override
  void dispose() {
    _isDisposed = true;
    _locationSub?.cancel();
    _clockTimer?.cancel();
    super.dispose();
  }
}

// Expose GpsFilter constants for tests
class GpsFilter {
  static const double maxAccuracyMeters = _GpsFilter.maxAccuracyMeters;
  static const double minMovementMeters = _GpsFilter.minMovementMeters;
  static const int maxAgeSeconds = _GpsFilter.maxAgeSeconds;
  static const double maxSpeedKmh = _GpsFilter.maxSpeedKmh;
  static const double maxJumpKm = _GpsFilter.maxJumpKm;
}

// Keep old alias for any existing references
typedef RideLifecycle = RideState;
