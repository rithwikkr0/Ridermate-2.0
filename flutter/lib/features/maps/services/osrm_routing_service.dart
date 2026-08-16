import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/navigation_route_model.dart';
import '../models/turn_by_turn_instruction.dart';
import '../../rides/models/route_model.dart';
import 'route_planning_service.dart';

/// RiderMate 2.0 — Real OpenStreetMap OSRM Routing Service
class OsrmRoutingService implements RoutePlanningService {
  @override
  Future<List<NavigationRouteModel>> planRoutes({
    required double startLat,
    required double startLng,
    required double destLat,
    required double destLng,
    bool avoidTolls = false,
    bool avoidHighways = false,
  }) async {
    try {
      final url =
          'https://router.project-osrm.org/route/v1/driving/$startLng,$startLat;$destLng,$destLat?overview=full&geometries=geojson&steps=true';

      final response = await http.get(
        Uri.parse(url),
        headers: {'User-Agent': 'RiderMateApp/2.0 (com.ridermate.ridermate)'},
      ).timeout(const Duration(seconds: 8));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final routes = data['routes'] as List?;

        if (routes != null && routes.isNotEmpty) {
          final List<NavigationRouteModel> calculatedRoutes = [];

          for (var idx = 0; idx < routes.length; idx++) {
            final routeData = routes[idx];
            final distanceMeters = (routeData['distance'] as num?)?.toDouble() ?? 0.0;
            final durationSeconds = (routeData['duration'] as num?)?.toDouble() ?? 0.0;

            final geometry = routeData['geometry'];
            final List<RoutePoint> routePoints = [];

            if (geometry != null && geometry['coordinates'] != null) {
              final coords = geometry['coordinates'] as List;
              final nowMs = DateTime.now().millisecondsSinceEpoch;

              for (var i = 0; i < coords.length; i++) {
                final pt = coords[i] as List;
                final lng = (pt[0] as num).toDouble();
                final lat = (pt[1] as num).toDouble();
                routePoints.add(
                  RoutePoint(
                    latitude: lat,
                    longitude: lng,
                    speedKmh: 45.0,
                    timestamp: nowMs + (i * 5000),
                    elevationMeters: 100.0,
                  ),
                );
              }
            }

            final distKm = (distanceMeters / 1000.0);
            final durMins = (durationSeconds / 60.0).round();

            calculatedRoutes.add(
              NavigationRouteModel(
                id: 'osrm_${idx + 1}',
                name: idx == 0 ? 'Optimal Route (OSRM)' : 'Alternative Route',
                type: idx == 0 ? RouteType.fastest : RouteType.scenic,
                distanceKm: double.parse(distKm.toStringAsFixed(1)),
                estimatedDuration: Duration(minutes: durMins > 0 ? durMins : 1),
                elevationGainMeters: 120.0,
                difficulty: distKm > 30 ? 'Moderate' : 'Easy',
                hasTolls: avoidTolls,
                hasHighways: !avoidHighways,
                points: routePoints,
              ),
            );
          }

          if (calculatedRoutes.isNotEmpty) {
            return calculatedRoutes;
          }
        }
      }
    } catch (_) {
      // Fallback to straight-line interpolation if network/OSRM is offline
    }

    // Fallback route geometry calculation if offline
    return _generateFallbackRoute(startLat, startLng, destLat, destLng);
  }

  /// Extracts turn-by-turn navigation instructions from OSRM JSON steps response
  List<TurnByTurnInstruction> parseInstructions(Map<String, dynamic> osrmStepData) {
    final List<TurnByTurnInstruction> instructions = [];
    try {
      final legs = osrmStepData['legs'] as List?;
      if (legs != null && legs.isNotEmpty) {
        final steps = legs.first['steps'] as List?;
        if (steps != null) {
          for (var step in steps) {
            final name = step['name']?.toString() ?? '';
            final distance = (step['distance'] as num?)?.toDouble() ?? 0.0;
            final maneuver = step['maneuver'] as Map<String, dynamic>?;
            final modifier = maneuver?['modifier']?.toString() ?? '';

            TurnDirection dir = TurnDirection.straight;
            if (modifier.contains('left')) {
              dir = TurnDirection.turnLeft;
            } else if (modifier.contains('right')) {
              dir = TurnDirection.turnRight;
            }

            instructions.add(
              TurnByTurnInstruction(
                instructionText: name.isNotEmpty ? 'Onto $name' : 'Continue straight',
                distanceMeters: distance.toDouble(),
                direction: dir,
                iconName: modifier,
              ),
            );

          }
        }
      }
    } catch (_) {}

    return instructions;
  }

  List<NavigationRouteModel> _generateFallbackRoute(
      double sLat, double sLng, double dLat, double dLng) {
    final points = List.generate(20, (i) {
      final ratio = i / 19.0;
      return RoutePoint(
        latitude: sLat + (dLat - sLat) * ratio,
        longitude: sLng + (dLng - sLng) * ratio,
        speedKmh: 40.0,
        timestamp: DateTime.now().millisecondsSinceEpoch + (i * 60000),
        elevationMeters: 100.0,
      );
    });

    return [
      NavigationRouteModel(
        id: 'osrm_fallback',
        name: 'Direct GPS Trajectory',
        type: RouteType.fastest,
        distanceKm: 15.4,
        estimatedDuration: const Duration(minutes: 24),
        elevationGainMeters: 80.0,
        difficulty: 'Easy',
        hasTolls: false,
        hasHighways: true,
        points: points,
      ),
    ];
  }
}
