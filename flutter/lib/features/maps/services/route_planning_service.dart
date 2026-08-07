import '../models/navigation_route_model.dart';
import '../../rides/models/route_model.dart';

abstract class RoutePlanningService {
  Future<List<NavigationRouteModel>> planRoutes({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    bool avoidTolls = false,
    bool avoidHighways = false,
  });
}

class MockRoutePlanningService implements RoutePlanningService {
  @override
  Future<List<NavigationRouteModel>> planRoutes({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    bool avoidTolls = false,
    bool avoidHighways = false,
  }) async {
    await Future.delayed(const Duration(milliseconds: 300));
    final mockPoints = List.generate(
      15,
      (i) => RoutePoint(
        latitude: startLat + (i * 0.002),
        longitude: startLng + (i * 0.002),
        speedKmh: 45.0,
        timestamp: DateTime.now().millisecondsSinceEpoch + (i * 120000),
        elevationMeters: 100.0 + (i * 5),
      ),
    );

    return [
      NavigationRouteModel(
        id: 'route-fastest',
        name: 'Western Express Highway',
        type: RouteType.fastest,
        distanceKm: 22.4,
        estimatedDuration: const Duration(minutes: 32),
        elevationGainMeters: 140.0,
        difficulty: 'Easy',
        hasTolls: true,
        hasHighways: true,
        points: mockPoints,
      ),
      NavigationRouteModel(
        id: 'route-scenic',
        name: 'Coastal Road Route',
        type: RouteType.scenic,
        distanceKm: 26.8,
        estimatedDuration: const Duration(minutes: 42),
        elevationGainMeters: 280.0,
        difficulty: 'Moderate',
        hasTolls: false,
        hasHighways: false,
        points: mockPoints,
      ),
    ];
  }
}
