import 'route_model.dart';

/// All possible states of a ride from start to finish.
enum RideStatus {
  idle,
  preparing,
  starting,
  active,
  paused,
  stopping,
  completed,
  failed,
}

/// RiderMate 2.0 — Core Ride Engine Model
class RideEngineModel {
  final String id;
  final String userId;
  final String title;
  final String rideMode; // 'solo' | 'group'
  final String origin;
  final String destination;
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
  final RideStatus status;

  const RideEngineModel({
    required this.id,
    this.userId = '',
    required this.title,
    this.rideMode = 'solo',
    this.origin = '',
    this.destination = '',
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
    this.status = RideStatus.completed,
  });

  RideEngineModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? rideMode,
    String? origin,
    String? destination,
    String? vehicle,
    DateTime? startTime,
    DateTime? endTime,
    Duration? duration,
    double? distanceKm,
    double? averageSpeedKmh,
    double? maxSpeedKmh,
    double? elevationMeters,
    int? caloriesBurned,
    String? weather,
    List<RoutePoint>? routePoints,
    int? rideScore,
    RideStatus? status,
  }) {
    return RideEngineModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      rideMode: rideMode ?? this.rideMode,
      origin: origin ?? this.origin,
      destination: destination ?? this.destination,
      vehicle: vehicle ?? this.vehicle,
      startTime: startTime ?? this.startTime,
      endTime: endTime ?? this.endTime,
      duration: duration ?? this.duration,
      distanceKm: distanceKm ?? this.distanceKm,
      averageSpeedKmh: averageSpeedKmh ?? this.averageSpeedKmh,
      maxSpeedKmh: maxSpeedKmh ?? this.maxSpeedKmh,
      elevationMeters: elevationMeters ?? this.elevationMeters,
      caloriesBurned: caloriesBurned ?? this.caloriesBurned,
      weather: weather ?? this.weather,
      routePoints: routePoints ?? this.routePoints,
      rideScore: rideScore ?? this.rideScore,
      status: status ?? this.status,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'title': title,
        'rideMode': rideMode,
        'origin': origin,
        'destination': destination,
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
        'status': status.name,
      };
}
