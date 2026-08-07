import 'navigation_route_model.dart';

class RouteComparisonModel {
  final NavigationRouteModel primaryRoute;
  final NavigationRouteModel alternativeRoute;

  const RouteComparisonModel({
    required this.primaryRoute,
    required this.alternativeRoute,
  });

  double get distanceDifferenceKm => alternativeRoute.distanceKm - primaryRoute.distanceKm;
  int get durationDifferenceMinutes => alternativeRoute.estimatedDuration.inMinutes - primaryRoute.estimatedDuration.inMinutes;
}
