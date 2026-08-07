import '../../rides/models/route_model.dart';

enum RouteType { fastest, shortest, scenic, eco }

/// RiderMate 2.0 — Navigation Route Model
class NavigationRouteModel {
  final String id;
  final String name;
  final RouteType type;
  final double distanceKm;
  final Duration estimatedDuration;
  final double elevationGainMeters;
  final String difficulty;
  final bool hasTolls;
  final bool hasHighways;
  final List<RoutePoint> points;

  const NavigationRouteModel({
    required this.id,
    required this.name,
    required this.type,
    required this.distanceKm,
    required this.estimatedDuration,
    required this.elevationGainMeters,
    required this.difficulty,
    required this.hasTolls,
    required this.hasHighways,
    required this.points,
  });
}
