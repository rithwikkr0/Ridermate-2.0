import 'route_model.dart';

/// Data model representing an ongoing, uncompleted ride session draft.
/// Used to recover active ride tracking after process termination or app restart.
class ActiveRideDraft {
  final String id;
  final String userId;
  final String rideMode;
  final String origin;
  final String destination;
  final DateTime startTime;
  final Duration pausedTotal;
  final bool isPaused;
  final DateTime? pausedAt;
  final double distanceKm;
  final double maxSpeedKmh;
  final List<RoutePoint> points;

  const ActiveRideDraft({
    required this.id,
    required this.userId,
    required this.rideMode,
    required this.origin,
    required this.destination,
    required this.startTime,
    required this.pausedTotal,
    required this.isPaused,
    this.pausedAt,
    required this.distanceKm,
    required this.maxSpeedKmh,
    required this.points,
  });
}
