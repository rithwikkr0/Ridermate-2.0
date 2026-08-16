import 'dart:async';
import '../../../core/notifications/services/notification_service.dart';
import '../models/traffic_violation_model.dart';
import '../repositories/sqlite_traffic_repository.dart';

/// RiderMate 2.0 — Traffic Points & Safety Evaluation Engine
class TrafficPointsEngine {
  static final TrafficPointsEngine instance = TrafficPointsEngine._();
  TrafficPointsEngine._();

  final SqliteTrafficRepository _repository = SqliteTrafficRepository();

  // In-memory cooldowns to prevent spamming duplicate violations
  final Map<String, DateTime> _cooldowns = {};

  /// Evaluates an overspeed event and records points deduction.
  ///
  /// Points Table:
  ///   Minor overspeed (81–95 km/h): Low (-2 pts)
  ///   Moderate overspeed (96–110 km/h): Medium (-5 pts)
  ///   Severe overspeed (>110 km/h): High (-10 pts)
  Future<void> evaluateOverspeed({
    required String userId,
    required String rideId,
    required double currentSpeedKmh,
    double speedLimitKmh = 80.0,
    double? latitude,
    double? longitude,
  }) async {
    if (userId.isEmpty || userId == 'user_guest') return;
    if (currentSpeedKmh <= speedLimitKmh) return;

    final key = 'overspeed_${userId}_$rideId';
    if (_cooldowns.containsKey(key)) {
      final last = _cooldowns[key]!;
      if (DateTime.now().difference(last) < const Duration(seconds: 30)) {
        return; // Throttled within 30-second window
      }
    }

    ViolationSeverity severity = ViolationSeverity.low;
    int points = 2;

    if (currentSpeedKmh > 110.0) {
      severity = ViolationSeverity.high;
      points = 10;
    } else if (currentSpeedKmh > 95.0) {
      severity = ViolationSeverity.medium;
      points = 5;
    }

    final violation = TrafficViolation(
      id: 'viol_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      rideId: rideId,
      type: ViolationType.overspeed,
      severity: severity,
      pointsDeducted: points,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      speedKmh: currentSpeedKmh,
      speedLimitKmh: speedLimitKmh,
      confidence: 0.95,
      source: 'gps_telemetry',
      evidence: 'Speed ${currentSpeedKmh.toStringAsFixed(0)} km/h on $speedLimitKmh km/h zone',
    );

    await _repository.recordViolation(violation);
    _cooldowns[key] = DateTime.now();

    // Trigger Notification
    await NotificationService.instance.notifySafetyWarning(
      title: '⚠️ Safety Points Deducted (-$points)',
      body: 'Speed ${currentSpeedKmh.toStringAsFixed(0)} km/h exceeds limit. Current score updated.',
      rideId: rideId,
      userId: userId,
      cooldown: const Duration(seconds: 30),
    );
  }

  /// Evaluates harsh braking or acceleration events.
  Future<void> evaluateGForceEvent({
    required String userId,
    required String rideId,
    required ViolationType type, // harshBraking or harshAcceleration
    required double deltaKmh,
    double? latitude,
    double? longitude,
  }) async {
    if (userId.isEmpty || userId == 'user_guest') return;

    final key = '${type.name}_${userId}_$rideId';
    if (_cooldowns.containsKey(key)) {
      if (DateTime.now().difference(_cooldowns[key]!) < const Duration(seconds: 30)) return;
    }

    final violation = TrafficViolation(
      id: 'viol_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      rideId: rideId,
      type: type,
      severity: ViolationSeverity.low,
      pointsDeducted: 2,
      timestamp: DateTime.now(),
      latitude: latitude,
      longitude: longitude,
      speedKmh: deltaKmh,
      confidence: 0.9,
      source: 'accelerometer_telemetry',
      evidence: '${type.displayName}: delta ${deltaKmh.toStringAsFixed(1)} km/h',
    );

    await _repository.recordViolation(violation);
    _cooldowns[key] = DateTime.now();
  }
}
