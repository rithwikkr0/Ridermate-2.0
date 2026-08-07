import 'route_model.dart';

/// RiderMate 2.0 — Core Ride Engine Model
class RideEngineModel {
  final String id;
  final String title;
  final String vehicle;
  final DateTime startTime;
  final DateTime? endTime;
  final Duration duration;
  final double distanceKm;
  final double averageSpeedKmh;
  final double maxSpeedKmh;
  final double elevationMeters;
  final int caloriesBurned;
  final String weather;
  final List<RoutePoint> routePoints;
  final int rideScore;

  const RideEngineModel({
    required this.id,
    required this.title,
    required this.vehicle,
    required this.startTime,
    this.endTime,
    required this.duration,
    required this.distanceKm,
    required this.averageSpeedKmh,
    required this.maxSpeedKmh,
    required this.elevationMeters,
    required this.caloriesBurned,
    required this.weather,
    required this.routePoints,
    required this.rideScore,
  });

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'vehicle': vehicle,
        'startTime': startTime.toIso8601String(),
        'endTime': endTime?.toIso8601String(),
        'durationSeconds': duration.inSeconds,
        'distanceKm': distanceKm,
        'averageSpeedKmh': averageSpeedKmh,
        'maxSpeedKmh': maxSpeedKmh,
        'elevationMeters': elevationMeters,
        'caloriesBurned': caloriesBurned,
        'weather': weather,
        'routePoints': routePoints.map((p) => p.toJson()).toList(),
        'rideScore': rideScore,
      };
}
